[#ftl]

[#-- Initialize various parameters --]

[#assign issueName = issue.name]
[#assign ownerID = owner.uid]
[#assign startId = start+1]
[#assign numArtsPerPage = count]
[#assign nextId = startId + numArtsPerPage]
[#assign prevId = startId - numArtsPerPage]
[#if prevId < 1]
  [#assign prevId = 1]
[/#if]

[#if Session?exists && Session.user?exists]
  [#assign user = Session.user]
[/#if]

[#-- Check if we are browsing news filtered by date or source .. in those situations, paging will be implemented differently! --]
[#if Parameters.start_date?exists || (Parameters.source_tag?exists && Parameters.source_tag != "") || cat.leafCategory == false]
  [#assign unknownNewsCount = true]
[#else]
  [#assign unknownNewsCount = false]
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
[#if unknownNewsCount]
	&nbsp;&nbsp;&nbsp; [#-- filler to ensure this navbar has some vertical space --]
   <div class="navbar">
  [#if Parameters.start_date?exists && Parameters.source_tag?exists]
    [@s.url id="base_url" namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${Parameters.start_date}" end_date="${Parameters.end_date}" source_tag="${Parameters.source_tag}" /]
  [#elseif Parameters.start_date?exists]
    [@s.url id="base_url" namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" start_date="${Parameters.start_date}" end_date="${Parameters.end_date}" /]
  [#elseif Parameters.source_tag?exists]
    [@s.url id="base_url" namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" source_tag="${Parameters.source_tag}" /]
  [#elseif cat.leafCategory == false ]
    [@s.url id="base_url" namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" show_news="true" /]
  [/#if] 
  [#if start < 1]
   |&lt; First &nbsp; &lt;&lt; Previous
  [#else]
   <a href="${base_url}"> |&lt; First</a> &nbsp; <a href="${base_url}&start=${prevId?c}"> &lt;&lt; Previous</a> &nbsp;
  [/#if]
  [#if news.size() < numArtsPerPage]
   Next &gt; &gt;
  [#else]
   <a href="${base_url}&start=${nextId?c}">Next &gt;&gt;</a>
  [/#if]
   &nbsp; Last &gt;|
   </div>
[#else]
	${rangeBegin} to ${rangeEnd} of ${numArts} &nbsp;&nbsp;&nbsp;
   <div class="navbar">
   [@s.url id="base_url" namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" /]
   [#if (startId>1)]
		<a href="${base_url}"> |&lt; First</a> &nbsp; <a href="${base_url}&start=${prevId?c}"> &lt;&lt; Previous</a>
   [#else]
		|&lt; First &nbsp; &lt;&lt; Previous
   [/#if]
	&nbsp;
   [#if nextId <= numArts]
		<a href="${base_url}&start=${nextId?c}">Next &gt;&gt;</a> &nbsp; <a href="${base_url}&start=${lastId?c}">Last &gt;|</a>
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
div.newsnavbar form            { border: 1px dotted #ccc; padding:5px; font-size: 10px; }
div.newsnavbar form select     { width: 150px; border: 1px solid black; height:18px; }
div.newsnavbar form input.date { width: 150px; height:18px; margin:0; color: black; font-weight: normal; padding:0; }
div.newsnavbar form div.filter { float: left; margin: 0 12px 0 0; }
div.newsnavbar form label      { display: block; font-weight: bold; font-size: 11px; margin-bottom: 5px; }
div.newsnavbar form input#filter_submit { font-size:13px;font-weight:bold; padding:1px 5px; margin: 15px 0 0 10px; }
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

function getObj(objId)  { return document.getElementById(objId); }
function getSelectedValue(selId)
{
	var selObj = getObj(selId);
	return (selObj.disabled) ? "" : selObj.options[selObj.selectedIndex].value;
}
function updateUrl()
{
   [#-- replace any existing source tag + removed any existing start count + add new source tag --]
  var newUrl     = document.location.href.replace(/&source_tag=[^&]*/, '').replace(/&start=[^&]*/, '').replace(/&start_date=[^&]*/, '').replace(/&end_date=[^&]*/, '');
  var source_tag = getSelectedValue('source_select');
  var start_date = getObj('start_date_box').value
  var end_date   = getObj('end_date_box').value
  if (source_tag != "")
    newUrl += "&source_tag=" + source_tag;
  if (start_date != "")
    newUrl += "&start_date=" + start_date;
  if (end_date != "")
    newUrl += "&end_date=" + end_date;

  document.location.href = newUrl;
  return false;
}

function hide(obj)      { obj.style.display = 'none'; }
function hideObj(objId) { hide(getObj(objId)); }
function show(obj, style) { obj.style.display = style; }
</script>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
[#include "/ftl/layout/header.ftl"]
<tr>
[#include "/ftl/layout/left.menu.ftl"]
<td class="user_news_space">
[#include "/ftl/layout/errors.ftl"]
[#include "/ftl/layout/messages.ftl"]
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
[#-- Display the news filtering form --]
      <div class="newsnavbar" style="margin:0;padding:5px;font-size:10px;">
      <form action="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" /]" method="post" onsubmit="return updateUrl()">
        <div class="filter">
          <label>Source:</label>
          <select id="source_select" name="source_tag" size="1">
          <option value="">All Sources</option>
[#foreach s in issue.monitoredSources]
          <option [#if Parameters.source_tag?exists && (s.tag == Parameters.source_tag)]selected[/#if] value="${s.tag}">${s.name}</option>
[/#foreach]
          </select>
        </div>
        <div class="filter">
          [#if Parameters.start_date?exists] [#assign sd = Parameters.start_date] [#else] [#assign sd = ""] [/#if]
          <label>Start date (yyyy.mm.dd):</label>
          <input class="date" id="start_date_box" type="text" name="start_date" value="${sd}">
        </div>
        <div class="filter">
          [#if Parameters.end_date?exists] [#assign ed = Parameters.end_date] [#else] [#assign ed = ""] [/#if]
          <label>End date (yyyy.mm.dd):</label>
          <input class="date" id="end_date_box" type="text" name="end_date" value="${ed}">
        </div>
        <div class="filter">
          <input id="filter_submit" type="submit" name="filter" value="Filter">
        </div>
        <div style="clear:both;">&nbsp;</div>
      </form>
      </div>

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

[#if cat.leafCategory && numArts == 0]
		<p class="bold center"> No news yet in this category! </p>
[#else]
[#-- DISPLAY the navigation bar --]
  [#call displayNavigationBar]
  [#if dispDelFlag]
  <div id="check_all_button" onclick="toggleCheckBoxes(this)">Check all</div>
  [/#if]
[#-- DISPLAY NEWS --]
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
      [#if cats.size() > 1 || (cat.leafCategory == false)]
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
