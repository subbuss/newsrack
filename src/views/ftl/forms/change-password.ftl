<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Change your password!</title>
</head>

<body>

<@s.set name="user" value="#session.user" />
<#if user?exists>
<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<#include "/ftl/layout/errors.ftl">
		<h1>Password change form for ${user.uid}</h1>

				<!-- Password change form -->
		<div class="ie_center_hack">
		<form class="register" style="width:260px" action="<@s.url namespace="/password" action="change-password" />" method="post">
		<div class="formelt mandatory"> Old <input class="text" name="oldPassword" type="password" /> </div>
		<div class="formelt mandatory"> New <input class="text" name="newPassword" type="password"> </div>
		<div class="formelt mandatory"> New (confirm) <input class="text" name="newPasswordConfirm" type="password"> </div>
		<div align="center"> <input class="submit" name="submit" value="Change" type="submit"> </div>
		</form>
		</div>
	</td>
</tr>
</table>
</div>
<#else>
<#include "/ftl/layout/no.user.ftl">
</#if>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
