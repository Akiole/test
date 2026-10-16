/*
 * MAP (Multi-AP / EasyMesh) common definitions
 * Lightweight userspace daemon for config sync
 */

#ifndef _MAP_COMMON_H_
#define _MAP_COMMON_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>

/* UDP port for MAP config sync protocol */
#define MAP_PORT            1905

/* Message types */
#define MAP_MSG_REQ_CONFIG  0x01    /* Agent requests config */
#define MAP_MSG_RSP_CONFIG  0x02    /* Controller responds with config */
#define MAP_MSG_ACK         0x03    /* Agent acknowledges config applied */

/* Max message size */
#define MAP_MAX_MSG_SIZE    2048

/* Config fields */
#define MAP_SSID_MAX_LEN    32
#define MAP_PSK_MAX_LEN     64
#define MAP_AUTH_MAX_LEN    16

/* Message header */
typedef struct {
    unsigned char type;
    unsigned char reserved[3];
    unsigned int  length;
} map_msg_header_t;

/* Config response payload */
typedef struct {
    char ssid_2g[MAP_SSID_MAX_LEN];
    char psk_2g[MAP_PSK_MAX_LEN];
    char auth_2g[MAP_AUTH_MAX_LEN];
    char wpa_mode_2g[16];
    char crypto_2g[16];
    char channel_2g[16];
    char ssid_5g[MAP_SSID_MAX_LEN];
    char psk_5g[MAP_PSK_MAX_LEN];
    char auth_5g[MAP_AUTH_MAX_LEN];
    char wpa_mode_5g[16];
    char crypto_5g[16];
    char channel_5g[16];
} map_config_t;

/* NVRAM helper functions */
static inline int nvram_get(const char *key, char *value, int size)
{
    char cmd[256];
    FILE *fp;
    int ret = -1;

    snprintf(cmd, sizeof(cmd), "nvram get %s", key);
    fp = popen(cmd, "r");
    if (fp) {
        if (fgets(value, size, fp)) {
            /* Remove trailing newline */
            value[strcspn(value, "\n")] = '\0';
            ret = 0;
        }
        pclose(fp);
    }
    return ret;
}

static inline int nvram_set(const char *key, const char *value)
{
    char cmd[512];
    char safe_value[256];
    int i, j = 0;

    /* Escape chars special inside double quotes: " $ ` \ */
    for (i = 0; value[i] != '\0' && j < (int)sizeof(safe_value) - 1; i++) {
        char c = value[i];
        if (c == '"' || c == '$' || c == '`' || c == '\\') {
            if (j < (int)sizeof(safe_value) - 2) {
                safe_value[j++] = '\\';
                safe_value[j++] = c;
            }
        } else {
            safe_value[j++] = c;
        }
    }
    safe_value[j] = '\0';

    /* Double-quote the whole assignment so spaces in SSID/PSK survive shell parsing */
    snprintf(cmd, sizeof(cmd), "nvram set \"%s=%s\"", key, safe_value);
    return system(cmd);
}

static inline int nvram_commit(void)
{
    return system("nvram commit");
}

/* Check if interface is up and running */
static inline int if_is_running(const char *ifname)
{
    int sock;
    struct ifreq ifr;
    int ret = 0;

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0)
        return 0;

    memset(&ifr, 0, sizeof(ifr));
    strncpy(ifr.ifr_name, ifname, IFNAMSIZ - 1);

    if (ioctl(sock, SIOCGIFFLAGS, &ifr) == 0) {
        if (ifr.ifr_flags & IFF_RUNNING)
            ret = 1;
    }

    close(sock);
    return ret;
}

/* Get gateway IP for an interface by parsing /proc/net/route (no awk dependency) */
static inline int if_get_gateway(const char *ifname, char *gw, int size)
{
    FILE *fp;
    char line[256];
    char iface[16];
    unsigned long dest, gateway;
    int ret = -1;

    fp = fopen("/proc/net/route", "r");
    if (!fp)
        return -1;

    /* Skip header */
    if (fgets(line, sizeof(line), fp) == NULL) {
        fclose(fp);
        return -1;
    }

    while (fgets(line, sizeof(line), fp)) {
        /* Format: Iface Destination Gateway Flags RefCnt Use Metric Mask MTU Window IRTT */
        if (sscanf(line, "%15s %lx %lx", iface, &dest, &gateway) == 3) {
            /* Default route: dest = 0.0.0.0, interface matches */
            if (dest == 0 && strcmp(iface, ifname) == 0 && gateway != 0) {
                /* Convert from little-endian hex to dotted decimal */
                unsigned char *p = (unsigned char *)&gateway;
                snprintf(gw, size, "%d.%d.%d.%d", p[0], p[1], p[2], p[3]);
                ret = 0;
                break;
            }
        }
    }

    fclose(fp);
    return ret;
}

/* Daemonize process */
static inline void daemonize(void)
{
    pid_t pid;
    int i;

    pid = fork();
    if (pid < 0)
        exit(EXIT_FAILURE);
    if (pid > 0)
        exit(EXIT_SUCCESS);

    if (setsid() < 0)
        exit(EXIT_FAILURE);

    signal(SIGCHLD, SIG_IGN);
    signal(SIGHUP, SIG_IGN);

    pid = fork();
    if (pid < 0)
        exit(EXIT_FAILURE);
    if (pid > 0)
        exit(EXIT_SUCCESS);

    umask(0);
    chdir("/");

    for (i = sysconf(_SC_OPEN_MAX); i >= 0; i--)
        close(i);

    open("/dev/null", O_RDWR);
    dup(0);
    dup(0);
}

#endif /* _MAP_COMMON_H_ */
