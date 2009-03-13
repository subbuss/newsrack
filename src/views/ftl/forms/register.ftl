<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Register with NewsRack</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<script type="text/javascript">
function initAddition()
{
  var n1 = Math.floor(Math.random() * 20);
  var n2 = Math.floor(Math.random() * 20);
  document.getElementById("n1").innerHTML = n1;
  document.getElementById("n2").innerHTML = n2;
  document.getElementById("n1_plus_n2").value = n1 + n2;
}
</script>
</head>

<body onload="initAddition()">

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
News Monitoring via NewsRack requires you to be able to spend a little effort
writing news filters in a relatively easy-to-learn, but non-trivial, format.
This is still text-based and there is no easy graphical interface to make this
process easier.  Familiarity with writing filters using AND, OR, NOT will be helpful.
<br/><br/>
<strong><a href="<@s.url namespace="/help" action="example1" />">A simple example of writing filters</a></strong>
<br/><br/>
<#--
<strong><a href="<@s.url namespace="/forms" action="updates-form" />">Sign up here</a> if you would much rather
leave your email and be contacted when the user interface improves.</strong>
If you are comfortable with the skill required and would like to experiment with this service,
go ahead and register.  Welcome!
-->
</p>

<div class="ie_center_hack">
<@s.form cssClass="register" namespace="/" action="register" method="post">
<div class="formelt">           Name     <input class="text" name="name" type="text"<#if name?exists> value="${name}"</#if>> </div>
<div class="formelt mandatory"> User-id  <input class="text" name="username" type="text"<#if username?exists> value="${username}"</#if>> </div>
<div class="formelt mandatory"> Password <input class="text" name="password" type="password"> </div>
<div class="formelt mandatory"> Password (confirm) <input class="text" name="passwordConfirm" type="password"> </div>
<div class="formelt mandatory"> Email id <input class="text" name="emailid" type="text"<#if emailid?exists> value="${emailid}"</#if>> </div>
<div style="padding:10px 5px; font-size:12px; text-align: center; color:red"> <strong style="font-size:14px"> Are you a human? </strong> (This prevents automated registration by spambots!) </div>
<input name="humanSumValue" id="n1_plus_n2" value="19" type="hidden">
<div class="formelt mandatory"> What is <span id="n1">7</span> + <span id="n2">12</span>? <input class="text" name="humanSumResponse" type="humanSumResponse"> </div>
<div align="center"> <input class="submit" name="submit" value="Register" type="submit"> </div>
</@s.form>
</div>

<br />

<p>
If you have an user account, <a href="<@s.url namespace="/forms" action="login" />"><strong>sign in</strong></a>
or, you can skip registration and <a href="<@s.url namespace="/" action="browse" />"><strong>browse publicly available
issues</strong></a> of other registered users.
</p>

</#if> <#-- read-only -->
</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
