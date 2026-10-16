<!DOCTYPE html>
<html>
<head>
<title></title>
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
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/wireless_2g.js"></script>
<script type="text/javascript" src="formcontrol.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
    var safe_wps_change = function() {
        try {
            rt_wps_change();
        } catch (e) {
            console.error("<#wps_error#>", e);
        }
    };

    init_itoggle('rt_radio_x', safe_wps_change);
    init_itoggle('rt_closed', safe_wps_change);
    init_itoggle('rt_WPS', safe_wps_change);
    init_itoggle('mesh_enable');

    wps_status_poll();
    setInterval(wps_status_poll, 10000);
});

</script>
<script>

var had_wrong_wep_key = false;

var wpsFailUntil = 0;

function wps_pbc(){
	var $button = $j('#btn_connect');
	if($button.hasClass('disabled') || $button.prop('disabled')) return;
	$button.button('loading');
	$j.getJSON('/wps_action.asp',function(response){
		var idTimeOut;
		if(response.status == 0) {
			$j('#wps_status_txt').text('<#wps_pairing#>');
			idTimeOut = setTimeout(function(){
				clearTimeout(idTimeOut);
				$button.removeClass('btn-info').addClass('btn-success');
				$button.button('reset');
				$button.addClass('wps-done');
				var idTimeOut2 = setTimeout(function(){
					clearTimeout(idTimeOut2);
					$button.removeClass('wps-done')
					       .removeClass('btn-success')
					       .removeClass('btn-info')
					       .addClass('btn-success');
				}, 2000);
			}, 30000);
		} else {
			wpsFailUntil = Date.now() + 4000;
			$j('#wps_status_txt').text('<#wps_failed#>');
			$button.removeClass('btn-success').addClass('btn-info');
			idTimeOut = setTimeout(function(){
				clearTimeout(idTimeOut);
				$button.button('reset');
				$button.removeClass('btn-success')
				       .removeClass('btn-info')
				       .addClass('btn-success');
			}, 2000);
		}
	})
}

function wps_status_poll(){
	$j.getJSON('/wps_status.asp',function(res){
		var el = $j('#wps_status_txt');
		if(!el.length) return;
		var btn = $j('#btn_connect');
		var s = res.status;
		if(Date.now() < wpsFailUntil) return;
		if(s >= 3){
			el.text('<#wps_pairing#>');
			if(!btn.hasClass('disabled')) btn.button('loading');
		} else {
			if(s == 2) el.text('<#wps_failed#>');
			else if(s == 34) el.text('<#wps_done#>');
			else el.text('<#wps_idle#>');
			if(btn.hasClass('disabled')) btn.button('reset');
		}
	});
}

function rt_wps_change(){
	var mode = document.form.rt_auth_mode.value;
	var rt_close = document.form.rt_closed.value;
	var rt_radio = document.form.rt_radio_x.value;

	if( rt_radio == 1 && (mode == "open" || mode == "psk") && rt_close == 0) {
		$("rt_WPS").style.display = "";
		$("wps_button").style.display = (document.form.rt_WPS.value == 0) ? "none" : "";
	} else {
		$j("label.itoggle")[2].click();
		$("rt_WPS").style.display = "none";
		$("wps_button").style.display = "none";
	}
}

<% wl_bssid_2g(); %>

function initial(){
	flash_button();
	loadXML();

	if (!support_5g_radio()) {
		$("tab_radio5g").style.display = "none";
	}

	if(parent.document.rt_form.rt_ssid.value == ""){
		document.form.rt_ssid.value = decodeURIComponent(document.form.rt_ssid2.value);
		document.form.rt_wpa_psk.value = decodeURIComponent(document.form.rt_wpa_psk_org.value);
		document.form.rt_key1.value = decodeURIComponent(document.form.rt_key1_org.value);
		document.form.rt_key2.value = decodeURIComponent(document.form.rt_key2_org.value);
		document.form.rt_key3.value = decodeURIComponent(document.form.rt_key3_org.value);
		document.form.rt_key4.value = decodeURIComponent(document.form.rt_key4_org.value);
	}
	else{
		document.form.rt_ssid.value = parent.document.rt_form.rt_ssid.value;
		document.form.rt_ssid2.value = parent.document.rt_form.rt_ssid2.value;
		document.form.rt_key_type.value = parent.document.rt_form.rt_key_type.value;
		document.form.rt_auth_mode.value = parent.document.rt_form.rt_auth_mode.value;
		document.form.rt_wpa_mode.value = parent.document.rt_form.rt_wpa_mode.value;
		document.form.rt_wep_x.value = parent.document.rt_form.rt_wep_x.value;
		document.form.rt_key.value = parent.document.rt_form.rt_key.value;
		document.form.rt_key1.value = parent.document.rt_form.rt_key1.value;
		document.form.rt_key2.value = parent.document.rt_form.rt_key2.value;
		document.form.rt_key3.value = parent.document.rt_form.rt_key3.value;
		document.form.rt_key4.value = parent.document.rt_form.rt_key4.value;
		document.form.rt_crypto.value = parent.document.rt_form.rt_crypto.value;
		document.form.rt_wpa_psk.value = parent.document.rt_form.rt_wpa_psk.value;
	}

	if(document.form.rt_wpa_psk.value.length <= 0)
		document.form.rt_wpa_psk.value = "Please type Password";

	if(document.form.rt_auth_mode.value == "psk"){
		var target_text;
		if(document.form.rt_wpa_mode.value == "0")
			target_text = "WPA/WPA2-Mixed";
		else if(document.form.rt_wpa_mode.value == "1")
			target_text = "WPA-Personal";
		else if(document.form.rt_wpa_mode.value == "5")
			target_text = "WPA3-Personal";
		else if(document.form.rt_wpa_mode.value == "6")
			target_text = "WPA2/WPA3-Mixed (*)";
		else
			target_text = "WPA2-Personal";
		for(var i = 0; i < document.form.rt_auth_mode.length; i++){
			if(document.form.rt_auth_mode.options[i].text == target_text){
				document.form.rt_auth_mode.selectedIndex = i;
				break;
			}
		}
	}

	rt_auth_mode_change(1);
	rt_wps_change();

	if(sw_mode == "3"){
		stopFlag = 1;
	}
	show_middle_status_router();
	show_LAN_info();
	domore_create();
}

function show_middle_status_router(){
	var auth_mode = document.form.rt_auth_mode_orig.value;
	var wpa_mode = document.form.rt_wpa_mode_orig.value;
	var wep_x = parseInt(document.form.rt_wep_x_orig.value);
	var security_mode;

	if(auth_mode == "open")
		security_mode = "Open System";
	else if(auth_mode == "shared")
		security_mode = "Shared Key";
	else if(auth_mode == "psk"){
		if(wpa_mode == "1")
			security_mode = "WPA-Personal";
		else if(wpa_mode == "2")
			security_mode = "WPA2-Personal";
		else if(wpa_mode == "5")
			security_mode = "WPA3-Personal";
		else if(wpa_mode == "0")
			security_mode = "WPA/WPA2-Mixed";
		else if(wpa_mode == "6")
			security_mode = "WPA2/WPA3-Mixed";
	}
	else if(auth_mode == "wpa"){
		if(wpa_mode == "3")
			security_mode = "WPA-Enterprise";
		else if(wpa_mode == "4")
			security_mode = "WPA/WPA2-Enterprise";
	}
	else if(auth_mode == "wpa2")
		security_mode = "WPA2-Enterprise";
	else if(auth_mode == "radius")
		security_mode = "Radius with 802.1x";
	else if(auth_mode == "owe")
		security_mode = "Enhanced Open";

	//parent.$("wl_securitylevel_span").innerHTML = security_mode;

	if(auth_mode == "open" && wep_x == 0){
		parent.$j("#wl_securitylevel_span").removeClass("badge badge-success");
		parent.$j("#wl_securitylevel_span").addClass("badge badge-important");
		parent.$j("#wl_securitylevel_span").html('<i class="icon-exclamation-sign icon-white"></i>');
	}else{
		parent.$j("#wl_securitylevel_span").removeClass("badge badge-important");
		parent.$j("#wl_securitylevel_span").addClass("badge badge-success");
		parent.$j("#wl_securitylevel_span").html('<i class="icon-lock icon-white"></i>');
	}
}

function domore_create(){
	if(get_ap_mode()){
		$("Router_domore").remove(6);
		$("Router_domore").remove(5);
		$("Router_domore").options[4].value="../Advanced_APLAN_Content.asp";
	}
}

function rt_auth_mode_change(isload){
	var mode = document.form.rt_auth_mode.value;
	var opts = document.form.rt_auth_mode.options;
	var new_array;
	var cur_pmf;
	var cur_crypto;
	var cur_key_index, cur_key_obj;

	if(mode == "open" || mode == "shared"){
		$("all_related_wep").style.display = "";
		$("all_wep_key").style.display = "";
		$("asus_wep_key").style.display = "";
		change_wep_type(mode);
	}
	else{
		$("all_related_wep").style.display = "none";
		$("all_wep_key").style.display = "none";
		$("asus_wep_key").style.display = "none";
	}

	if(mode == "wpa" || mode == "wpa2" || mode == "psk" || mode == "owe")
		$("rt_crypto").style.display = "";
	else
		$("rt_crypto").style.display = "none";

	if(mode == "psk")
		$("rt_wpa_psk").style.display = "";
	else
		$("rt_wpa_psk").style.display = "none";

	for(var i = 0; i < document.form.rt_pmf.length; ++i)
		if(document.form.rt_pmf[i].selected){
			cur_pmf = document.form.rt_pmf[i].value;
			break;
		}

	free_options(document.form.rt_pmf);
	$("rt_pmf").style.display = "";
	if(opts[opts.selectedIndex].text == "WPA2-Personal" || opts[opts.selectedIndex].text == "WPA2-Enterprise (Radius)" || opts[opts.selectedIndex].text == "WPA/WPA2-Enterprise (Radius)") {
		new_array = new Array("<#btn_Disable#>","<#PMF_Capable#>","<#PMF_Mandatory#>");
	} else if (opts[opts.selectedIndex].text == "WPA3-Personal" || opts[opts.selectedIndex].text == "Enhanced Open") {
		new_array = new Array("<#PMF_Mandatory#>");
	} else if (opts[opts.selectedIndex].text == "WPA2/WPA3-Mixed (*)") {
		new_array = new Array("<#PMF_Capable#>");
	} else {
		$("rt_pmf").style.display = "none";
		new_array = new Array("<#btn_Disable#>");
	}

	for(var i in new_array){
		var tmp;
		if (new_array[i] == "<#btn_Disable#>")
			tmp = 0;
		else if (new_array[i] == "<#PMF_Capable#>")
			tmp = 1;
		else
			tmp = 2;
		document.form.rt_pmf[i] = new Option(new_array[i], tmp);
		document.form.rt_pmf[i].value = tmp;
		if(tmp == cur_pmf)
			document.form.rt_pmf[i].selected = true;
	}

	for(var i = 0; i < document.form.rt_crypto.length; ++i)
		if(document.form.rt_crypto[i].selected){
			cur_crypto = document.form.rt_crypto[i].value;
			break;
		}

	if(mode == "psk"){
		if(opts[opts.selectedIndex].text == "WPA-Personal")
			new_array = new Array("TKIP");
		else if(opts[opts.selectedIndex].text == "WPA2-Personal")
			new_array = new Array("AES/CCMP");
		else if(opts[opts.selectedIndex].text == "WPA3-Personal" || opts[opts.selectedIndex].text == "WPA2/WPA3-Mixed (*)") {
			new_array = new Array("AES/CCMP");
			var has_gcmp = false;
			var has_gcmp256 = false;
			for(var i = 0; i < document.form.rt_crypto.length; i++) {
				if(document.form.rt_crypto.options[i].value == "gcmp") has_gcmp = true;
				if(document.form.rt_crypto.options[i].value == "gcmp-256") has_gcmp256 = true;
			}
			if(has_gcmp) new_array.push("GCMP-128");
			if(has_gcmp256) new_array.push("GCMP-256");
		}
		else
			new_array = new Array("AES/CCMP", "TKIP+AES");

		free_options(document.form.rt_crypto);
		for(var i in new_array){
			var val = new_array[i].toLowerCase();
			if(val == "aes/ccmp") val = "aes";
			document.form.rt_crypto[i] = new Option(new_array[i], val);
			document.form.rt_crypto[i].value = val;
			if(val == cur_crypto)
				document.form.rt_crypto[i].selected = true;
		}
	}
	else if(mode == "wpa"){
		if(opts[opts.selectedIndex].text == "WPA-Enterprise (Radius)")
			new_array = new Array("TKIP");
		else
			new_array = new Array("AES/CCMP", "TKIP+AES");

		free_options(document.form.rt_crypto);
		for(var i in new_array){
			var val = new_array[i].toLowerCase();
			if(val == "aes/ccmp") val = "aes";
			document.form.rt_crypto[i] = new Option(new_array[i], val);
			document.form.rt_crypto[i].value = val;
			if(val == cur_crypto)
				document.form.rt_crypto[i].selected = true;
		}
	}
	else if(mode == "wpa2" || mode == "owe"){
		new_array = new Array("AES/CCMP");

		free_options(document.form.rt_crypto);
		for(var i in new_array){
			var val = new_array[i].toLowerCase();
			if(val == "aes/ccmp") val = "aes";
			document.form.rt_crypto[i] = new Option(new_array[i], val);
			document.form.rt_crypto[i].value = val;
			if(val == cur_crypto)
				document.form.rt_crypto[i].selected = true;
		}
	}

	for(var i = 0; i < document.form.rt_key.length; ++i)
		if(document.form.rt_key[i].selected){
			cur_key_index = document.form.rt_key[i].value;
			break;
		}

	if(mode == "psk" || mode == "wpa" || mode == "wpa2" || mode == "owe")
		new_array = new Array("2", "3");
	else{
		new_array = new Array("1", "2", "3", "4");

		if(!isload)
			cur_key_index = "1";
	}

	free_options(document.form.rt_key);
	for(var i in new_array){
		document.form.rt_key[i] = new Option(new_array[i], new_array[i]);
		document.form.rt_key[i].value = new_array[i];
		if(new_array[i] == cur_key_index)
			document.form.rt_key[i].selected = true;
	}

	rt_wep_change();
}

function change_wep_type(mode){

	var cur_wep = document.form.rt_wep_x.value;
	var wep_type_array;
	var value_array;

	free_options(document.form.rt_wep_x);

	if(mode == "shared"){
		wep_type_array = new Array("WEP-64bits", "WEP-128bits");
		value_array = new Array("1", "2");
	}
	else{
		wep_type_array = new Array("None", "WEP-64bits", "WEP-128bits");
		value_array = new Array("0", "1", "2");
	}

	add_options_x2(document.form.rt_wep_x, wep_type_array, value_array, cur_wep);

	if(mode == "open"){
		if(document.form.rt_wep_x.value == 0){
			document.form.rt_wep_x.selectedIndex = 0;
		}
	}

	if(mode == "psk" || mode == "wpa" || mode == "wpa2" || mode == "owe")
		document.form.rt_wep_x.value = "0";

	change_wlweptype(document.form.rt_wep_x);
}

function change_wlweptype(wep_type_obj){
	var mode = document.form.rt_auth_mode.value;

	if(wep_type_obj.value == "0"){
		$("all_wep_key").style.display = "none";
		$("asus_wep_key").style.display = "none";
	}
	else{
		if(document.form.rt_gmode.value == "3" && document.form.rt_wep_x.value != 0){
			nmode_limitation2();
		}
		$("all_wep_key").style.display = "";
		$("asus_wep_key").style.display = "";
	}

	rt_wep_change();
}

function rt_wep_change(){
	var mode = document.form.rt_auth_mode.value;
	var wep = document.form.rt_wep_x.value;

	if(mode == "psk" || mode == "wpa" || mode == "wpa2" || mode == "owe"){
		if(mode == "psk" || mode == "owe")
			$("rt_crypto").style.display = "";

		if(mode == "psk")
			$("rt_wpa_psk").style.display = "";
		$("all_wep_key").style.display = "none";
		$("asus_wep_key").style.display = "none";
	}
	else{
		$("rt_crypto").style.display = "none";
		$("rt_wpa_psk").style.display = "none";
		if(wep == "0" || mode == "radius"){
			$("all_wep_key").style.display = "none";
			$("asus_wep_key").style.display = "none";
		}
		else{
			$("all_wep_key").style.display = "";
			$("asus_wep_key").style.display = "";
			show_key();
		}
	}
	change_key_des();
}

function change_key_des(){
	var objs = getElementsByName_iefix("span", "key_des");
	var wep_type = document.form.rt_wep_x.value;
	var str = "";

	if(wep_type == "1")
		str = " (<#WLANConfig11b_WEPKey_itemtype1#>)";
	else if(wep_type == "2")
		str = " (<#WLANConfig11b_WEPKey_itemtype2#>)";

	str += ":";

	for(var i = 0; i < objs.length; ++i)
		showtext(objs[i], str);
}

function change_auth_mode(auth_mode_obj){
	rt_auth_mode_change(0);
	if(auth_mode_obj.value == "psk" || auth_mode_obj.value == "wpa" || auth_mode_obj.value == "owe"){
		var opts = document.form.rt_auth_mode.options;

		if(opts[opts.selectedIndex].text == "WPA-Personal")
			document.form.rt_wpa_mode.value = "1";
		else if(opts[opts.selectedIndex].text == "WPA2-Personal")
			document.form.rt_wpa_mode.value="2";
		else if(opts[opts.selectedIndex].text == "WPA3-Personal")
			document.form.rt_wpa_mode.value="5";
		else if(opts[opts.selectedIndex].text == "WPA/WPA2-Mixed")
			document.form.rt_wpa_mode.value="0";
		else if(opts[opts.selectedIndex].text == "WPA2/WPA3-Mixed (*)")
			document.form.rt_wpa_mode.value="6";
		else if(opts[opts.selectedIndex].text == "WPA-Enterprise (Radius)")
			document.form.rt_wpa_mode.value="3";
		else if(opts[opts.selectedIndex].text == "WPA/WPA2-Enterprise (Radius)")
			document.form.rt_wpa_mode.value = "4";
		else if(opts[opts.selectedIndex].text == "Enhanced Open")
			document.form.rt_wpa_mode.value="7";

		if(auth_mode_obj.value == "psk"){
			document.form.rt_wpa_psk.focus();
			document.form.rt_wpa_psk.select();
		}
	}
	else if(auth_mode_obj.value == "shared"){
		show_key();
	}
	else{
		document.form.rt_wep_x.selectedIndex = 0;
		show_key();
		rt_wep_change();
	}
	nmode_limitation2();
}

function show_key(){
	var wep_type = document.form.rt_wep_x.value;
	var keyindex = document.form.rt_key.value;
	var cur_key_obj = eval("document.form.rt_key"+keyindex);
	var cur_key_length = cur_key_obj.value.length;

	if(wep_type == 1){
		if(cur_key_length == 5 || cur_key_length == 10)
			document.form.rt_asuskey1.value = cur_key_obj.value;
		else if(parent.document.rt_form.rt_asuskey1.value != "")
			document.form.rt_asuskey1.value = parent.document.rt_form.rt_asuskey1.value;
		else
			document.form.rt_asuskey1.value = "0000000000";
	}
	else if(wep_type == 2){
		if(cur_key_length == 13 || cur_key_length == 26)
			document.form.rt_asuskey1.value = cur_key_obj.value;
		else if(parent.document.rt_form.rt_asuskey1.value != "")
			document.form.rt_asuskey1.value = parent.document.rt_form.rt_asuskey1.value;
		else
			document.form.rt_asuskey1.value = "00000000000000000000000000";
	}
	else
		document.form.rt_asuskey1.value = "";

	document.form.rt_asuskey1.focus();
	document.form.rt_asuskey1.select();
}

function show_LAN_info(){
	var lan_ipaddr_t = '<% nvram_get_x("LANHostConfig", "lan_ipaddr_t"); %>';
	if(lan_ipaddr_t != '')
		showtext($("LANIP"), '<% nvram_get_x("LANHostConfig", "lan_ipaddr_t"); %>');
	else	
		showtext($("LANIP"), '<% nvram_get_x("LANHostConfig", "lan_ipaddr"); %>');
	showtext($("MAC"), get_bssid_rai0());
}

function show_wepkey_help(){
}

var secs;
var timerID = null;
var timerRunning = false;
var timeout = 1000;
var delay = 500;
var stopFlag=0;

function resetTimer()
{
	if (stopFlag==1){
		stopFlag=0;
		InitializeTimer();
	}
}

function InitializeTimer()
{
	if(document.form.rt_auth_mode.value == "shared"
		|| document.form.rt_auth_mode.value == "wpa"
		|| document.form.rt_auth_mode.value == "wpa2"
		|| document.form.rt_auth_mode.value == "radius")
		return;

	msecs = timeout;
	StopTheClock();
	StartTheTimer();
}

function StopTheClock()
{
	if(timerRunning)
		clearTimeout(timerID);
	timerRunning = false;
}

function StartTheTimer(){
	if(msecs == 0){
		StopTheClock();

		if(stopFlag == 1)
			return;

		msecs = timeout;
		StartTheTimer();
	}
	else{
		msecs = msecs-500;
		timerRunning = true;
		timerID = setTimeout("StartTheTimer();", delay);
	}
}

function loadXML()
{
	InitializeTimer();
}

function submitForm(){
	var auth_mode = document.form.rt_auth_mode.value;

	if(document.form.rt_wpa_psk.value == "Please type Password")
		document.form.rt_wpa_psk.value = "";

	if(!validate_string_ssid(document.form.rt_ssid))
		return false;

	if(auth_mode == "psk"){
		if(!validate_psk(document.form.rt_wpa_psk))
			return false;
	}
	else{
		if(!validate_wlkey(document.form.rt_asuskey1))
			return false;
	}

	stopFlag = 1;
	document.form.current_page.value = "/";
	document.form.next_page.value = "";
	document.form.action_mode.value = " Apply ";

	var wep11 = eval('document.form.rt_key'+document.form.rt_key.value);
	wep11.value = document.form.rt_asuskey1.value;

	if(auth_mode == "wpa" || auth_mode == "wpa2" || auth_mode == "radius"){
		document.form.target = "";
		document.form.next_page.value = "/Advanced_WSecurity2g_Content.asp";
	}

	parent.showLoading();
	document.form.submit();

	return true;
}

function nmode_limitation2(){
	if(document.form.rt_gmode.value == "3"){
		var auth_text = document.form.rt_auth_mode.options[document.form.rt_auth_mode.selectedIndex].text;

		// Open System + WEP
		if(auth_text == "Open System" && (document.form.rt_wep_x.selectedIndex == "1" || document.form.rt_wep_x.selectedIndex == "2")){
			alert("<#WLANConfig11n_nmode_limition_hint#>");
			document.form.rt_auth_mode.selectedIndex = 0;
			document.form.rt_wep_x.selectedIndex = 0;
		}
		// WPA-Personal (TKIP only)
		else if(auth_text == "WPA-Personal"){
			alert("<#WLANConfig11n_nmode_limition_hint#>");
			for(var i = 0; i < document.form.rt_auth_mode.length; i++){
				if(document.form.rt_auth_mode.options[i].text == "WPA2-Personal"){
					document.form.rt_auth_mode.selectedIndex = i;
					break;
				}
			}
			document.form.rt_wpa_mode.value = 2;
		}
		// Enhanced Open (not compatible with n Only)
		else if(auth_text == "Enhanced Open"){
			alert("<#WLANConfig11n_nmode_limition_hint#>");
			for(var i = 0; i < document.form.rt_auth_mode.length; i++){
				if(document.form.rt_auth_mode.options[i].text == "Open System"){
					document.form.rt_auth_mode.selectedIndex = i;
					break;
				}
			}
		}
		// WPA/WPA2-Mixed with TKIP encryption
		else if((auth_text == "WPA/WPA2-Mixed" || auth_text == "WPA-Enterprise (Radius)") && document.form.rt_crypto.value.indexOf("tkip") == 0){
			alert("<#WLANConfig11n_nmode_limition_hint#>");
			for(var i = 0; i < document.form.rt_crypto.length; i++){
				if(document.form.rt_crypto.options[i].value == "aes"){
					document.form.rt_crypto.selectedIndex = i;
					break;
				}
			}
		}
		rt_auth_mode_change(1);
	}
	document.form.rt_wpa_psk.focus();
	document.form.rt_wpa_psk.select();
}

window.onunload  = function(){
	var auth_mode = document.form.rt_auth_mode.value;

	if(document.form.rt_wpa_psk.value == "Please type Password")
		document.form.rt_wpa_psk.value = "";

	validate_string_ssid(document.form.rt_ssid);

	if(auth_mode == "psk")
		validate_psk(document.form.rt_wpa_psk);

	var keyindex = document.form.rt_key.value;
	var cur_key_obj = eval("parent.document.rt_form.rt_key"+keyindex);

	cur_key_obj.value = document.form.rt_asuskey1.value;
	parent.document.rt_form.rt_ssid.value = document.form.rt_ssid.value; 
	parent.document.rt_form.rt_wpa_mode.value = document.form.rt_wpa_mode.value;
	parent.document.rt_form.rt_ssid2.value = document.form.rt_ssid2.value;
	parent.document.rt_form.rt_auth_mode.value = document.form.rt_auth_mode.value;
	parent.document.rt_form.rt_key_type.value = document.form.rt_key_type.value;
	parent.document.rt_form.rt_key.value = document.form.rt_key.value;
	parent.document.rt_form.rt_key1.value = document.form.rt_key1.value;
	parent.document.rt_form.rt_key2.value = document.form.rt_key2.value;
	parent.document.rt_form.rt_key3.value = document.form.rt_key3.value;
	parent.document.rt_form.rt_key4.value = document.form.rt_key4.value;
	parent.document.rt_form.rt_wep_x.value = document.form.rt_wep_x.value;
	parent.document.rt_form.rt_crypto.value = document.form.rt_crypto.value;
	parent.document.rt_form.rt_wpa_psk.value = document.form.rt_wpa_psk.value;
	parent.document.rt_form.rt_asuskey1.value = document.form.rt_asuskey1.value;
}
</script>

<style>
/* ===== WPS circular icon button (one SVG mask + CSS colors) ===== */
:root {
    --wps-mask: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48ZyBmaWxsPSIjMDAwIj48cGF0aCBkPSJNIDUyLjUgMTcuMiBDIDQ1LjIgMTcuMiAzNi44IDIwLjggMzAuNSAyNy4xIEMgMjEuMiAzNi40IDE4LjUgNDkuOCAyMi44IDYxLjUgQyAyMy44IDY0LjIgMjUuNSA2Ny44IDI4LjIgNzEuMiBDIDI5LjUgNzIuOCAzMC44IDcyLjIgMjkuOCA3MC4xIEMgMjYuMiA2Mi44IDI1LjggNTUuMiAyOC4xIDQ3LjggQyAzMS41IDM2LjggNDEuMiAyOS41IDUyLjggMjkuNSBDIDU0LjggMjkuNSA1Ni41IDI5LjggNTYuNSAyNy4yIEMgNTYuNSAyMy41IDU1LjIgMTcuMiA1Mi41IDE3LjIgWiIvPjxwYXRoIGQ9Ik0gNDQuNSAxMS4yIEMgNDQuNSAxMC4yIDQ2LjIgMTAuMiA0Ny41IDExLjUgTCA2MC41IDI0LjUgQyA2MS44IDI1LjggNjEuOCAyNy4yIDYwLjUgMjguNSBMIDQ3LjUgNDEuNSBDIDQ2LjIgNDIuOCA0NC41IDQxLjggNDQuNSA0MC44IFoiLz48cGF0aCBkPSJNIDQ3LjUgODIuOCBDIDU0LjggODIuOCA2My4yIDc5LjIgNjkuNSA3Mi45IEMgNzguOCA2My42IDgxLjUgNTAuMiA3Ny4yIDM4LjUgQyA3Ni4yIDM1LjggNzQuNSAzMi4yIDcxLjggMjguOCBDIDcwLjUgMjcuMiA2OS4yIDI3LjggNzAuMiAyOS45IEMgNzMuOCAzNy4yIDc0LjIgNDQuOCA3MS45IDUyLjIgQyA2OC41IDYzLjIgNTguOCA3MC41IDQ3LjIgNzAuNSBDIDQ1LjIgNzAuNSA0My41IDcwLjIgNDMuNSA3Mi44IEMgNDMuNSA3Ni41IDQ0LjggODIuOCA0Ny41IDgyLjggWiIvPjxwYXRoIGQ9Ik0gNTUuNSA4OC44IEMgNTUuNSA4OS44IDUzLjggODkuOCA1Mi41IDg4LjUgTCAzOS41IDc1LjUgQyAzOC4yIDc0LjIgMzguMiA3Mi44IDM5LjUgNzEuNSBMIDUyLjUgNTguNSBDIDUzLjggNTcuMiA1NS41IDU4LjIgNTUuNSA1OS4yIFoiLz48L2c+PC9zdmc+");
}

    .table th{vertical-align: middle;}
    .table input, .table select{margin-bottom: 0px;}
</style>
</head>

<body class="body_iframe" onload="initial();">
<iframe name="hidden_frame" style="position: absolute;" id="hidden_frame" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="form" action="/start_apply.htm">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="sid_list" value="WLANConfig11b;MeshConfig;">
<input type="hidden" name="group_id" value="">
<input type="hidden" name="action_mode" value="">
<input type="hidden" name="action_script" value="">

<input type="hidden" name="rt_wpa_mode" value="<% nvram_get_x("", "rt_wpa_mode"); %>">
<input type="hidden" name="rt_key1" value="">
<input type="hidden" name="rt_key2" value="">
<input type="hidden" name="rt_key3" value="">
<input type="hidden" name="rt_key4" value="">
<input type="hidden" name="rt_ssid2" value="<% nvram_char_to_ascii("", "rt_ssid"); %>">
<input type="hidden" name="rt_wpa_psk_org" value="<% nvram_char_to_ascii("", "rt_wpa_psk"); %>">
<input type="hidden" name="rt_auth_mode_orig" value="<% nvram_get_x("","rt_auth_mode"); %>">
<input type="hidden" name="rt_wpa_mode_orig" value="<% nvram_get_x("", "rt_wpa_mode"); %>">
<input type="hidden" name="rt_wep_x_orig" value="<% nvram_get_x("", "rt_wep_x"); %>">
<input type="hidden" name="rt_key_type" value="<% nvram_get_x("","rt_key_type"); %>">
<input type="hidden" name="rt_key1_org" value="<% nvram_char_to_ascii("", "rt_key1"); %>">
<input type="hidden" name="rt_key2_org" value="<% nvram_char_to_ascii("", "rt_key2"); %>">
<input type="hidden" name="rt_key3_org" value="<% nvram_char_to_ascii("", "rt_key3"); %>">
<input type="hidden" name="rt_key4_org" value="<% nvram_char_to_ascii("", "rt_key4"); %>">
<input type="hidden" name="rt_gmode" value="<% nvram_get_x("","rt_gmode"); %>">

<ul class="nav nav-tabs">
    <li class="active"><a href="javascript:;">2.4GHz</a></li>
    <li id="tab_radio5g"><a href="router.asp">5GHz</a></li>
</ul>

<table class="table">
  <tr>
    <th width="50%" style="border-top: 0 none; padding-top: 0px;"><#WLANConfig11b_x_RadioEnable_itemname#></th>
    <td style="border-top: 0 none; padding-top: 0px;">
        <div class="main_itoggle">
            <div id="rt_radio_x_on_of">
                <input type="checkbox" id="rt_radio_x_fake" <% nvram_match_x("", "rt_radio_x", "1", "value=1 checked"); %><% nvram_match_x("", "rt_radio_x", "0", "value=0"); %>>
            </div>
            <div style="position: absolute; margin-left: -10000px;">
                <input type="radio" name="rt_radio_x" id="rt_radio_x_1" value="1" <% nvram_match_x("", "rt_radio_x", "1", "checked"); %>>On
                <input type="radio" name="rt_radio_x" id="rt_radio_x_0" value="0" <% nvram_match_x("", "rt_radio_x", "0", "checked"); %>>Off
            </div>
        </div>
    </td>
  </tr>
  <tr>
      <th width="110"><#MeshEnable#></th>
      <td>
          <div class="main_itoggle">
              <div id="mesh_enable_on_of">
                  <input type="checkbox" id="mesh_enable_fake" <% nvram_match_x("", "mesh_enable", "1", "value=1 checked"); %><% nvram_match_x("", "mesh_enable", "0", "value=0"); %>>
              </div>
          </div>
          <div style="position: absolute; margin-left: -10000px;">
              <input type="radio" name="mesh_enable" id="mesh_enable_1" value="1" <% nvram_match_x("", "mesh_enable", "1", "checked"); %>/><#checkbox_Yes#>
              <input type="radio" name="mesh_enable" id="mesh_enable_0" value="0" <% nvram_match_x("", "mesh_enable", "0", "checked"); %>/><#checkbox_No#>
          </div>
      </td>
  </tr>
  <tr>
    <th><#Wireless_name#> (SSID)</th>
    <td>
      <input id="sta_ssid" type="text" name="rt_ssid" value="<% nvram_get_x("", "rt_ssid"); %>" maxlength="32" size="22" />
    </td>
  </tr>
  <tr>
      <th><#WLANConfig11b_x_BlockBCSSID_itemname#></th>
      <td>
          <div class="main_itoggle">
              <div id="rt_closed_on_of">
                  <input type="checkbox" id="rt_closed_fake" <% nvram_match_x("", "rt_closed", "1", "value=1 checked"); %><% nvram_match_x("", "rt_closed", "0", "value=0"); %>>
              </div>
          </div>
          <div style="position: absolute; margin-left: -10000px;">
              <input type="radio" value="1" id="rt_closed_1" name="rt_closed" <% nvram_match_x("", "rt_closed", "1", "checked"); %>><#checkbox_Yes#>
              <input type="radio" value="0" id="rt_closed_0" name="rt_closed" <% nvram_match_x("", "rt_closed", "0", "checked"); %>><#checkbox_No#>
          </div>
      </td>
  </tr>
  <tr id='rt_WPS'>
      <th><#WLANConfig11b_x_WPS_itemname#></th>
      <td>
        <div class="main_itoggle">
            <div id="rt_WPS_on_of">
                <input type="checkbox" id="rt_WPS_fake" <% nvram_match_x("", "rt_WPS", "7", "value=7 checked"); %><% nvram_match_x("", "rt_WPS", "0", "value=0"); %>>
            </div>
        </div>
        <div style="position: absolute; margin-left: -10000px;">
            <input type="radio" name="rt_WPS" id="rt_WPS_1" value="7" <% nvram_match_x("", "rt_WPS", "7", "checked"); %>/><#checkbox_Yes#>
            <input type="radio" name="rt_WPS" id="rt_WPS_0" value="0" <% nvram_match_x("", "rt_WPS", "0", "checked"); %>/><#checkbox_No#>
        </div>
      </td>
  </tr>
  <tr>
    <th><#WLANConfig11b_AuthenticationMethod_itemname#></th>
    <td>
    <select name="rt_auth_mode" class="input" onchange="change_auth_mode(this);">
		<optgroup label="<#auth_group_open#>">
		<option value="open" <% nvram_match_x("","rt_auth_mode", "open","selected"); %>>Open System</option>
		<option value="shared" <% nvram_match_x("","rt_auth_mode", "shared","selected"); %>>Shared Key</option>
		<option value="owe" <% nvram_match_x("", "rt_auth_mode", "owe", "selected"); %>>Enhanced Open</option>
		</optgroup>
		<optgroup label="<#auth_group_personal#>">
		<option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "1", "selected"); %>>WPA-Personal</option>
		<option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "2", "selected"); %>>WPA2-Personal</option>
		<option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "5", "selected"); %>>WPA3-Personal</option>
		<option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "0", "selected"); %>>WPA/WPA2-Mixed</option>
		<option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "6", "selected"); %>>WPA2/WPA3-Mixed (*)</option>
		</optgroup>
		<optgroup label="<#auth_group_enterprise#>">
		<option value="wpa" <% nvram_double_match_x("", "rt_auth_mode", "wpa", "", "rt_wpa_mode", "3", "selected"); %>>WPA-Enterprise (Radius)</option>
		<option value="wpa2" <% nvram_match_x("", "rt_auth_mode", "wpa2", "selected"); %>>WPA2-Enterprise (Radius)</option>
		<option value="wpa" <% nvram_double_match_x("", "rt_auth_mode", "wpa", "", "rt_wpa_mode", "4", "selected"); %>>WPA/WPA2-Enterprise (Radius)</option>
		<option value="radius" <% nvram_match_x("","rt_auth_mode", "radius","selected"); %>>Radius with 802.1x</option>
		</optgroup>
	  </select>
    </td>
  </tr>

  <tr id='all_related_wep' style='display:none;'>
	<th width="110"><#WLANConfig11b_WEPType_itemname#></th>
	<td>
	  <select name="rt_wep_x" id="rt_wep_x" class="input" onchange="change_wlweptype(this);">
		<option value="0" <% nvram_match_x("", "rt_wep_x", "0", "selected"); %>>None</option>
		<option value="1" <% nvram_match_x("", "rt_wep_x", "1", "selected"); %>>WEP-64bits</option>
		<option value="2" <% nvram_match_x("", "rt_wep_x", "2", "selected"); %>>WEP-128bits</option>
	  </select>
	</td>
  </tr>

  <tr id='all_wep_key' style='display:none;'>
    <th width="110"><#WLANConfig11b_WEPDefaultKey_itemname#></th>
    <td>
      <select name="rt_key" class="input" onchange="show_key();">
        <option value="1" <% nvram_match_x("", "rt_key", "1", "selected"); %>>Key1</option>
        <option value="2" <% nvram_match_x("", "rt_key", "2", "selected"); %>>Key2</option>
        <option value="3" <% nvram_match_x("", "rt_key", "3", "selected"); %>>Key3</option>
        <option value="4" <% nvram_match_x("", "rt_key", "4", "selected"); %>>Key4</option>
      </select>
    </td>
  </tr>
  <tr id='asus_wep_key'>
    <th width="110"><#WLANConfig11b_WEPKey_itemname#></th>
    <td>
      <input type="text" id="sta_asuskey1" name="rt_asuskey1" onfocus="show_wepkey_help();" onKeyUp="return change_wlkey(this, 'WLANConfig11b');" value="" size="22" class="input"/>
    </td>
  </tr>

  <tr id='rt_crypto' style='display:none;'>
	<th width="110"><#WLANConfig11b_WPAType_itemname#></th>
	<td>
	  <select name="rt_crypto" class="input" onchange="rt_auth_mode_change(0);">
		<option value="aes" <% nvram_match_x("", "rt_crypto", "aes", "selected"); %>>AES/CCMP</option>
		<option value="tkip+aes" <% nvram_match_x("", "rt_crypto", "tkip+aes", "selected"); %>>TKIP+AES</option>
		<option value="gcmp" <% nvram_match_x("", "rt_crypto", "gcmp", "selected"); %>>GCMP-128</option>
		<option value="gcmp-256" <% nvram_match_x("", "rt_crypto", "gcmp-256", "selected"); %>>GCMP-256</option>
	  </select>
	</td>
  </tr>

  <tr id='rt_wpa_psk' style='display:none'>
    <th width="110"><#WPA-PSKKey#></th>
    <td>
      <div class="input-append">
          <input type="password" name="rt_wpa_psk" id="sta_wpa_psk" maxlength="63" size="22" value="" style="width: 175px;">
          <button style="margin-left: -5px;" class="btn" type="button" onclick="passwordShowHide('sta_wpa_psk')"><i class="icon-eye-close"></i></button>
      </div>
    </td>
  </tr>

  <tr id='rt_pmf' style='display:none;'>
	<th width="110"><#WLANConfig11b_PMFType_itemname#></th>
	<td>
	  <select name="rt_pmf" class="input" onchange="rt_auth_mode_change(0);">
		<option value="0" <% nvram_match_x("", "rt_pmf", "0", "selected"); %>><#btn_Disable#></option>
		<option value="1" <% nvram_match_x("", "rt_pmf", "1", "selected"); %>><#PMF_Capable#></option>
		<option value="2" <% nvram_match_x("", "rt_pmf", "2", "selected"); %>><#PMF_Mandatory#></option>
	  </select>
	</td>
  </tr>
  <tr>
      <th>&nbsp;</th>
      <td>
          <input id="bn_apply" type="button" class="btn btn-primary" value="<#CTL_apply#>" onclick="submitForm();" style="width: 219px;">
      </td>
  </tr>
 </table>
 <table class="table">
  <tr id="wps_button">
    <th width="50%"><#WPSControl#></th>
    <td>
      <button type="button" id="btn_connect" class="btn btn-success btn-wps" title="<#WPS_Trigger#>" onclick="wps_pbc()"></button>
      <span id="wps_status_txt" style="margin-left:10px;font-size:12px;color:#8FD4EF;vertical-align:middle"></span>
    </td>
  </tr>
  <tr>
    <th width="50%"><#LAN_IP#></th>
    <td id="LANIP"></td>
  </tr>
  <tr>
    <th><#MAC_Address#></th>
    <td id="MAC"></td>
  </tr>
  <tr>
    <th>&nbsp;</th>
    <td>
        <select id="Router_domore" class="domore" onchange="domore_link(this);">
            <option><#MoreConfig#>...</option>
            <option value="../Advanced_Wireless2g_Content.asp"><#menu5_1#> - <#menu5_1_1#></option>
            <option value="../Advanced_WGuest2g_Content.asp"><#menu5_1#> - <#menu5_1_2#></option>
            <option value="../Advanced_WAdvanced2g_Content.asp"><#menu5_1#> - <#menu5_1_6#></option>
            <option value="../Advanced_LAN_Content.asp"><#menu5_2_1#></option>
            <option value="../Advanced_DHCP_Content.asp"><#menu5_2_2#></option>
            <option value="../Advanced_GWStaticRoute_Content.asp"><#menu5_2_3#></option>
            <option value="../Main_WStatus2g_Content.asp"><#menu5_9#></option>
            <option value="../Main_LogStatus_Content.asp"><#menu5_7_2#></option>
        </select>
    </td>
  </tr>
</table>
</form>

</body>
</html>
