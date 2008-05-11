<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Public files</title> 
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/user.header.ftl"><tr>
<#include "/ftl/left.menu.ftl"><td class="user_space">
<h1 class="underline"> Publicly available files </h1>

<#if publicFiles>	<p class="justify">
	The following table lists all public files that are available.
	You can download any of them onto your computer, edit them to suit your needs 
	and then upload your versions of the files into your user space to create your profile.
	Or else, you can simply copy the file into your profile, and then edit them online
	(or even use as is without any modifications).
	</p>

	<div class="ie_center_hack">
	<table cellspacing="0" class="publicfiles">
	<thead>
		<tr class="tblhdr">
			<td style="padding: 1px 20px 1px 20px"> User </td> 
			<td> File </td>
		</tr>
	</thead>
	<tbody>
	<#foreach fff in publicFiles><#assign o = fff.getFileOwner()><#assign f = fff.getFileName()><#assign s = fff.toString()>		<tr>
			<td style="padding: 2px 20px 2px 20px"> ${o} </td>
			<td> 
			${f} [
			<a target="_blank" href="<@s.url namespace="/file" action="display" owner="o" file="f" />">View</a>,
			<a href="<@s.url namespace="/file" action="copy" owner="o" file="f" />">Copy</a>,
			<a href="<@s.url namespace="/file" action="download" owner="o" file="f" />">Download</a>
			] </td>
		</tr>
	</#foreach>	</tbody>
	</table>
	</div>
<#else><p> Sorry, there are no publicly available files yet. </p>
</#if>
</tr>
</td>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
