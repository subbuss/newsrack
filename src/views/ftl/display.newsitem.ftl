<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<#-- Prevent crawlers from caching the content -->
<meta name="ROBOTS" content="NOARCHIVE,NOINDEX">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>${title}</title>
<style>
<!--
td.user_news_space pre {
   margin : 5px 10px;
}
div#newsItemCats {
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
<#include "/ftl/user.header.ftl">
  <tr>
<#include "/ftl/left.menu.ftl">
  <td class="user_news_space">
<#include "/ftl/errors.ftl">
<#include "/ftl/messages.ftl">
<@s.if test="url">
  <div id="newsItemHdr">
	This article was downloaded from: <@s.property value="url" />
	</div>
</@s.if>
<@s.if test="ni">
  <div id="newsItemCats">
<#--	This article has been classified in the following NewsRack categories [USER : ISSUE : CATEGORY] <br /> -->
  This article has been classified in the following NewsRack categories [USER :: CATEGORY] <br />
	<span style="font-weight:bold">
  <@s.iterator value="ni.categories">
    [<@s.property value="user.uid" /> ::
     <a href="<@s.url namespace="/" action="browse" owner="user.uid" issue="issue.name" catID="catId" />">name</a>] &nbsp;
    <#--	 <a href="<@s.url namespace="/" action="browse" owner="uid" issue="issue" />">$issue</a> : -->
	</@s.iterator>
  </span>
	</div>
</@s.if>
<@s.else>
  <div id = "newsItemCats">
	FOUND NO CLASSIFIED CATS!
	</div>
</@s.else>
  <h1> <@s.property value="title" /> </h1>
  <@s.property value="body"  </h1>
	</td>
</tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
