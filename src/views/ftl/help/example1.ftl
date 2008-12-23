<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Example 1</title>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl"><tr>
<#include "/ftl/layout/left.menu.ftl">	<td class="user_space">

	<h1 class="underline center">Example 1: India-Australia cricket news</h1>
	<p>
	<strong>Copy-Paste example</strong>
	Suppose you wanted to monitor cricketing news for the India-Australia
	series from Rediff and Hindu.  You can do so using the following profile.
  Copy-paste the example below into a file using the Create New File link
  on the <a href="<@s.url namespace="/user" action="edit-profile" />">Edit Profile page</a>
  and save it.  Then, click on the validate link there, and you are all set!
	</p>
	<p>
	<strong> Explanation: </strong>
	The profile defines the rediff and Hindu news sources and requests news from
  there.  It defines three concepts (india, australia, and cricket).  Each
	concept defines the keywords that need to matched.  Finally, the issue
	of interest (Indo Aus Series) is defined which defines exactly one category.
	A news item is added to this category if it matches all three concepts
	(india, australia, and cricket).
	</p>

	<hr noshade="noshade">
<pre>
<#include "/ftl/help/example1.code"></pre>
	<hr noshade="noshade">

	</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
