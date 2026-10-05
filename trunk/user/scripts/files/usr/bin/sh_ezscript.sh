#!/bin/sh
# ============================================================
# sh_ezscript.sh — Padavan 扩展脚本集合
# 包含 AP 中继自动连接、按钮事件、系统工具等功能
# ============================================================

# ============================================================
# 辅助函数：扫描指定无线接口周围的 AP
# 参数: $1=无线接口名(ra0/rai0)
# 输出: 扫描结果文本
# ============================================================
survey_radio() {
	local radio_if="$1"
	local result=""

	iwpriv "$radio_if" set SiteSurvey=1 2>/dev/null
	sleep 1
	result=$(iwpriv "$radio_if" get_site_survey 2>/dev/null)

	# 扫描失败时重试两次
	if echo "$result" | grep -q "No BssInfo"; then
		sleep 2
		result=$(iwpriv "$radio_if" get_site_survey 2>/dev/null)
	fi
	if echo "$result" | grep -q "No BssInfo"; then
		sleep 3
		result=$(iwpriv "$radio_if" get_site_survey 2>/dev/null)
	fi

	echo "$result"
}

# ============================================================
# 辅助函数：在扫描结果中查找指定 SSID/BSSID 的 AP
# 参数: $1=扫描结果文本, $2=SSID, $3=BSSID(可选,小写)
# 输出: 匹配的行文本，空表示未找到
# ============================================================
find_ap_in_survey() {
	local survey="$1"
	local ssid="$2"
	local bssid="$3"
	local result=""

	if [ -n "$ssid" ] && [ -n "$bssid" ]; then
		# SSID + BSSID 同时匹配
		result=$(echo "$survey" | grep -Eo '[0-9]*[\ ]*'"$ssid"'.*' | tr 'A-Z' 'a-z' | sed -n "/$bssid/p" | sed -n '1p')
	elif [ -n "$bssid" ]; then
		# 仅 BSSID 匹配
		result=$(echo "$survey" | tr 'A-Z' 'a-z' | sed -n "/$bssid/p" | sed -n '1p')
	elif [ -n "$ssid" ]; then
		# 仅 SSID 匹配
		result=$(echo "$survey" | grep -Eo '[0-9]*[\ ]*'"$ssid"'.*' | tr 'A-Z' 'a-z' | sed -n '1p')
	fi

	echo "$result"
}

# ============================================================
# 辅助函数：解析扫描结果表头，计算各列字符偏移
# 参数: $1=表头行文本
# 全局输出: ap_ch_ac/ap_ch_c 等偏移量
# ============================================================
parse_survey_header() {
	local header="$1"

	# 信道列
	ap_ch_ac=$(awk -v a="$header" -v b="Ch" 'BEGIN{print index(a,b)}')
	ap_ch_b=$(echo "$header" | grep -Eo "Ch *" | sed -n '1p')
	ap_ch_bc=$(echo "$ap_ch_b" | wc -c)
	ap_ch_bc=$(( ${ap_ch_bc:-0} - 1 ))
	ap_ch_c=$(( ${ap_ch_ac:-0} + ${ap_ch_bc:-0} - 1 ))

	# SSID 列
	ap_ssid_ac=$(awk -v a="$header" -v b="SSID" 'BEGIN{print index(a,b)}')
	ap_ssid_b=$(echo "$header" | grep -Eo "SSID *" | sed -n '1p')
	ap_ssid_bc=$(echo "$ap_ssid_b" | wc -c)
	ap_ssid_bc=$(( ${ap_ssid_bc:-0} - 1 ))
	ap_ssid_c=$(( ${ap_ssid_ac:-0} + ${ap_ssid_bc:-0} - 1 ))

	# BSSID 列
	ap_bssid_ac=$(awk -v a="$header" -v b="BSSID" 'BEGIN{print index(a,b)}')
	ap_bssid_b=$(echo "$header" | grep -Eo "BSSID *" | sed -n '1p')
	ap_bssid_bc=$(echo "$ap_bssid_b" | wc -c)
	ap_bssid_bc=$(( ${ap_bssid_bc:-0} - 1 ))
	ap_bssid_c=$(( ${ap_bssid_ac:-0} + ${ap_bssid_bc:-0} - 1 ))

	# Security 列
	ap_security_ac=$(awk -v a="$header" -v b="Security" 'BEGIN{print index(a,b)}')
	ap_security_b=$(echo "$header" | grep -Eo "Security *" | sed -n '1p')
	ap_security_bc=$(echo "$ap_security_b" | wc -c)
	ap_security_bc=$(( ${ap_security_bc:-0} - 1 ))
	ap_security_c=$(( ${ap_security_ac:-0} + ${ap_security_bc:-0} - 1 ))

	# Signal 列
	ap_signal_ac=$(awk -v a="$header" -v b="Signal" 'BEGIN{print index(a,b)}')
	ap_signal_b="Signal(%)"
	ap_signal_bc=$(echo "$ap_signal_b" | wc -c)
	ap_signal_bc=$(( ${ap_signal_bc:-0} - 1 ))
	ap_signal_c=$(( ${ap_signal_ac:-0} + ${ap_signal_bc:-0} - 1 ))

	# W-Mode 列
	ap_wmode_ac=$(awk -v a="$header" -v b="W-Mode" 'BEGIN{print index(a,b)}')
	ap_wmode_b=$(echo "$header" | grep -Eo "W-Mode *" | sed -n '1p')
	ap_wmode_bc=$(echo "$ap_wmode_b" | wc -c)
	ap_wmode_bc=$(( ${ap_wmode_bc:-0} - 1 ))
	ap_wmode_c=$(( ${ap_wmode_ac:-0} + ${ap_wmode_bc:-0} - 1 ))
}

# ============================================================
# 辅助函数：从扫描结果行中提取各字段
# 参数: $1=扫描结果行
# 全局输出: Ch/SSID/BSSID/Security/Signal/WMode
# ============================================================
parse_survey_line() {
	local line="$1"
	Ch=$(echo "$line" | cut -b "$ap_ch_ac-$ap_ch_c")
	SSID=$(echo "$line" | cut -b "$ap_ssid_ac-$ap_ssid_c")
	BSSID=$(echo "$line" | cut -b "$ap_bssid_ac-$ap_bssid_c")
	Security=$(echo "$line" | cut -b "$ap_security_ac-$ap_security_c")
	Signal=$(echo "$line" | cut -b "$ap_signal_ac-$ap_signal_c")
	WMode=$(echo "$line" | cut -b "$ap_wmode_ac-$ap_wmode_c")
}

# ============================================================
# 辅助函数：检查当前是否已连接到指定 AP
# 参数: $1=频段(2/5), $2=SSID, $3=BSSID(小写)
# 返回: 0=已连接, 1=未连接
# ============================================================
check_already_connected() {
	local radio="$1"
	local ssid="$2"
	local bssid="$3"
	local apcli_if

	if [ "$radio" = "2" ]; then
		apcli_if="$radio2_apcli"
	else
		apcli_if="$radio5_apcli"
	fi

	# 按 SSID 检查
	if [ -n "$(iwconfig "$apcli_if" 2>/dev/null | grep ESSID: | grep "$ssid")" ]; then
		return 0
	fi
	# 按 BSSID 检查
	if [ -n "$(iwconfig "$apcli_if" 2>/dev/null | sed -n '/'$apcli_if'/,/Rate/{/'$apcli_if'/n;/Rate/b;p}' | tr 'A-Z' 'a-z' | grep "$bssid")" ]; then
		return 0
	fi
	return 1
}

# ============================================================
# 辅助函数：根据 Security 字符串推断认证/加密参数
# 参数: $1=Security 字符串
# 全局输出: rtwlt_sta_auth_mode/rtwlt_sta_wpa_mode/rtwlt_sta_crypto
# ============================================================
parse_security() {
	local sec="$1"

	rtwlt_sta_auth_mode=""
	rtwlt_sta_wpa_mode=""
	rtwlt_sta_crypto=""

	# Open / None
	if echo "$sec" | grep -qi "none" || echo "$sec" | grep -qi "open"; then
		rtwlt_sta_auth_mode="open"
		rtwlt_sta_wpa_mode="0"
	fi
	# WPA-PSK
	if echo "$sec" | grep -qi "1psk" || echo "$sec" | grep -qi "wpapsk"; then
		rtwlt_sta_auth_mode="psk"
		rtwlt_sta_wpa_mode="1"
	fi
	# WPA2-PSK
	if echo "$sec" | grep -qi "2psk"; then
		rtwlt_sta_auth_mode="psk"
		rtwlt_sta_wpa_mode="2"
	fi
	# TKIP
	if echo "$sec" | grep -qi "tkip"; then
		rtwlt_sta_crypto="tkip"
	fi
	# AES
	if echo "$sec" | grep -qi "aes"; then
		rtwlt_sta_crypto="aes"
	fi
}

# ============================================================
# 辅助函数：连接到指定 AP（设置 nvram + 重启无线）
# 参数: $1=频段(2/5), $2=信道, $3=模式, $4=角色, $5=SSID,
#       $6=密码, $7=认证模式, $8=WPA模式, $9=加密方式
# ============================================================
connect_to_ap() {
	local radio="$1"
	local channel="$2"
	local mode="$3"
	local wisp="$4"
	local ssid="$5"
	local psk="$6"
	local auth_mode="$7"
	local wpa_mode="$8"
	local crypto="$9"

	if [ "$radio" = "2" ]; then
		nvram set rt_channel="$channel"
		iwpriv "$radio2_apcli" set Channel="$channel" 2>/dev/null
		nvram set rt_mode_x="$mode"
		nvram set rt_sta_wisp="$wisp"
		nvram set rt_sta_ssid="$ssid"
		nvram set rt_sta_auth_mode="$auth_mode"
		nvram set rt_sta_wpa_mode="$wpa_mode"
		nvram set rt_sta_crypto="$crypto"
		nvram set rt_sta_wpa_psk="$psk"
		# 强制 20MHz 提高中继兼容性
		nvram set rt_HT_BW=0
		nvram commit
		rc radio2_restart
	else
		nvram set wl_channel="$channel"
		iwpriv "$radio5_apcli" set Channel="$channel" 2>/dev/null
		nvram set wl_mode_x="$mode"
		nvram set wl_sta_wisp="$wisp"
		nvram set wl_sta_ssid="$ssid"
		nvram set wl_sta_auth_mode="$auth_mode"
		nvram set wl_sta_wpa_mode="$wpa_mode"
		nvram set wl_sta_crypto="$crypto"
		nvram set wl_sta_wpa_psk="$psk"
		nvram commit
		rc radio5_restart
	fi
}

# ============================================================
# 主函数：扫描并连接到配置列表中的 AP
# 参数: $1="scan" 表示强制扫描（即使已连接）
# ============================================================
connAPSite () {
	. /usr/bin/ap_script.sh
	logger -t "【连接 AP】" "10秒后自动搜寻 AP"
	sleep 10

	# ---- 初始化接口名（自动检测） ----
	ap_fenge=$(nvram get ap_fenge)
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
	# 自动检测 2.4G AP-Client 接口
	if [ -z "$radio2_apcli" ]; then
		if [ "$radio2_main" = "rax0" ]; then
			radio2_apcli="apclix0"
		else
			radio2_apcli="apcli0"
		fi
	fi
	# 自动检测 5G AP-Client 接口
	if [ -z "$radio5_apcli" ]; then
		if [ "$radio5_main" = "ra0" ]; then
			radio5_apcli="apcli0"
		else
			radio5_apcli="apclii0"
		fi
	fi

	# 加载配置（优先从 nvram 同步到临时文件）
	load_config 2>/dev/null
	cat /tmp/ap2g5g.txt 2>/dev/null | grep -v '^#' | grep -v "^$" > /tmp/ap2g5g

	# ---- 检查 lock 和配置 ----
	if [ -f /tmp/apc.lock ] || [ ! -s /tmp/ap2g5g ]; then
		return
	fi
	touch /tmp/apc.lock

	# ---- 检查当前是否已连接 ----
	a2=$(iwconfig "$radio2_apcli" 2>/dev/null | awk -F'"' '/ESSID/ {print $2}')
	a5=$(iwconfig "$radio5_apcli" 2>/dev/null | awk -F'"' '/ESSID/ {print $2}')
	if [ -n "$a2" ] || [ -n "$a5" ]; then
		ap_connected=0
	else
		ap_connected=1
	fi

	# 非强制扫描且已连接时，不执行扫描
	if [ "$ap_connected" = "0" ] && [ "$1" != "scan" ]; then
		rm -f /tmp/apc.lock
		return
	fi

	# ---- 扫描周围 AP ----
	wds_aplist2g=""
	wds_aplist5g=""
	aplist_n=""

	if [ -n "$(grep -v '^#' /tmp/ap2g5g 2>/dev/null | cut -d "$ap_fenge" -f1 | grep "^2$")" ]; then
		logger -t "【连接 AP】" "扫描 2.4G ($radio2_main)"
		wds_aplist2g=$(survey_radio "$radio2_main")
		aplist_n=$(echo "$wds_aplist2g" | sed -n '2p')
	fi

	if [ -n "$(grep -v '^#' /tmp/ap2g5g 2>/dev/null | cut -d "$ap_fenge" -f1 | grep "^5$")" ]; then
		logger -t "【连接 AP】" "扫描 5G ($radio5_main)"
		wds_aplist5g=$(survey_radio "$radio5_main")
		[ -z "$aplist_n" ] && aplist_n=$(echo "$wds_aplist5g" | sed -n '2p')
	fi

	# 解析表头偏移
	[ -n "$aplist_n" ] && parse_survey_header "$aplist_n"

	ap_rule=$(nvram get ap_rule)
	ap3=1  # 标记是否需要继续搜寻(1=继续, 0=已找到可连接的)

	# ===== 模式1：最强信号自动连接 =====
	if [ "$ap_rule" = "1" ]; then
		echo -n "" > /tmp/ap2g5g_site_survey
		echo -n "" > /tmp/ap2g5g_apc

		# 在 2G 扫描结果中查找配置列表里的 AP
		if [ -n "$wds_aplist2g" ]; then
			echo "$wds_aplist2g" | while read -r i_a; do
				[ -z "$i_a" ] && continue
				[ -s /tmp/ap2g5g_site_survey ] && continue
				for i_b in $(grep -v '^#' /tmp/ap2g5g 2>/dev/null | grep -v "^$" | grep "^2"); do
					[ -z "$i_b" ] && continue
					[ -s /tmp/ap2g5g_apc ] && continue
					cfg_ssid=$(echo "$i_b" | cut -d "$ap_fenge" -f4)
					cfg_bssid=$(echo "$i_b" | cut -d "$ap_fenge" -f6 | tr 'A-Z' 'a-z')
					match=$(find_ap_in_survey "$i_a" "$cfg_ssid" "$cfg_bssid")
					if [ -n "$match" ]; then
						echo "$match" > /tmp/ap2g5g_site_survey
						echo "$i_b" > /tmp/ap2g5g_apc
					fi
				done
			done
		fi

		# 在 5G 扫描结果中查找
		if [ -n "$wds_aplist5g" ] && [ ! -s /tmp/ap2g5g_site_survey ]; then
			echo "$wds_aplist5g" | while read -r i_a; do
				[ -z "$i_a" ] && continue
				[ -s /tmp/ap2g5g_site_survey ] && continue
				for i_b in $(grep -v '^#' /tmp/ap2g5g 2>/dev/null | grep -v "^$" | grep "^5"); do
					[ -z "$i_b" ] && continue
					[ -s /tmp/ap2g5g_apc ] && continue
					cfg_ssid=$(echo "$i_b" | cut -d "$ap_fenge" -f4)
					cfg_bssid=$(echo "$i_b" | cut -d "$ap_fenge" -f6 | tr 'A-Z' 'a-z')
					match=$(find_ap_in_survey "$i_a" "$cfg_ssid" "$cfg_bssid")
					if [ -n "$match" ]; then
						echo "$match" > /tmp/ap2g5g_site_survey
						echo "$i_b" > /tmp/ap2g5g_apc
					fi
				done
			done
		fi
	fi

	# ===== 遍历配置列表，尝试连接 =====
	while read -r line; do
		# 跳过注释和空行
		echo "$line" | grep -q '^#' && continue
		[ -z "$(echo "$line" | tr -d ' ')" ] && continue

		# 最强信号模式：使用匹配到的那一行配置
		if [ "$ap_rule" = "1" ]; then
			apc=$(cat /tmp/ap2g5g_apc 2>/dev/null)
			site_survey=$(cat /tmp/ap2g5g_site_survey 2>/dev/null)
		else
			apc="$line"
			site_survey=""
		fi

		# 解析配置参数
		radio=$(echo "$apc" | cut -d "$ap_fenge" -f1)
		rtwlt_mode_x=$(echo "$apc" | cut -d "$ap_fenge" -f2)
		rtwlt_sta_wisp=$(echo "$apc" | cut -d "$ap_fenge" -f3)
		rtwlt_sta_ssid=$(echo "$apc" | cut -d "$ap_fenge" -f4)
		rtwlt_sta_wpa_psk=$(echo "$apc" | cut -d "$ap_fenge" -f5)
		rtwlt_sta_bssid=$(echo "$apc" | cut -d "$ap_fenge" -f6 | tr 'A-Z' 'a-z')

		# 按顺序模式：在扫描结果中查找当前配置的 AP
		if [ "$ap_rule" != "1" ]; then
			if [ "$radio" = "2" ]; then
				site_survey=$(find_ap_in_survey "$wds_aplist2g" "$rtwlt_sta_ssid" "$rtwlt_sta_bssid")
			else
				site_survey=$(find_ap_in_survey "$wds_aplist5g" "$rtwlt_sta_ssid" "$rtwlt_sta_bssid")
			fi
		fi

		# 未找到匹配的 AP，跳过
		if [ -z "$site_survey" ]; then
			continue
		fi

		# 解析扫描结果
		parse_survey_line "$site_survey"

		# 检查是否已连接
		if check_already_connected "$radio" "$rtwlt_sta_ssid" "$rtwlt_sta_bssid"; then
			ap3=1  # 已连接，标记为不需要切换
		else
			ap3=0  # 未连接，需要连接
		fi

		# 黑名单检查
		ap_black=$(nvram get ap_black)
		if [ "$ap_black" = "1" ] && [ -f /tmp/apblack.txt ]; then
			black_match=$(grep "【SSID:$rtwlt_sta_bssid" /tmp/apblack.txt 2>/dev/null)
			[ -z "$black_match" ] && black_match=$(grep "【SSID:$rtwlt_sta_ssid" /tmp/apblack.txt 2>/dev/null)
			if [ -n "$black_match" ]; then
				logger -t "【连接 AP】" "跳过黑名单 AP: $rtwlt_sta_ssid"
				ap3=1
			fi
		fi

		# 需要连接
		if [ "$ap3" != "1" ]; then
			# 推断认证/加密参数
			parse_security "$Security"

			logger -t "【连接 AP】" "正在连接: 频段=$radio 模式=$rtwlt_mode_x 角色=$rtwlt_sta_wisp SSID=$rtwlt_sta_ssid"

			# 执行连接
			connect_to_ap "$radio" "$Ch" "$rtwlt_mode_x" "$rtwlt_sta_wisp" \
				"$rtwlt_sta_ssid" "$rtwlt_sta_wpa_psk" \
				"$rtwlt_sta_auth_mode" "$rtwlt_sta_wpa_mode" "$rtwlt_sta_crypto"

			logger -t "【连接 AP】" "配置: 认证=$rtwlt_sta_auth_mode WPA=$rtwlt_sta_wpa_mode 加密=$rtwlt_sta_crypto"
			sleep 7
			logger -t "【连接 AP】" "目标: 信道=$Ch SSID=$SSID BSSID=$BSSID"
			logger -t "【连接 AP】" "信号: 安全=$Security 强度=$Signal% 模式=$WMode"

			# 黑名单验证：连接后检查是否能联网
			if [ "$ap_black" = "1" ]; then
				sleep 7
				ping_text=$(ping -4 223.5.5.5 -c 1 -w 4 -q 2>/dev/null)
				ping_time=$(echo "$ping_text" | awk -F '/' '{print $4}' | awk -F '.' '{print $1}')
				if [ -n "$ping_time" ]; then
					logger -t "【连接 AP】" "已连接 $rtwlt_sta_ssid，联网正常"
				else
					logger -t "【连接 AP】" "已连接 $rtwlt_sta_ssid，但无法联网，加入黑名单"
					echo "AP不联网: 信道=$Ch SSID=$SSID BSSID=$BSSID 安全=$Security 信号=$Signal% 模式=$WMode" >> /tmp/apblack.txt
				fi
			fi

			# 清理 lock 并重启守护进程
			rm -f /tmp/apc.lock
			/usr/bin/ap_script.sh &
			exit
		fi

		# 最强信号模式只处理一次
		if [ "$ap_rule" = "1" ]; then
			rm -f /tmp/apc.lock
			exit
		fi
	done < /tmp/ap2g5g

	# 遍历完所有配置都未连接成功，清理 lock
	rm -f /tmp/apc.lock
}

# ============================================================
# 辅助函数：获取当前连接的信号强度(dBm)
# 输出: 信号强度数值(如 -55)，空表示未连接
# ============================================================
get_current_signal_dbm() {
	local apcli_if=""
	local signal=""

	if [ -n "$(iwconfig "$radio5_apcli" 2>/dev/null | grep ESSID: | grep -v 'ESSID:""')" ]; then
		apcli_if="$radio5_apcli"
	elif [ -n "$(iwconfig "$radio2_apcli" 2>/dev/null | grep ESSID: | grep -v 'ESSID:""')" ]; then
		apcli_if="$radio2_apcli"
	fi

	[ -z "$apcli_if" ] && return

	# 优先用 iwconfig 获取（部分驱动支持）
	signal=$(iwconfig "$apcli_if" 2>/dev/null | grep "Signal level" | awk -F'=' '{print $NF}' | awk '{print $1}')

	# Ralink 驱动 iwconfig 不含 Signal level，改用 iwpriv 获取 RSSI
	# 格式: RSSI = -24 -31 -127 -127，取第一个有效值（-127 表示无效）
	if [ -z "$signal" ]; then
		local rssi_raw=$(iwpriv "$apcli_if" stat 2>/dev/null | grep "RSSI" | awk -F'=' '{print $2}')
		for val in $rssi_raw; do
			if [ "$val" != "-127" ] 2>/dev/null; then
				signal="$val"
				break
			fi
		done
	fi

	echo "$signal"
}

# ============================================================
# 辅助函数：获取当前连接的 SSID
# ============================================================
get_current_ssid() {
	local ssid=""
	ssid=$(iwconfig "$radio5_apcli" 2>/dev/null | awk -F'"' '/ESSID/ {print $2}')
	[ -z "$ssid" ] && ssid=$(iwconfig "$radio2_apcli" 2>/dev/null | awk -F'"' '/ESSID/ {print $2}')
	echo "$ssid"
}

# ============================================================
# 辅助函数：信号百分比转 dBm
# ============================================================
signal_pct_to_dbm() {
	local pct="$1"
	echo $(( pct / 2 - 80 ))
}

# ============================================================
# 辅助函数：检查漫游保护期
# 返回: 0=在保护期内, 1=保护期已过
# ============================================================
check_roam_protect() {
	local protect_time=$(nvram get ap_roam_protect)
	[ -z "$protect_time" ] && protect_time=60

	if [ -f /tmp/ap_last_switch ]; then
		local last_time=$(cat /tmp/ap_last_switch 2>/dev/null)
		local now_time=$(date +%s)
		if [ -n "$last_time" ]; then
			local elapsed=$(( now_time - last_time ))
			[ "$elapsed" -lt "$protect_time" ] && return 0
		fi
	fi
	return 1
}

# ============================================================
# 辅助函数：标记漫游保护开始
# ============================================================
mark_roam_protect() {
	date +%s > /tmp/ap_last_switch
}

# ============================================================
# 辅助函数：评估当前连接质量（ping 测试）
# 输出: "good" 或 "bad"
# ============================================================
eval_connection_quality() {
	local quality_enable=$(nvram get ap_quality_check)
	[ "$quality_enable" != "1" ] && echo "good" && return

	local loss_threshold=$(nvram get ap_quality_ping_loss)
	local delay_threshold=$(nvram get ap_quality_ping_delay)
	[ -z "$loss_threshold" ] && loss_threshold=50
	[ -z "$delay_threshold" ] && delay_threshold=200

	local ping_result=$(ping -4 223.5.5.5 -c 3 -w 3 -q 2>/dev/null)
	local loss=$(echo "$ping_result" | awk -F', ' '{print $3}' | awk '{print $1}' | tr -d '%')
	local avg_delay=$(echo "$ping_result" | awk -F '/' '{print $5}' | awk -F '.' '{print $1}')

	[ -n "$loss" ] && [ "$loss" -ge "$loss_threshold" ] 2>/dev/null && echo "bad" && return
	[ -n "$avg_delay" ] && [ "$avg_delay" -ge "$delay_threshold" ] 2>/dev/null && echo "bad" && return
	echo "good"
}

# ============================================================
# 智能切换评估：扫描周围 AP，如有更优信号则切换
# ============================================================
smart_switch_eval() {
	local auto_switch=$(nvram get ap_auto_switch)
	[ "$auto_switch" != "1" ] && return

	# 漫游保护期内不评估
	check_roam_protect && return

	# 加载配置
	. /usr/bin/ap_script.sh >/dev/null 2>&1
	[ ! -s /tmp/ap2g5g ] && return

	# 初始化接口名（自动检测，与 connAPSite 一致）
	ap_fenge=$(nvram get ap_fenge)
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
	# 自动检测 2.4G AP-Client 接口
	if [ -z "$radio2_apcli" ]; then
		if [ "$radio2_main" = "rax0" ]; then
			radio2_apcli="apclix0"
		else
			radio2_apcli="apcli0"
		fi
	fi
	# 自动检测 5G AP-Client 接口
	if [ -z "$radio5_apcli" ]; then
		if [ "$radio5_main" = "ra0" ]; then
			radio5_apcli="apcli0"
		else
			radio5_apcli="apclii0"
		fi
	fi

	# 获取当前信号
	local cur_signal=$(get_current_signal_dbm)
	local cur_ssid=$(get_current_ssid)
	[ -z "$cur_signal" ] && return

	local threshold=$(nvram get ap_switch_threshold)
	local hysteresis=$(nvram get ap_switch_hysteresis)
	[ -z "$threshold" ] && threshold=-75
	[ -z "$hysteresis" ] && hysteresis=10

	# 评估连接质量
	local quality=$(eval_connection_quality)

	# 信号好且质量好 → 不切换
	if [ "$cur_signal" -ge "$threshold" ] 2>/dev/null && [ "$quality" = "good" ]; then
		return
	fi

	logger -t "【智能切换】" "当前信号=${cur_signal}dBm 质量=${quality}，触发扫描评估"

	[ -f /tmp/apc.lock ] && return

	# 扫描周围 AP
	local wds_aplist2g=""
	local wds_aplist5g=""
	local aplist_n=""

	if [ -n "$(grep -v '^#' /tmp/ap2g5g 2>/dev/null | cut -d "$ap_fenge" -f1 | grep "^2$")" ]; then
		wds_aplist2g=$(survey_radio "$radio2_main")
		aplist_n=$(echo "$wds_aplist2g" | sed -n '2p')
	fi
	if [ -n "$(grep -v '^#' /tmp/ap2g5g 2>/dev/null | cut -d "$ap_fenge" -f1 | grep "^5$")" ]; then
		wds_aplist5g=$(survey_radio "$radio5_main")
		[ -z "$aplist_n" ] && aplist_n=$(echo "$wds_aplist5g" | sed -n '2p')
	fi

	[ -z "$aplist_n" ] && return
	parse_survey_header "$aplist_n"

	# 遍历配置列表，找到信号最强的候选 AP
	local best_signal_dbm=-200
	local best_ssid=""
	local best_line=""

	while read -r line; do
		echo "$line" | grep -q '^#' && continue
		[ -z "$(echo "$line" | tr -d ' ')" ] && continue

		local cfg_radio=$(echo "$line" | cut -d "$ap_fenge" -f1)
		local cfg_ssid=$(echo "$line" | cut -d "$ap_fenge" -f4)
		local cfg_bssid=$(echo "$line" | cut -d "$ap_fenge" -f6 | tr 'A-Z' 'a-z')

		# 跳过当前已连接的 AP
		[ -n "$cur_ssid" ] && [ "$cfg_ssid" = "$cur_ssid" ] && continue

		# 在扫描结果中查找
		local survey=""
		if [ "$cfg_radio" = "2" ]; then
			survey=$(find_ap_in_survey "$wds_aplist2g" "$cfg_ssid" "$cfg_bssid")
		else
			survey=$(find_ap_in_survey "$wds_aplist5g" "$cfg_ssid" "$cfg_bssid")
		fi

		[ -z "$survey" ] && continue

		parse_survey_line "$survey"
		local sig_pct=$(echo "$Signal" | tr -d ' ')
		local sig_dbm=$(signal_pct_to_dbm "$sig_pct")

		if [ "$sig_dbm" -gt "$best_signal_dbm" ] 2>/dev/null; then
			best_signal_dbm="$sig_dbm"
			best_ssid="$cfg_ssid"
			best_line="$line"
		fi
	done < /tmp/ap2g5g

	[ -z "$best_line" ] && return

	# 候选信号需比当前强迟滞值以上
	local diff=$(( best_signal_dbm - cur_signal ))
	if [ "$diff" -lt "$hysteresis" ] 2>/dev/null; then
		logger -t "【智能切换】" "候选 $best_ssid 信号=${best_signal_dbm}dBm，仅强 ${diff}dBm（需≥${hysteresis}），不切换"
		return
	fi

	logger -t "【智能切换】" "切换到更优 AP: $best_ssid 信号=${best_signal_dbm}dBm（当前 ${cur_signal}dBm，差值 ${diff}dBm）"

	mark_roam_protect

	# 将最优配置写入临时文件，调用 connAPSite 连接
	cp /tmp/ap2g5g /tmp/ap2g5g_backup
	echo "$best_line" > /tmp/ap2g5g
	connAPSite "scan"
	cp /tmp/ap2g5g_backup /tmp/ap2g5g
	rm -f /tmp/ap2g5g_backup
}

# ============================================================
# 命令分派
# ============================================================
case "$1" in
	1)
		button_1
		;;
	2)
		button_2
		;;
	3)
		button_3
		;;
	timesystem)
		timesystem
		;;
	serverchan)
		serverchan
		;;
	serverchan_clean)
		serverchan_clean
		;;
	relnmp)
		relnmp
		;;
	mkfs)
		mkfs
		;;
	reszUID)
		reszUID
		;;
	getAPSite2g)
		getAPSite "2g"
		;;
	getAPSite5g)
		getAPSite "5g"
		;;
	connAPSite)
		connAPSite
		;;
	connAPSite_scan)
		connAPSite "scan"
		;;
	smart_switch)
		smart_switch_eval
		;;
esac
