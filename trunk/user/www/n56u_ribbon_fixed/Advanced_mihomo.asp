<!DOCTYPE html>
<html>
<head>
	<title>
		<#Web_Title#> - <#menu5_39#>
	</title>
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
	<script type="text/javascript" src="/popup.js"></script>
	<script type="text/javascript" src="/help.js"></script>
	<script>
		var $j = jQuery.noConflict();

		<% mihomo_status(); %>
		<% mihomo_version(); %>
		<% mihomo_config(); %>

		function fill_status(status_code) {
			var el = document.getElementById('mihomo_run_state');
			if (status_code > 0)
				el.innerHTML = '<span class="label label-success"><#mihomo_018#></span>';
			else
				el.innerHTML = '<span class="label label-important"><#mihomo_019#></span>';
		}

		$j(document).ready(function () {
			init_itoggle('mihomo_enable');
			init_itoggle('mihomo_tls');
			init_itoggle('mihomo_dns_hijack');
			change_server_type();
			change_transport();
		});

		function initial() {
			try {
				document.getElementById('config_view').value = mihomo_config();
			} catch (e) {}

			try { show_banner(2); } catch (e) {}
			try { show_menu(28, 0); } catch (e) {}
			try { show_footer(); } catch (e) {}
			try { change_server_type(); } catch (e) {}
			try { change_transport(); } catch (e) {}
			try {
				fill_status(mihomo_status());
				document.getElementById('mihomo_ver').innerHTML = mihomo_version();
			} catch (e) {}
			try { toggleManualServer(); } catch (e) {}
		}

		function showmenu() {
		}

		function done_validating(action) {
			refreshpage();
		}

		function change_server_type() {
			var t = document.form.mihomo_type.value;
			showhide_div('mihomo_ss_fields', t == 'ss');
			showhide_div('mihomo_ss_fields2', t == 'ss');
			showhide_div('mihomo_hysteria_fields', t == 'hysteria2');
			showhide_div('mihomo_vmess_fields', t == 'vmess');
			showhide_div('mihomo_vless_fields', t == 'vless');
			showhide_div('mihomo_trojan_fields', t == 'trojan');
			showhide_div('mihomo_tls_fields', t == 'vless' || t == 'trojan' || t == 'hysteria2');
			showhide_div('mihomo_sni_fields', t == 'vless' || t == 'trojan' || t == 'hysteria2');
			showhide_div('mihomo_transport_fields', t == 'vmess' || t == 'vless');
			change_transport();
			if (t == 'trojan' || t == 'hysteria2') {
				document.form.mihomo_tls_fake.checked = true;
				document.form.mihomo_tls_1.checked = true;
			}
		}

		function change_transport() {
			var tr = document.form.mihomo_transport.value;
			showhide_div('mihomo_ws_path_fields', tr == 'ws');
		}

		function applyRule() {
			showLoading();
			document.form.action_mode.value = " Apply ";
			document.form.current_page.value = "/Advanced_mihomo.asp";
			document.form.next_page.value = "";
			document.form.submit();
		}

		function sendAction(action) {
			$j.ajax({
				type: "POST",
				url: "/Advanced_mihomo_action.asp",
				data: { connect_action: action },
				success: function () {
					setTimeout("refreshpage()", 1500);
				}
			});
		}

		function openDashboard() {
			var apiPort = document.form.mihomo_api_port ? document.form.mihomo_api_port.value : '9090';
			var host = location.hostname;
			var url = 'https://board.zashboard.org/#/setup?host=' + host + '&port=' + apiPort;
			window.open(url, '_blank');
		}

		function toggleManualServer() {
			var subInput = document.form.mihomo_sub_url;
			var manualTab = document.getElementById('tab_manual');
			if (!subInput) return;
			var hasSub = subInput.value.replace(/^\s+|\s+$/g, '').length > 0;
			if (manualTab) manualTab.style.display = hasSub ? 'none' : '';
		}

		function refreshStatus() {
			$j.ajax({
				url: "/Advanced_mihomo_action.asp?connect_action=Status",
				type: "GET",
				complete: function (xhr) {
					if (xhr.responseText.indexOf('mihomo_status()') > -1) {
						eval(xhr.responseText);
						fill_status(mihomo_status());
					}
				}
			});
		}

		function saveConfig() {
			var content = document.getElementById('config_view').value;
			var msg = document.getElementById('config_save_msg');
			msg.innerHTML = '<span style="color:#999;">Saving...</span>';
			$j.ajax({
				type: "POST",
				url: "/Advanced_mihomo_action.asp",
				data: { connect_action: "Save_config", config_content: content },
				success: function (resp) {
					if (resp.indexOf("OK") > -1) {
						msg.innerHTML = '<span style="color:green;"><#mihomo_config_saved#></span>';
						setTimeout("refreshpage()", 1500);
					} else {
						msg.innerHTML = '<span style="color:red;">' + resp + '</span>';
					}
				},
				error: function () {
					msg.innerHTML = '<span style="color:red;"><#mihomo_config_failed#></span>';
				}
			});
		}

		setInterval("refreshStatus()", 10000);
	</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
	<div class="container-fluid" style="padding-right: 0px">
		<div class="row-fluid">
			<div class="span3"><center><div id="logo"></div></center></div>
			<div class="span9">
				<div id="TopBanner"></div>
			</div>
		</div>
	</div>

	<div id="Loading" class="popup_bg"></div>

	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

	<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

		<input type="hidden" name="current_page" value="Advanced_mihomo.asp">
		<input type="hidden" name="next_page" value="">
		<input type="hidden" name="next_host" value="">
		<input type="hidden" name="sid_list" value="MihomoConf;">
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
							<div class="box well grad_colour_dark_blue">
								<h2 class="box_head round_top"><#menu5_39#></h2>
								<div class="round_bottom">

									<ul class="nav nav-tabs" style="margin: 10px 10px 0 10px;">
										<li class="active"><a href="#tab_status" data-toggle="tab"><#mihomo_tab_status#></a></li>
										<li><a href="#tab_sub" data-toggle="tab"><#mihomo_tab_sub#></a></li>
										<li id="tab_manual"><a href="#tab_manual" data-toggle="tab"><#mihomo_tab_manual#></a></li>
										<li><a href="#tab_rules" data-toggle="tab"><#mihomo_tab_rules#></a></li>
										<li><a href="#tab_advanced" data-toggle="tab"><#mihomo_tab_advanced#></a></li>
										<li><a href="#tab_config" data-toggle="tab"><#mihomo_tab_config#></a></li>
									</ul>

									<div class="tab-content" style="padding: 0 10px 10px 10px;">

										<!-- ========== Tab: Status ========== -->
										<div class="tab-pane active" id="tab_status">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%" style="border-top: 0 none;"><#mihomo_001#></th>
													<td style="border-top: 0 none;">
														<div class="main_itoggle">
															<div id="mihomo_enable_on_of">
																<input type="checkbox" id="mihomo_enable_fake" <% nvram_match_x("", "mihomo_enable", "1", "value=1 checked"); %><% nvram_match_x("", "mihomo_enable", "0", "value=0"); %> />
															</div>
														</div>
														<div style="position: absolute; margin-left: -10000px;">
															<input type="radio" value="1" name="mihomo_enable" id="mihomo_enable_1" <% nvram_match_x("", "mihomo_enable", "1", "checked"); %> /><#checkbox_Yes#>
															<input type="radio" value="0" name="mihomo_enable" id="mihomo_enable_0" <% nvram_match_x("", "mihomo_enable", "0", "checked"); %> /><#checkbox_No#>
														</div>
													</td>
												</tr>
												<tr>
													<th><#mihomo_017#></th>
													<td>
														<span id="mihomo_run_state"></span>
														&nbsp;&nbsp;<#mihomo_020#> <span id="mihomo_ver"></span>
													</td>
												</tr>
											</table>

											<div class="row-fluid">
												<div class="span12" style="margin-top: 10px;">
													<center>
														<input class="btn btn-primary btn-small" style="width: 100px" type="button" value="<#mihomo_014#>" onclick="applyRule()" />
														<input class="btn btn-success btn-small" style="width: 80px" type="button" value="<#mihomo_015#>" onclick="sendAction('Start')" />
														<input class="btn btn-warning btn-small" style="width: 80px" type="button" value="<#mihomo_016#>" onclick="sendAction('Restart')" />
														<input class="btn btn-danger btn-small" style="width: 80px" type="button" value="<#mihomo_010#>" onclick="sendAction('Stop')" />
														&nbsp;
														<input class="btn btn-small" style="width: 100px" type="button" value="<#mihomo_040#>" onclick="sendAction('Update_geo')" />
														<input class="btn btn-info btn-small" style="width: 110px" type="button" value="<#mihomo_050#>" onclick="openDashboard()" />
														<a href="Advanced_mihomo_log.asp" class="btn btn-small" style="width: 90px"><#mihomo_038#></a>
													</center>
												</div>
											</div>

											<div class="alert alert-info" style="margin: 15px 0 0 0;">
												<p><#mihomo_help#></p>
												<p><#mihomo_help2#></p>
											</div>
										</div>

										<!-- ========== Tab: Subscription ========== -->
										<div class="tab-pane" id="tab_sub">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#mihomo_043#></th>
													<td>
														<input type="text" class="input" style="width: 380px" name="mihomo_sub_url" value="<% nvram_get_x("", "mihomo_sub_url"); %>" oninput="toggleManualServer()" />
														&nbsp;
														<input class="btn btn-warning btn-small" style="width: 100px" type="button" value="<#mihomo_044#>" onclick="sendAction('Update_sub')" />
													</td>
												</tr>
												<tr>
													<th><#mihomo_045#></th>
													<td>
														<select name="mihomo_sub_node" class="input" style="width: 220px">
															<% mihomo_nodes(); %>
														</select>
													</td>
												</tr>
												<tr>
													<td colspan="2" style="color: #666; font-size: 12px;"><#mihomo_046#></td>
												</tr>
											</table>
										</div>

										<!-- ========== Tab: Manual Server ========== -->
										<div class="tab-pane" id="tab_manual">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#mihomo_003#></th>
													<td>
														<select name="mihomo_type" class="input" style="width: 200px" onchange="change_server_type()">
															<option value="ss" <% nvram_match_x("", "mihomo_type", "ss", "selected"); %>>Shadowsocks</option>
															<option value="vmess" <% nvram_match_x("", "mihomo_type", "vmess", "selected"); %>>VMess</option>
															<option value="vless" <% nvram_match_x("", "mihomo_type", "vless", "selected"); %>>VLESS</option>
															<option value="trojan" <% nvram_match_x("", "mihomo_type", "trojan", "selected"); %>>Trojan</option>
															<option value="hysteria2" <% nvram_match_x("", "mihomo_type", "hysteria2", "selected"); %>>Hysteria2</option>
														</select>
													</td>
												</tr>
												<tr>
													<th><#mihomo_004#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_server" value="<% nvram_get_x("", "mihomo_server"); %>" />
													</td>
												</tr>
												<tr>
													<th><#mihomo_005#></th>
													<td>
														<input type="text" class="input" size="8" maxlength="5" name="mihomo_server_port" value="<% nvram_get_x("", "mihomo_server_port"); %>" />
													</td>
												</tr>
												<tr id="mihomo_ss_fields">
													<th><#mihomo_006#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_password" value="<% nvram_get_x("", "mihomo_password"); %>" autocomplete="off" />
													</td>
												</tr>
												<tr id="mihomo_vmess_fields" style="display:none">
													<th><#mihomo_007#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_uuid" value="<% nvram_get_x("", "mihomo_uuid"); %>" />
													</td>
												</tr>
												<tr id="mihomo_vless_fields" style="display:none">
													<th><#mihomo_007#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_uuid" value="<% nvram_get_x("", "mihomo_uuid"); %>" />
													</td>
												</tr>
												<tr id="mihomo_trojan_fields" style="display:none">
													<th><#mihomo_006#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_password" value="<% nvram_get_x("", "mihomo_password"); %>" autocomplete="off" />
													</td>
												</tr>
												<tr id="mihomo_hysteria_fields" style="display:none">
													<th><#mihomo_006#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_password" value="<% nvram_get_x("", "mihomo_password"); %>" autocomplete="off" />
													</td>
												</tr>
												<tr id="mihomo_ss_fields2" style="display:none">
													<th><#mihomo_008#></th>
													<td>
														<select name="mihomo_method" class="input" style="width: 200px">
															<option value="aes-128-gcm" <% nvram_match_x("", "mihomo_method", "aes-128-gcm", "selected"); %>>aes-128-gcm</option>
															<option value="aes-256-gcm" <% nvram_match_x("", "mihomo_method", "aes-256-gcm", "selected"); %>>aes-256-gcm</option>
															<option value="chacha20-ietf-poly1305" <% nvram_match_x("", "mihomo_method", "chacha20-ietf-poly1305", "selected"); %>>chacha20-ietf-poly1305</option>
															<option value="2022-blake3-aes-128-gcm" <% nvram_match_x("", "mihomo_method", "2022-blake3-aes-128-gcm", "selected"); %>>2022-blake3-aes-128-gcm</option>
															<option value="2022-blake3-aes-256-gcm" <% nvram_match_x("", "mihomo_method", "2022-blake3-aes-256-gcm", "selected"); %>>2022-blake3-aes-256-gcm</option>
															<option value="2022-blake3-chacha20-poly1305" <% nvram_match_x("", "mihomo_method", "2022-blake3-chacha20-poly1305", "selected"); %>>2022-blake3-chacha20-poly1305</option>
														</select>
													</td>
												</tr>
												<tr id="mihomo_tls_fields" style="display:none">
													<th><#mihomo_009#></th>
													<td>
														<div class="main_itoggle">
															<div id="mihomo_tls_on_of">
																<input type="checkbox" id="mihomo_tls_fake" <% nvram_match_x("", "mihomo_tls", "1", "value=1 checked"); %><% nvram_match_x("", "mihomo_tls", "0", "value=0"); %> />
															</div>
														</div>
														<div style="position: absolute; margin-left: -10000px;">
															<input type="radio" value="1" name="mihomo_tls" id="mihomo_tls_1" <% nvram_match_x("", "mihomo_tls", "1", "checked"); %> /><#checkbox_Yes#>
															<input type="radio" value="0" name="mihomo_tls" id="mihomo_tls_0" <% nvram_match_x("", "mihomo_tls", "0", "checked"); %> /><#checkbox_No#>
														</div>
													</td>
												</tr>
												<tr id="mihomo_sni_fields" style="display:none">
													<th><#mihomo_011#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_sni" value="<% nvram_get_x("", "mihomo_sni"); %>" />
													</td>
												</tr>
												<tr id="mihomo_transport_fields" style="display:none">
													<th><#mihomo_012#></th>
													<td>
														<select name="mihomo_transport" class="input" style="width: 200px" onchange="change_transport()">
															<option value="tcp" <% nvram_match_x("", "mihomo_transport", "tcp", "selected"); %>>TCP</option>
															<option value="ws" <% nvram_match_x("", "mihomo_transport", "ws", "selected"); %>>WebSocket</option>
															<option value="grpc" <% nvram_match_x("", "mihomo_transport", "grpc", "selected"); %>>gRPC</option>
														</select>
													</td>
												</tr>
												<tr id="mihomo_ws_path_fields" style="display:none">
													<th><#mihomo_013#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_ws_path" value="<% nvram_get_x("", "mihomo_ws_path"); %>" />
													</td>
												</tr>
											</table>
										</div>

										<!-- ========== Tab: Rules ========== -->
										<div class="tab-pane" id="tab_rules">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#mihomo_022#></th>
													<td>
														<select name="mihomo_mode" class="input" style="width: 200px">
															<option value="1" <% nvram_match_x("", "mihomo_mode", "1", "selected"); %>><#mihomo_023#></option>
															<option value="0" <% nvram_match_x("", "mihomo_mode", "0", "selected"); %>><#mihomo_024#></option>
															<option value="2" <% nvram_match_x("", "mihomo_mode", "2", "selected"); %>><#mihomo_025#></option>
														</select>
													</td>
												</tr>
												<tr>
													<th><#mihomo_028#></th>
													<td>
														<select name="mihomo_route_mode" class="input" style="width: 200px">
															<option value="1" <% nvram_match_x("", "mihomo_route_mode", "1", "selected"); %>><#mihomo_029#></option>
															<option value="0" <% nvram_match_x("", "mihomo_route_mode", "0", "selected"); %>><#mihomo_030#></option>
															<option value="2" <% nvram_match_x("", "mihomo_route_mode", "2", "selected"); %>><#mihomo_031#></option>
														</select>
													</td>
												</tr>
											</table>
										</div>

										<!-- ========== Tab: Advanced ========== -->
										<div class="tab-pane" id="tab_advanced">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#mihomo_026#></th>
													<td>
														<input type="text" class="input" size="8" maxlength="5" name="mihomo_local_port" value="<% nvram_get_x("", "mihomo_local_port"); %>" />
														&nbsp;<span class="label"><#mihomo_027#></span>
													</td>
												</tr>
												<tr>
													<th><#mihomo_032#></th>
													<td>
														<div class="main_itoggle">
															<div id="mihomo_dns_hijack_on_of">
																<input type="checkbox" id="mihomo_dns_hijack_fake" <% nvram_match_x("", "mihomo_dns_hijack", "1", "value=1 checked"); %><% nvram_match_x("", "mihomo_dns_hijack", "0", "value=0"); %> />
															</div>
														</div>
														<div style="position: absolute; margin-left: -10000px;">
															<input type="radio" value="1" name="mihomo_dns_hijack" id="mihomo_dns_hijack_1" <% nvram_match_x("", "mihomo_dns_hijack", "1", "checked"); %> /><#checkbox_Yes#>
															<input type="radio" value="0" name="mihomo_dns_hijack" id="mihomo_dns_hijack_0" <% nvram_match_x("", "mihomo_dns_hijack", "0", "checked"); %> /><#checkbox_No#>
														</div>
													</td>
												</tr>
												<tr>
													<th><#mihomo_033#></th>
													<td>
														<input type="text" class="input" size="8" maxlength="5" name="mihomo_api_port" value="<% nvram_get_x("", "mihomo_api_port"); %>" />
														&nbsp;<span class="label"><#mihomo_034#></span>
													</td>
												</tr>
												<tr>
													<th><#mihomo_035#></th>
													<td>
														<select name="mihomo_log_level" class="input" style="width: 200px">
															<option value="error" <% nvram_match_x("", "mihomo_log_level", "error", "selected"); %>>error</option>
															<option value="warning" <% nvram_match_x("", "mihomo_log_level", "warning", "selected"); %>>warning</option>
															<option value="info" <% nvram_match_x("", "mihomo_log_level", "info", "selected"); %>>info</option>
															<option value="debug" <% nvram_match_x("", "mihomo_log_level", "debug", "selected"); %>>debug</option>
														</select>
													</td>
												</tr>
												<tr>
													<th><#mihomo_036#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_geoip_url" value="<% nvram_get_x("", "mihomo_geoip_url"); %>" />
													</td>
												</tr>
												<tr>
													<th><#mihomo_041#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="mihomo_geosite_url" value="<% nvram_get_x("", "mihomo_geosite_url"); %>" />
													</td>
												</tr>
											</table>
										</div><!-- /tab_advanced -->

										<!-- ========== Tab: Config File ========== -->
										<div class="tab-pane" id="tab_config">
											<p style="color: #666; font-size: 12px; margin: 5px 0;">
												<#mihomo_config_help#>
											</p>
											<textarea id="config_view" class="input" style="width: 100%; height: 480px; font-family: monospace; font-size: 12px;"></textarea>
											<div style="margin-top: 8px;">
												<input class="btn btn-primary btn-small" style="width: 100px" type="button" value="<#mihomo_config_save#>" onclick="saveConfig()" />
												<span id="config_save_msg" style="margin-left: 10px; font-size: 12px;"></span>
											</div>
										</div>

									</div><!-- /tab-content -->

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
