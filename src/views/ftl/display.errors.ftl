
<#-- VIM hack to allow syntax highlighting (the DOCTYPE below screws up VIM)
--><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>User space</title>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
	<#include "/ftl/user.header.ftl"><tr>
	<#include "/ftl/left.menu.ftl">	<td class="user_space">
	<#include "/ftl/errors.ftl">	<#include "/ftl/messages.ftl">	</td>
</tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
