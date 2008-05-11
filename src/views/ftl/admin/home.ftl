<!DOCTYPE HTML PUBLIC "-//W2C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title> Administration Screen </title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
</head>

<body>

<#if user><div class="bodymain">
  <table class="userhome" cellspacing="0">
<#include "/ftl/user.header.ftl">    <tr>
<#include "/ftl/left.menu.ftl">    <td class="user_space">
<#include "/ftl/errors.ftl"><#include "/ftl/messages.ftl">    <div>

<#if user.isAdmin()>    <h1> Sign In As Other User</h1>

    <form class="signin" action="<@s.url namespace="/admin" action="change-user" />" method="post">
    <input type="hidden" name="action" value="setUser">
    <div class="formelt mandatory">User-id<input class="text" type="text" name="username"></div>
    <div align="center"> <input class="submit" type="submit" name="submit" value="Sign in"> </div>
    </form>

    <br /> <br />

    <h1> Admin Commands </h1>
    <ul>
	 <#!-- <li> <a href="${vsLink.setAction("Admin").addQueryData("action", "gc")}">GC</a> </li> -->
      <li> <a href="<@s.url namespace="/admin" action="refresh-caching-rules" />">Refresh News Caching Rules</a> </li>
      <li> <a href="<@s.url namespace="/admin" action="refresh-global-properties" />">Refresh Global Properties</a> (CAUTION: This is just a short-cut ... be careful what properties you change and refresh while the app is running ...) </li>
    </ul>
<#else> <!-- NOT an admin -->
    <p style="color:red; font-weight:bold;"> You are not an administrator! </p>
</#if>    </div>
    </td>
    </tr>
  </table>
</div>
<#else> <#--# <!-- user signed in -->
-->	<#include "/ftl/no.user.ftl"></#if><#include "/ftl/footer.ftl" parse="n">
</body>
</html>
