<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Edit File</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<script language="Javascript">
function cancelEdit()
{
	if (confirm("Do you want to cancel creating a new file?")) {
		window.location.href="../EditProfile.do";
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
<#include "/ftl/user.header.ftl"><tr>
<#include "/ftl/left.menu.ftl"><td class="user_space">
<#include "/ftl/errors.ftl"><#include "/ftl/messages.ftl">
<div class="ie_center_hack">

<@s.form name="editform" cssClass="editfileform" namespace="/file" action="new" method="post">
<h1>New file</span></h1>
<div class="center">
<textarea class="textarea" name="content" rows="30" cols="70">
(** HERE IS AN EXAMPLE OF A PROFILE ... USE THIS TEMPLATE TO
 ** SUITABLY EDIT IT TO YOUR NEEDS.  FOR MORE HELP, CLICK ON
 ** THE HELP OR USER GUIDE LINKS. YOU CAN GET RID OF THESE 4 
 ** LINES AFTER READING THEM. **)

<#include "/ftl/issue.template"></textarea>
<br />
<span class="bold">File Name:</span> <input type="text" name="file" class="text">
<br />
<input type="submit" class="submit" name="submit" value="Save">
<input type="button" class="submit" onclick="cancelEdit()" value="Cancel">
<input type="button" class="submit" onclick="resetForm()" value="Clear">
</div>
</@s.form>

</div>

</tr>
</td>
</table>
</div>

<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
