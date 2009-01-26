<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Browse News By Source</title>
</head>

<body>

<#assign months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]>

<@s.set name="user" value="#session.user" />
<#if user?exists>
<div class="bodymain">
<table class="userhome" cellspacing="0">
	<#include "/ftl/layout/header.ftl">
  <tr>
	<#include "/ftl/layout/left.menu.ftl">
  <td class="user_space">
	<#include "/ftl/layout/errors.ftl">
  <#include "/ftl/layout/messages.ftl">
	<h1 class="underline">Browse News By Source</h1>

	<div class="ie_center_hack">
	<form class="ie_center_hack" method="post" action="<@s.url namespace="/" action="browse-source" />">
	<table class="dates">

	<tr> <td class="tblhdr center bold"> Sources </td> </tr>
	<tr> <td class="brownish center">
	<select name="srcId" size="10">
<#assign srcs = user.sources>
<#foreach s in srcs>
    <option value="${s.tag}">${s.name}</option>
</#foreach>
  </select>
	</tr>

	<tr> <td class="tblhdr center bold"> Date </td> </tr>
	<tr>
	<td class=" center brownish">
	<select name="d">
<#foreach num in 1..31>
    <option value="${num}">${num}</option>
</#foreach>
  </select>
	<select name="m">
  <#foreach month in months>
    <option value="${1+months?seq_index_of(month)}">${month}</option>
  </#foreach>
	</select>
	<select name="y">
<#foreach num in 2004..2009>
    <option value="${num?c}">${num?c}</option>
</#foreach>
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
<#else><#include "/ftl/layout/no.user.ftl"></#if>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
