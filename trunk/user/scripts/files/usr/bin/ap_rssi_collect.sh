#!/bin/sh
# Padavan 跨 AP 无线客户端 RSSI 采集脚本
# 从其他 Padavan AP 采集无线客户端列表，合并写入 /www/ap_rssi.js
# 前端 device-map/clients.asp 动态加载此文件显示跨 AP RSSI
# 用法: /etc/storage/ap_rssi_collect.sh
# 定时: cru a ap_rssi "* * * * * /etc/storage/ap_rssi_collect.sh"

# 从 nvram 读取配置
AP_IPS=$(nvram get ap_slave_ips)
AP_USER=$(nvram get ap_slave_user)
AP_PASS=$(nvram get ap_slave_pass)

# 默认值
[ -z "$AP_USER" ] && AP_USER="admin"
[ -z "$AP_PASS" ] && AP_PASS="admin"

# 没有配置 AP 列表就退出
[ -z "$AP_IPS" ] && exit 0

TMP_FILE="/tmp/ap_wireless_tmp.js"
CACHE_FILE="/tmp/ap_wireless.js"
BIND_TARGET="/www/ap_rssi.js"

# 开始输出
printf 'var ap_wireless = {' > "$TMP_FILE"

first=1
for ip in $AP_IPS; do
    [ -z "$ip" ] && continue

    # 请求 AP 的 lan_clients.asp（用 Basic Auth header，BusyBox wget 不支持 --http-user）
    AUTH_HEADER="Authorization: Basic $(echo -n "$AP_USER:$AP_PASS" | base64)"
    data=$(wget --header="$AUTH_HEADER" -qO- "http://$ip/lan_clients.asp" 2>/dev/null | grep -o 'wireless_last = {.*};' | sed 's/wireless_last = {//;s/};.*//')

    if [ -n "$data" ]; then
        if [ $first -eq 1 ]; then
            first=0
        else
            printf ', ' >> "$TMP_FILE"
        fi
        printf '%s' "$data" >> "$TMP_FILE"
    fi
done

printf '};\n' >> "$TMP_FILE"

# 覆盖缓存文件（用 cat 覆盖而非 mv，保持 inode 不变，使 mount --bind 能看到更新）
cat "$TMP_FILE" > "$CACHE_FILE"
rm -f "$TMP_FILE"

# /www 是只读 squashfs，用 mount --bind 把缓存文件覆盖到 /www/ap_rssi.js
if ! mount | grep -q "$BIND_TARGET"; then
    mount --bind "$CACHE_FILE" "$BIND_TARGET" 2>/dev/null
fi
