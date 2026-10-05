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

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <dirent.h>

#include <net/if.h>

#include <ralink_boards.h>
#include <ralink_priv.h>

#include "nvram_linux.h"
#include "netutils.h"
#include "rtutils.h"

/*
 * stage2c: runtime phy<->band detection for mt76 DBDC.
 *
 * mt7915e in DBDC mode registers two ieee80211 phy devices (phy0/phy1),
 * but the order is not guaranteed: phy0 could be 2.4G or 5G depending on
 * probe order and eeprom layout. We scan /sys/class/ieee80211/ for phy
 * devices and ask `iw phy <name> info` which band(s) each supports, then
 * cache the mapping. On any failure we fall back to the documented
 * assumption (phy0=2.4G, phy1=5G) and log a message; this must be
 * re-checked on real hardware (see stage2c report "board-check items").
 */

#define WIFI_PHY_NAME_MAX  32
#define WIFI_IFNAME_MAX    32

static char s_phy_2g[WIFI_PHY_NAME_MAX] = "phy0";
static char s_phy_5g[WIFI_PHY_NAME_MAX] = "phy1";
static int  s_phy_detected = 0;

static char s_if_main_2g[WIFI_IFNAME_MAX];
static char s_if_guest_2g[WIFI_IFNAME_MAX];
static char s_if_sta_2g[WIFI_IFNAME_MAX];
static char s_if_main_5g[WIFI_IFNAME_MAX];
static char s_if_guest_5g[WIFI_IFNAME_MAX];
static char s_if_sta_5g[WIFI_IFNAME_MAX];

/* logmessage is provided by shutils (linked into libshared consumers) */
extern void logmessage(char *logheader, char *fmt, ...);

static int
is_dir(const char *path)
{
	struct stat st;
	return (stat(path, &st) == 0 && S_ISDIR(st.st_mode));
}

/*
 * Returns 1 if phy advertises the requested band, 0 otherwise, -1 if
 * unknown (iw not present / parse failed). "Band 1:" in iw output is
 * 2.4GHz, "Band 2:" is 5GHz.
 */
static int
phy_supports_band(const char *phy_name, int want_2g)
{
	char cmd[512];
	char buf[1024];
	FILE *pp;
	int has_2g = 0, has_5g = 0;

	snprintf(cmd, sizeof(cmd),
		 "iw phy %s info 2>/dev/null | grep -E \"Band [12]:\"", phy_name);
	pp = popen(cmd, "r");
	if (!pp)
		return -1;

	while (fgets(buf, sizeof(buf), pp)) {
		if (strstr(buf, "Band 1:"))
			has_2g = 1;
		else if (strstr(buf, "Band 2:"))
			has_5g = 1;
	}
	pclose(pp);

	if (!has_2g && !has_5g)
		return -1;

	return want_2g ? has_2g : has_5g;
}

static void
detect_wifi_band(void)
{
	DIR *dir;
	struct dirent *de;
	char path[256];
	char phy_names[8][WIFI_PHY_NAME_MAX];
	int n_phy = 0, i;

	if (s_phy_detected)
		return;

	dir = opendir("/sys/class/ieee80211");
	if (!dir) {
		logmessage((char *)"rtutils",
			"ieee80211 class not present; assuming phy0=2.4G phy1=5G (verify on board)");
		s_phy_detected = 1;
		return;
	}

	while ((de = readdir(dir)) != NULL && n_phy < 8) {
		if (strncmp(de->d_name, "phy", 3) != 0)
			continue;
		snprintf(path, sizeof(path), "/sys/class/ieee80211/%s", de->d_name);
		if (is_dir(path))
			snprintf(phy_names[n_phy++], WIFI_PHY_NAME_MAX, "%s", de->d_name);
	}
	closedir(dir);

	if (n_phy < 2) {
		logmessage((char *)"rtutils",
			"expected 2 mt76 phy devices, found %d; using defaults (verify on board)", n_phy);
		s_phy_detected = 1;
		return;
	}

	s_phy_2g[0] = s_phy_5g[0] = 0;
	for (i = 0; i < n_phy; i++) {
		int r2 = phy_supports_band(phy_names[i], 1);
		if (r2 == 1 && !s_phy_2g[0]) {
			snprintf(s_phy_2g, WIFI_PHY_NAME_MAX, "%s", phy_names[i]);
			continue;
		}
		int r5 = phy_supports_band(phy_names[i], 0);
		if (r5 == 1 && !s_phy_5g[0])
			snprintf(s_phy_5g, WIFI_PHY_NAME_MAX, "%s", phy_names[i]);
	}

	if (!s_phy_2g[0]) {
		snprintf(s_phy_2g, WIFI_PHY_NAME_MAX, "%s", phy_names[0]);
		logmessage((char *)"rtutils",
			"2.4G band not detected; assuming %s (verify on board)", s_phy_2g);
	}
	if (!s_phy_5g[0]) {
		snprintf(s_phy_5g, WIFI_PHY_NAME_MAX, "%s", phy_names[n_phy > 1 ? 1 : 0]);
		logmessage((char *)"rtutils",
			"5G band not detected; assuming %s (verify on board)", s_phy_5g);
	}

	snprintf(s_if_main_2g, WIFI_IFNAME_MAX, "%s-ap0", s_phy_2g);
	snprintf(s_if_guest_2g, WIFI_IFNAME_MAX, "%s-ap1", s_phy_2g);
	snprintf(s_if_sta_2g,  WIFI_IFNAME_MAX, "%s-sta0", s_phy_2g);
	snprintf(s_if_main_5g, WIFI_IFNAME_MAX, "%s-ap0", s_phy_5g);
	snprintf(s_if_guest_5g, WIFI_IFNAME_MAX, "%s-ap1", s_phy_5g);
	snprintf(s_if_sta_5g,  WIFI_IFNAME_MAX, "%s-sta0", s_phy_5g);

	s_phy_detected = 1;
}

/*
 * DSA LAN port set (br0 membership iterates this array; switch contract).
 * Sentinel NULL so consumers can walk until NULL.
 */
const char *lan_port_names[5] = {
	"lan1", "lan2", "lan3", "lan4", NULL
};

const char *
wifi_main_ifname(int aband)
{
	detect_wifi_band();
	return aband ? s_if_main_5g : s_if_main_2g;
}

const char *
wifi_guest_ifname(int aband)
{
	detect_wifi_band();
	return aband ? s_if_guest_5g : s_if_guest_2g;
}

const char *
wifi_apcli_ifname(int aband)
{
	detect_wifi_band();
	return aband ? s_if_sta_5g : s_if_sta_2g;
}

const char *
wifi_phy_name(int aband)
{
	detect_wifi_band();
	return aband ? s_phy_5g : s_phy_2g;
}

const char *
find_wlan_if_up(int is_aband)
{
	static const char *(*candidates[3])(int) = {
		wifi_main_ifname,
		wifi_guest_ifname,
		wifi_apcli_ifname,
	};
	int i;

	for (i = 0; i < 3; i++) {
		const char *wifn = candidates[i](is_aband);
		if (is_interface_up(wifn))
			return wifn;
	}

	return NULL;
}

#if BOARD_HAS_5G_11AC
static int
is_phy_mode_can_vht(int i_phy_mode)
{
	switch (i_phy_mode)
	{
	case PHY_11VHT_N_ABG_MIXED:
	case PHY_11VHT_N_AG_MIXED:
	case PHY_11VHT_N_A_MIXED:
	case PHY_11VHT_N_MIXED:
	case PHY_11VHT:
	case PHY_11AX_24G:
	case PHY_11AX_5G:
	case PHY_11AX_6G:
	case PHY_11AX_24G_6G:
	case PHY_11AX_5G_6G:
	case PHY_11AX_24G_5G_6G:
		return 1;
	}

	return 0;
}
#endif

static int
is_phy_mode_can_ofdm(int i_phy_mode)
{
	switch (i_phy_mode)
	{
	case PHY_11B:
		return 0;
	}

	return 1;
}

int
calc_phy_mode(int i_val, int is_aband)
{
	int i_phy_mode;

	if (!is_aband) {
		i_phy_mode = PHY_11GN_MIXED;
		switch (i_val)
		{
		case 0:  // B
			i_phy_mode = PHY_11B;
			break;
		case 1:  // B,G
			i_phy_mode = PHY_11BG_MIXED;
			break;
		case 2:  // B,G,N
			i_phy_mode = PHY_11BGN_MIXED;
			break;
		case 3:  // N
			i_phy_mode = PHY_11N;
			break;
		case 4:  // G
			i_phy_mode = PHY_11G;
			break;
		case 5:  // G,N
			i_phy_mode = PHY_11GN_MIXED;
			break;
#if defined(BOARD_HAS_2G_11AX) && BOARD_HAS_2G_11AX
		case 6: // B/G/N/AX
			i_phy_mode = PHY_11AX_24G;
			break;
#endif
		}
	} else {
#if BOARD_HAS_5G_11AC
		i_phy_mode = PHY_11VHT_N_A_MIXED;
#else
		i_phy_mode = PHY_11AN_MIXED;
#endif
		switch (i_val)
		{
		case 0:  // A
			i_phy_mode = PHY_11A;
			break;
		case 1:  // N
			i_phy_mode = PHY_11N_5G;
			break;
		case 2:  // A/N
			i_phy_mode = PHY_11AN_MIXED;
			break;
#if BOARD_HAS_5G_11AC
		case 3:  // N/AC
			i_phy_mode = PHY_11VHT_N_MIXED;
			break;
		case 4:  // A/N/AC
			i_phy_mode = PHY_11VHT_N_A_MIXED;
			break;
		case 6:  // AC only
			i_phy_mode = PHY_11VHT;
			break;
#endif
#if defined(BOARD_HAS_5G_11AX) && BOARD_HAS_5G_11AX
		case 5: // A/N/AC/AX
			i_phy_mode = PHY_11AX_5G;
			break;
#endif
		}
	}

	return i_phy_mode;
}

int
calc_fixed_tx_mode(int i_val, int is_aband, int i_phy_mode, int *p_mcs)
{
	int i_phy = 0;		// FixedTxMode=OFF
	int i_mcs = 33;		// HT_MCS=Auto

	switch (i_val)
	{
	case 1:
		i_mcs = 2;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 2:
		i_mcs = 1;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 3:
		i_mcs = 0;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 4:
		i_mcs = 2;
		if (is_phy_mode_can_ofdm(i_phy_mode))
			i_phy = FIXED_TXMODE_OFDM;
		else if (!is_aband)
			i_phy = FIXED_TXMODE_CCK;
		break;
	case 5:
		i_mcs = 1;
		if (is_phy_mode_can_ofdm(i_phy_mode))
			i_phy = FIXED_TXMODE_OFDM;
		else if (!is_aband)
			i_phy = FIXED_TXMODE_CCK;
		break;
	case 6:
		i_mcs = 0;
		if (is_phy_mode_can_ofdm(i_phy_mode))
			i_phy = FIXED_TXMODE_OFDM;
		else if (!is_aband)
			i_phy = FIXED_TXMODE_CCK;
		break;
	case 7:
		i_mcs = 2;
		if (!is_aband)
			i_phy = FIXED_TXMODE_CCK;
#if BOARD_HAS_5G_11AC
		else if (is_phy_mode_can_vht(i_phy_mode))
			i_phy = FIXED_TXMODE_VHT;
#endif
		else
			i_phy = FIXED_TXMODE_HT;
		break;
	case 8:
		i_mcs = 1;
		if (!is_aband)
			i_phy = FIXED_TXMODE_CCK;
#if BOARD_HAS_5G_11AC
		else if (is_phy_mode_can_vht(i_phy_mode))
			i_phy = FIXED_TXMODE_VHT;
#endif
		else
			i_phy = FIXED_TXMODE_HT;
		break;
	case 9:
		i_mcs = 0;
		if (!is_aband)
			i_phy = FIXED_TXMODE_CCK;
#if BOARD_HAS_5G_11AC
		else if (is_phy_mode_can_vht(i_phy_mode))
			i_phy = FIXED_TXMODE_VHT;
#endif
		else
			i_phy = FIXED_TXMODE_HT;
		break;
	/* VHT MCS 3-9 (2S on 2x2 hardware) */
	case 10:
		i_mcs = 3;
		i_phy = FIXED_TXMODE_VHT;
		break;
	case 11:
		i_mcs = 4;
		i_phy = FIXED_TXMODE_VHT;
		break;
	case 12:
		i_mcs = 5;
		i_phy = FIXED_TXMODE_VHT;
		break;
	case 13:
		i_mcs = 6;
		i_phy = FIXED_TXMODE_VHT;
		break;
	case 14:
		i_mcs = 7;
		i_phy = FIXED_TXMODE_VHT;
		break;
	case 15:
		i_mcs = 8;
		i_phy = FIXED_TXMODE_VHT;
		break;
	case 16:
		i_mcs = 9;
		i_phy = FIXED_TXMODE_VHT;
		break;
	/* HT 2S MCS 7-0 (MCS 15-8) */
	case 17:
		i_mcs = 15;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 18:
		i_mcs = 14;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 19:
		i_mcs = 13;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 20:
		i_mcs = 12;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 21:
		i_mcs = 11;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 22:
		i_mcs = 10;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 23:
		i_mcs = 9;
		i_phy = FIXED_TXMODE_HT;
		break;
	case 24:
		i_mcs = 8;
		i_phy = FIXED_TXMODE_HT;
		break;
	}

	*p_mcs = i_mcs;

	return i_phy;
}

int
calc_mcast_tx_mode(int i_val, int is_aband, int *p_mmcs)
{
	int i_mphy = 2; // OFDM
	int i_mmcs = 0; // 6 Mbps

	switch (i_val)
	{
	case 0: // Auto
		i_mphy = 0;
		i_mmcs = 0;
		break;
	case 1: // CCK 1 Mbps
		if (!is_aband) {
			i_mphy = 1;
			i_mmcs = 0;
		}
		break;
	case 2: // CCK 2 Mbps
		if (!is_aband) {
			i_mphy = 1;
			i_mmcs = 1;
		}
		break;
	case 3: // OFDM 6 Mbps
		i_mphy = 2;
		i_mmcs = 0;
		break;
	case 4: // OFDM 9 Mbps
		i_mphy = 2;
		i_mmcs = 1;
		break;
	case 5: // OFDM 12 Mbps
		i_mphy = 2;
		i_mmcs = 2;
		break;
	case 6: // HTMIX (1S) 6.5-15 Mbps
		i_mphy = 3;
		i_mmcs = 0;
		break;
	case 7: // HTMIX (1S) 15-30 Mbps
		i_mphy = 3;
		i_mmcs = 1;
		break;
	}

	*p_mmcs = i_mmcs;

	return i_mphy;
}

void
nvram_wlan_set(int is_aband, const char *param, char *value)
{
	char wlan_param[64];
	const char *prefix = (is_aband) ? "wl" : "rt";

	snprintf(wlan_param, sizeof(wlan_param), "%s_%s", prefix, param);
	nvram_set(wlan_param, value);
}

void
nvram_wlan_set_int(int is_aband, const char *param, int value)
{
	char wlan_param[64];
	const char *prefix = (is_aband) ? "wl" : "rt";

	snprintf(wlan_param, sizeof(wlan_param), "%s_%s", prefix, param);
	nvram_set_int(wlan_param, value);
}

char*
nvram_wlan_get(int is_aband, const char *param)
{
	char wlan_param[64];
	const char *prefix = (is_aband) ? "wl" : "rt";

	snprintf(wlan_param, sizeof(wlan_param), "%s_%s", prefix, param);
	return nvram_safe_get(wlan_param);
}

int
nvram_wlan_get_int(int is_aband, const char *param)
{
	char *value = nvram_wlan_get(is_aband, param);
	if (value)
		return atoi(value);
	return 0;
}
