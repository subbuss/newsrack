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
<pre><#include "/ftl/help/example3.code"></pre>
	<hr noshade="noshade">
	<strong> Explanation: </strong>  This example shows that multiple
	issues can be defined in a single file.
	</p>

	</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
