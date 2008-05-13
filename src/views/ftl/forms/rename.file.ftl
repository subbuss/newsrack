<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Rename file</title>
</head>

<body>

<@s.set name="user" value="#session.user" />
<@s.if test="#user">
<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/user.header.ftl">
<tr>
<#include "/ftl/left.menu.ftl">
<td class="user_space">
<#include "/ftl/errors.ftl">
				<!-- Password change form -->
		<h1> Renaming file <@s.property value="file" /></h1>
		<div class="ie_center_hack">
		<form class="register" style="width:260px" action="<@s.url namespace="/file" action="rename" />" method="post">
		<input type="hidden" name="name" value="<@s.property value="file" />"> 
		<div class="formelt"> New Name : <input class="text" name="newname"> </div>
		<div align="center"> <input class="submit" name="submit" value="Rename" type="submit"> </div>
		</form>
		</div>
	</td>
</tr>
</table>
</div>
</@s.if>
<@s.else> <#include "/ftl/no.user.ftl"> </@s.else>
<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
