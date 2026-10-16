/*
 * MAP Controller - config sync service
 * Listens for Agent config requests and responds with local wireless config
 */

#include "map_common.h"

#define LOG_TAG "map_controller"

static int running = 1;

static void sig_handler(int sig)
{
    (void)sig;
    running = 0;
}

/* Read local wireless config from nvram */
static void read_local_config(map_config_t *cfg)
{
    memset(cfg, 0, sizeof(*cfg));

    /* 2.4G config */
    nvram_get("rt_ssid", cfg->ssid_2g, sizeof(cfg->ssid_2g));
    nvram_get("rt_wpa_psk", cfg->psk_2g, sizeof(cfg->psk_2g));
    nvram_get("rt_auth_mode", cfg->auth_2g, sizeof(cfg->auth_2g));
    nvram_get("rt_wpa_mode", cfg->wpa_mode_2g, sizeof(cfg->wpa_mode_2g));
    nvram_get("rt_crypto", cfg->crypto_2g, sizeof(cfg->crypto_2g));
    nvram_get("rt_channel", cfg->channel_2g, sizeof(cfg->channel_2g));

    /* 5G config */
    nvram_get("wl_ssid", cfg->ssid_5g, sizeof(cfg->ssid_5g));
    nvram_get("wl_wpa_psk", cfg->psk_5g, sizeof(cfg->psk_5g));
    nvram_get("wl_auth_mode", cfg->auth_5g, sizeof(cfg->auth_5g));
    nvram_get("wl_wpa_mode", cfg->wpa_mode_5g, sizeof(cfg->wpa_mode_5g));
    nvram_get("wl_crypto", cfg->crypto_5g, sizeof(cfg->crypto_5g));
    nvram_get("wl_channel", cfg->channel_5g, sizeof(cfg->channel_5g));
}

/* Handle config request from Agent */
static void handle_config_request(int sock, struct sockaddr_in *client_addr)
{
    map_msg_header_t resp_hdr;
    map_config_t config;
    char buf[MAP_MAX_MSG_SIZE];
    int total_len;

    /* Read local config */
    read_local_config(&config);

    /* Build response */
    memset(&resp_hdr, 0, sizeof(resp_hdr));
    resp_hdr.type = MAP_MSG_RSP_CONFIG;
    resp_hdr.length = htonl(sizeof(config));

    memcpy(buf, &resp_hdr, sizeof(resp_hdr));
    memcpy(buf + sizeof(resp_hdr), &config, sizeof(config));
    total_len = sizeof(resp_hdr) + sizeof(config);

    /* Send response */
    sendto(sock, buf, total_len, 0,
           (struct sockaddr *)client_addr, sizeof(*client_addr));

    printf("[%s] Config sent to %s\n", LOG_TAG,
           inet_ntoa(client_addr->sin_addr));
}

int main(int argc, char *argv[])
{
    int sock;
    struct sockaddr_in server_addr;
    struct sockaddr_in client_addr;
    socklen_t client_len;
    char buf[MAP_MAX_MSG_SIZE];
    ssize_t recv_len;
    map_msg_header_t *hdr;
    char mesh_enable[8] = {0};
    char mesh_agent[8] = {0};
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

    /* Check if MAP is enabled and this is a Controller */
    nvram_get("mesh_enable", mesh_enable, sizeof(mesh_enable));
    nvram_get("mesh_agent", mesh_agent, sizeof(mesh_agent));

    if (strcmp(mesh_enable, "1") != 0) {
        printf("[%s] EasyMesh not enabled, exiting\n", LOG_TAG);
        return 0;
    }

    if (strcmp(mesh_agent, "1") == 0) {
        printf("[%s] Device is Agent, Controller service not needed\n", LOG_TAG);
        return 0;
    }

    /* Daemonize unless foreground mode */
    if (!foreground)
        daemonize();
    else
        setbuf(stdout, NULL);

    /* Setup signal handlers */
    signal(SIGTERM, sig_handler);
    signal(SIGINT, sig_handler);

    /* Create UDP socket */
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("socket");
        return -1;
    }

    /* Allow address reuse */
    int reuse = 1;
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));

    /* Bind to MAP port */
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_port = htons(MAP_PORT);

    if (bind(sock, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind");
        close(sock);
        return -1;
    }

    printf("[%s] Controller service started on port %d\n", LOG_TAG, MAP_PORT);

    /* Main loop */
    while (running) {
        client_len = sizeof(client_addr);
        recv_len = recvfrom(sock, buf, sizeof(buf), 0,
                             (struct sockaddr *)&client_addr, &client_len);

        if (recv_len < 0) {
            if (errno == EINTR)
                continue;
            perror("recvfrom");
            break;
        }

        if (recv_len < (ssize_t)sizeof(map_msg_header_t))
            continue;

        hdr = (map_msg_header_t *)buf;

        switch (hdr->type) {
        case MAP_MSG_REQ_CONFIG:
            printf("[%s] Config request from %s\n", LOG_TAG,
                   inet_ntoa(client_addr.sin_addr));
            handle_config_request(sock, &client_addr);
            break;

        case MAP_MSG_ACK:
            printf("[%s] Agent %s applied config successfully\n", LOG_TAG,
                   inet_ntoa(client_addr.sin_addr));
            break;

        default:
            break;
        }
    }

    close(sock);
    printf("[%s] Controller service stopped\n", LOG_TAG);
    return 0;
}
