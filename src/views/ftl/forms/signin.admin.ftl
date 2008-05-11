<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title> Admin Sign on </title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/user.header.ftl"><tr>
<#include "/ftl/left.menu.ftl"><td class="user_space">
<#if signoutMessage><p style="color: blue; font-weight:bold; text-align:center"> ${signoutMessage} </p>
<hr class="separator" noshade="noshade">
</#if><#include "/ftl/errors.ftl"><#include "/ftl/messages.ftl">
<div class="ie_center_hack">

<h1> Administrator sign in </h1>

<form class="signin" action="<@s.url namespace="/" action="login" />" method="post">
<input name="username" value="admin" type="hidden">
<div class="formelt mandatory">Admin Password<input class="text" type="password" name="password"></div>
<div align="center"> <input class="submit" type="submit" name="submit" value="Sign in"> </div>
</form>
</div>

</td>
</tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
