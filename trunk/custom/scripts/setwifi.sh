#!/bin/sh
# 设置 WiFi SSID 和密码
# 用法: setwifi.sh <2G_SSID> <2G密码> <5G_SSID> <5G密码> <配置文件>

set -e

# 转义 sed 替换字符串中的特殊字符 (/ & \)
escape_sed() {
	printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

# 跨平台 sed -i（兼容 macOS BSD sed 和 Linux GNU sed）
sed_i() {
	if sed --version >/dev/null 2>&1; then
		sed -i "$@"
	else
		sed -i '' "$@"
	fi
}

if [ $# -lt 5 ]; then
	echo "用法: $0 <2G_SSID> <2G密码> <5G_SSID> <5G密码> <配置文件>" >&2
	exit 1
fi

wifi_2g_ssid=$1
wifi_2g_pwd=$2
wifi_5g_ssid=$3
wifi_5g_pwd=$4
defaultfile=$5

if [ ! -f "$defaultfile" ]; then
	echo "错误: 配置文件不存在: $defaultfile" >&2
	exit 1
fi

if [ -n "$wifi_2g_ssid" ]; then
	sed_i "40s/BOARD_PID \"_%s\"/\"$(escape_sed "$wifi_2g_ssid")\"/g" "$defaultfile"
fi
if [ -n "$wifi_2g_pwd" ]; then
	sed_i "44s/\"1234567890\"/\"$(escape_sed "$wifi_2g_pwd")\"/g" "$defaultfile"
fi
if [ -n "$wifi_5g_ssid" ]; then
	sed_i "41s/BOARD_PID \"_5G_%s\"/\"$(escape_sed "$wifi_5g_ssid")\"/g" "$defaultfile"
fi
if [ -n "$wifi_5g_pwd" ]; then
	sed_i "45s/\"1234567890\"/\"$(escape_sed "$wifi_5g_pwd")\"/g" "$defaultfile"
fi
