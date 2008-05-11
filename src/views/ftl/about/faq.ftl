<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title> FAQ </title>
<style>

h1 { font-size: 18px; text-decoration: none }
h2 { font-size: 16px; text-decoration: underline; text-align: left }
h3 { font-size: 14px; text-decoration: underline; text-align: left }
h4 { font-size: 13px; text-decoration: underline; text-align: left }

div.question {
	font-size       : 13px;
	color           : #224488;
	font-weight     : bold;
	margin-top      : 5px;
	padding         : 5px 0px;
	text-decoration : underline;
}

div.answer {
	font-size   : 12px;
	text-align  : justify;
	margin-bottom : 5px;
	padding     : 0px 0px 5px 30px;
}

ol, ol a {
	font-size   : 13px;
	color       : #224488;
	font-weight : bold;
}

span.rsslabel {
	padding         : 0px 2px;
	color           : white;
	background-color: brown; 
	font-weight     : bold;
}

div.nrcode {
	font-family: monospace;
   background-color: #ddeeff;
   border : 1px solid #0088ff;
   padding : 10px;
   margin : 5px 0px 5px 10px;
}

</style>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/user.header.ftl"><tr>
<#include "/ftl/left.menu.ftl">	<td class="user_space">

	<h1>NewsRack FAQ</h1>

	<ol>
	<li> <a href="#q1"> How is this different from Google News and Google News Alerts? </a> </li>
	<li> <a href="#q2"> Why have a separate entity called concepts?  Why not specify keywords in filtering rules directly?</a> </li>
	<li> <a href="#q3"> What is a RSS feed? </a> </li>
	<li> <a href="#q4"> How do I know if a newspaper provides a RSS feed? </a> </li>
	</ol>
	<hr noshade="noshade" />

	<a name="q1"></a>
	<div class="question">
	Q. How is this different from Google News and Google News Alerts?
	</div>
	<div class="answer">
	<p>
	If the news that you are trying to monitor is fairly straightforward
	(for example all tsunami-related news items), then you could use
	Google News Alerts to receive daily alerts.  But, you are still left with
	the task of filing these away, and if necessary, organizing the news. 
	</p>
	<p>
	However, if you are interested in monitoring tsunami-news and also organizing
	them into various categories (india, sri-lanka, tamil nadu, thailand, warning
	systems, etc.) it is harder to do this with Google News.  You would have to do
	this either manually or write a script to process Google News alerts.
	</p>
	<p>
	Or, consider the case where different newspapers refer to Nagapattinam as Nagapatnam,
	Nagapattinam, Nagappatinam, ... If you had to capture all the spelling variations,
	things get messy soon.  However, with NewsRack, you can put away all the different
	variations into a <b>concept</b> called "nagapattinam" and you are set.  If you discover
	a new spelling variation, simple add the new keyword to the <b>concept</b> and NewsRack
	will catch those news items too.
	</p>
	<p>
	One way to understand this is also to look at NewsRack filtering rules as pre-defined
	google news searches, but, far more complex ones at that.  In addition, NewsRack
   also lets you classify news into different categories.
	</p>
	</div>

	<a name="q2"></a>
	<div class="question">
	Q. Why have a separate entity like concepts?  Why not specify keywords in 
	the filtering rules directly?
	</div>
	<div class="answer">
	<p>
	Concepts make sense for several reasons.
	<ul>
   <li> 
   <span class="underline">They capture ideas in a way that keywords do not</span>.
   For example, consider the following three concepts:
   <div class="nrcode">
   1. &lt;oil-exploration&gt; = oil exploration, offshore oil, oil-field, oil hunt, oil find, oil rig, oil production <br />
   2. &lt;narmada&gt; = narmada, sardar sarovar, maheshwar, omkareshwar  <br />
   3. &lt;athirapally&gt; = athirapally, athirapilly, athirapilli, athirappilli
   </div>
   The first concept captures the idea of oil exploration and not just one particular keyword.
   The second concept captures the names of different narmada dams.  The third concept captures
   different spelling variations of a name.  Thus, the idea of concepts is more versatile.
   </li>

	<li>
	<span class="underline">They simplify filtering rules</span>.
	Compare <div class="nrcode">oil-exploration OR (oil AND drilling)</div> with
	<div class="nrcode">oil exploration OR offshore (oil OR oil-field OR ...) AND ((oil OR ...) AND (drilling OR ..))</div>
	</li>

	<li>
	<span class="underline">Multilingualism comes naturally</span>.
	Consider the concept: 
	<div class="nrcode">
	&lt;oil&gt; = oil, तेल, ಎಣ್ಣೆ
	</div>
	</li>

	<li>
	<span class="underline">Maintenance is easy</span>.
	If tomorrow you wanted to monitor news in Telugu, all you need to do is go and
	add the Telugu keyword for oil in the concept definition of oil, and everything works fine!
	</li>
	</ul>
	</p>
	</div>

	<a name="q3"></a>
	<div class="question"> Q. What is a RSS feed?  </div>
	<div class="answer">
	<p>
	The simplest way to describe this is to contrast this with the
	usual way of browsing on the web.  In this model, as an user, you
	open up your browser, type in a URL (or keywords in a search engine)
	to visit the desired website, and access content from that site.  In
	this model you, as an user, actively visit the website -- i.e. <strong>you
	pull content from the website</strong>.  If you want to keep up-to-date
	with the latest updates on those websites, for example with things like
	newspapers, journals, blogs, discussion lists, etc., you have to remember
	to visit every one of those websites (whenever they are updated, and at
	whatever frequency) to make sure you don't miss out on the updates.
	</p>
	<p>
	<strong>RSS</strong> (Really Simple Syndication or RDF Site Summary) 
	<strong>feeds flip this model completely and enable websites to push content
	to you</strong> -- website updates make their way to your desktop on their
	own once you subscribe to RSS feeds and add them to your RSS reader/aggregator.
	The aggregator now periodically downloads the feeds and displays the aggregated
	updates as links to the updated information (with brief descriptions if the
	feeds make that available).
	</p>

	<p>
	There are a number of
	<a target="_blank" href="http://www.google.com/search?q=RSS+reader+aggregator">RSS
	readers/aggregators</a> available today, and in the future, it is expected
	that most browsers will implement support for these in one way or the other.
	<a target="_blank" href="http://www.mozilla.org/firefox">Mozilla Firefox</a>
	already implements these as <i>live bookmarks</i>.
	</p>
	<p>
	For the technically minded, RSS feeds are just simple XML files.  However,
	unlike regular XML files, the semantics of a RSS file is what makes
	syndication possible -- it can be considered to be a syndication protocol.
	</p>
	</div>

	<a name="q4"></a>
	<div class="question">
	Q. How do I know if a newspaper provides a RSS feed, and how do I get the
	feed?
	</div>
	<div class="answer">
	<p>
	If a newspaper provides a RSS feed, it is usually pretty clearly advertised
	on the website.  Some websites have well-placed icons like 
   <img src="../icons/rss-12x12.jpg" valign="center" />
   or <img src="../icons/rss2.0.gif" valign="center" /> or
	<span class="rsslabel">RSS</span>, for example.
   </p>
   <p>
	Since a RSS feed is just another file (with special semantics) being served
	by the website, it has a well-defined URL.  To add the feed to your news
	aggregator, all you need to is add this URL to your aggregator software.
	In the context of NewsRack, you have to copy this URL
	when defining the news source.
	</p>
	</div>


	</td>
</tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
