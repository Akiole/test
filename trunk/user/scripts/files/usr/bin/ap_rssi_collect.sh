#!/bin/sh
# Padavan 跨 AP 无线客户端信息采集脚本
# 数据格式：var ap_wireless = {"MAC":{"rssi":0,"name":"hostname","band":"5G"}}
# 注意：lan_clients.asp 包含 ipmonitor_last（客户端列表）和 wireless_band_last（频段映射），
#       无 wireless_last（RSSI），所以 RSSI 统一设为 0，采集 MAC、主机名和频段。

AP_IPS=$(nvram get ap_slave_ips | tr ',' ' ')
AP_USER=$(nvram get ap_slave_user)
AP_PASS=$(nvram get ap_slave_pass)
[ -z "$AP_USER" ] && AP_USER="admin"
[ -z "$AP_PASS" ] && AP_PASS="admin"
[ -z "$AP_IPS" ] && exit 0

CACHE_FILE="/tmp/ap_wireless.js"
BIND_TARGET="/www/ap_rssi.js"
CLIENT_FILE="/tmp/ap_client_list.txt"
BAND_FILE="/tmp/ap_band_list.txt"
> "$CLIENT_FILE"
> "$BAND_FILE"

for ip in $AP_IPS; do
    [ -z "$ip" ] && continue
    AUTH="Authorization: Basic $(echo -n "$AP_USER:$AP_PASS" | base64 | tr -d '\n')"
    PAGE=$(wget --header="$AUTH" -qO- "http://$ip/lan_clients.asp" 2>/dev/null)
    # 重试一次
    if [ -z "$PAGE" ] || ! echo "$PAGE" | grep -q "ipmonitor_last"; then
        sleep 1
        PAGE=$(wget --header="$AUTH" -qO- "http://$ip/lan_clients.asp" 2>/dev/null)
    fi
    [ -z "$PAGE" ] && continue

    # 提取 ipmonitor_last：解析数组 [IP, MAC, name, ...]，输出 "MAC name"
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
                if(name == "null") name="";
                if(mac != "" && mac != "null") print mac" "name;
            }
        }' >> "$CLIENT_FILE"

    # 提取 wireless_band_last：解析 {"MAC":"5G", ...}，输出 "MAC band"（统一大写）
    # 注意：MAC 本身含冒号，需按条目拆分后取最后一个冒号作为 MAC/band 分隔
    echo "$PAGE" | grep -o 'wireless_band_last = {.*};' \
        | sed 's/wireless_band_last = {//;s/};.*//' \
        | sed 's/", */"\n"/g' \
        | awk '{
            gsub(/"/, "", $0);
            gsub(/^ +| +$/, "", $0);
            if ($0 == "") next;
            # 找最后一个冒号位置，前面是 MAC，后面是 band
            idx = 0;
            for(i=1; i<=length($0); i++) if(substr($0,i,1)==":") idx=i;
            if(idx == 0) next;
            mac = substr($0, 1, idx-1);
            band = substr($0, idx+1);
            if(mac != "" && band != "") print toupper(mac)" "band;
        }' >> "$BAND_FILE"
done

# 按 MAC 去重，同一 MAC 优先保留有 name 的条目
sort -k1,1 "$CLIENT_FILE" | awk '
{
    mac = $1; name = $2;
    if (mac != prev_mac) {
        if (prev_mac != "") print prev_mac" "prev_name;
        prev_mac = mac; prev_name = name;
    } else if (prev_name == "" && name != "") {
        prev_name = name;
    }
}
END { if (prev_mac != "") print prev_mac" "prev_name; }
' > "${CLIENT_FILE}.tmp" 2>/dev/null && mv "${CLIENT_FILE}.tmp" "$CLIENT_FILE"

# 合并输出 JSON，rssi 统一设为 0，band 从映射表查找（大小写不敏感匹配）
printf 'var ap_wireless = {' > "$CACHE_FILE"
first=1
while read mac name; do
    [ -z "$mac" ] && continue
    band=$(awk -v m="$(echo "$mac" | tr 'a-z' 'A-Z')" '
        { if (toupper($1) == m) { print $2; found=1; exit } }
        END { if (!found) print "" }
    ' "$BAND_FILE")
    [ $first -eq 1 ] && first=0 || printf ', ' >> "$CACHE_FILE"
    if [ -n "$band" ]; then
        printf '"%s":{"rssi":0,"name":"%s","band":"%s"}' "$mac" "${name:-}" "$band" >> "$CACHE_FILE"
    else
        printf '"%s":{"rssi":0,"name":"%s"}' "$mac" "${name:-}" >> "$CACHE_FILE"
    fi
done < "$CLIENT_FILE"
printf '};\n' >> "$CACHE_FILE"

rm -f "$CLIENT_FILE" "$BAND_FILE"

if ! mount | grep -q "$BIND_TARGET"; then
    mount --bind "$CACHE_FILE" "$BIND_TARGET" 2>/dev/null
fi
