<!DOCTYPE html>
<html>
<head>
	<title>
		<#Web_Title#> - <#menu5_38#>
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

		<% singbox_status(); %>
		<% singbox_version(); %>
		<% singbox_config(); %>

		function fill_status(status_code) {
			var el = document.getElementById('singbox_run_state');
			if (status_code > 0)
				el.innerHTML = '<span class="label label-success"><#singbox_018#></span>';
			else
				el.innerHTML = '<span class="label label-important"><#singbox_019#></span>';
		}

		$j(document).ready(function () {
			init_itoggle('singbox_enable');
			init_itoggle('singbox_tls');
			init_itoggle('singbox_dns_hijack');
			change_server_type();
			change_transport();
		});

		function initial() {
			// load generated config.json first (before other init steps that may fail)
			try {
				document.getElementById('config_view').value = singbox_config();
			} catch (e) {}

			try { show_banner(2); } catch (e) {}
			try { show_menu(28, 0); } catch (e) {}
			try { show_footer(); } catch (e) {}
			try { change_server_type(); } catch (e) {}
			try { change_transport(); } catch (e) {}
			try {
				fill_status(singbox_status());
				document.getElementById('singbox_ver').innerHTML = singbox_version();
			} catch (e) {}
			try { toggleManualServer(); } catch (e) {}
		}

		function showmenu() {
		}

		function done_validating(action) {
			refreshpage();
		}

		function change_server_type() {
			var t = document.form.singbox_type.value;
			showhide_div('singbox_ss_fields', t == 'shadowsocks');
			showhide_div('singbox_ss_fields2', t == 'shadowsocks');
			showhide_div('singbox_hysteria_fields', t == 'hysteria2');
			showhide_div('singbox_vmess_fields', t == 'vmess');
			showhide_div('singbox_vless_fields', t == 'vless');
			showhide_div('singbox_trojan_fields', t == 'trojan');
			showhide_div('singbox_tls_fields', t == 'vless' || t == 'trojan' || t == 'hysteria2');
			showhide_div('singbox_sni_fields', t == 'vless' || t == 'trojan' || t == 'hysteria2');
			showhide_div('singbox_transport_fields', t == 'vmess' || t == 'vless');
			change_transport();
			if (t == 'trojan' || t == 'hysteria2') {
				document.form.singbox_tls_fake.checked = true;
				document.form.singbox_tls_1.checked = true;
			}
		}

		function change_transport() {
			var tr = document.form.singbox_transport.value;
			showhide_div('singbox_ws_path_fields', tr == 'ws' || tr == 'httpupgrade');
		}

		function applyRule() {
			showLoading();
			document.form.action_mode.value = " Apply ";
			document.form.current_page.value = "/Advanced_singbox.asp";
			document.form.next_page.value = "";
			document.form.submit();
		}

		function sendAction(action) {
			$j.ajax({
				type: "POST",
				url: "/Advanced_singbox_action.asp",
				data: { connect_action: action },
				success: function () {
					setTimeout("refreshpage()", 1500);
				}
			});
		}

		// Open a third-party Clash-compatible dashboard (zashboard) in a new
		// tab, pre-filled with this router's clash_api address.
		function openDashboard() {
			var apiPort = document.form.singbox_api_port ? document.form.singbox_api_port.value : '9090';
			var host = location.hostname;
			var url = 'https://board.zashboard.org/#/setup?host=' + host + '&port=' + apiPort;
			window.open(url, '_blank');
		}

		// When a subscription URL is configured, hide the manual server
		// settings block (subscription overrides manual config).
		function toggleManualServer() {
			var subInput = document.form.singbox_sub_url;
			var manualTab = document.getElementById('tab_manual');
			if (!subInput) return;
			var hasSub = subInput.value.replace(/^\s+|\s+$/g, '').length > 0;
			if (manualTab) manualTab.style.display = hasSub ? 'none' : '';
		}

		function refreshStatus() {
			$j.ajax({
				url: "/Advanced_singbox_action.asp?connect_action=Status",
				type: "GET",
				complete: function (xhr) {
					if (xhr.responseText.indexOf('singbox_status()') > -1) {
						eval(xhr.responseText);
						fill_status(singbox_status());
					}
				}
			});
		}

		// Save edited config.json: POST to action hook, which runs
		// `sing-box check` first and only writes the file if valid.
		function saveConfig() {
			var content = document.getElementById('config_view').value;
			var msg = document.getElementById('config_save_msg');
			msg.innerHTML = '<span style="color:#999;">Saving...</span>';
			$j.ajax({
				type: "POST",
				url: "/Advanced_singbox_action.asp",
				data: { connect_action: "Save_config", config_content: content },
				success: function (resp) {
					if (resp.indexOf("OK") > -1) {
						msg.innerHTML = '<span style="color:green;"><#singbox_config_saved#></span>';
						setTimeout("refreshpage()", 1500);
					} else {
						msg.innerHTML = '<span style="color:red;">' + resp + '</span>';
					}
				},
				error: function () {
					msg.innerHTML = '<span style="color:red;"><#singbox_config_failed#></span>';
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

		<input type="hidden" name="current_page" value="Advanced_singbox.asp">
		<input type="hidden" name="next_page" value="">
		<input type="hidden" name="next_host" value="">
		<input type="hidden" name="sid_list" value="SingboxConf;">
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
								<h2 class="box_head round_top"><#menu5_38#></h2>
								<div class="round_bottom">

									<ul class="nav nav-tabs" style="margin: 10px 10px 0 10px;">
										<li class="active"><a href="#tab_status" data-toggle="tab"><#singbox_tab_status#></a></li>
										<li><a href="#tab_sub" data-toggle="tab"><#singbox_tab_sub#></a></li>
										<li id="tab_manual"><a href="#tab_manual" data-toggle="tab"><#singbox_tab_manual#></a></li>
										<li><a href="#tab_rules" data-toggle="tab"><#singbox_tab_rules#></a></li>
										<li><a href="#tab_advanced" data-toggle="tab"><#singbox_tab_advanced#></a></li>
										<li><a href="#tab_config" data-toggle="tab"><#singbox_tab_config#></a></li>
									</ul>

									<div class="tab-content" style="padding: 0 10px 10px 10px;">

										<!-- ========== Tab: Status ========== -->
										<div class="tab-pane active" id="tab_status">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%" style="border-top: 0 none;"><#singbox_001#></th>
													<td style="border-top: 0 none;">
														<div class="main_itoggle">
															<div id="singbox_enable_on_of">
																<input type="checkbox" id="singbox_enable_fake" <% nvram_match_x("", "singbox_enable", "1", "value=1 checked"); %><% nvram_match_x("", "singbox_enable", "0", "value=0"); %> />
															</div>
														</div>
														<div style="position: absolute; margin-left: -10000px;">
															<input type="radio" value="1" name="singbox_enable" id="singbox_enable_1" <% nvram_match_x("", "singbox_enable", "1", "checked"); %> /><#checkbox_Yes#>
															<input type="radio" value="0" name="singbox_enable" id="singbox_enable_0" <% nvram_match_x("", "singbox_enable", "0", "checked"); %> /><#checkbox_No#>
														</div>
													</td>
												</tr>
												<tr>
													<th><#singbox_017#></th>
													<td>
														<span id="singbox_run_state"></span>
														&nbsp;&nbsp;<#singbox_020#> <span id="singbox_ver"></span>
													</td>
												</tr>
											</table>

											<div class="row-fluid">
												<div class="span12" style="margin-top: 10px;">
													<center>
														<input class="btn btn-primary btn-small" style="width: 100px" type="button" value="<#singbox_014#>" onclick="applyRule()" />
														<input class="btn btn-success btn-small" style="width: 80px" type="button" value="<#singbox_015#>" onclick="sendAction('Start')" />
														<input class="btn btn-warning btn-small" style="width: 80px" type="button" value="<#singbox_016#>" onclick="sendAction('Restart')" />
														<input class="btn btn-danger btn-small" style="width: 80px" type="button" value="<#singbox_010#>" onclick="sendAction('Stop')" />
														&nbsp;
														<input class="btn btn-small" style="width: 100px" type="button" value="<#singbox_040#>" onclick="sendAction('Update_geo')" />
														<input class="btn btn-info btn-small" style="width: 110px" type="button" value="<#singbox_050#>" onclick="openDashboard()" />
														<a href="Advanced_singbox_log.asp" class="btn btn-small" style="width: 90px"><#singbox_038#></a>
													</center>
												</div>
											</div>

											<div class="alert alert-info" style="margin: 15px 0 0 0;">
												<p><#singbox_help#></p>
											</div>
										</div>

										<!-- ========== Tab: Subscription ========== -->
										<div class="tab-pane" id="tab_sub">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#singbox_043#></th>
													<td>
														<input type="text" class="input" style="width: 380px" name="singbox_sub_url" value="<% nvram_get_x("", "singbox_sub_url"); %>" oninput="toggleManualServer()" />
														&nbsp;
														<input class="btn btn-warning btn-small" style="width: 100px" type="button" value="<#singbox_044#>" onclick="sendAction('Update_sub')" />
													</td>
												</tr>
												<tr>
													<th><#singbox_045#></th>
													<td>
														<select name="singbox_sub_node" class="input" style="width: 220px">
															<option value="auto" <% nvram_match_x("", "singbox_sub_node", "auto", "selected"); %>><#singbox_047#></option>
															<% singbox_nodes(); %>
														</select>
													</td>
												</tr>
												<tr>
													<td colspan="2" style="color: #666; font-size: 12px;"><#singbox_046#></td>
												</tr>
											</table>
										</div>

										<!-- ========== Tab: Manual Server ========== -->
										<div class="tab-pane" id="tab_manual">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#singbox_003#></th>
													<td>
														<select name="singbox_type" class="input" style="width: 200px" onchange="change_server_type()">
															<option value="shadowsocks" <% nvram_match_x("", "singbox_type", "shadowsocks", "selected"); %>>Shadowsocks</option>
															<option value="vmess" <% nvram_match_x("", "singbox_type", "vmess", "selected"); %>>VMess</option>
															<option value="vless" <% nvram_match_x("", "singbox_type", "vless", "selected"); %>>VLESS</option>
															<option value="trojan" <% nvram_match_x("", "singbox_type", "trojan", "selected"); %>>Trojan</option>
															<option value="hysteria2" <% nvram_match_x("", "singbox_type", "hysteria2", "selected"); %>>Hysteria2</option>
														</select>
													</td>
												</tr>
												<tr>
													<th><#singbox_004#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_server" value="<% nvram_get_x("", "singbox_server"); %>" />
													</td>
												</tr>
												<tr>
													<th><#singbox_005#></th>
													<td>
														<input type="text" class="input" size="8" maxlength="5" name="singbox_server_port" value="<% nvram_get_x("", "singbox_server_port"); %>" />
													</td>
												</tr>
												<tr id="singbox_ss_fields">
													<th><#singbox_006#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_password" value="<% nvram_get_x("", "singbox_password"); %>" autocomplete="off" />
													</td>
												</tr>
												<tr id="singbox_vmess_fields" style="display:none">
													<th><#singbox_007#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_uuid" value="<% nvram_get_x("", "singbox_uuid"); %>" />
													</td>
												</tr>
												<tr id="singbox_vless_fields" style="display:none">
													<th><#singbox_007#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_uuid" value="<% nvram_get_x("", "singbox_uuid"); %>" />
													</td>
												</tr>
												<tr id="singbox_trojan_fields" style="display:none">
													<th><#singbox_006#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_password" value="<% nvram_get_x("", "singbox_password"); %>" autocomplete="off" />
													</td>
												</tr>
												<tr id="singbox_hysteria_fields" style="display:none">
													<th><#singbox_006#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_password" value="<% nvram_get_x("", "singbox_password"); %>" autocomplete="off" />
													</td>
												</tr>
												<tr id="singbox_ss_fields2" style="display:none">
													<th><#singbox_008#></th>
													<td>
														<select name="singbox_method" class="input" style="width: 200px">
															<option value="aes-128-gcm" <% nvram_match_x("", "singbox_method", "aes-128-gcm", "selected"); %>>aes-128-gcm</option>
															<option value="aes-256-gcm" <% nvram_match_x("", "singbox_method", "aes-256-gcm", "selected"); %>>aes-256-gcm</option>
															<option value="chacha20-ietf-poly1305" <% nvram_match_x("", "singbox_method", "chacha20-ietf-poly1305", "selected"); %>>chacha20-ietf-poly1305</option>
															<option value="2022-blake3-aes-128-gcm" <% nvram_match_x("", "singbox_method", "2022-blake3-aes-128-gcm", "selected"); %>>2022-blake3-aes-128-gcm</option>
															<option value="2022-blake3-aes-256-gcm" <% nvram_match_x("", "singbox_method", "2022-blake3-aes-256-gcm", "selected"); %>>2022-blake3-aes-256-gcm</option>
															<option value="2022-blake3-chacha20-poly1305" <% nvram_match_x("", "singbox_method", "2022-blake3-chacha20-poly1305", "selected"); %>>2022-blake3-chacha20-poly1305</option>
														</select>
													</td>
												</tr>
												<tr id="singbox_tls_fields" style="display:none">
													<th><#singbox_009#></th>
													<td>
														<div class="main_itoggle">
															<div id="singbox_tls_on_of">
																<input type="checkbox" id="singbox_tls_fake" <% nvram_match_x("", "singbox_tls", "1", "value=1 checked"); %><% nvram_match_x("", "singbox_tls", "0", "value=0"); %> />
															</div>
														</div>
														<div style="position: absolute; margin-left: -10000px;">
															<input type="radio" value="1" name="singbox_tls" id="singbox_tls_1" <% nvram_match_x("", "singbox_tls", "1", "checked"); %> /><#checkbox_Yes#>
															<input type="radio" value="0" name="singbox_tls" id="singbox_tls_0" <% nvram_match_x("", "singbox_tls", "0", "checked"); %> /><#checkbox_No#>
														</div>
													</td>
												</tr>
												<tr id="singbox_sni_fields" style="display:none">
													<th><#singbox_011#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_sni" value="<% nvram_get_x("", "singbox_sni"); %>" />
													</td>
												</tr>
												<tr id="singbox_transport_fields" style="display:none">
													<th><#singbox_012#></th>
													<td>
														<select name="singbox_transport" class="input" style="width: 200px" onchange="change_transport()">
															<option value="tcp" <% nvram_match_x("", "singbox_transport", "tcp", "selected"); %>>TCP</option>
															<option value="ws" <% nvram_match_x("", "singbox_transport", "ws", "selected"); %>>WebSocket</option>
															<option value="httpupgrade" <% nvram_match_x("", "singbox_transport", "httpupgrade", "selected"); %>>HTTPUpgrade</option>
															<option value="grpc" <% nvram_match_x("", "singbox_transport", "grpc", "selected"); %>>gRPC</option>
														</select>
													</td>
												</tr>
												<tr id="singbox_ws_path_fields" style="display:none">
													<th><#singbox_013#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_ws_path" value="<% nvram_get_x("", "singbox_ws_path"); %>" />
													</td>
												</tr>
											</table>
										</div>

										<!-- ========== Tab: Rules ========== -->
										<div class="tab-pane" id="tab_rules">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#singbox_022#></th>
													<td>
														<select name="singbox_mode" class="input" style="width: 200px">
															<option value="1" <% nvram_match_x("", "singbox_mode", "1", "selected"); %>><#singbox_023#></option>
															<option value="0" <% nvram_match_x("", "singbox_mode", "0", "selected"); %>><#singbox_024#></option>
															<option value="2" <% nvram_match_x("", "singbox_mode", "2", "selected"); %>><#singbox_025#></option>
														</select>
													</td>
												</tr>
												<tr>
													<th><#singbox_028#></th>
													<td>
														<select name="singbox_route_mode" class="input" style="width: 200px">
															<option value="1" <% nvram_match_x("", "singbox_route_mode", "1", "selected"); %>><#singbox_029#></option>
															<option value="0" <% nvram_match_x("", "singbox_route_mode", "0", "selected"); %>><#singbox_030#></option>
															<option value="2" <% nvram_match_x("", "singbox_route_mode", "2", "selected"); %>><#singbox_031#></option>
														</select>
													</td>
												</tr>
												<tr>
													<th><#singbox_048#></th>
													<td>
														<textarea class="input" style="width: 380px; height: 120px" name="singbox_route_rules" wrap="off"><% nvram_get_x("", "singbox_route_rules"); %></textarea>
														<br/><span style="color: #666; font-size: 12px;"><#singbox_049#></span>
													</td>
												</tr>
											</table>
										</div>

										<!-- ========== Tab: Advanced ========== -->
										<div class="tab-pane" id="tab_advanced">
											<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
												<tr>
													<th width="30%"><#singbox_026#></th>
													<td>
														<input type="text" class="input" size="8" maxlength="5" name="singbox_local_port" value="<% nvram_get_x("", "singbox_local_port"); %>" />
														&nbsp;<span class="label"><#singbox_027#></span>
													</td>
												</tr>
												<tr>
													<th><#singbox_032#></th>
													<td>
														<div class="main_itoggle">
															<div id="singbox_dns_hijack_on_of">
																<input type="checkbox" id="singbox_dns_hijack_fake" <% nvram_match_x("", "singbox_dns_hijack", "1", "value=1 checked"); %><% nvram_match_x("", "singbox_dns_hijack", "0", "value=0"); %> />
															</div>
														</div>
														<div style="position: absolute; margin-left: -10000px;">
															<input type="radio" value="1" name="singbox_dns_hijack" id="singbox_dns_hijack_1" <% nvram_match_x("", "singbox_dns_hijack", "1", "checked"); %> /><#checkbox_Yes#>
															<input type="radio" value="0" name="singbox_dns_hijack" id="singbox_dns_hijack_0" <% nvram_match_x("", "singbox_dns_hijack", "0", "checked"); %> /><#checkbox_No#>
														</div>
													</td>
												</tr>
												<tr>
													<th><#singbox_033#></th>
													<td>
														<input type="text" class="input" size="8" maxlength="5" name="singbox_api_port" value="<% nvram_get_x("", "singbox_api_port"); %>" />
														&nbsp;<span class="label"><#singbox_034#></span>
													</td>
												</tr>
												<tr>
													<th><#singbox_035#></th>
													<td>
														<select name="singbox_log_level" class="input" style="width: 200px">
															<option value="error" <% nvram_match_x("", "singbox_log_level", "error", "selected"); %>>error</option>
															<option value="warn" <% nvram_match_x("", "singbox_log_level", "warn", "selected"); %>>warn</option>
															<option value="info" <% nvram_match_x("", "singbox_log_level", "info", "selected"); %>>info</option>
															<option value="debug" <% nvram_match_x("", "singbox_log_level", "debug", "selected"); %>>debug</option>
														</select>
													</td>
												</tr>
												<tr>
													<th><#singbox_036#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_geoip_url" value="<% nvram_get_x("", "singbox_geoip_url"); %>" />
													</td>
												</tr>
												<tr>
													<th><#singbox_041#></th>
													<td>
														<input type="text" class="input" style="width: 300px" name="singbox_geosite_url" value="<% nvram_get_x("", "singbox_geosite_url"); %>" />
													</td>
												</tr>
											</table>
										</div><!-- /tab_advanced -->

										<!-- ========== Tab: Config File ========== -->
										<div class="tab-pane" id="tab_config">
											<p style="color: #666; font-size: 12px; margin: 5px 0;">
												<#singbox_config_help#>
											</p>
											<textarea id="config_view" class="input" style="width: 100%; height: 480px; font-family: monospace; font-size: 12px;"></textarea>
											<div style="margin-top: 8px;">
												<input class="btn btn-primary btn-small" style="width: 100px" type="button" value="<#singbox_config_save#>" onclick="saveConfig()" />
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
		</div>

	</form>

	<div id="footer"></div>
</div>
</body>
</html>
