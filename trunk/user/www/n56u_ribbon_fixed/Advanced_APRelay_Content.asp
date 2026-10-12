<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_1_7#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
	init_itoggle('ap_relay_enable');
	toggle_smart_switch();
	toggle_quality_check();
});

var aprelay_scanning = false;

function initial(){
	show_banner(1);
	show_menu(5,4,7);
	show_footer();
	load_body();
	refresh_status();
}

function applyRule(){
	// 验证：启用AP中继前必须先开启无线桥接
	var enableVal = $j('input[name="ap_relay_enable"]:checked').val();
	if(enableVal == '1'){
		var rtMode = parseInt($j('#rt_mode_x').val()) || 0;
		var wlMode = parseInt($j('#wl_mode_x').val()) || 0;
		// 3=AP-Client, 4=AP-Client+AP
		if(rtMode < 3 && wlMode < 3){
			alert('<#aprelay_need_bridge#>');
			return;
		}
	}
	showLoading();
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "/Advanced_APRelay_Content.asp";
	document.form.next_page.value = "";
	document.form.submit();
}

// 清空AP列表配置并直接保存生效
function clear_ap_list(){
	if(!confirm('<#aprelay_clear_confirm#>')) return;
	var ta = document.getElementById('ap_relay_list');
	if(ta){ ta.value = ''; }
	applyRule();
}

function done_validating(action){
	refreshpage();
}

// Status display
function refresh_status(manual){
	var startTime = Date.now();
	if(manual){
		var btn = document.getElementById('btn_refresh');
		if(btn){ btn.disabled = true; btn.innerHTML = '<#aprelay_refreshing#>'; }
	}
	$j('#status_daemon').text('<#aprelay_refreshing#>');
	$j.ajax({
		url: '/ap_relay_status.asp',
		dataType: 'text',
		timeout: 8000,
		cache: false,
		success: function(text){
			var data = null;
			try {
				// nvram_get_x 会把 " 编码成 &#34;，需要先解码 HTML 实体
				var decoded = text.replace(/&#(\d+);/g, function(m, num){
					return String.fromCharCode(num);
				});
				data = $j.parseJSON($j.trim(decoded));
			} catch(e) {
				data = null;
			}
			if(data){
				if(aprelay_scanning){
					$j('#status_daemon').text('<#aprelay_scanning#>');
				} else {
					$j('#status_daemon').text(data.daemon || '<#aprelay_not_running#>');
				}
				$j('#status_mode').text(data.mode || '-');
				$j('#status_ssid').text(data.ssid || '-');
				$j('#status_bssid').text(data.bssid || '-');
				$j('#status_signal').text(data.signal || '-');
				$j('#status_quality').text(data.quality || '-');
				$j('#status_apcount').text(data.apcount || '0');
			} else {
				$j('#status_daemon').text('<#aprelay_get_failed#>');
			}
		},
		error: function(){
			$j('#status_daemon').text('<#aprelay_get_failed#>');
		},
		complete: function(){
			if(manual){
				// 至少显示3秒
				var elapsed = Date.now() - startTime;
				var delay = Math.max(0, 3000 - elapsed);
				setTimeout(function(){
					var btn = document.getElementById('btn_refresh');
					if(btn){ btn.disabled = false; btn.innerHTML = '<#aprelay_refresh#>'; }
				}, delay);
			}
		}
	});
}

// <#aprelay_scan_now#>
function do_scan(){
	var apListEl = document.getElementById('ap_relay_list');
	var apList = apListEl ? apListEl.value.trim() : '';
	if(!apList){
		alert('<#aprelay_no_config#>');
		return;
	}
	aprelay_scanning = true;
	$j('#status_daemon').text('<#aprelay_scanning#>');
	// 按钮短暂提示3秒后恢复，扫描状态通过守护进程字段显示
	var btnScan = document.getElementById('btn_scan');
	if(btnScan){ btnScan.disabled = true; btnScan.innerHTML = '<#aprelay_scanning#>'; }
	setTimeout(function(){
		if(btnScan){ btnScan.disabled = false; btnScan.innerHTML = '<#aprelay_scan_now#>'; }
	}, 3000);
	$j.ajax({
		url: '/start_apply.htm',
		type: 'POST',
		data: { action_mode: 'SystemCmd', SystemCmd: 'nohup /usr/bin/sh_ezscript.sh connAPSite_scan >/dev/null 2>&1 &', current_page: '/Advanced_APRelay_Content.asp' },
		complete: function(){
			// connAPSite 先 sleep 10 秒再扫描，多次刷新获取最新状态
			setTimeout(refresh_status, 5000);
			setTimeout(refresh_status, 12000);
			setTimeout(refresh_status, 20000);
			setTimeout(function(){
				aprelay_scanning = false;
				refresh_status();
			}, 28000);
		}
	});
}

// <#aprelay_restart_daemon#>
function do_restart(){
	if(!confirm('<#aprelay_confirm_restart#>')) return;
	var btnRestart = document.querySelector('button[onclick*="do_restart"]');
	if(btnRestart){ btnRestart.disabled = true; btnRestart.innerHTML = '<#aprelay_restarting#>'; }
	$j.ajax({
		url: '/start_apply.htm',
		type: 'POST',
		data: { action_mode: 'SystemCmd', SystemCmd: 'killall sh_apauto.sh ap_script.sh 2>/dev/null; sleep 1; nohup /usr/bin/ap_script.sh >/dev/null 2>&1 &', current_page: '/Advanced_APRelay_Content.asp' },
		complete: function(){
			setTimeout(function(){
				if(btnRestart){ btnRestart.disabled = false; btnRestart.innerHTML = '<#aprelay_restart_daemon#>'; }
				refresh_status();
			}, 3000);
		}
	});
}

// Smart switch toggle linkage
function toggle_smart_switch(){
	var enabled = $j('#ap_auto_switch').is(':checked');
	$j('.smart-switch-field').prop('disabled', !enabled);
	$j('.smart-switch-field').closest('tr').find('td').css('opacity', enabled ? '1' : '0.5');
}

// Quality check toggle linkage
function toggle_quality_check(){
	var enabled = $j('#ap_quality_check').is(':checked');
	$j('.quality-field').prop('disabled', !enabled);
	$j('.quality-field').closest('tr').find('td').css('opacity', enabled ? '1' : '0.5');
}

// Scan nearby APs (table style, same as OperationMode)
var ap_scan_busy = 0;
var ap_scan_data = { '2': [], '5': [] };

function scan_aps(band){
	if(ap_scan_busy) return;
	ap_scan_busy = 1;
	var scan_url = (band == '5') ? '/wds_aplist.asp' : '/wds_aplist_2g.asp';
	var tbl_id = (band == '5') ? '#ap_list_5g' : '#ap_list_2g';
	var btn_id = (band == '5') ? '#btn_scan_5g' : '#btn_scan_2g';
	$j(btn_id).prop('disabled', true).text("<#AP_scanning#>");
	$j(tbl_id + ' tbody').html('<tr><td colspan="6"><#AP_scanning#>...</td></tr>');

	if(window.wds_aplist) delete window.wds_aplist;

	var script = document.createElement('script');
	script.type = 'text/javascript';
	script.src = scan_url + '?t=' + (new Date()).getTime();

	var done = false;
	var timeoutId = setTimeout(function(){ on_finish(false); }, 30000);

	function on_finish(ok){
		if(done) return;
		done = true;
		clearTimeout(timeoutId);
		if(script.parentNode) script.parentNode.removeChild(script);
		try {
			if(ok && window.wds_aplist && window.wds_aplist.length > 0
			   && !(window.wds_aplist.length == 1 && window.wds_aplist[0][0] == '')){
				ap_scan_data[band] = window.wds_aplist;
				render_ap_list(band);
			} else if(ok){
				$j(tbl_id + ' tbody').html('<tr><td colspan="6"><#AP_no_ap_found#></td></tr>');
			} else {
				$j(tbl_id + ' tbody').html('<tr><td colspan="6"><#AP_scan_failed#></td></tr>');
			}
		} catch(e){
			$j(tbl_id + ' tbody').html('<tr><td colspan="6"><#AP_scan_failed#></td></tr>');
		}
		ap_scan_busy = 0;
		$j(btn_id).prop('disabled', false).text((band == '5') ? '<#aprelay_scan_5g#>' : '<#aprelay_scan_2g#>');
	}

	script.onload = function(){ on_finish(true); };
	script.onerror = function(){ on_finish(false); };
	document.head.appendChild(script);
}

function decode_ssid(s){
	if(!s) return s;
	try { return decodeURIComponent(s); } catch(e) { return s; }
}

function escape_html(s){
	if(!s) return '';
	return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}

function render_ap_list(band){
	var tbl_id = (band == '5') ? '#ap_list_5g' : '#ap_list_2g';
	var list = ap_scan_data[band];
	var html = '';
	if(!list || list.length == 0 || (list.length == 1 && list[0][0] == '')){
		html = '<tr><td colspan="6"><#AP_no_ap_found#></td></tr>';
	} else {
		list.sort(function(a,b){ return parseInt(b[3]) - parseInt(a[3]); });
		for(var i = 0; i < list.length; i++){
			var ssid = escape_html(decode_ssid(list[i][0]));
			if(typeof ssid != 'string') ssid = String(ssid || '');
			var bssid = escape_html(list[i][1] || '');
			var channel = escape_html(list[i][2] || '');
			var signal = escape_html(list[i][3] || '');
			html += '<tr>'
				+ '<td>' + (i+1) + '</td>'
				+ '<td style="text-align:left;padding-left:8px;">' + ssid + '</td>'
				+ '<td>' + bssid + '</td>'
				+ '<td>' + channel + '</td>'
				+ '<td>' + signal + '%</td>'
				+ '<td><button type="button" class="btn btn-mini btn-primary" onclick="select_ap(' + i + ',\'' + band + '\')"><#aprelay_select_btn#></button></td>'
				+ '</tr>';
		}
	}
	$j(tbl_id + ' tbody').html(html);
}

function select_ap(num, band){
	var list = ap_scan_data[band];
	if(!list || !list[num]) return;
	var ssid = decode_ssid(list[num][0]);
	var bssid = list[num][1];
	// Format: Band@Mode@ClientRole@SSID@Password@BSSID
	// Mode: 3=AP-Client 4=AP-Client+AP | Role: 0=LAN bridge 1=WAN
	var line = band + "@4@1@" + ssid + "@@" + bssid;
	var ta = document.form.ap_relay_list;
	if(ta.value && ta.value.trim() != "")
		ta.value += "\n" + line;
	else
		ta.value = line;
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
    <input type="hidden" id="rt_mode_x" value="<% nvram_get_x("", "rt_mode_x"); %>">
    <input type="hidden" id="wl_mode_x" value="<% nvram_get_x("", "wl_mode_x"); %>">

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
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top"><#menu5_1#> - <#menu5_1_7#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                        <div id="tabMenu" class="submenuBlock"></div>
                        <div class="alert alert-info" style="margin: 10px;">
                          <span style="color: #d14; font-weight: bold;"><#aprelay_notice_0#></span></br>
                          <#aprelay_notice_1#>
                        </div>

                        <!-- Enable toggle -->
                        <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table" style="margin-top: 10px;">
                            <tr>
                                <th width="50%" style="border-top: 0 none;"><#aprelay_auto_start#></th>
                                <td style="border-top: 0 none;">
                                    <div class="main_itoggle">
                                        <div id="ap_relay_enable_on_of">
                                            <input type="checkbox" id="ap_relay_enable_fake" <% nvram_match_x("", "ap_relay_enable", "1", "value=1 checked"); %><% nvram_match_x("", "ap_relay_enable", "0", "value=0"); %>>
                                        </div>
                                    </div>
                                    <div style="position: absolute; margin-left: -10000px;">
                                        <input type="radio" name="ap_relay_enable" id="ap_relay_enable_1" class="input" value="1" <% nvram_match_x("", "ap_relay_enable", "1", "checked"); %>/><#checkbox_Yes#>
                                        <input type="radio" name="ap_relay_enable" id="ap_relay_enable_0" class="input" value="0" <% nvram_match_x("", "ap_relay_enable", "0", "checked"); %>/><#checkbox_No#>
                                    </div>
                                </td>
                            </tr>
                        </table>

                        <!-- Status display -->
                        <fieldset>
                            <legend><#aprelay_current_status#></legend>
                            <table class="table table-bordered table-condensed" style="table-layout: fixed;">
                                <tr>
                                    <th style="width: 20%;"><#aprelay_daemon#></th>
                                    <td style="width: 30%;"><span id="status_daemon"><#aprelay_checking#></span></td>
                                    <th style="width: 20%;"><#aprelay_current_mode#></th>
                                    <td style="width: 30%;"><span id="status_mode">-</span></td>
                                </tr>
                                <tr>
                                    <th><#aprelay_conn_ssid#></th>
                                    <td><span id="status_ssid">-</span></td>
                                    <th><#aprelay_conn_bssid#></th>
                                    <td><span id="status_bssid">-</span></td>
                                </tr>
                                <tr>
                                    <th><#aprelay_signal#></th>
                                    <td><span id="status_signal">-</span></td>
                                    <th><#aprelay_conn_quality#></th>
                                    <td><span id="status_quality">-</span></td>
                                </tr>
                                <tr>
                                    <th><#aprelay_config_ap_count#></th>
                                    <td><span id="status_apcount">0</span></td>
                                    <th><#aprelay_action#></th>
                                    <td>
                                        <button type="button" id="btn_refresh" class="btn btn-mini btn-info" onclick="refresh_status(true);"><#aprelay_refresh#></button>
                                        <button type="button" id="btn_scan" class="btn btn-mini btn-info" onclick="do_scan();"><#aprelay_scan_now#></button>
                                        <button type="button" class="btn btn-mini btn-warning" onclick="do_restart();"><#aprelay_restart_daemon#></button>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <!-- AP list config -->
                        <fieldset>
                            <legend><#aprelay_ap_list_config#></legend>
                            <p style="font-size: 12px; color: #666; margin-bottom: 2px;">
                                <#aprelay_param_hint#>
                            </p>
                            <p style="font-size: 12px; color: #666; margin-top: 0;">
                                <#aprelay_format_hint#>
                            </p>
                            <textarea id="ap_relay_list" name="ap_relay_list" rows="10" style="width: 98%; font-family: monospace; font-size: 12px; margin-bottom: 10px;"><% nvram_get_x("", "ap_relay_list"); %></textarea>
                            <div style="margin-bottom: 10px;">
                                <button type="button" id="btn_scan_2g" class="btn btn-mini btn-info" onclick="scan_aps('2');"><#aprelay_scan_2g#></button>
                                <button type="button" id="btn_scan_5g" class="btn btn-mini btn-info" onclick="scan_aps('5');"><#aprelay_scan_5g#></button>
                                <span style="font-size: 11px; color: #999; margin-left: 10px;"><#aprelay_scan_hint#></span>
                            </div>
                            <table id="ap_list_2g" class="table table-striped table-bordered table-condensed" style="margin-bottom: 10px; table-layout: fixed;">
                                <thead><tr><th style="width:15%;"># 2.4GHz</th><th style="width:30%; text-align:left;padding-left:8px;"><#AP_ssid#></th><th style="width:25%;">BSSID</th><th style="width:10%;"><#AP_channel#></th><th style="width:10%;"><#AP_signal#></th><th style="width:10%;"></th></tr></thead>
                                <tbody><tr><td colspan="6"></td></tr></tbody>
                            </table>
                            <table id="ap_list_5g" class="table table-striped table-bordered table-condensed" style="margin-bottom: 10px; table-layout: fixed;">
                                <thead><tr><th style="width:15%;"># 5GHz</th><th style="width:30%; text-align:left;padding-left:8px;"><#AP_ssid#></th><th style="width:25%;">BSSID</th><th style="width:10%;"><#AP_channel#></th><th style="width:10%;"><#AP_signal#></th><th style="width:10%;"></th></tr></thead>
                                <tbody><tr><td colspan="6"></td></tr></tbody>
                            </table>
                        </fieldset>

                        <!-- Basic parameters -->
                        <fieldset>
                            <legend><#aprelay_basic_params#></legend>
                            <table class="table table-bordered table-condensed" style="table-layout: fixed;">
                                <tr>
                                    <th style="width: 30%;"><#aprelay_trigger_condition#></th>
                                    <td style="width: 70%;">
                                        <select name="ap_check">
                                            <option value="0" <% nvram_match_x("", "ap_check", "0", "selected"); %>><#aprelay_trigger_inet_down#></option>
                                            <option value="1" <% nvram_match_x("", "ap_check", "1", "selected"); %>><#aprelay_trigger_signal_down#></option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_success_condition#></th>
                                    <td>
                                        <select name="ap_inet_check">
                                            <option value="0" <% nvram_match_x("", "ap_inet_check", "0", "selected"); %>><#aprelay_success_connected#></option>
                                            <option value="1" <% nvram_match_x("", "ap_inet_check", "1", "selected"); %>><#aprelay_success_internet#></option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_scan_interval#></th>
                                    <td>
                                        <input type="text" name="ap_time_check" value="<% nvram_get_x("", "ap_time_check"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;"><#aprelay_interval_hint#></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_scan_sort#></th>
                                    <td>
                                        <select name="ap_rule">
                                            <option value="0" <% nvram_match_x("", "ap_rule", "0", "selected"); %>><#aprelay_sort_config_order#></option>
                                            <option value="1" <% nvram_match_x("", "ap_rule", "1", "selected"); %>><#aprelay_sort_strongest#></option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_blacklist#></th>
                                    <td>
                                        <label class="checkbox inline">
                                            <input type="checkbox" name="ap_black" value="1" <% nvram_match_x("", "ap_black", "1", "checked"); %>>
                                            <#aprelay_blacklist_enable#>
                                        </label>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <!-- Smart switch parameters -->
                        <fieldset>
                            <legend><#aprelay_smart_switch#></legend>
                            <table class="table table-bordered table-condensed" style="table-layout: fixed;">
                                <tr>
                                    <th style="width: 30%;"><#aprelay_smart_switch#></th>
                                    <td style="width: 70%;">
                                        <label class="checkbox inline">
                                            <input type="checkbox" id="ap_auto_switch" name="ap_auto_switch" value="1" <% nvram_match_x("", "ap_auto_switch", "1", "checked"); %> onclick="toggle_smart_switch();">
                                            <#aprelay_switch_enable#>
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_switch_threshold#></th>
                                    <td>
                                        <input type="text" class="smart-switch-field" name="ap_switch_threshold" value="<% nvram_get_x("", "ap_switch_threshold"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;"><#aprelay_threshold_hint#></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_switch_hysteresis#></th>
                                    <td>
                                        <input type="text" class="smart-switch-field" name="ap_switch_hysteresis" value="<% nvram_get_x("", "ap_switch_hysteresis"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;"><#aprelay_hysteresis_hint#></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_roaming_protect#></th>
                                    <td>
                                        <input type="text" class="smart-switch-field" name="ap_roam_protect" value="<% nvram_get_x("", "ap_roam_protect"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;"><#aprelay_roaming_hint#></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_quality_check#></th>
                                    <td>
                                        <label class="checkbox inline">
                                            <input type="checkbox" id="ap_quality_check" class="smart-switch-field" name="ap_quality_check" value="1" <% nvram_match_x("", "ap_quality_check", "1", "checked"); %> onclick="toggle_quality_check();">
                                            <#aprelay_quality_check_enable#>
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_loss_threshold#></th>
                                    <td>
                                        <input type="text" class="quality-field" name="ap_quality_ping_loss" value="<% nvram_get_x("", "ap_quality_ping_loss"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;"><#aprelay_loss_hint#></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th><#aprelay_delay_threshold#></th>
                                    <td>
                                        <input type="text" class="quality-field" name="ap_quality_ping_delay" value="<% nvram_get_x("", "ap_quality_ping_delay"); %>" style="width: 80px;">
                                        <span style="font-size: 11px; color: #999; margin-left: 8px;"><#aprelay_delay_hint#></span>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>

                        <!-- Save button -->
                        <div style="text-align: center; margin: 20px 0;">
                            <button type="button" class="btn btn-primary" onclick="applyRule();"><#aprelay_save_config#></button>
                            <button type="button" class="btn" onclick="clear_ap_list();"><#aprelay_reset#></button>
                        </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
</div>

<div id="footer"></div>
</body>
</html>
