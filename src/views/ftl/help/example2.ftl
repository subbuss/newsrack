<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Example 2</title>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl"><tr>
<#include "/ftl/layout/left.menu.ftl">	<td class="user_space">

	<h1 class="underline center">Example 2: Kashmir-related news from Rediff</h1>
<pre><#include "/ftl/help/example2.code"></pre>
	<hr noshade="noshade">
	<strong> Explanation: </strong>
	This profile defines the rediff news source and requests news from there.
  It then defines the "jk" concept.  Whenever "jammu" or "kashmir" is seen,
  this concept will be matched.  Finally, the issue of interest (Kashmir News)
  is defined which is basically a simple filter that looks for a match of 
  the "jk" concept in the news item.
	</p>

	</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
