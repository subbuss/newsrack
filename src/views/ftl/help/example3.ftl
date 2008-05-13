<!DOCTYPE HTML PUBLIC "-//W2C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Example 3</title>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl"><tr>
<#include "/ftl/layout/left.menu.ftl">	<td class="user_space">

	<h1 class="underline center">Example 3: Cricket as well as Kashmir news from Rediff</h1>
	<p>
	Suppose you wanted to monitor india-australia cricketing news as well as 
	Kashmir news from Rediff.  You can do so using the following profile.
	Copy-paste the following contents into a file using the Create New File
   link on the <a href="<@s.url namespace="/user" action="edit-profile" />">Edit Profile page</a>
   and save it.  Then, click on the validate link there, and you are all set!
	</p>
	<p>
	<strong> Explanation: </strong>  This example shows that multiple
	issues can be defined as part of the same profile.
	</p>

	<hr noshade="noshade">
<pre>
<#include "/ftl/help/example3.code"></pre>
	<hr noshade="noshade">

	</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
