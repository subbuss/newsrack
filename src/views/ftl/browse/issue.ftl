[#ftl]
[#assign issueName = issue.name]
[#assign ownerID   = owner.uid]
[#assign cats      = issue.categories]
[#assign selfBrowse = user?exists && user.uid.equals(ownerID)]

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="[@s.url value="/css/main.css" /]" type="text/css">
<link rel="alternate" type="application/rss+xml" title="'${issueName}' news for user ${ownerID}" href="${issue.getRSSFeedURL()}" />
<title>'${issueName}' news for user ${ownerID}</title>
<meta name="Description" content="This page set up by user ${ownerID} has the following news categories in '${issueName}' topic: [#foreach cat in cats] ${cat.name}; [/#foreach]">
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
			<br /><br />
			<div class="statusline">
[#assign numNew = issue.numItemsSinceLastDownload]
[#if (numNew>0) && issue.lastUpdateTime?exists && lastUpdateTime?exists && issue.lastUpdateTime.after(lastUpdateTime)]
			<span class="newartcount">${numNew} new</span> since ${lastDownloadTime}
[#else]
	[#if issue.lastUpdateTime?exists]
			<span style="color:#777777; font-weight:bold">Last updated</span>: ${issue.lastUpdateTime_String}
   [#else]
			0 new since ${lastDownloadTime}
   [/#if]
[/#if]
			<a class="rssfeed" href="${issue.getRSSFeedURL()}"><img src="/icons/rss-12x12.jpg" alt="RSS 2.0"></a>
         </div>
      </div>
		
		<!-- DISPLAY CATEGORIES IN CURRENT CATEGORY -->
      <div class="catlisting ie_center_hack">
      <table cellspacing="0" class="catlisting">
      <tr class="tblhdr">
        <td colspan="2">Category</td>
        <td>RSS</td>
        <td>Time of <br>last update</td>
      </tr>
[#foreach cat in cats]
			<tr>
        <td style="border:none;text-align:right;">
  [#if cat.isLeafCategory()]
				<a class="browseleafcat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" /]">${cat.name}</a>
  [#else]
				<a class="browsecat" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" /]">${cat.name} [+]</a>
  [/#if]
				</td>
        <td style="border:none;text-align:right;padding-right:15px;">
  [#if cat.isLeafCategory()]
        <span class="artcount">[${cat.numArticles}]</span>
  [#else]
    [#if selfBrowse]
				<a class="browseleafcat" style="font-weight:bold;font-size:11px" href="[@s.url namespace="/" action="browse" owner="${ownerID}" issue="${issueName}" catID="${cat.catId}" show_news="true" /]">News &raquo;</a>
    [#else]
        ---
    [/#if]
  [/#if]
        <td style="border-right:none;text-align:center">
        <a class="rssfeed" href="${cat.getRSSFeedURL()}"><img src="/icons/rss-12x12.jpg" alt="RSS 2.0"></a>
        </td>
        <td class="center"> ${cat.lastUpdateTime_String} </td>
      </tr>
[/#foreach]
		  </table>
    </div>
[#if selfBrowse]
<div style="margin:20px 10px">
<ul>
<li> Categories <span class="bold browseleafcat">in this color</span> are leaf categories. </li>
<li> Categories <span class="bold browsecat">in this color</span> are non-leaf categories with nested news categories.
<ul>
<li> Clicking on the <span class="bold browsecat">[+]</span> sign will let you navigate the taxonomy.</li>
<li> 
Clicking on the <span class="bold browseleafcat">News &raquo;</span> will show you combined news from all nested categories.
<strong> In this non-leaf category view, if you delete a news item, it will be deleted from ALL nested categories it is present in.</strong>
</li>
</ul>
</li>
</ul>
</div>
[/#if]
</td>
</tr>
</table>
</div>

[#include "/ftl/layout/footer.ftl" parse="n"]
</body>
</html>
