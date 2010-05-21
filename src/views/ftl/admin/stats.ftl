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
	 <h1> Cache + SQL execution Stats </h1>
	 ${stats}
    </div>
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
