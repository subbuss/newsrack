<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title> Sign In </title>
<#include "/ftl/layout/common_includes.ftl">
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

<#assign readonly = false>
<#if readonly>
<#include "/ftl/layout/maintenance.ftl">
<#else>
<h1> Sign In </h1>

<p>
If you have an user account, please sign in
with your user id and password to enter your personal user space.
</p>

<div class="ie_center_hack">
<form class="signin" action="<@s.url namespace="/" action="login" />" method="post">
<div class="formelt mandatory">User-id<input class="text" type="text" name="username"<#if username?exists> value="${username}"</#if>></div>
<div class="formelt mandatory">Password<input class="text" type="password" name="password"></div>
<div align="center"> <input class="submit" type="submit" name="submit" value="Sign in"> </div>
<div class="forgot_password"> <a href="<@s.url namespace="/forms" action="forgot-password" />">Forgot Password?</a></div>
</form>
</div>
<#--
<@s.form namespace="/" action="login" method="post">
<#if username?exists>
<@s.textfield key="label.uid" name="username" value="${username}" />
<#else>
<@s.textfield key="label.uid" name="username" />
</#if>
<@s.password key="label.pwd" name="password" />
<@s.submit key="label.signin" />
<@s.url id="url" namespace="/forms" action="forgot-password" />
<@s.a href="${url}">Forgot Password?</@s.a>
</@s.form>
-->

<p>
If you don't have an account, you can <a href="<@s.url namespace="/forms" action="register" />">register</a>
yourself.  If you register, you monitor topics that interest you.
</p>
</div>

</#if> <#-- read-only -->
</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
