<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<#-- Prevent crawlers from caching the content -->
<meta name="ROBOTS" content="NOARCHIVE,NOINDEX">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>${newsItem.title}</title>
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
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
  <td class="user_news_space">
<#include "/ftl/layout/errors.ftl">
<#include "/ftl/layout/messages.ftl">
  <div id="newsItemHdr">
  This article was downloaded from: <a href="${newsItem.getURL()}">${newsItem.getURL()}</a>
  </div>
<@s.if test="newsItem.leafCategories">
  <div id="newsItemCats">
  This article has been classified in the following NewsRack categories: <br />
	<span style="font-weight:bold">
  <@s.iterator value="newsItem.leafCategories">
    [${user.uid} ::
     <a href="<@s.url namespace="/" action="browse" owner="${user.uid}" issue="${issue.name}" catID="${catId}" />">${name}</a>] &nbsp;
	</@s.iterator>
  </span>
	</div>
</@s.if>
<@s.else>
  <div id="newsItemCats"> FOUND NO CLASSIFIED CATS!  </div>
</@s.else>
  <h1> ${newsItem.title} </h1>
  <pre> ${body} </pre>
	</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
