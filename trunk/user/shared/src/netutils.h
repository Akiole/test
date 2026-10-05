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

#ifndef _netutils_h_
#define _netutils_h_

#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include <ralink_boards.h>

/*
 * stage2c (mt76+hostapd / DSA) interface naming contract.
 *
 * Wired side (DSA / mt7530):
 *   - CPU bridge            : br0
 *   - LAN ports             : lan1..lan4  (DSA user ports)
 *   - WAN port              : wan         (DSA user port)
 *   - IFNAME_LAN  = "lan1"  (semantic: first LAN port; br0 membership
 *                            iterates lan_port_names[] instead)
 *   - IFNAME_MAC  = "br0"   (DSA carries LAN MAC on the bridge)
 *   - IFNAME_MAC2 = "wan"   (WAN MAC carrier)
 *
 * Wireless side (mt76 DBDC, phy0/phy1 detected at runtime):
 *   The legacy ra0/rax0/ra1/rax1/apcli0/apclix0 names are gone.
 *   Instance names are produced by helpers in rtutils.c
 *   (wifi_main_ifname / wifi_guest_ifname / wifi_apcli_ifname /
 *    wifi_phy_name) which map band (0=2.4G, 1=5G) to the right
 *    phyX-apY / phyX-staY after runtime phy<->band detection.
 *
 *   Function-style macros are used so that call sites in net.c,
 *   smp.c, net6.c, defaults.c, netutils.c and httpd keep compiling
 *   unchanged; any site that previously used these names in a
 *   static initializer must be migrated to runtime lookup (see
 *   stage2c report "cross-shard TODO list").
 */

//#define IFUP				(IFF_UP | IFF_RUNNING | IFF_BROADCAST | IFF_MULTICAST)
#define IFUP				(IFF_UP | IFF_RUNNING)
#define sin_addr(s)			(((struct sockaddr_in *)(s))->sin_addr)

#define IFNAME_BR			"br0"

/* --- DSA wired naming (switch contract) --- */
#define IFNAME_MAC			"br0"
#define IFNAME_MAC2			"wan"
#define IFNAME_LAN			"lan1"
#define IFNAME_WAN			"wan"

/* DSA LAN port set (lan1..lan4). br0 membership iterates this array. */
#define IFNAME_LAN1			"lan1"
#define IFNAME_LAN2			"lan2"
#define IFNAME_LAN3			"lan3"
#define IFNAME_LAN4			"lan4"
extern const char *lan_port_names[];

#define BOARD_2G_AS_WSOC		(BOARD_2G_IN_SOC || !BOARD_5G_IN_SOC)

/*
 * Include rtutils.h for the wifi_*_ifname helper declarations.
 * No circular include: rtutils.h does not include netutils.h.
 */
#include <rtutils.h>

/* --- Wireless naming (function-style macros; band: 0=2.4G, 1=5G) --- */
#define IFNAME_2G_MAIN			wifi_main_ifname(0)
#define IFNAME_2G_GUEST			wifi_guest_ifname(0)
#define IFNAME_2G_APCLI			wifi_apcli_ifname(0)
#define IFNAME_5G_MAIN			wifi_main_ifname(1)
#define IFNAME_5G_GUEST			wifi_guest_ifname(1)
#define IFNAME_5G_APCLI			wifi_apcli_ifname(1)

/*
 * WDS: mt76 supports only single-link 4addr WDS; the legacy wds0..wds3
 * multi-interface SDK model is degraded (design §6). Names are kept as
 * static strings so that any lingering call sites still compile; the
 * WDS start/stop paths in net_wifi.c are no-ops under hostapd.
 */
#define IFNAME_2G_WDS0			"wds0"
#define IFNAME_2G_WDS1			"wds1"
#define IFNAME_2G_WDS2			"wds2"
#define IFNAME_2G_WDS3			"wds3"
#define IFNAME_5G_WDS0			"wds0"
#define IFNAME_5G_WDS1			"wds1"
#define IFNAME_5G_WDS2			"wds2"
#define IFNAME_5G_WDS3			"wds3"

#if defined(USE_RT3352_MII)
#define IFNAME_INIC_MAIN		IFNAME_2G_MAIN
#define IFNAME_INIC_GUEST		IFNAME_2G_GUEST
#define IFNAME_INIC_GUEST_VLAN		"lan1.3"
#define INIC_GUEST_VLAN_VID		3
#define MIN_EXT_VLAN_VID		4
#else
#define MIN_EXT_VLAN_VID		2
#endif

#define IFNAME_SIT			"sit1"

#define WAN_PPP_UNIT			0
#define WAN_PPP_UNIT_MAX		1
#define IFNAME_PPP			"ppp0"

#define RAS_PPP_UNIT			2
#define IFNAME_RAS			"ppp2"

#define VPNC_PPP_UNIT			5
#define IFNAME_CLIENT_PPP		"ppp5"

#define IFNAME_SERVER_TAP		"tap1"
#define IFNAME_CLIENT_TAP		"tap0"

#define IFNAME_SERVER_TUN		"tun1"
#define IFNAME_CLIENT_TUN		"tun0"

#define IFNAME_USBNET1			"wwan0"
#define IFNAME_USBNET2			"weth0"

#define IFDESC_VPNC			"VPNC"
#define IFDESC_WISP			"WISP"
#define IFDESC_WWAN			"WWAN"
#define IFDESC_WAN			"WAN"
#define IFDESC_LAN			"LAN"
#define IFDESC_WLAN2_MII		"WLAN2_MII"
#define IFDESC_WLAN2_AP0		"WLAN2_AP0"
#define IFDESC_WLAN2_AP1		"WLAN2_AP1"
#define IFDESC_WLAN2_APC		"WLAN2_APC"
#define IFDESC_WLAN2_WDS		"WLAN2_WDS"
#if BOARD_HAS_5G_RADIO
#define IFDESC_WLAN5_AP0		"WLAN5_AP0"
#define IFDESC_WLAN5_AP1		"WLAN5_AP1"
#define IFDESC_WLAN5_APC		"WLAN5_APC"
#define IFDESC_WLAN5_WDS		"WLAN5_WDS"
#define IFDESCS_MAX_NUM			12
#else
#define IFDESCS_MAX_NUM			8
#endif


enum {
	IPV4_WAN_PROTO_IPOE_STATIC = 0,
	IPV4_WAN_PROTO_IPOE_DHCP,
	IPV4_WAN_PROTO_PPPOE,
	IPV4_WAN_PROTO_PPTP,
	IPV4_WAN_PROTO_L2TP
};

enum {
	IPV6_DISABLED = 0,
	IPV6_NATIVE_STATIC,
	IPV6_NATIVE_DHCP6,
	IPV6_6IN4,
	IPV6_6TO4,
	IPV6_6RD
};

extern in_addr_t inet_addr_safe(const char *cp);
extern int       is_valid_ipv4(const char *cp);
extern int       is_valid_hostname(const char *hname);
extern int       is_man_wisp(const char *ifname);
extern int       is_usbnet_interface(const char *ifname);
extern int       get_ap_mode(void);
extern int       get_wan_proto(int unit);
extern char*     get_man_ifname(int unit);
extern int       get_usb_modem_wan(int unit);
extern int       get_usb_modem_dev_wan(int unit, int devnum);
extern void      set_usb_modem_dev_wan(int unit, int devnum);
extern int       get_wan_ether_link_cached(void);
extern int       get_internet_state_cached(void);
extern int       ifconfig(const char *ifname, int flags, const char *addr, const char *mask);
extern int       is_interface_exist(const char *ifname);
extern int       is_interface_up(const char *ifname);
extern int       get_interface_flags(const char *ifname);
extern int       get_interface_index(const char *ifname);
extern int       get_interface_irq(const char *ifname);
extern int       get_interface_mtu(const char *ifname);
extern int       set_interface_mtu(const char *ifname, int mtu);
extern int       get_interface_hwaddr(const char *ifname, unsigned char mac[6]);
extern int       set_interface_hwaddr(const char *ifname, const char *mac_str);
extern in_addr_t get_interface_addr4(const char *ifname);
extern void      set_interface_conf_int(const char *ver, const char *ifname, const char *param, int value);
extern int       get_ipv6_type(void);

extern int       vconfig_add_if(const char *ifname, unsigned int vid);
extern int       vconfig_del_if(const char *vifname);
extern int       vconfig_egress_map(const char *vifname, int skb_prio, int qos_prio);

extern int       br_add_del_bridge(const char *brname, int is_add);
extern int       br_add_del_if(const char *brname, const char *ifname, int is_add);
extern int       br_del_all_ifs(const char *brname, int do_if_down, int do_if_rem);
extern void      br_set_param_int(const char *brname, const char *param, int value);
extern void      br_set_fd(const char *brname, int delay_sec);
extern void      br_set_stp(const char *brname, int stp_state);
extern void      brport_set_param_int(const char *ifname, const char *param, int value);
extern void      brport_set_m2u(const char *ifname, int m2u_on);

extern const char* get_ifname_descriptor(const char* ifname, int ap_mode, int *ifindex, int *wan_no);
extern uint64_t    get_ifstats_bytes_rx(const char* ifname);
extern uint64_t    get_ifstats_bytes_tx(const char* ifname);

#if defined (USE_IPV6)
extern int  is_valid_ipv6(const char *cp);
extern char *get_ifaddr6(const char *ifname, int linklocal, char *p_addr6s);
#endif

#endif
