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

#ifndef _rtutils_h_
#define _rtutils_h_

extern const char* find_wlan_if_up(int is_aband);

/*
 * stage2c (mt76 DBDC) wireless interface name helpers.
 *
 * These map a band selector (aband: 0=2.4GHz, 1=5GHz) to the runtime
 * mt76/hotplug interface names. phy<->band mapping is detected once by
 * detect_wifi_band() by scanning /sys/class/ieee80211/phyX for supported
 * frequency bands; results are cached for the process lifetime.
 *
 * Returned strings are static buffers (valid until next call in a
 * re-detect scenario; for the normal cached path they are immutable).
 * Callers must not free the returned pointer.
 */
extern const char *wifi_main_ifname(int aband);   /* e.g. "phy1-ap0" */
extern const char *wifi_guest_ifname(int aband);  /* e.g. "phy1-ap1" */
extern const char *wifi_apcli_ifname(int aband);  /* e.g. "phy1-sta0" */
extern const char *wifi_phy_name(int aband);      /* e.g. "phy1"     */

extern int calc_phy_mode(int i_val, int is_aband);
extern int calc_fixed_tx_mode(int i_val, int is_aband, int i_phy_mode, int *p_mcs);
extern int calc_mcast_tx_mode(int i_val, int is_aband, int *p_mmcs);

extern void  nvram_wlan_set(int is_aband, const char *param, char *value);
extern void  nvram_wlan_set_int(int is_aband, const char *param, int value);
extern char* nvram_wlan_get(int is_aband, const char *param);
extern int   nvram_wlan_get_int(int is_aband, const char *param);

#endif
