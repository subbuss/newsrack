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
<#include "/ftl/user.header.ftl"><tr>
<#include "/ftl/left.menu.ftl">	<td class="user_space">

	<h1 class="underline center">Example 2: Kashmir-related news from Rediff</h1>
	<p>
	Suppose you wanted to monitor news about Kashmir from Rediff.
	You can do so using the following profile.  Copy-paste the
   following contents into a file using the Create New File link on
   the <a href="<@s.url namespace="/user" action="edit-profile" />">Edit Profile page</a>
   and save it.  Then, click on the validate link there, and you are all set!
	</p>
	<strong> Explanation: </strong>
	As in <a href="example1.ftl">Example 1</a>, the profile defines the rediff 
	news source and requests news from there.  It then defines the "jk" concept.
	Whenever "jammu" or "kashmir" is seen, this concept will be matched.
	Finally, the issue of interest (Kashmir News) is defined which defines
   exactly one category.  A news item is added to this category if it matches
   the "jk" concept.
	</p>

	<hr noshade="noshade">
<pre>
<#include "/ftl/example2.code"></pre>
	<hr noshade="noshade">

	</td>
</tr>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
