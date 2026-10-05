#!/bin/sh
# igmpproxy 启动脚本
# 用法: igmpproxy.sh start|stop|restart

CONFIG="/etc/igmpproxy.conf"
PIDFILE="/var/run/igmpproxy.pid"

case "$1" in
    start)
        if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
            echo "igmpproxy already running"
            exit 0
        fi
        if [ ! -f "$CONFIG" ]; then
            # 自动检测 WAN 接口生成配置
            WAN_IF=$(ip route show default 2>/dev/null | awk '{print $5}' | head -1)
            [ -z "$WAN_IF" ] && WAN_IF="ppp0"
            cat > "$CONFIG" << EOF
quickleave
phyint $WAN_IF upstream ratelimit 0 threshold 1
phyint br0 downstream ratelimit 0 threshold 1
phyint eth2 disabled
phyint eth3 disabled
phyint lo disabled
EOF
            logger -t igmpproxy "Auto-generated config with WAN interface: $WAN_IF"
        fi
        igmpproxy "$CONFIG"
        echo $! > "$PIDFILE" 2>/dev/null
        logger -t igmpproxy "igmpproxy started"
        ;;
    stop)
        if [ -f "$PIDFILE" ]; then
            kill $(cat "$PIDFILE") 2>/dev/null
            rm -f "$PIDFILE"
        fi
        killall igmpproxy 2>/dev/null
        logger -t igmpproxy "igmpproxy stopped"
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
