<#-- VIM hack to allow syntax highlighting (the DOCTYPE below screws up VIM)
--><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<#-- Prevent crawlers from caching the content
--><meta name="ROBOTS" content="NOARCHIVE,NOINDEX">
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
	<#include "/ftl/errors.ftl">	<#include "/ftl/messages.ftl"><#if url>	<div id="newsItemHdr">
	This article was downloaded from: ${url}
	</div>
</#if><#if ni>	<div id="newsItemCats">
<#--	This article has been classified in the following NewsRack categories [USER : ISSUE : CATEGORY] <br />
-->	This article has been classified in the following NewsRack categories [USER :: CATEGORY] <br />
	<span style="font-weight:bold">
	<#assign cats = ni.getCategories()>	<#foreach nc in cats><#assign cat = nc><#assign uid = cat.getUser().getUid()><#assign issue = cat.getIssue().getName()><#assign catID = cat.getCatId()><#assign catName = cat.getName()>	[${uid} ::
<#--	 <a href="<@s.url namespace="/" action="browse" owner="uid" issue="issue" />">$issue</a> : -->
	<a href="<@s.url namespace="/" action="browse" owner="uid" issue="issue" catID="catID" />">${catName}</a>] &nbsp;
	</#foreach>	</span>
	</div>
<#else>	<div id = "newsItemCats">
	FOUND NO CLASSIFIED CATS!
	</div>
</#if>	<h1> ${title} </h1>
	${body}
	</td>
</tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
