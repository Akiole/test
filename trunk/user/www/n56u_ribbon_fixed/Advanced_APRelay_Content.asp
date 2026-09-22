<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - AP 中继自动守护</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>
var $j = jQuery.noConflict();

function initial(){
	show_banner(1);
	show_menu(5,2,4);
	show_footer();
	load_body();
	refresh_status();
}

function applyRule(){
	showLoading();
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "/Advanced_APRelay_Content.asp";
	document.form.next_page.value = "";
	document.form.submit();
}

function done_validating(action){
	refreshpage();
}

// 刷新状态显示
function refresh_status(){
	$j.ajax({
		url: '/ap_relay_status.asp',
		dataType: 'json',
		timeout: 5000,
		success: function(data){
			$j('#status_daemon').text(data.daemon || '未运行');
			$j('#status_mode').text(data.mode || '-');
			$j('#status_ssid').text(data.ssid || '-');
			$j('#status_bssid').text(data.bssid || '-');
			$j('#status_signal').text(data.signal || '-');
			$j('#status_quality').text(data.quality || '-');
			$j('#status_apcount').text(data.apcount || '0');
		},
		error: function(){
			$j('#status_daemon').text('获取失败');
		}
	});
}

// 立即扫描
function do_scan(){
	if(!confirm('确定要立即扫描并连接最优 AP 吗？扫描期间无线网络会瞬断。')) return;
	showLoading();
	$j.ajax({
		url: '/start_apply.htm',
		type: 'POST',
		data: { action_mode: 'SystemCmd', SystemCmd: 'if [ -x /etc/storage/sh_ezscript.sh ]; then /etc/storage/sh_ezscript.sh connAPSite_scan; else /usr/bin/sh_ezscript.sh connAPSite_scan; fi', current_page: '/Advanced_APRelay_Content.asp' },
		complete: function(){
			hideLoading();
			setTimeout(refresh_status, 3000);
		}
	});
}

// 重启守护
function do_restart(){
	if(!confirm('确定要重启 AP 中继守护进程吗？')) return;
	showLoading();
	$j.ajax({
		url: '/start_apply.htm',
		type: 'POST',
		data: { action_mode: 'SystemCmd', SystemCmd: 'killall sh_apauto.sh; if [ -x /etc/storage/ap_script.sh ]; then /etc/storage/ap_script.sh & else /usr/bin/ap_script.sh & fi', current_page: '/Advanced_APRelay_Content.asp' },
		complete: function(){
			hideLoading();
			setTimeout(refresh_status, 3000);
		}
	});
}

// 查看日志
function show_log(){
	$j.ajax({
		url: '/ap_relay_log.asp',
		success: function(data){
			alert(data);
		},
		error: function(){
			alert('无法获取日志');
		}
	});
}

// 智能切换开关联动
function toggle_smart_switch(){
	var enabled = $j('#ap_auto_switch').is(':checked');
	$j('.smart-switch-field').prop('disabled', !enabled);
	$j('.smart-switch-field').closest('tr').find('td').css('opacity', enabled ? '1' : '0.5');
}

// 质量检查开关联动
function toggle_quality_check(){
	var enabled = $j('#ap_quality_check').is(':checked');
	$j('.quality-field').prop('disabled', !enabled);
	$j('.quality-field').closest('tr').find('td').css('opacity', enabled ? '1' : '0.5');
}
</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9" >
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
    <form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
    <input type="hidden" name="current_page" value="/Advanced_APRelay_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="APRelayConfig;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <div class="well sidebar-nav side_nav" style="padding: 0px;">
                    <ul id="mainMenu" class="clearfix"></ul>
                    <ul class="clearfix">
                        <li>
                            <div id="subMenu" class="accordion"></div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="span9">
                <div class="row-fluid">
                    <div class="span12">
                        <h3>AP 中继自动守护</h3>

                        <!-- 状态显示 -->
                        <fieldset>
                            <legend>当前状态</legend>
                            <table class="table table-bordered table-condensed" style="table-layout: fixed;">
                                <tr>
                                    <th style="width: 20%;">守护进程</th>
                                    <td style="width: 30%;"><span id="status_daemon">检查中...</span></td>
                                    <th style="width: 20%;">当前模式</th>
                                    <td style="width: 30%;"><span id="status_mode">-</span></td>
                                </tr>
                                <tr>
                                    <th>连接 SSID</th>
                                    <td><span id="status_ssid">-</span></td>
                                    <th>连接 BSSID</th>
                                    <td><span id="status_bssid">-</span></td>
                                </tr>
                                <tr>
                                    <th>信号强度</th>
                                    <td><span id="status_signal">-</span></td>
                                    <th>连接质量</th>
                                    <td><span id="status_quality">-</span></td>
                                </tr>
                                <tr>
                                    <th>配置 AP 数</th>
                                    <td><span id="status_apcount">0</span></td>
                                    <th>操作</th>
                                    <td>
                                        <button type="button" class="btn btn-mini" onclick="refresh_status();">刷新</button>
                                        <button type="button" class="btn btn-mini btn-info" onclick="do_scan();">立即扫描</button>
                                        <button type="button" class="btn btn-mini btn-warning" onclick="do_restart();">重启守护</button>
                                        <button type="button" class="btn btn-mini" onclick="show_log();">查看日志</button>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <!-- AP 列表配置 -->
                        <fieldset>
                            <legend>AP 列表配置</legend>
                            <p style="font-size: 12px; color: #666;">
                                各参数用 @ 分隔，多个 AP 换行填写（第一行最优先）。搜寻时无线网络会瞬断一下。<br>
                                格式：频段@工作模式@客户端角色@SSID@密码@BSSID<br>
                                频段：2=2.4GHz 5=5GHz | 模式：3=AP-Client 4=AP-Client+AP | 角色：0=LAN bridge 1=WAN
                            </p>
                            <textarea name="ap_relay_list" rows="8" style="width: 100%; font-family: monospace; font-size: 12px;"><% nvram_get_x("", "ap_relay_list"); %></textarea>
                        </fieldset>

                        <!-- 基础参数 -->
                        <fieldset>
                            <legend>基础参数</legend>
                            <table class="table table-bordered table-condensed" style="table-layout: fixed;">
                                <tr>
                                    <th style="width: 30%;">守护触发条件</th>
                                    <td style="width: 70%;">
                                        <select name="ap_check">
                                            <option value="0" <% nvram_match_x("", "ap_check", "0", "selected"); %>>Internet 断线后搜寻</option>
                                            <option value="1" <% nvram_match_x("", "ap_check", "1", "selected"); %>>信号断开时搜寻</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th>定时搜寻间隔(秒)</th>
                                    <td>
                                        <input type="text" name="ap_time_check" value="<% nvram_get_x("", "ap_time_check"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;">0=成功后停止，≥10=每隔N秒搜寻最优信号</span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>搜寻排序</th>
                                    <td>
                                        <select name="ap_rule">
                                            <option value="0" <% nvram_match_x("", "ap_rule", "0", "selected"); %>>按配置顺序（首行最优先）</option>
                                            <option value="1" <% nvram_match_x("", "ap_rule", "1", "selected"); %>>自动连接最强信号</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th>黑名单功能</th>
                                    <td>
                                        <label class="checkbox inline">
                                            <input type="checkbox" name="ap_black" value="1" <% nvram_match_x("", "ap_black", "1", "checked"); %>>
                                            启用（无法联网的 AP 自动加入黑名单）
                                        </label>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <!-- 智能切换参数 -->
                        <fieldset>
                            <legend>智能切换（第二阶段）</legend>
                            <table class="table table-bordered table-condensed" style="table-layout: fixed;">
                                <tr>
                                    <th style="width: 30%;">智能切换</th>
                                    <td style="width: 70%;">
                                        <label class="checkbox inline">
                                            <input type="checkbox" id="ap_auto_switch" name="ap_auto_switch" value="1" <% nvram_match_x("", "ap_auto_switch", "1", "checked"); %> onclick="toggle_smart_switch();">
                                            启用（信号低于阈值且有更强信号时自动切换）
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <th>切换信号阈值(dBm)</th>
                                    <td>
                                        <input type="text" class="smart-switch-field" name="ap_switch_threshold" value="<% nvram_get_x("", "ap_switch_threshold"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;">当前信号低于此值时触发扫描评估（默认 -75）</span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>切换迟滞(dBm)</th>
                                    <td>
                                        <input type="text" class="smart-switch-field" name="ap_switch_hysteresis" value="<% nvram_get_x("", "ap_switch_hysteresis"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;">候选信号需比当前强多少才切换，避免临界震荡（默认 10）</span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>漫游保护(秒)</th>
                                    <td>
                                        <input type="text" class="smart-switch-field" name="ap_roam_protect" value="<% nvram_get_x("", "ap_roam_protect"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;">切换后多久内不再切换，防止频繁切换（默认 60）</span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>连接质量检查</th>
                                    <td>
                                        <label class="checkbox inline">
                                            <input type="checkbox" id="ap_quality_check" class="smart-switch-field" name="ap_quality_check" value="1" <% nvram_match_x("", "ap_quality_check", "1", "checked"); %> onclick="toggle_quality_check();">
                                            启用（ping 延迟/丢包率评估，质量差也触发切换）
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <th>丢包率阈值(%)</th>
                                    <td>
                                        <input type="text" class="quality-field" name="ap_quality_ping_loss" value="<% nvram_get_x("", "ap_quality_ping_loss"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;">超过则认为质量差（默认 50）</span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>延迟阈值(ms)</th>
                                    <td>
                                        <input type="text" class="quality-field" name="ap_quality_ping_delay" value="<% nvram_get_x("", "ap_quality_ping_delay"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;">超过则认为质量差（默认 200）</span>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <!-- 保存按钮 -->
                        <div style="text-align: center; margin: 20px 0;">
                            <button type="button" class="btn btn-primary" onclick="applyRule();">保存配置</button>
                            <button type="reset" class="btn">重置</button>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
</div>

<script>
// 页面加载后初始化开关联动状态
$j(document).ready(function(){
	toggle_smart_switch();
	toggle_quality_check();
});
</script>

</body>
</html>
