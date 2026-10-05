#!/bin/sh
# ============================================================
# AP 中继自动守护脚本
# ============================================================
# 配置文件: /etc/storage/ap_relay.conf  (持久化，重启不丢失)
# PID  文件: /tmp/ap_relay.pid
# Lock 文件: /tmp/apc.lock
# AP 列表: /tmp/ap2g5g  (过滤后的有效配置)
# AP 模板: /tmp/ap2g5g.txt (含注释的完整配置)
# ============================================================

CONFIG_FILE="/etc/storage/ap_relay.conf"
PID_FILE="/tmp/ap_relay.pid"
LOCK_FILE="/tmp/apc.lock"
AP_LIST_FILE="/tmp/ap2g5g"
AP_LIST_TEMPLATE="/tmp/ap2g5g.txt"
DAEMON_SCRIPT="/tmp/sh_apauto.sh"

# ------------------------------------------------------------
# 初始化默认 nvram 参数（仅在未设置时写入默认值）
# ------------------------------------------------------------
init_nvram_defaults() {
    # 中继连接守护触发条件: 0=Internet断线后搜寻; 1=信号断开时搜寻
    [ -z "$(nvram get ap_check)" ] && nvram set ap_check=0
    # 连接成功条件: 0=连上即可; 1=连上且能联网
    [ -z "$(nvram get ap_inet_check)" ] && nvram set ap_inet_check=0
    # 定时搜寻间隔(秒): 0=成功后停止; >=10=每隔N秒搜寻最优信号
    [ -z "$(nvram get ap_time_check)" ] && nvram set ap_time_check=0
    # 黑名单功能: 0=关闭; 1=启用
    [ -z "$(nvram get ap_black)" ] && nvram set ap_black=0
    # 配置字段分隔符
    [ -z "$(nvram get ap_fenge)" ] && nvram set ap_fenge='@'
    # 搜寻排序: 0=按配置顺序(首行最优先); 1=自动连接最强信号
    [ -z "$(nvram get ap_rule)" ] && nvram set ap_rule=0
    # ===== 智能切换（第二阶段） =====
    # 智能切换开关: 0=关闭; 1=启用（信号低于阈值且有更强信号时自动切换）
    [ -z "$(nvram get ap_auto_switch)" ] && nvram set ap_auto_switch=0
    # 切换信号阈值(dBm): 当前信号低于此值时触发扫描评估（默认-75）
    [ -z "$(nvram get ap_switch_threshold)" ] && nvram set ap_switch_threshold=-75
    # 切换迟滞(dBm): 候选信号需比当前强多少才切换，避免临界震荡（默认10）
    [ -z "$(nvram get ap_switch_hysteresis)" ] && nvram set ap_switch_hysteresis=10
    # 漫游保护(秒): 切换后多久内不再切换，防止频繁切换（默认60）
    [ -z "$(nvram get ap_roam_protect)" ] && nvram set ap_roam_protect=60
    # 连接质量检查: 0=关闭; 1=启用（ping 延迟/丢包率评估，质量差也触发切换）
    [ -z "$(nvram get ap_quality_check)" ] && nvram set ap_quality_check=0
    # 质量检查丢包率阈值(%): 超过则认为质量差（默认50）
    [ -z "$(nvram get ap_quality_ping_loss)" ] && nvram set ap_quality_ping_loss=50
    # 质量检查延迟阈值(ms): 超过则认为质量差（默认200）
    [ -z "$(nvram get ap_quality_ping_delay)" ] && nvram set ap_quality_ping_delay=200
}

# ------------------------------------------------------------
# 生成配置模板（首次使用时）
# ------------------------------------------------------------
generate_config_template() {
    cat > "$AP_LIST_TEMPLATE" <<-'EOF'
# ============================================================
# AP 中继配置
# 各参数用 @ 分隔，多个 AP 换行填写（第一行最优先）
# 搜寻时无线网络会瞬断一下
# ============================================================
# 参数说明：
#   ① 频段:     2=2.4GHz  5=5GHz
#   ② 工作模式: 3=AP-Client(AP被禁用)  4=AP-Client+AP(不支持WDS)
#   ③ 客户端角色: 0=LAN bridge  1=WAN (Wireless ISP)
#   ④ SSID:     目标AP的名称
#   ⑤ 密码:     目标AP的密码
#   ⑥ BSSID:    目标AP的MAC地址(SSID含中文时必填，大小写不限)
# ============================================================
# 示例（删除行首 # 生效）：
#2@4@1@ASUS_2.4G@1234567890
#5@4@1@ASUS_5G@1234567890@34:bd:f9:1f:d2:b1
# ============================================================


EOF
}

# ------------------------------------------------------------
# 加载配置：优先从 nvram ap_relay_list 同步，否则从持久化文件读取
# ------------------------------------------------------------
load_config() {
    local nvram_list=$(nvram get ap_relay_list)

    # 如果 nvram 中有配置且非空，写入配置文件（Web UI 保存的配置优先）
    if [ -n "$nvram_list" ]; then
        echo "$nvram_list" > "$AP_LIST_TEMPLATE"
        cp "$AP_LIST_TEMPLATE" "$CONFIG_FILE" 2>/dev/null
    elif [ -f "$CONFIG_FILE" ] && [ -s "$CONFIG_FILE" ]; then
        # 从持久化文件加载
        cp "$CONFIG_FILE" "$AP_LIST_TEMPLATE"
        # 同步到 nvram 供 Web UI 显示
        nvram set ap_relay_list="$(cat "$CONFIG_FILE")"
    else
        generate_config_template
        cp "$AP_LIST_TEMPLATE" "$CONFIG_FILE" 2>/dev/null
        nvram set ap_relay_list="$(cat "$CONFIG_FILE")"
    fi

    # 过滤注释和空行，生成有效配置列表
    grep -v '^#' "$AP_LIST_TEMPLATE" 2>/dev/null | grep -v "^$" > "$AP_LIST_FILE"
}

# ------------------------------------------------------------
# 保存配置到持久化文件
# ------------------------------------------------------------
save_config() {
    [ -f "$AP_LIST_TEMPLATE" ] && cp "$AP_LIST_TEMPLATE" "$CONFIG_FILE" 2>/dev/null
}

# ------------------------------------------------------------
# 检查守护进程是否已在运行
# 返回: 0=已在运行, 1=未运行
# ------------------------------------------------------------
check_daemon_running() {
    # 检查 sh_apauto.sh 进程
    if [ -n "$(ps -w | grep "$DAEMON_SCRIPT" | grep -v grep)" ]; then
        return 0
    fi
    # 检查 PID 文件
    if [ -f "$PID_FILE" ]; then
        old_pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# ------------------------------------------------------------
# 清理残留的 lock 文件（仅当无实际扫描进程时）
# ------------------------------------------------------------
clean_stale_lock() {
    if [ -f "$LOCK_FILE" ]; then
        # 检查是否有实际的扫描/连接进程在运行
        if [ -z "$(ps -w | grep -E '[c]onnAPSite|[s]h_ezscript\.sh' | grep -v grep)" ]; then
            logger -t "【AP 中继】" "清理残留 lock 文件"
            rm -f "$LOCK_FILE"
        fi
    fi
}

# ------------------------------------------------------------
# 生成守护进程脚本
# ------------------------------------------------------------
generate_daemon_script() {
    cat > "$DAEMON_SCRIPT" <<-'DAEMON_EOF'
#!/bin/sh
# AP 中继守护进程（自动生成，请勿手动修改）
# 每隔 15 秒检查中继状态，必要时触发自动搜寻

[ "$1" = "crontabs" ] && sleep 15
logger -t "【AP 中继】" "连接守护启动"

while [ -s /tmp/ap2g5g ]; do
    # 获取 AP-Client 接口名（自动检测，必须在状态更新之前）
    radio2_apcli=$(nvram get radio2_apcli)
    radio5_apcli=$(nvram get radio5_apcli)
    radio2_main=$(nvram get radio2_main)
    radio5_main=$(nvram get radio5_main)
    # 自动检测 2.4G 主接口
    if [ -z "$radio2_main" ]; then
        if iwpriv rax0 get_site_survey >/dev/null 2>&1; then
            radio2_main="rax0"
        else
            radio2_main="ra0"
        fi
    fi
    # 自动检测 5G 主接口
    if [ -z "$radio5_main" ]; then
        if iwpriv ra0 get_site_survey >/dev/null 2>&1 && [ "$radio2_main" != "ra0" ]; then
            radio5_main="ra0"
        else
            radio5_main="rai0"
        fi
    fi
    # 自动检测 AP-Client 接口名
    if [ -z "$radio2_apcli" ]; then
        [ "$radio2_main" = "rax0" ] && radio2_apcli="apclix0" || radio2_apcli="apcli0"
    fi
    if [ -z "$radio5_apcli" ]; then
        [ "$radio5_main" = "ra0" ] && radio5_apcli="apcli0" || radio5_apcli="apclii0"
    fi

    # 更新状态到 nvram（供 Web UI 显示）
    cur_mode="AP-Client"
    cur_ssid=""
    cur_bssid=""
    cur_signal=""
    cur_quality="-"
    if [ -n "$(iwconfig "$radio5_apcli" 2>/dev/null | grep ESSID: | grep -v 'ESSID:""')" ]; then
        cur_ssid=$(iwconfig "$radio5_apcli" 2>/dev/null | awk -F'"' '/ESSID/ {print $2}')
        cur_bssid=$(iwconfig "$radio5_apcli" 2>/dev/null | sed -n '/'$radio5_apcli'/,/Rate/{/'$radio5_apcli'/n;/Rate/b;p}' | tr 'A-Z' 'a-z' | awk -F'point:' '/point/ {print $2}' | tr -d ' ')
        # 用 iwpriv 获取 RSSI（此驱动 iwconfig 不提供 Signal level）
        cur_signal=$(iwpriv "$radio5_apcli" stat 2>/dev/null | grep "RSSI" | awk -F'=' '{print $2}' | awk '{print $1}')
        cur_mode="5G AP-Client"
    elif [ -n "$(iwconfig "$radio2_apcli" 2>/dev/null | grep ESSID: | grep -v 'ESSID:""')" ]; then
        cur_ssid=$(iwconfig "$radio2_apcli" 2>/dev/null | awk -F'"' '/ESSID/ {print $2}')
        cur_bssid=$(iwconfig "$radio2_apcli" 2>/dev/null | sed -n '/'$radio2_apcli'/,/Rate/{/'$radio2_apcli'/n;/Rate/b;p}' | tr 'A-Z' 'a-z' | awk -F'point:' '/point/ {print $2}' | tr -d ' ')
        # 用 iwpriv 获取 RSSI
        cur_signal=$(iwpriv "$radio2_apcli" stat 2>/dev/null | grep "RSSI" | awk -F'=' '{print $2}' | awk '{print $1}')
        cur_mode="2G AP-Client"
    fi
    # 信号强度处理：有效值大于 -127
    if [ -n "$cur_signal" ] && [ "$cur_signal" -gt -127 ] 2>/dev/null; then
        rssi_val="$cur_signal"
        cur_signal="${cur_signal}dBm"
        # 根据 RSSI 估算连接质量百分比
        # -30dBm≈100%, -50dBm≈80%, -70dBm≈40%, -90dBm≈0%
        rssi_abs=$(( -rssi_val ))
        if [ $rssi_abs -le 30 ]; then
            cur_quality="100%"
        elif [ $rssi_abs -le 40 ]; then
            cur_quality="90%"
        elif [ $rssi_abs -le 50 ]; then
            cur_quality="80%"
        elif [ $rssi_abs -le 60 ]; then
            cur_quality="65%"
        elif [ $rssi_abs -le 70 ]; then
            cur_quality="50%"
        elif [ $rssi_abs -le 80 ]; then
            cur_quality="35%"
        elif [ $rssi_abs -le 90 ]; then
            cur_quality="20%"
        else
            cur_quality="5%"
        fi
    else
        cur_signal="-"
        cur_quality="-"
    fi
    [ -z "$cur_bssid" ] && cur_bssid="-"
    [ -z "$cur_ssid" ] && cur_ssid="-"

    # 重新加载配置（支持运行时修改，优先从 nvram 读取 WebUI 保存的配置）
    # 必须在状态更新之前执行，确保 apcount 反映最新配置
    reload_nvram_list=$(nvram get ap_relay_list)
    if [ -n "$reload_nvram_list" ]; then
        echo "$reload_nvram_list" | grep -v '^#' | grep -v "^$" > /tmp/ap2g5g
        # 同步到持久化文件（仅在内容变化时写入，避免频繁写 flash）
        if [ ! -f /etc/storage/ap_relay.conf ] || [ "$(cat /etc/storage/ap_relay.conf 2>/dev/null)" != "$reload_nvram_list" ]; then
            echo "$reload_nvram_list" > /etc/storage/ap_relay.conf 2>/dev/null
        fi
    elif [ -f /etc/storage/ap_relay.conf ]; then
        grep -v '^#' /etc/storage/ap_relay.conf 2>/dev/null | grep -v "^$" > /tmp/ap2g5g
    fi

    ap_count=$(grep -v '^#' /tmp/ap2g5g 2>/dev/null | grep -v "^$" | wc -l)
    nvram set ap_relay_status="{\"daemon\":\"运行中\",\"mode\":\"$cur_mode\",\"ssid\":\"$cur_ssid\",\"bssid\":\"$cur_bssid\",\"signal\":\"$cur_signal\",\"quality\":\"$cur_quality\",\"apcount\":\"$ap_count\"}"

    # 检查相关进程状态
    ap_script_num=$(ps | grep -E "[a]p_script.sh" | wc -l)
    sh_ezscript_num=$(ps | grep -E "[s]h_ezscript.sh" | wc -l)

    # ap_script.sh 不在运行时清理 lock
    if [ "$ap_script_num" = "0" ]; then
        rm -f /tmp/apc.lock
    fi

    ap_check=$(nvram get ap_check)

    # ===== 模式1：中继信号断开时自动搜寻 =====
    if [ "$ap_check" = "1" ] && [ ! -f /tmp/apc.lock ]; then
        a2=$(ifconfig | grep "$radio2_apcli")
        sleep 1
        a5=$(ifconfig | grep "$radio5_apcli")
        sleep 1
        if [ -z "$a2" ] && [ -z "$a5" ]; then
            logger -t "【AP 中继】" "连接中断，启动自动搜寻"
            [ "$sh_ezscript_num" = "0" ] && /usr/bin/sh_ezscript.sh connAPSite_scan &
            sleep 10
        fi
    fi

    # ===== 定时搜寻最优信号 =====
    ap_time_check="$(nvram get ap_time_check)"
    if [ "$ap_time_check" -ge 9 ] 2>/dev/null && [ ! -f /tmp/apc.lock ]; then
        ap_fenge="$(nvram get ap_fenge)"
        first_line=$(grep -v '^#' /tmp/ap2g5g 2>/dev/null | grep -v "^$" | head -1)
        target_ssid=$(echo "$first_line" | cut -d "$ap_fenge" -f4)
        target_bssid=$(echo "$first_line" | cut -d "$ap_fenge" -f6 | tr 'A-Z' 'a-z')

        # 根据首行配置确定当前使用的接口
        if [ "$(echo "$first_line" | cut -d "$ap_fenge" -f1)" = "5" ]; then
            cur_apcli="$radio5_apcli"
        else
            cur_apcli="$radio2_apcli"
        fi

        cur_ssid="$(iwconfig "$cur_apcli" 2>/dev/null | awk -F'"' '/ESSID/ {print $2}')"
        sleep 1
        cur_bssid="$(iwconfig "$cur_apcli" 2>/dev/null | sed -n '/'$cur_apcli'/,/Rate/{/'$cur_apcli'/n;/Rate/b;p}' | tr 'A-Z' 'a-z' | awk -F'point:' '/point/ {print $2}')"
        sleep 1
        cur_bssid="$(echo "$cur_bssid")"

        # 已连接到最优先信号则跳过本次搜寻
        [ -n "$target_ssid" ] && [ -n "$cur_ssid" ] && [ "$target_ssid" = "$cur_ssid" ] && ap_time_check=0
        [ -n "$target_bssid" ] && [ -n "$cur_bssid" ] && [ "$target_bssid" = "$cur_bssid" ] && ap_time_check=0

        if [ "$ap_time_check" -ge 9 ] 2>/dev/null && [ ! -f /tmp/apc.lock ]; then
            logger -t "【连接 AP】" "${ap_time_check}秒后自动搜寻，直到连上最优先信号 ${target_ssid}"
            sleep "$ap_time_check"
            [ "$sh_ezscript_num" = "0" ] && /usr/bin/sh_ezscript.sh connAPSite_scan &
            sleep 10
        fi
    fi

    # ===== 模式0：Internet 断线后自动搜寻 =====
    if [ "$ap_check" = "0" ] && [ ! -f /tmp/apc.lock ]; then
        ping_text=$(ping -4 223.5.5.5 -c 1 -w 4 -q 2>/dev/null)
        ping_time=$(echo "$ping_text" | awk -F '/' '{print $4}' | awk -F '.' '{print $1}')
        if [ -z "$ping_time" ]; then
            logger -t "【AP 中继】" "Internet 断线，启动自动搜寻"
            [ "$sh_ezscript_num" = "0" ] && /usr/bin/sh_ezscript.sh connAPSite_scan &
            sleep 10
        fi
    fi

    # ===== 智能切换：信号阈值触发 + 漫游保护 + 连接质量评估 =====
    # 每2次循环(30秒)评估一次，避免频繁扫描导致瞬断
    smart_switch_count=$(( ${smart_switch_count:-0} + 1 ))
    if [ "$smart_switch_count" -ge 2 ] && [ ! -f /tmp/apc.lock ]; then
        smart_switch_count=0
        if [ "$(nvram get ap_auto_switch)" = "1" ]; then
            [ "$sh_ezscript_num" = "0" ] && /usr/bin/sh_ezscript.sh smart_switch &
        fi
    fi

    sleep 15
done

logger -t "【AP 中继】" "配置列表为空，守护进程退出"
DAEMON_EOF
    chmod 755 "$DAEMON_SCRIPT"
}

# ============================================================
# 主流程
# ============================================================

main() {
# 1. 初始化默认参数
init_nvram_defaults

# 2. 加载配置
load_config

# 3. 检查当前是否为 AP-Client 模式
rt_mode_x=$(nvram get rt_mode_x)
wl_mode_x=$(nvram get wl_mode_x)
if [ "${rt_mode_x:-0}" -le 2 ] && [ "${wl_mode_x:-0}" -le 2 ]; then
    # 非 AP-Client 模式，不启动守护
    exit 0
fi

# 4. 配置列表为空则不启动
if [ ! -s "$AP_LIST_FILE" ]; then
    logger -t "【AP 中继】" "未配置中继 AP 列表，跳过启动"
    exit 0
fi

# 5. 防重复运行
if check_daemon_running; then
    logger -t "【AP 中继】" "守护进程已在运行，跳过重复启动"
    exit 0
fi

# 6. 清理残留 lock
clean_stale_lock

# 7. 杀掉旧的守护进程（保险）
killall sh_apauto.sh 2>/dev/null

# 8. 生成并启动守护进程
generate_daemon_script
echo $$ > "$PID_FILE"
"$DAEMON_SCRIPT" "$1" &

# 9. 等待守护进程结束后清理 PID
wait
rm -f "$PID_FILE"
}

# 仅在直接执行时运行主流程，被 source 时只定义函数
case "$0" in
    *ap_script.sh) main "$@" ;;
esac
