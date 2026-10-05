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

#ifndef _SWITCH_H_
#define _SWITCH_H_

#include <stdint.h>

#if defined(USE_RTL8367)
#include <rtl8367_ioctl.h>
int rtl8367_node(void);
int rtl8367_main(int argc, char **argv);
#endif

#if defined(USE_MTK_ESW) || defined(USE_MTK_GSW)
int mtk_esw_node(void);
int mtk_esw_main(int argc, char **argv);
#endif

////////////////////////////////////////////////////////////////////////////////
// DSA PORT / VLAN CONSTANTS (replacement for closed-source mtk_esw/ioctl.h)
//
// stage2c: 4.4 closed-source raeth/mtk_esw switch control (/dev/mtk_esw,
// major 219) no longer exists on linux-6.x.  The switch is now the mainline
// mt7530 DSA driver.  The numeric UAPI port ids / bridge-mode / vlan-rule /
// link-mode constants below are retained ONLY as source-compatible symbols so
// the upper layers (net_lan.c / net_wan.c / detect_link.c / rstats.c) keep
// their existing enumeration; the actual switch control面 is implemented in
// switch_mtk_esw.c via /sys/class/net/<port> + iproute2 (ip/bridge vlan).
//
// DSA netdev mapping (mt7530, port@0=wan, port@1-4=lan1..lan4,
// gmac0->switch0 port@6 = the only CPU port, aggregated by DSA framework):
//   UAPI 0 -> "wan", 1 -> "lan1", 2 -> "lan2", 3 -> "lan3", 4 -> "lan4".
////////////////////////////////////////////////////////////////////////////////

/* HW-independent port ids (== DSA switch port number) */
#define SWAPI_PORT_WAN			0
#define SWAPI_PORT_LAN1			1
#define SWAPI_PORT_LAN2			2
#define SWAPI_PORT_LAN3			3
#define SWAPI_PORT_LAN4			4
#define SWAPI_PORT_LAN5			5

/* WAN<->LAN bridge (STB / IPTV pass-through) modes -- hardware bypass is NOT
 * available under DSA; phy_bridge_mode() is a best-effort degraded no-op. */
#define SWAPI_WAN_BRIDGE_DISABLE		(0)
#define SWAPI_WAN_BRIDGE_LAN1			(1)
#define SWAPI_WAN_BRIDGE_LAN2			(2)
#define SWAPI_WAN_BRIDGE_LAN3			(3)
#define SWAPI_WAN_BRIDGE_LAN4			(4)
#define SWAPI_WAN_BRIDGE_LAN3_LAN4		(5)
#define SWAPI_WAN_BRIDGE_LAN1_LAN2		(6)
#define SWAPI_WAN_BRIDGE_LAN1_LAN2_LAN3		(7)
#define SWAPI_WAN_BRIDGE_DISABLE_WAN		(8)

#define SWAPI_WAN_BWAN_ISOLATION_NONE		(0)
#define SWAPI_WAN_BWAN_ISOLATION_FROM_CPU	(1)
#define SWAPI_WAN_BWAN_ISOLATION_BETWEEN	(2)

/* VLAN rule indices consumed by switch_config_vlan() */
#define SWAPI_VLAN_RULE_WAN_INET		(0)
#define SWAPI_VLAN_RULE_WAN_IPTV		(1)
#define SWAPI_VLAN_RULE_WAN_LAN1		(2)
#define SWAPI_VLAN_RULE_WAN_LAN2		(3)
#define SWAPI_VLAN_RULE_WAN_LAN3		(4)
#define SWAPI_VLAN_RULE_WAN_LAN4		(5)
#define SWAPI_VLAN_RULE_NUM			(SWAPI_VLAN_RULE_WAN_LAN4 + 1)

/* Link / flow-control modes (nvram ether_link_* / ether_flow_*) */
#define SWAPI_LINK_SPEED_MODE_AUTO		(0)
#define SWAPI_LINK_SPEED_MODE_AUTO_1000_FD	(1)
#define SWAPI_LINK_SPEED_MODE_AUTO_100_FD	(2)
#define SWAPI_LINK_SPEED_MODE_AUTO_100_HD	(3)
#define SWAPI_LINK_SPEED_MODE_AUTO_10_FD	(4)
#define SWAPI_LINK_SPEED_MODE_AUTO_10_HD	(5)
#define SWAPI_LINK_SPEED_MODE_FORCE_100_FD	(6)
#define SWAPI_LINK_SPEED_MODE_FORCE_100_HD	(7)
#define SWAPI_LINK_SPEED_MODE_FORCE_10_FD	(8)
#define SWAPI_LINK_SPEED_MODE_FORCE_10_HD	(9)
#define SWAPI_LINK_SPEED_MODE_FORCE_POWER_OFF	(15)

#define SWAPI_LINK_FLOW_CONTROL_TX_RX		(0)
#define SWAPI_LINK_FLOW_CONTROL_TX_ASYNC	(1)
#define SWAPI_LINK_FLOW_CONTROL_DISABLE		(2)

/* Ethernet LED modes (BOARD_NUM_ETH_LEDS=0 on FCJ, compiled out) */
#define SWAPI_LED_OFF				(11)

/* Map a UAPI port id to its DSA netdev name (0=wan,1..4=lan1..lan4).
 * Returns NULL for out-of-range ports. */
const char *dsa_port_netdev(int port_id_uapi);

////////////////////////////////////////////////////////////////////////////////
// SWITCH STATUS
////////////////////////////////////////////////////////////////////////////////

int phy_status_port_link(int port_id_uapi, unsigned int *p_link_on);
int phy_status_port_link_wan_all(unsigned int *p_link_on);
int phy_status_port_link_lan_all(unsigned int *p_link_on);
int phy_status_port_link_changed(unsigned int *p_link_changed);

int phy_status_port_speed(int port_id_uapi, unsigned int *p_speed_mode);

int phy_status_port_bytes(int port_id_uapi, uint64_t *rx, uint64_t *tx);

////////////////////////////////////////////////////////////////////////////////
// SWITCH CONTROL
////////////////////////////////////////////////////////////////////////////////

int phy_set_link_port(int port_id_uapi, unsigned int link_mode, unsigned int flow_mode);

int phy_storm_unicast_unknown(unsigned int storm_rate_mbps);
int phy_storm_multicast_unknown(unsigned int storm_rate_mbps);
int phy_storm_multicast(unsigned int storm_rate_mbps);
int phy_storm_broadcast(unsigned int storm_rate_mbps);

int phy_led_mode_green(unsigned int led_green);
int phy_led_mode_yellow(unsigned int led_yellow);

int phy_green_ethernet(unsigned int green_ethernet_on);
int phy_eee_lpi(unsigned int eee_lpi_on);
int phy_jumbo_frames(unsigned int jumbo_frames_on);
int phy_igmp_static_port(int static_port);
int phy_igmp_snooping(unsigned int igmp_snooping_on);

int phy_ports_power(int power_on);
int phy_ports_wan_power(int power_on);
int phy_ports_lan_power(int power_on);

int phy_bridge_mode(unsigned int bridge_mode, int isolated_mode);
int phy_isolate_inic(unsigned int inic_isolated);
int phy_disable_inic(unsigned int inic_disabled);

int phy_clear_mac_table(void);

int phy_vlan_reset_table(void);
int phy_vlan_pvid_wan_get(void);
int phy_vlan_accept_port_mode(int accept_mode, unsigned int port_pask);
int phy_vlan_create_port_vid(int pvid, int priority, unsigned int member, unsigned int untag, int fid);
int phy_vlan_create_entry(int vid, unsigned int member, unsigned int untag, int fid);
int phy_vlan_rule_set(unsigned int rule_id, int vid, int priority, int tagged);

#endif
