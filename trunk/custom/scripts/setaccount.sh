#!/bin/sh
# 设置管理员账号和密码
# 用法: setaccount.sh <账号> <密码> <配置文件>

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

if [ $# -lt 3 ]; then
	echo "用法: $0 <账号> <密码> <配置文件>" >&2
	exit 1
fi

account=$1
password=$2
defaultfile=$3

if [ ! -f "$defaultfile" ]; then
	echo "错误: 配置文件不存在: $defaultfile" >&2
	exit 1
fi

if [ -n "$account" ]; then
	sed_i "28s/\"admin\"/\"$(escape_sed "$account")\"/g" "$defaultfile"
fi
if [ -n "$password" ]; then
	sed_i "47s/\"admin\"/\"$(escape_sed "$password")\"/g" "$defaultfile"
fi
