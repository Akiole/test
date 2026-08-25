#!/bin/sh
# 设置 LAN IP 和 DHCP 地址范围
# 用法: setip.sh <LAN_IP> <配置文件> <字典文件>

set -e

# 跨平台 sed -i（兼容 macOS BSD sed 和 Linux GNU sed）
sed_i() {
	if sed --version >/dev/null 2>&1; then
		sed -i "$@"
	else
		sed -i '' "$@"
	fi
}

if [ $# -lt 3 ]; then
	echo "用法: $0 <LAN_IP> <配置文件> <字典文件>" >&2
	exit 1
fi

lanip=$1
defaultfile=$2
dicfile=$3

# 简单的 IP 格式校验
if ! printf '%s' "$lanip" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
	echo "错误: IP 格式不正确: $lanip" >&2
	exit 1
fi

if [ ! -f "$defaultfile" ]; then
	echo "错误: 配置文件不存在: $defaultfile" >&2
	exit 1
fi

if [ ! -f "$dicfile" ]; then
	echo "错误: 字典文件不存在: $dicfile" >&2
	exit 1
fi

# 解析 IP 前三段，生成 DHCP 范围 (.100 - .244)
oc1=${lanip%%.*}
x=${lanip#*.*}
oc2=${x%%.*}
x=${x#*.*}
oc3=${x%%.*}
dhcpfrom="$oc1.$oc2.$oc3.100"
dhcpto="$oc1.$oc2.$oc3.244"

sed_i "s/\"192.168.2.1\"/\"$lanip\"/g" "$defaultfile"
sed_i "s/\"192.168.2.100\"/\"$dhcpfrom\"/g" "$defaultfile"
sed_i "s/\"192.168.2.244\"/\"$dhcpto\"/g" "$defaultfile"
sed_i "s/192.168.2.1/$lanip/g" "$dicfile"
