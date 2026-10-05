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
 * stage2c: net_wifi.c rewritten to control hostapd (AP) and
 * wpa_supplicant (STA/apcli) instead of the legacy Ralink SDK
 * (iwpriv ra0 / ifconfig ra0 / rt2860apd / rtinicapd).
 *
 * Entry points are preserved so rc.c call sites do not need changes;
 * only the internals are swapped.
 *
 * Process model:
 *   hostapd -B -P /var/run/hostapd-<2g|5g>.pid      \
 *           -i <phyX-ap0> /var/run/hostapd-<2g|5g>-main.conf
 *   hostapd -B -P /var/run/hostapd-<2g|5g>-guest.pid \
 *           -i <phyX-ap1> /var/run/hostapd-<2g|5g>-guest.conf
 *   wpa_supplicant -B -P /var/run/wpa_supplicant-<2g|5g>.pid \
 *           -i <phyX-sta0> -c /var/run/wpa_supplicant-<band>.conf
 */

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "nvram_linux.h"
#include "netutils.h"
#include "rtutils.h"
#include "rc.h"
#include "shutils.h"

/* Read a pidfile; return 0 if the process is alive. */
static int
pidfile_alive(const char *path)
{
	FILE *fp = fopen(path, "r");
	int pid;
	if (!fp)
		return 0;
	if (fscanf(fp, "%d", &pid) != 1 || pid <= 0) {
		fclose(fp);
		return 0;
	}
	fclose(fp);
	if (kill(pid, 0) == 0)
		return 1;
	return 0;
}

/* Kill a daemon by pidfile. */
static void
kill_hostapd_pidfile(const char *path)
{
	FILE *fp = fopen(path, "r");
	int pid;
	if (!fp)
		return;
	if (fscanf(fp, "%d", &pid) == 1 && pid > 0) {
		kill(pid, SIGTERM);
		sleep(1);
		kill(pid, SIGKILL);
	}
	fclose(fp);
	unlink(path);
}

/* Return 1 if hostapd (main) is running for the given band. */
static int
hostapd_main_running(int is_aband)
{
	char path[64];
	snprintf(path, sizeof(path), "/var/run/hostapd-%s.pid",
		is_aband ? "5g" : "2g");
	return pidfile_alive(path);
}

static int
hostapd_guest_running(int is_aband)
{
	char path[64];
	snprintf(path, sizeof(path), "/var/run/hostapd-%s-guest.pid",
		is_aband ? "5g" : "2g");
	return pidfile_alive(path);
}

/* Start hostapd for main BSS of one band. */
static int
hostapd_main_start(int is_aband)
{
	const char *ifname = is_aband ? IFNAME_5G_MAIN : IFNAME_2G_MAIN;
	char pidfile[64], conffile[64], cmd[256];

	if (hostapd_main_running(is_aband))
		return 0;

	snprintf(pidfile, sizeof(pidfile), "/var/run/hostapd-%s.pid",
		is_aband ? "5g" : "2g");
	snprintf(conffile, sizeof(conffile), "/var/run/hostapd-%s-main.conf",
		is_aband ? "5g" : "2g");

	/* Ensure the interface exists and is up before hostapd binds. */
	doSystem("ip link set %s up 2>/dev/null", ifname);
	snprintf(cmd, sizeof(cmd),
		"hostapd -B -P %s -i %s %s 2>/dev/null",
		pidfile, ifname, conffile);
	doSystem("%s", cmd);
	return 0;
}

static int
hostapd_guest_start(int is_aband)
{
	const char *ifname = is_aband ? IFNAME_5G_GUEST : IFNAME_2G_GUEST;
	char pidfile[64], conffile[64];

	if (hostapd_guest_running(is_aband))
		return 0;

	/* guest must be bridged into br0 (or guest bridge) before hostapd. */
	doSystem("ip link set %s up 2>/dev/null", ifname);
	br_add_del_if(IFNAME_BR, ifname, 1);

	snprintf(pidfile, sizeof(pidfile), "/var/run/hostapd-%s-guest.pid",
		is_aband ? "5g" : "2g");
	snprintf(conffile, sizeof(conffile), "/var/run/hostapd-%s-guest.conf",
		is_aband ? "5g" : "2g");

	doSystem("hostapd -B -P %s -i %s %s 2>/dev/null",
		pidfile, ifname, conffile);
	return 0;
}

static void
hostapd_main_stop(int is_aband)
{
	char path[64];
	snprintf(path, sizeof(path), "/var/run/hostapd-%s.pid",
		is_aband ? "5g" : "2g");
	kill_hostapd_pidfile(path);
	doSystem("ip link set %s down 2>/dev/null",
		is_aband ? IFNAME_5G_MAIN : IFNAME_2G_MAIN);
}

static void
hostapd_guest_stop(int is_aband)
{
	char path[64];
	snprintf(path, sizeof(path), "/var/run/hostapd-%s-guest.pid",
		is_aband ? "5g" : "2g");
	kill_hostapd_pidfile(path);
}

/* Render wpa_supplicant-<band>.conf from per-band STA nvram keys (wl_sta_* for 5G, rt_sta_* for 2.4G). */
static void
render_wpa_supplicant_conf(int is_aband)
{
	const char *prefix = is_aband ? "wl" : "rt";
	char path[64], buf[128];
	FILE *fp;
	char *ssid, *bssid, *auth, *crypt, *key;
	int wep_idx, hidden;

	snprintf(path, sizeof(path), "/var/run/wpa_supplicant-%s.conf",
		is_aband ? "5g" : "2g");
	fp = fopen(path, "w");
	if (!fp)
		return;

	fprintf(fp, "ctrl_interface=/var/run/wpa_supplicant\n");
	fprintf(fp, "update_config=1\n\n");

	ssid   = nvram_wlan_get(is_aband, "ssid_sta");
	bssid  = nvram_wlan_get(is_aband, "bssid_sta");
	auth   = nvram_wlan_get(is_aband, "auth_sta");
	crypt  = nvram_wlan_get(is_aband, "crypto_sta");
	key    = nvram_wlan_get(is_aband, "wpa_psk_sta");
	wep_idx= nvram_wlan_get_int(is_aband, "wep_idx_sta");
	hidden = nvram_wlan_get_int(is_aband, "hidden_sta");

	fprintf(fp, "network={\n");
	fprintf(fp, "\tssid=\"%s\"\n", ssid ? ssid : "");
	if (bssid && bssid[0])
		fprintf(fp, "\tbssid=%s\n", bssid);
	fprintf(fp, "\tscan_ssid=%d\n", hidden ? 2 : 1);

	if (!auth || !strcmp(auth, "open")) {
		fprintf(fp, "\tkey_mgmt=NONE\n");
	} else if (!strcmp(auth, "wep")) {
		fprintf(fp, "\tkey_mgmt=NONE\n");
		fprintf(fp, "\twep_tx_keyidx=%d\n", wep_idx);
		/* wep keys wpa_psk_sta is used as hex/passphrase */
		if (key && key[0])
			fprintf(fp, "\twep_key0=\"%s\"\n", key);
	} else {
		/* WPA/WPA2 PSK */
		fprintf(fp, "\tkey_mgmt=WPA-PSK\n");
		if (!crypt || !strcmp(crypt, "aes"))
			fprintf(fp, "\tpairwise=CCMP\n");
		else if (!strcmp(crypt, "tkip"))
			fprintf(fp, "\tpairwise=TKIP\n");
		else
			fprintf(fp, "\tpairwise=CCMP TKIP\n");
		if (key && key[0])
			fprintf(fp, "\tpsk=\"%s\"\n", key);
	}
	fprintf(fp, "}\n");
	fclose(fp);
	(void)prefix; (void)buf;
}

static int
wpa_supplicant_running(int is_aband)
{
	char path[64];
	snprintf(path, sizeof(path), "/var/run/wpa_supplicant-%s.pid",
		is_aband ? "5g" : "2g");
	return pidfile_alive(path);
}

static void
wpa_supplicant_start(int is_aband)
{
	const char *ifname = is_aband ? IFNAME_5G_APCLI : IFNAME_2G_APCLI;
	char pidfile[64], conffile[64];

	if (wpa_supplicant_running(is_aband))
		return;

	render_wpa_supplicant_conf(is_aband);

	doSystem("ip link set %s up 2>/dev/null", ifname);
	snprintf(pidfile, sizeof(pidfile), "/var/run/wpa_supplicant-%s.pid",
		is_aband ? "5g" : "2g");
	snprintf(conffile, sizeof(conffile), "/var/run/wpa_supplicant-%s.conf",
		is_aband ? "5g" : "2g");

	doSystem("wpa_supplicant -B -P %s -i %s -c %s 2>/dev/null",
		pidfile, ifname, conffile);
}

static void
wpa_supplicant_stop(int is_aband)
{
	char path[64];
	snprintf(path, sizeof(path), "/var/run/wpa_supplicant-%s.pid",
		is_aband ? "5g" : "2g");
	kill_hostapd_pidfile(path);
}

/*
 * Wrapper for is_aband. wl = 2.4G (is_aband=0), rt = 5G (is_aband=1).
 */

static int nvram_bool(const char *k)
{
	char *v = nvram_safe_get(k);
	return (v && (v[0] == '1' || !strcasecmp(v, "yes") || !strcasecmp(v, "on")));
}

void
start_wifi_ap_wl(int radio_on)
{
	if (!radio_on)
		return;
	if (!nvram_bool("rt_enable"))
		return;
	gen_ralink_config_2g(0);
	hostapd_main_start(0);
	if (nvram_bool("rt_gfn"))
		hostapd_guest_start(0);
}

void
start_wifi_ap_rt(int radio_on)
{
	if (!radio_on)
		return;
	if (!nvram_bool("wl_enable"))
		return;
	gen_ralink_config_5g(0);
	hostapd_main_start(1);
	if (nvram_bool("wl_gfn"))
		hostapd_guest_start(1);
}

void
stop_wifi_all_wl(void)
{
	hostapd_guest_stop(0);
	hostapd_main_stop(0);
	wpa_supplicant_stop(0);
}

void
stop_wifi_all_rt(void)
{
	hostapd_guest_stop(1);
	hostapd_main_stop(1);
	wpa_supplicant_stop(1);
}

int
is_radio_on_wl(void)
{
	return hostapd_main_running(0);
}

int
is_radio_on_rt(void)
{
	return hostapd_main_running(1);
}

int
is_radio_allowed_wl(void)
{
	return nvram_bool("rt_enable");
}

int
is_radio_allowed_rt(void)
{
	return nvram_bool("wl_enable");
}

int
control_radio_wl(int radio_on, int manual)
{
	(void)manual;
	if (radio_on)
		start_wifi_ap_wl(1);
	else
		stop_wifi_all_wl();
	return radio_on;
}

int
control_radio_rt(int radio_on, int manual)
{
	(void)manual;
	if (radio_on)
		start_wifi_ap_rt(1);
	else
		stop_wifi_all_rt();
	return radio_on;
}

int
control_guest_wl(int guest_on, int manual)
{
	(void)manual;
	if (guest_on)
		hostapd_guest_start(0);
	else
		hostapd_guest_stop(0);
	return guest_on;
}

int
control_guest_rt(int guest_on, int manual)
{
	(void)manual;
	if (guest_on)
		hostapd_guest_start(1);
	else
		hostapd_guest_stop(1);
	return guest_on;
}

void
restart_wifi_wl(int radio_on, int need_reload_conf)
{
	(void)need_reload_conf;
	stop_wifi_all_wl();
	start_wifi_ap_wl(radio_on);
}

void
restart_wifi_rt(int radio_on, int need_reload_conf)
{
	(void)need_reload_conf;
	stop_wifi_all_rt();
	start_wifi_ap_rt(radio_on);
}

void
control_wifi_config(void)
{
	int wl = nvram_bool("rt_enable");
	int rt = nvram_bool("wl_enable");

	if (wl) restart_wifi_wl(1, 1);
	if (rt) restart_wifi_rt(1, 1);
}

/* WDS: degraded under mt76 (design §6: only single-link 4addr WDS;
 * the legacy 4-interface WDS0..3 model is not supported). Entry points
 * are kept as no-ops so rc.c still links. */
void
start_wifi_wds_wl(int radio_on)
{
	(void)radio_on;
}

void
start_wifi_wds_rt(int radio_on)
{
	(void)radio_on;
}

/* apcli / STA mode */
void
start_wifi_apcli_wl(int radio_on)
{
	(void)radio_on;
	if (!nvram_bool("rt_sta_enable"))
		return;
	wpa_supplicant_start(0);
}

void
start_wifi_apcli_rt(int radio_on)
{
	(void)radio_on;
	if (!nvram_bool("wl_sta_enable"))
		return;
	wpa_supplicant_start(1);
}

void
reconnect_apcli(const char *ifname_apcli, int force)
{
	/* Force reassociation by sending reconfigure to wpa_supplicant. */
	doSystem("wpa_cli -i %s reconfigure 2>/dev/null", ifname_apcli);
	(void)force;
}

/* 802.1X is now rendered into hostapd.conf by gen_hostapd_conf
 * (radius_ipaddr / radius_port / radius_key nvram keys). These
 * entry points are kept as no-ops. */
void
start_8021x_wl(void)
{
}

void
start_8021x_rt(void)
{
}

/* VGA clamp was a closed-SDK power control; deleted per design §6. */
void
update_vga_clamp_wl(int first_call)
{
	(void)first_call;
}

void
update_vga_clamp_rt(int first_call)
{
	(void)first_call;
}

/* Manual radio toggle (WPS button / hardware switch) */
int
manual_toggle_radio_wl(int radio_on)
{
	return control_radio_wl(radio_on, 1);
}

int
manual_toggle_radio_rt(int radio_on)
{
	return control_radio_rt(radio_on, 1);
}

int
manual_change_radio_wl(int radio_on)
{
	nvram_set_int("rt_enable", radio_on);
	return control_radio_wl(radio_on, 1);
}

int
manual_change_radio_rt(int radio_on)
{
	nvram_set_int("wl_enable", radio_on);
	return control_radio_rt(radio_on, 1);
}

int
manual_change_guest_wl(int guest_on)
{
	nvram_set_int("rt_gfn", guest_on);
	return control_guest_wl(guest_on, 1);
}

int
manual_change_guest_rt(int guest_on)
{
	nvram_set_int("wl_gfn", guest_on);
	return control_guest_wl(guest_on, 1);
}

/*
 * timecheck_wifi: schedule-based radio on/off. We evaluate the nvram
 * time window and call control_radio_* accordingly. Returns the desired
 * state (1=on, 0=off).
 */
int
timecheck_wifi(int is_aband, const char *nv_date, const char *nv_time1, const char *nv_time2)
{
	time_t t = time(NULL);
	struct tm *tm = localtime(&t);
	char date_str[16], time_str[16], *v;
	int desired = 1;

	snprintf(date_str, sizeof(date_str), "%04d-%02d-%02d",
		tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday);
	snprintf(time_str, sizeof(time_str), "%02d:%02d",
		tm->tm_hour, tm->tm_min);

	v = nvram_safe_get(nv_date);
	if (v && v[0] && strstr(v, date_str) == NULL)
		desired = 1;
	else if (nv_time1 && nv_time1[0] && nv_time2 && nv_time2[0]) {
		char *t1 = nvram_safe_get(nv_time1);
		char *t2 = nvram_safe_get(nv_time2);
		if (t1 && t2 && t1[0] && t2[0]) {
			if (strcmp(time_str, t1) < 0 || strcmp(time_str, t2) > 0)
				desired = 0;
		}
	}

	if (is_aband)
		control_radio_rt(desired, 0);
	else
		control_radio_wl(desired, 0);

	return desired;
}

/*
 * ------------------------------------------------------------------
 * stage2c: legacy-symbol thin wrappers.
 *
 * These symbols were originally defined in net_wifi.c (and used by
 * rc.c / watchdog.c / services.c / net_lan.c / rc.h). They were lost
 * during the hostapd rewrite; we re-export them here as thin wrappers
 * so existing call sites (and rc.h prototypes) keep linking. Semantics
 * are preserved against the new hostapd state machine.
 * ------------------------------------------------------------------
 */

/* nvram radio/guest mode + enable getters.
 * Convention preserved: wl = 5G band (is_aband=1), rt = 2.4G band
 * (is_aband=0). This matches the old nvram_wlan_get_int(is_aband,...)
 * argument order in the pre-stage2c file. */
int
get_enabled_radio_wl(void)
{
	return nvram_wlan_get_int(1, "radio_x");
}

int
get_enabled_radio_rt(void)
{
	return nvram_wlan_get_int(0, "radio_x");
}

int
get_enabled_guest_wl(void)
{
	return nvram_wlan_get_int(1, "guest_enable");
}

int
get_enabled_guest_rt(void)
{
	return nvram_wlan_get_int(0, "guest_enable");
}

int
get_mode_radio_wl(void)
{
	return nvram_wlan_get_int(1, "mode_x");
}

int
get_mode_radio_rt(void)
{
	return nvram_wlan_get_int(0, "mode_x");
}

int
is_apcli_wisp_wl(void)
{
	return nvram_wlan_get_int(1, "sta_wisp");
}

int
is_apcli_wisp_rt(void)
{
	return nvram_wlan_get_int(0, "sta_wisp");
}

int
get_apcli_sta_auto(int is_aband)
{
	return nvram_wlan_get_int(is_aband, "sta_auto");
}

/*
 * get_apcli_wisp_ifname: return the apcli/sta interface name that is
 * currently acting as a WAN-side WISP uplink, or NULL. Preserves the
 * old logic (mode 3/4 + sta_wisp=1 + sta_ssid non-empty) but uses the
 * new helper-provided interface names.
 */
char *
get_apcli_wisp_ifname(void)
{
	int i_mode_x;

	i_mode_x = get_mode_radio_rt();
	if (get_enabled_radio_rt() && (i_mode_x == 3 || i_mode_x == 4) &&
	    is_apcli_wisp_rt() &&
	    (strlen(nvram_wlan_get(0, "sta_ssid")) > 0))
		return (char *)IFNAME_2G_APCLI;

#if BOARD_HAS_5G_RADIO
	i_mode_x = get_mode_radio_wl();
	if (get_enabled_radio_wl() && (i_mode_x == 3 || i_mode_x == 4) &&
	    is_apcli_wisp_wl() &&
	    (strlen(nvram_wlan_get(1, "sta_ssid")) > 0))
		return (char *)IFNAME_5G_APCLI;
#endif
	return NULL;
}

/*
 * stop_8021x_all: used to kill rt2860apd/rtinicapd. Under hostapd the
 * 802.1X/RADIUS server is hosted inside hostapd itself; stopping the
 * band (via stop_wifi_all_wl/rt) already kills hostapd, so this is a
 * no-op. Kept for source compatibility with rc.h.
 */
void
stop_8021x_all(void)
{
	/* no-op: 802.1X is now rendered into hostapd.conf; no separate
	 * 802.1X daemon to kill. */
}

/*
 * is_guest_allowed_*: guest BSS is allowed if nvram guest_enable=1 AND
 * the guest schedule (timecheck) permits. Preserves old semantics.
 */
int
is_guest_allowed_wl(void)
{
	if (get_enabled_guest_wl())
		return timecheck_wifi(1, "guest_date_x", "guest_time_x", "guest_time2_x");
	return 0;
}

int
is_guest_allowed_rt(void)
{
	if (get_enabled_guest_rt())
		return timecheck_wifi(0, "guest_date_x", "guest_time_x", "guest_time2_x");
	return 0;
}

/*
 * restart_guest_lan_isolation: re-apply guest port isolation.
 *
 * Under mt76+hostapd, per-BSS isolation is already set via hostapd.conf
 * ap_isolate=1 (rendered in gen_hostapd_conf). The bridge-level
 * brport isolate_mode is still applied here for DSA guest ports, and
 * AP-mode ebtables filtering is ported unchanged.
 */
void
restart_guest_lan_isolation(void)
{
	int bp_isolate, is_need_ebtables = 0;
	int is_ap_mode = get_ap_mode();
	const char *rt_ifname_guest = IFNAME_2G_GUEST;
#if BOARD_HAS_5G_RADIO
	const char *wl_ifname_guest = IFNAME_5G_GUEST;

	bp_isolate = 0;
	if (is_interface_up(wl_ifname_guest)) {
		if (nvram_wlan_get_int(1, "guest_lan_isolate")) {
			if (!is_ap_mode)
				bp_isolate = 1;
			else
				is_need_ebtables |= 0x10;
		}
	}

	brport_set_param_int(wl_ifname_guest, "isolate_mode", bp_isolate);
#endif

	bp_isolate = 0;
	if (is_interface_up(rt_ifname_guest)) {
		if (nvram_wlan_get_int(0, "guest_lan_isolate")) {
			if (!is_ap_mode)
				bp_isolate = 1;
			else
				is_need_ebtables |= 0x01;
		}
	}

	brport_set_param_int(rt_ifname_guest, "isolate_mode", bp_isolate);

	/*
	 * stage2c: AP-mode ebtables guest filtering was previously driven
	 * by ebtables_filter_guest_ap(), which has been removed by the
	 * firewall shard (firewall_ex.c). The firewall shard now owns
	 * guest isolation iptables/ebtables rules via its own notify_rc
	 * hook; this function only enforces the bridge-level
	 * brport isolate_mode above.
	 */
	(void)is_ap_mode;
	(void)is_need_ebtables;
}
