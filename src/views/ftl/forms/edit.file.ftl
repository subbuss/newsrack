<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Edit File</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<script language="Javascript">
function cancelEdit(cancelUrl)
{
	if (confirm("Do you want to cancel the edit?")) {
		window.location.href=cancelUrl;
	}
	return false;
}

function resetForm()
{
	if (confirm("Do you want to reset the file contents?")) {
		window.document.editform.reset();
	}
	return false;
}
</script>
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
<#include "/ftl/messages.ftl">
<div class="ie_center_hack">
<form name="editform" class="editfileform" action="<@s.url namespace="/file" action="save" />" method="post">
<h1><span style="color:#777777">File:</span> <@s.property value="file" /></h1>
<div class="center">
<textarea class="textarea" name="content" rows="36" cols="76"><@s.property value="fileContent" /></textarea>
<br />
<input type="hidden" name="file" value="<@s.property value="file" />">
<input type="button" class="submit" onclick="cancelEdit('<@s.url namespace="/user" action="edit-profile"/>')" value="Cancel">
<input type="button" class="submit" onclick="resetForm()" value="Reset">
<input type="submit" class="submit" name="submit" value="Save">
</div>
</form>
</div>

</tr>
</td>
</table>
</div>
</@s.if>
<@s.else> <#include "/ftl/no.user.ftl"> </@s.else>
<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
