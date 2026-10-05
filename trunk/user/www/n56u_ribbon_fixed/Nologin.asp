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

.alert {
  padding: 20px 25px;
  color: #3a87ad;
  background-color: rgba(217, 237, 247, 0.95);
  border: 1px solid #bce8f1;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  width: 420px;
  font-family: Arial, Verdana, Helvetica, sans-serif;
  text-align: left;
  line-height: 1.8;
}

#logined_ip_str {
    color: #BD362F;
    font-weight: bold;
}

@media (max-width: 480px) {
  .alert {
    width: 90%;
    padding: 15px 20px;
  }
}
</style>

<script>
<% login_state_hook(); %>

function initial(){
  /* If loaded inside an iframe, break out to the top window. */
  if (window.top !== window.self) {
    try {
      window.top.location.href = '/Nologin.asp';
    } catch (e) {
      window.top.location = '/Nologin.asp';
    }
    return;
  }
  document.getElementById("logined_ip_str").innerHTML = login_ip_str();
}
</script>
</head>

<body onload="initial()">
<center>
    <div class="alert alert-info">
        <p><#login_hint1#> <span id="logined_ip_str"></span></p>
        <p><#login_hint2#></p>
    </div>
</center>
</body>
</html>
