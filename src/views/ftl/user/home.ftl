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
	<#include "/ftl/user.header.ftl">
	<tr>
	<#include "/ftl/left.menu.ftl">
	<td class="user_space">
	<#include "/ftl/errors.ftl">
	<#include "/ftl/messages.ftl">
		<h1 class="underline"><@s.property value="#user.uid" />'s news space</h1>
		<p> </p>
	<@s.if test="!#user.validated">
		<p class="center bold">
		You do not yet have any validated topics! &nbsp;&nbsp;
		<a href="<@s.url namespace="/user" action="edit-profile" />">Click here</a> 
		and create / validate your topics.
		</p>

		<#include "/ftl/monitoring.steps.ftl">
	</@s.if>
	<@s.else>
		<@s.set name="issues" value="#user.issues" />
		<@s.if test="#issues"> <!-- NOW, DISPLAY THE NEWS ITEMS -->

		<#--### DISPLAY ISSUES ##### -->
		<div class="ie_center_hack">
		<table cellspacing="0" class="userissuelisting">
		<tr class="tblhdr">
			<td>Issue</td>
			<td style="width:60px">RSS feed</td>
			<td style="width:90px">New since <br><@s.property value="#user.lastDownloadTime" /></td>
			<td>Time of <br>last update</td>
		</tr>
			<@s.iterator value="#issues">
			<tr>
			<td style="text-align:right">
				<a class="browsecat" href="<@s.url namespace="/" action="browse"><@s.param name="owner" value="#user.uid" /><@s.param name="issue" value="name" /></@s.url>"><@s.property value="name" /></a>
				<span class="artcount">[<@s.property value="numArticles" />]</span>
			</td>
			<td>
				<a class="rssfeed" href="<@s.property value="getRSSFeedURL()" />">RSS 2.0</a>
			</td>
			<td class="center">
				<@s.set name="numNew" value="numItemsSinceLastDownload" />
				<@s.if test="#numNew > 0">
				(<span class="newartcount"><@s.property value="#numNew" /> new</span>) &nbsp;
				</@s.if>
				<@s.else>
				(None) &nbsp;
				</@s.else>
			</td>
			<td class="center">
				<@s.set name="lut" value="lastUpdateTime_String" />
				<@s.if test="#lut != null"> <@s.property value="#lut" /> </@s.if><@s.else> -- </@s.else>
			</td>
			</tr>
			</@s.iterator>
		</table>
		</div>
		</@s.if> <#-- of #if issues -->
		<@s.else>
		<p class="bold center">You have not built your issues yet!</p>
		<p class="justify">Without that, you cannot monitor news and add them to your issues. </p>
		<p>
		Please go to the
		<a href="<@s.url namespace="/user" action="edit-profile" />">edit issues page</a> 
		and build your issues.
		</p>
		</@s.else> <#-- of #if issues -->
	</@s.else> <#-- of #if active-profile exists -->
	</td>
</tr>
</table>
</div>
</@s.if>
<@s.else> <#-- user signed in -->
<#include "/ftl/no.user.ftl">
</@s.else>
<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
