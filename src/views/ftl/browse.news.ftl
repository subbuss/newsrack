[#ftl]
[#assign cat = stack.findValue("cat")]
[#assign issueName = stack.findValue("issue.name")]
[#assign ownerID = stack.findValue("owner.uid")]
[#assign ancestors = stack.findValue("catAncestors")]

[#if Parameters.count?exists]
	[#assign numArtsPerPage = Parameters.count?number]
	[#if (numArtsPerPage>200)]
		[#assign errorMessage = "Will only display a maximum of 200 articles per page"]
		[#assign numArtsPerPage = 200]
	[#elseif numArtsPerPage < 5]
		[#assign numArtsPerPage = 5]
	[/#if]
[#else]
	[#assign numArtsPerPage = 20]
[/#if]

[#if Parameters.start?exists]
	[#assign start = Parameters.start]
[/#if]

[#if Session?exists && Session.user?exists]
	[#assign user = Session.user]
[/#if]

[#-- Check if there is a currently signed in user and if so, if the user owns the issue being displayed --]
[#assign dispDelFlag = user?exists && user.getUid().equals(ownerID)]

[#-- Check if user newstrust is signed in --]
[#assign addNTButton = user?exists && user.getUid().equals("newstrust")]

[#--################################## --]
[#macro displayNavigationBar]
<div class="newsnavbar">
[#if dispDelFlag]
	<input type="submit" id="delArts" name="DEL" value="Delete">
[/#if]
	${rangeBegin} to ${rangeEnd} of ${numArts} &nbsp;&nbsp;&nbsp;
   <div class="navbar">
   [#if (startId>1)]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.getCatId()}" /]"> |&lt; First</a>
      &nbsp;
      <a href="[@s.url namespace="/" action="browse" owner="ownerID" issue="${issueName}" catID="${cat.getCatId()}" start="${prevId}" /]"> &lt;&lt; Previous</a>
   [#else]
		|&lt; First &nbsp; &lt;&lt; Previous
   [/#if]
	&nbsp;
   [#if nextId <= numArts]
		<a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.getCatId()}" start="${nextId}" /]">Next &gt;&gt;</a>
      &nbsp;
      <a href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.getCatId()}" start="${lastId}" /]">Last &gt;|</a>
   [#else]
		Next &gt;&gt; &nbsp; Last &gt;|
   [/#if]
	</div>
</div>
[/#macro]

[#-- #################################### --]
[#-- Recursive macro to display ancestors --]
[#macro displayAncestors(ancestors)] 
[#foreach cat in ancestors]
<a class="browsecat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.getCatId()}" /]">${cat.getName()}</a> ::
[/#foreach]
[/#macro]

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="[@s.url value="/css/main.css" /]" type="text/css">
<link rel="alternate" type="application/rss+xml" title="RSS feed for ${cat.getName()}" href="${cat.getRSSFeedURL()}" />
<title>News archived in the [#if cat?exists] ${cat.getName()} category in the [/#if] ${issueName} topic for user ${ownerID}</title>
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
[#if dispDelFlag]
<form action="[@s.url namespace="/news" action="delete" /]" method="post">
<input type="hidden" name="issue" value="${issueName}">
	[#if Parameters.start?exists] <input type="hidden" name="start" value="${Parameters.start}"> [/#if]
	[#if Parameters.count?exists] <input type="hidden" name="count" value="${Parameters.count}"> [/#if]
	[#if cat?exists]
<input type="hidden" name="catID" value="${cat.getCatId()}">
<input type="hidden" name="globalCatKey" value="${cat.getKey()}">
	[/#if]
[/#if]
        [#-- DISPLAY THE HEADER --]
      <div class="browsenewshdr">
         User: <span class="impHdrElt">${ownerID}</span>
         Topic: <a class="browsecat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" /]">${issueName}</a>
			<div class="catpath"> Category: [#call displayAncestors(ancestors)] <span class="impHdrElt">${cat.getName()}</span> </div>
			<div class="statusline">
[#assign numNew = cat.getNumItemsSinceLastDownload()]
[#if (numNew>0)]
			<span class="newartcount">${numNew} new</span> since ${lastDownloadTime}
[#else]
	[#if cat.getLastUpdateTime()?exists]
			<span style="color:#777777; font-weight:bold">Last updated</span>: ${cat.getLastUpdateTime_String()}
   [#else]
			0 new since ${lastDownloadTime}
   [/#if]
[/#if]
			<a class="rssfeed" href="${cat.getRSSFeedURL()}"><img src="/icons/rss-12x12.jpg" alt="RSS 2.0"></a>
         </div>
      </div>

  [#-- COMPUTE VARIOUS INDICES INTO THE LIST --]
[#assign numArts = cat.getNumArticles()]
[#if start?exists]
	[#assign startId = start?number]
	[#if startId < 1]
		[#assign startId = 1]
	[#elseif (startId>numArts)]
		[#assign startId = numArts]
	[/#if]
[#else]
	[#assign startId = 1]
[/#if]
[#assign rangeBegin = startId]
[#assign rangeEnd = startId + numArtsPerPage-1]
[#if (rangeEnd>numArts)]
	[#assign rangeEnd = numArts]
[/#if]
[#assign prevId = startId-numArtsPerPage]
[#assign nextId = startId + numArtsPerPage]
[#assign lastId = numArts-numArtsPerPage + 1]
[#if prevId < 1]
	[#assign prevId = 1]
[/#if]
[#if lastId < 1]
	[#assign lastId = 1]
[#elseif lastId < nextId]
	[#assign lastId = nextId]
[/#if>
[#if numArts == 0]
		<p class="bold center"> No news yet in this category! </p>
[#else]
		<!-- DISPLAY the navigation bar -->
  [#call displayNavigationBar]
  [#if dispDelFlag]
  <div id="check_all_button" onclick="toggleCheckBoxes(this)">Check all</div>
  [/#if]
		<!-- DISPLAY NEWS -->
  [#assign startNewsId = startId-1]
	[#assign news = cat.getNews(startNewsId, numArtsPerPage)]
		<table class="news">
  [#foreach nc in 1..numArtsPerPage]
		[#if news.hasNext()]
			[#assign ni = news.next()]
			[#assign url = ni.getURL()]
			[#assign storyTitle = ni.getTitle()]
			[#assign srcName = ni.getSourceNameForUser(owner)]
			[#-- Display the news item  - title, date, source ### --]
		<tr class="newsbasic">
         <td class="newstitle">
      [#if !storyTitle?exists || storyTitle.length() == 0]
				[#assign storyTitle = "<span>ERROR: Missing Story Title</span>"]
			[/#if]
			[#if addNTButton]
<script type="text/javascript">
newstrust_publication_name = '${vsEsc.javascript(srcName)}';
newstrust_story_url = '${url}';
newstrust_story_title = '${vsEsc.javascript(storyTitle)}';
newstrust_story_subject = '${issueName}';
newstrust_story_topic = '${cat.getName()}';
newstrust_story_date = '${vsDate.format("yyyy-MM-dd", ni.getDate())}';
</script>
<script src="http://www.newstrust.net/js/submit_story.js" type="text/javascript"></script>
         [/#if]
			[#if dispDelFlag]
				<input class="delbox" type="checkbox" name="key${nc}" value="${ni.getKey()}">
			[/#if]
			[#if url == ""]
				${storyTitle}
			[#else]
				<a target="_blank" class="originalArt" href="${ni.getURL()}">${storyTitle}</a>
			[/#if]
			[#if ni.getDisplayCachedTextFlag()]
				(<a target="_blank" rel="nofollow" class="filteredArt" href="[@s.url namespace="/news" action="display" ni="${ni.getLocalCopyPath()}" /]">Cached</a>)
      [/#if]
			</td>
         <td class="newsdate">${ni.getDateString()}</td> 
         <td class="newssource">${srcName}</td>
      </tr>
[#-- Display the news item description ### --]
			[#if ni.getDescription()?exists]
		<tr class="newsdesc"> <td colspan="3"> ${ni.getDescription()} </td> </tr>
      [/#if]
			[#-- Display the other categories it belongs to ### --]
      [#assign cats = ni.getCategories()]
      [#if cats.size() > 1]
		<tr class="newscats"> 
			<td colspan="3">
			<span class="normal underline">Also found in:</span>
        [#foreach c in cats]
			[${c.user.uid} :: <a href="[@s.url namespace="/" action="browse" owner="${c.user.uid}" issue="${c.issue.name}" catID="${c.catId}" /]">${c.name}</a>] &nbsp;
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
