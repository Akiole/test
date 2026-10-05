#!/bin/sh
# Padavan firmware configuration tool
# Network defaults (defaults.h + dict files) and .config plugin management.
#
# Commands: account ip wifi plugin nano oc all
# Cross-platform sed: set SED env (from host-tools.mk) or auto-detect.
#
# Usage:
#   custom.sh account  <account> <password> <config_file>
#   custom.sh ip       <lan_ip>  <config_file> <dict_file...>
#   custom.sh wifi     <2g_ssid> <2g_pwd> <5g_ssid> <5g_pwd> <config_file>
#   custom.sh plugin   <dot_config> <plugin_list>
#   custom.sh nano     <dot_config>
#   custom.sh oc       <dot_config> [oc_value]
#   custom.sh all      <account> <password> <lan_ip> <2g_ssid> <2g_pwd> \
#                      <5g_ssid> <5g_pwd> <config_file> <dict_file...>

set -e

# --- helpers ---

escape_sed() {
	printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

# In-place sed: SED env (host-tools.mk) > GNU sed (Linux) > BSD sed (macOS)
sed_i() {
	if [ -n "$SED" ]; then
		$SED "$@"
	elif sed --version >/dev/null 2>&1; then
		sed -i "$@"
	else
		sed -i '' "$@"
	fi
}

validate_ip() {
	ip=$1
	printf '%s' "$ip" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' || return 1
	oc1=${ip%%.*}; x=${ip#*.*}; oc2=${x%%.*}; x=${x#*.*}; oc3=${x%%.*}; oc4=${x#*.*}
	for octet in "$oc1" "$oc2" "$oc3" "$oc4"; do
		if [ "$octet" -gt 255 ] 2>/dev/null; then
			return 1
		fi
	done
	return 0
}

# Full-width to half-width punctuation (Chinese IME)
normalize() {
	printf '%s' "$1" | sed -e 's/，/,/g' -e 's/－/-/g'
}

# --- defaults.h helpers (macro-anchored) ---

get_macro() {
	grep "^#define $2 " "$1" 2>/dev/null | head -1 | sed "s/^#define $2[[:space:]]*//"
}

# Replace #define value; prints old -> new. Args: <file> <macro> <quoted_value>
set_macro() {
	old=$(get_macro "$1" "$2")
	if [ -z "$old" ]; then
		echo "  [SKIP] $2: not found" >&2
		return 1
	fi
	[ "$old" = "$3" ] && { echo "  [SKIP] $2: already $3"; return 0; }
	sed_i "s/^#define $2 .*/#define $2 $3/" "$1"
	echo "  [ OK ] $2: $old -> $3"
}

# --- .config helpers ---

is_blacklisted() {
	case "$1" in
		CONFIG_VENDOR|CONFIG_PRODUCT|CONFIG_FIRMWARE_PRODUCT_ID|CONFIG_LINUXDIR|\
		CONFIG_KERNEL_NO_COMPRESS|CONFIG_32M_REBOOT_FIXUP|\
		CONFIG_FIRMWARE_INCLUDE_SFE|CONFIG_FIRMWARE_INCLUDE_CURL|\
		CONFIG_FIRMWARE_ENABLE_EXT2|CONFIG_FIRMWARE_ENABLE_EXT3|\
		CONFIG_FIRMWARE_ENABLE_EXT4|CONFIG_FIRMWARE_ENABLE_XFS|\
		CONFIG_FIRMWARE_ENABLE_FAT|CONFIG_FIRMWARE_ENABLE_EXFAT|\
		CONFIG_FIRMWARE_ENABLE_FUSE|CONFIG_FIRMWARE_ENABLE_SWAP|\
		CONFIG_FIRMWARE_INCLUDE_DUMP1090|CONFIG_FIRMWARE_INCLUDE_RTL_SDR)
			return 0 ;;
		*) return 1 ;;
	esac
}

# Resolve short name to full CONFIG_ key by trying prefixes.
# Matches active, #CONFIG_X=, and "# CONFIG_X is not set" forms.
find_config_key() {
	for prefix in CONFIG_FIRMWARE_INCLUDE_ CONFIG_FIRMWARE_ENABLE_ CONFIG_; do
		candidate="${prefix}$1"
		if grep -qE "^#?[[:space:]]*${candidate}(=|[[:space:]]+is[[:space:]]+not[[:space:]]+set)" "$2" 2>/dev/null; then
			printf '%s' "$candidate"
			return 0
		fi
	done
	return 1
}

# Set CONFIG_KEY=value, handling active / commented / missing forms
set_config_value() {
	if grep -qE "^$2=" "$1"; then
		old=$(grep -E "^$2=" "$1" | head -1 | sed -E "s/^$2=//")
		[ "$old" = "$3" ] && { echo "  [SKIP] $2 already $3"; return 0; }
		sed_i "s/^$2=.*/$2=$3/" "$1"
		echo "  [ OK ] $2: $old -> $3"
	elif grep -qE "^#$2=" "$1"; then
		sed_i "s/^#$2=.*/$2=$3/" "$1"
		echo "  [ OK ] $2: (disabled) -> $3"
	elif grep -qE "^# $2 is not set" "$1"; then
		sed_i "s/^# $2 is not set.*/$2=$3/" "$1"
		echo "  [ OK ] $2: (not set) -> $3"
	else
		printf '%s=%s\n' "$2" "$3" >> "$1"
		echo "  [ OK ] $2: (not found) -> $3"
	fi
}

# --- commands ---

do_account() {
	[ $# -lt 3 ] && { echo "Usage: $0 account <account> <password> <config_file>" >&2; exit 1; }
	[ ! -f "$3" ] && { echo "[ERR] config file not found: $3" >&2; exit 1; }
	echo "== Account =="
	[ -n "$1" ] && set_macro "$3" "SYS_USER_ROOT" "\"$(escape_sed "$1")\""
	[ -n "$2" ] && set_macro "$3" "DEF_ROOT_PASSWORD" "\"$(escape_sed "$2")\""
	return 0
}

do_ip() {
	[ $# -lt 3 ] && { echo "Usage: $0 ip <lan_ip> <config_file> <dict_file...>" >&2; exit 1; }
	lanip=$1; defaultfile=$2; shift 2
	validate_ip "$lanip" || { echo "[ERR] invalid IP format: $lanip" >&2; exit 1; }
	[ ! -f "$defaultfile" ] && { echo "[ERR] config file not found: $defaultfile" >&2; exit 1; }

	oc1=${lanip%%.*}; x=${lanip#*.*}; oc2=${x%%.*}; x=${x#*.*}; oc3=${x%%.*}
	dhcpfrom="$oc1.$oc2.$oc3.100"; dhcpto="$oc1.$oc2.$oc3.244"

	echo "== LAN IP =="
	set_macro "$defaultfile" "DEF_LAN_ADDR" "\"$lanip\""
	set_macro "$defaultfile" "DEF_LAN_DHCP_BEG" "\"$dhcpfrom\""
	set_macro "$defaultfile" "DEF_LAN_DHCP_END" "\"$dhcpto\""

	for dicfile in "$@"; do
		[ ! -f "$dicfile" ] && { echo "[ERR] dict file not found: $dicfile" >&2; exit 1; }
		count=$(grep -c '192.168.2.1' "$dicfile" 2>/dev/null || echo 0)
		sed_i "s/192.168.2.1/$lanip/g" "$dicfile"
		echo "  [ OK ] $dicfile: replaced $count occurrence(s)"
	done
}

do_wifi() {
	[ $# -lt 5 ] && { echo "Usage: $0 wifi <2g_ssid> <2g_pwd> <5g_ssid> <5g_pwd> <config_file>" >&2; exit 1; }
	[ ! -f "$5" ] && { echo "[ERR] config file not found: $5" >&2; exit 1; }
	echo "== WiFi =="
	[ -n "$1" ] && set_macro "$5" "DEF_WLAN_2G_SSID" "\"$(escape_sed "$1")\""
	[ -n "$2" ] && set_macro "$5" "DEF_WLAN_2G_PSK" "\"$(escape_sed "$2")\""
	[ -n "$3" ] && set_macro "$5" "DEF_WLAN_5G_SSID" "\"$(escape_sed "$3")\""
	[ -n "$4" ] && set_macro "$5" "DEF_WLAN_5G_PSK" "\"$(escape_sed "$4")\""
	return 0
}

# plugin_list: comma-separated; "-name" means disable
do_plugin() {
	[ $# -lt 2 ] && { echo "Usage: $0 plugin <dot_config> <plugin_list>" >&2; exit 1; }
	[ ! -f "$1" ] && { echo "[ERR] config file not found: $1" >&2; exit 1; }
	configfile=$1; cleaned=$(normalize "$2")
	echo "== Plugins =="

	oldIFS=$IFS; IFS=','
	for item in $cleaned; do
		IFS=$oldIFS
		item=$(printf '%s' "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
		[ -z "$item" ] && continue
		if printf '%s' "$item" | grep -q '^-'; then
			action='n'; name=$(printf '%s' "$item" | sed 's/^-//' | tr '[:lower:]' '[:upper:]')
		else
			action='y'; name=$(printf '%s' "$item" | tr '[:lower:]' '[:upper:]')
		fi
		name=$(printf '%s' "$name" | sed 's/ //g')
		[ -z "$name" ] && continue
		full_key=$(find_config_key "$name" "$configfile") || true
		[ -z "$full_key" ] && { echo "  [SKIP] $name: not found"; continue; }
		is_blacklisted "$full_key" && { echo "  [LOCK] $name: blacklisted"; continue; }
		set_config_value "$configfile" "$full_key" "$action"
	done
	IFS=$oldIFS
}

do_nano() {
	[ $# -lt 1 ] && { echo "Usage: $0 nano <dot_config>" >&2; exit 1; }
	[ ! -f "$1" ] && { echo "[ERR] config file not found: $1" >&2; exit 1; }
	configfile=$1

	NANO_DISABLE="ANTFS FAT EXFAT EXT2 EXT3 EXT4 XFS FUSE SWAP \
UVC HID SERIAL AUDIO XFRM QOS IMQ IFB NFSD NFSC NATMAP \
CIFS NTFS_3G LPRD U2EC TCPDUMP HDPARM PARTED \
SMBD WINS SMBD_SYSLOG FTPD WEBDAV RPL2TP EAP_PEAP HTTPS \
SFTP DROPBEAR DROPBEAR_FAST_CODE OPENSSH TMUX OPENVPN SSWAN \
OPENSSL_EC OPENSSL_EXE XUPNPD MINIDLNA FIREFLY FFMPEG_NEW \
TRANSMISSION TRANSMISSION_WEB_CONTROL ARIA ARIA_WEB_CONTROL \
CURL SCUTCLIENT GDUT_DRCOM DOGCOM MINIEAP NJIT_CLIENT \
SOFTETHERVPN_SERVER SOFTETHERVPN_CLIENT SOFTETHERVPN_CMD N2N xTUN \
VLMCSD TTYD MSD_LITE LRZSZ HTOP NANO IPERF3 NEOFETCH JQ \
DUMP1090 RTL_SDR MTR SOCAT SRELAY MENTOHUST FAKEHTTP FAKESIP RTP2HTTPD \
FRPC FRPS REDSOCKS SHADOWSOCKS SSSERVER XRAY V2RAY TROJAN \
SSOBFS SINGBOX NAIVEPROXY MIHOMO MICROSOCKS 3PROXY WING ADBYBY DNSFORWARDER SMARTDNS \
ADGUARDHOME ZEROTIER ALIDDNS DDNSTO INADYN ALDRIVER SQM WIREGUARD"

	echo "== Nano mode =="
	disabled=0
	for name in $NANO_DISABLE; do
		full_key=$(find_config_key "$name" "$configfile") || true
		[ -z "$full_key" ] && continue
		is_blacklisted "$full_key" && continue
		grep -qE "^${full_key}=n" "$configfile" && continue
		set_config_value "$configfile" "$full_key" "n"
		disabled=$((disabled + 1))
	done
	echo "  [DONE] nano mode: $disabled item(s) disabled"
}

do_oc() {
	[ $# -lt 1 ] && { echo "Usage: $0 oc <dot_config> [oc_value]" >&2; exit 1; }
	[ ! -f "$1" ] && { echo "[ERR] config file not found: $1" >&2; exit 1; }
	echo "== Overclock =="
	set_config_value "$1" "CONFIG_FIRMWARE_INCLUDE_OC" "y"
	[ -n "$2" ] && set_config_value "$1" "CONFIG_FIRMWARE_MT7621_OC" "\"$2\""
	return 0
}

do_all() {
	[ $# -lt 9 ] && { echo "Usage: $0 all <account> <password> <lan_ip> <2g_ssid> <2g_pwd>" >&2; echo "            <5g_ssid> <5g_pwd> <config_file> <dict_file...>" >&2; exit 1; }
	account=$1; password=$2; lanip=$3; wifi_2g_ssid=$4; wifi_2g_pwd=$5
	wifi_5g_ssid=$6; wifi_5g_pwd=$7; defaultfile=$8; shift 8
	do_account "$account" "$password" "$defaultfile"
	do_ip "$lanip" "$defaultfile" "$@"
	do_wifi "$wifi_2g_ssid" "$wifi_2g_pwd" "$wifi_5g_ssid" "$wifi_5g_pwd" "$defaultfile"
	echo "== All network configurations applied =="
}

# --- main ---

[ $# -lt 1 ] && { echo "[ERR] missing command" >&2; exit 1; }
command=$1; shift

case "$command" in
	account|ip|wifi|plugin|nano|oc|all)
		"do_$command" "$@"
		;;
	*)
		echo "[ERR] unknown command '$command'" >&2
		exit 1
		;;
esac
