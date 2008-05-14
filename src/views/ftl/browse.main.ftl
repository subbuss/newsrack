[#ftl]
[#-- Macro for displaying a list of issues in a 3-column format --]

[#macro displayIssues(issueList, issueCount, heading)]
[#assign count = 0]
[#assign c1 = 1 + issueCount/3]
[#assign c2 = 2*c1]
	<h1> ${issueCount} ${heading} </h1>
   <table style="width:100%" cellspacing="0">
      <tr><td style="vertical-align:top; width:33%; padding:2px 7px; line-height:17px">
[#foreach i in issueList]
	[#assign uid = i.user.uid]
	[#if count == c1?int || count == c2?int]
		</td>
		<td style="vertical-align:top; width:33%; padding:2px 7px; line-height:17px">
   [/#if]
			<a class="browsecat" href="[@s.url action="browse" owner="${uid}" issue="${i.name}" /]">${i.name}</a> (${uid}) <br />
   [#assign count = count + 1]
[/#foreach]
		</td></tr>
   </table>
[/#macro]

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="[@s.url value="/css/main.css" /]" type="text/css">
<title>Browse all news topics</title>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
[#include "/ftl/layout/header.ftl"]
<tr>
[#include "/ftl/layout/left.menu.ftl"]
<td class="user_news_space">
[#include "/ftl/layout/messages.ftl"]
[#include "/ftl/layout/errors.ftl"]
	<div class="ie_center_hack">
    <div class="issuelisting" style="margin:0px auto">
[#call displayIssues(mostRecentUpdates, mostRecentUpdates.size(), "issues updated since " + lastDownloadTime)] <br /><br />
[#call displayIssues(last24HourUpdates, last24HourUpdates.size(), "other issues updated within the last 24 hours")] <br /><br />
[#call displayIssues(oldestUpdates, oldestUpdates.size(), "other issues updated more than 24 hours back")]
		</div>
  </div>
</td>
</tr>
</table>
</div>

[#include "/ftl/layout/footer.ftl" parse="n"]
</body>
</html>
