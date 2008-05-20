<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title> Forgot Password? </title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<#include "/ftl/layout/errors.ftl">
<#include "/ftl/layout/messages.ftl">
<div>

<p> Please enter your user id.  A password reset link will be sent to the email id you used to register. </p>

<div class="ie_center_hack">
<form class="signin" action="<@s.url namespace="/password" action="send-reset-key" />" method="post">
<div class="formelt mandatory">User-id<input class="text" type="text" name="uid"></div>
<div align="center"> <input class="submit" type="submit" name="submit" value="Submit"> </div>
</form>
</div>

<p>
If you don't know your user id,
<a href="<@s.url namespace="/about" action="contact" />">send email</a>
specifying the email you used to register, and we'll send you
a password reset link, if possible, to your registered email id.
</p>

</div>

</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
