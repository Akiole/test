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
 * stage2c: DSA (mt7530) replacement for the closed-source raeth/mtk_esw
 * switch control plane.  On linux-6.x there is no /dev/mtk_esw (major 219);
 * the switch is managed by the mainline DSA driver.  Every phy_* wrapper now
 * maps to /sys/class/net/<port> attributes or to iproute2 (ip link / bridge
 * vlan).  The exported signatures are kept identical so the upper layers
 * (net_lan.c / net_wan.c / detect_link.c / rstats.c) need no signature change.
 *
 * DSA netdev mapping (mt7530 on MT7621):
 *   UAPI 0 -> "wan"  (switch port@0)
 *   UAPI 1 -> "lan1" (port@1)
 *   UAPI 2 -> "lan2" (port@2)
 *   UAPI 3 -> "lan3" (port@3)
 *   UAPI 4 -> "lan4" (port@4)
 *   gmac0 -> switch0 port@6 is the only CPU port; the DSA framework
 *   aggregates its tagged/untagged membership automatically, so user space
 *   never addresses port@6 directly.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>

#include "rc.h"
#include "switch.h"

////////////////////////////////////////////////////////////////////////////////
// DSA port <-> netdev mapping + small sysfs helpers
////////////////////////////////////////////////////////////////////////////////

const char *
dsa_port_netdev(int port_id_uapi)
{
	switch (port_id_uapi) {
	case SWAPI_PORT_WAN:	return "wan";
	case SWAPI_PORT_LAN1:	return "lan1";
	case SWAPI_PORT_LAN2:	return "lan2";
	case SWAPI_PORT_LAN3:	return "lan3";
	case SWAPI_PORT_LAN4:	return "lan4";
	default:		return NULL;
	}
}

/* All user DSA ports (order: wan, lan1..lan4). CPU port@6 excluded. */
static const int dsa_all_ports[] = {
	SWAPI_PORT_WAN, SWAPI_PORT_LAN1, SWAPI_PORT_LAN2, SWAPI_PORT_LAN3, SWAPI_PORT_LAN4
};
#define DSA_ALL_PORTS_NUM  (sizeof(dsa_all_ports)/sizeof(dsa_all_ports[0]))

/* read a single-attribute sysfs file into a long; returns 0 on success */
static int
dsa_read_sysfs_long(const char *ifname, const char *attr, long *out)
{
	char path[128];
	char buf[32];
	int fd, ret = -1;
	ssize_t n;

	snprintf(path, sizeof(path), "/sys/class/net/%s/%s", ifname, attr);
	fd = open(path, O_RDONLY);
	if (fd < 0)
		return -1;
	n = read(fd, buf, sizeof(buf) - 1);
	if (n > 0) {
		buf[n] = '\0';
		*out = strtol(buf, NULL, 10);
		ret = 0;
	}
	close(fd);
	return ret;
}

/* read a string sysfs attribute (e.g. operstate/duplex) into buf, trimmed */
static int
dsa_read_sysfs_str(const char *ifname, const char *attr, char *buf, size_t len)
{
	char path[128];
	int fd, ret = -1;
	ssize_t n;
	size_t i;

	snprintf(path, sizeof(path), "/sys/class/net/%s/%s", ifname, attr);
	fd = open(path, O_RDONLY);
	if (fd < 0)
		return -1;
	n = read(fd, buf, len - 1);
	if (n > 0) {
		buf[n] = '\0';
		for (i = 0; buf[i] && i < len; i++)
			if (buf[i] == '\n' || buf[i] == '\r') { buf[i] = '\0'; break; }
		ret = 0;
	}
	close(fd);
	return ret;
}

/* physical link state of one DSA port: operstate == "up" -> 1 */
static int
dsa_port_link_up(const char *ifname)
{
	char state[16];

	if (dsa_read_sysfs_str(ifname, "operstate", state, sizeof(state)) != 0)
		return 0;
	return (strcmp(state, "up") == 0) ? 1 : 0;
}

////////////////////////////////////////////////////////////////////////////////
// SWITCH STATUS (read-only)
////////////////////////////////////////////////////////////////////////////////

int
phy_status_port_link(int port_id_uapi, unsigned int *p_link_on)
{
	const char *ifname = dsa_port_netdev(port_id_uapi);

	if (!ifname)
		return -EINVAL;
	*p_link_on = dsa_port_link_up(ifname);
	return 0;
}

int
phy_status_port_link_wan_all(unsigned int *p_link_on)
{
	/* single WAN port on this board (port@0 == "wan") */
	*p_link_on = dsa_port_link_up("wan") ? (1u << SWAPI_PORT_WAN) : 0;
	return 0;
}

int
phy_status_port_link_lan_all(unsigned int *p_link_on)
{
	unsigned int mask = 0;
	int i;

	for (i = SWAPI_PORT_LAN1; i <= SWAPI_PORT_LAN4; i++) {
		const char *ifname = dsa_port_netdev(i);
		if (ifname && dsa_port_link_up(ifname))
			mask |= (1u << i);
	}
	*p_link_on = mask;
	return 0;
}

/* Edge detection via polling: DSA has no private "link changed" event.  We
 * snapshot each port's operstate and report "changed" when any differs from
 * the previous poll.  detect_link.c calls us on a timer, so this is the
 * accepted poll fallback (design §1.1). */
int
phy_status_port_link_changed(unsigned int *p_link_changed)
{
	static unsigned int last_mask = 0;
	unsigned int cur_mask = 0;
	int i;

	for (i = SWAPI_PORT_WAN; i <= SWAPI_PORT_LAN4; i++) {
		const char *ifname = dsa_port_netdev(i);
		if (ifname && dsa_port_link_up(ifname))
			cur_mask |= (1u << i);
	}

	*p_link_changed = (cur_mask != last_mask) ? 1 : 0;
	last_mask = cur_mask;
	return 0;
}

////////////////////////////////////////////////////////////////////////////////

int
phy_status_port_speed(int port_id_uapi, unsigned int *p_speed_mode)
{
	const char *ifname = dsa_port_netdev(port_id_uapi);
	unsigned int mode = 0;
	long speed = 0;
	char duplex[16] = {0};

	if (!ifname)
		return -EINVAL;

	if (dsa_port_link_up(ifname)) {
		mode |= (1u << 16);			/* link up */
		if (dsa_read_sysfs_long(ifname, "speed", &speed) == 0) {
			if (speed >= 1000)	mode |= 2;	/* 1000M */
			else if (speed >= 100)	mode |= 1;	/* 100M */
			else			mode |= 0;	/* 10M */
		}
		if (dsa_read_sysfs_str(ifname, "duplex", duplex, sizeof(duplex)) == 0
		    && strcmp(duplex, "full") == 0) {
			mode |= (1u << 8);		/* full duplex */
			mode |= (3u << 9);		/* FC tx/rx (best-effort hint) */
		}
	}

	*p_speed_mode = mode;
	return 0;
}

////////////////////////////////////////////////////////////////////////////////

int
phy_set_link_port(int port_id_uapi, unsigned int link_mode, unsigned int flow_mode)
{
	const char *ifname = dsa_port_netdev(port_id_uapi);

	(void) flow_mode;	/* pause/flow control not reliably mappable; best-effort */
	if (!ifname)
		return -EINVAL;

	switch (link_mode) {
	case SWAPI_LINK_SPEED_MODE_AUTO:
	case SWAPI_LINK_SPEED_MODE_AUTO_1000_FD:
	case SWAPI_LINK_SPEED_MODE_AUTO_100_FD:
	case SWAPI_LINK_SPEED_MODE_AUTO_100_HD:
	case SWAPI_LINK_SPEED_MODE_AUTO_10_FD:
	case SWAPI_LINK_SPEED_MODE_AUTO_10_HD:
		doSystem("ethtool -s %s autoneg on", ifname);
		break;
	case SWAPI_LINK_SPEED_MODE_FORCE_POWER_OFF:
		doSystem("ip link set %s down", ifname);
		break;
	case SWAPI_LINK_SPEED_MODE_FORCE_100_FD:
		doSystem("ethtool -s %s speed 100 duplex full autoneg off", ifname);
		break;
	case SWAPI_LINK_SPEED_MODE_FORCE_100_HD:
		doSystem("ethtool -s %s speed 100 duplex half autoneg off", ifname);
		break;
	case SWAPI_LINK_SPEED_MODE_FORCE_10_FD:
		doSystem("ethtool -s %s speed 10 duplex full autoneg off", ifname);
		break;
	case SWAPI_LINK_SPEED_MODE_FORCE_10_HD:
		doSystem("ethtool -s %s speed 10 duplex half autoneg off", ifname);
		break;
	default:
		break;
	}

	return 0;
}

////////////////////////////////////////////////////////////////////////////////

int
phy_status_port_bytes(int port_id_uapi, uint64_t *rx, uint64_t *tx)
{
	const char *ifname = dsa_port_netdev(port_id_uapi);
	char path[128];
	char buf[32];
	int fd;
	ssize_t n;

	if (!ifname)
		return -EINVAL;

	*rx = 0;
	*tx = 0;

	snprintf(path, sizeof(path), "/sys/class/net/%s/statistics/rx_bytes", ifname);
	if ((fd = open(path, O_RDONLY)) >= 0) {
		n = read(fd, buf, sizeof(buf) - 1);
		if (n > 0) { buf[n] = '\0'; *rx = strtoull(buf, NULL, 10); }
		close(fd);
	}

	snprintf(path, sizeof(path), "/sys/class/net/%s/statistics/tx_bytes", ifname);
	if ((fd = open(path, O_RDONLY)) >= 0) {
		n = read(fd, buf, sizeof(buf) - 1);
		if (n > 0) { buf[n] = '\0'; *tx = strtoull(buf, NULL, 10); }
		close(fd);
	}

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// User-tunable features
////////////////////////////////////////////////////////////////////////////////

/* Storm rate limiting: no user-space equivalent on mt7530 DSA.  Kept as
 * no-ops (design §1.5 "保不住"). */
int phy_storm_unicast_unknown(unsigned int storm_rate_mbps) { (void) storm_rate_mbps; return 0; }
int phy_storm_multicast_unknown(unsigned int storm_rate_mbps) { (void) storm_rate_mbps; return 0; }
int phy_storm_multicast(unsigned int storm_rate_mbps) { (void) storm_rate_mbps; return 0; }
int phy_storm_broadcast(unsigned int storm_rate_mbps) { (void) storm_rate_mbps; return 0; }

/* Ethernet port LEDs: BOARD_NUM_ETH_LEDS=0 on FCJ; kept as no-ops. */
int phy_led_mode_green(unsigned int led_green)   { (void) led_green; return 0; }
int phy_led_mode_yellow(unsigned int led_yellow) { (void) led_yellow; return 0; }

int phy_green_ethernet(unsigned int green_ethernet_on) { (void) green_ethernet_on; return 0; }
int phy_eee_lpi(unsigned int eee_lpi_on) { (void) eee_lpi_on; return 0; }

/* Jumbo frames: bump MTU on every DSA user port (DSA ports follow CPU port). */
int
phy_jumbo_frames(unsigned int jumbo_frames_on)
{
	int mtu = jumbo_frames_on ? 9000 : 1500;
	size_t i;

	for (i = 0; i < DSA_ALL_PORTS_NUM; i++) {
		const char *ifname = dsa_port_netdev(dsa_all_ports[i]);
		if (ifname)
			doSystem("ip link set %s mtu %d", ifname, mtu);
	}
	return 0;
}

/* IGMP static ports: bridge has no direct "static group port"; would need
 * `bridge mdb add`.  No-op for now (design §1.5 "保不住"). */
int phy_igmp_static_port(int static_port) { (void) static_port; return 0; }

/* Bridge IGMP snooping is controlled by the bridge itself. */
int
phy_igmp_snooping(unsigned int igmp_snooping_on)
{
	int fd = open("/sys/class/net/br0/bridge/multicast_snooping", O_WRONLY);
	if (fd >= 0) {
		dprintf(fd, "%u", igmp_snooping_on ? 1u : 0u);
		close(fd);
	}
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// Port power (link up/down) -- DSA port "power" == netdev admin state
////////////////////////////////////////////////////////////////////////////////

int
phy_ports_power(int power_on)
{
	size_t i;

	for (i = 0; i < DSA_ALL_PORTS_NUM; i++) {
		const char *ifname = dsa_port_netdev(dsa_all_ports[i]);
		if (ifname)
			doSystem("ip link set %s %s", ifname, power_on ? "up" : "down");
	}
	return 0;
}

int
phy_ports_wan_power(int power_on)
{
	doSystem("ip link set %s %s", "wan", power_on ? "up" : "down");
	return 0;
}

int
phy_ports_lan_power(int power_on)
{
	int i;

	for (i = SWAPI_PORT_LAN1; i <= SWAPI_PORT_LAN4; i++) {
		const char *ifname = dsa_port_netdev(i);
		if (ifname)
			doSystem("ip link set %s %s", ifname, power_on ? "up" : "down");
	}
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// WAN<->LAN hardware isolation / STB pass-through
////////////////////////////////////////////////////////////////////////////////

/* wan_stb_x hardware cut-through (port-to-port bypass inside the switch ASIC)
 * has no DSA user-space equivalent.  A CPU soft bridge (brwan) could approximate
 * it but that path is gated behind the (unbuilt) USE_GMAC2 branch.  Degraded
 * to a documented no-op (design §3.3): STB/IPTV single-line reuse falls back to
 * the IPTV VLAN sub-interface (wan.<vid>) + normal bridging. */
int
phy_bridge_mode(unsigned int bridge_mode, int isolated_mode)
{
	(void) bridge_mode;
	(void) isolated_mode;
	return 0;
}

int phy_isolate_inic(unsigned int inic_isolated) { (void) inic_isolated; return 0; }
int phy_disable_inic(unsigned int inic_disabled) { (void) inic_disabled; return 0; }

/* L2 forwarding table is managed by the kernel/DSA; flush not needed. */
int phy_clear_mac_table(void) { return 0; }

////////////////////////////////////////////////////////////////////////////////
// VLAN configuration -> `bridge vlan add`
////////////////////////////////////////////////////////////////////////////////

int phy_vlan_reset_table(void) { return 0; }

/* Historical default WAN PVID; DSA reads it back via `bridge vlan show dev wan`
 * if needed.  Callers only use this as a fallback VID when nvram is invalid. */
int phy_vlan_pvid_wan_get(void) { return 2; }

/* Port accept-mode is implicit in bridge vlan pvid/untagged semantics. */
int phy_vlan_accept_port_mode(int accept_mode, unsigned int port_pask)
{
	(void) accept_mode;
	(void) port_pask;
	return 0;
}

/* Emit `bridge vlan add vid=<vid> dev <port> [pvid untagged]` for every port
 * bit set in the member mask (bit0=wan, bit1..4=lan1..4). */
static int
dsa_bridge_vlan_add_ports(int vid, unsigned int member, unsigned int untag, int as_pvid)
{
	int i;

	if (vid < 2 || vid >= 4095)
		return 0;

	for (i = SWAPI_PORT_WAN; i <= SWAPI_PORT_LAN4; i++) {
		const char *ifname;
		int is_member = (member >> i) & 1u;
		int is_untag = (untag >> i) & 1u;

		if (!is_member)
			continue;

		ifname = dsa_port_netdev(i);
		if (!ifname)
			continue;

		if (as_pvid && is_untag)
			doSystem("bridge vlan add vid=%d dev %s pvid untagged", vid, ifname);
		else if (is_untag)
			doSystem("bridge vlan add vid=%d dev %s untagged", vid, ifname);
		else
			doSystem("bridge vlan add vid=%d dev %s", vid, ifname);
	}

	return 0;
}

int
phy_vlan_create_port_vid(int pvid, int priority, unsigned int member, unsigned int untag, int fid)
{
	(void) priority;
	(void) fid;
	return dsa_bridge_vlan_add_ports(pvid, member, untag, 1);
}

int
phy_vlan_create_entry(int vid, unsigned int member, unsigned int untag, int fid)
{
	(void) fid;
	return dsa_bridge_vlan_add_ports(vid, member, untag, 0);
}

/* switch_config_vlan() issues one call per rule_id (0..5):
 *   0 = WAN INET, 1 = WAN IPTV, 2..5 = LAN1..LAN4.
 * WAN-side tagging is realised by the 802.1q sub-interfaces wan.<vid> created
 * in net_wan.c, so rules 0/1 need no per-port bridge vlan here.  LAN rules
 * translate to `bridge vlan add vid=<vid> dev lanX [pvid untagged]`. */
int
phy_vlan_rule_set(unsigned int rule_id, int vid, int priority, int tagged)
{
	const char *ifname = NULL;

	(void) priority;

	if (vid < 2 || vid >= 4095)
		return 0;

	switch (rule_id) {
	case SWAPI_VLAN_RULE_WAN_INET:
	case SWAPI_VLAN_RULE_WAN_IPTV:
		/* WAN uplink VLAN: handled by wan.<vid> sub-interface (net_wan.c). */
		return 0;
	case SWAPI_VLAN_RULE_WAN_LAN1:
		ifname = "lan1"; break;
	case SWAPI_VLAN_RULE_WAN_LAN2:
		ifname = "lan2"; break;
	case SWAPI_VLAN_RULE_WAN_LAN3:
		ifname = "lan3"; break;
	case SWAPI_VLAN_RULE_WAN_LAN4:
		ifname = "lan4"; break;
	default:
		return 0;
	}

	if (!ifname)
		return 0;

	if (tagged)
		doSystem("bridge vlan add vid=%d dev %s", vid, ifname);
	else
		doSystem("bridge vlan add vid=%d dev %s pvid untagged", vid, ifname);

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// /dev/mtk_esw node + CLI: no longer exists on 6.x.  Kept as inert symbols so
// rc.c (mtk_esw_node() call, "mtk_esw" command table entry) still links.
// The esw node creation is removed by the wireless/rc shard; these stubs make
// the deletion safe even before that edit lands.
////////////////////////////////////////////////////////////////////////////////

int mtk_esw_node(void) { return 0; }

int
mtk_esw_main(int argc, char **argv)
{
	(void) argc;
	(void) argv;
	/* On linux-6.x the switch is DSA; use `ip -br link`, `bridge vlan show`,
	 * `ethtool <port>` instead of the legacy mtk_esw ioctl CLI. */
	return 0;
}
