<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_6_1#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>
var $j = jQuery.noConflict();

function initial(){
	show_banner(2);
	show_menu(5,7,3);
	show_footer();

	if(sw_mode == '1' || sw_mode == '3'){
		showhide_div('wl_rt', 1);
		showhide_div('rt_wo_nat', 0);
	}else if(sw_mode == '4'){
		showhide_div('wl_rt', 0);
		showhide_div('rt_wo_nat', 1);
	}

	if(!support_5g_radio()){
		$j(".ap_5g_only").hide();
	}

	setScenerion(sw_mode);

	load_gateway_info();

	var o1 = document.form.sw_mode;
	var vd = support_btn_mode();
	o1[0].disabled = vd;
	o1[1].disabled = vd;
	o1[2].disabled = vd;
	document.form.button.disabled = vd;
}

function saveMode(){
	var o1 = document.form.sw_mode;
	if(sw_mode == '1'){
		if(o1[0].checked == true){
			alert("<#op_already_configured#>");
			return false;
		}
	}else if(sw_mode == '4'){
		if(o1[1].checked == true){
			alert("<#op_already_configured#>");
			return false;
		}
	}else if(sw_mode == '3'){
		if(o1[2].checked == true){
			alert("<#op_already_configured#>");
			return false;
		}
	}

	/* EasyMesh: auto-enable Agent when switching to AP mode; disable when leaving AP mode */
	if (o1[2].checked && document.form.mesh_enable.value == "1") {
		document.form.mesh_agent.value = "1";
	} else if (!o1[2].checked) {
		document.form.mesh_agent.value = "0";
	}

	showLoading();

	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "Advanced_OperationMode_Content.asp";
	document.form.next_page.value = "";

	document.form.submit();
}

function done_validating(action){
	refreshpage();
}

function setScenerion(mode){
	if(mode == '1' || mode == '4'){
		$j("#radio2").hide();
		$j("#Internet_span").css("display", "");
		$j("#ap-line").css("display", "none");
		$j(".AP").hide();
		$j("#ap_sync_section").hide();
		$j("#mode_desc").html("<#OP_GW_desc1#> <#OP_GW_desc2#>");
		$j("#nextButton").attr("value","<#CTL_next#>");
	}
	else if(mode == '3'){
		$j("#radio2").css("display", "none");
		$j("#Internet_span").css("display", "");
		$j("#ap-line").css("display", "none");
		$j(".AP").show();
		$j("#ap_sync_section").show();
		$j("#mode_desc").html("<#OP_AP_desc1#> <#OP_AP_desc2#>");
		$j("#nextButton").attr("value","<#CTL_next#>");
	}
}

var ap_scan_busy = 0;
var gateway_mac = '';

function load_gateway_info(){
	$j.ajax({
		url: '/ap_gateway.asp',
		dataType: 'text',
		timeout: 5000,
		cache: false,
		success: function(data){
			try {
				var info = eval('(' + data + ')');
				if(info && info.mac){
					gateway_mac = info.mac.toUpperCase();
				}
			} catch(e){}
		}
	});
}

function is_main_router(bssid){
	if(!gateway_mac || !bssid) return false;
	return (bssid.toUpperCase() == gateway_mac);
}

function scan_aps(band){
	if(ap_scan_busy) return;
	ap_scan_busy = 1;
	var scan_url = (band == 1) ? '/wds_aplist.asp' : '/wds_aplist_2g.asp';
	var tbl_id = (band == 1) ? '#ap_list_5g' : '#ap_list_2g';
	var btn_id = (band == 1) ? '#btn_scan_5g' : '#btn_scan_2g';
	$j(btn_id).prop('disabled', true).val("<#AP_scanning#>");
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
		if(ok && window.wds_aplist && window.wds_aplist.length > 0
		   && !(window.wds_aplist.length == 1 && window.wds_aplist[0][0] == '')){
			render_ap_list(band, window.wds_aplist);
		} else if(ok){
			$j(tbl_id + ' tbody').html('<tr><td colspan="6"><#AP_no_ap_found#></td></tr>');
		} else {
			$j(tbl_id + ' tbody').html('<tr><td colspan="6"><#AP_scan_failed#></td></tr>');
		}
		ap_scan_busy = 0;
		$j(btn_id).prop('disabled', false).val((band == 1) ? '<#AP_scan_5g#>' : '<#AP_scan_2g#>');
	}

	script.onload = function(){ on_finish(true); };
	script.onerror = function(){ on_finish(false); };
	document.head.appendChild(script);
}

function decode_ssid(s){
	if(!s) return s;
	try { return decodeURIComponent(s); } catch(e) { return s; }
}

function render_ap_list(band, list){
	var tbl_id = (band == 1) ? '#ap_list_5g' : '#ap_list_2g';
	var html = '';
	if(!list || list.length == 0 || (list.length == 1 && list[0][0] == '')){
		html = '<tr><td colspan="6"><#AP_no_ap_found#></td></tr>';
	} else {
		list.sort(function(a,b){
			var a_main = is_main_router(a[1]) ? 1 : 0;
			var b_main = is_main_router(b[1]) ? 1 : 0;
			if(a_main != b_main) return b_main - a_main;
			return parseInt(b[3]) - parseInt(a[3]);
		});
		for(var i = 0; i < list.length; i++){
			var ssid = decode_ssid(list[i][0]);
			if(typeof ssid != 'string') ssid = String(ssid || '');
			var bssid = list[i][1] || '';
			var channel = list[i][2] || '';
			var signal = list[i][3] || '';
			var main_router = is_main_router(bssid);
			var safe_ssid = ssid.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
			var row_class = main_router ? ' style="background-color:#dff0d8;"' : '';
			var ssid_html = ssid;
			if(main_router){
				ssid_html += ' <span class="label label-success"><#AP_main_router#></span>';
			}
			html += '<tr' + row_class + '>'
				+ '<td>' + (i+1) + '</td>'
				+ '<td style="text-align:left;padding-left:8px;">' + ssid_html + '</td>'
				+ '<td>' + bssid + '</td>'
				+ '<td>' + channel + '</td>'
				+ '<td>' + signal + '%</td>'
				+ '<td><button type="button" class="btn btn-mini btn-primary" onclick="sync_ssid(' + band + ',\'' + safe_ssid + '\',' + channel + ')">' + '<#AP_sync_btn#>' + '</button></td>'
				+ '</tr>';
		}
	}
	$j(tbl_id + ' tbody').html(html);
}

function sync_ssid(band, ssid, channel){
	var field_ssid = (band == 1) ? 'wl_ssid' : 'rt_ssid';
	var field_channel = (band == 1) ? 'wl_channel' : 'rt_channel';
	var field_psk = (band == 1) ? 'wl_wpa_psk' : 'rt_wpa_psk';
	var field_auth = (band == 1) ? 'wl_auth_mode' : 'rt_auth_mode';
	var field_wpa = (band == 1) ? 'wl_wpa_mode' : 'rt_wpa_mode';
	var field_crypto = (band == 1) ? 'wl_crypto' : 'rt_crypto';
	var label = (band == 1) ? '5GHz' : '2.4GHz';

	/* Prompt for Wi-Fi password (cannot be obtained from scan) */
	var psk = prompt('<#AP_sync_password_prompt#>', '');
	if (psk === null) return;  /* user cancelled */
	if (psk.length < 8) {
		alert('<#AP_sync_password_error#>');
		return;
	}

	document.form[field_ssid].value = ssid;
	document.form[field_channel].value = 0;  /* auto channel */
	document.form[field_psk].value = psk;
	document.form[field_auth].value = 'psk';
	document.form[field_wpa].value = '2';    /* WPA2 */
	document.form[field_crypto].value = 'aes';

	$j('#ap_sync_status_' + band).html('<span class="label label-success">' + label + ' <#AP_sync_success#>: ' + ssid + ' <#AP_sync_apply_hint#></span>');
}

</script>

<style>
table {width: 100%;}
table td {text-align: center; }
.ap-table th, .ap-table td { padding: 4px 6px; font-size: 12px; }
</style>

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
    <input type="hidden" name="sid_list" value="IPConnection;WLANConfig11a;WLANConfig11b;MeshConfig;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="prev_page" value="">
    <input type="hidden" name="current_page" value="/Advanced_OperationMode_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="flag" value="">
    <input type="hidden" name="lan_ipaddr" value="<% nvram_get_x("", "lan_ipaddr"); %>">
    <input type="hidden" name="rt_ssid" value="<% nvram_get_x("", "rt_ssid"); %>">
    <input type="hidden" name="rt_channel" value="<% nvram_get_x("", "rt_channel"); %>">
    <input type="hidden" name="rt_wpa_psk" value="<% nvram_get_x("", "rt_wpa_psk"); %>">
    <input type="hidden" name="rt_auth_mode" value="<% nvram_get_x("", "rt_auth_mode"); %>">
    <input type="hidden" name="rt_wpa_mode" value="<% nvram_get_x("", "rt_wpa_mode"); %>">
    <input type="hidden" name="rt_crypto" value="<% nvram_get_x("", "rt_crypto"); %>">
    <input type="hidden" name="wl_ssid" value="<% nvram_get_x("", "wl_ssid"); %>">
    <input type="hidden" name="wl_channel" value="<% nvram_get_x("", "wl_channel"); %>">
    <input type="hidden" name="wl_wpa_psk" value="<% nvram_get_x("", "wl_wpa_psk"); %>">
    <input type="hidden" name="wl_auth_mode" value="<% nvram_get_x("", "wl_auth_mode"); %>">
    <input type="hidden" name="wl_wpa_mode" value="<% nvram_get_x("", "wl_wpa_mode"); %>">
    <input type="hidden" name="wl_crypto" value="<% nvram_get_x("", "wl_crypto"); %>">
    <input type="hidden" name="mesh_enable" value="<% nvram_get_x("", "mesh_enable"); %>">
    <input type="hidden" name="mesh_agent" value="<% nvram_get_x("", "mesh_agent"); %>">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <!--Sidebar content-->
                <!--=====Beginning of Main Menu=====-->
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
                <!--Body content-->
                <div class="row-fluid">
                    <div class="span12">
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top"><#menu5_6#> - <#t2OP#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                        <div style="margin-left: 10px; margin-top: 10px;">
                                            <div class="controls">
                                                <label class="radio inline"><div id="wl_rt" style="display:none;"><input type="radio" name="sw_mode" class="input" value="1" onclick="setScenerion(1);" <% nvram_match_x("IPConnection", "sw_mode", "1", "checked"); %>><#OP_GW_item#></div></label>
                                                <label class="radio inline"><div id="rt_wo_nat" style="display:none;"><input type="radio" name="sw_mode" class="input" value="4" onclick="setScenerion(4);" <% nvram_match_x("IPConnection", "sw_mode", "4", "checked"); %>><#OP_GW_item#></div></label>
                                                <label class="radio inline"><div id="wl_ap"><input type="radio" name="sw_mode" class="input" value="3" onclick="setScenerion(3);" <% nvram_match_x("IPConnection", "sw_mode", "3", "checked"); %>><#OP_AP_item#></div></label>
                                            </div>

                                            <div id="mode_desc" style="margin-left: 0px; margin-top: 10px; margin-right: 10px;" class="alert alert-info"><#OP_GW_desc1#></div>
                                        </div>

                                        <div style="margin-top: 10px; margin-right: 10px; margin-left: 10px;">
                                            <center><div id="Senario" class="span12" style="height: 170px;">
                                                <div class="row-fluid">
                                                    <table style="width: 100%">
                                                        <tr>
                                                            <td><span class="label"><#Wireless_Clients#></span></td>
                                                            <td>&nbsp;</td>
                                                            <td><span class="label label-info"><#Web_Title#></span></td>
                                                            <td class="AP">&nbsp;</td>
                                                            <td class="AP"><span class="label"><#Device_type_02_RT#></span></td>
                                                            <td>&nbsp;</td>
                                                            <td id="Internet_span"><span class="label"><#Internet#></span></td>
                                                        </tr>
                                                        <tr>
                                                            <td><img src="bootstrap/img/wl_device/clients.png"></td>
                                                            <td><img src="bootstrap/img/wl_device/arrow-left.png"></td>
                                                            <td><img src="bootstrap/img/wl_device/n56u.png"></td>
                                                            <td class="AP"><img src="bootstrap/img/wl_device/arrow-left.png"></td>
                                                            <td class="AP"><img src="bootstrap/img/wl_device/server.png"></td>
                                                            <td><img src="bootstrap/img/wl_device/arrow-left.png"></td>
                                                            <td><img src="bootstrap/img/wl_device/globe.png"></td>
                                                        </tr>
                                                    </table>
                                                </div>

                                                <div id="ap-line" style="display: none;position: absolute; margin-left: -10000px"></div>
                                            </div></center>
                                        </div>

                                        <div id="ap_sync_section" style="display:none; margin: 15px 10px 10px 10px;">
                                            <div class="alert alert-info" style="margin-bottom: 8px;"><#AP_sync_desc#></div>

                                            <div style="margin-bottom: 8px;">
                                                <button type="button" id="btn_scan_2g" class="btn" onclick="scan_aps(0);"><#AP_scan_2g#></button>
                                                <button type="button" id="btn_scan_5g" class="btn ap_5g_only" onclick="scan_aps(1);"><#AP_scan_5g#></button>
                                            </div>

                                            <div id="ap_sync_status_0" style="margin-bottom: 6px;"></div>
                                            <table id="ap_list_2g" class="table table-striped table-bordered ap-table" style="margin-bottom: 15px; table-layout: fixed;">
                                                <thead><tr><th style="width:15%;"># 2.4GHz</th><th style="width:30%; text-align:left;padding-left:8px;"><#AP_ssid#></th><th style="width:25%;">BSSID</th><th style="width:10%;"><#AP_channel#></th><th style="width:10%;"><#AP_signal#></th><th style="width:10%;"></th></tr></thead>
                                                <tbody><tr><td colspan="6"></td></tr></tbody>
                                            </table>

                                            <div id="ap_sync_status_1" class="ap_5g_only" style="margin-bottom: 6px;"></div>
                                            <table id="ap_list_5g" class="table table-striped table-bordered ap-table ap_5g_only" style="table-layout: fixed;">
                                                <thead><tr><th style="width:15%;"># 5GHz</th><th style="width:30%; text-align:left;padding-left:8px;"><#AP_ssid#></th><th style="width:25%;">BSSID</th><th style="width:10%;"><#AP_channel#></th><th style="width:10%;"><#AP_signal#></th><th style="width:10%;"></th></tr></thead>
                                                <tbody><tr><td colspan="6"></td></tr></tbody>
                                            </table>
                                        </div>

                                        <center><input name="button" type="button" class="btn btn-primary" style="width: 219px;" onClick="saveMode();" value="<#CTL_onlysave#>"></center>
                                        <br/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    </form>

    <div id="footer"></div>
</div>
</body>
</html>
