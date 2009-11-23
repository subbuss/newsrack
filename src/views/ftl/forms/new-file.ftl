<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Edit File</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<script language="Javascript">
function cancelEdit(cancelUrl)
{
	if (confirm("Do you want to cancel creating a new file?")) {
		window.location.href=cancelUrl;
	}
	return false;
}

function resetForm()
{
	if (confirm("Do you want to reset the file to empty?")) {
		window.document.editform.reset();
	}
	return false;
}
</script>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<#include "/ftl/layout/errors.ftl">
<#include "/ftl/layout/messages.ftl">
<div class="ie_center_hack">

<@s.form name="editform" cssClass="editfileform" namespace="/file" action="new" method="post">
<h1>New file</span></h1>
<div class="center">
<textarea class="textarea" name="fileContent" rows="40" cols="85">
(** Here are 3 examples.  Use them to set up your own topics **)

<#include "/ftl/help/examples"></textarea>
<br />
<span class="bold">File Name:</span> <input type="text" name="file" class="text">
<br />
<input type="button" class="submit" onclick="cancelEdit('<@s.url namespace="/my-account" action="edit-profile"/>')" value="Cancel">
<input type="button" class="submit" onclick="resetForm()" value="Clear">
<input type="submit" class="submit" name="submit" value="Save">
</div>
</@s.form>

</div>

</tr>
</td>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
