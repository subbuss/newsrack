<@s.set name="user" value="#session.user" />

<#assign userID = user.uid>
<#assign d = Parameters.d>
<#assign m = Parameters.m>
<#assign y = Parameters.y>

<#if Parameters.count?exists>
	<#assign numArtsPerPage = Parameters.count?number>
	<#if (numArtsPerPage > 1000)>
		<#assign errorMessage = "Will only display a maximum of 1000 articles per page">
    <#assign numArtsPerPage = 1000>
	</#if>
<#else>
	<#assign numArtsPerPage = 50>
</#if>

<#assign numArts = news.size()>

<#-- COMPUTE VARIOUS INDICES INTO THE LIST -->
<#if Parameters.start?exists>
  <#assign startId = Parameters.start?number>
  <#if (startId < 1)>
    <#assign startId = 1>	
  <#elseif (startId > numArts)>
    <#assign startId = numArts>
  </#if>
<#else>
  <#assign startId = 1>
</#if>

<#assign rangeBegin = startId>
<#assign rangeEnd = startId + numArtsPerPage-1>
<#if (rangeEnd > numArts)> <#assign rangeEnd = numArts> </#if>
<#assign prevId = startId - numArtsPerPage>
<#assign nextId = startId + numArtsPerPage>
<#assign lastId = numArts - numArtsPerPage + 1>
<#if (prevId < 1)> <#assign prevId = 1> </#if>
<#if (lastId < 1)> <#assign lastId = 1> <#elseif (lastId < nextId)> <#assign lastId = nextId> </#if>

<#--######## BEGIN MACRO ############# -->
<#macro displayNavigationBar>
	<div class="newsnavbar">
		${rangeBegin} to ${rangeEnd} of ${numArts} &nbsp;&nbsp;&nbsp;
		<div class="navbar">
	<#if (startId > 1)>
		<a href="<@s.url namespace="/" action="browse-source" srcId="${source.tag}" d="${d}" m="${m}" y="${y}" />"> |&lt; First</a> &nbsp;
		<a href="<@s.url namespace="/" action="browse-source" srcId="${source.tag}" d="${d}" m="${m}" y="${y}" start="${prevId}" />"> &laquo; Previous</a>
	<#else>
		|&lt; First &nbsp; &laquo; Previous
	</#if>
		&nbsp;
	<#if (nextId <= numArts)>
		<a href="<@s.url namespace="/" action="browse-source" srcId="${source.tag}" d="${d}" m="${m}" y="${y}" start="${nextId}" />">Next &raquo;</a> &nbsp;
		<a href="<@s.url namespace="/" action="browse-source" srcId="${source.tag}" d="${d}" m="${m}" y="${y}" start="${lastId}" />">Last &gt;|</a>
	<#else>
    Next &raquo; &nbsp; Last &gt;|
	</#if>
    </div>
	</div>
</#macro>
<#--######## END MACRO ############# -->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<link rel="alternate" type="application/rss+xml" title="RSS feed for ${source.name}" href="${source.feed.url}" />
<title>News downloaded from source ${source.name}</title>
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
<!-- DISPLAY THE HEADER -->
		<div class="browsenewshdr">
			<span style="color:#777777">User:</span> ${userID} &nbsp;&nbsp;&nbsp;
			<span style="color:#777777">Source:</span> ${source.name} &nbsp;&nbsp;&nbsp;
			<span style="color:#777777">Date:</span> ${d}/${m}/${y}
			<a style="position: absolute; right:10px" class="rssfeed" href="${source.feed.url}">RSS 2.0</a>
		</div>
<#if numArts == 0>
  <p class="bold center"> No news in this source for this date! </p>
<#else>
  <#-- DISPLAY the navigation bar -->
	<#call displayNavigationBar>
    <#-- DISPLAY NEWS -->
		<table class="newsbysrc">
		<tr class="tblhdr">
			<td class="tblhdr"> Article </td>
			<td class="tblhdr"> Categories </td>
		</tr>
  <#assign startNewsId = startId-1>
  <#assign srcNews = news.listIterator(startNewsId)>
  <#foreach nc in 1..numArtsPerPage>
    <#if srcNews.hasNext()>
      <#assign ni = srcNews.next()>
        <#-- Display the news item - title, url -->
      <tr class="newsbysrc" style="width:100%">
			<td class="newstitle">
			<#assign url = ni.getURL()>
      <#if url == "">
        ${ni.getTitle()}
			<#else>
        <a target="_blank" class="originalArt" href="${url}">${ni.title}</a>
			</#if>
      <#if ni.displayCachedTextFlag>
        (<a target="_blank" class="filteredArt" href="<@s.url namespace="/news" action="display" ni="${ni.linkForCachedItem}" />">Cached</a>)
			</#if>
      </td>
        <#-- Display the categories it belongs to -->
      <#assign cats = ni.leafCategories>
			<#if (cats.size() > 1)>
      <td class="newscats center">
				<#foreach c in cats>
      [${c.user.uid} :: <a href="<@s.url namespace="/" action="browse" owner="${c.user.uid}" issue="${c.issue.name}" catID="${c.catId}" />">${c.name}</a>] &nbsp;
				</#foreach>
      </td>
			<#else>
      <td class="unclassified"> -- </td>
			</#if>
      </tr>
    </#if>
  </#foreach> <#-- (foreach) -->
  </table>
	<#call displayNavigationBar>
</#if> <#-- ($numArts == 0) -->
  </td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
