<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<#include "/ftl/layout/common_includes.ftl">
<title>Public files</title> 
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<h1 class="underline"> Publicly available files </h1>

<@s.set name="user" value="#session.user" />

<@s.if test="publicFiles">
<p class="justify">
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
  <@s.iterator value="publicFiles">
    <#if !fileOwner.equals(user.uid)>
    <tr>
			<td style="padding: 2px 20px 2px 20px">${fileOwner}</td>
			<td> 
			${fileName} [
			<a target="_blank" href="<@s.url namespace="/file" action="display" owner="${fileOwner}" file="${fileName}" />">View</a>,
			<a href="<@s.url namespace="/file" action="copy" owner="${fileOwner}" file="${fileName}" />">Copy</a>,
			<a href="<@s.url namespace="/file" action="download" owner="${fileOwner}" file="${fileName}" />">Download</a>
			] </td>
		</tr>
    </#if>
	</@s.iterator>
  </tbody>
	</table>
	</div>
</@s.if>
<@s.else>
<p> Sorry, there are no publicly available files yet. </p>
</@s.else>
</tr>
</td>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
