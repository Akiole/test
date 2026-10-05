#!/bin/sh
# ============================================================
#  sing-box control script (Padavan)
#  Usage: singbox.sh {start|stop|restart|update_geo|status}
#  nvram parameters:
#    singbox_enable      enable switch 0/1
#    singbox_mode        mode 1=tproxy 0=redirect 2=tun
#    singbox_type        protocol shadowsocks/vmess/vless/trojan/hysteria2
#    singbox_server      server address
#    singbox_server_port server port
#    singbox_uuid        UUID (vmess/vless)
#    singbox_password    password (ss/trojan/hysteria2)
#    singbox_method      encryption method (ss)
#    singbox_tls         enable TLS 0/1 (vless/trojan/hysteria2)
#    singbox_sni         SNI/ServerName
#    singbox_transport   transport tcp/ws/httpupgrade/grpc (vmess/vless)
#    singbox_ws_path     WS path
#    singbox_local_port  local mixed port (socks+http)
#    singbox_route_mode  route 1=rule 0=global 2=direct
#    singbox_dns_hijack  DNS hijack 0/1
#    singbox_api_port    Clash API port, 0=disabled
#    singbox_log_level   log level
#    singbox_geoip_url   GeoIP rule database download URL
#    singbox_geosite_url GeoSite rule database download URL
#    singbox_sub_url     subscription URL (empty = manual server config)
#    singbox_sub_node    selected subscription node tag (default node1)
# ============================================================

SB_BIN=/usr/bin/sing-box
SB_CONFIG_DIR=/etc/storage/singbox
SB_TMP_DIR=/tmp/singbox
SB_CONFIG=$SB_CONFIG_DIR/config.json
SB_SUB_OUT=$SB_CONFIG_DIR/sub_outbounds.json
SB_SUB_NODES=$SB_CONFIG_DIR/sub_nodes.txt
SB_LOG=/tmp/singbox.log
SB_PID=/tmp/singbox.pid
SB_DNS_PORT=1053
SB_MARK=0x1

logger -t "singbox" "singbox.sh called: $1"

[ -x "$SB_BIN" ] || { logger -t "singbox" "sing-box binary not found"; exit 1; }

mkdir -p "$SB_CONFIG_DIR" "$SB_TMP_DIR"

json_escape() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

# decode common URL percent-escapes (enough for sub links)
url_decode() {
    echo "$1" | sed 's/%2F/\//g; s/%2f/\//g; s/%3A/:/g; s/%3a/:/g; s/%40/@/g; s/%3D/=/g; s/%3d/=/g; s/%26/\&/g; s/%3F/?/g; s/%3f/?/g; s/%23/#/g; s/%25/%/g'
}

# base64 decode with padding fixup
# mod 4 = 1 means a trailing stray char (common on single-line sub dumps): drop it
# mod 4 = 2/3 means missing padding: append '=' accordingly
b64_decode() {
    local s="$1"
    case $((${#s} % 4)) in
        1) s="${s%?}" ;;
        2) s="${s}==" ;;
        3) s="${s}=" ;;
    esac
    echo "$s" | base64 -d 2>/dev/null
}

# extract JSON string field (single-line JSON, tolerates spaces around ':')
json_field() {
    echo "$1" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}

get_conf() {
    nvram get "$1"
}

# ---------------- flush rules and processes ----------------
stop() {
    if [ -f "$SB_PID" ]; then
        kill -9 "$(cat $SB_PID)" 2>/dev/null
        rm -f "$SB_PID"
    fi
    killall -9 sing-box 2>/dev/null

    # tproxy (mangle)
    iptables -t mangle -F SING_BOX 2>/dev/null
    iptables -t mangle -D PREROUTING -j SING_BOX 2>/dev/null
    iptables -t mangle -X SING_BOX 2>/dev/null
    iptables -t mangle -F SING_BOX_MARK 2>/dev/null
    iptables -t mangle -D OUTPUT -j SING_BOX_MARK 2>/dev/null
    iptables -t mangle -X SING_BOX_MARK 2>/dev/null
    # redirect / dns (nat)
    iptables -t nat -F SING_BOX 2>/dev/null
    iptables -t nat -D PREROUTING -j SING_BOX 2>/dev/null
    iptables -t nat -D OUTPUT -j SING_BOX 2>/dev/null
    iptables -t nat -X SING_BOX 2>/dev/null
    iptables -t nat -F SING_BOX_DNS 2>/dev/null
    iptables -t nat -D PREROUTING -j SING_BOX_DNS 2>/dev/null
    iptables -t nat -D OUTPUT -j SING_BOX_DNS 2>/dev/null
    iptables -t nat -X SING_BOX_DNS 2>/dev/null
    # policy routing
    ip rule del fwmark $SB_MARK lookup 100 2>/dev/null
    ip route del local 0.0.0.0/0 dev lo table 100 2>/dev/null

    # release page-cache / dentries after the proxy process exits so the
    # router does not hold stale memory on a 128 MB-flash device
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
    SB_TPROXY_PORT=$((LOCAL_PORT + 1))

    if [ "$MODE" = "1" ]; then
        # ============ TPROXY ============
        modprobe -q xt_TPROXY 2>/dev/null
        iptables -t mangle -N SING_BOX 2>/dev/null
        priv_rules mangle SING_BOX
        # when DNS hijack is off, let port 53 pass through untouched
        if [ "$DNS_HIJACK" != "1" ]; then
            iptables -t mangle -A SING_BOX -p tcp --dport 53 -j RETURN 2>/dev/null
            iptables -t mangle -A SING_BOX -p udp --dport 53 -j RETURN 2>/dev/null
        fi
        iptables -t mangle -A SING_BOX -p tcp -j TPROXY --on-port "$SB_TPROXY_PORT" --tproxy-mark $SB_MARK/1 2>/dev/null
        iptables -t mangle -A SING_BOX -p udp -j TPROXY --on-port "$SB_TPROXY_PORT" --tproxy-mark $SB_MARK/1 2>/dev/null
        iptables -t mangle -I PREROUTING 1 -j SING_BOX 2>/dev/null

        # local traffic
        iptables -t mangle -N SING_BOX_MARK 2>/dev/null
        priv_rules mangle SING_BOX_MARK
        if [ "$DNS_HIJACK" != "1" ]; then
            iptables -t mangle -A SING_BOX_MARK -p tcp --dport 53 -j RETURN 2>/dev/null
            iptables -t mangle -A SING_BOX_MARK -p udp --dport 53 -j RETURN 2>/dev/null
        fi
        iptables -t mangle -A SING_BOX_MARK -p tcp -j MARK --set-mark $SB_MARK/1 2>/dev/null
        iptables -t mangle -A SING_BOX_MARK -p udp -j MARK --set-mark $SB_MARK/1 2>/dev/null
        iptables -t mangle -I OUTPUT 1 -j SING_BOX_MARK 2>/dev/null

        ip rule add fwmark $SB_MARK lookup 100 2>/dev/null
        ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null
    elif [ "$MODE" = "0" ]; then
        # ============ REDIRECT (TCP only) ============
        iptables -t nat -N SING_BOX 2>/dev/null
        priv_rules nat SING_BOX
        if [ "$DNS_HIJACK" = "1" ]; then
            # DNS queries are handled by sing-box dns module via the mixed inbound
            iptables -t nat -A SING_BOX -p tcp --dport 53 -j REDIRECT --to-ports "$LOCAL_PORT" 2>/dev/null
            iptables -t nat -A SING_BOX -p udp --dport 53 -j REDIRECT --to-ports "$LOCAL_PORT" 2>/dev/null
        fi
        iptables -t nat -A SING_BOX -p tcp -j REDIRECT --to-ports "$LOCAL_PORT" 2>/dev/null
        iptables -t nat -I PREROUTING 1 -j SING_BOX 2>/dev/null
        iptables -t nat -I OUTPUT 1 -j SING_BOX 2>/dev/null
    fi

    return 0
}

# ---------------- generate config ----------------
gen_config() {
    MODE=$(get_conf singbox_mode)
    TYPE=$(get_conf singbox_type)
    SERVER=$(get_conf singbox_server)
    PORT=$(get_conf singbox_server_port)
    UUID=$(get_conf singbox_uuid)
    PASSWORD=$(get_conf singbox_password)
    METHOD=$(get_conf singbox_method)
    TLS=$(get_conf singbox_tls)
    SNI=$(get_conf singbox_sni)
    TRANSPORT=$(get_conf singbox_transport)
    WS_PATH=$(get_conf singbox_ws_path)
    LOCAL_PORT=$(get_conf singbox_local_port)
    ROUTE_MODE=$(get_conf singbox_route_mode)
    DNS_HIJACK=$(get_conf singbox_dns_hijack)
    API_PORT=$(get_conf singbox_api_port)
    LOG_LEVEL=$(get_conf singbox_log_level)
    SUB_URL=$(get_conf singbox_sub_url)
    SUB_NODE=$(get_conf singbox_sub_node)
    ROUTE_RULES=$(get_conf singbox_route_rules)

    [ -z "$MODE" ] && MODE=1
    [ -z "$TYPE" ] && TYPE=shadowsocks
    [ -z "$PORT" ] && PORT=443
    [ -z "$METHOD" ] && METHOD=aes-128-gcm
    [ -z "$LOCAL_PORT" ] && LOCAL_PORT=1080
    [ -z "$ROUTE_MODE" ] && ROUTE_MODE=1
    [ -z "$DNS_HIJACK" ] && DNS_HIJACK=1
    [ -z "$API_PORT" ] && API_PORT=9090
    [ -z "$LOG_LEVEL" ] && LOG_LEVEL=info
    [ -z "$TRANSPORT" ] && TRANSPORT=tcp
    [ -z "$WS_PATH" ] && WS_PATH=/

    SB_TPROXY_PORT=$((LOCAL_PORT + 1))

    # subscription mode: use parsed subscription nodes when available
    SUB_ACTIVE=0
    AUTO_GROUP=""
    if [ -n "$SUB_URL" ] && [ -s "$SB_SUB_OUT" ]; then
        SUB_ACTIVE=1
        [ -z "$SUB_NODE" ] && SUB_NODE=node1
        OUTBOUND=$(cat "$SB_SUB_OUT")
        if [ "$SUB_NODE" = "auto" ]; then
            # url-test group: automatically pick the lowest-latency node,
            # nodes that go down are excluded until they recover
            NODE_TAGS=$(awk -F'\t' '{ if (NR > 1) printf ","; printf "\"%s\"", $2 }' "$SB_SUB_NODES")
            AUTO_GROUP=",{\"type\":\"urltest\",\"tag\":\"auto\",\"outbounds\":[$NODE_TAGS],\"url\":\"http://www.gstatic.com/generate_204\",\"interval\":\"1m\",\"tolerance\":50}"
            SUB_NODE=auto
        fi
    fi

    SERVER=$(json_escape "$SERVER")
    UUID=$(json_escape "$UUID")
    PASSWORD=$(json_escape "$PASSWORD")
    SNI=$(json_escape "$SNI")
    WS_PATH=$(json_escape "$WS_PATH")

    # ----- outbound -----
    if [ "$SUB_ACTIVE" != "1" ]; then
    OUTBOUND=""
    case "$TYPE" in
        shadowsocks)
            OUTBOUND="{\"type\":\"shadowsocks\",\"tag\":\"proxy\",\"server\":\"$SERVER\",\"server_port\":$PORT,\"method\":\"$METHOD\",\"password\":\"$PASSWORD\"}"
            ;;
        vmess)
            OUTBOUND="{\"type\":\"vmess\",\"tag\":\"proxy\",\"server\":\"$SERVER\",\"server_port\":$PORT,\"uuid\":\"$UUID\""
            if [ "$TRANSPORT" = "ws" ]; then
                OUTBOUND="$OUTBOUND,\"transport\":{\"type\":\"ws\",\"path\":\"$WS_PATH\"}"
            elif [ "$TRANSPORT" = "httpupgrade" ]; then
                OUTBOUND="$OUTBOUND,\"transport\":{\"type\":\"httpupgrade\",\"path\":\"$WS_PATH\"}"
            elif [ "$TRANSPORT" = "grpc" ]; then
                OUTBOUND="$OUTBOUND,\"transport\":{\"type\":\"grpc\"}"
            fi
            OUTBOUND="$OUTBOUND}"
            ;;
        vless)
            OUTBOUND="{\"type\":\"vless\",\"tag\":\"proxy\",\"server\":\"$SERVER\",\"server_port\":$PORT,\"uuid\":\"$UUID\""
            if [ "$TLS" = "1" ]; then
                OUTBOUND="$OUTBOUND,\"tls\":{\"enabled\":true,\"server_name\":\"$SNI\"}"
            fi
            if [ "$TRANSPORT" = "ws" ]; then
                OUTBOUND="$OUTBOUND,\"transport\":{\"type\":\"ws\",\"path\":\"$WS_PATH\"}"
            elif [ "$TRANSPORT" = "httpupgrade" ]; then
                OUTBOUND="$OUTBOUND,\"transport\":{\"type\":\"httpupgrade\",\"path\":\"$WS_PATH\"}"
            elif [ "$TRANSPORT" = "grpc" ]; then
                OUTBOUND="$OUTBOUND,\"transport\":{\"type\":\"grpc\"}"
            fi
            OUTBOUND="$OUTBOUND}"
            ;;
        trojan)
            OUTBOUND="{\"type\":\"trojan\",\"tag\":\"proxy\",\"server\":\"$SERVER\",\"server_port\":$PORT,\"password\":\"$PASSWORD\""
            if [ "$TLS" = "1" ]; then
                OUTBOUND="$OUTBOUND,\"tls\":{\"enabled\":true,\"server_name\":\"$SNI\"}"
            fi
            OUTBOUND="$OUTBOUND}"
            ;;
        hysteria2)
            # Hysteria2 always requires TLS
            OUTBOUND="{\"type\":\"hysteria2\",\"tag\":\"proxy\",\"server\":\"$SERVER\",\"server_port\":$PORT,\"password\":\"$PASSWORD\",\"tls\":{\"enabled\":true,\"server_name\":\"$SNI\"}}"
            ;;
        *)
            OUTBOUND="{\"type\":\"direct\",\"tag\":\"proxy\"}"
            ;;
    esac
    fi

    # ----- DNS -----
    # sing-box 1.14 new DNS server format: type+server instead of address
    DNS_JSON="{\"servers\":[{\"tag\":\"remote\",\"type\":\"udp\",\"server\":\"8.8.8.8\",\"detour\":\"proxy\"},{\"tag\":\"local\",\"type\":\"udp\",\"server\":\"223.5.5.5\",\"detour\":\"direct\"}],\"strategy\":\"prefer_ipv4\"}"
    if [ -f "$SB_TMP_DIR/geosite.db" ] || [ -f "$SB_CONFIG_DIR/geosite.db" ]; then
        DNS_JSON="{\"servers\":[{\"tag\":\"remote\",\"type\":\"udp\",\"server\":\"8.8.8.8\",\"detour\":\"proxy\"},{\"tag\":\"local\",\"type\":\"udp\",\"server\":\"223.5.5.5\",\"detour\":\"direct\"}],\"rules\":[{\"rule_set\":[\"geosite-cn\"],\"server\":\"local\"}],\"strategy\":\"prefer_ipv4\"}"
    fi

    # ----- inbound -----
    # note: sing-box 1.10 has no "dns" inbound type; DNS hijack is done via
    # tproxy/redirect capturing port 53 and the dns module above
    INBOUNDS="{\"type\":\"mixed\",\"tag\":\"mixed-in\",\"listen\":\"0.0.0.0\",\"listen_port\":$LOCAL_PORT}"
    if [ "$MODE" = "1" ]; then
        INBOUNDS="$INBOUNDS,{\"type\":\"tproxy\",\"tag\":\"tproxy-in\",\"listen\":\"0.0.0.0\",\"listen_port\":$SB_TPROXY_PORT}"
    elif [ "$MODE" = "2" ]; then
        INBOUNDS="$INBOUNDS,{\"type\":\"tun\",\"tag\":\"tun-in\",\"interface_name\":\"sing-tun\",\"inet4_address\":\"172.19.0.1/30\",\"auto_route\":true,\"strict_route\":false,\"stack\":\"gvisor\",\"mtu\":1500}"
    fi

    # ----- route -----
    RULE_PRIV="{\"ip_cidr\":[\"0.0.0.0/8\",\"10.0.0.0/8\",\"100.64.0.0/10\",\"127.0.0.0/8\",\"169.254.0.0/16\",\"172.16.0.0/12\",\"192.0.0.0/24\",\"192.0.2.0/24\",\"192.168.0.0/16\",\"198.18.0.0/15\",\"198.51.100.0/24\",\"203.0.113.0/24\",\"224.0.0.0/4\",\"240.0.0.0/4\",\"255.255.255.255/32\"],\"outbound\":\"direct\"},{\"ip_is_private\":true,\"outbound\":\"direct\"}"
    # user-defined rules: one JSON rule object per line, e.g.
    #   {"domain_suffix":[".example.com"],"outbound":"direct"}
    # they are inserted right after the private/reserved rules, so they
    # take priority over the geoip/geosite auto rules below
    CUSTOM_RULES=""
    if [ -n "$ROUTE_RULES" ]; then
        CR_LIST=""
        while IFS= read -r cr_line || [ -n "$cr_line" ]; do
            cr_line=$(echo "$cr_line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            [ -n "$cr_line" ] && CR_LIST="$CR_LIST,$cr_line"
        done <<EOF
$ROUTE_RULES
EOF
        CUSTOM_RULES="$CR_LIST"
    fi
    RULES="[$RULE_PRIV$CUSTOM_RULES"
    if [ "$SUB_ACTIVE" = "1" ]; then
        if [ "$ROUTE_MODE" = "1" ]; then
            if [ -f "$SB_TMP_DIR/geoip.db" ] || [ -f "$SB_CONFIG_DIR/geoip.db" ]; then
                RULES="$RULES,{\"geoip\":[\"cn\"],\"outbound\":\"direct\"}"
            fi
            if [ -f "$SB_TMP_DIR/geosite.db" ] || [ -f "$SB_CONFIG_DIR/geosite.db" ]; then
                RULES="$RULES,{\"geosite\":[\"cn\"],\"outbound\":\"direct\"}"
            fi
        fi
        if [ "$ROUTE_MODE" = "2" ]; then
            FINAL="direct"
        else
            FINAL="$SUB_NODE"
        fi
    elif [ "$ROUTE_MODE" = "1" ]; then
        if [ -f "$SB_TMP_DIR/geoip.db" ] || [ -f "$SB_CONFIG_DIR/geoip.db" ]; then
            RULES="$RULES,{\"geoip\":[\"cn\"],\"outbound\":\"direct\"}"
        fi
        if [ -f "$SB_TMP_DIR/geosite.db" ] || [ -f "$SB_CONFIG_DIR/geosite.db" ]; then
            RULES="$RULES,{\"geosite\":[\"cn\"],\"outbound\":\"direct\"}"
        fi
        FINAL="proxy"
    elif [ "$ROUTE_MODE" = "0" ]; then
        FINAL="proxy"
    else
        FINAL="direct"
    fi
    RULES="$RULES]"

    ROUTE_JSON="{\"auto_detect_interface\":true,\"default_domain_resolver\":{\"server\":\"local\"},\"rules\":$RULES,\"final\":\"$FINAL\"}"

    # ----- Clash API -----
    # bind to 0.0.0.0 so external dashboards (metacubexd / yacd / zashboard)
    # can connect from LAN. access_control_allow_origin permits any origin so
    # browser-based dashboards can call the API without CORS issues.
    if [ "$API_PORT" != "0" ] && [ -n "$API_PORT" ]; then
        API_JSON="{\"clash_api\":{\"external_controller\":\"0.0.0.0:$API_PORT\",\"access_control_allow_origin\":[\"*\"]}}"
    else
        API_JSON="{}"
    fi

    # ----- local rule database files -----
    GEOIP_PATH=""
    GEOSITE_PATH=""
    if [ -f "$SB_TMP_DIR/geoip.db" ]; then
        GEOIP_PATH="$SB_TMP_DIR/geoip.db"
    elif [ -f "$SB_CONFIG_DIR/geoip.db" ]; then
        GEOIP_PATH="$SB_CONFIG_DIR/geoip.db"
    fi
    if [ -f "$SB_TMP_DIR/geosite.db" ]; then
        GEOSITE_PATH="$SB_TMP_DIR/geosite.db"
    elif [ -f "$SB_CONFIG_DIR/geosite.db" ]; then
        GEOSITE_PATH="$SB_CONFIG_DIR/geosite.db"
    fi

    # ===================================================
    # write config
    # ===================================================
    {
        printf '{\n'
        printf '"log":{"level":"%s","timestamp":true,"output":"/tmp/singbox.log"},\n' "$LOG_LEVEL"
        printf '"dns":%s,\n' "$DNS_JSON"
        printf '"inbounds":[%s],\n' "$INBOUNDS"
        if [ "$SUB_ACTIVE" = "1" ]; then
            # append url-test group (if any), direct and block inside the
            # subscription outbounds array
            OUTBOUND="${OUTBOUND%]}$AUTO_GROUP,{\"type\":\"direct\",\"tag\":\"direct\"},{\"type\":\"block\",\"tag\":\"block\"}]"
            printf '"outbounds":%s,\n' "$OUTBOUND"
        else
            printf '"outbounds":[%s,{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}],\n' "$OUTBOUND"
        fi
        if [ -n "$GEOSITE_PATH" ]; then
            printf '"route":{"auto_detect_interface":true,"default_domain_resolver":{"server":"local"},"rule_set":[{"type":"local","tag":"geosite-cn","format":"binary","path":"%s"}],"rules":%s,"final":"%s"},\n' "$GEOSITE_PATH" "$RULES" "$FINAL"
        else
            printf '"route":%s,\n' "$ROUTE_JSON"
        fi
        printf '"experimental":%s\n' "$API_JSON"
        printf '}\n'
    } > "$SB_CONFIG"

    return 0
}

# ============================================================
# subscription parsing helpers
# each parse_* function prints one outbound JSON object and
# appends "name\ttag" to $SB_SUB_NODES
# ============================================================
NODE_INDEX=0

node_start() {
    NODE_INDEX=$((NODE_INDEX + 1))
}

node_emit() {  # $1 = outbound JSON, $2 = display name
    echo "$1"
    printf '%s\tnode%s\n' "$2" "$NODE_INDEX" >> "$SB_SUB_NODES"
}

# vmess://  (base64 JSON or uuid:aid@host:port)
parse_vmess() {
    local rest="${1#vmess://}"
    local ps="${rest##*#}"
    [ "$ps" = "$rest" ] && ps=""
    local b64="${rest%%#*}"
    local json dec
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
        # legacy vmess://uuid:aid@host:port
        local auth="${b64%%@*}" addr="${b64##*@}"
        juid="${auth%%:*}"
        jadd="${addr%:*}"
        jport="${addr##*:}"
        jnet=tcp
    fi
    [ -z "$jport" ] && return 1
    node_start
    local out="{\"type\":\"vmess\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$jadd")\",\"server_port\":$jport,\"uuid\":\"$(json_escape "$juid")\""
    if [ "$jnet" = "ws" ]; then
        [ -z "$jpath" ] && jpath="/"
        out="$out,\"transport\":{\"type\":\"ws\",\"path\":\"$(json_escape "$jpath")\""
        [ -n "$jhost" ] && out="$out,\"headers\":{\"Host\":\"$(json_escape "$jhost")\"}"
        out="$out}"
    fi
    if [ "$jtls" = "tls" ]; then
        [ -z "$jsni" ] && jsni="$jhost"
        [ -z "$jsni" ] && jsni="$jadd"
        out="$out,\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$jsni")\"}"
    fi
    out="$out}"
    node_emit "$out" "$ps"
}

# ss://  (method:pass@host:port, optionally base64 whole or credentials)
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
    node_emit "{\"type\":\"shadowsocks\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$host")\",\"server_port\":$port,\"method\":\"$(json_escape "$method")\",\"password\":\"$(json_escape "$pass")\"}" "$ps"
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
            security=*) : ;;
        esac
    done
    IFS="$oifs"
    [ -z "$sni" ] && sni="$host"
    node_start
    local out="{\"type\":\"trojan\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$host")\",\"server_port\":$port,\"password\":\"$(json_escape "$pass")\""
    out="$out,\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$sni")\"}"
    if [ "$type" = "ws" ]; then
        [ -z "$path" ] && path="/"
        out="$out,\"transport\":{\"type\":\"ws\",\"path\":\"$(json_escape "$path")\"}"
    fi
    out="$out}"
    node_emit "$out" "$ps"
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
    local security sni type path hosthdr
    local oifs="$IFS"; IFS='&'
    for kv in $query; do
        case "$kv" in
            security=*) security="${kv#security=}" ;;
            sni=*) sni=$(url_decode "${kv#sni=}") ;;
            type=*) type="${kv#type=}" ;;
            path=*) path=$(url_decode "${kv#path=}") ;;
            host=*) hosthdr=$(url_decode "${kv#host=}") ;;
        esac
    done
    IFS="$oifs"
    [ -z "$sni" ] && sni="$host"
    node_start
    local out="{\"type\":\"vless\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$host")\",\"server_port\":$port,\"uuid\":\"$(json_escape "$uuid")\""
    if [ "$security" = "tls" ] || [ "$security" = "reality" ]; then
        out="$out,\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$sni")\"}"
    fi
    if [ "$type" = "ws" ]; then
        [ -z "$path" ] && path="/"
        out="$out,\"transport\":{\"type\":\"ws\",\"path\":\"$(json_escape "$path")\""
        [ -n "$hosthdr" ] && out="$out,\"headers\":{\"Host\":\"$(json_escape "$hosthdr")\"}"
        out="$out}"
    elif [ "$type" = "grpc" ]; then
        out="$out,\"transport\":{\"type\":\"grpc\"}"
    elif [ "$type" = "httpupgrade" ]; then
        [ -z "$path" ] && path="/"
        out="$out,\"transport\":{\"type\":\"httpupgrade\",\"path\":\"$(json_escape "$path")\"}"
    fi
    out="$out}"
    node_emit "$out" "$ps"
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
    local sni obfs obfspw
    local oifs="$IFS"; IFS='&'
    for kv in $query; do
        case "$kv" in
            sni=*) sni=$(url_decode "${kv#sni=}") ;;
            obfs=*) obfs="${kv#obfs=}" ;;
            obfs-password=*) obfspw=$(url_decode "${kv#obfs-password=}") ;;
        esac
    done
    IFS="$oifs"
    [ -z "$sni" ] && sni="$host"
    node_start
    local out="{\"type\":\"hysteria2\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$host")\",\"server_port\":$port,\"password\":\"$(json_escape "$pass")\",\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$sni")\"}"
    if [ -n "$obfs" ]; then
        out="$out,\"obfs\":{\"type\":\"$(json_escape "$obfs")\""
        [ -n "$obfspw" ] && out="$out,\"password\":\"$(json_escape "$obfspw")\""
        out="$out}"
    fi
    out="$out}"
    node_emit "$out" "$ps"
}

# parse one decoded subscription link line
parse_link() {
    case "$1" in
        vmess://*) parse_vmess "$1" ;;
        ss://*) parse_ss "$1" ;;
        trojan://*) parse_trojan "$1" ;;
        vless://*) parse_vless "$1" ;;
        hysteria2://*) parse_hysteria2 "$1" ;;
        # ssr/hysteria not supported in v1
    esac
}

# parse clash yaml proxies into the same pipe-record stream handled below
# emits: name|type|server|port|uuid|aid|cipher|network|tls|sni|wspath|password
parse_clash() {  # $1 = yaml file
    awk '
        /^proxies:[[:space:]]*$/ { inf=1; next }
        inf && /^[A-Za-z]/ && !/^[[:space:]]/ { inf=0 }
        inf && /^[[:space:]]*-[[:space:]]*\{/ {
            # flow style node on a single line
            if (in_node) flush()
            line=$0
            name=""; type=""; server=""; port=""; uuid=""; aid=""; cipher=""; network=""; tls=""; sni=""; wspath=""; password=""
            if (match(line, /name:[[:space:]]*"?[^",}]*/)) { name=substr(line, RSTART, RLENGTH); sub(/^name:[[:space:]]*"?/, "", name) }
            if (match(line, /type:[[:space:]]*[a-zA-Z0-9-]+/)) { type=substr(line, RSTART, RLENGTH); sub(/^type:[[:space:]]*/, "", type) }
            if (match(line, /server:[[:space:]]*"?[^",}]*"?/)) { server=substr(line, RSTART, RLENGTH); sub(/^server:[[:space:]]*"?/, "", server); sub(/"$/, "", server) }
            if (match(line, /port:[[:space:]]*[0-9]+/)) { port=substr(line, RSTART, RLENGTH); sub(/^port:[[:space:]]*/, "", port) }
            if (match(line, /uuid:[[:space:]]*"?[^",}]*"?/)) { uuid=substr(line, RSTART, RLENGTH); sub(/^uuid:[[:space:]]*"?/, "", uuid); sub(/"$/, "", uuid) }
            if (match(line, /alterId:[[:space:]]*[0-9]+/)) { aid=substr(line, RSTART, RLENGTH); sub(/^alterId:[[:space:]]*/, "", aid) }
            if (match(line, /cipher:[[:space:]]*[a-zA-Z0-9-]+/)) { cipher=substr(line, RSTART, RLENGTH); sub(/^cipher:[[:space:]]*/, "", cipher) }
            if (match(line, /network:[[:space:]]*[a-zA-Z0-9-]+/)) { network=substr(line, RSTART, RLENGTH); sub(/^network:[[:space:]]*/, "", network) }
            if (match(line, /tls:[[:space:]]*(true|false)/)) { tls=substr(line, RSTART, RLENGTH); sub(/^tls:[[:space:]]*/, "", tls) }
            if (match(line, /sni:[[:space:]]*"?[^",}]*"?/)) { sni=substr(line, RSTART, RLENGTH); sub(/^sni:[[:space:]]*"?/, "", sni); sub(/"$/, "", sni) }
            if (match(line, /ws-path:[[:space:]]*"?[^",}]*"?/)) { wspath=substr(line, RSTART, RLENGTH); sub(/^ws-path:[[:space:]]*"?/, "", wspath); sub(/"$/, "", wspath) }
            if (match(line, /password:[[:space:]]*"?[^",}]*"?/)) { password=substr(line, RSTART, RLENGTH); sub(/^password:[[:space:]]*"?/, "", password); sub(/"$/, "", password) }
            print name "|" type "|" server "|" port "|" uuid "|" aid "|" cipher "|" network "|" tls "|" sni "|" wspath "|" password
            in_node=0
            next
        }
        inf && /^[[:space:]]*-[[:space:]]/ {
            # block style node start
            if (in_node) flush()
            in_node=1
            name=""; type=""; server=""; port=""; uuid=""; aid=""; cipher=""; network=""; tls=""; sni=""; wspath=""; password=""; in_wsopts=0
            if (match($0, /name:[[:space:]]*"?[^"]*"?/)) {
                nm=substr($0, RSTART+5, RLENGTH-5)
                gsub(/^[[:space:]]*"?|"?[[:space:]]*$/, "", nm)
                name=nm
            }
            next
        }
        inf && in_node && /^[[:space:]]*[a-zA-Z0-9_-]+[[:space:]]*:/ {
            line=$0
            sub(/^[[:space:]]*/, "", line)
            key=line; sub(/:.*/, "", key)
            val=line; sub(/^[^:]*:[[:space:]]*/, "", val)
            gsub(/^"|"$/, "", val)
            if (key=="ws-opts") { in_wsopts=1; next }
            if (key=="headers") { next }
            if (in_wsopts) {
                if (key=="path") wspath=val
                in_wsopts=0
                next
            }
            if (key=="name") name=val
            else if (key=="type") type=val
            else if (key=="server") server=val
            else if (key=="port") port=val
            else if (key=="uuid") uuid=val
            else if (key=="alterId") aid=val
            else if (key=="cipher") cipher=val
            else if (key=="network") network=val
            else if (key=="tls") tls=val
            else if (key=="sni") sni=val
            else if (key=="password") password=val
            next
        }
        inf && in_node && /^[[:space:]]*path:[[:space:]]/ {
            # ws-opts path on its own line
            line=$0
            val=line; sub(/^[^:]*:[[:space:]]*/, "", val)
            gsub(/^"|"$/, "", val)
            wspath=val
            in_wsopts=0
            next
        }
        END { if (in_node) flush() }
        function flush() {
            print name "|" type "|" server "|" port "|" uuid "|" aid "|" cipher "|" network "|" tls "|" sni "|" wspath "|" password
        }
    ' "$1"
}

# turn one pipe-record into an outbound JSON + node list entry
clash_node() {
    local IFS='|'
    set -- $1
    local name="$1" type="$2" server="$3" port="$4" uuid="$5" aid="$6" cipher="$7" network="$8" tls="$9"
    shift 9
    local sni="$1" wspath="$2" password="$3"
    [ -z "$server" ] && return 1
    node_start
    case "$type" in
        vmess)
            local out="{\"type\":\"vmess\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$server")\",\"server_port\":$port,\"uuid\":\"$(json_escape "$uuid")\""
            if [ "$network" = "ws" ]; then
                [ -z "$wspath" ] && wspath="/"
                out="$out,\"transport\":{\"type\":\"ws\",\"path\":\"$(json_escape "$wspath")\"}"
            fi
            if [ "$tls" = "true" ]; then
                [ -z "$sni" ] && sni="$server"
                out="$out,\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$sni")\"}"
            fi
            out="$out}"
            node_emit "$out" "$name"
            ;;
        vless)
            local out="{\"type\":\"vless\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$server")\",\"server_port\":$port,\"uuid\":\"$(json_escape "$uuid")\""
            if [ "$tls" = "true" ]; then
                [ -z "$sni" ] && sni="$server"
                out="$out,\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$sni")\"}"
            fi
            if [ "$network" = "ws" ]; then
                [ -z "$wspath" ] && wspath="/"
                out="$out,\"transport\":{\"type\":\"ws\",\"path\":\"$(json_escape "$wspath")\"}"
            elif [ "$network" = "grpc" ]; then
                out="$out,\"transport\":{\"type\":\"grpc\"}"
            fi
            out="$out}"
            node_emit "$out" "$name"
            ;;
        trojan)
            local out="{\"type\":\"trojan\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$server")\",\"server_port\":$port,\"password\":\"$(json_escape "$password")\""
            [ -z "$sni" ] && sni="$server"
            out="$out,\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$sni")\"}"
            if [ "$network" = "ws" ]; then
                [ -z "$wspath" ] && wspath="/"
                out="$out,\"transport\":{\"type\":\"ws\",\"path\":\"$(json_escape "$wspath")\"}"
            fi
            out="$out}"
            node_emit "$out" "$name"
            ;;
        shadowsocks)
            node_emit "{\"type\":\"shadowsocks\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$server")\",\"server_port\":$port,\"method\":\"$(json_escape "$cipher")\",\"password\":\"$(json_escape "$password")\"}" "$name"
            ;;
        hysteria2)
            [ -z "$sni" ] && sni="$server"
            node_emit "{\"type\":\"hysteria2\",\"tag\":\"node$NODE_INDEX\",\"server\":\"$(json_escape "$server")\",\"server_port\":$port,\"password\":\"$(json_escape "$password")\",\"tls\":{\"enabled\":true,\"server_name\":\"$(json_escape "$sni")\"}}" "$name"
            ;;
    esac
}

# ---------------- download and parse subscription ----------------
update_sub() {
    SUB_URL=$(get_conf singbox_sub_url)
    [ -z "$SUB_URL" ] && { logger -t "singbox" "no subscription URL configured"; return 1; }
    logger -t "singbox" "download subscription ..."
    wget -q -T 30 -O "$SB_TMP_DIR/sub.raw" "$SUB_URL" 2>>"$SB_LOG" || {
        logger -t "singbox" "subscription download failed"
        return 1
    }
    SIZE=$(wc -c < "$SB_TMP_DIR/sub.raw" 2>/dev/null)
    if [ "$SIZE" -lt 100 ]; then
        logger -t "singbox" "subscription too small($SIZE), abort"
        rm -f "$SB_TMP_DIR/sub.raw"
        return 1
    fi

    rm -f "$SB_SUB_OUT" "$SB_SUB_NODES"
    touch "$SB_SUB_NODES"
    NODE_INDEX=0
    TMP_OUT="$SB_TMP_DIR/sub.out.lines"
    : > "$TMP_OUT"

    if grep -q "^proxies:" "$SB_TMP_DIR/sub.raw"; then
        # clash yaml subscription
        logger -t "singbox" "subscription format: clash yaml"
        parse_clash "$SB_TMP_DIR/sub.raw" > "$SB_TMP_DIR/sub.rec"
        while IFS= read -r rec || [ -n "$rec" ]; do
            [ -n "$rec" ] && clash_node "$rec" >> "$TMP_OUT"
        done < "$SB_TMP_DIR/sub.rec"
        rm -f "$SB_TMP_DIR/sub.rec"
    else
        # base64 or plain link list subscription
        logger -t "singbox" "subscription format: base64/links"
        DEC="$SB_TMP_DIR/sub.dec"
        if b64_decode "$(cat "$SB_TMP_DIR/sub.raw")" | grep -q "://"; then
            b64_decode "$(cat "$SB_TMP_DIR/sub.raw")" > "$DEC"
        elif b64_decode "$(cat "$SB_TMP_DIR/sub.raw" | tr -d '\n')" > "$DEC" 2>/dev/null && grep -q "://" "$DEC"; then
            :
        else
            cp "$SB_TMP_DIR/sub.raw" "$DEC"
        fi
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | tr -d '\r' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            [ -n "$line" ] && parse_link "$line" >> "$TMP_OUT"
        done < "$DEC"
        rm -f "$DEC"
    fi

    if [ "$NODE_INDEX" -eq 0 ]; then
        logger -t "singbox" "no usable nodes found in subscription"
        rm -f "$SB_SUB_OUT" "$SB_SUB_NODES"
        return 1
    fi

    # assemble the outbounds array from collected JSON lines
    {
        printf '['
        i=0
        while IFS= read -r line; do
            [ "$i" -gt 0 ] && printf ','
            printf '%s' "$line"
            i=$((i + 1))
        done
        printf ']\n'
    } > "$SB_SUB_OUT" < "$TMP_OUT"
    rm -f "$TMP_OUT"

    logger -t "singbox" "subscription updated: $NODE_INDEX nodes -> $SB_SUB_OUT"
    ls -la "$SB_SUB_OUT" "$SB_SUB_NODES" >> "$SB_LOG" 2>&1
    return 0
}

# ---------------- download rule databases ----------------
update_geo() {
    GEO_URL=$(get_conf singbox_geoip_url)
    GEO_URL2=$(get_conf singbox_geosite_url)
    [ -z "$GEO_URL" ] && GEO_URL="https://github.com/SagerNet/sing-geoip/releases/download/v1.0.0/geoip.db"
    [ -z "$GEO_URL2" ] && GEO_URL2="https://github.com/SagerNet/sing-geosite/releases/download/v20240807020603/geosite.db"
    logger -t "singbox" "download geoip.db ..."
    wget -q -T 30 -O "$SB_TMP_DIR/geoip.db" "$GEO_URL" 2>>"$SB_LOG" && {
        SIZE=$(wc -c < "$SB_TMP_DIR/geoip.db" 2>/dev/null)
        if [ "$SIZE" -lt 1000000 ]; then
            logger -t "singbox" "geoip.db too small($SIZE), remove"
            rm -f "$SB_TMP_DIR/geoip.db"
        fi
    }
    logger -t "singbox" "download geosite.db ..."
    wget -q -T 30 -O "$SB_TMP_DIR/geosite.db" "$GEO_URL2" 2>>"$SB_LOG" && {
        SIZE=$(wc -c < "$SB_TMP_DIR/geosite.db" 2>/dev/null)
        if [ "$SIZE" -lt 1000000 ]; then
            logger -t "singbox" "geosite.db too small($SIZE), remove"
            rm -f "$SB_TMP_DIR/geosite.db"
        fi
    }
    ls -la "$SB_TMP_DIR" >> "$SB_LOG" 2>&1
    return 0
}

# ---------------- start ----------------
start() {
    # free page-cache before starting, gives the Go binary room to work
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null

    stop
    logger -t "singbox" "generate config ..."
    gen_config
    if ! "$SB_BIN" check -c "$SB_CONFIG" >> "$SB_LOG" 2>&1; then
        logger -t "singbox" "config check failed, see $SB_LOG"
        return 1
    fi
    setup_firewall "$MODE" "$LOCAL_PORT" "$DNS_HIJACK" 2>>"$SB_LOG"

    "$SB_BIN" run -c "$SB_CONFIG" >> "$SB_LOG" 2>&1 &
    SB_PID_NEW=$!
    echo "$SB_PID_NEW" > "$SB_PID"
    sleep 2
    if kill -0 "$SB_PID_NEW" 2>/dev/null; then
        logger -t "singbox" "started, pid=$SB_PID_NEW"
        return 0
    fi
    logger -t "singbox" "start failed, see $SB_LOG"
    rm -f "$SB_PID"
    return 1
}

status() {
    if [ -f "$SB_PID" ] && kill -0 "$(cat $SB_PID)" 2>/dev/null; then
        echo "running"
        return 0
    fi
    if pidof sing-box >/dev/null 2>&1; then
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
