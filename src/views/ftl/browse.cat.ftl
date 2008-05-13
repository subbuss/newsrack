[#ftl]
[#assign cat = stack.findValue("cat")]
[#assign issueName = stack.findValue("issue.name")]
[#assign ownerID = stack.findValue("owner.uid")]
[#assign ancestors = stack.findValue("catAncestors")]

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
<title>News archived in the ${cat.getName()} category in the ${issueName} topic for user ${ownerID}</title>
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
	<!-- DISPLAY THE HEADER -->
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

[#assign cats = cat.getChildren()]
		
		<!-- DISPLAY CATEGORIES IN CURRENT CATEGORY -->
      <div class="catlisting ie_center_hack">
      <table cellspacing="0" class="catlisting">
         <tr class="tblhdr">
            <td colspan="2" style="width:50%">Category</td>
            <td style="width: 125px">New since <br>${lastDownloadTime}</td>
            <td>Time of <br>last update</td>
         </tr>
[#foreach cat in cats]
			<tr>
            <td style="border-right: 0px; text-align:right;">
   [#if cat.isLeafCategory()]
				<a class="browseleafcat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.getCatId()}" /]">${cat.getName()}</a>
   [#else]
				<a class="browsecat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.getCatId()}" /]">${cat.getName()} [+]</a>
   [/#if]
				</td>
            <td style="border-left: 0px; text-align:right">
            <span class="artcount">[${cat.getNumArticles()}]</span>
            <a class="rssfeed" href="${cat.getRSSFeedURL()}"><img src="/icons/rss-12x12.jpg" alt="RSS 2.0"></a>
            </td>
            <td class="center">
   [#assign numNew = cat.getNumItemsSinceLastDownload()] 
	[#if (numNew>0)]
				(<span class="newartcount">${numNew} new</span>) &nbsp;
   [#else]
				(None) &nbsp;
   [/#if]
				</td>
            <td class="center"> ${cat.getLastUpdateTime_String()} </td>
         </tr>
[/#foreach]
		</table>
      </div>
</td>
</tr>
</table>
</div>

[#include "/ftl/layout/footer.ftl" parse="n"]
</body>
</html>
