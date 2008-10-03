<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>User space</title>
</head>

<body>

<@s.set name="user" value="#session.user" />

<@s.if test="#user">
<div class="bodymain">
<table class="userhome">
	<#include "/ftl/layout/header.ftl">
	<tr>
	<#include "/ftl/layout/left.menu.ftl">
	<td class="user_space">
	<#include "/ftl/layout/errors.ftl">
	<#include "/ftl/layout/messages.ftl">
		<h1 class="underline">${user.uid}'s news space</h1>
		<p> </p>
	<@s.if test="!#user.validated">
		<p class="center bold">
		You do not yet have any validated topics! &nbsp;&nbsp;
		<a href="<@s.url namespace="/user" action="edit-profile" />">Click here</a> 
		and create / validate your topics.
		</p>

		<#include "/ftl/help/monitoring.steps.ftl">
	</@s.if>
	<@s.else>
    <#assign issues=user.issues>
    <#if issues?exists>

		<#--### DISPLAY ISSUES ##### -->
		<div class="ie_center_hack">
		<table cellspacing="0" class="userissuelisting">
		<tr class="tblhdr">
			<td>Issue</td>
			<td style="width:60px">RSS feed</td>
			<td style="width:90px">New since <br>${user.lastDownloadTime_String}</td>
			<td>Time of <br>last update</td>
		</tr>
      <#foreach i in issues>
			<tr>
			<td style="text-align:right">
        <#if i.frozen> (<span style="color:00a;font-weight:bold;"> FROZEN </span>) </#if>
				<a class="browsecat" href="<@s.url namespace="/" action="browse" owner="${user.uid}" issue="${i.name}" />">${i.name}</a>
				<span class="artcount">[${i.numArticles}]</span>
			</td>
			<td>
				<a class="rssfeed" href="${i.getRSSFeedURL()}">RSS 2.0</a>
			</td>
			<td class="center">
        <#if (i.numItemsSinceLastDownload > 0) && user.lastDownloadTime?exists && lastDownloadTime?exists && user.lastDownloadTime.after(lastDownloadTime)>
				(<span class="newartcount">${i.numItemsSinceLastDownload} new</span>) &nbsp;
				<#else>
				(None) &nbsp;
				</#if>
			</td>
			<td class="center">
        <#assign lut=i.lastUpdateTime_String>
        <#if lut?exists> ${lut} <#else> -- </#if>
			</td>
			</tr>
			</#foreach>
		</table>
		</div>
		<#else>
		<p class="bold center">You have not built your issues yet!</p>
		<p class="justify">Without that, you cannot monitor news and add them to your issues. </p>
		<p>
		Please go to the
		<a href="<@s.url namespace="/user" action="edit-profile" />">edit issues page</a> 
		and build your issues.
		</p>
		</#if> <#-- of #if issues -->
	</@s.else> <#-- of #if active-profile exists -->
	</td>
</tr>
</table>
</div>
</@s.if>
<@s.else> <#-- user signed in -->
<#include "/ftl/layout/no.user.ftl">
</@s.else>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
