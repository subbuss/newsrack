<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Register with NewsRack</title>
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
<#assign readonly = false>
<#if readonly>
<#include "/ftl/layout/maintenance.ftl">
<#else>
<h1> Register with News Rack</h1>

<p>
Please fill the form below to register yourself. Once you are registered
successfully, you can sign in to the system, create a profile, and start
downloading news of your interest.
</p>

<p>
<strong> Avoid using a password that you might use for sensitive accounts. </strong>
</p>

<br />

<div class="ie_center_hack">
<@s.form cssClass="register" namespace="/" action="register" method="post">
<div class="formelt">           Name     <input class="text" name="name" type="text"> </div>
<div class="formelt mandatory"> User-id  <input class="text" name="username" type="text"> </div>
<div class="formelt mandatory"> Password <input class="text" name="password" type="password"> </div>
<div class="formelt mandatory"> Password (confirm) <input class="text" name="passwordConfirm" type="password"> </div>
<div class="formelt mandatory"> Email id <input class="text" name="emailid" type="text"> </div>
<div style="padding:10px 5px; text-align: center; color:red"> The next line is to prevent automated registration by spambots! </div>
<input name="humanSumValue" value="19" type="hidden">
<div class="formelt mandatory"> What is 7 + 12? <input class="text" name="humanSumResponse" type="humanSumResponse"> </div>
<div align="center"> <input class="submit" name="submit" value="Register" type="submit"> </div>
</@s.form>
</div>

<br />

<p>
If you have an user account, <a href="<@s.url namespace="/forms" action="login" />"><strong>sign in</strong></a>
or, you can skip registration and <a href="<@s.url namespace="/" action="browse" />"><strong>browse publicly available
issues</strong></a> of other registered users.
</p>

</#if> <#-- read-only
-->
</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
