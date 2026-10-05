#!/bin/sh
# ============================================================
#  mihomo control script (Padavan)
#  Usage: mihomo.sh {start|stop|restart|update_geo|status}
#  nvram parameters:
#    mihomo_enable       enable switch 0/1
#    mihomo_mode         mode 1=tproxy 0=redirect 2=tun
#    mihomo_type         protocol ss/vmess/vless/trojan/hysteria2
#    mihomo_server       server address
#    mihomo_server_port  server port
#    mihomo_uuid         UUID (vmess/vless)
#    mihomo_password     password (ss/trojan/hysteria2)
#    mihomo_method       encryption method (ss)
#    mihomo_tls          enable TLS 0/1 (vless/trojan/hysteria2)
#    mihomo_sni          SNI/ServerName
#    mihomo_transport    transport tcp/ws/grpc (vmess/vless)
#    mihomo_ws_path      WS path
#    mihomo_local_port   local mixed port (socks+http)
#    mihomo_route_mode   route 1=rule 0=global 2=direct
#    mihomo_dns_hijack   DNS hijack 0/1
#    mihomo_api_port     Clash API port, 0=disabled
#    mihomo_log_level    log level
#    mihomo_geoip_url    GeoIP mmdb download URL
#    mihomo_geosite_url  GeoSite dat download URL
#    mihomo_sub_url      subscription URL (empty = manual server config)
#    mihomo_sub_node     selected subscription node tag (default node1)
# ============================================================

MH_BIN=/usr/bin/mihomo
MH_CONFIG_DIR=/etc/storage/mihomo
MH_TMP_DIR=/tmp/mihomo
MH_CONFIG=$MH_CONFIG_DIR/config.yaml
MH_SUB_DIR=$MH_CONFIG_DIR/sub
MH_SUB_NODES=$MH_CONFIG_DIR/sub_nodes.txt
MH_LOG=/tmp/mihomo.log
MH_PID=/tmp/mihomo.pid
MH_MARK=0x1

logger -t "mihomo" "mihomo.sh called: $1"

[ -x "$MH_BIN" ] || { logger -t "mihomo" "mihomo binary not found"; exit 1; }

mkdir -p "$MH_CONFIG_DIR" "$MH_TMP_DIR" "$MH_SUB_DIR"

yaml_escape() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g'
}

# decode common URL percent-escapes (enough for sub links)
url_decode() {
    echo "$1" | sed 's/%2F/\//g; s/%2f/\//g; s/%3A/:/g; s/%3a/:/g; s/%40/@/g; s/%3D/=/g; s/%3d/=/g; s/%26/\&/g; s/%3F/?/g; s/%3f/?/g; s/%23/#/g; s/%25/%/g'
}

# base64 decode with padding fixup
b64_decode() {
    local s="$1"
    case $((${#s} % 4)) in
        1) s="${s%?}" ;;
        2) s="${s}==" ;;
        3) s="${s}=" ;;
    esac
    echo "$s" | base64 -d 2>/dev/null
}

# extract JSON string field (single-line JSON)
json_field() {
    echo "$1" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}

get_conf() {
    nvram get "$1"
}

# ---------------- flush rules and processes ----------------
stop() {
    if [ -f "$MH_PID" ]; then
        kill -9 "$(cat $MH_PID)" 2>/dev/null
        rm -f "$MH_PID"
    fi
    killall -9 mihomo 2>/dev/null

    # tproxy (mangle)
    iptables -t mangle -F MIHOMO 2>/dev/null
    iptables -t mangle -D PREROUTING -j MIHOMO 2>/dev/null
    iptables -t mangle -X MIHOMO 2>/dev/null
    iptables -t mangle -F MIHOMO_MARK 2>/dev/null
    iptables -t mangle -D OUTPUT -j MIHOMO_MARK 2>/dev/null
    iptables -t mangle -X MIHOMO_MARK 2>/dev/null
    # redirect / dns (nat)
    iptables -t nat -F MIHOMO 2>/dev/null
    iptables -t nat -D PREROUTING -j MIHOMO 2>/dev/null
    iptables -t nat -D OUTPUT -j MIHOMO 2>/dev/null
    iptables -t nat -X MIHOMO 2>/dev/null
    iptables -t nat -F MIHOMO_DNS 2>/dev/null
    iptables -t nat -D PREROUTING -j MIHOMO_DNS 2>/dev/null
    iptables -t nat -D OUTPUT -j MIHOMO_DNS 2>/dev/null
    iptables -t nat -X MIHOMO_DNS 2>/dev/null
    # policy routing
    ip rule del fwmark $MH_MARK lookup 100 2>/dev/null
    ip route del local 0.0.0.0/0 dev lo table 100 2>/dev/null

    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    return 0
}

# ---------------- private/reserved address rules ----------------
priv_rules() {
    iptables -t "$1" -A "$2" -d 0.0.0.0/8 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 10.0.0.0/8 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 100.64.0.0/10 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 127.0.0.0/8 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 169.254.0.0/16 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 172.16.0.0/12 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 192.0.0.0/24 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 192.0.2.0/24 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 192.168.0.0/16 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 198.18.0.0/15 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 198.51.100.0/24 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 203.0.113.0/24 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 224.0.0.0/4 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 240.0.0.0/4 -j RETURN 2>/dev/null
    iptables -t "$1" -A "$2" -d 255.255.255.255/32 -j RETURN 2>/dev/null
}

# ---------------- firewall rules ----------------
setup_firewall() {
    MODE="$1"
    LOCAL_PORT="$2"
    DNS_HIJACK="$3"
    MH_REDIR_PORT=$((LOCAL_PORT + 1))
    MH_TPROXY_PORT=$((LOCAL_PORT + 2))

    if [ "$MODE" = "1" ]; then
        # ============ TPROXY ============
        modprobe -q xt_TPROXY 2>/dev/null
        iptables -t mangle -N MIHOMO 2>/dev/null
        priv_rules mangle MIHOMO
        if [ "$DNS_HIJACK" != "1" ]; then
            iptables -t mangle -A MIHOMO -p tcp --dport 53 -j RETURN 2>/dev/null
            iptables -t mangle -A MIHOMO -p udp --dport 53 -j RETURN 2>/dev/null
        fi
        iptables -t mangle -A MIHOMO -p tcp -j TPROXY --on-port "$MH_TPROXY_PORT" --tproxy-mark $MH_MARK/1 2>/dev/null
        iptables -t mangle -A MIHOMO -p udp -j TPROXY --on-port "$MH_TPROXY_PORT" --tproxy-mark $MH_MARK/1 2>/dev/null
        iptables -t mangle -I PREROUTING 1 -j MIHOMO 2>/dev/null

        # local traffic
        iptables -t mangle -N MIHOMO_MARK 2>/dev/null
        priv_rules mangle MIHOMO_MARK
        if [ "$DNS_HIJACK" != "1" ]; then
            iptables -t mangle -A MIHOMO_MARK -p tcp --dport 53 -j RETURN 2>/dev/null
            iptables -t mangle -A MIHOMO_MARK -p udp --dport 53 -j RETURN 2>/dev/null
        fi
        iptables -t mangle -A MIHOMO_MARK -p tcp -j MARK --set-mark $MH_MARK/1 2>/dev/null
        iptables -t mangle -A MIHOMO_MARK -p udp -j MARK --set-mark $MH_MARK/1 2>/dev/null
        iptables -t mangle -I OUTPUT 1 -j MIHOMO_MARK 2>/dev/null

        ip rule add fwmark $MH_MARK lookup 100 2>/dev/null
        ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null
    elif [ "$MODE" = "0" ]; then
        # ============ REDIRECT (TCP only) ============
        iptables -t nat -N MIHOMO 2>/dev/null
        priv_rules nat MIHOMO
        if [ "$DNS_HIJACK" = "1" ]; then
            iptables -t nat -A MIHOMO -p tcp --dport 53 -j REDIRECT --to-ports "$LOCAL_PORT" 2>/dev/null
            iptables -t nat -A MIHOMO -p udp --dport 53 -j REDIRECT --to-ports "$LOCAL_PORT" 2>/dev/null
        fi
        iptables -t nat -A MIHOMO -p tcp -j REDIRECT --to-ports "$MH_REDIR_PORT" 2>/dev/null
        iptables -t nat -I PREROUTING 1 -j MIHOMO 2>/dev/null
        iptables -t nat -I OUTPUT 1 -j MIHOMO 2>/dev/null
    fi

    return 0
}

# ---------------- generate proxy yaml block ----------------
gen_proxy_yaml() {
    TYPE="$1"
    NAME="$2"
    SERVER=$(yaml_escape "$3")
    PORT="$4"
    UUID=$(yaml_escape "$5")
    PASSWORD=$(yaml_escape "$6")
    METHOD=$(yaml_escape "$7")
    TLS="$8"
    SNI=$(yaml_escape "$9")
    TRANSPORT="$10"
    WS_PATH=$(yaml_escape "$11")

    case "$TYPE" in
        ss|shadowsocks)
            cat <<EOF
  - name: "$NAME"
    type: ss
    server: "$SERVER"
    port: $PORT
    cipher: "$METHOD"
    password: "$PASSWORD"
EOF
            ;;
        vmess)
            cat <<EOF
  - name: "$NAME"
    type: vmess
    server: "$SERVER"
    port: $PORT
    uuid: "$UUID"
    alterId: 0
    cipher: auto
EOF
            if [ "$TRANSPORT" = "ws" ]; then
                cat <<EOF
    network: ws
    ws-opts:
      path: "$WS_PATH"
EOF
            elif [ "$TRANSPORT" = "grpc" ]; then
                cat <<EOF
    network: grpc
EOF
            fi
            ;;
        vless)
            cat <<EOF
  - name: "$NAME"
    type: vless
    server: "$SERVER"
    port: $PORT
    uuid: "$UUID"
    network: tcp
EOF
            if [ "$TLS" = "1" ]; then
                cat <<EOF
    tls: true
    servername: "$SNI"
EOF
            fi
            if [ "$TRANSPORT" = "ws" ]; then
                cat <<EOF
    network: ws
    ws-opts:
      path: "$WS_PATH"
EOF
            elif [ "$TRANSPORT" = "grpc" ]; then
                cat <<EOF
    network: grpc
EOF
            fi
            ;;
        trojan)
            cat <<EOF
  - name: "$NAME"
    type: trojan
    server: "$SERVER"
    port: $PORT
    password: "$PASSWORD"
EOF
            if [ "$TLS" = "1" ]; then
                cat <<EOF
    sni: "$SNI"
EOF
            fi
            ;;
        hysteria2)
            cat <<EOF
  - name: "$NAME"
    type: hysteria2
    server: "$SERVER"
    port: $PORT
    password: "$PASSWORD"
    sni: "$SNI"
EOF
            ;;
    esac
}

# ---------------- generate config ----------------
gen_config() {
    MODE=$(get_conf mihomo_mode)
    TYPE=$(get_conf mihomo_type)
    SERVER=$(get_conf mihomo_server)
    PORT=$(get_conf mihomo_server_port)
    UUID=$(get_conf mihomo_uuid)
    PASSWORD=$(get_conf mihomo_password)
    METHOD=$(get_conf mihomo_method)
    TLS=$(get_conf mihomo_tls)
    SNI=$(get_conf mihomo_sni)
    TRANSPORT=$(get_conf mihomo_transport)
    WS_PATH=$(get_conf mihomo_ws_path)
    LOCAL_PORT=$(get_conf mihomo_local_port)
    ROUTE_MODE=$(get_conf mihomo_route_mode)
    DNS_HIJACK=$(get_conf mihomo_dns_hijack)
    API_PORT=$(get_conf mihomo_api_port)
    LOG_LEVEL=$(get_conf mihomo_log_level)
    SUB_URL=$(get_conf mihomo_sub_url)
    SUB_NODE=$(get_conf mihomo_sub_node)

    [ -z "$MODE" ] && MODE=1
    [ -z "$TYPE" ] && TYPE=ss
    [ -z "$PORT" ] && PORT=443
    [ -z "$METHOD" ] && METHOD=aes-128-gcm
    [ -z "$LOCAL_PORT" ] && LOCAL_PORT=7890
    [ -z "$ROUTE_MODE" ] && ROUTE_MODE=1
    [ -z "$DNS_HIJACK" ] && DNS_HIJACK=1
    [ -z "$API_PORT" ] && API_PORT=9090
    [ -z "$LOG_LEVEL" ] && LOG_LEVEL=info
    [ -z "$TRANSPORT" ] && TRANSPORT=tcp
    [ -z "$WS_PATH" ] && WS_PATH=/

    MH_REDIR_PORT=$((LOCAL_PORT + 1))
    MH_TPROXY_PORT=$((LOCAL_PORT + 2))

    # subscription mode
    SUB_ACTIVE=0
    PROXY_LIST=""
    GROUP_PROXIES=""
    if [ -n "$SUB_URL" ] && [ -d "$MH_SUB_DIR" ] && ls "$MH_SUB_DIR"/*.yaml >/dev/null 2>&1; then
        SUB_ACTIVE=1
        [ -z "$SUB_NODE" ] && SUB_NODE=node1
        # concatenate all subscription proxy files
        cat "$MH_SUB_DIR"/*.yaml > "$MH_TMP_DIR/sub_proxies.yaml" 2>/dev/null
        PROXY_LIST=$(cat "$MH_TMP_DIR/sub_proxies.yaml")
        # build proxy group proxy list from node names
        GROUP_PROXIES=$(awk '/^  - name:/ { gsub(/^  - name: "/, ""); gsub(/"$/, ""); printf "      - \"%s\"\n", $0 }' "$MH_TMP_DIR/sub_proxies.yaml")
    fi

    # ===================================================
    # write config
    # ===================================================
    {
        # ----- log -----
        cat <<EOF
log-level: $LOG_LEVEL
log-file: /tmp/mihomo.log
external-controller-pid: /tmp/mihomo.pid

EOF

        # ----- inbound ports -----
        echo "mixed-port: $LOCAL_PORT"
        if [ "$MODE" = "0" ]; then
            echo "redir-port: $MH_REDIR_PORT"
        elif [ "$MODE" = "1" ]; then
            echo "tproxy-port: $MH_TPROXY_PORT"
        fi
        echo "allow-lan: true"
        echo "bind-address: '*'"
        echo "mode: rule"
        echo "ipv6: false"
        echo ""

        # ----- tun -----
        if [ "$MODE" = "2" ]; then
            cat <<EOF
tun:
  enable: true
  stack: gvisor
  dns-hijack:
    - any:53
  auto-route: true
  auto-detect-interface: true
  mtu: 1500

EOF
        fi

        # ----- DNS -----
        if [ "$DNS_HIJACK" = "1" ]; then
            cat <<EOF
dns:
  enable: true
  listen: 0.0.0.0:1053
  ipv6: false
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  fallback:
    - https://1.1.1.1/dns-query
    - https://8.8.8.8/dns-query
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4

EOF
        fi

        # ----- proxies -----
        if [ "$SUB_ACTIVE" = "1" ]; then
            echo "proxies:"
            echo "$PROXY_LIST"
        else
            echo "proxies:"
            gen_proxy_yaml "$TYPE" "proxy" "$SERVER" "$PORT" "$UUID" "$PASSWORD" "$METHOD" "$TLS" "$SNI" "$TRANSPORT" "$WS_PATH"
        fi
        echo ""

        # ----- proxy groups -----
        if [ "$SUB_ACTIVE" = "1" ]; then
            cat <<EOF
proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
$GROUP_PROXIES
      - DIRECT
EOF
        else
            cat <<EOF
proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - "proxy"
      - DIRECT
EOF
        fi
        echo ""

        # ----- rules -----
        if [ "$ROUTE_MODE" = "0" ]; then
            # global mode
            cat <<EOF
rules:
  - MATCH,PROXY
EOF
        elif [ "$ROUTE_MODE" = "2" ]; then
            # direct mode
            cat <<EOF
rules:
  - MATCH,DIRECT
EOF
        else
            # rule mode
            GEOIP_AVAILABLE=0
            GEOSITE_AVAILABLE=0
            [ -f "$MH_CONFIG_DIR/geoip.metadb" ] || [ -f "$MH_CONFIG_DIR/Country.mmdb" ] && GEOIP_AVAILABLE=1
            [ -f "$MH_CONFIG_DIR/geosite.dat" ] && GEOSITE_AVAILABLE=1

            echo "rules:"
            echo "  - DOMAIN-SUFFIX,local,DIRECT"
            echo "  - IP-CIDR,127.0.0.0/8,DIRECT,no-resolve"
            echo "  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve"
            echo "  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve"
            echo "  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve"
            echo "  - IP-CIDR,169.254.0.0/16,DIRECT,no-resolve"
            if [ "$GEOSITE_AVAILABLE" = "1" ]; then
                echo "  - GEOSITE,cn,DIRECT"
            fi
            if [ "$GEOIP_AVAILABLE" = "1" ]; then
                echo "  - GEOIP,CN,DIRECT,no-resolve"
            fi
            echo "  - MATCH,PROXY"
        fi
        echo ""

        # ----- external controller (Clash API) -----
        if [ "$API_PORT" != "0" ] && [ -n "$API_PORT" ]; then
            echo "external-controller: 0.0.0.0:$API_PORT"
            echo "secret: \"\""
        fi

        # ----- geo data -----
        if [ -f "$MH_CONFIG_DIR/geoip.metadb" ]; then
            echo "geo-auto-update: false"
        fi

    } > "$MH_CONFIG"

    return 0
}

# ============================================================
# subscription parsing
# ============================================================
NODE_INDEX=0

node_start() {
    NODE_INDEX=$((NODE_INDEX + 1))
}

# vmess://  (base64 JSON or uuid:aid@host:port)
parse_vmess() {
    local rest="${1#vmess://}"
    local ps="${rest##*#}"
    [ "$ps" = "$rest" ] && ps=""
    local b64="${rest%%#*}"
    local dec
    dec=$(b64_decode "$b64")
    local jadd jport juid jaid jnet jpath jhost jtls jsni
    if [ -n "$dec" ] && printf '%s' "$dec" | grep -q '"'; then
        jadd=$(json_field "$dec" add)
        jport=$(json_field "$dec" port)
        juid=$(json_field "$dec" id)
        jaid=$(json_field "$dec" aid)
        jnet=$(json_field "$dec" net)
        jpath=$(json_field "$dec" path)
        jhost=$(json_field "$dec" host)
        jtls=$(json_field "$dec" tls)
        jsni=$(json_field "$dec" sni)
        [ -z "$ps" ] && ps=$(json_field "$dec" ps)
    else
        local auth="${b64%%@*}" addr="${b64##*@}"
        juid="${auth%%:*}"
        jadd="${addr%:*}"
        jport="${addr##*:}"
        jnet=tcp
    fi
    [ -z "$jport" ] && return 1
    node_start
    [ -z "$ps" ] && ps="vmess-$NODE_INDEX"
    {
        echo "  - name: \"$(yaml_escape "$ps")\""
        echo "    type: vmess"
        echo "    server: \"$(yaml_escape "$jadd")\""
        echo "    port: $jport"
        echo "    uuid: \"$(yaml_escape "$juid")\""
        echo "    alterId: ${jaid:-0}"
        echo "    cipher: auto"
        if [ "$jnet" = "ws" ]; then
            echo "    network: ws"
            echo "    ws-opts:"
            echo "      path: \"$(yaml_escape "$jpath")\""
        fi
        if [ "$jtls" = "tls" ]; then
            echo "    tls: true"
            [ -n "$jsni" ] && echo "    servername: \"$(yaml_escape "$jsni")\""
        fi
    } > "$MH_SUB_DIR/node$NODE_INDEX.yaml"
    printf '%s\tnode%s\n' "$ps" "$NODE_INDEX" >> "$MH_SUB_NODES"
}

# ss://  (method:pass@host:port)
parse_ss() {
    local rest="${1#ss://}"
    local ps="${rest##*#}"
    [ "$ps" = "$rest" ] && ps=""
    local body="${rest%%#*}"
    local addr cred dec
    if printf '%s' "$body" | grep -q '@'; then
        addr="${body##*@}"
        cred="${body%%@*}"
        if printf '%s' "$cred" | grep -q '='; then
            dec=$(b64_decode "$cred")
            [ -n "$dec" ] && cred="$dec"
        fi
    else
        dec=$(b64_decode "$body")
        [ -z "$dec" ] && return 1
        addr="${dec##*@}"
        cred="${dec%%@*}"
    fi
    local host="${addr%:*}" port="${addr##*:}"
    local method="${cred%%:*}" pass="${cred#*:}"
    [ -z "$host" ] || [ -z "$port" ] || [ -z "$pass" ] && return 1
    node_start
    [ -z "$ps" ] && ps="ss-$NODE_INDEX"
    {
        echo "  - name: \"$(yaml_escape "$ps")\""
        echo "    type: ss"
        echo "    server: \"$(yaml_escape "$host")\""
        echo "    port: $port"
        echo "    cipher: \"$(yaml_escape "$method")\""
        echo "    password: \"$(yaml_escape "$pass")\""
    } > "$MH_SUB_DIR/node$NODE_INDEX.yaml"
    printf '%s\tnode%s\n' "$ps" "$NODE_INDEX" >> "$MH_SUB_NODES"
}

# trojan://password@host:port?query
parse_trojan() {
    local rest="${1#trojan://}"
    local ps="${rest##*#}"
    [ "$ps" = "$rest" ] && ps=""
    local body="${rest%%#*}"
    local query=""
    case "$body" in
        *\?*) query="${body#*\?}"; body="${body%%\?*}" ;;
    esac
    local addr="${body##*@}" pass="${body%%@*}"
    [ "$addr" = "$body" ] && return 1
    local host="${addr%:*}" port="${addr##*:}"
    local sni type path
    local oifs="$IFS"; IFS='&'
    for kv in $query; do
        case "$kv" in
            sni=*) sni=$(url_decode "${kv#sni=}") ;;
            type=*) type="${kv#type=}" ;;
            path=*) path=$(url_decode "${kv#path=}") ;;
        esac
    done
    IFS="$oifs"
    [ -z "$sni" ] && sni="$host"
    node_start
    [ -z "$ps" ] && ps="trojan-$NODE_INDEX"
    {
        echo "  - name: \"$(yaml_escape "$ps")\""
        echo "    type: trojan"
        echo "    server: \"$(yaml_escape "$host")\""
        echo "    port: $port"
        echo "    password: \"$(yaml_escape "$pass")\""
        echo "    sni: \"$(yaml_escape "$sni")\""
    } > "$MH_SUB_DIR/node$NODE_INDEX.yaml"
    printf '%s\tnode%s\n' "$ps" "$NODE_INDEX" >> "$MH_SUB_NODES"
}

# vless://uuid@host:port?query
parse_vless() {
    local rest="${1#vless://}"
    local ps="${rest##*#}"
    [ "$ps" = "$rest" ] && ps=""
    local body="${rest%%#*}"
    local query=""
    case "$body" in
        *\?*) query="${body#*\?}"; body="${body%%\?*}" ;;
    esac
    local addr="${body##*@}" uuid="${body%%@*}"
    [ "$addr" = "$body" ] && return 1
    local host="${addr%:*}" port="${addr##*:}"
    local security sni type path
    local oifs="$IFS"; IFS='&'
    for kv in $query; do
        case "$kv" in
            security=*) security="${kv#security=}" ;;
            sni=*) sni=$(url_decode "${kv#sni=}") ;;
            type=*) type="${kv#type=}" ;;
            path=*) path=$(url_decode "${kv#path=}") ;;
        esac
    done
    IFS="$oifs"
    [ -z "$sni" ] && sni="$host"
    node_start
    [ -z "$ps" ] && ps="vless-$NODE_INDEX"
    {
        echo "  - name: \"$(yaml_escape "$ps")\""
        echo "    type: vless"
        echo "    server: \"$(yaml_escape "$host")\""
        echo "    port: $port"
        echo "    uuid: \"$(yaml_escape "$uuid")\""
        echo "    network: tcp"
        if [ "$security" = "tls" ] || [ "$security" = "reality" ]; then
            echo "    tls: true"
            echo "    servername: \"$(yaml_escape "$sni")\""
        fi
        if [ "$type" = "ws" ]; then
            echo "    network: ws"
            echo "    ws-opts:"
            echo "      path: \"$(yaml_escape "$path")\""
        elif [ "$type" = "grpc" ]; then
            echo "    network: grpc"
        fi
    } > "$MH_SUB_DIR/node$NODE_INDEX.yaml"
    printf '%s\tnode%s\n' "$ps" "$NODE_INDEX" >> "$MH_SUB_NODES"
}

# hysteria2://password@host:port?query
parse_hysteria2() {
    local rest="${1#hysteria2://}"
    local ps="${rest##*#}"
    [ "$ps" = "$rest" ] && ps=""
    local body="${rest%%#*}"
    local query=""
    case "$body" in
        *\?*) query="${body#*\?}"; body="${body%%\?*}" ;;
    esac
    local addr="${body##*@}" pass="${body%%@*}"
    [ "$addr" = "$body" ] && return 1
    local host="${addr%:*}" port="${addr##*:}"
    local sni
    local oifs="$IFS"; IFS='&'
    for kv in $query; do
        case "$kv" in
            sni=*) sni=$(url_decode "${kv#sni=}") ;;
        esac
    done
    IFS="$oifs"
    [ -z "$sni" ] && sni="$host"
    node_start
    [ -z "$ps" ] && ps="hysteria2-$NODE_INDEX"
    {
        echo "  - name: \"$(yaml_escape "$ps")\""
        echo "    type: hysteria2"
        echo "    server: \"$(yaml_escape "$host")\""
        echo "    port: $port"
        echo "    password: \"$(yaml_escape "$pass")\""
        echo "    sni: \"$(yaml_escape "$sni")\""
    } > "$MH_SUB_DIR/node$NODE_INDEX.yaml"
    printf '%s\tnode%s\n' "$ps" "$NODE_INDEX" >> "$MH_SUB_NODES"
}

parse_link() {
    case "$1" in
        vmess://*) parse_vmess "$1" ;;
        ss://*) parse_ss "$1" ;;
        trojan://*) parse_trojan "$1" ;;
        vless://*) parse_vless "$1" ;;
        hysteria2://*) parse_hysteria2 "$1" ;;
    esac
}

# ---------------- download and parse subscription ----------------
update_sub() {
    SUB_URL=$(get_conf mihomo_sub_url)
    [ -z "$SUB_URL" ] && { logger -t "mihomo" "no subscription URL configured"; return 1; }
    logger -t "mihomo" "download subscription ..."
    wget -q -T 30 -O "$MH_TMP_DIR/sub.raw" "$SUB_URL" 2>>"$MH_LOG" || {
        logger -t "mihomo" "subscription download failed"
        return 1
    }
    SIZE=$(wc -c < "$MH_TMP_DIR/sub.raw" 2>/dev/null)
    if [ "$SIZE" -lt 100 ]; then
        logger -t "mihomo" "subscription too small($SIZE), abort"
        rm -f "$MH_TMP_DIR/sub.raw"
        return 1
    fi

    rm -f "$MH_SUB_DIR"/*.yaml "$MH_SUB_NODES"
    touch "$MH_SUB_NODES"
    NODE_INDEX=0

    if grep -q "^proxies:" "$MH_TMP_DIR/sub.raw"; then
        # clash yaml subscription - extract proxies section directly
        logger -t "mihomo" "subscription format: clash yaml"
        awk '
            /^proxies:[[:space:]]*$/ { inf=1; next }
            inf && /^[A-Za-z]/ && !/^[[:space:]]/ { inf=0 }
            inf { print }
        ' "$MH_TMP_DIR/sub.raw" > "$MH_TMP_DIR/sub_proxies.yaml"
        # count nodes and generate node list
        NODE_COUNT=$(grep -c '^  - name:' "$MH_TMP_DIR/sub_proxies.yaml" 2>/dev/null)
        if [ "$NODE_COUNT" -gt 0 ]; then
            # split into individual node files for consistency
            awk '
                /^  - name:/ { if (f) close(f); n++; f=sprintf("'"$MH_SUB_DIR"'/node%d.yaml", n) }
                { if (f) print > f }
                END { print n }
            ' "$MH_TMP_DIR/sub_proxies.yaml" > /dev/null
            NODE_INDEX=$NODE_COUNT
            awk '/^  - name:/ { gsub(/^  - name: "/, ""); gsub(/"$/, ""); n++; printf "%s\tnode%d\n", $0, n }' "$MH_TMP_DIR/sub_proxies.yaml" > "$MH_SUB_NODES"
        fi
    else
        # base64 or plain link list subscription
        logger -t "mihomo" "subscription format: base64/links"
        DEC="$MH_TMP_DIR/sub.dec"
        if b64_decode "$(cat "$MH_TMP_DIR/sub.raw")" | grep -q "://"; then
            b64_decode "$(cat "$MH_TMP_DIR/sub.raw")" > "$DEC"
        elif b64_decode "$(cat "$MH_TMP_DIR/sub.raw" | tr -d '\n')" > "$DEC" 2>/dev/null && grep -q "://" "$DEC"; then
            :
        else
            cp "$MH_TMP_DIR/sub.raw" "$DEC"
        fi
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | tr -d '\r' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            [ -n "$line" ] && parse_link "$line"
        done < "$DEC"
        rm -f "$DEC"
    fi

    if [ "$NODE_INDEX" -eq 0 ]; then
        logger -t "mihomo" "no usable nodes found in subscription"
        rm -f "$MH_SUB_DIR"/*.yaml "$MH_SUB_NODES"
        return 1
    fi

    logger -t "mihomo" "subscription updated: $NODE_INDEX nodes"
    ls -la "$MH_SUB_DIR" >> "$MH_LOG" 2>&1
    return 0
}

# ---------------- download rule databases ----------------
update_geo() {
    GEO_URL=$(get_conf mihomo_geoip_url)
    GEO_URL2=$(get_conf mihomo_geosite_url)
    [ -z "$GEO_URL" ] && GEO_URL="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb"
    [ -z "$GEO_URL2" ] && GEO_URL2="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
    logger -t "mihomo" "download geoip.metadb ..."
    wget -q -T 30 -O "$MH_TMP_DIR/geoip.metadb" "$GEO_URL" 2>>"$MH_LOG" && {
        SIZE=$(wc -c < "$MH_TMP_DIR/geoip.metadb" 2>/dev/null)
        if [ "$SIZE" -lt 100000 ]; then
            logger -t "mihomo" "geoip.metadb too small($SIZE), remove"
            rm -f "$MH_TMP_DIR/geoip.metadb"
        else
            mv "$MH_TMP_DIR/geoip.metadb" "$MH_CONFIG_DIR/geoip.metadb"
        fi
    }
    logger -t "mihomo" "download geosite.dat ..."
    wget -q -T 30 -O "$MH_TMP_DIR/geosite.dat" "$GEO_URL2" 2>>"$MH_LOG" && {
        SIZE=$(wc -c < "$MH_TMP_DIR/geosite.dat" 2>/dev/null)
        if [ "$SIZE" -lt 100000 ]; then
            logger -t "mihomo" "geosite.dat too small($SIZE), remove"
            rm -f "$MH_TMP_DIR/geosite.dat"
        else
            mv "$MH_TMP_DIR/geosite.dat" "$MH_CONFIG_DIR/geosite.dat"
        fi
    }
    ls -la "$MH_CONFIG_DIR" >> "$MH_LOG" 2>&1
    return 0
}

# ---------------- start ----------------
start() {
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null

    stop
    logger -t "mihomo" "generate config ..."
    gen_config
    if ! "$MH_BIN" -t -f "$MH_CONFIG" >> "$MH_LOG" 2>&1; then
        logger -t "mihomo" "config check failed, see $MH_LOG"
        return 1
    fi
    setup_firewall "$MODE" "$LOCAL_PORT" "$DNS_HIJACK" 2>>"$MH_LOG"

    "$MH_BIN" -d "$MH_CONFIG_DIR" -f "$MH_CONFIG" >> "$MH_LOG" 2>&1 &
    MH_PID_NEW=$!
    echo "$MH_PID_NEW" > "$MH_PID"
    sleep 2
    if kill -0 "$MH_PID_NEW" 2>/dev/null; then
        logger -t "mihomo" "started, pid=$MH_PID_NEW"
        return 0
    fi
    logger -t "mihomo" "start failed, see $MH_LOG"
    rm -f "$MH_PID"
    return 1
}

status() {
    if [ -f "$MH_PID" ] && kill -0 "$(cat $MH_PID)" 2>/dev/null; then
        echo "running"
        return 0
    fi
    if pidof mihomo >/dev/null 2>&1; then
        echo "running"
        return 0
    fi
    echo "stopped"
    return 1
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 1
        start
        ;;
    update_geo)
        update_geo
        ;;
    update_sub)
        update_sub
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|update_geo|update_sub|status}"
        exit 1
        ;;
esac

exit 0
