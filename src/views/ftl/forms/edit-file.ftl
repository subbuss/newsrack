<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Edit File</title>
<#include "/ftl/layout/common_includes.ftl">
<script language="javascript">
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
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<#include "/ftl/layout/errors.ftl">
<#include "/ftl/layout/messages.ftl">
<div class="ie_center_hack">

<@s.form name="editform" cssClass="editfileform" namespace="/file" action="save" method="post">
<h1><span style="color:#777777">File:</span>${file}</h1>
<div class="center">
<textarea class="textarea" name="fileContent" rows="40" cols="85">${fileContent}</textarea>
<br />
<input type="button" class="submit" onclick="cancelEdit('<@s.url namespace="/my-account" action="edit-profile"/>')" value="Cancel">
<input type="button" class="submit" onclick="resetForm()" value="Reset">
<input type="submit" class="submit" name="submit" value="Save">
<input type="hidden" name="file" value="${file}">
</div>
</@s.form>
</div>

</tr>
</td>
</table>
</div>
</@s.if>
<@s.else> <#include "/ftl/layout/no.user.ftl"> </@s.else>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
