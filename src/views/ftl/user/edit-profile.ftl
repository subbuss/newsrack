<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Edit Profile</title>
<script language="Javascript">
function confirmDelete() { return confirm("Do you want to delete the file?"); }
function confirmReset()  { return confirm("All filtered news will be removed. Are you sure?"); }
</script>
<style>
pre.example { padding: 20px; font-size: 11px; font-weight: bold;}
</style>
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
			<a href="<@s.url namespace="/file" action="edit" file="${f}" />">Edit</a>,
			<a onclick="return confirmDelete()" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'deleteFile'" /><@s.param name="file" value="'${f}'" /></@s.url>">Delete</a>
			]
			<br />
	</#foreach>
	</#if>
</#macro>

<#--########################################################
    # THIS IS THE CODE THAT DISPLAYS THE EDIT PROFILE PAGE #
    ######################################################## -->

<@s.set name="user" value="#session.user" />

<@s.if test="#user">
<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl">
<tr>
<#include "/ftl/layout/left.menu.ftl">
<td class="user_space">
<#-- FIRST, DISPLAY ANY ERRORS AND MESSAGES -->
<#include "/ftl/layout/errors.ftl">
<#include "/ftl/layout/messages.ftl">
  <@s.set name="hasIssues" value="#user.validated" />
	<#-- NEXT, DISPLAY THE USER'S PROFILE TABLE -->
		<div class="ie_center_hack">
<#--
		All your files and defined issues are shown below.  You can add a new file by:
    <ul style="text-align:left;margin:0 0 20px 0">
    <li> Uploading a file from your disk using the upload form </li>
    <li> Creating a new file using the "Create new file" link </li>
    <li> Getting a file from other users and editing it to meet your needs. </li>
    </ul>
-->

		<table class="editprofile" cellspacing="0">
		<tr class="tblhdr">
			<td class="s18 tblhdr"> ${user.uid}'s files </td>
			<td class="s18 tblhdr"> Add more ...  </td>
      </tr>
		<tr>
			<td class="files"> <#call displayFiles(user.files)> </td>
			<td class="center s14" style="width:200px">
      <br/>
			<a class="newfile" href="<@s.url namespace="/forms" action="new-file" />">Create new file</a> </br/><br/>
			<a class="newfile" href="<@s.url namespace="/" action="public-files" />">Get from other users</a>
			<form class="upload" action="<@s.url namespace="/file" action="upload" />" enctype="multipart/form-data" method="post">
			<input class="file_browse" size="10" name="uploadedFile" type="file" />
			<div align="center"><input class="submit" value="Upload" type="submit"></div>
			</form>
			</td>
		</tr>
  <@s.if test="#hasIssues == true">
		<tr class="tblhdr"> <td class="s18 tblhdr" colspan="2"> Issues </td> </tr>
    <@s.iterator value="#user.issues">
		<tr>
			<td class="right"> <a href="<@s.url namespace="/" action="browse" owner="${user.uid}" issue="${name}" />">${name}</a> <span class="artcount">[${numArticles}]</span> </td>
			<td class="left">
			<a onclick="return confirmReset()" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'reset'" /><@s.param name="issue" value="name" /></@s.url>">Clear News</a>,
      <@s.if test="frozen == false">
				<a href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'freeze'" /><@s.param name="issue" value="name" /></@s.url>">Freeze</a>,
      </@s.if>
      <@s.else>
				<a style="color:#070;font-weight:bold;" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'unfreeze'" /><@s.param name="issue" value="name" /></@s.url>">Unfreeze</a>,
      </@s.else>
				<a href="<@s.url namespace="/forms" action="reclassify-news"><@s.param name="issue" value="name" /></@s.url>">Reclassify</a>
			</td>
    </tr>
    </@s.iterator> <#-- for each issue -->
	</@s.if>
    <tr>
			<td class="center s14" colspan="2" style="padding:10px 0">
  <@s.if test="#hasIssues == true">
      <a class="newfile" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'disableActiveProfile'" /></@s.url>">Invalidate all issues</a> &nbsp; &nbsp; &nbsp;
  </@s.if>
  <@s.else>
      <span class="bold s12">
      The files have to conform to what NewsRack understands (see examples below).  Do not upload Word docs, html files, images, etc.
      </span>
      <br/><br/>
      <a class="newfile" href="<@s.url namespace="/user" action="edit-profile"><@s.param name="action" value="'validateProfile'" /></@s.url>">Build issues</a>
   </td></tr>
   <tr> 
     <td colspan="2">
     <div style="padding:5px 10px;text-align:left">
       <h1> Examples </h1>
<#include "/ftl/issue.template">		
     </div>
  </@s.else>
      </td>
    </tr>
		</table>
  <@s.if test="#hasIssues == true">
		<p>
		<b> Freeze </b>: Once an issue is frozen, no new articles are downloaded
		into it.  But, old news in the issue continues to be available.  This is
		a good way to set up demo issues. <br/> <br/>
		<b> Reclassify </b>: Classify from the archives.  This is useful when you have made changes 
		to your issue and want those changes reflected.  Or, when you have created a new issue and 
		want to see what kind of news it will capture, use this feature to find out!
		</p>
	</@s.if>
    </div>
	</td>
</table>
</div>
</@s.if>
<@s.else> <#include "/ftl/layout/no.user.ftl"></@s.else>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
