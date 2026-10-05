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
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <limits.h>
#include <fcntl.h>
#include <signal.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/klog.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <assert.h>
#include <dirent.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/ethernet.h>
#include <net/if.h>
#include <linux/ethtool.h>
#include <linux/sockios.h>
#include <net/if_arp.h>

#include <iwlib.h>

#include "common.h"
#include "httpd.h"

/******************************************************************************************************************************************/

/* Dump leases in <tr><td>hostname</td><td>MAC</td><td>IP</td><td>expires</td></tr> format */
int
ej_lan_leases(int eid, webs_t wp, int argc, char **argv)
{
	/* dnsmasq ex: 43200 00:26:18:57:08:bc 192.168.1.105 mypc-3eaf6880a0 01:00:26:18:57:08:bc */

	FILE *fp = NULL;
	int ret = 0;
	int i;
	char buff[256], dh_lease[32], dh_mac[64], dh_ip[64], dh_host[64];
#if defined (USE_IPV6)
	int ip6_count = 0;
	struct in6_addr addr6;
#endif

	ret += websWrite(wp, "IPv4 Address       MAC Address          Host Name\n");
	//                    192.168.100.100    00:90:F5:XX:XX:XX    Padavan
	//                    ffff:ffff:ffff:0001:0000:0000:0000:0001 Padavan

	if (!(fp = fopen("/tmp/dnsmasq.leases", "r")))
		return ret;

	while (fgets(buff, sizeof(buff), fp)) {
		if (sscanf(buff, "%31s %63s %63s %63s %*s", dh_lease, dh_mac, dh_ip, dh_host) != 4)
			continue;

		if (strcmp(dh_lease, "duid") == 0)
			continue;

#if defined (USE_IPV6)
		if (inet_pton(AF_INET6, dh_ip, &addr6) != 0) {
			ip6_count++;
			continue;
		}
#endif
		strcat(dh_lease, " secs");

		if (!dh_host[0])
			strcpy(dh_host, "*");

		// convert MAC to upper case
		for (i=0; i<strlen(dh_mac); i++)
			dh_mac[i] = toupper(dh_mac[i]);

		ret += websWrite(wp, "%-19s", (dh_ip[0]!=0) ? dh_ip : " ");
		ret += websWrite(wp, "%-21s", (dh_mac[0]!=0) ? dh_mac : " " );
		ret += websWrite(wp, "%s\n",  dh_host);
	}
	fclose(fp);

#if defined (USE_IPV6)
	if (ip6_count < 1)
		return ret;

	ret += websWrite(wp, "\nIPv6 Address                            Host Name\n");
	//                      ffff:ffff:ffff:0001:0000:0000:0000:0001 Padavan

	fp = fopen("/tmp/dnsmasq.leases", "r");
	if (fp) {
		while (fgets(buff, sizeof(buff), fp)) {
			if (sscanf(buff, "%31s %63s %63s %63s %*s", dh_lease, dh_mac, dh_ip, dh_host) != 4)
				continue;

			if (strcmp(dh_lease, "duid") == 0)
				continue;

			if (inet_pton(AF_INET6, dh_ip, &addr6) == 0)
				continue;

			strcat(dh_lease, " secs");

			if (!dh_host[0])
				strcpy(dh_host, "*");

			ret += websWrite(wp, "%-40s", (dh_ip[0]!=0) ? dh_ip : " ");
			ret += websWrite(wp, "%s\n",  dh_host);
		}
		fclose(fp);
	}
#endif

	return ret;
}

int
ej_vpns_leases(int eid, webs_t wp, int argc, char **argv)
{
	FILE *fp;
	int ret = 0, i_clients = 0;
	char ifname[16], addr_l[64], addr_r[64], peer_name[64];

	ret += websWrite(wp, "#  IP Local         IP Remote        Login          NetIf\n");

	if (!(fp = fopen("/tmp/vpns.leases", "r"))) {
		return ret;
	}

	while (fscanf(fp, "%15s %63s %63s %63[^\n]\n", ifname, addr_l, addr_r, peer_name) == 4) 
	{
		i_clients++;
		ret += websWrite(wp, "%-3u", i_clients);
		ret += websWrite(wp, "%-17s", addr_l);
		ret += websWrite(wp, "%-17s", addr_r);
		ret += websWrite(wp, "%-15s", peer_name);
		ret += websWrite(wp, "%s\n",  ifname);
	}
	fclose(fp);

	return ret;
}

int is_hwnat_loaded()
{
#if defined (USE_HW_NAT)
	DIR *dir_to_open = NULL;
	FILE *fp;
	char offload_val[32];

	dir_to_open = opendir("/sys/module/hw_nat");
	if (dir_to_open)
	{
		closedir(dir_to_open);
		fp = fopen("/sys/module/hw_nat/parameters/wifi_offload", "r");
		if (fp) {
			offload_val[0] = 0;
			fgets(offload_val, sizeof(offload_val), fp);
			fclose(fp);
			if (strlen(offload_val) > 0)
				offload_val[strlen(offload_val) - 1] = 0; /* get rid of '\n' */

			if (offload_val[0] == 'Y' || offload_val[0] == '1')
				return 2;
		}

		return 1;
	}
#endif
	return 0;
}

/* Dump NAT table <tr><td>destination</td><td>MAC</td><td>IP</td><td>expires</td></tr> format */
int
ej_nat_table(int eid, webs_t wp, int argc, char **argv)
{
	FILE *fp;
	int ret, sw_mode;
	char line[256], tmp[256], target[16], proto[16], src[24], dst[24];
	char *range, *host, *port, *ptr, *val;
	char *nat_argv[] = {"iptables", "-t", "nat", "-nxL", NULL};

	ret = 0;
	sw_mode = nvram_get_int("sw_mode");

#if defined (USE_HW_NAT)
	if (sw_mode == 1 || sw_mode == 4) {
		const char *hwnat_status = "Disabled";
		int i_loaded = is_hwnat_loaded();

		if (i_loaded == 2)
#if defined(USE_WWAN_HW_NAT)
			hwnat_status = "Enabled, IPoE/PPPoE offload [WAN/WWAN]<->[LAN/WLAN]";
#else
			hwnat_status = "Enabled, IPoE/PPPoE offload [WAN]<->[LAN/WLAN]";
#endif
		else if (i_loaded == 1)
			hwnat_status = "Enabled, IPoE/PPPoE offload [WAN]<->[LAN]";

		ret += websWrite(wp, "Hardware NAT/Routing: %s\n", hwnat_status);
	}
#endif

	if (sw_mode == 1) {
//		ret += websWrite(wp, "Software QoS: %s\n", nvram_match("qos_enable", "1") ? "Enabled": "Disabled");
		ret += websWrite(wp, "\n");

		ret += websWrite(wp, "Port Forwards List\n");
		ret += websWrite(wp, "----------------------------------------\n");
		ret += websWrite(wp, "Source             Proto  Port Range  Redirect to     Local port\n");
//                                    255.255.255.255/24 other  65535:65535 255.255.255.255 65535:65535

//		ret += websWrite(wp, "Source             Destination        Proto Port Range  Redirect to     Local port\n");
//                                    255.255.255.255/24 255.255.255.255/24 other 65535:65535 255.255.255.255 65535:65535

		_eval(nat_argv, ">/tmp/nat.log", 3, NULL);

		fp = fopen("/tmp/nat.log", "r");
		if (fp == NULL)
			return ret;

		while (fgets(line, sizeof(line), fp) != NULL) {
			tmp[0] = 0;
			if (sscanf(line,
			    "%15s%*[ \t]"		// target
			    "%15s%*[ \t]"		// prot
			    "%*s%*[ \t]"		// opt
			    "%18s%*[ \t]"		// source
			    "%18s%*[ \t]"		// destination
			    "%255[^\n]",		// options
			    target, proto, src, dst, tmp) < 4)
				continue;

			if (strcmp(target, "DNAT"))
				continue;

			for (ptr = proto; *ptr; ptr++)
				*ptr = toupper(*ptr);

			if (!strcmp(src, "0.0.0.0/0"))
				strcpy(src, "ALL");

			if (!strcmp(dst, "0.0.0.0/0"))
				strcpy(dst, "ALL");

			port = host = range = "";
			ptr = tmp;
			while ((val = strsep(&ptr, " ")) != NULL) {
				if (strncmp(val, "dpt:", 4) == 0)
					range = val + 4;
				else if (strncmp(val, "dpts:", 5) == 0)
					range = val + 5;
				else if (strncmp(val, "to:", 3) == 0) {
					port = host = val + 3;
					strsep(&port, ":");
				}
			}

			ret += websWrite(wp,
				"%-18s %-6s %-11s %-15s %-11s\n",
				src, proto, range, host, port ? : range);
		}
		fclose(fp);
	}

	return ret;
}

int
ej_route_table(int eid, webs_t wp, int argc, char **argv)
{
	char buff[256];
	int  nl = 0 ;
	struct in_addr dest;
	struct in_addr gw;
	struct in_addr mask;
	int flgs, ref, use, metric, ret;
	char flags[4];
	unsigned long int d,g,m;
	char sdest[16], sgw[16];
	FILE *fp;

	ret = 0;
	ret += websWrite(wp, "Destination     Gateway         Genmask         Flags Metric Ref    Use Iface\n");

	if (!(fp = fopen("/proc/net/route", "r"))) return 0;

	while (fgets(buff, sizeof(buff), fp) != NULL )
	{
		if (nl)
		{
			int ifl = 0;
			while (buff[ifl]!=' ' && buff[ifl]!='\t' && buff[ifl]!='\0')
				ifl++;
			buff[ifl]=0;    /* interface */
			if (sscanf(buff+ifl+1, "%lx%lx%d%d%d%d%lx",
			   &d, &g, &flgs, &ref, &use, &metric, &m)!=7) {
				//error_msg_and_die( "Unsuported kernel route format\n");
				//continue;
			}

			ifl = 0;	/* parse flags */
			if (flgs&1)
				flags[ifl++]='U';
			if (flgs&2)
				flags[ifl++]='G';
			if (flgs&4)
				flags[ifl++]='H';
			flags[ifl]=0;
			dest.s_addr = d;
			gw.s_addr   = g;
			mask.s_addr = m;
			strcpy(sdest,  (dest.s_addr==0 ? "default" :
					inet_ntoa(dest)));
			strcpy(sgw,    (gw.s_addr==0   ? "*"       :
					inet_ntoa(gw)));

			ret += websWrite(wp, "%-16s%-16s%-16s%-6s%-6d %-2d %7d %s\n",
				sdest, sgw, inet_ntoa(mask), flags, metric, ref, use, buff);
		}
		nl++;
	}
	fclose(fp);

	return ret;
}

int
ej_conntrack_table(int eid, webs_t wp, int argc, char **argv)
{
	FILE *fp;
	int ret;
	char buff[1024], ipv[16], proto[16], state[32], src[64], dst[64], sport[8], dport[8];

	ret = 0;
	ret += websWrite(wp, "Proto   Source Address & Port                           Destination Address & Port\n");
	//                    tcp     222.222.222.222:65535                           222.222.222.222:65535
	//                    tcp     [ffff:ffff:ffff:0001:0000:0000:0000:0001]:65535 [ffff:ffff:ffff:0001:0000:0000:0000:0001]:65535

	if (!(fp = fopen("/proc/net/nf_conntrack", "r"))) return 0;

	while (fgets(buff, sizeof(buff), fp) != NULL) {
		if (sscanf(buff, "%15s %*s %15s", ipv, proto) < 2)
			continue;

		if (strcmp(proto, "tcp") == 0 || strcmp(proto, "sctp") == 0) {
			if (sscanf(buff, "%*s %*s %*s %*s %*s %31s src=%63s dst=%63s sport=%7s dport=%7s", state, src, dst, sport, dport) < 5)
				continue;
			if (strcmp(state, "ESTABLISHED") != 0)
				continue;
		} else {
			if (sscanf(buff, "%*s %*s %*s %*s %*s src=%63s dst=%63s sport=%7s dport=%7s", src, dst, sport, dport) < 4)
				continue;
		}
#if defined (USE_IPV6)
		if (strcmp(ipv, "ipv6") == 0) {
			struct in6_addr addr6;
			if (inet_pton(AF_INET6, src, &addr6) == 1) {
				inet_ntop(AF_INET6, &addr6, src+1, sizeof(src)-1);
				src[0] = '[';
				strcat(src, "]");
			}
			if (inet_pton(AF_INET6, dst, &addr6) == 1) {
				inet_ntop(AF_INET6, &addr6, dst+1, sizeof(dst)-1);
				dst[0] = '[';
				strcat(dst, "]");
			}
		}
#endif
		strcat(src, ":");
		strcat(src, sport);
		strcat(dst, ":");
		strcat(dst, dport);
		ret += websWrite(wp, "%-8s%-48s%s\n", proto, src, dst);
	}

	fclose(fp);

	return ret;
}

/************************ CONSTANTS & MACROS ************************/

/*
 * Constants fof WE-9->15
 */
#define IW15_MAX_FREQUENCIES	16
#define IW15_MAX_BITRATES	8
#define IW15_MAX_TXPOWER	8
#define IW15_MAX_ENCODING_SIZES	8
#define IW15_MAX_SPY		8
#define IW15_MAX_AP		8

/****************************** TYPES ******************************/

/*
 *	Struct iw_range up to WE-15
 */
struct	iw15_range
{
	__u32		throughput;
	__u32		min_nwid;
	__u32		max_nwid;
	__u16		num_channels;
	__u8		num_frequency;
	struct iw_freq	freq[IW15_MAX_FREQUENCIES];
	__s32		sensitivity;
	struct iw_quality	max_qual;
	__u8		num_bitrates;
	__s32		bitrate[IW15_MAX_BITRATES];
	__s32		min_rts;
	__s32		max_rts;
	__s32		min_frag;
	__s32		max_frag;
	__s32		min_pmp;
	__s32		max_pmp;
	__s32		min_pmt;
	__s32		max_pmt;
	__u16		pmp_flags;
	__u16		pmt_flags;
	__u16		pm_capa;
	__u16		encoding_size[IW15_MAX_ENCODING_SIZES];
	__u8		num_encoding_sizes;
	__u8		max_encoding_tokens;
	__u16		txpower_capa;
	__u8		num_txpower;
	__s32		txpower[IW15_MAX_TXPOWER];
	__u8		we_version_compiled;
	__u8		we_version_source;
	__u16		retry_capa;
	__u16		retry_flags;
	__u16		r_time_flags;
	__s32		min_retry;
	__s32		max_retry;
	__s32		min_r_time;
	__s32		max_r_time;
	struct iw_quality	avg_qual;
};

/*
 * Union for all the versions of iwrange.
 * Fortunately, I mostly only add fields at the end, and big-bang
 * reorganisations are few.
 */
union	iw_range_raw
{
	struct iw15_range	range15;	/* WE 9->15 */
	struct iw_range		range;		/* WE 16->current */
};

/*
 * Offsets in iw_range struct
 */
#define iwr15_off(f)	( ((char *) &(((struct iw15_range *) NULL)->f)) - \
			  (char *) NULL)
#define iwr_off(f)	( ((char *) &(((struct iw_range *) NULL)->f)) - \
			  (char *) NULL)

/* Disable runtime version warning in ralink_get_range_info() */
int	iw_ignore_version_sp = 0;

/*------------------------------------------------------------------*/
/*
 * Get the range information out of the driver
 */
int
ralink_get_range_info(iwrange *	range, char* buffer, int length)
{
  union iw_range_raw *	range_raw;

  /* Point to the buffer */
  range_raw = (union iw_range_raw *) buffer;

  /* For new versions, we can check the version directly, for old versions
   * we use magic. 300 bytes is a also magic number, don't touch... */
  if (length < 300)
    {
      /* That's v10 or earlier. Ouch ! Let's make a guess...*/
      range_raw->range.we_version_compiled = 9;
    }

  /* Check how it needs to be processed */
  if (range_raw->range.we_version_compiled > 15)
    {
      /* This is our native format, that's easy... */
      /* Copy stuff at the right place, ignore extra */
      memcpy((char *) range, buffer, sizeof(iwrange));
    }
  else
    {
      /* Zero unknown fields */
      bzero((char *) range, sizeof(struct iw_range));

      /* Initial part unmoved */
      memcpy((char *) range,
	     buffer,
	     iwr15_off(num_channels));
      /* Frequencies pushed futher down towards the end */
      memcpy((char *) range + iwr_off(num_channels),
	     buffer + iwr15_off(num_channels),
	     iwr15_off(sensitivity) - iwr15_off(num_channels));
      /* This one moved up */
      memcpy((char *) range + iwr_off(sensitivity),
	     buffer + iwr15_off(sensitivity),
	     iwr15_off(num_bitrates) - iwr15_off(sensitivity));
      /* This one goes after avg_qual */
      memcpy((char *) range + iwr_off(num_bitrates),
	     buffer + iwr15_off(num_bitrates),
	     iwr15_off(min_rts) - iwr15_off(num_bitrates));
      /* Number of bitrates has changed, put it after */
      memcpy((char *) range + iwr_off(min_rts),
	     buffer + iwr15_off(min_rts),
	     iwr15_off(txpower_capa) - iwr15_off(min_rts));
      /* Added encoding_login_index, put it after */
      memcpy((char *) range + iwr_off(txpower_capa),
	     buffer + iwr15_off(txpower_capa),
	     iwr15_off(txpower) - iwr15_off(txpower_capa));
      /* Hum... That's an unexpected glitch. Bummer. */
      memcpy((char *) range + iwr_off(txpower),
	     buffer + iwr15_off(txpower),
	     iwr15_off(avg_qual) - iwr15_off(txpower));
      /* Avg qual moved up next to max_qual */
      memcpy((char *) range + iwr_off(avg_qual),
	     buffer + iwr15_off(avg_qual),
	     sizeof(struct iw_quality));
    }

  /* We are now checking much less than we used to do, because we can
   * accomodate more WE version. But, there are still cases where things
   * will break... */
  if (!iw_ignore_version_sp)
    {
      /* We don't like very old version (unfortunately kernel 2.2.X) */
      if (range->we_version_compiled <= 10)
	{
	  fprintf(stderr, "Warning: Driver for device %s has been compiled with an ancient version\n", "raxx");
	  fprintf(stderr, "of Wireless Extension, while this program support version 11 and later.\n");
	  fprintf(stderr, "Some things may be broken...\n\n");
	}

      /* We don't like future versions of WE, because we can't cope with
       * the unknown */
      if (range->we_version_compiled > WE_MAX_VERSION)
	{
	  fprintf(stderr, "Warning: Driver for device %s has been compiled with version %d\n", "raxx", range->we_version_compiled);
	  fprintf(stderr, "of Wireless Extension, while this program supports up to version %d.\n", WE_VERSION);
	  fprintf(stderr, "Some things may be broken...\n\n");
	}

      /* Driver version verification */
      if ((range->we_version_compiled > 10) &&
	 (range->we_version_compiled < range->we_version_source))
	{
	  fprintf(stderr, "Warning: Driver for device %s recommend version %d of Wireless Extension,\n", "raxx", range->we_version_source);
	  fprintf(stderr, "but has been compiled with version %d, therefore some driver features\n", range->we_version_compiled);
	  fprintf(stderr, "may not be available...\n\n");
	}
      /* Note : we are only trying to catch compile difference, not source.
       * If the driver source has not been updated to the latest, it doesn't
       * matter because the new fields are set to zero */
    }

  /* Don't complain twice.
   * In theory, the test apply to each individual driver, but usually
   * all drivers are compiled from the same kernel. */
  iw_ignore_version_sp = 1;

  return (0);
}

#define RTPRIV_IOCTL_SHOW			(SIOCIWFIRSTPRIV + 0x11)
#define RTPRIV_IOCTL_GET_MAC_TABLE		(SIOCIWFIRSTPRIV + 0x0F)
#define RTPRIV_IOCTL_GET_MAC_TABLE_STRUCT	(SIOCIWFIRSTPRIV + 0x1F)

int
wl_ioctl(const char *ifname, int cmd, struct iwreq *pwrq)
{
	int ret = 0;
 	int s;

	if (!ifname || !*ifname)
		return -1;

	/* open socket to kernel */
	if ((s = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		perror("socket");
		return errno;
	}

	/* do it */
	strncpy(pwrq->ifr_name, ifname, IFNAMSIZ);
	if ((ret = ioctl(s, cmd, pwrq)) < 0)
		perror(pwrq->ifr_name);

	/* cleanup */
	close(s);
	return ret;
}

/* ==========================================================================
 * stage2c: mt76 / hostapd data-source helpers.
 *
 * The closed-source Ralink SDK private ioctls (RTPRIV_IOCTL_*, RT_PRIV_IOCTL,
 * SIOCGIWFREQ/SIOCGIWRANGE on ra0/rax0) do not exist on the new mt76/mac80211
 * stack. These helpers shell out to the standard userspace tools:
 *   - /bin/iw            (nl80211: dev info / station dump / scan dump)
 *   - /bin/hostapd_cli   (hostapd control interface)
 *
 * The wireless-rc slice provides, via rtutils.h (frozen contract):
 *   wifi_main_ifname(aband) / wifi_guest_ifname(aband) / wifi_apcli_ifname()
 *   wifi_phy_name(aband)   aband: 1=5G, 0=2.4G
 * ========================================================================== */

/* Run a shell command, capture its stdout into out[] (NUL-terminated). */
static int
capture_cmd(const char *cmd, char *out, size_t outlen)
{
	FILE *fp;
	size_t n;

	if (!out || outlen == 0)
		return -1;
	out[0] = '\0';
	fp = popen(cmd, "r");
	if (!fp)
		return -1;
	n = fread(out, 1, outlen - 1, fp);
	out[n] = '\0';
	pclose(fp);
	return 0;
}

/* hostapd_cli -i <ifname> <arg...> ; stdout captured. */
static int
run_hostapd_cli(const char *ifname, const char *arg, char *out, size_t outlen)
{
	char cmd[320];

	if (!ifname || !*ifname)
		return -1;
	snprintf(cmd, sizeof(cmd), "/bin/hostapd_cli -i %s %s 2>/dev/null", ifname, arg);
	return capture_cmd(cmd, out, outlen);
}

/* iw dev <ifname> <args...> ; stdout captured. */
static int
run_iw_dev(const char *ifname, const char *args, char *out, size_t outlen)
{
	char cmd[384];

	if (!ifname || !*ifname)
		return -1;
	snprintf(cmd, sizeof(cmd), "/bin/iw dev %s %s 2>/dev/null", ifname, args);
	return capture_cmd(cmd, out, outlen);
}

/* Current operating channel of <ifname> parsed from `iw dev <if> info`.
 * Returns 0 if unknown/radio down. */
static int
iw_current_channel(const char *ifname)
{
	char out[2048], *p;
	int ch = 0;

	if (run_iw_dev(ifname, "info", out, sizeof(out)) < 0)
		return 0;
	for (p = out; (p = strstr(p, "channel")) != NULL; p += 7) {
		if (sscanf(p, "channel %d", &ch) == 1 ||
		    sscanf(p, "channel: %d", &ch) == 1)
			return ch;
	}
	return 0;
}

/* Is MAC associated on <ifname>? If so and rssi!=NULL, fill signal (dBm). */
static int
iw_sta_has_mac(const char *ifname, const unsigned char *mac, int *rssi)
{
	char out[8192], macstr[18], *p;

	snprintf(macstr, sizeof(macstr), "%02x:%02x:%02x:%02x:%02x:%02x",
		mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	if (run_iw_dev(ifname, "station dump", out, sizeof(out)) < 0)
		return 0;
	p = strcasestr(out, macstr);
	if (!p)
		return 0;
	if (rssi) {
		char *s = strstr(p, "signal:");
		if (s && (s - p) < 600)
			sscanf(s, "signal: %d", rssi);
		else
			*rssi = 0;
	}
	return 1;
}

/* Print an associated-STA list (MAC + RSSI) for <ifname> via `iw station dump`. */
static int
iw_print_sta_list(webs_t wp, const char *ifname, const char *caption)
{
	char out[16384], *p;
	int ret = 0;

	ret += websWrite(wp, "\nAP %s Stations List\n", caption);
	ret += websWrite(wp, "----------------------------------------\n");
	ret += websWrite(wp, "%-19s%-6s\n", "MAC", "RSSI");

	if (run_iw_dev(ifname, "station dump", out, sizeof(out)) < 0)
		return ret;

	for (p = out; (p = strcasestr(p, "Station ")) != NULL; p += 8) {
		char mac[18] = {0};
		int sig = 0;

		if (sscanf(p, "Station %17s", mac) != 1)
			continue;
		{
			char *s = strstr(p, "signal:");
			if (s && (s - p) < 600)
				sscanf(s, "signal: %d", &sig);
		}
		ret += websWrite(wp, "%s  %4d\n", mac, sig);
	}
	return ret;
}

char* GetBW(int BW)
{
	switch(BW)
	{
	case BW_10:
		return "10M";
	case BW_20:
		return "20M";
	case BW_40:
		return "40M";
	case BW_80:
		return "80M";
	case BW_160:
		return "160M";
	default:
		return "N/A";
	}
}

char* GetPhyMode(int Mode)
{
	switch(Mode)
	{
	case MODE_CCK:
		return "CCK";
	case MODE_OFDM:
		return "OFDM";
	case MODE_HTMIX:
		return "HTMIX";
	case MODE_HTGREENFIELD:
		return "HT_GF";
	case MODE_VHT:
		return "VHT";
	case MODE_HE:
	case MODE_HE_SU:
	case MODE_HE_24G:
	case MODE_HE_5G:
	case MODE_HE_EXT_SU:
	case MODE_HE_TRIG:
	case MODE_HE_MU:
		return "HE";
	default:
		return "N/A";
	}
}

static int
getMCS(MACHTTRANSMIT_SETTING HTSetting)
{
	int mcs_1ss = (int)HTSetting.field.MCS;

	if (HTSetting.field.MODE >= MODE_VHT) {
		if (mcs_1ss > 9)
			mcs_1ss %= 16;
	}

	return mcs_1ss;
}

static const int
MCSMappingRateTable[] =
{
	/* CCK */
	1, 2, 5, 11,

	/* OFDM */
	6, 9, 12, 18, 24, 36, 48, 54,

	/* 11n 20MHz, 800ns GI */
	6,  13, 19,  26,  39,  52,  58, 65,			/* 1ss , MCS 0-7 */
	13, 26, 39,  52,  78, 104, 117, 130,		/* 2ss , MCS 8-15 */
	19, 39, 58,  78, 117, 156, 175, 195,		/* 3ss , MCS 16-23 */
	26, 52, 78, 104, 156, 208, 234, 260,		/* 4ss , MCS 24-31 */

	/* 11n 40MHz, 800ns GI */
	13,  27,  40,  54,  81, 108, 121, 135,
	27,  54,  81, 108, 162, 216, 243, 270,
	40,  81, 121, 162, 243, 324, 364, 405,
	54, 108, 162, 216, 324, 432, 486, 540,

	/* 11n 20MHz, 400ns GI */
	7,  14, 21,  28,  43,  57,  65,  72,
	14, 28, 43,  57,  86, 115, 130, 144,
	21, 43, 65,  86, 130, 173, 195, 216,
	28, 57, 86, 115, 173, 231, 260, 288,

	/* 11n 40MHz, 400ns GI */
	15,  30,  45,  60,  90, 120, 135, 150,
	30,  60,  90, 120, 180, 240, 270, 300,
	45,  90, 135, 180, 270, 360, 405, 450,
	60, 120, 180, 240, 360, 480, 540, 600,

	/* 11ac 20 Mhz 800ns GI */
	6,  13, 19, 26,  39,  52,  58,  65,  78,  87,     /*1ss mcs 0~8*/
	13, 26, 39, 52,  78,  104, 117, 130, 156, 173,    /*2ss mcs 0~8*/
	19, 39, 58, 78,  117, 156, 175, 195, 234, 260,    /*3ss mcs 0~9*/
	26, 52, 78, 104, 156, 208, 234, 260, 312, 347,    /*4ss mcs 0~8*/

	/* 11ac 40 Mhz 800ns GI */
	13,	27,	40,	54,	 81,  108, 121, 135, 162, 180,   /*1ss mcs 0~9*/
	27,	54,	81,	108, 162, 216, 243, 270, 324, 360,   /*2ss mcs 0~9*/
	40,	81,	121, 162, 243, 324, 364, 405, 486, 540,  /*3ss mcs 0~9*/
	54,	108, 162, 216, 324, 432, 486, 540, 648, 720, /*4ss mcs 0~9*/

	/* 11ac 80 Mhz 800ns GI */
	29,	58,	87,	117, 175, 234, 263, 292, 351, 390,   /*1ss mcs 0~9*/
	58,	117, 175, 243, 351, 468, 526, 585, 702, 780, /*2ss mcs 0~9*/
	87,	175, 263, 351, 526, 702, 789,	877, 1053, 1170, /*3ss mcs 0~9*/
	117, 234, 351, 468, 702, 936, 1053, 1170, 1404, 1560, /*4ss mcs 0~9*/

	/* 11ac 160 Mhz 800ns GI */
	58,	117, 175, 234, 351, 468, 526, 585, 702, 780, /*1ss mcs 0~9*/
	117, 234, 351, 468, 702, 936, 1053, 1170, 1404, 1560, /*2ss mcs 0~9*/
	175, 351, 526, 702, 1053, 1404, 1579, 1755, 2160, 2340, /*3ss mcs 0~8*/
	234, 468, 702, 936, 1404, 1872, 2106, 2340, 2808, 3120, /*4ss mcs 0~9*/

	/* 11ac 20 Mhz 400ns GI */
	7,	14,	21,	28,  43,  57,   65,	 72,  86,  96,    /*1ss mcs 0~8*/
	14,	28,	43,	57,	 86,  115,  130, 144, 173, 192,    /*2ss mcs 0~8*/
	21,	43,	65,	86,	 130, 173,  195, 216, 260, 288,  /*3ss mcs 0~9*/
	28,	57,	86,	115, 173, 231,  260, 288, 346, 390,    /*4ss mcs 0~8*/

	/* 11ac 40 Mhz 400ns GI */
	15,	30,	45,	60,	 90,  120,  135, 150, 180, 200,  /*1ss mcs 0~9*/
	30,	60,	90,	120, 180, 240,  270, 300, 360, 400,  /*2ss mcs 0~9*/
	45,	90,	135, 180, 270, 360,  405, 450, 540, 600, /*3ss mcs 0~9*/
	60,	120, 180, 240, 360, 480,  540, 600, 720, 800, /*4ss mcs 0~9*/

	/* 11ac 80 Mhz 400ns GI */
	32,	65,	97,	130, 195, 260,  292, 325, 390, 433,  /*1ss mcs 0~9*/
	65,	130, 195, 260, 390, 520,  585, 650, 780, 866, /*2ss mcs 0~9*/
	97,	195, 292, 390, 585, 780,  877, 975, 1170, 1300, /*3ss mcs 0~9*/
	130, 260, 390, 520, 780, 1040,	1170, 1300, 1560, 1733, /*4ss mcs 0~9*/

	/* 11ac 160 Mhz 400ns GI */
	65,	130, 195, 260, 390, 520,  585, 650, 780, 866, /*1ss mcs 0~9*/
	130, 260, 390, 520, 780, 1040,	1170, 1300, 1560, 1733, /*2ss mcs 0~9*/
	195, 390, 585, 780, 1170, 1560, 1755, 1950, 2340, 2600, /*3ss mcs 0~8*/
	260, 520, 780, 1040, 1560, 2080, 2340, 2600, 3120, 3466, /*4ss mcs 0~9*/
};

#define MAX_NUM_HE_BANDWIDTHS 4
#define MAX_NUM_HE_SPATIAL_STREAMS 4
#define MAX_NUM_HE_MCS_ENTRIES 12
static const int he_mcs_phyrate_mapping_table[MAX_NUM_HE_BANDWIDTHS][MAX_NUM_HE_SPATIAL_STREAMS][MAX_NUM_HE_MCS_ENTRIES] = 
{
	{ /* 20 Mhz*/
		{  8, 17,  25,  34,  51,  68,  77,  86, 103, 114, 129, 143 },		/* 1 SS */
		{ 17, 34,  51,  68, 103, 137, 154, 172, 206, 229, 258, 286 },		/* 2 SS */
		{ 25, 51,  77, 103, 154, 206, 232, 258, 309, 344, 387, 430 },		/* 3 SS */
		{ 34, 68, 103, 137, 206, 275, 309, 344, 412, 458, 516, 573 }		/* 4 SS */
	},
	{ /* 40 Mhz*/
		{ 17,  34,  51,  68, 103, 137, 154, 172, 206, 229,  258, 286 },
		{ 34,  68, 103, 137, 206, 275, 309, 344, 412, 458,  516, 573 },
		{ 51, 103, 154, 206, 309, 412, 464, 516, 619, 688,  774, 860 },
		{ 68, 137, 206, 275, 412, 550, 619, 688, 825, 917, 1032, 1147 }
	},
	{ /* 80 Mhz*/
		{  36,  72, 108, 144, 216,  288,  324,  360,  432,  480,  540, 600 },
		{  72, 144, 216, 288, 432,  576,  648,  720,  864,  960, 1080, 1201 },
		{ 108, 216, 324, 432, 648,  864,  972, 1080, 1297, 1441, 1621, 1801 },
		{ 144, 288, 432, 576, 864, 1152, 1297, 1441, 1729, 1921, 2161, 2401 }
	},
	{ /* 160 Mhz*/
		{ 72,  144, 216,  288,  432,  576,  648,  720,  864,  960, 1080, 1201 },
		{ 144, 288, 432,  576,  864, 1152, 1297, 1441, 1729, 1921, 2161, 2401 },
		{ 216, 432, 648,  864, 1297, 1729, 1945, 2161, 2594, 2882, 3242, 3602 },
		{ 288, 576, 864, 1152, 1729, 2305, 2594, 2882, 3458, 3843, 4323, 4803 },
	}
};

static int getLegacyOFDMMCSIndex(unsigned char MCS)
{
	int mcs_index = MCS;
	if (MCS == 0xb)
		mcs_index = 0;
	else if (MCS == 0xf)
		mcs_index = 1;
	else if (MCS == 0xa)
		mcs_index = 2;
	else if (MCS == 0xe)
		mcs_index = 3;
	else if (MCS == 0x9)
		mcs_index = 4;
	else if (MCS == 0xd)
		mcs_index = 5;
	else if (MCS == 0x8)
		mcs_index = 6;
	else if (MCS == 0xc)
		mcs_index = 7;

	return mcs_index;
}

static int
getRate(MACHTTRANSMIT_SETTING HTSetting)
{
	int rate_count = sizeof(MCSMappingRateTable)/sizeof(int);
	int rate_index = 0;
	int mcs_1ss = 0;
	int num_ss_vht = 0;
	int bw = 0;

	if (HTSetting.field.MODE >= MODE_HE) {
		mcs_1ss = (unsigned char)HTSetting.field.MCS & 0xf;
		num_ss_vht = ((unsigned char)HTSetting.field.MCS >> 4) + 1;
		bw = (unsigned char)HTSetting.field.BW;

		if (bw > MAX_NUM_HE_BANDWIDTHS)
			bw = MAX_NUM_HE_BANDWIDTHS - 1;

		if (mcs_1ss > MAX_NUM_HE_MCS_ENTRIES)
			mcs_1ss = MAX_NUM_HE_MCS_ENTRIES - 1;
		
		if (num_ss_vht > MAX_NUM_HE_SPATIAL_STREAMS)
			num_ss_vht = MAX_NUM_HE_SPATIAL_STREAMS;

		return he_mcs_phyrate_mapping_table[bw][num_ss_vht-1][mcs_1ss];
	}
	
	if (HTSetting.field.MODE >= MODE_VHT) {
		mcs_1ss = (unsigned char)HTSetting.field.MCS & 0xf;
		num_ss_vht = ((unsigned char)HTSetting.field.MCS >> 4) + 1;

		if (HTSetting.field.BW == BW_20)
			rate_index = 140 + ((unsigned char)HTSetting.field.ShortGI * 160) + ((num_ss_vht - 1) * 10) + mcs_1ss;
		else if (HTSetting.field.BW == BW_40)
			rate_index = 180 + ((unsigned char)HTSetting.field.ShortGI * 160) + ((num_ss_vht - 1) * 10) + mcs_1ss;
		else if (HTSetting.field.BW == BW_80)
			rate_index = 220 + ((unsigned char)HTSetting.field.ShortGI * 160) + ((num_ss_vht - 1) * 10) + mcs_1ss;
		else if (HTSetting.field.BW == BW_160)
			rate_index = 260 + ((unsigned char)HTSetting.field.ShortGI * 160) + ((num_ss_vht - 1) * 10) + mcs_1ss;
	}
	else if (HTSetting.field.MODE >= MODE_HTMIX)
		rate_index = 12 + ((unsigned char)HTSetting.field.BW * 32) + ((unsigned char)HTSetting.field.ShortGI * 64) + ((unsigned char)HTSetting.field.MCS);
	else if (HTSetting.field.MODE == MODE_OFDM)
		rate_index = getLegacyOFDMMCSIndex((unsigned char)(HTSetting.field.MCS)) + 4;
	else if (HTSetting.field.MODE == MODE_CCK)
		rate_index = (unsigned char)(HTSetting.field.MCS);

	if (rate_index < 0)
		rate_index = 0;

	if (rate_index >= rate_count)
		rate_index = rate_count-1;

	return (MCSMappingRateTable[rate_index]);
}

int
get_apcli_peer_connected(const char *ifname, struct iwreq *p_wrq)
{
	if (wl_ioctl(ifname, SIOCGIWAP, p_wrq) >= 0) {
		p_wrq->u.ap_addr.sa_family = ARPHRD_ETHER;
		if (p_wrq->u.ap_addr.sa_data[0] ||
		    p_wrq->u.ap_addr.sa_data[1] ||
		    p_wrq->u.ap_addr.sa_data[2] ||
		    p_wrq->u.ap_addr.sa_data[3] ||
		    p_wrq->u.ap_addr.sa_data[4] ||
		    p_wrq->u.ap_addr.sa_data[5] ) {
			return 1;
		}
	}

	return 0;
}

int
get_apcli_wds_entry(const char *ifname, RT_802_11_MAC_ENTRY *pme)
{
	struct iwreq wrq;

	bzero(pme, sizeof(RT_802_11_MAC_ENTRY));
	wrq.u.data.pointer = pme;
	wrq.u.data.length = sizeof(RT_802_11_MAC_ENTRY);
	wrq.u.data.flags = 0;

	if (wl_ioctl(ifname, RTPRIV_IOCTL_GET_MAC_TABLE_STRUCT, &wrq) >= 0 &&
	    wrq.u.data.length == sizeof(RT_802_11_MAC_ENTRY)) {
		return 1;
	}

	return 0;
}

int
is_mac_in_sta_list(const unsigned char* p_mac)
{
	/* stage2c: replaced RTPRIV_IOCTL_GET_MAC_TABLE_STRUCT on ra0/rax0 with
	 * `iw dev <hostapd-instance> station dump` per band/main/guest.
	 *
	 * Return-value contract preserved (device-map / ACL pages depend on it):
	 *   1 = 2.4G main, 2 = 2.4G guest, 3 = 5G main, 4 = 5G guest, 0 = none.
	 * Band selection now comes from the frozen wifi_*_ifname(aband) helpers
	 * (mt76 phyX-apY naming) instead of the ra0/rax0 ApIdx table.
	 */
	const char *if_main, *if_guest;

#if BOARD_HAS_5G_RADIO
	if_main = wifi_main_ifname(1);
	if (if_main && *if_main && iw_sta_has_mac(if_main, p_mac, NULL))
		return 3;
	if_guest = wifi_guest_ifname(1);
	if (if_guest && *if_guest && iw_sta_has_mac(if_guest, p_mac, NULL))
		return 4;
#endif

	if_main = wifi_main_ifname(0);
	if (if_main && *if_main && iw_sta_has_mac(if_main, p_mac, NULL))
		return 1;
	if_guest = wifi_guest_ifname(0);
	if (if_guest && *if_guest && iw_sta_has_mac(if_guest, p_mac, NULL))
		return 2;

	return 0;
}

static int
print_apcli_wds_header(webs_t wp, const char *caption)
{
	int ret = 0;

	ret += websWrite(wp, caption);
	ret += websWrite(wp, "----------------------------------------\n");
	ret += websWrite(wp, "%-19s%-8s%-4s%-4s%-4s%-5s%-5s%-6s%-5s\n",
				   "BSSID", "PhyMode", "BW", "MCS", "SGI", "LDPC", "STBC", "TRate", "RSSI");

	return ret;
}

static int
get_rssi_from_me(RT_802_11_MAC_ENTRY *me, int num_ss_rx)
{
	int rssi;

	rssi = -127;
	if ((int)me->AvgRssi0 > rssi && me->AvgRssi0 != 0)
		rssi = (int)me->AvgRssi0;
	if (num_ss_rx > 1) {
		if ((int)me->AvgRssi1 > rssi && me->AvgRssi1 != 0)
			rssi = (int)me->AvgRssi1;
	}
	if (num_ss_rx > 2) {
		if ((int)me->AvgRssi2 > rssi && me->AvgRssi2 != 0)
			rssi = (int)me->AvgRssi2;
	}
	return rssi;
}

static int
print_apcli_wds_entry(webs_t wp, RT_802_11_MAC_ENTRY *me, int num_ss_rx)
{
	int ret, rssi;

	ret = 0;

	rssi = get_rssi_from_me(me, num_ss_rx);

	ret += websWrite(wp, "%02X:%02X:%02X:%02X:%02X:%02X  %-7s %3s %3d %3s %4s %4s %4dM %4d\n",
			me->Addr[0], me->Addr[1], me->Addr[2],
			me->Addr[3], me->Addr[4], me->Addr[5],
			GetPhyMode(me->TxRate.field.MODE),
			GetBW(me->TxRate.field.BW),
			getMCS(me->TxRate),
			me->TxRate.field.ShortGI ? "YES" : "NO",
			me->TxRate.field.ldpc ? "YES" : "NO",
			me->TxRate.field.STBC ? "YES" : "NO",
			getRate(me->TxRate),
			rssi
		);

	return ret;
}

static int
print_sta_list(webs_t wp, RT_802_11_MAC_TABLE *mp, int num_ss_rx, int ap_idx)
{
	int ret, i, hr, min, sec, rssi;

	ret = 0;

#if defined (BOARD_MT7615_DBDC) || defined (BOARD_MT7915_DBDC)
	ret += websWrite(wp, "\nAP %s Stations List\n", (ap_idx == 0 || ap_idx == 2) ? "Main" : "Guest");
#else
	ret += websWrite(wp, "\nAP %s Stations List\n", (ap_idx == 0) ? "Main" : "Guest");
#endif
	ret += websWrite(wp, "----------------------------------------\n");
	ret += websWrite(wp, "%-19s%-8s%-4s%-4s%-4s%-5s%-5s%-7s%-7s%-5s%-4s%-12s\n",
			   "MAC", "PhyMode", "BW", "MCS", "SGI", "LDPC", "STBC", "TxRate", "RxRate", "RSSI", "PSM", "ConnectTime");

	for (i = 0; i < mp->Num; i++) {
		if ((int)mp->Entry[i].ApIdx != ap_idx)
			continue;

		hr = mp->Entry[i].ConnectedTime / 3600;
		min = (mp->Entry[i].ConnectedTime % 3600) / 60;
		sec = mp->Entry[i].ConnectedTime - hr * 3600 - min * 60;
		rssi = get_rssi_from_me(&mp->Entry[i], num_ss_rx);

		MACHTTRANSMIT_SETTING RxRate;
		bzero(&RxRate, sizeof(RxRate));
		RxRate.word = mp->Entry[i].LastRxRate;
		/* Fallback: if LastRxRate is invalid (zero), use TxRate */
		if (RxRate.word == 0)
			RxRate = mp->Entry[i].TxRate;

		ret += websWrite(wp, "%02X:%02X:%02X:%02X:%02X:%02X  %-7s %3s %3d %3s %4s %4s %5dM %5dM %4d %3s %02d:%02d:%02d\n",
				mp->Entry[i].Addr[0], mp->Entry[i].Addr[1], mp->Entry[i].Addr[2],
				mp->Entry[i].Addr[3], mp->Entry[i].Addr[4], mp->Entry[i].Addr[5],
				GetPhyMode(mp->Entry[i].TxRate.field.MODE),
				GetBW(mp->Entry[i].TxRate.field.BW),
				getMCS(mp->Entry[i].TxRate),
				mp->Entry[i].TxRate.field.ShortGI ? "YES" : "NO",
				mp->Entry[i].TxRate.field.ldpc ? "YES" : "NO",
				mp->Entry[i].TxRate.field.STBC ? "YES" : "NO",
				getRate(mp->Entry[i].TxRate), 
				getRate(RxRate),
				rssi,
				mp->Entry[i].Psm ? "YES" : "NO",
				hr, min, sec
			);
	}

	return ret;
}

#if defined(USE_RT3352_MII)
static int
getRate_inic(MACHTTRANSMIT_SETTING_INIC HTSetting)
{
	int rate_count = sizeof(MCSMappingRateTable)/sizeof(int);
	int rate_index = 0;

	if (HTSetting.field.MODE >= MODE_HTMIX)
		rate_index = 12 + ((unsigned char)HTSetting.field.BW * 24) + ((unsigned char)HTSetting.field.ShortGI * 48) + ((unsigned char)HTSetting.field.MCS);
	else if (HTSetting.field.MODE == MODE_OFDM)
		rate_index = (unsigned char)(HTSetting.field.MCS) + 4;
	else if (HTSetting.field.MODE == MODE_CCK)
		rate_index = (unsigned char)(HTSetting.field.MCS);

	if (rate_index < 0)
		rate_index = 0;

	if (rate_index >= rate_count)
		rate_index = rate_count-1;

	return (MCSMappingRateTable[rate_index] * 5)/10;
}

static int
print_sta_list_inic(webs_t wp, RT_802_11_MAC_TABLE_INIC* mp, int num_ss_rx, int ap_idx)
{
	int ret, i, hr, min, sec, rssi;

	ret = 0;

	ret += websWrite(wp, "\nAP %s Stations List\n", (ap_idx == 0) ? "Main" : "Guest");
	ret += websWrite(wp, "----------------------------------------\n");
	ret += websWrite(wp, "%-19s%-8s%-4s%-4s%-4s%-5s%-5s%-6s%-5s%-4s%-12s\n",
			   "MAC", "PhyMode", "BW", "MCS", "SGI", "LDPC", "STBC", "TRate", "RSSI", "PSM", "ConnectTime");

	for (i = 0; i < mp->Num; i++) {
		if ((int)mp->Entry[i].ApIdx != ap_idx)
			continue;

		hr = mp->Entry[i].ConnectedTime / 3600;
		min = (mp->Entry[i].ConnectedTime % 3600) / 60;
		sec = mp->Entry[i].ConnectedTime - hr * 3600 - min * 60;
		rssi = get_rssi_from_me(&mp->Entry[i], num_ss_rx);

		ret += websWrite(wp, "%02X:%02X:%02X:%02X:%02X:%02X  %-7s %3s %3d %3s %4s %4s %4dM %4d %3s %02d:%02d:%02d\n",
				mp->Entry[i].Addr[0], mp->Entry[i].Addr[1], mp->Entry[i].Addr[2],
				mp->Entry[i].Addr[3], mp->Entry[i].Addr[4], mp->Entry[i].Addr[5],
				GetPhyMode(mp->Entry[i].TxRate.field.MODE),
				GetBW(mp->Entry[i].TxRate.field.BW),
				mp->Entry[i].TxRate.field.MCS,
				mp->Entry[i].TxRate.field.ShortGI ? "YES" : "NO",
				mp->Entry[i].TxRate.field.STBC ? "YES" : "NO",
				getRate_inic(mp->Entry[i].TxRate),
				rssi,
				mp->Entry[i].Psm ? "YES" : "NO",
				hr, min, sec
			);
	}

	return ret;
}

static int
print_mac_table_inic(webs_t wp, const char *wif_name, int num_ss_rx, int is_guest_on)
{
	char mac_table_data[4096];
	struct iwreq wrq;
	RT_802_11_MAC_TABLE_INIC *mp;
	int ret = 0;

	bzero(mac_table_data, sizeof(mac_table_data));
	wrq.u.data.pointer = mac_table_data;
	wrq.u.data.length = sizeof(mac_table_data);
	wrq.u.data.flags = 0;

	if (wl_ioctl(wif_name, RTPRIV_IOCTL_GET_MAC_TABLE, &wrq) >= 0) {
		mp = (RT_802_11_MAC_TABLE_INIC*)wrq.u.data.pointer;

		ret += print_sta_list_inic(wp, mp, num_ss_rx, 0);
		if (is_guest_on)
			ret += print_sta_list_inic(wp, mp, num_ss_rx, 1);
	}

	return ret;
}
#endif

static int
print_wmode(webs_t wp, unsigned int wmode, unsigned int phy_mode)
{
	char buf[32] = {0};
	int ret = 0;

	if (wmode) {
		char *p = buf;
		if (wmode & WMODE_A)
			p += sprintf(p, "/a");
		if (wmode & WMODE_B)
			p += sprintf(p, "/b");
		if (wmode & WMODE_G)
			p += sprintf(p, "/g");
		if (wmode & WMODE_GN)
			p += sprintf(p, "/n");
		if (wmode & WMODE_AN)
			p += sprintf(p, "/n");
		if (wmode & WMODE_AC)
			p += sprintf(p, "/ac");
		if ((wmode & WMODE_AX_24G) || (wmode & WMODE_AX_5G) || (wmode & WMODE_AX_6G))
			p += sprintf(p, "/ax");
		if (p != buf)
			ret += websWrite(wp, "WPHY Mode\t: 11%s\n", buf+1);
	} else {
		switch (phy_mode)
		{
		case PHY_11BG_MIXED:
			strcpy(buf, "b/g");
			break;
		case PHY_11B:
			strcpy(buf, "b");
			break;
		case PHY_11A:
			strcpy(buf, "a");
			break;
		case PHY_11ABG_MIXED:
			strcpy(buf, "a/b/g");
			break;
		case PHY_11G:
			strcpy(buf, "g");
			break;
		case PHY_11ABGN_MIXED:
			strcpy(buf, "a/b/g/n");
			break;
		case PHY_11N:
		case PHY_11N_5G:
			strcpy(buf, "n");
			break;
		case PHY_11GN_MIXED:
			strcpy(buf, "g/n");
			break;
		case PHY_11AN_MIXED:
			strcpy(buf, "a/n");
			break;
		case PHY_11BGN_MIXED:
			strcpy(buf, "b/g/n");
			break;
		case PHY_11AGN_MIXED:
			strcpy(buf, "a/g/n");
			break;
		case PHY_11AX_24G:
			strcpy(buf, "b/g/n/ax");
			break;
		case PHY_11AX_5G:
			strcpy(buf, "a/n/ac/ax");
			break;
		case PHY_11AX_6G:
			strcpy(buf, "ax");
			break;
		case PHY_11AX_24G_6G:
			strcpy(buf, "g/n/ax");
			break;
		case PHY_11AX_5G_6G:
			strcpy(buf, "a/n/ac/ax");
			break;
		case PHY_11AX_24G_5G_6G:
			strcpy(buf, "a/b/g/n/ac/ax");
			break;
		}
		if (buf[0])
			ret += websWrite(wp, "WPHY Mode\t: 11%s\n", buf);
	}

	return ret;
}

static int
print_mac_table(webs_t wp, const char *wif_name, int num_ss_rx, int is_guest_on)
{
	char mac_table_data[4096];
	struct iwreq wrq;
	RT_802_11_MAC_TABLE *mp;
	int ret = 0;

#if defined (BOARD_MT7615_DBDC)
/*
	5g main ra0: apidx=0
	5g guest ra1: apidx=1
	2.4g main rax0: apidx=2
	2.4g guest rax1: apidx=3
*/
	int apidx = 0; //default: main 5g, ra0, apidx=0
	int apidx_guest = 1;//default: guest 5g, ra1, apidx=1
	if (!strcmp(wif_name, IFNAME_2G_MAIN)) {
		apidx = 2;
		apidx_guest = 3;
	}
#elif defined (BOARD_MT7915_DBDC)
	int apidx = 2;
	int apidx_guest = 3;
	if (!strcmp(wif_name, IFNAME_2G_MAIN)) {
		apidx = 0;
		apidx_guest = 1;
	}
#endif
	bzero(mac_table_data, sizeof(mac_table_data));
	wrq.u.data.pointer = mac_table_data;
	wrq.u.data.length = sizeof(mac_table_data);
	wrq.u.data.flags = 0;

	if (wl_ioctl(wif_name, RTPRIV_IOCTL_GET_MAC_TABLE_STRUCT, &wrq) >= 0) {
		mp = (RT_802_11_MAC_TABLE*)wrq.u.data.pointer;
#if defined (BOARD_MT7615_DBDC) || defined (BOARD_MT7915_DBDC)
		ret += print_sta_list(wp, mp, num_ss_rx, apidx); 
#else
		ret += print_sta_list(wp, mp, num_ss_rx, 0);
#endif
		if (is_guest_on)
#if defined (BOARD_MT7615_DBDC) || defined (BOARD_MT7915_DBDC)
			ret += print_sta_list(wp, mp, num_ss_rx, apidx_guest);
#else
			ret += print_sta_list(wp, mp, num_ss_rx, 1);
#endif
	}

	return ret;
}

static int
print_radio_status(webs_t wp, int is_aband)
{
	int ret, i, channel, op_mode, ht_mode, is_guest_on, num_ss_rx;
	unsigned int wmode, phy_mode;
	const char *caption, *wif_ap[2], *wif_wds[4], *wif_apcli;
	struct iw_range range;
	double freq;
	char buffer[sizeof(iwrange) * 2];
	unsigned char mac[8];
	struct iwreq wrq0;
	struct iwreq wrq1;
	struct iwreq wrq2;

	ret = 0;

#if BOARD_HAS_5G_RADIO
	if (is_aband) {
		if (nvram_match("wl_radio_x", "0")
#if defined(USE_IWPRIV_RADIO_5G)
		 || nvram_match("mlme_radio_wl", "0")
#endif
		   ) {
			ret += websWrite(wp, "Radio %s is disabled\n", "5GHz");
			return ret;
		}
		
		wif_ap[0]  = wifi_main_ifname(1);
		wif_ap[1]  = wifi_guest_ifname(1);
		wif_wds[0] = NULL;
		wif_wds[1] = NULL;
		wif_wds[2] = NULL;
		wif_wds[3] = NULL;
		wif_apcli  = wifi_apcli_ifname(1);
	} else
#endif
	{
		if (nvram_match("rt_radio_x", "0")
#if defined(USE_IWPRIV_RADIO_2G) || defined(USE_RT3352_MII)
		 || nvram_match("mlme_radio_rt", "0")
#endif
		   ) {
			ret += websWrite(wp, "Radio %s is disabled\n", "2.4GHz");
			return ret;
		}

		wif_ap[0]  = wifi_main_ifname(0);
		wif_ap[1]  = wifi_guest_ifname(0);
		wif_wds[0] = NULL;
		wif_wds[1] = NULL;
		wif_wds[2] = NULL;
		wif_wds[3] = NULL;
		wif_apcli  = wifi_apcli_ifname(0);
	}

	op_mode = nvram_wlan_get_int(is_aband, "mode_x");
	ht_mode = nvram_wlan_get_int(is_aband, "gmode");
	num_ss_rx = nvram_wlan_get_int(is_aband, "stream_rx");
	is_guest_on = (nvram_wlan_get_int(is_aband, "guest_enable") == 1);

	caption = (op_mode == 1) ? "WDS" : "AP Main";

	if (op_mode != 3) {
		if (!wif_ap[0] || !*wif_ap[0] || get_interface_hwaddr(wif_ap[0], mac) < 0) {
			ret += websWrite(wp, "Radio is disabled\n");
			return ret;
		}
		ret += websWrite(wp, "MAC (%s)\t: %02X:%02X:%02X:%02X:%02X:%02X\n", caption,
			mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	}

	if (op_mode != 1 && op_mode != 3 && is_guest_on) {
		if (wif_ap[1] && *wif_ap[1] && get_interface_hwaddr(wif_ap[1], mac) == 0) {
			ret += websWrite(wp, "MAC (%s)\t: %02X:%02X:%02X:%02X:%02X:%02X\n", "AP Guest",
				mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
		}
	}

	if (op_mode == 3 || op_mode == 4) {
		if (get_interface_hwaddr(wif_apcli, mac) == 0) {
			ret += websWrite(wp, "MAC (%s)\t: %02X:%02X:%02X:%02X:%02X:%02X\n", "AP-Client",
				mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
		}
	}

	/* stage2c: channel from `iw dev <if> info` (nl80211). The old
	 * SIOCGIWFREQ/SIOCGIWRANGE and RT_PRIV_IOCTL PHY_MODE are closed-SDK
	 * private calls with no mt76/mac80211 equivalent. PhyMode is rendered
	 * from nvram gmode via calc_phy_mode() (driver no longer reports it). */
	channel = iw_current_channel(wif_ap[0]);

	wmode = 0;
	phy_mode = calc_phy_mode(ht_mode, is_aband);

	caption = "Operation Mode";

	if (op_mode == 1)
		ret += websWrite(wp, "%s\t: WDS bridge\n", caption);
	else if (op_mode == 2)
		ret += websWrite(wp, "%s\t: WDS repeater (bridge + AP)\n", caption);
	else if (op_mode == 3)
		ret += websWrite(wp, "%s\t: AP-Client\n", caption);
	else if (op_mode == 4)
		ret += websWrite(wp, "%s\t: AP-Client + AP\n", caption);
	else
		ret += websWrite(wp, "%s\t: AP\n", caption);

	ret += print_wmode(wp, wmode, phy_mode);

	ret += websWrite(wp, "Channel Main\t: %d\n", channel);

	if (op_mode == 3 || op_mode == 4) {
		struct iwreq wrq;
		
		if (get_apcli_peer_connected(wif_apcli, &wrq)) {
#if defined(USE_RT3352_MII)
			if (!is_aband) {
				ret += websWrite(wp, "STA Connected\t: YES -> [%02X:%02X:%02X:%02X:%02X:%02X]\n",
					(unsigned char)wrq.u.ap_addr.sa_data[0],
					(unsigned char)wrq.u.ap_addr.sa_data[1],
					(unsigned char)wrq.u.ap_addr.sa_data[2],
					(unsigned char)wrq.u.ap_addr.sa_data[3],
					(unsigned char)wrq.u.ap_addr.sa_data[4],
					(unsigned char)wrq.u.ap_addr.sa_data[5]);
			} else
#endif
			{
				RT_802_11_MAC_ENTRY me;
				
				if (get_apcli_wds_entry(wif_apcli, &me)) {
					ret += print_apcli_wds_header(wp, "\nAP-Client Connection\n");
					ret += print_apcli_wds_entry(wp, &me, num_ss_rx);
				}
			}
		} else {
			ret += websWrite(wp, "STA Connected\t: %s\n", "NO");
		}
	}

	if ((op_mode == 1 || op_mode == 2)
#if defined(USE_RT3352_MII)
	    && (is_aband)
#endif
	    ) {
		RT_802_11_MAC_ENTRY me;
		
		ret += print_apcli_wds_header(wp, "\nWDS Peers\n");
		
		for (i = 0; i < 4; i++) {
			if (get_apcli_wds_entry(wif_wds[i], &me))
				ret += print_apcli_wds_entry(wp, &me, num_ss_rx);
		}
	}

	if (op_mode != 1 && op_mode != 3) {
		/* stage2c: associated-STA list from `iw dev <if> station dump`,
		 * one table per hostapd instance (main + guest). */
		iw_print_sta_list(wp, wif_ap[0], "Main");
		if (is_guest_on && wif_ap[1] && *wif_ap[1])
			iw_print_sta_list(wp, wif_ap[1], "Guest");
	}

	return ret;
}

#if BOARD_HAS_5G_RADIO
int
ej_wl_status_5g(int eid, webs_t wp, int argc, char **argv)
{
	return print_radio_status(wp, 1);
}
#endif

int
ej_wl_status_2g(int eid, webs_t wp, int argc, char **argv)
{
	return print_radio_status(wp, 0);
}

/* stage2c: emit `"MAC":rssi` pairs (comma-separated, JS object body) for the
 * associated STAs on <ifname>, parsed from `iw dev <if> station dump`.
 * Used by ej_wl_auth_list (ACL / device-map pages). */
static void
iw_emit_sta_json(webs_t wp, const char *ifname, int *firstRow, int *ret)
{
	char out[16384], *p;

	if (!ifname || !*ifname)
		return;
	if (run_iw_dev(ifname, "station dump", out, sizeof(out)) < 0)
		return;

	for (p = out; (p = strcasestr(p, "Station ")) != NULL; p += 8) {
		char mac[18] = {0};
		int sig = 0;

		if (sscanf(p, "Station %17s", mac) != 1)
			continue;
		{
			char *s = strstr(p, "signal:");
			if (s && (s - p) < 600)
				sscanf(s, "signal: %d", &sig);
		}
		if (*firstRow)
			*firstRow = 0;
		else
			*ret += websWrite(wp, ", ");
		/* keep MAC in upper-case to match the historical output */
		{
			char *q = mac;
			while (*q) { *q = toupper((unsigned char)*q); q++; }
		}
		*ret += websWrite(wp, "\"%s\":%d", mac, sig);
	}
}

int
ej_wl_auth_list(int eid, webs_t wp, int argc, char **argv)
{
	/* stage2c: replaced RTPRIV_IOCTL_GET_MAC_TABLE_STRUCT on ra0/rax0 with
	 * `iw dev <hostapd-instance> station dump`. Emits the same JS-object
	 * body "MAC":rssi, ... consumed by Advanced_ACL / device-map pages
	 * (var wireless = {<% wl_auth_list(); %>}). */
	int firstRow = 1, ret = 0;
	const char *if_main, *if_guest;

#if BOARD_HAS_5G_RADIO
	if_main = wifi_main_ifname(1);
	if_guest = wifi_guest_ifname(1);
	iw_emit_sta_json(wp, if_main, &firstRow, &ret);
	iw_emit_sta_json(wp, if_guest, &firstRow, &ret);
#endif

	if_main = wifi_main_ifname(0);
	if_guest = wifi_guest_ifname(0);
	iw_emit_sta_json(wp, if_main, &firstRow, &ret);
	iw_emit_sta_json(wp, if_guest, &firstRow, &ret);

	return ret;
}


#define SSURV_LINE_LEN		(4+33+20+23+9+12+7+3)		// Channel+SSID+Bssid+Security+Signal+WiressMode+ExtCh+NetworkType
#define SSURV_LINE_LEN_WPS	(4+33+20+23+9+7+7+3+4+5)	// Channel+SSID+Bssid+Security+Signal+WiressMode+ExtCh+NetworkType+WPS+PIN

/* stage2c: approximate channel number from center frequency (MHz).
 * Good enough for the WDS/scan-list display; DFS edge cases are approximate. */
static int
freq_mhz_to_channel(int freq)
{
	if (freq >= 2412 && freq <= 2472)
		return (freq - 2407) / 5;
	if (freq == 2484)
		return 14;
	if (freq >= 5000)
		return (freq - 5000) / 5;
	return 0;
}

/* stage2c: trigger a scan on the band's main hostapd interface and emit the
 * result as the JSON array [["ssid","bssid","channel","signal"], ...].
 * Replaces RTPRIV_IOCTL_SET(SiteSurvey=1) + RTPRIV_IOCTL_GSITESURVEY with
 * `iw dev <if> scan` (trigger) + `iw dev <if> scan dump` (results). */
static int
ej_wl_scan_band(webs_t wp, int aband)
{
	const char *ifname = wifi_main_ifname(aband);
	char out[32768], *p, *end;
	int retval = 0, apCount = 0;
	const char *empty = "[\"\", \"\", \"\", \"\"]";

	if (!ifname || !*ifname)
		return websWrite(wp, "[%s]", empty);

	/* trigger scan (async) then give the driver time to populate results */
	if (run_iw_dev(ifname, "scan", out, sizeof(out)) < 0) {
		dbg("trigger scan fails\n");
		return websWrite(wp, "[%s]", empty);
	}
	sleep(3);

	if (run_iw_dev(ifname, "scan dump", out, sizeof(out)) < 0) {
		dbg("read scan dump fails\n");
		return websWrite(wp, "[%s]", empty);
	}

	retval += websWrite(wp, "[");

	/* walk each "BSS <bssid>(on ...)" block */
	for (p = out; (p = strcasestr(p, "BSS ")) != NULL; ) {
		char bssid[24] = {0}, ssid[64] = {0};
		int freq = 0, signal = 0;
		char *nl;

		p += 4;
		if (sscanf(p, "%23[^(\n]", bssid) != 1)
			continue;

		/* block ends at the next "BSS " or EOF */
		end = strcasestr(p, "BSS ");
		nl = strchr(p, '\n');
		/* limit scan window to end of this BSS block (~800 bytes) */
		{
			char *w = p, *wlim = p + 1024;
			char *fq = strstr(w, "freq:");
			if (fq && fq < wlim) sscanf(fq, "freq: %d", &freq);
			{
				char *sg = strstr(w, "signal:");
				if (sg && sg < wlim) sscanf(sg, "signal: %d", &signal);
			}
			{
				char *ss = strstr(w, "SSID:");
				if (ss && ss < wlim) {
					ss += 5;
					while (*ss == ' ') ss++;
					{
						char *e = strchr(ss, '\n');
						size_t l = e ? (size_t)(e - ss) : strlen(ss);
						if (l >= sizeof(ssid)) l = sizeof(ssid) - 1;
						memcpy(ssid, ss, l);
						ssid[l] = '\0';
					}
				}
			}
		}

		if (!strlen(ssid))
			strcpy(ssid, "???");

		if (apCount)
			retval += websWrite(wp, ", ");
		retval += websWrite(wp, "[\"%s\", \"%s\", \"%d\", \"%d\"]",
			ssid, bssid, freq_mhz_to_channel(freq), signal);
		apCount++;

		if (!end)
			break;
		p = end;
	}

	if (apCount < 1)
		retval += websWrite(wp, empty);

	retval += websWrite(wp, "]");
	return retval;
}

#if BOARD_HAS_5G_RADIO
int
ej_wl_scan_5g(int eid, webs_t wp, int argc, char **argv)
{
	/* stage2c: ej endpoint name preserved (wds_aplist.asp contract);
	 * data source switched to nl80211 `iw scan` on the 5G main instance. */
	return ej_wl_scan_band(wp, 1);
}
#endif

int
ej_wl_scan_2g(int eid, webs_t wp, int argc, char **argv)
{
	/* stage2c: ej endpoint name preserved (wds_aplist_2g.asp contract);
	 * data source switched to nl80211 `iw scan` on the 2.4G main instance. */
	return ej_wl_scan_band(wp, 0);
}

#if BOARD_HAS_5G_RADIO
int
ej_wl_bssid_5g(int eid, webs_t wp, int argc, char **argv)
{
	char bssid[32] = {0};
	unsigned char mac[8];

	snprintf(bssid, sizeof(bssid), "%s", nvram_safe_get("wl_macaddr"));
	if (get_interface_hwaddr(IFNAME_5G_MAIN, mac) == 0)
	{
		sprintf(bssid, "%02X:%02X:%02X:%02X:%02X:%02X",
			mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	}

	websWrite(wp, "function get_bssid_ra0() { return '%s';}\n", bssid);

	return 0;
}
#endif

int
ej_wl_bssid_2g(int eid, webs_t wp, int argc, char **argv)
{
	char bssid[32] = {0};
	unsigned char mac[8];

	snprintf(bssid, sizeof(bssid), "%s", nvram_safe_get("rt_macaddr"));

#if defined(USE_RT3352_MII)
	if (nvram_get_int("inic_disable") != 1)
	{
#endif
		if (get_interface_hwaddr(IFNAME_2G_MAIN, mac) == 0)
		{
			sprintf(bssid, "%02X:%02X:%02X:%02X:%02X:%02X",
				mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
		}
#if defined(USE_RT3352_MII)
	}
#endif

	websWrite(wp, "function get_bssid_rai0() { return '%s';}\n", bssid);

	return 0;
}

