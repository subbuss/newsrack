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
<table class="userhome" cellspacing="0">
<#include "/ftl/user.header.ftl">
<tr>
<#include "/ftl/left.menu.ftl">
<td class="user_space">
<#include "/ftl/errors.ftl">
<#include "/ftl/messages.ftl">
	<h1 class="underline"> Download news </h1>
	<p>
	Periodically (every 2 hours at this time), news is automatically
	downloaded from all the news sources you have specified in your
	profile.  So, it is not necessary to explicitly request a news download.
	However, if you would like to download news right now rather than wait
	for news to be downloaded at the next scheduled time, click on the
	button below. 

	<div class="ie_center_hack">
	<form class="ie_center_hack" method="post" action="<@s.url namespace="/news" action="download" />">
	<input class="submit" name="DownloadNews" value="Download News" type="submit">
	</form>
	</div>

	</p>

</tr>
</table>
</div>
</@s.if>
<@s.else>
<#include "/ftl/no.user.ftl" parse="y">
<@/s.else>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
