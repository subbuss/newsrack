<!DOCTYPE HTML PUBLIC "-//W2C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title> Administration Screen </title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
</head>

<body>

<@s.set name="user" value="#session.user" />

<#if user?exists>
<div class="bodymain">
  <table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
  <tr>
<#include "/ftl/layout/left.menu.ftl">
    <td class="user_space">
<#include "/ftl/layout/errors.ftl">
<#include "/ftl/layout/messages.ftl">
    <div>
<#if user.isAdmin()>
    <h1> Sign In As Other User</h1>

    <form class="signin" action="<@s.url namespace="/admin" action="change-user" />" method="post">
    <input type="hidden" name="action" value="setUser">
    <div class="formelt mandatory">User-id<input class="text" type="text" name="username"></div>
    <div align="center"> <input class="submit" type="submit" name="submit" value="Sign in"> </div>
    </form>

    <br /> <br />

    <h1> Admin Commands </h1>
    <ul>
      <li> <a href="<@s.url namespace="/admin" action="refresh-caching-rules" />">Refresh News Caching Rules</a> </li>
      <li> <a href="<@s.url namespace="/admin" action="refresh-global-properties" />">Refresh Global Properties</a> (CAUTION: This is just a short-cut ... be careful what properties you change and refresh while the app is running ...) </li>
    </ul>
<#else> <#-- NOT an admin -->
    <p style="color:red; font-weight:bold;"> You are not an administrator! </p>
</#if>    </div>
    </td>
    </tr>
  </table>
</div>
<#else> <#-- user signed in -->
<#include "/ftl/layout/no.user.ftl">
</#if>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
