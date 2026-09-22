<% 
// AP 中继日志页面
// 通过 SystemCmd 机制获取日志
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>AP 中继日志</title>
<style>
body { font-family: monospace; font-size: 12px; padding: 10px; }
pre { white-space: pre-wrap; word-wrap: break-word; }
</style>
</head>
<body>
<h4>AP 中继日志（最近 50 条）</h4>
<pre id="logcontent">加载中...</pre>
<script>
// 通过 SystemCmd 获取日志
var form = document.createElement('form');
form.method = 'POST';
form.action = '/start_apply.htm';
form.target = 'hidden_frame';
var input1 = document.createElement('input');
input1.name = 'action_mode';
input1.value = 'SystemCmd';
form.appendChild(input1);
var input2 = document.createElement('input');
input2.name = 'SystemCmd';
input2.value = 'logread | grep -E "AP 中继|连接 AP|智能切换" | tail -50 > /tmp/ap_relay_log.txt';
form.appendChild(input2);
var input3 = document.createElement('input');
input3.name = 'current_page';
input3.value = '/ap_relay_log.asp';
form.appendChild(input3);
document.body.appendChild(form);
form.submit();

// 2秒后读取日志
setTimeout(function(){
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/ap_relay_log.txt', true);
    xhr.onload = function(){
        document.getElementById('logcontent').textContent = xhr.responseText || '暂无日志';
    };
    xhr.onerror = function(){
        document.getElementById('logcontent').textContent = '无法获取日志';
    };
    xhr.send();
}, 2000);
</script>
<iframe name="hidden_frame" style="display:none;"></iframe>
</body>
</html>
