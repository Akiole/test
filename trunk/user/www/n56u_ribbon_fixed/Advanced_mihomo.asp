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
			try { show_menu(19,0); } catch (e) {}
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

		// ---- Clash API helpers ----
		var _mh_last_down = 0, _mh_last_up = 0, _mh_last_time = 0;

		function getApiBase() {
			var port = document.form.mihomo_api_port ? document.form.mihomo_api_port.value : '9090';
			if (!port || port == '0') port = '9090';
			return location.protocol + '//' + location.hostname + ':' + port;
		}

		function fmtBytes(b) {
			if (b < 1024) return b + ' B';
			if (b < 1048576) return (b / 1024).toFixed(1) + ' KB';
			if (b < 1073741824) return (b / 1048576).toFixed(1) + ' MB';
			return (b / 1073741824).toFixed(2) + ' GB';
		}

		function fmtRate(bps) {
			if (bps < 1024) return bps.toFixed(0) + ' B/s';
			if (bps < 1048576) return (bps / 1024).toFixed(1) + ' KB/s';
			return (bps / 1048576).toFixed(2) + ' MB/s';
		}

		function refreshTraffic() {
			var base = getApiBase();
			$j.ajax({
				url: base + '/connections',
				type: 'GET',
				timeout: 3000,
				success: function (data) {
					try {
						var now = Date.now();
						var down = data.downloadTotal || 0;
						var up = data.uploadTotal || 0;
						var connCount = data.connections ? data.connections.length : 0;
						var mem = data.memory ? data.memory : 0;

						if (_mh_last_time > 0) {
							var dt = (now - _mh_last_time) / 1000;
							if (dt > 0) {
								var dr = (down - _mh_last_down) / dt;
								var ur = (up - _mh_last_up) / dt;
								var el_dr = document.getElementById('mh_rate_down');
								var el_ur = document.getElementById('mh_rate_up');
								if (el_dr) el_dr.innerHTML = fmtRate(dr < 0 ? 0 : dr);
								if (el_ur) el_ur.innerHTML = fmtRate(ur < 0 ? 0 : ur);
							}
						}
						_mh_last_down = down;
						_mh_last_up = up;
						_mh_last_time = now;

						var el_td = document.getElementById('mh_total_down');
						var el_tu = document.getElementById('mh_total_up');
						var el_conn = document.getElementById('mh_conn_count');
						var el_mem = document.getElementById('mh_mem_usage');
						if (el_td) el_td.innerHTML = fmtBytes(down);
						if (el_tu) el_tu.innerHTML = fmtBytes(up);
						if (el_conn) el_conn.innerHTML = connCount;
						if (el_mem && mem > 0) el_mem.innerHTML = fmtBytes(mem);
					} catch (e) {}
				},
				error: function () {
					var el_dr = document.getElementById('mh_rate_down');
					var el_ur = document.getElementById('mh_rate_up');
					if (el_dr) el_dr.innerHTML = '--';
					if (el_ur) el_ur.innerHTML = '--';
				}
			});
		}

		function refreshCurrentProxy() {
			var base = getApiBase();
			$j.ajax({
				url: base + '/proxies',
				type: 'GET',
				timeout: 3000,
				success: function (data) {
					try {
						var groups = data.proxies ? data.proxies : {};
						var proxyGroup = groups['PROXY'];
						if (proxyGroup && proxyGroup.now) {
							var el = document.getElementById('mh_current_node');
							if (el) el.innerHTML = proxyGroup.now;
						}
					} catch (e) {}
				}
			});
		}

		function testNodeDelay(nodeName) {
			var base = getApiBase();
			var safeId = nodeName.replace(/[^a-zA-Z0-9]/g, '_');
			var listEl = document.getElementById('mh_delay_list');
			if (listEl) {
				var existing = document.getElementById('delay_row_' + safeId);
				if (!existing) {
					var row = document.createElement('div');
					row.id = 'delay_row_' + safeId;
					row.innerHTML = '<span style="display:inline-block; width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="' + nodeName + '">' + nodeName + '</span> <span id="delay_' + safeId + '" style="color:#999;">testing...</span>';
					listEl.appendChild(row);
				} else {
					var el = document.getElementById('delay_' + safeId);
					if (el) el.innerHTML = '<span style="color:#999;">testing...</span>';
				}
			}
			var url = base + '/proxies/' + encodeURIComponent(nodeName) + '/delay?timeout=5000&url=http://www.gstatic.com/generate_204';
			$j.ajax({
				url: url,
				type: 'GET',
				timeout: 6000,
				success: function (data) {
					var el = document.getElementById('delay_' + safeId);
					if (el) {
						if (data.delay !== undefined) {
							var color = data.delay < 300 ? 'green' : (data.delay < 800 ? 'orange' : 'red');
							el.innerHTML = '<span style="color:' + color + ';">' + data.delay + ' ms</span>';
						} else {
							el.innerHTML = '<span style="color:red;">ERR</span>';
						}
					}
				},
				error: function () {
					var el = document.getElementById('delay_' + safeId);
					if (el) el.innerHTML = '<span style="color:red;">TIMEOUT</span>';
				}
			});
		}

		function testSelectedDelay() {
			var selects = document.getElementsByName('mihomo_sub_node');
			if (selects.length === 0) return;
			var sel = selects[0];
			if (sel.selectedIndex >= 0) {
				testNodeDelay(sel.options[sel.selectedIndex].text);
			}
		}

		function switchSelectedNode() {
			var selects = document.getElementsByName('mihomo_sub_node');
			if (selects.length === 0) return;
			var sel = selects[0];
			if (sel.selectedIndex >= 0) {
				switchProxyNode(sel.options[sel.selectedIndex].text);
			}
		}

		function switchProxyNode(nodeName) {
			var base = getApiBase();
			$j.ajax({
				url: base + '/proxies/PROXY',
				type: 'PUT',
				contentType: 'application/json',
				data: JSON.stringify({ name: nodeName }),
				timeout: 3000,
				success: function () {
					refreshCurrentProxy();
					var el = document.getElementById('mh_switch_msg');
					if (el) {
						el.innerHTML = '<span style="color:green;"><#mihomo_switched#></span>';
						setTimeout(function () { el.innerHTML = ''; }, 2000);
					}
				},
				error: function () {
					var el = document.getElementById('mh_switch_msg');
					if (el) el.innerHTML = '<span style="color:red;"><#mihomo_switch_failed#></span>';
				}
			});
		}

		function testAllDelays() {
			var selects = document.getElementsByName('mihomo_sub_node');
			if (selects.length === 0) return;
			var sel = selects[0];
			var listEl = document.getElementById('mh_delay_list');
			if (listEl) listEl.innerHTML = '';
			for (var i = 0; i < sel.options.length; i++) {
				testNodeDelay(sel.options[i].text);
			}
		}

		setInterval("refreshStatus()", 10000);
		setInterval("refreshTraffic()", 2000);
		setInterval("refreshCurrentProxy()", 5000);
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
												<tr>
													<th><#mihomo_current_node#></th>
													<td><span id="mh_current_node" style="font-weight:bold;">--</span></td>
												</tr>
												<tr>
													<th><#mihomo_rate_down#></th>
													<td><span id="mh_rate_down">--</span></td>
												</tr>
												<tr>
													<th><#mihomo_rate_up#></th>
													<td><span id="mh_rate_up">--</span></td>
												</tr>
												<tr>
													<th><#mihomo_total_down#></th>
													<td><span id="mh_total_down">--</span></td>
												</tr>
												<tr>
													<th><#mihomo_total_up#></th>
													<td><span id="mh_total_up">--</span></td>
												</tr>
												<tr>
													<th><#mihomo_conn_count#></th>
													<td><span id="mh_conn_count">--</span></td>
												</tr>
												<tr>
													<th><#mihomo_mem_usage#></th>
													<td><span id="mh_mem_usage">--</span></td>
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
														&nbsp;
														<input class="btn btn-info btn-small" type="button" value="<#mihomo_test_delay#>" onclick="testSelectedDelay()" />
														<input class="btn btn-small" type="button" value="<#mihomo_test_all#>" onclick="testAllDelays()" />
														<input class="btn btn-primary btn-small" type="button" value="<#mihomo_switch_node#>" onclick="switchSelectedNode()" />
														<span id="mh_switch_msg" style="margin-left: 10px;"></span>
													</td>
												</tr>
												<tr>
													<th><#mihomo_delay_result#></th>
													<td>
														<div id="mh_delay_list" style="font-size: 12px; max-height: 200px; overflow-y: auto; border: 1px solid #ddd; padding: 5px; background: #fafafa;">
															<span style="color: #999;"><#mihomo_delay_hint#></span>
														</div>
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
