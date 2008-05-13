<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Edit Profile</title>
<script language="Javascript">
function confirmDelete() { return confirm("Do you want to delete the file?"); }
</script>
</head>

<body>

<#--######################################################
    ### MACROS USED FOR DISPLAYING THE PROFILE TABLE  ####
    ###################################################### -->
<#-- Macro for getting the url of a file in a user's space
<#macro fileUrlFromName(name)>
<#assign url = vsLink.setURI(userHome + "/" + name)></#macro>

<#-- Macro for displaying a list of files -->
<#macro displayFiles(fileList)>
	<#if fileList?exists && fileList.hasNext()>
	<#foreach f in fileList>
		${f} [
			<a target="_blank" href="<@s.url namespace="/file" action="display" file="${f}" />">View</a>,
			<a href="<@s.url namespace="/forms" action="rename-file" file="${f}" />">Rename</a>,
			<a href="<@s.url namespace="/forms" action="edit-file" file="${f}" />">Edit</a>,
			<a onclick="return confirmDelete()" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'deleteFile'" /><@s.param name="file" value="'${f}'" /></@s.url>">Delete</a>
			]
			<br />
	</#foreach>
	</#if>
</#macro>

<#--########################################################
    # THIS IS THE CODE THAT DISPLAYS THE EDIT PROFILE PAGE #
    ######################################################## -->

<#if Session.user?exists>
<#assign user = Session.user>
<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<#-- FIRST, DISPLAY ANY ERRORS AND MESSAGES -->
<#include "/ftl/layout/errors.ftl">
<#include "/ftl/layout/messages.ftl">
	<#assign hasIssues = user.isValidated()>
	<#assign issues = user.getIssues()>
	<#-- NEXT, DISPLAY THE USER'S PROFILE TABLE -->
		<div class="ie_center_hack">
		<p style="margin-bottom: 20px">
		All your files and defined issues are shown below.  You can add a new file by
		(a) Create a new file using the "Create New File" link (b) uploading a file from your disk, 
		(c) or by getting a file from other users and editing it to meet your needs. <br/> <br/>
	<#if !hasIssues>		<span class="underline bold"> NOTE: </span><br />
		1. The files have to conform to what NewsRack understands (see example below). 
		<b>Do not upload Word docs, html files, images, etc.</b>. <br/>
		2. You have to build your issues by clicking on "Build all issues" link below
		after creating these files.
		3. News will start getting added to your issues next time news is downloaded (news is downloaded 10 times a day).
		</p>
	</#if>
		<table class="editprofile" cellspacing="0">
		<tr class="tblhdr">
			<td class="s18 tblhdr"> ${user.getUid()}'s files </td>
			<td class="s18 tblhdr"> Add more ...  </td>
      </tr>
		<tr>
			<td class="files"> <#call displayFiles(user.getFiles())> </td>
			<td class="center s14">
			<a class="newfile" href="<@s.url namespace="/forms" action="new-file" />">Create New File</a>

			<form class="upload" action="<@s.url namespace="/file" action="upload" />" enctype="multipart/form-data" method="post">
			<input class="file_browse" size="10" name="uploadedFile" type="file" />
			<div align="center"><input class="submit" name="submit" value="Upload" type="submit"></div>
			</form>

			<a class="newfile" href="<@s.url namespace="/" action="public-files" />">Get from other users</a>
			</td>
		</tr>
		<#if hasIssues>
			<tr class="tblhdr"> <td class="s18 tblhdr" colspan="2"> Issues </td> </tr>
			<#foreach i in issues>
			<tr>
			<td class="right"> ${i.getName()} <span class="artcount">[${i.getNumArticles()}]</span> </td>
			<td class="left">
				<a href="<@s.url namespace="/" action="browse" owner="${user.uid}" issue="${i.name}" />">Browse</a>, 
			<#if !i.isFrozen()>
				<a href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'freeze'" /><@s.param name="issue" value="i.name" /></@s.url>">Freeze</a>,
			<#else>
				<a href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'unfreeze'" /><@s.param name="issue" value="i.name" /></@s.url>">Unfreeze</a>,
			</#if>
				<a href="<@s.url namespace="/news" action="reclassify" issue="i.name" />">Reclassify</a>
			</td>
		</tr>
			</#foreach> <#-- for each issue -->
			</#if>		<tr>
			<td class="center s14" colspan="2" style="padding:10px 0">
	<#if hasIssues>			<a class="newfile" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'disableActiveProfile'" /></@s.url>">Invalidate all issues</a> &nbsp; &nbsp; &nbsp;
   <#else>			<a class="newfile" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'validateProfile'" /></@s.url>">Build issues</a>
   </#if>			</td>
		</tr>
		<#if !hasIssues>
		<tr> <td colspan="2">
      <h1> Example (Copy, paste, and edit) </h1>
			<pre>
<#include "/ftl/issue.template">		
			</pre>
		</td> </tr>
		</#if>
		</table>
		<#if hasIssues>
		<p>
		<b> Freeze </b>: Once an issue is frozen, no new articles are downloaded
		into it.  But, old news in the issue continues to be available.  This is
		a good way to set up demo issues. <br/> <br/>
		<b> Reclassify </b>: Classify from the archives.  This is useful when you have made changes 
		to your issue and want those changes reflected.  Or, when you have created a new issue and 
		want to see what kind of news it will capture, use this feature to find out!
		</p>
		</#if>		</div>
	</td>
</table>
</div>
<#else>	<#include "/ftl/layout/no.user.ftl"></#if>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
