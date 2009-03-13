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
<pre><#include "/ftl/help/example1.code"></pre>
	<hr noshade="noshade">
	<p>
	<strong> Explanation: </strong>
	The profile defines the rediff and Hindu news sources and requests news from
  there.  It defines three concepts (india, australia, and cricket).  Each
	concept defines the keywords that need to matched.  Finally, the issue
	of interest (Indo Aus Series) is defined which defines exactly one category.
	A news item is added to this category if it matches all three concepts
	(india, australia, and cricket).
	</p>

	</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
