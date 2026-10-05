#!/bin/sh

set -e -o pipefail

NAME=shadowsocksr
GFWLIST_URL="$(nvram get ss_gfwlist_url)"

log() {
	logger -t "$NAME" "$@"
	echo "$(date "+%Y-%m-%d %H:%M:%S") $@" >> "/tmp/ssrplus.log"
}

[ "$1" != "force" ] && [ "$(nvram get ss_update_gfwlist)" != "1" ] && exit 0

log "GFWList 开始更新..."
[ ! -d /etc/storage/gfwlist/ ] && mkdir -p /etc/storage/gfwlist/

if [ -z "$GFWLIST_URL" ]; then
	log "ss_gfwlist_url 未配置，跳过更新。"
	exit 1
fi

if ! curl -s -o /tmp/gfwlist_list_origin.conf --connect-timeout 10 --retry 3 "$GFWLIST_URL"; then
	log "GFWList 下载失败（$GFWLIST_URL），保持现有列表。"
	rm -f /tmp/gfwlist_list_origin.conf
	exit 1
fi

lua /etc_ro/ss/gfwupdate.lua || { log "GFWList 解析失败,请重试！"; rm -f /tmp/gfwlist_list_origin.conf /tmp/gfwlist_list.conf; exit 1; }

count=$(wc -l < /tmp/gfwlist_list.conf 2>/dev/null || echo 0)
if [ "${count:-0}" -gt 1000 ]; then
    rm -f /etc/storage/gfwlist/gfwlist_list.conf
    mv -f /tmp/gfwlist_list.conf /etc/storage/gfwlist/gfwlist_list.conf
	mtd_storage.sh save >/dev/null 2>&1
	log "GFWList 更新完成（$count 行）！"
	if [ "$(nvram get ss_enable)" = "1" ]; then
		# 重新生成 dnsmasq 分流配置并重启，避免使用 /tmp 下的旧缓存
		mkdir -p /tmp/dnsmasq.dom
		lua /etc_ro/ss/gfwcreate.lua
		log "正在重启 ShadowSocksR Plus..."
		/usr/bin/shadowsocks.sh stop
		/usr/bin/shadowsocks.sh start
	fi
else
	log "GFWList 内容校验失败（仅 $count 行），保持现有列表。"
fi
rm -f /tmp/gfwlist_list_origin.conf
rm -f /tmp/gfwlist_list.conf
