<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>${title}</title>
<style>
<!--
td.user_news_space pre {
   margin : 5px 10px;
}
div<#call newsItemCats> {
	width       : auto;
	background  : white;
	font-weight : normal;
	border      : 0px;
}
-->
</style>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
	<#include "/ftl/user.header.ftl"><tr>
	<#include "/ftl/left.menu.ftl">	<td class="user_news_space">
	<#include "/ftl/errors.ftl">	<#include "/ftl/messages.ftl"><#assign url = request.getParameter("url")><#if url>	<div id="newsItemHdr">
	This article is being shown from: ${url}
	</div>
   <iframe src="${url}" style="background:white; width:600px; height:100%" frameborder="0">
   Iframe not working on your browser!  <a target="_blank" href="${url}">Go to the page directly!</a>
   </iframe>
<#else>   Missing parameter ${url}
</#if></tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
