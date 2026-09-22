#!/bin/sh
# Padavan 跨 AP 无线客户端 RSSI + 主机名采集脚本
# 数据格式：var ap_wireless = {"MAC":{"rssi":-57,"name":"hostname"}}

AP_IPS=$(nvram get ap_slave_ips)
AP_USER=$(nvram get ap_slave_user)
AP_PASS=$(nvram get ap_slave_pass)
[ -z "$AP_USER" ] && AP_USER="admin"
[ -z "$AP_PASS" ] && AP_PASS="admin"
[ -z "$AP_IPS" ] && exit 0

CACHE_FILE="/tmp/ap_wireless.js"
BIND_TARGET="/www/ap_rssi.js"
RSSI_FILE="/tmp/ap_rssi_list.txt"
NAME_FILE="/tmp/ap_name_list.txt"
> "$RSSI_FILE"
> "$NAME_FILE"

for ip in $AP_IPS; do
    [ -z "$ip" ] && continue
    AUTH="Authorization: Basic $(echo -n "$AP_USER:$AP_PASS" | base64)"
    PAGE=$(wget --header="$AUTH" -qO- "http://$ip/lan_clients.asp" 2>/dev/null)
    # 重试一次：如果页面为空或不包含 ipmonitor_last
    if [ -z "$PAGE" ] || ! echo "$PAGE" | grep -q "ipmonitor_last"; then
        sleep 1
        PAGE=$(wget --header="$AUTH" -qO- "http://$ip/lan_clients.asp" 2>/dev/null)
    fi
    [ -z "$PAGE" ] && continue

    # 提取 wireless_last："MAC":rssi → 输出 "MAC rssi"
    echo "$PAGE" | grep -o 'wireless_last = {.*};' \
        | sed 's/wireless_last = {//;s/};.*//' \
        | tr ',' '\n' \
        | sed 's/^ *"//;s/":/ /' >> "$RSSI_FILE"

    # 提取 ipmonitor_last：用 awk 解析数组，输出 "MAC name"
    echo "$PAGE" | grep -o 'ipmonitor_last = \[.*\];' \
        | sed 's/ipmonitor_last = \[//;s/\];.*//' \
        | awk '{
            n = split($0, arr, /\], \[/);
            for(i=1; i<=n; i++) {
                gsub(/^\[|\]$/, "", arr[i]);
                split(arr[i], f, /,/);
                mac = f[2]; name = f[3];
                gsub(/^ *"|" *$/, "", mac);
                gsub(/^ *"|" *$/, "", name);
                gsub(/^ +| +$/, "", name);
                gsub(/\.lan$/, "", name);
                if(name != "" && name != "null") print mac" "name;
            }
        }' >> "$NAME_FILE"
done

# 去重
sort -u "$RSSI_FILE" -o "$RSSI_FILE" 2>/dev/null
sort -u -k1,1 "$NAME_FILE" -o "$NAME_FILE" 2>/dev/null

# 合并输出 JSON
printf 'var ap_wireless = {' > "$CACHE_FILE"
first=1
while read mac rssi; do
    [ -z "$mac" ] && continue
    name=$(grep -i "^$mac " "$NAME_FILE" 2>/dev/null | head -1 | cut -d' ' -f2-)
    [ $first -eq 1 ] && first=0 || printf ', ' >> "$CACHE_FILE"
    printf '"%s":{"rssi":%s,"name":"%s"}' "$mac" "$rssi" "${name:-}" >> "$CACHE_FILE"
done < "$RSSI_FILE"
printf '};\n' >> "$CACHE_FILE"

rm -f "$RSSI_FILE" "$NAME_FILE"

if ! mount | grep -q "$BIND_TARGET"; then
    mount --bind "$CACHE_FILE" "$BIND_TARGET" 2>/dev/null
fi
