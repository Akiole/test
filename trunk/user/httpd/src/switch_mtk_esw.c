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
 * stage2c: httpd switch status page, DSA (mt7530) replacement.
 * The three exported functions keep their signatures (web_ex.c call sites are
 * untouched by the wireless/httpd shard).  Internally they now read
 * /sys/class/net/<wan|lanX>/{operstate,speed,duplex,statistics/*} instead of
 * the closed-source /dev/mtk_esw ioctl.  Per-port detailed error MIB
 * (CRC/alignment/pause) is not exposed by mt7530 DSA and is dropped.
 *
 * Port UAPI -> DSA netdev: 0=wan, 1=lan1, 2=lan2, 3=lan3, 4=lan4.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>

#include "httpd.h"

static const char *
eth_port_netdev(int port_id_uapi)
{
	switch (port_id_uapi) {
	case 0: return "wan";
	case 1: return "lan1";
	case 2: return "lan2";
	case 3: return "lan3";
	case 4: return "lan4";
	default: return NULL;
	}
}

static int
read_sysfs_str(const char *ifname, const char *attr, char *buf, size_t len)
{
	char path[128];
	int fd;
	ssize_t n;

	snprintf(path, sizeof(path), "/sys/class/net/%s/%s", ifname, attr);
	fd = open(path, O_RDONLY);
	if (fd < 0)
		return -1;
	n = read(fd, buf, len - 1);
	close(fd);
	if (n <= 0)
		return -1;
	buf[n] = '\0';
	while (n > 0 && (buf[n-1] == '\n' || buf[n-1] == '\r')) { buf[n-1] = '\0'; n--; }
	return 0;
}

static long long
read_sysfs_ll(const char *ifname, const char *attr)
{
	char path[128], buf[32];
	int fd;
	ssize_t n;
	long long v = 0;

	snprintf(path, sizeof(path), "/sys/class/net/%s/%s", ifname, attr);
	fd = open(path, O_RDONLY);
	if (fd < 0)
		return 0;
	n = read(fd, buf, sizeof(buf) - 1);
	if (n > 0) { buf[n] = '\0'; v = strtoll(buf, NULL, 10); }
	close(fd);
	return v;
}

static int
port_link_up(const char *ifname)
{
	char state[16];
	if (read_sysfs_str(ifname, "operstate", state, sizeof(state)) != 0)
		return 0;
	return (strcmp(state, "up") == 0) ? 1 : 0;
}

////////////////////////////////////////////////////////////////////////////////

int
get_eth_port_bytes(int port_id_uapi, uint64_t *rx, uint64_t *tx)
{
	const char *ifname = eth_port_netdev(port_id_uapi);

	if (!ifname)
		return -1;

	*rx = (uint64_t) read_sysfs_ll(ifname, "statistics/rx_bytes");
	*tx = (uint64_t) read_sysfs_ll(ifname, "statistics/tx_bytes");
	return 0;
}

int
fill_eth_port_status(int port_id_uapi, char linkstate[40])
{
	const char *ifname = eth_port_netdev(port_id_uapi);
	char speed[16] = {0}, duplex[16] = {0};
	long spd = 0;

	if (!ifname) {
		strcpy(linkstate, "I/O Error");
		return 0;
	}

	if (!port_link_up(ifname)) {
		strcpy(linkstate, "No Link");
		return 0;
	}

	if (read_sysfs_str(ifname, "speed", speed, sizeof(speed)) == 0)
		spd = atol(speed);
	read_sysfs_str(ifname, "duplex", duplex, sizeof(duplex));

	/* "1000 Mbps, Full Duplex" (FC/EEE are not exposed per-port by DSA) */
	snprintf(linkstate, 40, "%ld Mbps, %s Duplex",
		spd, (strcmp(duplex, "full") == 0) ? "Full" : "Half");

	return 1;
}

int
fill_eth_status(int port_id_uapi, webs_t wp)
{
	const char *ifname = eth_port_netdev(port_id_uapi);
	char etherlink[40] = {0};
	int ret = 0;

	fill_eth_port_status(port_id_uapi, etherlink);
	ret += websWrite(wp, "Port Link			: %s\n", etherlink);

	if (!ifname)
		return ret;

	/* DSA exposes only the standard netdev statistics; detailed switch MIB
	 * (CRC / alignment / pause frames) is not available on mt7530 DSA. */
	ret += websWrite(wp, "\nStatistics\n");
	ret += websWrite(wp, "----------------------------------------\n");
	ret += websWrite(wp, "RX Bytes			: %llu\n",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/rx_bytes"));
	ret += websWrite(wp, "RX Packets			: %llu\n",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/rx_packets"));
	ret += websWrite(wp, "RX Errors			: %llu\n",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/rx_errors"));
	ret += websWrite(wp, "RX Dropped			: %llu\n",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/rx_dropped"));
	ret += websWrite(wp, "TX Bytes			: %llu\n",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/tx_bytes"));
	ret += websWrite(wp, "TX Packets			: %llu\n",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/tx_packets"));
	ret += websWrite(wp, "TX Errors			: %llu\n",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/tx_errors"));
	ret += websWrite(wp, "TX Dropped			: %llu",
		(unsigned long long) read_sysfs_ll(ifname, "statistics/tx_dropped"));

	return ret;
}
