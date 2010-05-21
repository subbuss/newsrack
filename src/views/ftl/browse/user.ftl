<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<title>${owner.uid}'s topics</title>
<#include "/ftl/layout/common_includes.ftl">
</head>

<body>

<div class="bodymain">
<table class="userhome">
	<#include "/ftl/layout/header.ftl">
	<tr>
	<#include "/ftl/layout/left.menu.ftl">
	<td class="user_space">
	<#include "/ftl/layout/errors.ftl">
	<#include "/ftl/layout/messages.ftl">
		<h1 class="underline">${owner.uid}'s topics</h1>
		<p> </p>
	<@s.if test="!owner.validated">
		<p class="center bold"> ${owner.uid} does not yet have any validated topics! &nbsp;&nbsp; </p>
	</@s.if>
	<@s.else>
    <#assign issues=owner.issues>
    <#if issues?exists>

		<#--### DISPLAY ISSUES ##### -->
		<div class="ie_center_hack">
		<table cellspacing="0" class="userissuelisting">
		<tr class="tblhdr">
			<td>Issue</td>
			<td>Time of <br>last update</td>
		</tr>
      <#foreach i in issues>
			<tr>
			<td style="text-align:right">
        <#if i.frozen> (<span style="color:00a;font-weight:bold;"> FROZEN </span>) </#if>
				<a class="browsecat" href="<@s.url namespace="/" action="browse" owner="${owner.uid}" issue="${i.name}" />">${i.name}</a>
				[${i.numArticles}] &nbsp;
			   <a class="rssfeed" href="${i.getRSSFeedURL()}"><img src="/icons/rss-12x12.jpg" alt="RSS 2.0"></a>
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
		<p class="center bold"> ${owner.uid} does not yet have any validated topics! &nbsp;&nbsp; </p>
		</#if> <#-- of #if issues -->
	</@s.else> <#-- of #if active-profile exists -->
	</td>
</tr>
</table>
</div>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
