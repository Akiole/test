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

#include <ralink_boards.h>
#include "nvram_linux.h"
#include "netutils.h"
#include "defaults.h"

#define STR1(x) #x
#define STR(x) STR1(x)

struct nvram_pair router_defaults[] = {
	/* Restore defaults */
	{ "restore_defaults", "0" },                   /* Set to 0 to not restore defaults on boot */
	{ "nvram_manual", "0" },                       /* Manual commit mode: 1: manual, 0: auto */

#if defined (USE_NAND_FLASH)
	{ "mtd_rwfs_mount", "0" },                     /* Allow mount MTD RWFS partition on boot */
#endif

	/* Miscellaneous parameters */
	{ "time_zone", DEF_TIMEZONE },
	{ "preferred_lang", "CN" },                    /* Preferred language */
	{ "log_float_ui", "1" },                       /* WebUI syslog float panel mode */
	{ "log_ipaddr", "" },                          /* syslog recipient IP */
	{ "log_port", "514" },                         /* syslog recipient Port */
	{ "log_level", "1" },                          /* Bitmask 0:off 1:denied 2:accepted */
	{ "console_loglevel", "7" },                   /* Kernel panics only */
	{ "stats_server", "" },                        /* URL for posting stats */

	/* Big switches */
	{ "fw_enable_x", "1" },                        /* Firewall master switch */

	/* LAN H/W parameters */
	{ "lan_hwaddr", "" },                          /* LAN interface MAC address */

	/* LAN TCP/IP parameters */
	{ "lan_proto_x", "1" },                        /* DHCP client [static|dhcp] in AP mode */
	{ "lan_dhcpd_x", "0" },                        /* DHCP server in AP mode */
	{ "lan_ipaddr", DEF_LAN_ADDR },                /* LAN IP address */
	{ "lan_netmask", DEF_LAN_MASK },               /* LAN netmask */
	{ "lan_gateway", DEF_LAN_ADDR },               /* LAN gateway */
	{ "lan_dns_x", "1" },                          /* LAN DNS [static|dhcp] */
	{ "lan_dns1", "" },                            /* LAN DNS1 */
	{ "lan_dns2", "" },                            /* LAN DNS2 */
	{ "lan_domain", "lan" },                       /* LAN domain name */
	{ "lan_stp", "1" },                            /* LAN spanning tree protocol */

	/* WAN H/W parameters */
	{ "wan_ifname", IFNAME_WAN },                  /* WAN interface name */
	{ "wan_hwaddr", "" },                          /* WAN interface MAC address */

	/* WAN TCP/IP parameters */
	{ "wan_proto", "dhcp" },                       /* [static|dhcp|pppoe|pptp|l2tp|disabled] */
	{ "wan_ipaddr", "0.0.0.0" },                   /* WAN IP address */
	{ "wan_netmask", "0.0.0.0" },                  /* WAN netmask */
	{ "wan_gateway", "0.0.0.0" },                  /* WAN gateway */
	{ "wan_dnsenable_x", "1" },                    /* Auto DNS */
	{ "wan_dns1_x", "" },                          /* Primary DNS */
	{ "wan_dns2_x", "" },                          /* Secondary DNS */
	{ "wan_dns3_x", "" },                          /* Tertiary DNS */
	{ "wan_hostname", "" },                        /* WAN hostname */
	{ "wan_vci", "" },                             /* WAN vendor class identifier (OPT-60) */
	{ "wan_ttl_fix", "0" },                        /* TTL fix */
	{ "wan_ttl_value", "0" },                      /* TTL value (0=unchanged) */
	{ "wan_hwaddr_x", "" },                        /* WAN MAC address (custom) */
	{ "wan_nat_x", "1" },                          /* NAT enable */
	{ "wan_mtu", "1500" },                         /* WAN MTU */
	{ "wan_auth_mode", "0" },                      /* Web auth mode */
	{ "wan_auth_user", "" },                       /* Web auth username */
	{ "wan_auth_pass", "" },                       /* Web auth password */
	{ "wan_auth_host", "10.0.0.1" },               /* Web auth server */
	{ "wan_route_x", "IP_Routed" },                /* WAN route mode */
	{ "wan_src_phy", "0" },                        /* WAN source port */
	{ "wan_stb_x", "0" },                          /* IPTV STB enable */
	{ "wan_stb_iso", "1" },                        /* IPTV isolation */
	{ "vlan_filter", "0" },                        /* VLAN filter */
	{ "vlan_vid_cpu", "" },                        /* CPU port VLAN ID */
	{ "vlan_pri_cpu", "0" },                       /* CPU port priority */
	{ "vlan_vid_iptv", "" },                       /* IPTV port VLAN ID */
	{ "vlan_pri_iptv", "0" },                      /* IPTV port priority */
	{ "vlan_vid_lan1", "" },                       /* LAN1 VLAN ID */
	{ "vlan_pri_lan1", "0" },                      /* LAN1 priority */
	{ "vlan_tag_lan1", "0" },                      /* LAN1 tag mode */
	{ "vlan_vid_lan2", "" },                       /* LAN2 VLAN ID */
	{ "vlan_pri_lan2", "0" },                      /* LAN2 priority */
	{ "vlan_tag_lan2", "0" },                      /* LAN2 tag mode */
	{ "vlan_vid_lan3", "" },                       /* LAN3 VLAN ID */
	{ "vlan_pri_lan3", "0" },                      /* LAN3 priority */
	{ "vlan_tag_lan3", "0" },                      /* LAN3 tag mode */
	{ "vlan_vid_lan4", "" },                       /* LAN4 VLAN ID */
	{ "vlan_pri_lan4", "0" },                      /* LAN4 priority */
	{ "vlan_tag_lan4", "0" },                      /* LAN4 tag mode */
	{ "x_DHCPClient", "1" },                       /* DHCP client */

	/* VLAN IPTV path */
	{ "viptv_mode", "0" },                         /* IPTV mode */
	{ "viptv_ipaddr", "0.0.0.0" },                 /* IPTV IP address */
	{ "viptv_netmask", "0.0.0.0" },                /* IPTV subnet mask */
	{ "viptv_gateway", "0.0.0.0" },                /* IPTV gateway */

	/* PPP VPN parameters */
	{ "wan_pppoe_mwanenable", "0" },               /* MWAN support */
	{ "wan_pppoe_sync", "1" },                     /* PPP sync support */
	{ "wan_pppoe_num", "1" },                      /* PPP username */
	{ "wan_pppoe_username", "" },                  /* PPP username */
	{ "wan_pppoe_passwd", "" },                    /* PPP password */
	{ "wan_pppoe_idletime", "0" },                 /* PPP idle time */
	{ "wan_pppoe_demand", "0" },                   /* Dial on demand */
	{ "wan_pppoe_txonly_x", "0" },                 /* PPPoE TX-only mode */
	{ "wan_pppoe_service", "" },                   /* PPPoE service name */
	{ "wan_pppoe_ac", "" },                        /* PPPoE access concentrator name */
	{ "wan_pppoe_man", "1" },                      /* PPPoE & MAN */
	{ "pppoemwan_staticnum_x", "0" },              /* Multi-dial static count */
	{ "pppoemwan_443", "0" },                      /* Port 443 multi-dial */
	{ "wan_pppoe_mtu", "1500" },                   /* PPPoE MTU (RFC 4638 max 1500, requires ISP support) */
	{ "wan_pppoe_mru", "1500" },                   /* PPPoE MRU (RFC 4638 max 1500, requires ISP support) */
	{ "wan_pptp_mtu", "1400" },                    /* Negotiate MTU to the smaller of this value or the peer MRU */
	{ "wan_pptp_mru", "1400" },                    /* Negotiate MRU to this value */
	{ "wan_l2tp_mtu", "1460" },                    /* Negotiate MTU to the smaller of this value or the peer MRU */
	{ "wan_l2tp_mru", "1460" },                    /* Negotiate MRU to this value */
#if defined (APP_RPL2TP)
	{ "wan_l2tpd", "0" },                          /* L2TP control daemon (xL2TPD/RP-L2TP) */
#endif
	{ "wan_ppp_peer", "" },                        /* VPN server address */
	{ "wan_ppp_auth", "0" },                       /* PPP authentication */
	{ "wan_ppp_mppe", "0" },                       /* MPPE encryption */
	{ "wan_ppp_lcp", "1" },                        /* Automatically send LCP requests */
	{ "wan_ppp_alcp", "0" },                       /* Adaptive LCP Echo */
	{ "wan_ppp_pppd", "" },                        /* Custom PPPD options */

	/* Exposed station */
	{ "dmz_ip", "" },                              /* DMZ host IP */

	/* Web server parameters */
	{ "http_username", SYS_USER_ROOT },            /* Username */
	{ "http_passwd", DEF_ROOT_PASSWORD },          /* Password */
	{ "http_access", "2" },                        /* HTTP access (0: ALL, 1: LAN only, 2: LAN + Wireless MainAP) */
	{ "http_proto", "0" },                         /* HTTP proto (0: HTTP, 1: HTTPS, 2: Both) */
	{ "http_lanport", "80" },                      /* HTTP LAN port to listen on */
	{ "https_lport", "443" },                      /* HTTPS LAN port to listen on */
	{ "https_clist", DEF_HTTPS_CIPH_LIST },        /* HTTPS SSL cipher list */
	{ "fw_dos_x", "0" },                           /* DoS Attacks Protection */
	{ "dr_enable_x", "1" },                        /* Use DHCP Routes */
	{ "mr_enable_x", "1" },                        /* Multicast Routing to LAN */
	{ "mr_qleave_x", "1" },                        /* Fast leave */

#if BOARD_HAS_5G_RADIO
	/* 5GHz Wireless parameters */
	{ "wl_country_code", DEF_WLAN_5G_CC },         /* Country Code (default obtained from driver) */
	{ "wl_ssid", DEF_WLAN_5G_SSID },               /* Service set ID (network name) */
#if defined(BOARD_HAS_5G_11AX) && BOARD_HAS_5G_11AX
	{ "wl_gmode", "5" },                           /* A/N/AC/AX Mixed */
#elif BOARD_HAS_5G_11AC
	{ "wl_gmode", "3" },                           /* N/AC Mixed */
#else
	{ "wl_gmode", "2" },                           /* A/N Mixed */
#endif
	{ "wl_mcs_mode", "0" },                        /* MCS mode */
	{ "wl_channel", "0" },                         /* Channel number */
	{ "wl_bcn", "100" },                           /* Beacon interval */
	{ "wl_dtim", "1" },                            /* DTIM period */
	{ "wl_rts", "2347" },                          /* RTS threshold */
	{ "wl_frag", "2346" },                         /* Fragmentation threshold */
	{ "wl_ap_isolate", "0" },                      /* AP isolate mode */
	{ "wl_closed", "0" },                          /* Closed (hidden) network */
	{ "wl_macmode", "disabled" },                  /* "allow" only, "deny" only, or "disabled"(allow all) */
	{ "wl_maclist", "" },                          /* xx:xx:xx:xx:xx:xx ... */
	{ "wl_wme", "1" },                             /* WME mode (off|on) */
	{ "wl_wme_no_ack", "off" },                    /* WME No-Acknowledgment mode */
	{ "wl_auth_mode", "psk" },                     /* Network authentication mode: WPAx Personal */
	{ "wl_key", "1" },                             /* Current WEP key */
	{ "wl_key1", "" },                             /* 5/13 char ASCII or 10/26 char hex */
	{ "wl_key2", "" },                             /* 5/13 char ASCII or 10/26 char hex */
	{ "wl_key3", "" },                             /* 5/13 char ASCII or 10/26 char hex */
	{ "wl_key4", "" },                             /* 5/13 char ASCII or 10/26 char hex */
	{ "wl_key_type", "0" } ,                       /* WEP key format (HEX/ASCII) */
	{ "wl_mrate", "2" },                           /* Mcast Rate */
	{ "wl_crypto", "aes" },                        /* WPA data encryption */
	{ "wl_wpa_psk", DEF_WLAN_5G_PSK },             /* WPA pre-shared key */
	{ "wl_wpa_gtk_rekey", "3600" },                /* GTK rotation interval */
	{ "wl_radius_ipaddr", ""},                     /* RADIUS server IP address */
	{ "wl_radius_port", "1812" },                  /* RADIUS server UDP port */
	{ "wl_radius_key", "" },                       /* RADIUS shared secret */
	{ "wl_radio_x", "1" },                         /* Enable (1) or disable (0) radio */
	{ "wl_IgmpSnEnable", "1" },                    /* IGMP snooping */
	{ "wl_TxPower", "100" },                       /* TX power (%) */
	{ "wl_TxBurst", "1" },                         /* TX burst */
	{ "wl_PktAggregate", "1" },                    /* Packet aggregation */
	{ "wl_APSDCapable", "0" },                     /* APSD */
	{ "wl_HT_OpMode", "1" },                       /* HT op mode */
	{ "wl_pmf", "1" },                             /* PMF (1=optional, required for WPA3) */
	{ "wl_sta_pmf", "0" },                         /* Station PMF */
#if BOARD_HAS_5G_11AC
	{ "wl_HT_BW", "3" },                           /* HT BW (0=20MHz,1=20/40MHz,2=20/40/80MHz,3=20/40/80/160MHz) */
#else
	{ "wl_HT_BW", "1" },                           /* HT BW (0=20MHz,1=20/40MHz) */
#endif
	{ "wl_WPS", "0" },                             /* WPS */
	{ "wl_txbf", "1" },                            /* Beamforming */
	{ "wl_ssid2",  DEF_WLAN_5G_SSID },
	{ "wl_mode_x", "0" },                          /* 5GHz Wireless Bridge Mode */
	{ "wl_wdsapply_x", "0" },                      /* WDS apply */
	{ "wl_wdsnum_x", "0" },                        /* WDS count */
	{ "wl_wep_x", "0" },                           /* WEP */
	{ "wl_phrase_x", "" },                         /* WEP passphrase */
	{ "wl_radio_date_x", "1111111" },              /* Radio schedule days */
	{ "wl_radio_time_x", "00002359" },             /* Radio schedule time 1 */
	{ "wl_radio_time2_x", "00002359" },            /* Radio schedule time 2 */
	{ "wl_macnum_x", "0" },                        /* MAC filter count */
	{ "wl_wdslist_x", "" },                        /* WDS list */
	{ "wl_maclist_x", "" },                        /* MAC filter list */
	{ "wl_macdesc_x", "" },                        /* MAC description list */
	{ "wl_wpa_mode", "6" },                        /* WPA mode (6=WPA2/WPA3-Mixed Personal) */
	{ "wl_stream_tx", STR(BOARD_NUM_ANT_5G_TX) },
	{ "wl_stream_rx", STR(BOARD_NUM_ANT_5G_RX) },
	{ "wl_preamble", "1" },                        /* Preamble type */
	{ "wl_greenap", "0" },                         /* 5GHz GreenAP */
	{ "wl_ldpc", "3" },                            /* LDPC */
#if defined (USE_WID_5G) && (USE_WID_5G==7615 || USE_WID_5G==7915)
	{ "wl_stbc", "3" },                            /* STBC */
#else
	{ "wl_stbc", "0" },                            /* STBC */
#endif
	{ "wl_HT_RDG", "0" },                          /* HT RDG */
#if defined (USE_WID_5G) && (USE_WID_5G==7615 || USE_WID_5G==7915)
	{ "wl_HT_AMSDU", "1" },                        /* HT AMSDU */
	{ "wl_HT_BAWinSize", "256" },                  /* HT BA window size */
	{ "wl_mumimo", "1" },                          /* MU-MIMO */
	{ "wl_band_steering", "0" },                   /* band steering AP 5Ghz */
#else
	{ "wl_HT_AMSDU", "0" },                        /* HT AMSDU */
	{ "wl_HT_BAWinSize", "64" },                   /* HT BA window size */
#endif
	{ "wl_HT_80211KV", "0" },                      /* 802.11k/v roaming */
	{ "wl_HT_80211R", "0" },                       /* 802.11r FT */
	{ "wl_HT_MpduDensity", "5" },                  /* HT MPDU density */
	{ "wl_HT_AutoBA", "1" },                       /* HT auto BA */
	{ "wl_VgaClamp", "0" },                        /* VGA clamp */
	{ "wl_KickStaRssiLow", "0" },                  /* Low RSSI kick threshold */
	{ "wl_AssocReqRssiThres", "0" },               /* Assoc req RSSI threshold */

	/* guest AP 5GHz */
	{ "wl_guest_enable", "0" },                    /* Guest network */
	{ "wl_guest_date_x", "1111111" },              /* Guest schedule days */
	{ "wl_guest_time_x", "00002359" },             /* Guest schedule time 1 */
	{ "wl_guest_time2_x", "00002359" },            /* Guest schedule time 2 */
	{ "wl_guest_ssid", DEF_WLAN_5G_GSSID },
	{ "wl_guest_closed", "0" },                    /* Guest hide SSID */
	{ "wl_guest_ap_isolate", "1" },                /* Guest AP isolation */
	{ "wl_guest_lan_isolate", "1" },               /* Guest LAN isolation */
	{ "wl_guest_auth_mode", "open" },              /* Guest auth mode */
	{ "wl_guest_wpa_mode", "2" },                  /* Guest WPA mode */
	{ "wl_guest_crypto", "aes" },                  /* Guest encryption */
	{ "wl_guest_wpa_psk", "" },                    /* Guest key */
	{ "wl_guest_macrule", "0" },                   /* Guest MAC rule */
	{ "wl_guest_mcs_mode", "0" },                  /* Guest MCS mode */

	/* ApCli 5GHz */
	{ "wl_sta_ssid", "" },                         /* Station SSID */
	{ "wl_sta_auth_mode", "psk" },                 /* Station auth mode */
	{ "wl_sta_wpa_mode", "2" },                    /* Station WPA mode */
	{ "wl_sta_crypto", "aes" },                    /* Station encryption */
	{ "wl_sta_wpa_psk", "" },                      /* Station key */
	{ "wl_sta_wisp", "1" },                        /* Station WISP mode */
	{ "wl_sta_auto", "1" },                        /* Station auto connect */
#endif

#if BOARD_HAS_2G_RADIO
	/* 2.4GHz Wireless parameters */
	{ "rt_country_code", DEF_WLAN_2G_CC },
	{ "rt_ssid", DEF_WLAN_2G_SSID },
#if defined(BOARD_HAS_2G_11AX) && BOARD_HAS_2G_11AX
	{ "rt_gmode", "6" },                           /* b/g/n/ax mixed */
#else
	{ "rt_gmode", "5" },                           /* g/n mixed */
#endif
	{ "rt_mcs_mode", "0" },                        /* MCS mode */
	{ "rt_channel", "0" },                         /* Channel number */
	{ "rt_bcn", "100" },                           /* Beacon interval */
	{ "rt_dtim", "1" },                            /* DTIM interval */
	{ "rt_gmode_protection", "auto" },             /* G mode protection */
	{ "rt_rts", "2347" },                          /* RTS threshold */
	{ "rt_frag", "2346" },                         /* Fragment threshold */
	{ "rt_ap_isolate", "0" },                      /* AP isolation */
	{ "rt_closed", "0" },                          /* Closed (hidden) network */
	{ "rt_macmode", "disabled" },                  /* MAC filter mode */
	{ "rt_mrate", "2" },                           /* Fixed rate */
	{ "rt_mode", "ap" },                           /* Op mode */
	{ "rt_HT_BW", "1" },                           /* HT BW */
	{ "rt_WPS", "0" },                             /* WPS */
	{ "rt_HT_EXTCHA", "1" },                       /* HT extension channel */
	{ "rt_HT_OpMode", "1" },                       /* HT op mode */
	{ "rt_wme", "1" },                             /* WMM */
	{ "rt_wme_no_ack", "off" },                    /* WMM No-Ack */
	{ "rt_IgmpSnEnable", "1" },                    /* IGMP Snooping */
	{ "rt_TxPower", "100" },                       /* TX power (%) */
	{ "rt_TxBurst", "1" },                         /* TX burst */
	{ "rt_PktAggregate", "1" },                    /* Packet aggregation */
	{ "rt_APSDCapable", "0" },                     /* APSD */
	{ "rt_auth_mode", "psk" },                     /* Auth mode */
	{ "rt_crypto", "aes" },                        /* Encryption */
	{ "rt_wpa_psk", DEF_WLAN_2G_PSK },
	{ "rt_wpa_gtk_rekey", "3600" },                /* WPA GTK rekey */
	{ "rt_key", "1" },                             /* Current WEP key index */
	{ "rt_key_type", "0" } ,
	{ "rt_key1", "" },                             /* WEP key 1 */
	{ "rt_key2", "" },                             /* WEP key 2 */
	{ "rt_key3", "" },                             /* WEP key 3 */
	{ "rt_key4", "" },                             /* WEP key 4 */
	{ "rt_radius_ipaddr", "" },                    /* RADIUS server IP */
	{ "rt_radius_port", "1812" },                  /* RADIUS port */
	{ "rt_radius_key", "" },                       /* RADIUS key */
	{ "rt_radio_x", "1" },                         /* Radio enable */
	{ "rt_ssid2", DEF_WLAN_2G_SSID },
	{ "rt_mode_x", "0" },                          /* 2.4GHz Wireless Bridge Mode */
	{ "rt_wdsapply_x", "0" },                      /* WDS apply */
	{ "rt_wdsnum_x", "0" },                        /* WDS count */
	{ "rt_wep_x", "0" },                           /* WEP */
	{ "rt_phrase_x", "" },                         /* WEP passphrase */
	{ "rt_radio_date_x", "1111111" },              /* Radio schedule days */
	{ "rt_radio_time_x", "00002359" },             /* Radio schedule time 1 */
	{ "rt_radio_time2_x", "00002359" },            /* Radio schedule time 2 */
	{ "rt_macnum_x", "0" },                        /* MAC filter count */
	{ "rt_wdslist_x", "" },                        /* WDS list */
	{ "rt_maclist_x", "" },                        /* MAC filter list */
	{ "rt_macdesc_x", "" },                        /* MAC description list */
	{ "rt_wpa_mode", "2" },                        /* WPA mode (2=WPA2-Personal) */
	{ "rt_stream_tx", STR(BOARD_NUM_ANT_2G_TX) },
	{ "rt_stream_rx", STR(BOARD_NUM_ANT_2G_RX) },
	{ "rt_preamble", "1" },                        /* Preamble type */
	{ "rt_greenap", "0" },                         /* 2.4GHz GreenAP */
	{ "rt_pmf", "1" },                             /* PMF (1=optional, required for WPA3) */
	{ "rt_sta_pmf", "0" },                         /* Station PMF */
	{ "rt_HT_RDG", "0" },                          /* HT RDG */
	{ "rt_HT_AMSDU", "1" },                        /* HT AMSDU */
	{ "rt_HT_80211KV", "0" },                      /* 802.11k/v roaming */
	{ "rt_HT_80211R", "0" },                       /* 802.11r FT */
	{ "rt_HT_MpduDensity", "5" },                  /* HT MPDU density */
	{ "rt_band_steering", "0" },                   /* band steering AP 2.4Ghz */
#if defined (USE_WID_2G) && (USE_WID_2G==7615 || USE_WID_2G==7915)
	{ "rt_HT_BAWinSize", "256" },                  /* HT BA window size */
	{ "rt_ldpc", "1" },                            /* LDPC */
	{ "rt_turbo_qam", "1" },                       /* Turbo QAM */
	{ "rt_airtimefairness", "1" },                 /* Airtime fairness */
#else
	{ "rt_HT_BAWinSize", "64" },                   /* HT BA window size */
	{ "rt_ldpc", "0" },                            /* LDPC */
#endif
	{ "rt_stbc", "1" },                            /* STBC */
	{ "rt_HT_AutoBA", "1" },                       /* HT auto BA */
	{ "rt_VgaClamp", "0" },                        /* VGA clamp */
	{ "rt_KickStaRssiLow", "0" },                  /* Low RSSI kick threshold */
	{ "rt_AssocReqRssiThres", "0" },               /* Assoc req RSSI threshold */

	/* guest AP 2.4GHz */
	{ "rt_guest_enable", "0" },                    /* Guest network */
	{ "rt_guest_date_x", "1111111" },              /* Guest schedule days */
	{ "rt_guest_time_x", "00002359" },             /* Guest schedule time 1 */
	{ "rt_guest_time2_x", "00002359" },            /* Guest schedule time 2 */
	{ "rt_guest_ssid", DEF_WLAN_2G_GSSID },
	{ "rt_guest_closed", "0" },                    /* Guest hide SSID */
	{ "rt_guest_ap_isolate", "1" },                /* Guest AP isolation */
	{ "rt_guest_lan_isolate", "1" },               /* Guest LAN isolation */
	{ "rt_guest_auth_mode", "open" },              /* Guest auth mode */
	{ "rt_guest_wpa_mode", "2" },                  /* Guest WPA mode */
	{ "rt_guest_crypto", "aes" },                  /* Guest encryption */
	{ "rt_guest_wpa_psk", "" },                    /* Guest key */
	{ "rt_guest_macrule", "0" },                   /* Guest MAC rule */
	{ "rt_guest_mcs_mode", "0" },                  /* Guest MCS mode */

	/* ApCli 2.4GHz */
	{ "rt_sta_ssid", "" },                         /* Station SSID */
	{ "rt_sta_auth_mode", "psk" },                 /* Station auth mode */
	{ "rt_sta_wpa_mode", "2" },                    /* Station WPA mode */
	{ "rt_sta_crypto", "aes" },                    /* Station encryption */
	{ "rt_sta_wpa_psk", "" },                      /* Station key */
	{ "rt_sta_wisp", "1" },                        /* Station WISP mode */
	{ "rt_sta_auto", "1" },                        /* Station auto connect */
#endif

	/* USB related */
	{ "acc_num", "0" },                            /* ACC count */
	{ "enable_ftp", "0" },                         /* FTP server */
	{ "enable_samba", "0" },                       /* Samba enable */
	{ "st_samba_fp", "0" },                        /* Samba empty password */
	{ "st_samba_mode", "1" },                      /* Samba mode */
	{ "st_samba_lmb", "1" },                       /* Samba LM compat */
	{ "st_samba_workgroup", DEF_SMB_WORKGROUP },
	{ "st_ftp_mode", "1" },                        /* FTP mode */
	{ "st_ftp_log", "0" },                         /* FTP log */
	{ "st_ftp_pmin", "50000" },                    /* FTP passive port min */
	{ "st_ftp_pmax", "50100" },                    /* FTP passive port max */
	{ "st_ftp_anmr", "0" },                        /* FTP anonymous write */
	{ "st_max_user", "10" },                       /* Max users */
	{ "apps_dms", "0" },                           /* Media server */
	{ "apps_itunes", "0"},
	{ "sh_num", "0" },                             /* Share count */
	{ "computer_name", BOARD_NAME },
	{ "pcache_reclaim", "2" },                     /* Page cache reclaim */
	{ "usb3_disable", "0" },                       /* Disable USB3.0 */
	{ "u2ec_enable", "1" },                        /* USB ethernet */
	{ "lprd_enable", "1" },                        /* LPR printer */
	{ "rawd_enable", "0" },                        /* RAW printer */
	{ "achk_enable", "1" },                        /* Auto check */
	{ "nfsd_enable", "0" },                        /* NFS server */
	{ "optw_enable", "0" },                        /* Optware */
	{ "dlna_disc", "895" },                        /* DLNA discovery interval */
	{ "dlna_root", "0" },                          /* DLNA root */
	{ "dlna_sort", "0" },                          /* DLNA sort */
	{ "dlna_src1", "/media/AiDisk_a1" },           /* DLNA source 1 */
	{ "dlna_src2", "" },                           /* DLNA source 2 */
	{ "dlna_src3", "" },                           /* DLNA source 3 */
	{ "dlna_rescan", "0"},
	{ "trmd_enable", "0" },                        /* Transmission */
	{ "trmd_pport", "51413" },                     /* Transmission peer port */
	{ "trmd_rport", "9091" },                      /* Transmission RPC port */
	{ "trmd_ropen", "0" },                         /* Transmission RPC open */
	{ "aria_enable", "0" },                        /* Aria2 */
	{ "aria_pport", "16888" },                     /* Aria2 peer port */
	{ "aria_rport", "6800" },                      /* Aria2 RPC port */
	{ "aria_ropen", "0" },                         /* Aria2 RPC open */
	{ "hdd_spindt", "0" },                         /* HDD spindown */
	{ "hdd_apmoff", "0" },                         /* Disable HDD APM */

	{ "ip6_service", "dhcp6" },                    /* IPV6 */
	{ "ip6_wan_if", "0" },                         /* IPv6 WAN interface */

	{ "ip6_6in4_remote", "" },                     /* 6in4 remote */
	{ "ip6_6to4_relay", "192.88.99.1" },           /* 6to4 relay */
	{ "ip6_6rd_relay", "" },                       /* 6rd relay */
	{ "ip6_6rd_size", "0" },                       /* 6rd prefix length */
	{ "ip6_6rd_dhcp", "1" },                       /* 6rd DHCP */
	{ "ip6_sit_mtu", "1280" },                     /* 6in4 MTU */
	{ "ip6_sit_ttl", "64" },                       /* 6in4 TTL */

	{ "ip6_wan_dhcp", "0" },                       /* IPv6 WAN DHCP */
	{ "ip6_wan_priv", "0" },                       /* IPv6 WAN privacy */
	{ "ip6_wan_addr", "" },                        /* IPv6 WAN address */
	{ "ip6_wan_size", "64" },                      /* IPv6 WAN prefix length */
	{ "ip6_wan_gate", "" },                        /* IPv6 WAN gateway */

	{ "ip6_dns_auto", "1" },                       /* IPv6 DNS auto */
	{ "ip6_dns1", "" },                            /* IPv6 DNS1 */
	{ "ip6_dns2", "" },                            /* IPv6 DNS2 */
	{ "ip6_dns3", "" },                            /* IPv6 DNS3 */

	{ "ip6_lan_auto", "1" },                       /* IPv6 LAN auto */
	{ "ip6_lan_addr", "fc00:101:101::1" },         /* IPv6 LAN address */
	{ "ip6_lan_size", "64" },                      /* IPv6 LAN prefix length */
	{ "ip6_lan_radv", "1" },                       /* IPv6 RA */
	{ "ip6_lan_dhcp", "1" },                       /* IPv6 LAN DHCP */
	{ "ip6_lan_sflt", "1800" },                    /* IPv6 source filter */
	{ "ip6_lan_sfps", "4096" },                    /* 0x1000 */
	{ "ip6_lan_sfpe", "4352" },                    /* 0x1100 */

	{ "upnp_enable_x", "1" },                      /* UPnP enable */
	{ "upnp_proto", "0" },                         /* UPnP protocol */
	{ "upnp_secure", "1" },                        /* UPnP secure mode */
	{ "upnp_clean_min", "10" },                    /* UPnP clean min */
	{ "upnp_clean_int", "600" },                   /* UPnP clean interval */
	{ "upnp_iport_min", "21" },                    /* UPnP internal port min */
	{ "upnp_iport_max", "65535" },                 /* UPnP internal port max */
	{ "upnp_eport_min", "80" },                    /* UPnP external port min */
	{ "upnp_eport_max", "65535" },                 /* UPnP external port max */
	{ "vts_enable_x", "0" },                       /* Virtual server enable */
	{ "vts_num_x", "0" },                          /* Virtual server count */
	{ "sp_battle_ips", "0" },                      /* Game boost IP */
	{ "fw_log_x", "none" },                        /* Firewall logging */
	{ "misc_http_x", "0" },                        /* HTTP proxy */
	{ "misc_httpport_x", "8080" },                 /* HTTP proxy port */
	{ "https_wopen", "0" },                        /* HTTPS WAN open */
	{ "https_wport", "8443" },                     /* HTTPS WAN port */
	{ "udpxy_wopen", "0" },                        /* udpxy WAN open */
	{ "udpxy_wport", "34040" },                    /* udpxy WAN port */
	{ "ftpd_wopen", "0" },                         /* FTP WAN open */
	{ "ftpd_wport", "21" },                        /* FTP WAN port */
	{ "sshd_wopen", "0" },                         /* SSH WAN open */
	{ "sshd_wport", "10022" },                     /* SSH WAN port */
	{ "sshd_wbfp", "2" },                          /* SSH WAN brute force protect */
	{ "misc_lpr_x", "0" },                         /* LPR WAN open */
	{ "misc_ping_x", "0" },                        /* WAN respond ping */
	{ "fw_lw_enable_x", "0" },                     /* Access control */
	{ "filter_lw_date_x", "1111111" },             /* Access control days */
	{ "filter_lw_time_x", "00002359" },            /* Access control time */
	{ "filter_lw_default_x", "ACCEPT" },           /* Access control default */
	{ "filter_lw_icmp_x", "" },                    /* Access control ICMP */
	{ "filter_lw_num_x", "0" },                    /* Access control rule count */
	{ "url_enable_x", "0" },                       /* URL filter */
	{ "url_date_x", "1111111" },                   /* URL filter days */
	{ "url_time_x", "00002359" },                  /* URL filter time */
	{ "url_mac_x", "" },                           /* URL filter MAC */
	{ "url_inv_x", "0" },                          /* URL filter invert */
	{ "url_num_x", "0" },                          /* URL filter count */
	{ "macfilter_enable_x", "0" },                 /* MAC filter */
	{ "macfilter_num_x", "0" },                    /* MAC filter count */
	{ "sr_enable_x", "0" },                        /* Static route enable */
	{ "sr_rip_x", "0" },                           /* Static route RIP */
	{ "sr_num_x", "0" },                           /* Static route count */
	{ "dr_static_rip_x", "0" },                    /* Static route RIP */
	{ "dr_static_matric_x", "1" },                 /* Static route metric */
	{ "dr_default_x", "1" },                       /* Default route */
	{ "dr_staticnum_x", "0" },                     /* Static route count */
	{ "dr_staticipaddr_x", "" },                   /* Static route IP */
	{ "dr_staticnetmask_x", "0" },                 /* Static route mask */
	{ "dr_staticgateway_x", "" },                  /* Static route gateway */

#if defined(APP_SCUT)
	/* scutclient related */
	{ "scutclient_enable", "0" },                  /* scutclient enable */
	{ "scutclient_debug", "0" },                   /* scutclient debug */
	{ "scutclient_hostname", "Lenovo-PC" },        /* scutclient hostname */
	{ "scutclient_server_auth_ip", "202.38.210.131" }, /* scutclient server auth IP */
	{ "scutclient_skip_udp_hb", "0" },             /* scutclient skip UDP heartbeat */
	{ "scutclient_version", "4472434f4d0096022a" }, /* scutclient version */
	{ "scutclient_hash", "2ec15ad258aee9604b18f2f8114da38db16efd00" }, /* scutclient hash */
	{ "scutclient_username", "" },                 /* scutclient username */
	{ "scutclient_password", "" },                 /* scutclient password */
	{ "scutclient_watchcat", "1" },                /* scutclient watchdog */
	{ "scutclient_wdg_force", "1" },               /* scutclient watchdog force */
#endif

#if defined(APP_MENTOHUST)
	/* mentohust related */
	{ "mentohust_enable", "0" },                   /* mentohust enable */
	{ "mentohust_username", "" },                  /* mentohust username */
	{ "mentohust_password", "" },                  /* mentohust password */
	{ "mentohust_nic", "" },                       /* mentohust NIC */
	{ "mentohust_ip", "" },                        /* mentohust IP */
	{ "mentohust_mask", "" },                      /* mentohust mask */
	{ "mentohust_gw", "" },                        /* mentohust gateway */
	{ "mentohust_dns", "" },                       /* mentohust DNS */
	{ "mentohust_pinghost", "" },                  /* mentohust ping host */
	{ "mentohust_timeout", "8" },                  /* mentohust timeout */
	{ "mentohust_interval", "30" },                /* mentohust interval */
	{ "mentohust_restart_wait", "15" },            /* mentohust restart wait */
	{ "mentohust_maxfail", "0" },                  /* mentohust max fail */
	{ "mentohust_startmode", "1" },                /* mentohust start mode */
	{ "mentohust_dhcp", "0" },                     /* mentohust DHCP */
	{ "mentohust_daemon", "1" },                   /* mentohust daemon */
	{ "mentohust_service", "0" },                  /* mentohust service */
	{ "mentohust_ver", "0.00" },                   /* mentohust version */
	{ "mentohust_datafile", "/etc/storage/mentohust/" }, /* mentohust data file */
	{ "mentohust_dhcpscript", "" },                /* mentohust DHCP script */
#endif

#if defined(APP_TTYD)
	/* ttyd related */
	{ "ttyd_enable", "0" },                        /* ttyd web terminal */
	{ "ttyd_port", "7681" },                       /* ttyd port */
#endif

#if defined(APP_VLMCSD)
	/* vlmcsd */
	{ "vlmcsd_enable", "0" },                      /* vlmcsd KMS */
#endif

#if defined (APP_IPERF3)
	/* iperf3 */
	{ "iperf3_enable", "0" },                      /* iperf3 server */
#endif

#if defined(APP_DNSFORWARDER)
	/* dns-forwarder */
	{ "dns_forwarder_enable", "0" },               /* DNS forwarder enable */
	{ "dns_forwarder_port", "5353" },              /* DNS forwarder port */
	{ "dns_forwarder_bind", "0.0.0.0" },           /* DNS forwarder bind */
	{ "dns_forwarder_server", "8.8.4.4:53" },      /* DNS forwarder server */
#endif

#if defined(APP_SHADOWSOCKS)
	/* shadowsocks */
	{ "ss_enable", "0" },                          /* Shadowsocks enable */
	{ "global_server", "nil" },                    /* nil = disabled */
	{ "udp_relay_server", "nil" },                 /* nil = disabled, same = same as main server */
	{ "ss_threads", "0" },                         /* SS threads */
	{ "ss_run_mode", "gfw" },                      /* gfw = router mode, all = all overseas */
	{ "s_dports", "0" },                           /* Socks5 target ports */
	{ "lan_con", "0" },                            /* LAN connections */
	{ "pdnsd_enable", "0" },                       /* pdnsd enable */
	{ "ss_chdns", "0" },                           /* SS China DNS */
	{ "china_dns", "223.5.5.5#53" },               /* China DNS */
	{ "tunnel_forward", "8.8.8.8#53" },            /* Tunnel forward */
	{ "ss_cgroups", "0" },                         /* SS cgroups */
	{ "ss_cgoups_cpu_s", "512" },                  /* SS cgroups CPU */
	{ "ss_cgoups_mem_s", "20M" },                  /* SS cgroups memory */
	{ "ss_watchcat", "0" },                        /* SS watchdog */
	{ "socks5_enable", "nil" },                    /* nil = disabled, same = same as main server */
	{ "socks5_port", "1088" },                     /* Socks5 port */
	{ "ss_adblock", "0" },                         /* SS adblock */
	{ "ss_adblock_url", "https://anti-ad.net/anti-ad-for-dnsmasq.conf"},
	{ "ss_update_chnroute", "1" },                 /* SS update chnroute */
	{ "ss_chnroute_url", "https://ispip.clang.cn/all_cn.txt"},
	{ "ss_update_gfwlist", "1" },                  /* SS update gfwlist */
	{ "ss_gfwlist_url", "https://cdn.jsdelivr.net/gh/YW5vbnltb3Vz/domain-list-community@release/gfwlist.txt"},
	{ "ss_type", "0" },                            /* SS type */
	{ "backup_server", "nil" },                    /* Backup server */
	{ "ssp_local_port", "1080" },                  /* SS proxy local port */
	{ "ssp_dns_ip", "2" },                         /* SS proxy DNS IP */
	{ "socks5_s_username", "" },                   /* Socks5 server username */
	{ "socks5_s_password", "" },                   /* Socks5 server password */
	{ "ss_schedule_enable", "0" },                 /* SS schedule enable */
	{ "ss_schedule", "00000000000" },              /* SS schedule */

	{ "ss_mode", "1" },                            /* SS mode */
	{ "ss_server", "127.0.0.1" },                  /* Server address */
	{ "ss_server_port", "8989" },                  /* SS server port */
	{ "ss_key", "Secret" },                        /* SS key */
	{ "ss_method", "rc4-md5" },                    /* Encryption */
	{ "ss_own", "1" },                             /* SS own */
	{ "ss_local_port", "1080" },                   /* Local port */
	{ "ss_mtu", "1492" },                          /* SS MTU */
	{ "ss_router_proxy", "1" },                    /* Route proxy mode */
	{ "ss_lower_port_only", "1" },                 /* SS low port only */
	{ "ss_timeout", "60"},
	{ "ss_protocol", "origin"},
	{ "ss_proto_param", ""},
	{ "ss_obfs", "plain"},
	{ "ss_obfs_param", ""},

	{ "ss-tunnel_enable", "0" },                   /* SS tunnel enable */
	{ "ss-tunnel_local_port", "5353" },            /* SS tunnel local port */
	{ "ss-tunnel_remote", "8.8.4.4:53" },          /* Tunnel remote */
	{ "ss-tunnel_mtu", "1492" },                   /* SS tunnel MTU */
	
	{ "ssp_staticnum_x", "0" },                    /* SS proxy static count */
	
	{ "v2_type_tcp", "none" },                     /* V2Ray TCP type */
	{ "v2_type_mkcp", "none" },                    /* mKCP type */
	{ "v2_mkcp_mtu", "1350" },                     /* mKCP MTU */
	{ "v2_mkcp_tti", "50" },                       /* mKCP TTI */
	{ "v2_mkcp_uplink", "50" },                    /* mKCP uplink */
	{ "v2_mkcp_downlink", "20" },                  /* mKCP downlink */
	{ "v2_mkcp_readbu", "2" },                     /* V2Ray mKCP read buffer */
	{ "v2_mkcp_writebu", "2" },                    /* V2Ray mKCP write buffer */
	{ "v2_mkcp_congestion", "0" },                 /* mKCP congestion */
	{ "v2_webs_host", "" },                        /* V2Ray WebSocket host */
	{ "v2_webs_path", "" },                        /* V2Ray WebSocket path */
	{ "v2_http2_host", "" },                       /* V2Ray HTTP2 host */
	{ "v2_http2_path", "" },                       /* V2Ray HTTP2 path */
	{ "v2_tls", "0" },                             /* TLS */
	{ "v2_mux", "0" },                             /* V2Ray Mux */
	
	/* SS subscription */
	{ "ss_list", "0" },                            /* SS list */
	{ "d_server", "" },                            /* Proxy server */
	{ "d_port", "" },                              /* Proxy port */
	{ "d_type", "" },                              /* Proxy type */
	{ "ud_type", "" },                             /* UDP type */
	{ "s5_type", "" },                             /* Socks5 type */
	{ "d_v2_aid", "" },                            /* Proxy V2Ray alterId */
	{ "d_v2_uid", "" },                            /* Proxy V2Ray UUID */
	{ "d_v2_security", "" },                       /* Proxy V2Ray security */
	{ "d_v2_net", "" },                            /* Proxy V2Ray network */
	{ "d_v2_type", "" },                           /* Proxy V2Ray type */
	{ "d_v2_host", "" },                           /* Proxy V2Ray host */
	{ "d_v2_path", "" },                           /* Proxy V2Ray path */
	{ "d_v2_tls", "" },                            /* Proxy V2Ray TLS */
	{ "d_ss_password", "" },                       /* Proxy SS password */
	{ "d_ss_method", "" },                         /* Proxy SS encryption */
	{ "d_ss_protocol", "" },                       /* Proxy SS protocol */
	{ "d_ss_protoparam", "" },                     /* Proxy SS protocol param */
	{ "d_ss_obfs", "" },                           /* Proxy SS obfs */
	{ "d_ss_obfsparam", "" },                      /* Proxy SS obfs param */
	{ "d_keyword_n", "" },                         /* Proxy keyword N */
	{ "d_keyword_y", "" },                         /* Proxy keyword Y */
	{ "d_update_link", "" },                       /* Proxy update URL */
	{ "ss_keyword", "过期时间/剩余流量" },                 /* SS keyword */
#endif

#if defined(APP_ADBYBY)
	/* Adbyby Plus+ */
	{ "adbyby_enable", "0" },                      /* Adbyby adblock */
	{ "adbyby_set", "0" },                         /* Adbyby settings */
	{ "adbyby_adb_update", "0" },                  /* Adbyby ADB update */
	{ "adbyby_update", "2" },                      /* Adbyby update */
	{ "hosts_ad", "1" },                           /* Hosts adblock */
	{ "adbyby_update_hour", "03" },                /* Adbyby update hour */
	{ "adbyby_update_min", "30" },                 /* Adbyby update minute */
	{ "adbyby_ip_x", "0" },                        /* Adbyby IP */
	{ "adbyby_rules_x", "0" },                     /* Adbyby rules */
	{ "adbybyip_staticnum_x", "0" },               /* Adbyby IP static count */
	{ "adbybyrules_staticnum_x", "0" },            /* Adbyby rules static count */
	{ "block_ios", "0" },                          /* Block iOS */
	{ "block_douyin", "0" },                       /* Block Douyin */
	{ "anti_ad", "0" },                            /* Adblock */
	{ "anti_ad_link", "https://anti-ad.net/anti-ad-for-dnsmasq.conf" }, /* Adblock rules URL */
	{ "anti_ad_count", "0" },                      /* Adblock count */
#endif

#if defined(Pdnsd)
	/* Pdnsd */
	{ "dns_enable", "0" },                         /* DNS enable */
	{ "dns_server", "223.5.5.5,114.114.114.114" }, /* DNS server */
	{ "dns_server_port", "5333" },                 /* DNS server port */
	{ "dns_server_bind", "0.0.0.0" },              /* DNS server bind */
#endif

#if defined(APP_ALIDDNS)
	/* Aliddns */
	{ "aliddns_enable", "0" },                     /* Aliyun DDNS */
	{ "aliddns_interval", "600" },                 /* Update interval */
	{ "aliddns_ttl", "600" },                      /* TTL */
	{ "aliddns_ak", ""  },
	{ "aliddns_sk", "" },                          /* AccessKey Secret */
	{ "aliddns_name", "" },                        /* Aliyun DDNS name */
	{ "aliddns_name2", "" },                       /* Aliyun DDNS name 2 */
	{ "aliddns_name6", "" },                       /* Aliyun DDNS name 6 */
	{ "aliddns_domain", "" },                      /* Domain */
	{ "aliddns_domain2", "" },                     /* Aliyun DDNS domain 2 */
	{ "aliddns_domain6", "" },                     /* Aliyun DDNS domain 6 */
#endif
	
#if defined(APP_ADGUARDHOME)
	/* AdGuard Home */
	{ "adg_enable", "0" },                         /* AdGuard enable */
	{ "adg_redirect", "0" },                       /* AdGuard redirect */
#endif

#if defined(APP_CADDY)
	/* Caddy */
	{ "caddy_enable", "0" },                       /* Caddy web server */
	{ "caddy_file", "0" },                         /* Caddy config file */
	{ "caddy_wan", "0" },                          /* Caddy WAN */
	{ "caddy_storage", "-1" },                     /* Caddy storage */
	{ "caddy_dir", "/tmp" },                       /* Caddy dir */
	{ "caddyf_wan_port", "19998" },                /* Caddy file WAN port */
	{ "caddyw_wan_port", "19999" },                /* Caddy web WAN port */
	{ "caddy_wip6", "0" },                         /* Caddy WAN IPv6 */
	{ "caddy_wname", "admin" },                    /* Caddy WAN name */
	{ "caddy_wpassword", "admin" },                /* Caddy WAN password */
#endif

#if defined(APP_FRP)
	/* frp */
	{ "frpc_enable", "0" },                        /* frp client */
	{ "frps_enable", "0" },                        /* frp server */
#endif

#if defined(APP_SMARTDNS)
	/* SmartDNS */
	{ "sdns_enable", "0" },                        /* SmartDNS enable */
	{ "sdns_name", "smartdns" },                   /* SmartDNS name */
	{ "sdns_group", "domestic" },                  /* SmartDNS group */
	{ "sdns_port", "6053" },                       /* SmartDNS port */
	{ "sdns_tcp_server", "1" },                    /* SmartDNS TCP server */
	{ "sdns_ipv6_server", "1" },                   /* SmartDNS IPv6 server */
	{ "sdns_redirect", "1" },                      /* SmartDNS redirect */
	{ "sdns_cache", "32768" },                     /* SmartDNS cache */
	{ "sdns_cache_persist", "1" },                 /* SmartDNS cache persist */
	{ "sdns_cache_checkpoint_time", "0" },         /* SmartDNS cache checkpoint */
	{ "sdns_tcp_idle_time","120"},
	{ "sdns_rr_ttl", "300" },                      /* SmartDNS RR TTL */
	{ "sdns_rr_ttl_min", "60" },                   /* SmartDNS RR TTL min */
	{ "sdns_rr_ttl_max", "3600" },                 /* SmartDNS RR TTL max */
	{ "sdns_rr_ttl_reply_max", "60" },             /* SmartDNS RR TTL reply max */
	{ "sdns_max_reply_ip_num", "3" },              /* SmartDNS max reply IP */

	{ "sdns_speed", "0" },                         /* SmartDNS speed */
	{ "sdns_speed_mode", "ping,tcp:80,tcp:443" },  /* SmartDNS speed mode */
	{ "sdns_address", "0" },                       /* SmartDNS address */
	{ "sdns_ns", "0" },                            /* SmartDNS NS */
	{ "sdns_ipset", "0" },                         /* SmartDNS IPset */
	{ "sdns_ipset_timeout", "1" },                 /* SmartDNS IPset timeout */
	{ "sdns_as", "0" },                            /* SmartDNS AS */
	{ "sdns_ip_change", "1" },                     /* SmartDNS IP change */
	{ "sdns_ip_change_time", "10" },               /* SmartDNS IP change time */
	{ "sdns_force_aaaa_soa", "1" },                /* SmartDNS force AAAA SOA */
	{ "sdns_force_qtype_soa", "28 65" },           /* SmartDNS force QTYPE SOA */
	{ "sdns_prefetch_domain", "1" },               /* SmartDNS prefetch domain */
	{ "sdns_exp", "1" },                           /* SmartDNS expire */
	{ "sdns_exp_ttl", "259200" },                  /* SmartDNS expire TTL */
	{ "sdns_exp_ttl_max", "3" },                   /* SmartDNS expire TTL max */
	{ "sdns_exp_prefetch_time", "21600" },         /* SmartDNS expire prefetch */
	{ "sdns_dualstack_ip_allow_force_aaaa", "1" }, /* SmartDNS dualstack force AAAA */

	{ "sdnse_enable", "0" },                       /* SmartDNS extra enable */
	{ "sdnse_port", "8053" },                      /* SmartDNS extra port */
	{ "sdnse_tcp_server", "1" },                   /* SmartDNS extra TCP server */
	{ "sdnse_name", "overseas" },                  /* SmartDNS extra name */
	{ "sdnse_speed", "1" },                        /* SmartDNS extra speed */
	{ "sdnse_ipset", "0" },                        /* SmartDNS extra IPset */
	{ "sdnse_address", "1" },                      /* SmartDNS extra address */
	{ "sdnse_ns", "1" },                           /* SmartDNS extra NS */
	{ "sdnse_as", "0" },                           /* SmartDNS extra AS */
	{ "sdnse_ipv6_server", "1" },                  /* SmartDNS extra IPv6 server */
	{ "sdnse_ipc", "1" },                          /* SmartDNS extra IPC */
	{ "sdnse_cache", "1" },                        /* SmartDNS extra cache */

	{ "sdns_adblock", "0" },                       /* SmartDNS adblock */
	{ "sdns_adblock_url", "https://anti-ad.net/anti-ad-for-smartdns.conf" }, /* SmartDNS adblock URL */
	{ "sdns_white", "0" },                         /* SmartDNS whitelist */
	{ "sdns_black", "0" },                         /* SmartDNS blacklist */
	{ "sdns_auto_restart", "0" },                  /* SmartDNS auto restart */
	{ "sdns_coredump", "0" },                      /* SmartDNS coredump */
	{ "sdns_staticnum_x", "0" },                   /* SmartDNS static count */
#endif

#if defined(APP_WYY)
	/* UnblockNeteaseMusic */
	{ "wyy_enable", "0" },                         /* UnblockNeteaseMusic */
	{ "wyy_apptype", "cloud" },                    /* Netease app type */
	{ "wyy_cloudserver", "cdn-shanghai.service.project-openwrt.eu.org:30000:30001" }, /* Cloud server */
	{ "wyy_musicapptype", "kuwo" },                /* Netease music app type */
	{ "wyy_coustom_server", "" },                  /* Custom server */
	{ "wyy_coustom_music", "" },                   /* Custom music */
	{ "wyy_flac", "0" },                           /* Lossless quality */
	{ "wyy_staticnum_x", "0" },                    /* Netease static count */
#endif

#if defined(APP_ZEROTIER)
	/* ZeroTier */
	{ "zerotier_enable", "0" },                    /* ZeroTier enable */
	{ "zerotier_id", "" },                         /* ZeroTier node ID */
	{ "zerotier_nat", "1" },                       /* ZeroTier NAT */
	{ "zerotier_secret", "" },                     /* ZeroTier secret */
	{ "zero_staticnum_x", "0" },                   /* ZeroTier static route count */
#endif

#if defined(APP_DDNSTO)
	/* DDNSTO */
	{ "ddnsto_enable", "0" },                      /* DDNSTO enable */
	{ "ddnsto_id", "" },                           /* DDNSTO ID */
#endif

#if defined(APP_ALDRIVER)
	/* AliyunDrive */
	{ "aliyundrive_enable", "0" },                 /* AliyunDrive enable */
	{ "ald_refresh_token", "" },                   /* Aliyun refresh token */
	{ "ald_auth_user", "" },                       /* Aliyun auth user */
	{ "ald_auth_password", "" },                   /* Aliyun auth password */
	{ "ald_read_buffer_size", "10485760" },        /* Aliyun read buffer size */
	{ "ald_cache_size", "1000" },                  /* Aliyun cache size */
	{ "ald_cache_ttl", "600" },                    /* Aliyun cache TTL */
	{ "ald_host", "0.0.0.0" },                     /* Aliyun host */
	{ "ald_port", "8089" },                        /* Aliyun port */
	{ "ald_root", "/" },                           /* Aliyun root */
	{ "ald_domain_id", "0" },                      /* Aliyun domain ID */
	{ "ald_no_trash", "0" },                       /* Aliyun no trash */
	{ "ald_read_only", "0" },                      /* Aliyun read-only */
#endif
	/* Auto reboot */
	{ "reboot_schedule_enable", "0" },             /* Reboot schedule enable */
	{ "reboot_schedule", "00000000000" },          /* Reboot schedule */

#if defined(APP_WIREGUARD)
	/* WireGuard */
	{ "wireguard_enable", "0" },                   /* WireGuard enable */
	{ "wireguard_localip", "" },                   /* WireGuard local IP */
	{ "wireguard_localkey", "" },                  /* WireGuard local key */
	{ "wireguard_peerip", "" },                    /* WireGuard peer IP */
	{ "wireguard_peerkey", "" },                   /* WireGuard peer key */
#endif

#if defined(APP_SQM)
	/* SQM QoS */
	{ "sqm_enable", "0" },                         /* SQM QoS enable */
	{ "sqm_flag"  , "3" },
	{ "sqm_active", "ra0" },                       /* SQM active */
	{ "sqm_down_speed", "0" },                     /* SQM download speed */
	{ "sqm_up_speed", "0" },                       /* SQM upload speed */
	{ "sqm_debug_log", "0" },                      /* SQM debug log */
	{ "sqm_log_level", "5" },                      /* SQM log level */
	{ "sqm_qdisc", "fq_codel" },                   /* Queue discipline */
	{ "sqm_script", "simple" },                    /* Script */
#endif

	/* DHCP server parameters */
	{ "dhcp_start", DEF_LAN_DHCP_BEG },            /* First assignable DHCP address */
	{ "dhcp_end", DEF_LAN_DHCP_END },              /* Last assignable DHCP address */
	{ "dhcp_enable_x", "1" },                      /* DHCP server */
	{ "dhcp_lease", "86400" },                     /* DHCP lease (sec) */
	{ "dhcp_gateway_x", "" },                      /* DHCP gateway */
	{ "dhcp_dns1_x", "" },                         /* DHCP primary DNS */
	{ "dhcp_dns2_x", "" },                         /* DHCP secondary DNS */
	{ "dhcp_dns3_x", "" },                         /* DHCP DNS3 */
	{ "dhcp_dnsv6_x", "" },                        /* DHCP IPv6 DNS */
	{ "dhcp_dnsv61_x", "" },                       /* DHCP IPv6 DNS1 */
	{ "dhcp_wins_x", "" },                         /* DHCP WINS */
	{ "redirect_all_dns", "0" },                   /* Redirect all clients DNS requests */
	{ "dhcp_filter_aaaa", "0" },                   /* Filter AAAA queries */
	{ "dhcp_all_servers", "1" },                   /* Respond to all DHCP servers */
	{ "dhcp_strict_order", "0" },                  /* DNS strict order */
	{ "dhcp_stop_dns_rebind", "1" },               /* Prevent DNS rebinding */
	{ "ap_rssi_enable", "0" },                     /* Cross-AP client RSSI display */
	{ "ap_slave_ips", "" },                        /* Slave router IP list (comma separated) */
	{ "ap_slave_user", "admin" },                  /* Slave router username */
	{ "ap_slave_pass", "admin" },                  /* Slave router password */
	{ "ap_relay_enable", "0" },                    /* AP relay master switch */
	{ "ap_relay_list", "" },                       /* AP relay config list (band@mode@role@SSID@key@BSSID) */
	{ "ap_check", "0" },                           /* Network check */
	{ "ap_inet_check", "1" },                      /* Internet connectivity check */
	{ "ap_time_check", "0" },                      /* Scheduled check */
	{ "ap_rule", "0" },                            /* Switch rule (0=signal,1=quality) */
	{ "ap_black", "1" },                           /* Blacklist mode (0=whitelist,1=blacklist) */
	{ "ap_auto_switch", "0" },                     /* Auto switch */
	{ "ap_switch_threshold", "-75" },              /* Switch RSSI threshold (dBm) */
	{ "ap_switch_hysteresis", "10" },              /* Switch hysteresis (dB) */
	{ "ap_roam_protect", "60" },                   /* Roam protect time (sec) */
	{ "ap_quality_check", "0" },                   /* Link quality check */
	{ "ap_quality_ping_loss", "50" },              /* Quality packet loss threshold (%) */
	{ "ap_quality_ping_delay", "200" },            /* Quality latency threshold (ms) */
	{ "ap_fenge", "@" },                           /* Config field separator */
	{ "dhcp_proxy_dnssec", "0" },                  /* DNSSEC proxy */
	{ "dhcp_verbose", "0" },                       /* 0 : quiet, 1: verbose DHCP, 2: verbose DHCPv6, 3: verbose all */
	{ "dhcp_static_x", "0" },                      /* Static IP binding */
	{ "dhcp_static_arp", "0" },                    /* Static ARP binding */
	{ "dhcp_staticnum_x", "0" },                   /* Static IP count */

	/* NTP client parameters */
	{ "ntp_period", "24" },                        /* NTP period */
	{ "ntp_server0", DEF_NTP_SERVER0 },
	{ "ntp_server1", DEF_NTP_SERVER1 },

	/* DDNS parameters */
	{ "ddns_enable_x", "0" },                      /* DDNS enable */
	{ "ddns_server_x", "" },                       /* DDNS server */
	{ "ddns_username_x", "" },                     /* DDNS username */
	{ "ddns_passwd_x", "" },                       /* DDNS password */
	{ "ddns_hostname_x", "" },                     /* DDNS hostname */
	{ "ddns_hostname2_x", "" },                    /* DDNS hostname 2 */
	{ "ddns_hostname3_x", "" },                    /* DDNS hostname 3 */
	{ "ddns_wildcard_x", "0" },                    /* DDNS wildcard */
	{ "ddns2_wildcard_x", "0" },                   /* DDNS2 wildcard */
	{ "ddns_ipv6", "0" },                          /* DDNS IPv6 */
	{ "ddns_cst_svr", "" },                        /* DDNS custom server */
	{ "ddns_cst_url", "" },                        /* DDNS custom URL */
	{ "ddns_period", "24" },                       /* DDNS update period */
	{ "ddns_forced", "10" },                       /* DDNS force update */
	{ "ddns_verbose", "1" },                       /* DDNS verbose */
	{ "ddns_source", "0" },                        /* DDNS source */
	{ "ddns_checkip", "0" },                       /* DDNS check IP */
	{ "ddns2_checkip", "0" },                      /* DDNS2 check IP */
	{ "ddns_ssl", "0" },                           /* DDNS SSL */
	{ "ddns2_server", "" },                        /* DDNS2 server */
	{ "ddns2_hname", "" },                         /* DDNS2 hostname */
	{ "ddns2_user", "" },                          /* DDNS2 user */
	{ "ddns2_pass", "" },                          /* DDNS2 password */
	{ "ddns2_ssl", "0" },                          /* DDNS2 SSL */
	{ "asusddns_tos_agreement", "0" },             /* ASUS DDNS TOS agreement */

	{ "modem_rule", "0" },                         /* Modem rule */
	{ "modem_prio", "1" },                         /* Modem priority */
	{ "modem_type", "0" },                         /* Modem type */
	{ "modem_country", "" },                       /* Modem country */
	{ "modem_isp", "" },                           /* Modem ISP */
	{ "modem_apn", "" },                           /* Modem APN */
	{ "modem_dialnum", "" },                       /* Modem dial number */
	{ "modem_user", "" },                          /* Modem user */
	{ "modem_pass", "" },                          /* Modem password */
	{ "modem_pin", "" },                           /* Modem PIN */
	{ "modem_dnsa", "1" },                         /* Modem DNS */
	{ "modem_node", "0" },                         /* Modem node */
	{ "modem_nets", "0" },                         /* Modem network */
	{ "modem_zcd", "0" },                          /* Modem ZCD */
	{ "modem_cmd", "" },                           /* Modem command */
	{ "modem_mtu", "1500" },                       /* Modem MTU */

	{ "force_igmp", "0" },                         /* Force IGMP */
	{ "force_mld", "0" },                          /* Force MLD */
	{ "udpxy_enable_x", "0" },                     /* udpxy enable */
	{ "udpxy_clients", "10" },                     /* udpxy clients */
	{ "udpxy_renew_period", "120" },               /* udpxy renew period */
#if defined(APP_XUPNPD)
	{ "xupnpd_enable_x", "0" },                    /* xupnpd enable */
	{ "xupnpd_udpxy", "0" },                       /* xupnpd udpxy address */
#endif
	{ "rstats_enable", "1" },                      /* Traffic stats */
	{ "rstats_stored", "1" },                      /* Traffic stats stored */
	{ "stime_stored", "1" },                       /* Stored time */

	{ "http_id", "TIDe855a6487043d70a" },          /* HTTP session ID */
	{ "controlrate_unknown_unicast", "0" },        /* Unknown unicast rate control */
	{ "controlrate_unknown_multicast", "0" },      /* Unknown multicast rate control */
	{ "controlrate_multicast", "0" },              /* Multicast rate control */
	{ "controlrate_broadcast", "10" },             /* Broadcast rate control */

	{ "di_poll_mode", "0" },                       /* Poll mode */
	{ "di_timeout", "2" },                         /* Timeout */
	{ "di_time_done", "30" },                      /* Done time */
	{ "di_time_fail", "5" },                       /* Fail time */
	{ "di_lost_delay", "1" },                      /* Loss delay */
	{ "di_lost_action", "0" },                     /* Loss action */
	{ "di_recon_pause", "0" },                     /* Reconnect pause */
	{ "di_addr0", "114.114.114.114" },             /* Detect address 0 */
	{ "di_addr1", "208.67.222.222" },              /* Detect address 1 */
	{ "di_addr2", "14.17.42.40" },                 /* Detect address 2 */
	{ "di_addr3", "8.8.8.8" },                     /* Detect address 3 */
	{ "di_addr4", "8.8.4.4" },                     /* Detect address 4 */
	{ "di_addr5", "208.67.220.220" },              /* Detect address 5 */
	{ "di_port0", "53" },                          /* Detect port 0 */
	{ "di_port1", "53" },                          /* Detect port 1 */
	{ "di_port2", "80" },                          /* Detect port 2 */
	{ "di_port3", "53" },                          /* Detect port 3 */
	{ "di_port4", "53" },                          /* Detect port 4 */
	{ "di_port5", "53" },                          /* Detect port 5 */

	{ "fw_pt_pppoe", "0" },                        /* Firewall PPPoE passthrough */

#if defined(BOARD_ROLE_REPEATER)
	{ "sw_mode", "3" },                            /* Switch mode */
#else
	{ "sw_mode", "1" },                            /* Switch mode */
#endif

	{ "telnetd", "0" },                            /* Telnet */
	{ "sshd_enable", "1" },                        /* SSH enable */
	{ "wins_enable", "0" },                        /* WINS enable */
	{ "lltd_enable", "1" },                        /* LLTD enable */
	{ "crond_enable", "1" },                       /* Cron enable */
	{ "crond_log", "0" },                          /* Cron log */

#if defined(BOARD_N65U)
	{ "inic_disable", "0" },                       /* Disable INIC */
#endif

	{ "wol_mac_last", "" },                        /* Last WOL MAC */
	{ "gw_arp_ping", "0" },                        /* Gateway ARP ping */
	{ "ez_action_short", "0" },                    /* EZ button short press */
#if defined(BOARD_K2P)
	{ "ez_action_long", "15" },                    /* Reset */
#else
	{ "ez_action_long", "0" },                     /* EZ button long press */
#endif
	{ "fn1_action_short", "0" },                   /* FN1 short press */
	{ "fn1_action_long", "0" },                    /* FN1 long press */
	{ "fn2_action_short", "0" },                   /* FN2 short press */
	{ "fn2_action_long", "0" },                    /* FN2 long press */
	{ "watchdog_cpu", "1" },                       /* Watchdog CPU */
	{ "front_led_all", "1" },                      /* Front all LED */
	{ "front_led_wan", "2" },                      /* Front WAN LED */
	{ "front_led_lan", "2" },                      /* Front LAN LED */
	{ "front_led_wif", "1" },                      /* Front WiFi LED */
	{ "front_led_usb", "1" },                      /* Front USB LED */
	{ "front_led_pwr", "1" },                      /* Front power LED */

	{ "ether_igmp", "1" },                         /* Ethernet IGMP */
	{ "ether_uport", "0" },                        /* WAN port in AP mode is static upstream by default */
	{ "ether_m2u", "2" },                          /* Ethernet M2U */
	{ "ether_green", "1" },                        /* Ethernet green */
	{ "ether_eee", "0" },                          /* Ethernet EEE */
	{ "ether_jumbo", "1" },                        /* Ethernet jumbo */
#if (BOARD_NUM_ETH_LEDS > 1)
	{ "ether_led0", "3" },                         /* Ethernet LED 0 */
#else
	{ "ether_led0", "7" },                         /* Ethernet LED 0 */
#endif
	{ "ether_led1", "0" },                         /* Ethernet LED 1 */

	{ "ether_link_wan",  "0" },
	{ "ether_flow_wan",  "0" },
	{ "ether_link_lan1", "0" },                    /* LAN1 link */
	{ "ether_flow_lan1", "0" },                    /* LAN1 flow control */
	{ "ether_link_lan2", "0" },                    /* LAN2 link */
	{ "ether_flow_lan2", "0" },                    /* LAN2 flow control */
	{ "ether_link_lan3", "0" },                    /* LAN3 link */
	{ "ether_flow_lan3", "0" },                    /* LAN3 flow control */
	{ "ether_link_lan4", "0" },                    /* LAN4 link */
	{ "ether_flow_lan4", "0" },                    /* LAN4 flow control */
#if BOARD_NUM_ETH_EPHY > 5
	{ "ether_link_lan5", "0" },                    /* LAN5 link */
	{ "ether_flow_lan5", "0" },                    /* LAN5 flow control */
#if BOARD_NUM_ETH_EPHY > 6
	{ "ether_link_lan6", "0" },                    /* LAN6 link */
	{ "ether_flow_lan6", "0" },                    /* LAN6 flow control */
	{ "ether_link_lan7", "0" },                    /* LAN7 link */
	{ "ether_flow_lan7", "0" },                    /* LAN7 flow control */
#endif
#endif
	{ "hw_nat_mode", "1" },                        /* HW NAT mode */
	{ "sw_nat_mode", "0" },                        /* Switch NAT mode */
#if defined(USE_SFE)
	{ "sfe_enable", "2" },                         /* Software Offload Routing IPv4/IPv6 */
#endif
	{ "fw_syn_cook", "0" },                        /* Prevent SYN Flood Attack */
	{ "fw_mac_drop", "0" },                        /* Firewall MAC drop */
	{ "nf_nat_type", "1" },                        /* NAT type */
	{ "nf_nat_loop", "1" },                        /* NAT loopback */
#if (BOARD_RAM_SIZE > 128)
	{ "nf_max_conn", "32768" },                    /* Max conntrack */
#elif (BOARD_RAM_SIZE > 32)
	{ "nf_max_conn", "16384" },                    /* Max conntrack */
#else
	{ "nf_max_conn", "8192" },                     /* Max conntrack */
#endif
	{ "nf_alg_ftp0", "21" },                       /* FTP ALG 0 */
	{ "nf_alg_ftp1", "" },                         /* FTP ALG 1 */
	{ "nf_alg_pptp", "0" },                        /* PPTP ALG */
	{ "nf_alg_h323", "0" },                        /* H323 ALG */
	{ "nf_alg_sip", "0" },                         /* SIP ALG */

	{ "help_enable", "1" },                        /* Help enable */

	{ "vpns_enable", "0" },                        /* VPN server */
	{ "vpns_type", "0" },                          /* VPN server type */
	{ "vpns_cast", "0" },                          /* VPN server broadcast */
	{ "vpns_auth", "0" },                          /* VPN server auth */
	{ "vpns_mppe", "1" },                          /* VPN MPPE */
	{ "vpns_mtu", "1450" },                        /* VPN server MTU */
	{ "vpns_mru", "1450" },                        /* VPN server MRU */
	{ "vpns_vuse", "0" },                          /* VPN server virtual use */
	{ "vpns_vnet", "10.8.0.0" },                   /* VPN server virtual network */
	{ "vpns_actl", "0" },                          /* VPN server ACL */
	{ "vpns_cli0", "245" },                        /* VPN server client 0 */
	{ "vpns_cli1", "254" },                        /* VPN server client 1 */
	{ "vpns_num_x", "0" },                         /* VPN server client count */

	{ "vpnc_enable", "0" },                        /* VPN client */
	{ "vpnc_type", "0" },                          /* VPN client type */
	{ "vpnc_peer", "" },                           /* VPN client peer */
	{ "vpnc_user", "" },                           /* VPN client user */
	{ "vpnc_pass", "" },                           /* VPN client password */
	{ "vpnc_auth", "0" },                          /* VPN client auth */
	{ "vpnc_mppe", "0" },                          /* VPN client MPPE */
	{ "vpnc_pppd", "" },                           /* VPN client pppd */
	{ "vpnc_rnet", "" },                           /* VPN client route network */
	{ "vpnc_rmsk", "" },                           /* VPN client route mask */
	{ "vpnc_pdns", "0" },                          /* VPN push DNS */
	{ "vpnc_mtu", "1450" },                        /* VPN client MTU */
	{ "vpnc_mru", "1450" },                        /* VPN client MRU */
	{ "vpnc_sfw", "0" },                           /* VPN client firewall */
	{ "vpnc_dgw", "0" },                           /* VPN client default gateway */

	{ "vpns_ov_mode", "1" },                       /* VPN server OpenVPN mode */
	{ "vpns_ov_prot", "0" },                       /* VPN server OpenVPN protocol */
	{ "vpns_ov_port", "1194" },                    /* VPN server OpenVPN port */
	{ "vpns_ov_mdig", "1" },                       /* VPN server OpenVPN digest */
	{ "vpns_ov_ciph", "15" },                      /* VPN server OpenVPN cipher */
	{ "vpns_ov_ncp_clist", DEF_OVPNS_CIPH_LIST },
	{ "vpns_ov_compress", "2" },                   /* VPN server OpenVPN compress */
	{ "vpns_ov_atls", "0" },                       /* VPN server OpenVPN TLS */
	{ "vpns_ov_tcv2", "0" },                       /* VPN server OpenVPN TCP v2 */
	{ "vpns_ov_rdgw", "0" },                       /* VPN server OpenVPN redirect gateway */
	{ "vpnc_ov_mode", "1" },                       /* VPN client OpenVPN mode */
	{ "vpnc_ov_cnat", "0" },                       /* VPN client OpenVPN NAT */
	{ "vpnc_ov_prot", "0" },                       /* VPN client OpenVPN protocol */
	{ "vpnc_ov_port", "1194" },                    /* VPN client OpenVPN port */
	{ "vpnc_ov_auth", "0" },                       /* VPN client OpenVPN auth */
	{ "vpnc_ov_mdig", "1" },                       /* VPN client OpenVPN digest */
	{ "vpnc_ov_ciph", "15" },                      /* VPN client OpenVPN cipher */
	{ "vpnc_ov_ncp_clist", DEF_OVPNC_CIPH_LIST },
	{ "vpnc_ov_compress", "2" },                   /* VPN client OpenVPN compress */
	{ "vpnc_ov_atls", "0" },                       /* VPN client OpenVPN TLS */

#if defined(APP_XTU)
	/* xTun */
	{ "xTun_iface", "tun0" },                      /* xTun interface */
	{ "xTun_cidr", "10.0.1.2/24" },                /* xTun CIDR */
	{ "xTun_server", "server.me" },                /* xTun server */
	{ "xTun_port", "1082" },                       /* xTun port */
	{ "xTun_tcp", "0" },                           /* xTun TCP mode */
	{ "xTun_key", "password" },                    /* xTun key */

	{ "xTun_dns", "1.1.1.1" },                     /* xTun DNS */
	{ "xTun_black_list", "/etc/storage/xTun_black_list" }, /* xTun blacklist */
#endif

	{ 0, 0 }
};

struct nvram_pair tables_defaults[] = {

	{ "vts_port_x", "" },                          /* Virtual server port */
	{ "vts_ipaddr_x", "" },                        /* Virtual server IP */
	{ "vts_lport_x", "" },                         /* Virtual server local port */
	{ "vts_proto_x", "" },                         /* Virtual server protocol */
	{ "vts_protono_x", "" },                       /* Virtual server protocol number */
	{ "vts_srcip_x", "" },                         /* Virtual server src IP */
	{ "vts_desc_x", "" },                          /* Virtual server desc */

	{ "filter_lw_srcip_x", "" },                   /* Filter src IP */
	{ "filter_lw_srcport_x", "" },                 /* Filter src port */
	{ "filter_lw_dstip_x", "" },                   /* Filter dest IP */
	{ "filter_lw_dstport_x", "" },                 /* Filter dest port */
	{ "filter_lw_proto_x", "" },                   /* Filter protocol */
	{ "filter_lw_protono_x", "" },                 /* Filter protocol number */

	{ "macfilter_list_x", "" },                    /* MAC filter list */
	{ "macfilter_date_x", "" },                    /* MAC filter days */
	{ "macfilter_time_x", "" },                    /* MAC filter time */

	{ "url_keyword_x", "" },                       /* URL keyword */

	{ "acc_username", "" },                        /* ACC username */
	{ "acc_password", "" },                        /* ACC password */

	{ "sr_ipaddr_x", "" },                         /* Static route IP */
	{ "sr_netmask_x", "" },                        /* Static route mask */
	{ "sr_gateway_x", "" },                        /* Static route gateway */
	{ "sr_matric_x", "" },                         /* Static route metric */
	{ "sr_if_x", "" },                             /* Static route interface */
#if defined(APP_SHADOWSOCKS)
	{ "ssp_type_x", "" },                          /* SS proxy type */
	{ "ssp_name_x", "" },                          /* SS proxy name */
	{ "ssp_server_x", "" },                        /* SS proxy server */
	{ "ssp_prot_x", "" },                          /* SS proxy protocol */
	{ "switch_enable_x", "1" },                    /* Switch enable */
	{ "ss_key_x", "" },                            /* SS key x */
	{ "s5_username_x", "" },                       /* Socks5 username */
	{ "s5_password_x", "" },                       /* Socks5 password */
	{ "ss_method_x", "" },                         /* SS encryption x */
	{ "ss_protocol_x", "" },                       /* SS protocol x */
	{ "ss_proto_param_x", "" },                    /* SS protocol param x */
	{ "ss_obfs_x", "" },                           /* SS obfs x */
	{ "ss_obfs_param_x", "" },                     /* SS obfs param x */
	/* { "ssp_local_port_x", "" }, */
	{ "v2_aid_x", "" },                            /* V2Ray alterId x */
	{ "v2_vid_x", "" },                            /* V2Ray UUID x */
	{ "v2_security_x", "" },                       /* V2Ray security x */
	{ "v2_net_x", "" },                            /* V2Ray transport x */
	{ "v2_type_tcp_x", "none" },                   /* V2Ray TCP type x */
	{ "v2_type_mkcp_x", "none" },                  /* V2Ray mKCP type x */
	{ "v2_mkcp_mtu_x", "1350" },                   /* mKCP MTU (client) */
	{ "v2_mkcp_tti_x", "50" },                     /* mKCP TTI (client) */
	{ "v2_mkcp_uplink_x", "50" },                  /* V2Ray mKCP uplink x */
	{ "v2_mkcp_downlink_x", "20" },                /* V2Ray mKCP downlink x */
	{ "v2_mkcp_readbu_x", "2" },                   /* V2Ray mKCP read buffer x */
	{ "v2_mkcp_writebu_x", "2" },                  /* V2Ray mKCP write buffer x */
	{ "v2_mkcp_congestion_x", "0" },               /* V2Ray mKCP congestion x */
	{ "v2_webs_host_x", "" },                      /* V2Ray WebSocket host x */
	{ "v2_webs_path_x", "" },                      /* V2Ray WebSocket path x */
	{ "v2_http2_host_x", "" },                     /* V2Ray HTTP2 host x */
	{ "v2_http2_path_x", "" },                     /* V2Ray HTTP2 path x */
	{ "v2_tls_x", "0" },                           /* V2Ray TLS x */
#endif

#if defined(APP_SMARTDNS)
	{ "sdnss_enable_x", "" },                      /* SmartDNS server enable */
	{ "sdnss_name_x", "" },                        /* SmartDNS server name */
	{ "sdnss_ip_x", "" },                          /* SmartDNS server IP */
	{ "sdnss_port_x", "" },                        /* SmartDNS server port */
	{ "sdnss_type_x", "" },                        /* SmartDNS server type */
	{ "sdnss_ipc_x", "" },                         /* SmartDNS server IPC */
	{ "sdnss_named_x", "" },                       /* SmartDNS server named */
	{ "sdnss_ipset_x", "" },                       /* SmartDNS server IPset */
	{ "sdnss_non_x", "" },                         /* SmartDNS server non */
#endif

	{ "dhcp_staticmac_x", "" },                    /* DHCP static MAC */
	{ "dhcp_staticip_x", "" },                     /* DHCP static IP */
	{ "dhcp_staticname_x", "" },                   /* DHCP static name */

	{"pppoemwan_mac_x", "" },
	{"pppoemwan_ip_x", "" },
	{"pppoemwan_name_x", "" },
	{"pppoemwan_interface_x", "" },

	{"adbybyip_mac_x", "" },
	{"adbybyip_ip_x", "" },
	{"adbybyip_name_x", "" },
	{"adbybyip_ip_road_x", "" },

	{"adbybyrules_x", "" },
	{"adbybyrules_road_x", "" },

	{ "vpns_user_x", "" },                         /* VPN server user */
	{ "vpns_pass_x", "" },                         /* VPN server password */
	{ "vpns_addr_x", "" },                         /* VPN server address */
	{ "vpns_rnet_x", "" },                         /* VPN server route network */
	{ "vpns_rmsk_x", "" },                         /* VPN server route mask */

	{ 0, 0 }
};
