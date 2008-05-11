<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Browse News By Source</title>
</head>

<body>

<#if user><div class="bodymain">
<table class="userhome" cellspacing="0">
	<#include "/ftl/user.header.ftl"><tr>
	<#include "/ftl/left.menu.ftl">	<td class="user_space">
	<#include "/ftl/errors.ftl">	<#include "/ftl/messages.ftl">
	<h1 class="underline">Browse News By Source</h1>

	<div class="ie_center_hack">
	<form class="ie_center_hack" method="post" action="<@s.url namespace="/" action="browse" />">
	<table class="dates">

	<tr> <td class="tblhdr center bold"> Sources </td> </tr>
	<tr> <td class="brownish center">
	<select name="source" size="10">
<#assign srcs = user.getSources()><#foreach s in srcs>	<option value="${s.getTag()}">${s.getName()}</option>
</#foreach>	</select>
	</tr>

	<tr> <td class="tblhdr center bold"> Date </td> </tr>
	<tr>
	<td class=" center brownish">
	<select name="d">
<#foreach num in 1..31>	<option value="${num}">${num}</option>
</#foreach>	</select>
	<select name="m">
	<option selected value="1">Jan</option>
	<option value="2">Feb</option>
	<option value="3">Mar</option>
	<option value="4">Apr</option>
	<option value="5">May</option>
	<option value="6">Jun</option>
	<option value="7">Jul</option>
	<option value="8">Aug</option>
	<option value="9">Sep</option>
	<option value="10">Oct</option>
	<option value="11">Nov</option>
	<option value="12">Dec</option>
	</select>
	<select name="y">
<#foreach num in 2004..2006>	<option value="${num}">${num}</option>
</#foreach>	<option selected value="2007">2007</option>
	</select>
	</td>
	</tr>

	<tr>
	<td class="brownish center">
	<input type="submit" class="submit" name="Browse" value="Browse Source">
	</td>
	</tr>
	</table>
	</form>
	</div>
</tr>
</table>
</div>
<#else><#include "/ftl/no.user.ftl"></#if>
<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
