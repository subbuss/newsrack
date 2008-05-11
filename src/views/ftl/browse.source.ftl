<#--################################## -->
<#macro dispNavBar>
	<div class="newsnavbar">
		${rangeBegin} to ${rangeEnd} of ${numArts} &nbsp;&nbsp;&nbsp;
		<div class="navbar">
		<#if (startId>1)>
		<a href="<@s.url namespace="/" action="browse" source="src.getID() d="d" m="m" y="y" />"> |&lt; First</a>
		&nbsp;
		<a href="<@s.url namespace="/" action="browse" source="src.getID() d="d" m="m" y="y" start="prevId" />"> &lt;&lt; Previous</a>
		<#else>
		|&lt; First &nbsp; &lt;&lt; Previous
		</#if>
		&nbsp;
		<#if nextId <= numArts>
		<a href="<@s.url namespace="/" action="browse" source="src.getID() d="d" m="m" y="y" start="nextId" />">Next &gt;&gt;</a>
		&nbsp;
		<a href="<@s.url namespace="/" action="browse" source="src.getID() d="d" m="m" y="y" start="lastId" />">Last &gt;|</a>
		<#else>		Next &gt;&gt;
		&nbsp;
		Last &gt;|
		</#if>		</div>
	</div>
</#macro>
<#--################################## -->
<#assign userID = user.getUid()>
<#if count>
	<#assign numArtsPerPage = count.intValue()>
	<#if (numArtsPerPage>1000)>
		<#assign errorMessage = "Will only display a maximum of 1000 articles per page"><#assign numArtsPerPage = 1000>
	</#if>
<#else>
	<#assign numArtsPerPage = 50>
</#if>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<link rel="alternate" type="application/rss+xml" title="RSS feed for ${src.getName()}" href="${src.getFeed()}" />
<title>News downloaded from source ${src.getName()}</title>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/user.header.ftl"><tr>
<#include "/ftl/left.menu.ftl">	<td class="user_news_space">
<#include "/ftl/errors.ftl"><#include "/ftl/messages.ftl"><#if errorMessage>	<p style="font-size: 14px; text-align:center; color:red">${errorMessage}</p>
</#if>		<!-- DISPLAY THE HEADER -->
		<div class="browsenewshdr">
			<span style="color:#777777">User:</span> ${userID} &nbsp;&nbsp;&nbsp;
			<span style="color:#777777">Source:</span> ${src.getName()} &nbsp;&nbsp;&nbsp;
			<span style="color:#777777">Date:</span> ${d}/${m}/${y}
			<a style="position: absolute; right:10px" class="rssfeed" href="${src.getFeed()}">RSS 2.0</a>
		</div>

		<!-- NOW, NEWS or CATS -->
<#assign numArts = news.size()>
	<#-- COMPUTE VARIOUS INDICES INTO THE LIST
--><#if start><#assign startId = start.intValue()>	<#if startId < 1><#assign startId = 1>	<#elseif (startId>numArts)><#assign startId = numArts>	</#if><#else><#assign startId = 1></#if>
<#assign rangeBegin = startId><#assign rangeEnd = startId + numArtsPerPage-1><#if (rangeEnd>numArts)><#assign rangeEnd = numArts></#if><#assign prevId = startId-numArtsPerPage><#assign nextId = startId + numArtsPerPage><#assign lastId = numArts-numArtsPerPage + 1>
<#if prevId < 1><#assign prevId = 1></#if><#if lastId < 1><#assign lastId = 1><#elseif lastId < nextId><#assign lastId = nextId></#if>
<#if numArts == 0>	<p class="bold center"> No news in this source for this date! </p>
<#else><!-- DISPLAY the navigation bar -->
	<#call dispNavBar>
<!-- DISPLAY NEWS -->
		<table class="newsbysrc">
		<tr class="tblhdr">
			<td class="tblhdr"> Article </td>
			<td class="tblhdr"> Categories </td>
		</tr>
<#--
--><#assign startNewsId = startId-1><#assign srcNews = news.listIterator(startNewsId)>	<#foreach nc in 1..numArtsPerPage>		<#if srcNews.hasNext()><#assign ni = srcNews.next()><#--# Display the news item - title, url ###
-->		<tr class="newsbysrc" style="width:100%">
			<td class="newstitle">
			<#assign url = ni.getURL()>			<#if url == "">			${ni.getTitle()}
			<#else>			<a target="_blank" class="originalArt" href="${ni.getURL()}">${ni.getTitle()}</a>
			</#if>         <#if ni.getDisplayCachedTextFlag()>			(<a target="_blank" class="filteredArt" href="${vsLink.setAction("DisplayNewsItem").addQueryData("ni", ni.getLocalCopyPath())}">Cached</a>)
			</#if>			</td>
<#--# Display the categories it belongs to ### -->
			<#if (ni.getNumCats()>0)><#assign cats = ni.getCategories()>			<td class="newscats center">
				<#foreach nc in cats><#assign ncCat = nc><#assign ncUid = ncCat.getUser().getUid()><#assign ncIssue = ncCat.getIssue().getName()><#assign ncCatID = ncCat.getCatId()><#assign ncCatName = ncCat.getName()>			[${ncUid} :: <a href="<@s.url namespace="/" action="browse" owner="ncUid" issue="ncIssue" catID="ncCatID" />">${ncCatName}</a>] &nbsp;
				</#foreach>			</td>
			<#else>			<td class="unclassified"> -- </td>
			</#if>		</tr>
<#--# Display the news item description ###
--><#--			#if ($ni.getDescription())
--><#--		<tr class="newsdesc">
--><#--			<td colspan="2"> $ni.getDescription() </td>
--><#--		</tr>
--><#--			#end
-->		</#if>	</#foreach> <#--# (foreach)
-->		</table>
	<#call dispNavBar></#if>    <#--# ($numArts == 0)
-->	</td>
</tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
