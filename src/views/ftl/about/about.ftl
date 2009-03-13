<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title> About NewsRack </title>
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<style type="text/css">
p {
	margin     : 2px 8px 4px 8px;
	text-align : justify;
}
</style>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl"><tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
	<h1 class="left">About NewsRack</h1>

	<p>
	NewsRack is a tool/service for classifying, filing, and long-term archiving
	of news.  Users specify filtering rules which are used to select relevant
	articles from incoming news feeds.  The selected articles are then classified
	into various categories.  This process is similar to the process of specifying
	email filters to pre-sort incoming mail into various folders.
	</p>

	<p>
	Visit <a href="<@s.url namespace="/" action="selected-topics" />">
	a selection of news categories</a> from profiles of various users or else
	<a href="<@s.url namespace="/" action="browse" />">browse the entire public 
	archives</a> to see some examples of news classification into categories.
	</p>

	<br /><br />

	<h1 class="left">Motivation</h1>
	<p>
	Several organizations in the social development sector monitor news that
	is relevant to their work.  This is a time-consuming and laborious process
	for some groups, especially when the news is monitored, marked, cut, and
	filed using hard copies of newspapers and magazines.  The issue here is not
	so much that this is a manual process, as much as that organizations have
	a hard time keeping up.  This is very much the case in India.  However,
  using web versions of newspapers and magazines, news monitoring can be
	made easier.  In this context, the broad goal of this project is to aid
  the news monitoring for organizations and researchers.
	</p>
	<p>
	An auxilliary goal is to enable analysis of media coverage, a task that,
	increasingly seems to be one of the strengths of NewsRack.  It is already
	possible, by defining appropriate filtering rules and topics, and to track
	how media covers a particular issue, and what slants are given more
	coverage over others.
	</p>

	<br /> <br />

	<h3 class="s16 left"> Conceptual Model: </h3>
	<p>
	The image below shows the conceptual design of NewsRack.  Stripped to the bone,
	NewsRack takes input news feeds and generates a set of categorized news feeds
	based on filtering rules that you specify.  You could use these output news
	feeds in your favourite news aggregator, or you can let NewsRack organize
	this information for you into categories letting you and others browse through
	them.
	</p>

	<div style="text-align: center; ">
	<img src="<@s.url value="/icons/newsrack.conceptual.png" />" alt="NewsRack Conceptual Diagram">
	</div>

	<br /> <br />

	<h3 class="s16 left"> Known limitations: </h3>
	<ul>
	<li>Currently, NewsRack can only process news from news sources that
	provide RSS feeds.  For sites without RSS feeds, work is ongoing to
	provide support via site-specific crawlers.  For now, there is a
	functioning crawler for
	<a href="<@s.url namespace="/extras" action="crawled-feeds" />"> several
	papers</a> (even though they
	do not provide RSS feeds).  But, there is no generic solution for other
	sites yet.  This mean that news from such newspapers cannot be monitored
	at this time till such time they provide RSS feeds or till a crawler
	becomes available.
	</li>
	<li>
	Creating profiles is not straightforward.  Users are expected to write
	rules to tell NewsRack what to do.  Work is in progress to make this 
	more user-friendly.
	</li>
	</ul>
	</td>
</tr>
</table>
</div>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
