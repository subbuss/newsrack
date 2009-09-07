<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Extras: RSS feeds for newspapers</title>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl"><tr>
<#include "/ftl/layout/left.menu.ftl">	<td class="user_space">
	<h1 class="underline"> Extras: RSS feeds for newspapers and magazines </h1>
	<p>
	In an attempt to support newspapers and magazines without RSS feeds, NewsRack
   works with site-specific crawlers to generate RSS feeds for a select few newspapers
   and magazines.  These Newsrack-generated RSS feeds are then used by NewsRack
   to monitor those papers.  Since these feeds are perhaps useful more widely,
   they are being provided on this page.  As more crawlers are developed, this page
	will be updated.
	</p>

	<ul>
	<li> <a href="<@s.url value="/crawled.feeds/cc.rss.xml" />">Central Chronicle</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/ct.rss.xml" />">Chandigarh Tribune</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/at.rss.xml" />">Assam Tribune</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/ko.rss.xml" />">Kangla Online</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/epao.rss.xml" />">Manipur E-Pao</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/som.rss.xml" />">Star of Mysore</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/bs.rss.xml" />">Business Standard</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/oh.rss.xml" />">OHeraldo (Goa)</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/pioneer.rss.xml" />">The Pioneer</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/nie.rss.xml" />">New Indian Express</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/fe.rss.xml" />">Financial Express</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/statesman.rss.xml" />">The Statesman</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/telegraph.ne.rss.xml" />">The Telegraph - North East</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/goi.pib.rss.xml" />">Government of India Press Information Bureau Releases</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/pm.rss.xml" />">Projects Monitor </a> </li>
<!-- <li> <a href="<@s.url value="/crawled.feeds/iln.rss.xml" />">Ind Law News </a> </li> -->
	<li> <a href="<@s.url value="/crawled.feeds/frontline.rss.xml" />">Frontline</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/outlook.rss.xml" />">Outlook</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/nbt.rss.xml" />">नवभारत टैम्स (Navbharat Times) </a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/dj.rss.xml" />"> दैनिक जागरण (Dainik Jagran)</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/hd.rss.xml" />"> हिन्दुस्तान दैनिक (Hindustan Dainik)</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/db.rss.xml" />"> दैनिक भास्कर (Dainik Bhaskar)</a> </li>
	<li> <a href="<@s.url value="/crawled.feeds/kp.rss.xml" />"> ಕನ್ನಡ  ಪ್ರಭ (Kannada Prabha) </a> </li>
	</ul>

	<p>
	NOTE: Feeds for Pioneer, New Indian Express, Business Standard, do not cover the entire site 
	content -- only a subsection of the paper that is of interest to NewsRack.
	</p>

	</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
