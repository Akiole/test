<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_title#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>

<script>
var map_code = "";

function initial(){
	show_banner(0);
	show_menu(8,0,0);
	show_footer();
	show_sitemap();
}

function show_sitemap(){
	var items = [];
	for(var i = 1; i <= 10; i++){
		if(menuL2_title[i] != ""){
			items.push({title: menuL2_title[i], link: menuL2_link[i], tab_idx: i - 1});
		}
	}
	var l2 = items.length;
	if (l2 > 8) l2 = 8;

	for(var idx = 0; idx < l2; idx++){
		var k = (idx/4 < 1)?0:3;
		$("menu_body").rows[k].cells[idx%4].innerHTML = '<b><a href="'+items[idx].link+'" style="color: inherit;">'+items[idx].title+'</a></b>';
		$("menu_body").rows[k].cells[idx%4].className = "head";
	}

	for(var idx = 0; idx < l2; idx++){
		var t = items[idx].tab_idx;
		map_code = '<ul class="nav nav-list">\n';
		for(var m = 1; m < tabtitle[t].length; m++){
			if(tablink[t][m] == "")
				continue;
			map_code += '    <li>\n';
			map_code += '        <a href="'+tablink[t][m]+'">'
			map_code += tabtitle[t][m];
			map_code += '</a>\n    </li>\n';
		}
		map_code += '</ul>\n';
		var n = (idx/4 < 1)?0:3;
		$("menu_body").rows[n+2].cells[idx%4].innerHTML = map_code;
	}
}
</script>

<style>
    table#menu_body tr td.head {text-align: center;}
    table#menu_body tr td {vertical-align: top;}
</style>

</head>

<body onload="initial();" onunload="return unload_body();">

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
                            <h2 class="box_head round_top"><#menu5_title#></h2>
                            <div class="round_bottom">

                                <div class="row-fluid">
                                    <div id="tabMenu"></div>
                                    <table class="table">
                                        <tr>
                                            <!--=====Beginning of Main Content=====-->
                                            <td style="border-top: 0 none;">
                                                <table id="menu_body" width="100%" border="0" align="center" cellpadding="3" cellspacing="1" bgcolor="#CCCCCC" class="sitemap">
                                                    <tr>
                                                        <td width="25%">&nbsp;</td>
                                                        <td width="25%">&nbsp;</td>
                                                        <td width="25%">&nbsp;</td>
                                                        <td width="25%">&nbsp;</td>
                                                    </tr>

                                                    <tr style="display: none;">
                                                        <td>&nbsp;</td>
                                                        <td>&nbsp;</td>
                                                        <td>&nbsp;</td>
                                                        <td>&nbsp;</td>
                                                    </tr>

                                                    <tr valign="top">
                                                        <td height="120"></td>
                                                        <td height="120"></td>
                                                        <td height="120"></td>
                                                        <td height="120"></td>
                                                    </tr>

                                                    <tr>
                                                        <td>&nbsp;</td>
                                                        <td>&nbsp;</td>
                                                        <td>&nbsp;</td>
                                                        <td>&nbsp;</td>
                                                    </tr>

                                                    <tr style="display: none;">
                                                        <td width="25%">&nbsp;</td>
                                                        <td width="25%">&nbsp;</td>
                                                        <td width="25%">&nbsp;</td>
                                                        <td width="25%">&nbsp;</td>
                                                    </tr>

                                                    <tr valign="top">
                                                        <td height="120"></td>
                                                        <td height="120"></td>
                                                        <td height="120"></td>
                                                        <td height="120"></td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
             </div>
        </div>
    </div>

    <div id="footer"></div>
</div>

</body>
</html>
