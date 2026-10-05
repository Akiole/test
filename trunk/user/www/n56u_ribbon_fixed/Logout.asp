<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<script>
function initial(){
	var xmlhttp;
	try{
		if (window.XMLHttpRequest)
			xmlhttp=new XMLHttpRequest();
		else
			xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}catch (e){
		xmlhttp=null;
	}
	if (xmlhttp != null){
		xmlhttp.open("HEAD","logout",true,"logout","");
		xmlhttp.send(null);
	}
	// 注销后 3 秒自动跳转主页
	var countdown = 3;
	var timer = setInterval(function(){
		countdown--;
		var el = document.getElementById('redirect_countdown');
		if (el) el.textContent = countdown;
		if (countdown <= 0){
			clearInterval(timer);
			window.location.href = '/';
		}
	}, 1000);
}
</script>
</head>
<body onload="initial()">
    <div style="margin-top: 50px;">
        <center>
            <div class="well" style="max-width: 600px;">
                <h2><#logoutmessage#></h2>

                <div><#Not_authpage_login_again#></div>
                <div style="margin-top: 15px; color: #666;">
                    <span id="redirect_countdown">3</span> <#logout_redirect#>
                </div>
            </div>
        </center>
    </div>
</body>
</html>
