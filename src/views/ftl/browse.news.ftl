[#ftl]

[#-- Initialize various parameters --]

[#assign issueName = issue.name]
[#assign ownerID = owner.uid]
[#assign startId = start+1]
[#assign numArtsPerPage = count]
[#assign nextId = startId + numArtsPerPage]
[#assign prevId = startId-numArtsPerPage]
[#if prevId < 1]
    [#assign prevId = 1]
[/#if]

[#if Session?exists && Session.user?exists]
	[#assign user = Session.user]
[/#if]

[#-- Check if we are browsing news filtered by date or source .. in those situations, paging will be implemented differently! --]
[#if Parameters.start_date?exists || (Parameters.source_tag?exists && Parameters.source_tag != "")]
	[#assign filteredBySrcDate = true]
[#else]
	[#assign filteredBySrcDate = false]
  [#assign rangeBegin = startId]
  [#assign rangeEnd = startId + numArtsPerPage-1]
  [#if (rangeEnd>numArts)]
    [#assign rangeEnd = numArts]
  [/#if]
  [#assign lastId = numArts-numArtsPerPage + 1]
  [#if lastId < 1]
    [#assign lastId = 1]
  [#elseif lastId < nextId]
    [#assign lastId = nextId]
  [/#if]
[/#if]

[#-- Check if there is a currently signed in user and if so, if the user owns the issue being displayed --]
[#assign dispDelFlag = user?exists && user.uid.equals(ownerID)]

[#-- Check if user newstrust is signed in --]
[#assign addNTButton = user?exists && user.uid.equals("newstrust")]

[#--################################## --]
[#macro displayNavigationBar]
<div class="newsnavbar">
[#if dispDelFlag]
	<input type="submit" id="delArts" name="DEL" value="Delete">
[/#if]
[#if filteredBySrcDate]
	&nbsp;&nbsp;&nbsp; [#-- filler to ensure this navbar has some vertical space --]
  <div class="navbar">
  [#if Parameters.start_date?exists && Parameters.source_tag?exists]
    [#assign sd = Parameters.start_date]
    [#assign ed = Parameters.end_date]
    [#assign stag = Parameters.source_tag]
    [#if start < 1]
		|&lt; First &nbsp; &lt;&lt; Previous
    [#else]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${sd}" end_date="${ed}" source_tag="${stag}" /]"> |&lt; First</a> &nbsp;
    <a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${sd}" end_date="${ed}" source_tag="${stag}" start="${prevId?c}" /]"> &lt;&lt; Previous</a> &nbsp;
    [/#if]
    [#if news.size() < numArtsPerPage]
    Next &gt; &gt;
    [#else]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${sd}" end_date="${ed}" source_tag="${stag}" start="${nextId?c}" /]">Next &gt;&gt;</a>
    [/#if]
		&nbsp; Last &gt;|
  [#elseif Parameters.start_date?exists]
    [#assign sd = Parameters.start_date]
    [#assign ed = Parameters.end_date]
    [#if start < 1]
		|&lt; First &nbsp; &lt;&lt; Previous
    [#else]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${sd}" end_date="${ed}" /]"> |&lt; First</a> &nbsp;
    <a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${sd}" end_date="${ed}" start="${prevId?c}" /]"> &lt;&lt; Previous</a> &nbsp;
    [/#if]
    [#if news.size() < numArtsPerPage]
    Next &gt; &gt;
    [#else]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${sd}" end_date="${ed}" start="${nextId?c}" /]">Next &gt;&gt;</a>
    [/#if]
		&nbsp; Last &gt;|
  [#else]
    [#assign stag = Parameters.source_tag]
    [#if start < 1]
		|&lt; First &nbsp; &lt;&lt; Previous
    [#else]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" source_tag="${stag}" /]"> |&lt; First</a> &nbsp;
    <a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" source_tag="${stag}" start="${prevId?c}" /]"> &lt;&lt; Previous</a> &nbsp;
    [/#if]
    [#if news.size() < numArtsPerPage]
    Next &gt; &gt;
    [#else]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" source_tag="${stag}" start="${nextId?c}" /]">Next &gt;&gt;</a>
    [/#if]
		&nbsp; Last &gt;|
  [/#if] 
	</div>
[#else]
	${rangeBegin} to ${rangeEnd} of ${numArts} &nbsp;&nbsp;&nbsp;
   <div class="navbar">
   [#if (startId>1)]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" /]"> |&lt; First</a>
      &nbsp;
      <a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start="${prevId?c}" /]"> &lt;&lt; Previous</a>
   [#else]
		|&lt; First &nbsp; &lt;&lt; Previous
   [/#if]
	&nbsp;
   [#if nextId <= numArts]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start="${nextId?c}" /]">Next &gt;&gt;</a>
      &nbsp;
      <a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start="${lastId?c}" /]">Last &gt;|</a>
   [#else]
		Next &gt;&gt; &nbsp; Last &gt;|
   [/#if]
	</div>
[/#if]
</div>
[/#macro]

[#-- #################################### --]
[#-- Recursive macro to display ancestors --]
[#macro displayAncestors(ancestors)] 
[#foreach cat in ancestors]
<a class="browsecat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" /]">${cat.name}</a> ::
[/#foreach]
[/#macro]

[#-- ######### Now, we begin with the actual page display ######## --]
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="[@s.url value="/css/main.css" /]" type="text/css">
<link rel="alternate" type="application/rss+xml" title="[#if cat?exists] '${cat.name}' news in [/#if] '${issueName}' topic for user ${ownerID}" href="${cat.getRSSFeedURL()}" />
<title>[#if cat?exists] '${cat.name}' news in [/#if] '${issueName}' topic for user ${ownerID}</title>
<meta name="Description" content="This page displays news for [#if cat?exists] '${cat.name}' category in [/#if] '${issueName}' topic set up by user ${ownerID}.">
<style>
div#check_all_button { 
  width:58px;
  margin-left:5px;
  padding:2px 0;
  text-align:center;
  background:white;
  color:red;
  font-size:10px;
  font-weight:bold;
  border:1px solid black;
  cursor:pointer;
}
</style>
<script type="text/javascript">
[#if dispDelFlag]
var checked = false;
function toggleCheckBoxes(divObj)
{
  var boxes = document.getElementsByTagName('input');
  for (i = 0; i < boxes.length; i++) {
    var box = boxes[i];
    if (box.type == "checkbox") {
      box.checked = !checked; /* !box.checked; */
    }
  }

  if (!checked) {
    checked = true;
    divObj.innerHTML = "Uncheck All";
    divObj.style.width = "70px";
  }
  else {
    checked = false;
    divObj.innerHTML = "Check All";
    divObj.style.width = "58px";
  }
}
[/#if]

function updateUrl(sourceTag)
{
   [#-- replace any existing source tag + removed any existing start count + add new source tag --]
   newUrl = document.location.href.replace(/&source_tag=[^&]*/, '').replace(/&start=[^&]*/, '');
   if (sourceTag != "")
     newUrl += "&source_tag=" + sourceTag;
   document.location.href = newUrl;
}

function getObj(objId)  { return document.getElementById(objId); }
function hide(obj)      { obj.style.display = 'none'; }
function hideObj(objId) { hide(getObj(objId)); }
function show(obj, style) { obj.style.display = style; }

function init()
{
  hideObj('filter_submit');   // submit only for browsers with js turned off 
[#if Parameters.source_tag?exists]
  var source_tag = '${Parameters.source_tag}';
  var selobj = getObj('source_select');
  hide(selobj);
  var opts = selobj.options
  for (i = 0; i < opts.length; i++) {
     if (opts[i].value == source_tag) {
        selobj.selectedIndex = i
        break;
     }
  }
  show(selobj, 'inline');
[/#if]
}
</script>
</head>

<body onload="init()">

<div class="bodymain">
<table class="userhome" cellspacing="0">
[#include "/ftl/layout/header.ftl"]
<tr>
[#include "/ftl/layout/left.menu.ftl"]
<td class="user_news_space">
[#include "/ftl/layout/errors.ftl"]
[#include "/ftl/layout/messages.ftl"]
[#if dispDelFlag]
<form action="[@s.url namespace="/news" action="delete" /]" method="post">
<input type="hidden" name="issue" value="${issueName}">
	[#if Parameters.start?exists] <input type="hidden" name="start" value="${Parameters.start}"> [/#if]
	[#if Parameters.count?exists] <input type="hidden" name="count" value="${Parameters.count}"> [/#if]
	[#if cat?exists]
<input type="hidden" name="catID" value="${cat.catId}">
<input type="hidden" name="globalCatKey" value="${cat.key?c}">
	[/#if]
[/#if]
        [#-- DISPLAY THE HEADER --]
      <div class="browsenewshdr">
         User: <span class="impHdrElt">${ownerID}</span>
         Topic: <a class="browsecat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" /]">${issueName}</a>
			<div class="catpath"> Category: [#call displayAncestors(catAncestors)] <span class="impHdrElt">${cat.name}</span> </div>
			<div class="statusline">
[#assign numNew = cat.numItemsSinceLastDownload]
[#if (numNew>0) && cat.lastUpdateTime?exists && lastUpdateTime?exists && cat.lastUpdateTime.after(lastUpdateTime)]
			<span class="newartcount">${numNew} new</span> since ${lastDownloadTime}
[#else]
	[#if cat.lastUpdateTime?exists]
			<span style="color:#777777; font-weight:bold">Last updated</span>: ${cat.lastUpdateTime_String}
   [#else]
			0 new since ${lastDownloadTime}
   [/#if]
[/#if]
			<a class="rssfeed" href="${cat.getRSSFeedURL()}"><img src="/icons/rss-12x12.jpg" alt="RSS 2.0"></a>
         </div>
      </div>
      <div class="newsnavbar" style="margin:0;padding:5px;font-size:10px;">
         <form action="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" /]" method="post">
         Filter by source:
         <select id="source_select" name="source_tag" size="1" onchange="updateUrl(this.options[this.selectedIndex].value)">
         <option value="">All Sources</option>
         [#foreach s in issue.monitoredSources]
         <option value="${s.tag}">${s.name}</option>
         [/#foreach]
         </select>
         &nbsp;&nbsp;&nbsp; <input id="filter_submit" style="font-size:11px;font-weight:bold;" type="submit" name="Filter" value="Filter">
         </form>
      </div>
[#if numArts == 0]
		<p class="bold center"> No news yet in this category! </p>
[#else]
		<!-- DISPLAY the navigation bar -->
  [#call displayNavigationBar]
  [#if dispDelFlag]
  <div id="check_all_button" onclick="toggleCheckBoxes(this)">Check all</div>
  [/#if]
		<!-- DISPLAY NEWS -->
	[#assign newsIt = news.iterator()]
		<table class="news">
  [#foreach nc in 1..numArtsPerPage]
		[#if newsIt.hasNext()]
			[#assign ni = newsIt.next()]
			[#assign url = ni.getURL()]
			[#assign storyTitle = ni.title]
			[#assign srcName = ni.getSourceNameForUser(owner)]
			[#-- Display the news item  - title, date, source ### --]
		<tr class="newsbasic">
         <td class="newstitle">
      [#if !storyTitle?exists || storyTitle.length() == 0]
				[#assign storyTitle = "<span>ERROR: Missing Story Title</span>"]
			[/#if]
			[#if addNTButton]
<script type="text/javascript">
newstrust_publication_name = '${srcName?js_string}';
newstrust_story_url = '${url}';
newstrust_story_title = '${storyTitle?js_string}';
newstrust_story_subject = '${issueName}';
newstrust_story_topic = '${cat.name}';
newstrust_story_date = '${ni.date?string("yyyy-MM-dd")}';
</script>
<script src="http://www.newstrust.net/js/submit_story.js" type="text/javascript"></script>
         [/#if]
			[#if dispDelFlag]
				<input class="delbox" type="checkbox" name="key${nc}" value="${ni.key?c}">
			[/#if]
			[#if url == ""]
				${storyTitle}
			[#else]
				<a target="_blank" class="originalArt" href="${ni.getURL()}">${storyTitle}</a>
			[/#if]
			[#if ni.displayCachedTextFlag]
				(<a target="_blank" rel="nofollow" class="filteredArt" href="[@s.url namespace="/news" action="display" ni="${ni.linkForCachedItem}" /]">Cached</a>)
      [/#if]
			</td>
         <td class="newsdate">${ni.dateString}</td> 
         <td class="newssource">${srcName}</td>
      </tr>
[#-- Display the news item description ### --]
			[#if ni.description?exists]
		<tr class="newsdesc"> <td colspan="3"> ${ni.description} </td> </tr>
      [/#if]
			[#-- Display the other categories it belongs to ### --]
      [#assign cats = ni.categories]
      [#if cats.size() > 1]
		<tr class="newscats"> 
			<td colspan="3">
			<span class="normal underline">Also found in:</span>
        [#foreach c in cats]
          [#if !cat.key.equals(c.key)]
			[${c.user.uid} :: <a href="[@s.url namespace="/" action="browse" owner="${c.user.uid}" issue="${c.issue.name}" catID="${c.catId}" /]">${c.name}</a>] &nbsp;
          [/#if]
        [/#foreach]
			[/#if]
			</td>
    </tr>
    [/#if]
	[/#foreach]
		</table>
   [#call displayNavigationBar]
[/#if]    [#-- ($numArts == 0) --]
[#if dispDelFlag]
	</form>
[/#if]
</td>
</tr>
</table>
</div>

[#include "/ftl/layout/footer.ftl" parse="n"]
</body>
</html>
