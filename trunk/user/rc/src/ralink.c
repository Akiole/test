/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

/*
 * stage2c: ralink.c rewritten for mt76 + hostapd.
 *
 * What changed vs. the 4.4 SDK era:
 *  - The huge gen_ralink_config() that rendered RT2860AP.dat / iNIC_ap.dat
 *    is replaced by gen_hostapd_conf() which writes
 *    /var/run/hostapd-<2g|5g>-<main|guest>.conf per design §1.1.
 *  - The private regulatory tables (asus_regspec_table / ralink_cc_table)
 *    and the SingleSKU symlink chain are deleted; cfg80211 regdb replaces
 *    them. Country code is now applied via `iw reg set <CC>` and written
 *    into hostapd.conf as country_code=<CC>.
 *  - get_apcli_connected() no longer uses SIOCGIWAP/WEXT; it parses
 *    `wpa_cli -i <sta0> status` for wpa_state=COMPLETED.
 *  - WPS PIN storage moves from Factory to nvram "secret_code" (the
 *    standard Padavan location); the WPS checksum validation in
 *    pinvalidate() is kept unchanged.
 *  - Wireless MAC set at runtime uses `ip link set <if> address <mac>`;
 *    Factory write is intentionally NOT done (nvmem macaddr@4 is the
 *    source of truth). Reading the Factory MAC for UI display is kept.
 *  - Wired MAC helpers (get/set_wired_mac*, detect_lan_mac_offset) are
 *    unchanged: they still read/write the Factory partition for the
 *    DSA CPU/port MAC carrier (br0 / wan).
 */

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <net/if_arp.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

#include <ralink_priv.h>
#include <flash_mtd.h>

#include "rc.h"

#define MAX_FRW 64

/* 判断 MAC 地址是否为有效真实 MAC（非全0/全FF/组播/Padavan默认前缀） */
static int
is_valid_real_mac(const unsigned char *mac)
{
	if (mac[0] & 0x01)
		return 0;
	if (mac[0] == 0x00 && mac[1] == 0x00 && mac[2] == 0x00 &&
	    mac[3] == 0x00 && mac[4] == 0x00 && mac[5] == 0x00)
		return 0;
	if (mac[0] == 0xFF && mac[1] == 0xFF && mac[2] == 0xFF &&
	    mac[3] == 0xFF && mac[4] == 0xFF && mac[5] == 0xFF)
		return 0;
	/* Padavan 默认 MAC 前缀 00:11:22:33:44:xx（未初始化的假MAC） */
	if (mac[0] == 0x00 && mac[1] == 0x11 && mac[2] == 0x22 &&
	    mac[3] == 0x33 && mac[4] == 0x44)
		return 0;
	return 1;
}

/* 自动探测 Factory 分区中 LAN MAC 的偏移（缓存结果，只探测一次） */
static int
detect_lan_mac_offset(void)
{
	static int s_detected_offset = -1;
	static const int s_candidate_offsets[] = {
		0xe000,   /* 最常见 (MT7621 default: R2100 / FCJ / K2P / MI-R3G 等) */
		0x3FFFA,  /* 新一代 NAND 板子 (CR660x / 360 / JCG / CMCC 等) */
		0xe006,   /* 部分板子 */
		0x018E,   /* N14U / N11P */
	};
	unsigned char mac[6];
	int i;

	if (s_detected_offset >= 0)
		return s_detected_offset;

	for (i = 0; i < (int)(sizeof(s_candidate_offsets) / sizeof(s_candidate_offsets[0])); i++) {
		if (flash_mtd_read(MTD_PART_NAME_FACTORY, s_candidate_offsets[i], mac, sizeof(mac)) == 0) {
			if (is_valid_real_mac(mac)) {
				s_detected_offset = s_candidate_offsets[i];
				return s_detected_offset;
			}
		}
	}

	/* 兜底：使用默认偏移 */
	s_detected_offset = OFFSET_MAC_GMAC0;
	return s_detected_offset;
}

inline int
get_wired_mac_is_single(void)
{
	static int s_is_single = -1;
	unsigned char lan_mac[6], wan_mac[6];
	int lan_offset, wan_offset;

	if (s_is_single >= 0)
		return s_is_single;

	lan_offset = detect_lan_mac_offset();
	wan_offset = lan_offset + 6;  /* WAN MAC 通常在 LAN MAC 后 6 字节 */

	if (flash_mtd_read(MTD_PART_NAME_FACTORY, lan_offset, lan_mac, sizeof(lan_mac)) != 0 ||
	    flash_mtd_read(MTD_PART_NAME_FACTORY, wan_offset, wan_mac, sizeof(wan_mac)) != 0) {
		s_is_single = 1;
		return s_is_single;
	}

	if (!is_valid_real_mac(wan_mac) || memcmp(wan_mac, lan_mac, 3) != 0) {
		s_is_single = 1;
	} else {
		s_is_single = 0;
	}

	return s_is_single;
}

inline int
get_wired_mac_e2p_offset(int is_wan)
{
	int lan_offset = detect_lan_mac_offset();
	return (is_wan) ? lan_offset + 6 : lan_offset;
}

int
get_wired_mac(int is_wan)
{
	char macaddr[18] = {0};
	unsigned char buffer[ETHER_ADDR_LEN] = {0};
	int i_offset;

	i_offset = get_wired_mac_e2p_offset(is_wan);
	if (flash_mtd_read(MTD_PART_NAME_FACTORY, i_offset, buffer, ETHER_ADDR_LEN) < 0) {
		puts("Unable to read MAC from EEPROM!");
		return -1;
	}

	if (is_wan && get_wired_mac_is_single())
		buffer[5] |= 0x03;

	ether_etoa(buffer, macaddr);

	printf("%s EEPROM MAC address: %s\n", (is_wan) ? "WAN" : "LAN", macaddr);

	return 0;
}

int
set_wired_mac(int is_wan, const char *mac)
{
	unsigned char ea[ETHER_ADDR_LEN] = {0};
	int i_offset;

	if (is_wan && get_wired_mac_is_single()) {
		printf("This device has only single wired MAC-address!\n");
		return EINVAL;
	}

	if (ether_atoe(mac, ea)) {
		i_offset = get_wired_mac_e2p_offset(is_wan);
		if (flash_mtd_write(MTD_PART_NAME_FACTORY, i_offset, ea, ETHER_ADDR_LEN) == 0) {
			if (get_wired_mac(is_wan) == 0)
				puts("\nPlease reboot router!");
		} else {
			puts("Write MAC to EEPROM FAILED!");
			return -1;
		}
	} else {
		printf("MAC [%s] is not valid MAC address!\n", mac);
		return EINVAL;
	}

	return 0;
}

inline int
get_wireless_mac_e2p_offset(int is_5ghz)
{
	/*
	 * stage2c: mt76 loads its MAC from nvmem macaddr@4 (DTS), so the
	 * Factory offset is only used as a UI display fallback. The two
	 * BSSes on a DBDC phy share the same base MAC; we just return the
	 * single wireless MAC offset.
	 */
	(void)is_5ghz;
	return OFFSET_MAC_ADDR_WSOC;
}

int
get_wireless_mac(int is_5ghz)
{
	char macaddr[18] = {0};
	unsigned char buffer[ETHER_ADDR_LEN] = {0};
	int i_offset;

	i_offset = get_wireless_mac_e2p_offset(is_5ghz);
	if (flash_mtd_read(MTD_PART_NAME_FACTORY, i_offset, buffer, ETHER_ADDR_LEN) < 0) {
		puts("Unable to read wireless MAC from EEPROM!");
		return -1;
	}

	ether_etoa(buffer, macaddr);
#if BOARD_HAS_5G_RADIO
	printf("%s EEPROM MAC address: %s\n", (is_5ghz) ? "5GHz" : "2.4GHz", macaddr);
#else
	printf("2.4GHz EEPROM MAC address: %s\n", macaddr);
#endif

	return 0;
}

int
set_wireless_mac(int is_5ghz, const char *mac)
{
	/*
	 * stage2c: runtime MAC change via `ip link set <if> address <mac>`.
	 * We do NOT write Factory (nvmem macaddr@4 is read-only at runtime
	 * and a Factory write would brick the calibration layout). The
	 * caller is expected to restart hostapd after this.
	 */
	const char *ifname = is_5ghz ? IFNAME_5G_MAIN : IFNAME_2G_MAIN;

	if (is_5ghz)
		(void)IFNAME_5G_MAIN;

	doSystem("ip link set %s address %s 2>/dev/null", ifname, mac);
	printf("Wireless MAC set to %s on %s (hostapd restart required)\n", mac, ifname);
	return 0;
}

int
get_wireless_cc(void)
{
	/* stage2c: country code lives in nvram wl_country_code; cfg80211
	 * regdb enforces it via `iw reg set`. Display the nvram value. */
	char *cc = nvram_safe_get("wl_country_code");
	if (cc && cc[0] && cc[1])
		printf("Current regdomain: %s\n", cc);
	else
		printf("Current regdomain: 00 (default)\n");
	return 0;
}

int
set_wireless_cc(const char *cc)
{
	/* stage2c: validate 2-letter code, persist to nvram, apply via
	 * `iw reg set`. cfg80211 regdb replaces the old ralink_cc_table. */
	if (!cc || strlen(cc) != 2) {
		puts("Invalid Country Code (expected 2 letters)!");
		return EINVAL;
	}

	nvram_set("wl_country_code", (char *)cc);
	nvram_set("rt_country_code", (char *)cc);
	doSystem("iw reg set %s 2>/dev/null", cc);
	printf("Regdomain set to %s (applied via cfg80211 regdb)\n", cc);
	return 0;
}

int
atoh(const char *a, unsigned char *e)
{
	char *c = (char *) a;
	int i = 0;

	memset(e, 0, MAX_FRW);
	for (;;) {
		e[i++] = (unsigned char) strtoul(c, &c, 16);
		if (!*c++ || i == MAX_FRW)
			break;
	}
	return i;
}

char*
htoa(const unsigned char *e, char *a, int len)
{
	char *c = a;
	int i;

	for (i = 0; i < len; i++) {
		if (i)
			*c++ = ':';
		c += sprintf(c, "%02X", e[i] & 0xff);
	}
	return a;
}

int
pincheck(const char *a)
{
	unsigned char *c = (char *) a;
	int i = 0;

	for (;;) {
		if (*c>0x39 || *c<0x30)
			break;
		else
			i++;
		if (!*c++ || i == 8)
			break;
	}
	return (i == 8);
}

int
pinvalidate(const char *pin_string)
{
	unsigned long PIN = strtoul(pin_string, NULL, 10);
	unsigned long int accum = 0;
	unsigned int len = strlen(pin_string);

	if (len != 4 && len != 8)
		return  -1;

	if (len == 8) {
		accum += 3 * ((PIN / 10000000) % 10);
		accum += 1 * ((PIN / 1000000) % 10);
		accum += 3 * ((PIN / 100000) % 10);
		accum += 1 * ((PIN / 10000) % 10);
		accum += 3 * ((PIN / 1000) % 10);
		accum += 1 * ((PIN / 100) % 10);
		accum += 3 * ((PIN / 10) % 10);
		accum += 1 * ((PIN / 1) % 10);

		if (0 == (accum % 10))
			return 0;
	}
	else if (len == 4)
		return 0;

	return -1;
}

int
setPIN(const char *pin)
{
	/* stage2c: store WPS PIN in nvram "secret_code" instead of Factory. */
	if (pincheck(pin) && !pinvalidate(pin)) {
		nvram_set("secret_code", (char *)pin);
		puts(pin);
	}
	return 0;
}

int
getBootVer(void)
{
	unsigned char bootv[5] = {0};

	flash_mtd_read(MTD_PART_NAME_FACTORY, OFFSET_BOOT_VER, bootv, 4);
	puts(bootv);

	return 0;
}

int
getPIN(void)
{
	char *pin = nvram_safe_get("secret_code");
	if (pin && pin[0])
		puts(pin);
	return 0;
}

/*
 * ------------------------------------------------------------------
 * hostapd.conf generation (replaces the old gen_ralink_config).
 * ------------------------------------------------------------------
 */

/* Map nvram auth_mode + wpa_mode + pmf to hostapd wpa= / wpa_key_mgmt=. */
static void
render_auth(FILE *fp, int is_aband)
{
	char *auth_mode = nvram_wlan_get(is_aband, "auth_mode");
	int wpa_mode   = nvram_wlan_get_int(is_aband, "wpa_mode");
	int pmf        = nvram_wlan_get_int(is_aband, "pmf");
	char *crypto   = nvram_wlan_get(is_aband, "crypto");
	int wpa_val = 0, ieee80211w = 0;
	char key_mgmt[64] = "NONE";
	char rsn_pairwise[32] = "CCMP";

	if (!strcmp(auth_mode, "psk")) {
		switch (wpa_mode) {
		case 1:  wpa_val = 1; snprintf(key_mgmt, sizeof(key_mgmt), "%s", "WPA-PSK"); break;
		case 5:  wpa_val = 3; snprintf(key_mgmt, sizeof(key_mgmt), "%s", "SAE"); break;
		case 6:  wpa_val = 3; snprintf(key_mgmt, sizeof(key_mgmt), "%s", "WPA-PSK SAE"); break;
		case 2:
		default:
			wpa_val = 2;
			snprintf(key_mgmt, sizeof(key_mgmt), "%s",
				(wpa_mode == 4) ? "WPA-PSK" : "WPA-PSK");
			break;
		}
		if (wpa_mode == 5 || wpa_mode == 6)
			ieee80211w = 2;
		else if (pmf == 1)
			ieee80211w = 1;
		else if (pmf == 2)
			ieee80211w = 2;
	} else if (!strcmp(auth_mode, "wpa") || !strcmp(auth_mode, "wpa2")) {
		wpa_val = 2;
		snprintf(key_mgmt, sizeof(key_mgmt), "%s", "WPA-EAA");
		ieee80211w = pmf ? 1 : 0;
	} else if (!strcmp(auth_mode, "radius")) {
		wpa_val = 2;
		snprintf(key_mgmt, sizeof(key_mgmt), "%s", "WPA-EAP");
	} else if (!strcmp(auth_mode, "owe")) {
		wpa_val = 2;
		snprintf(key_mgmt, sizeof(key_mgmt), "%s", "OWE");
		ieee80211w = 2;
	} else {
		/* open / shared */
		wpa_val = 0;
		snprintf(key_mgmt, sizeof(key_mgmt), "%s", "NONE");
	}

	/* crypto: TKIP/AES applies to WPA-PSK only */
	if (wpa_val > 0 && strcmp(key_mgmt, "SAE") != 0 && strcmp(key_mgmt, "OWE") != 0) {
		if (!strcmp(crypto, "tkip"))
			snprintf(rsn_pairwise, sizeof(rsn_pairwise), "%s", "TKIP");
		else if (!strcmp(crypto, "tkip+aes"))
			snprintf(rsn_pairwise, sizeof(rsn_pairwise), "%s", "CCMP TKIP");
		else
			snprintf(rsn_pairwise, sizeof(rsn_pairwise), "%s", "CCMP");
	}

	fprintf(fp, "wpa=%d\n", wpa_val);
	fprintf(fp, "wpa_key_mgmt=%s\n", key_mgmt);
	fprintf(fp, "rsn_pairwise=%s\n", rsn_pairwise);
	fprintf(fp, "ieee80211w=%d\n", ieee80211w);
}

/* Render MAC ACL file (accept/deny list) from nvram maclist_x/macnum_x. */
static void
render_mac_acl(FILE *fp, int is_aband, const char *prefix_bss)
{
	char *macmode = nvram_wlan_get(is_aband, "macmode");
	int macnum = nvram_wlan_get_int(is_aband, "macnum_x");
	int acl = 0;  /* 0=none, 1=deny, 2=allow */
	char path[64], line[64];
	FILE *acl_fp;
	int i;

	if (!strcmp(macmode, "deny"))
		acl = 1;
	else if (!strcmp(macmode, "allow"))
		acl = 2;

	fprintf(fp, "macaddr_acl=%d\n", acl);
	if (acl == 0 || macnum <= 0)
		return;

	snprintf(path, sizeof(path), "/var/run/hostapd.%s",
		(acl == 1) ? "deny" : "accept");
	acl_fp = fopen(path, "w");
	if (!acl_fp)
		return;

	for (i = 0; i < macnum; i++) {
		mac_conv((char *)(prefix_bss[0] ? "wl_maclist_x" : "rt_maclist_x"), i, line);
		fprintf(acl_fp, "%s\n", line);
	}
	fclose(acl_fp);

	fprintf(fp, "%s_mac_file=%s\n",
		(acl == 1) ? "deny" : "accept", path);
}

/*
 * Render /var/run/hostapd-<band>-<bss>.conf for one BSS.
 * is_aband: 0=2.4G, 1=5G. bss_index: 0=main, 1=guest.
 */
static int
gen_hostapd_conf(int is_aband, int bss_index)
{
	const char *band_tag = is_aband ? "5g" : "2g";
	const char *bss_tag = bss_index == 0 ? "main" : "guest";
	const char *ifname;
	const char *ssid_nv, *psk_nv, *auth_nv, *crypto_nv, *wpa_mode_nv;
	const char *country_cc;
	int channel, ht_bw, gmode, bcn, dtim, rts, frag, wme, gtk_rekey;
	int closed, ap_isolate, wps_enabled, pmf;
	char path[80];
	FILE *fp;
	int is_5g = is_aband;

	/* pick nvram prefix (guest BSS uses guest_* keys) */
	if (bss_index == 0) {
		ssid_nv    = "ssid";
		psk_nv     = "wpa_psk";
		auth_nv    = "auth_mode";
		crypto_nv  = "crypto";
		wpa_mode_nv= "wpa_mode";
	} else {
		ssid_nv    = "guest_ssid";
		psk_nv     = "guest_wpa_psk";
		auth_nv    = "guest_auth_mode";
		crypto_nv  = "guest_crypto";
		wpa_mode_nv= "guest_wpa_mode";
	}

	ifname = bss_index == 0
		? (is_aband ? IFNAME_5G_MAIN  : IFNAME_2G_MAIN)
		: (is_aband ? IFNAME_5G_GUEST : IFNAME_2G_GUEST);

	snprintf(path, sizeof(path), "/var/run/hostapd-%s-%s.conf", band_tag, bss_tag);
	if (!(fp = fopen(path, "w"))) {
		perror(path);
		return -1;
	}

	fprintf(fp, "# Generated by rc (stage2c hostapd.conf)\n");
	fprintf(fp, "interface=%s\n", ifname);
	fprintf(fp, "driver=nl80211\n");
	fprintf(fp, "ctrl_interface=/var/run/hostapd\n");
	fprintf(fp, "ctrl_interface_group=0\n");

	/* SSID */
	fprintf(fp, "ssid=%s\n", nvram_wlan_get(is_aband, ssid_nv));
	closed = nvram_wlan_get_int(is_aband, bss_index == 0 ? "closed" : "guest_closed");
	fprintf(fp, "ignore_broadcast_ssid=%d\n", closed ? 1 : 0);

	/* Country code: prefer per-band nvram, fall back to wl_country_code */
	country_cc = nvram_wlan_get(is_aband, "country_code");
	if (!country_cc || strlen(country_cc) != 2)
		country_cc = nvram_safe_get("wl_country_code");
	if (country_cc && strlen(country_cc) == 2)
		fprintf(fp, "country_code=%s\n", country_cc);

	/* PHY mode / band */
	fprintf(fp, "hw_mode=%s\n", is_aband ? "a" : "g");
	fprintf(fp, "ieee80211n=1\n");
	if (is_aband)
		fprintf(fp, "ieee80211ac=1\n");

	gmode = nvram_wlan_get_int(is_aband, "gmode");
	/* gmode: for 2.4G 6=ax, for 5G 5=ax/ac. Enable HE (802.11ax) when set. */
	if ((!is_aband && gmode == 6) || (is_aband && gmode == 5))
		fprintf(fp, "ieee80211ax=1\n");

	/* Channel (0 = ACS / leave to driver) */
	channel = nvram_wlan_get_int(is_aband, "channel");
	if (channel > 0)
		fprintf(fp, "channel=%d\n", channel);
	else
		fprintf(fp, "chan=acs\n");

	/* Bandwidth / HT capabilities */
	ht_bw = nvram_wlan_get_int(is_aband, "HT_BW");
	if (is_aband) {
		/* DBDC: cap at 80MHz (design §6: 160MHz not available) */
		fprintf(fp, "vht_oper_chwidth=%d\n", (ht_bw >= 2) ? 1 : 0);
	} else {
		int extcha = nvram_wlan_get_int(0, "HT_EXTCHA");
		fprintf(fp, "ht_capab=[HT40%s]\n", extcha ? "+" : "-");
	}

	/* WMM */
	wme = nvram_wlan_get_int(is_aband, "wme");
	fprintf(fp, "wmm_enabled=%d\n", wme ? 1 : 0);

	/* Beacon / DTIM / RTS / Frag */
	bcn = nvram_wlan_get_int(is_aband, "bcn");
	if (bcn < 20 || bcn > 1000) bcn = 100;
	fprintf(fp, "beacon_int=%d\n", bcn);

	dtim = nvram_wlan_get_int(is_aband, "dtim");
	if (dtim < 1 || dtim > 255) dtim = 1;
	fprintf(fp, "dtim_period=%d\n", dtim);

	rts = nvram_wlan_get_int(is_aband, "rts");
	if (rts < 1 || rts > 2347) rts = 2347;
	fprintf(fp, "rts_threshold=%d\n", rts);

	frag = nvram_wlan_get_int(is_aband, "frag");
	if (frag < 256 || frag > 2346) frag = 2346;
	fprintf(fp, "fragm_threshold=%d\n", frag);

	/* Authentication / encryption (main and guest render independently) */
	{
		char *auth_mode = nvram_wlan_get(is_aband, auth_nv);
		int wpa_mode_v  = nvram_wlan_get_int(is_aband, wpa_mode_nv);
		char *crypto_v  = nvram_wlan_get(is_aband, crypto_nv);
		pmf = nvram_wlan_get_int(is_aband, "pmf");

		(void)auth_mode; (void)wpa_mode_v; (void)crypto_v; (void)pmf;
		render_auth(fp, is_aband);
	}

	/* PSK */
	{
		char *psk = nvram_wlan_get(is_aband, psk_nv);
		if (psk && psk[0])
			fprintf(fp, "wpa_passphrase=%s\n", psk);
	}

	/* GTK rekey */
	gtk_rekey = nvram_wlan_get_int(is_aband, "wpa_gtk_rekey");
	if (gtk_rekey > 0)
		fprintf(fp, "wpa_group_rekey=%d\n", gtk_rekey);

	/* AP isolation (per-BSS) */
	ap_isolate = nvram_wlan_get_int(is_aband,
		bss_index == 0 ? "ap_isolate" : "guest_ap_isolate");
	fprintf(fp, "ap_isolate=%d\n", ap_isolate ? 1 : 0);

	/* MAC ACL */
	render_mac_acl(fp, is_aband, band_tag);

	/* RADIUS (802.1X) */
	{
		char *radius_ip = nvram_wlan_get(is_aband, "radius_ipaddr");
		int radius_port = nvram_wlan_get_int(is_aband, "radius_port");
		char *radius_key = nvram_wlan_get(is_aband, "radius_key");
		if (radius_ip && radius_ip[0]) {
			fprintf(fp, "auth_server_addr=%s\n", radius_ip);
			fprintf(fp, "auth_server_port=%d\n", radius_port ? radius_port : 1812);
			fprintf(fp, "auth_server_shared_secret=%s\n", radius_key ? radius_key : "");
		}
	}

	/* WPS */
	wps_enabled = nvram_wlan_get_int(is_aband, "WPS");
	if (wps_enabled) {
		fprintf(fp, "wps_state=1\n");
		fprintf(fp, "device_name=WPS Router\n");
		fprintf(fp, "manufacturer=%s\n", BOARD_VENDOR_NAME);
		fprintf(fp, "model_number=%s\n", BOARD_NAME);
		{
			char *pin = nvram_safe_get("secret_code");
			if (pin && pin[0])
				fprintf(fp, "device_password=%s\n", pin);
		}
	} else {
		fprintf(fp, "wps_state=0\n");
	}

	(void)is_5g;
	fclose(fp);
	return 0;
}

int
gen_ralink_config_2g(int disable_autoscan)
{
	(void)disable_autoscan;
	gen_hostapd_conf(0, 0);  /* main */
	gen_hostapd_conf(0, 1);  /* guest */
	return 0;
}

int
gen_ralink_config_5g(int disable_autoscan)
{
#if BOARD_HAS_5G_RADIO
	(void)disable_autoscan;
	gen_hostapd_conf(1, 0);  /* main */
	gen_hostapd_conf(1, 1);  /* guest */
	return 0;
#else
	return -1;
#endif
}

/*
 * get_apcli_connected: was SIOCGIWAP (WEXT). With mt76 + wpa_supplicant
 * we ask wpa_cli for the interface state and treat COMPLETED as "associated".
 */
int
get_apcli_connected(const char *ifname)
{
	char cmd[128], buf[256];
	FILE *pp;
	int connected = 0;

	snprintf(cmd, sizeof(cmd), "wpa_cli -i %s status 2>/dev/null", ifname);
	pp = popen(cmd, "r");
	if (!pp)
		return 0;

	while (fgets(buf, sizeof(buf), pp)) {
		if (strstr(buf, "wpa_state=COMPLETED")) {
			connected = 1;
			break;
		}
	}
	pclose(pp);

	return connected;
}
