<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">

<style type="text/css">
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  font-family: Arial, Verdana, Helvetica, sans-serif;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}

.login-box {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  padding: 40px;
  width: 360px;
}

.login-title {
  text-align: center;
  color: #333;
  font-size: 22px;
  margin-bottom: 30px;
  font-weight: bold;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  color: #555;
  font-size: 14px;
  margin-bottom: 6px;
}

.form-group input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.3s;
}

.form-group input:focus {
  outline: none;
  border-color: #4a90d9;
  box-shadow: 0 0 0 2px rgba(74, 144, 217, 0.2);
}

.login-btn {
  width: 100%;
  padding: 12px;
  background: #4a90d9;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.3s;
}

.login-btn:hover {
  background: #357abd;
}

.login-btn:active {
  background: #2a63a8;
}

.error-msg {
  color: #d9534f;
  font-size: 13px;
  text-align: center;
  margin-bottom: 15px;
  min-height: 18px;
}

.login-hint {
  text-align: center;
  color: #999;
  font-size: 12px;
  margin-top: 20px;
}

@media (max-width: 480px) {
  .login-box {
    width: 90%;
    padding: 25px;
  }
}
</style>

<script>
function getQueryParam(name) {
  var match = window.location.search.match(new RegExp('[?&]' + name + '=([^&]*)'));
  return match ? decodeURIComponent(match[1]) : '';
}

function initial() {
  /* If loaded inside an iframe (e.g. statusframe after session timeout),
     break out to the top window so the whole page redirects to login. */
  if (window.top !== window.self) {
    try {
      window.top.location.href = '/Login.asp';
    } catch (e) {
      window.top.location = '/Login.asp';
    }
    return;
  }

  var error = getQueryParam('error');
  if (error) {
    document.getElementById('error_msg').innerHTML = '<#login_error#>';
  }
}
</script>
</head>

<body onload="initial()">
<div class="login-box">
  <div class="login-title"><#Web_Title#></div>
  <div id="error_msg" class="error-msg"></div>
  <form method="POST" action="do_login">
    <div class="form-group">
      <label for="username"><#login_username#></label>
      <input type="text" id="username" name="username" value="<% nvram_get_x("","http_username"); %>" autocomplete="username" autofocus>
    </div>
    <div class="form-group">
      <label for="password"><#login_password#></label>
      <input type="password" id="password" name="password" autocomplete="current-password">
    </div>
    <button type="submit" class="login-btn"><#login_button#></button>
  </form>
  <div class="login-hint"><#login_hint#></div>
</div>
</body>
</html>
