<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title> ${username}: You are now registered with NewsRack </title>
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<h1> Registration Successful!</h1>
<h2 style="font-size:14px; text-align:center">
You are now successfully registered as <span style="color:red">${username}</span>.
</h2>
<p>
A user space has now been created for you.
Please <a href="<@s.url namespace="/forms" action="login" />"><b>sign in</b></a>
to the system to add a user profile.  This user profile will be used to download
news that you are interested in.
</p>

</tr>
</td>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
