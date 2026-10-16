/*
 * MAP Agent - config sync daemon
 * Monitors apcli connection, fetches config from Controller, applies locally
 */

#include "map_common.h"

#define LOG_TAG "map_agent"

/* MT7915 DBDC: ra0/apcli0 = 5GHz, rax0/apclix0 = 2.4GHz */
#define APCLI_IF_0        "apcli0"
#define APCLI_IF_1        "apclix0"
#define POLL_INTERVAL       3       /* seconds between connection checks */
#define CONFIG_TIMEOUT      5       /* seconds to wait for config response */
#define RECONNECT_DELAY     30      /* seconds before retry after disconnect */
#define WPS_TIMEOUT         120     /* WPS PBC timeout (2 minutes) */
#define WPS_RETRY_INTERVAL  300     /* retry WPS after 5 minutes if failed */
#define CONFIG_CHECK_INTERVAL 300   /* check for config updates every 5 min */

static int running = 1;
static time_t wps_trigger_time = 0;
static int wps_in_progress = 0;
static time_t last_config_check = 0;
static time_t wireless_restart_time = 0;

#define WIRELESS_RESTART_GRACE 60  /* suppress WPS trigger for 60s after wireless restart */

static void sig_handler(int sig)
{
    (void)sig;
    running = 0;
}

/* Check if apcli interface is actually associated (not just UP) */
static int apcli_is_associated(const char *ifname)
{
    char cmd[128];
    char buf[256];
    FILE *fp;
    int associated = 0;

    if (!if_is_running(ifname))
        return 0;

    snprintf(cmd, sizeof(cmd), "iwconfig %s 2>/dev/null | grep 'Access Point'", ifname);
    fp = popen(cmd, "r");
    if (fp) {
        if (fgets(buf, sizeof(buf), fp)) {
            /* "Not-Associated" means not connected; any MAC means associated */
            if (strstr(buf, "Not-Associated") == NULL &&
                strstr(buf, "00:00:00:00:00:00") == NULL) {
                associated = 1;
            }
        }
        pclose(fp);
    }
    return associated;
}

/* Check if connected via wireless backhaul (apcli) or wired (br0) */
static int is_connected(char *ifname, int ifname_size)
{
    /* Wireless backhaul: must be truly associated, not just UP */
    if (apcli_is_associated(APCLI_IF_0)) {
        snprintf(ifname, ifname_size, "%s", APCLI_IF_0);
        return 1;
    }
    if (apcli_is_associated(APCLI_IF_1)) {
        snprintf(ifname, ifname_size, "%s", APCLI_IF_1);
        return 1;
    }

    /* Wired via br0 (bridge has no IFF_RUNNING, check gateway directly) */
    char gw[64] = {0};
    if (if_get_gateway("br0", gw, sizeof(gw)) == 0 && strlen(gw) > 0) {
        snprintf(ifname, ifname_size, "%s", "br0");
        return 1;
    }
    return 0;
}

/* Request config from Controller via UDP */
static int request_config(const char *controller_ip, map_config_t *config)
{
    int sock;
    struct sockaddr_in server_addr;
    struct sockaddr_in recv_addr;
    socklen_t recv_len;
    map_msg_header_t req_hdr;
    char buf[MAP_MAX_MSG_SIZE];
    ssize_t recv_bytes;
    map_msg_header_t *resp_hdr;
    fd_set read_fds;
    struct timeval tv;
    int ret = -1;

    /* Create socket */
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("socket");
        return -1;
    }

    /* Set receive timeout */
    tv.tv_sec = CONFIG_TIMEOUT;
    tv.tv_usec = 0;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    /* Build request */
    memset(&req_hdr, 0, sizeof(req_hdr));
    req_hdr.type = MAP_MSG_REQ_CONFIG;
    req_hdr.length = 0;

    /* Send request */
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(MAP_PORT);
    if (inet_pton(AF_INET, controller_ip, &server_addr.sin_addr) != 1) {
        printf("[%s] Invalid Controller IP: %s\n", LOG_TAG, controller_ip);
        close(sock);
        return -1;
    }

    if (sendto(sock, &req_hdr, sizeof(req_hdr), 0,
               (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("sendto");
        close(sock);
        return -1;
    }

    printf("[%s] Config request sent to %s\n", LOG_TAG, controller_ip);

    /* Wait for response */
    FD_ZERO(&read_fds);
    FD_SET(sock, &read_fds);

    ret = select(sock + 1, &read_fds, NULL, NULL, &tv);
    if (ret <= 0) {
        printf("[%s] Config request timeout\n", LOG_TAG);
        close(sock);
        return -1;
    }

    recv_len = sizeof(recv_addr);
    recv_bytes = recvfrom(sock, buf, sizeof(buf), 0,
                           (struct sockaddr *)&recv_addr, &recv_len);

    if (recv_bytes < (ssize_t)sizeof(map_msg_header_t)) {
        printf("[%s] Invalid response size\n", LOG_TAG);
        close(sock);
        return -1;
    }

    resp_hdr = (map_msg_header_t *)buf;
    if (resp_hdr->type != MAP_MSG_RSP_CONFIG) {
        printf("[%s] Unexpected response type: %d\n", LOG_TAG, resp_hdr->type);
        close(sock);
        return -1;
    }

    if (ntohl(resp_hdr->length) != sizeof(map_config_t)) {
        printf("[%s] Invalid config length: %u\n", LOG_TAG, ntohl(resp_hdr->length));
        close(sock);
        return -1;
    }

    memcpy(config, buf + sizeof(map_msg_header_t), sizeof(map_config_t));
    close(sock);

    printf("[%s] Config received from %s\n", LOG_TAG, controller_ip);
    return 0;
}

/* Apply config to local wireless settings */
static int apply_config(const map_config_t *config)
{
    printf("[%s] Applying config...\n", LOG_TAG);
    printf("  2.4G SSID: %s\n", config->ssid_2g);
    printf("  5G  SSID: %s\n", config->ssid_5g);

    /* Apply 2.4G config */
    if (strlen(config->ssid_2g) > 0)
        nvram_set("rt_ssid", config->ssid_2g);
    if (strlen(config->psk_2g) > 0)
        nvram_set("rt_wpa_psk", config->psk_2g);
    if (strlen(config->auth_2g) > 0)
        nvram_set("rt_auth_mode", config->auth_2g);
    if (strlen(config->wpa_mode_2g) > 0)
        nvram_set("rt_wpa_mode", config->wpa_mode_2g);
    if (strlen(config->crypto_2g) > 0)
        nvram_set("rt_crypto", config->crypto_2g);
    if (strlen(config->channel_2g) > 0)
        nvram_set("rt_channel", config->channel_2g);

    /* Apply 5G config */
    if (strlen(config->ssid_5g) > 0)
        nvram_set("wl_ssid", config->ssid_5g);
    if (strlen(config->psk_5g) > 0)
        nvram_set("wl_wpa_psk", config->psk_5g);
    if (strlen(config->auth_5g) > 0)
        nvram_set("wl_auth_mode", config->auth_5g);
    if (strlen(config->wpa_mode_5g) > 0)
        nvram_set("wl_wpa_mode", config->wpa_mode_5g);
    if (strlen(config->crypto_5g) > 0)
        nvram_set("wl_crypto", config->crypto_5g);
    if (strlen(config->channel_5g) > 0)
        nvram_set("wl_channel", config->channel_5g);

    /* Switch to bridged mode (AP mode) */
    nvram_set("wan_route_x", "IP_Bridged");

    /* Commit to flash */
    nvram_commit();

    printf("[%s] Config applied and saved\n", LOG_TAG);
    return 0;
}

/* Send ACK to Controller */
static void send_ack(const char *controller_ip)
{
    int sock;
    struct sockaddr_in server_addr;
    map_msg_header_t ack_hdr;

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0)
        return;

    memset(&ack_hdr, 0, sizeof(ack_hdr));
    ack_hdr.type = MAP_MSG_ACK;
    ack_hdr.length = 0;

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(MAP_PORT);
    if (inet_pton(AF_INET, controller_ip, &server_addr.sin_addr) != 1) {
        close(sock);
        return;
    }

    sendto(sock, &ack_hdr, sizeof(ack_hdr), 0,
           (struct sockaddr *)&server_addr, sizeof(server_addr));

    close(sock);
}

/* Restart wireless to apply new config.
   Some builds lack /sbin/radio5_restart symlink; create temp one in /tmp. */
static void restart_wireless(void)
{
    printf("[%s] Restarting wireless...\n", LOG_TAG);
    wireless_restart_time = time(NULL);

    /* Ensure radio5_restart is available (some firmware builds omit the symlink) */
    system("test -x /sbin/radio5_restart || ln -sf /sbin/rc /tmp/radio5_restart");

    system("radio2_restart 2>/dev/null");
    sleep(2);
    system("radio5_restart 2>/dev/null || /tmp/radio5_restart 2>/dev/null");
    sleep(8);

    wireless_restart_time = time(NULL);
}

/* Trigger WPS PBC for EasyMesh pairing (both radios) */
static void trigger_wps_pbc(void)
{
    printf("[%s] Triggering WPS PBC for EasyMesh pairing...\n", LOG_TAG);

    /* 5GHz (ra0 on MT7915 DBDC) */
    system("/bin/iwpriv ra0 set WscMode=2 2>/dev/null");
    system("/bin/iwpriv ra0 set WscGetConf=1 2>/dev/null");

    /* 2.4GHz (rax0 on MT7915 DBDC) */
    system("/bin/iwpriv rax0 set WscMode=2 2>/dev/null");
    system("/bin/iwpriv rax0 set WscGetConf=1 2>/dev/null");

    wps_trigger_time = time(NULL);
    wps_in_progress = 1;
}

int main(int argc, char *argv[])
{
    char apcli_if[IFNAMSIZ] = {0};
    char controller_ip[64] = {0};
    char mesh_enable[8] = {0};
    char mesh_agent[8] = {0};
    map_config_t config;
    int was_connected = 0;
    int foreground = 0;
    int opt;

    /* Parse arguments */
    while ((opt = getopt(argc, argv, "f")) != -1) {
        switch (opt) {
        case 'f':
            foreground = 1;
            break;
        default:
            break;
        }
    }

    /* Check if MAP is enabled and this is an Agent */
    nvram_get("mesh_enable", mesh_enable, sizeof(mesh_enable));
    nvram_get("mesh_agent", mesh_agent, sizeof(mesh_agent));

    if (strcmp(mesh_enable, "1") != 0) {
        printf("[%s] EasyMesh not enabled, exiting\n", LOG_TAG);
        return 0;
    }

    if (strcmp(mesh_agent, "1") != 0) {
        printf("[%s] Device is Controller, Agent daemon not needed\n", LOG_TAG);
        return 0;
    }

    /* Daemonize unless foreground mode */
    if (!foreground)
        daemonize();
    else
        setbuf(stdout, NULL);  /* disable stdout buffering for foreground debug */

    /* Setup signal handlers */
    signal(SIGTERM, sig_handler);
    signal(SIGINT, sig_handler);

    printf("[%s] Agent daemon started\n", LOG_TAG);

    /* Main loop */
    while (running) {
        int connected = is_connected(apcli_if, sizeof(apcli_if));
        time_t now = time(NULL);

        if (connected && !was_connected) {
            /* New connection detected (wireless backhaul or wired) */
            printf("[%s] connected via %s\n", LOG_TAG, apcli_if);
            wps_in_progress = 0;

            /* Get Controller IP: bridge mode routes via br0 even for wireless backhaul */
            if (if_get_gateway(apcli_if, controller_ip, sizeof(controller_ip)) != 0)
                if_get_gateway("br0", controller_ip, sizeof(controller_ip));

            if (strlen(controller_ip) > 0) {

                /* Request config from Controller */
                if (request_config(controller_ip, &config) == 0) {
                    /* Apply config */
                    apply_config(&config);

                    /* Send ACK */
                    send_ack(controller_ip);

                    /* Restart wireless to apply */
                    printf("[%s] Config sync complete, restarting...\n",
                           LOG_TAG);
                    restart_wireless();

                    /* Keep was_connected=1 to avoid immediate re-sync loop.
                       Wireless backhaul will detect disconnect on next poll;
                       wired br0 stays up and goes to periodic check branch. */
                    was_connected = 1;
                    last_config_check = time(NULL);
                    sleep(RECONNECT_DELAY);
                    continue;
                } else {
                    printf("[%s] Failed to get config, retry later\n",
                           LOG_TAG);
                }
            } else {
                printf("[%s] Failed to get gateway IP\n", LOG_TAG);
            }
        } else if (!connected && was_connected) {
            /* Connection lost */
            printf("[%s] disconnected\n", LOG_TAG);
            was_connected = 0;
            wps_in_progress = 0;
        } else if (!connected) {
            /* Not connected: auto trigger WPS PBC (skip during wireless restart grace) */
            if (now - wireless_restart_time < WIRELESS_RESTART_GRACE) {
                /* wait for wireless to stabilize */
            } else if (wps_in_progress) {
                /* Check WPS timeout */
                if (now - wps_trigger_time > WPS_TIMEOUT) {
                    printf("[%s] WPS PBC timeout, retry in %d min\n",
                           LOG_TAG, WPS_RETRY_INTERVAL / 60);
                    wps_in_progress = 0;
                }
            } else {
                /* Trigger WPS if retry interval elapsed */
                if (wps_trigger_time == 0 ||
                    now - wps_trigger_time > WPS_RETRY_INTERVAL) {
                    trigger_wps_pbc();
                }
            }
        } else if (connected && was_connected) {
            /* Periodic config check while connected */
            if (now - last_config_check > CONFIG_CHECK_INTERVAL) {
                last_config_check = now;

                /* Get Controller IP: bridge mode routes via br0 even for wireless backhaul */
                if (if_get_gateway(apcli_if, controller_ip, sizeof(controller_ip)) != 0)
                    if_get_gateway("br0", controller_ip, sizeof(controller_ip));

                if (strlen(controller_ip) > 0) {
                    map_config_t new_config;
                    if (request_config(controller_ip, &new_config) == 0) {
                        /* Compare key fields (both 2.4G and 5G) to detect changes */
                        int changed = 0;
                        char cur_ssid_2g[64] = {0};
                        char cur_ssid_5g[64] = {0};
                        char cur_ch_2g[16] = {0};
                        char cur_ch_5g[16] = {0};

                        nvram_get("rt_ssid", cur_ssid_2g, sizeof(cur_ssid_2g));
                        nvram_get("wl_ssid", cur_ssid_5g, sizeof(cur_ssid_5g));
                        nvram_get("rt_channel", cur_ch_2g, sizeof(cur_ch_2g));
                        nvram_get("wl_channel", cur_ch_5g, sizeof(cur_ch_5g));

                        if (strcmp(cur_ssid_2g, new_config.ssid_2g) != 0 ||
                            strcmp(cur_ssid_5g, new_config.ssid_5g) != 0 ||
                            strcmp(cur_ch_2g, new_config.channel_2g) != 0 ||
                            strcmp(cur_ch_5g, new_config.channel_5g) != 0) {
                            changed = 1;
                        }

                        if (changed) {
                            printf("[%s] Config change detected, syncing...\n",
                                   LOG_TAG);
                            apply_config(&new_config);
                            send_ack(controller_ip);
                            restart_wireless();
                            was_connected = 1;
                            last_config_check = time(NULL);
                            sleep(RECONNECT_DELAY);
                            continue;
                        }
                    }
                }
            }
        }

        was_connected = connected;

        /* Sleep before next check */
        sleep(POLL_INTERVAL);
    }

    printf("[%s] Agent daemon stopped\n", LOG_TAG);
    return 0;
}
