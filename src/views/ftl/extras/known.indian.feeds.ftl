<!DOCTYPE HTML PUBLIC"-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head> 
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title> List of all known RSS feeds for Indian newspapers and magazines </title> 
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<style>
td.user_space table { background: #f8f8f8; }
td.user_space td { vertical-align: top; margin: 2px; padding: 3px 4px; }
td.user_space a { padding: 1px 0px; text-decoration: none; color: 882222; font-size: 11px; }
td.user_space a:hover { padding: 3px 0px; text-decoration: none; background-color: 882222; color: white }
</style>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
  <#include "/ftl/layout/header.ftl"><tr>
  <#include "/ftl/layout/left.menu.ftl"><td class="user_space">
  <h1> List of known RSS feeds for Indian newspapers and magazines </h1>

  <p>
  The name of the magazine / newspaper (or newspaper section, as the case might be) is linked to the RSS feed for that magazine / newspaper.
  <span class="bold">If you find any error or find a feed that should be listed here, please <a href="<@s.url namespace="/about" action="contact" />">get in touch</a>!</span>
  </p>

<table>
  <tr>
  <#assign i = 0>
  <@s.iterator value="indianFeeds">
    <#if i % 3 == 0> </tr><tr> </#if>
    <td> <a href="<@s.url value="${url}" />">${name}</a> </td>
    <#assign i = i + 1>
	</@s.iterator>
  </tr>
</table>

</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
