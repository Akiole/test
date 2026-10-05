#!/bin/sh

set -e -o pipefail

NAME=chnroute
CHNROUTE_URL="$(nvram get ss_chnroute_url)"

log() {
	logger -t "$NAME" "$@"
	echo "$(date "+%Y-%m-%d %H:%M:%S") $@" >> "/tmp/ssrplus.log"
}

[ "$1" != "force" ] && [ "$(nvram get ss_update_chnroute)" != "1" ] && exit 0

log "CHNRoute 开始更新..."
mkdir -p /etc/storage/chinadns/
rm -f /tmp/chinadns_chnroute.txt

# 下载：优先使用用户配置的 URL（all_cn.txt 等现成 CIDR 列表）；未配置时回退到 APNIC
if [ -n "$CHNROUTE_URL" ]; then
	if ! curl -s -o /tmp/chinadns_chnroute.txt --connect-timeout 10 --retry 3 "$CHNROUTE_URL"; then
		log "CHNRoute 下载失败（$CHNROUTE_URL），保持现有列表。"
		rm -f /tmp/chinadns_chnroute.txt
		exit 1
	fi
else
	log "未配置 ss_chnroute_url，回退到 APNIC 官方列表..."
	if ! curl -s --connect-timeout 10 --retry 3 http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest | \
		awk -F'|' '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /tmp/chinadns_chnroute.txt; then
		log "APNIC 列表下载/解析失败，保持现有列表。"
		rm -f /tmp/chinadns_chnroute.txt
		exit 1
	fi
fi

# 校验下载内容：至少 100 行且为合法 CIDR/IP 行，否则不覆盖现有列表（防止错误页/空文件把 chnroute 冲掉导致规则失效）
row_count=$(grep -cE '^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$' /tmp/chinadns_chnroute.txt 2>/dev/null || echo 0)
if [ "$row_count" -lt 100 ]; then
	log "CHNRoute 内容校验失败（有效 CIDR 行数=$row_count），保持现有列表。"
	rm -f /tmp/chinadns_chnroute.txt
	exit 1
fi

mv -f /tmp/chinadns_chnroute.txt /etc/storage/chinadns/chnroute.txt
mtd_storage.sh save >/dev/null 2>&1
log "CHNRoute 更新完成（$row_count 条）！"

# 任意运行模式（gfw/router/oversea）下都需要重载 china ipset，否则更新不生效
if [ -f /usr/bin/shadowsocks.sh ] && [ "$(nvram get ss_enable)" = "1" ]; then
	log "正在重启 ShadowSocksR Plus 以加载新的 CHNRoute..."
	/usr/bin/shadowsocks.sh restart >/dev/null 2>&1
fi
