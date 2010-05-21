<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<title>Edit Profile</title>
<#include "/ftl/layout/common_includes.ftl">
<script language="javascript">
function confirmDelete() { return confirm("Do you want to delete the file?"); }
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
  <tr>
    <td class="files"> 
			<a target="_blank" href="<@s.url namespace="/file" action="display" file="${f.name}" />">${f.name}</a>
    </td>
    <td class="actions">
			<a href="<@s.url namespace="/file" action="edit" file="${f.name}" />">Edit</a>,
			<a href="<@s.url namespace="/forms" action="rename-file" file="${f.name}" />">Rename</a>,
			<a onclick="return confirmDelete()" href="<@s.url namespace="/my-account" action="edit-profile"><@s.param name="action" value="'deleteFile'" /><@s.param name="file" value="'${f.name}'" /></@s.url>">Delete</a>
    </td>
  </tr>
	</#foreach>
  <#else>
  <tr>
  <td style="padding:15px; text-align:left;" colspan="2">
  In NewsRack, you define your topics by defining concepts, filters, topics, and sources to monitor.<br/><br/>
  <a class="helplink" href="#" onclick="$('#examples').toggle(); return false;">See examples</a> and/or check the <a class="helplink" target="_blank" href="<@s.url namespace="/help" action="user-guide" />">User Guide</a>.
  </td>
  </tr>
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
  <h1> Your files </h1>
  <@s.set name="hasIssues" value="#user.validated" />
	<#-- NEXT, DISPLAY THE USER'S PROFILE TABLE -->
	<div class="ie_center_hack">
		<table class="editprofile" cellspacing="0">
    <#call displayFiles(user.files)> 
    <tr>
			<td colspan="2">
        <div class="more_files">
          <a href="<@s.url namespace="/forms" action="new-file" />">Create new file</a>
          <a href="<@s.url namespace="/" action="public-files" />">Copy from another user</a>
          <a href="#" onclick="$('#upload_form').toggle(); return false;">Upload file</a>
          <a href="#" class='helplink' onclick="$('#new_file_help').toggle(); return false;">Help</a>
          <form id="upload_form" style="width:275px;display:none;" class="upload" action="<@s.url namespace="/file" action="upload" />" enctype="multipart/form-data" method="post">
            <input class="file_browse" size="15" name="uploadedFile" type="file" />
            <div align="center"><input class="submit" value="Upload File" type="submit"></div>
          </form>
        </div>

        <div id="new_file_help" style="text-align:left;margin:20px;display:none;">
        <ul style="text-align:left;margin:0 0 20px 0">
        <li> Create a new file using the "Create new file" link </li>
        <li> Get a file from other users and edit it to meet your needs </li>
        <li> Upload a file from your disk using the upload form. <span class="bold">Note that the files have to conform to what NewsRack understands.  Do not upload Word docs, html files, images, etc. </span> </li>
        </ul>
        </div>
			</td>
		</tr>
    <tr>
  <@s.if test="#hasIssues == true">
    <td colspan="2" style="text-align:center">
    Your files have been validated and <a href="<@s.url namespace="/my-account" action="home" />">you can find your topics here</a>. <br/><br/>
    <a class="action_link" href="<@s.url namespace="/my-account" action="edit-profile"><@s.param name="action" value="'disableActiveProfile'" /></@s.url>">Invalidate all topics</a> <br/><br/>
  </@s.if>
  <@s.else>
    <#if user.files?exists&& user.files.hasNext()>
    <td colspan="2" style="text-align:center">
    <a class="action_link" href="<@s.url namespace="/my-account" action="edit-profile"><@s.param name="action" value="'validateProfile'" /></@s.url>">Validate files</a>
    <br/>
    <div style="color:red;margin:10px;">
    Your files have not been validated.<br/>
    Please validate them and fix errors to turn on news monitoring.
    </div>
    </td>
    </tr><tr> 
    </#if>
    <td id="examples" style="display:none;" colspan="2">
      <a name="examples"></a>
      <div style="padding:5px 10px;text-align:left;">
        <h1> Examples </h1>
<#include "/ftl/issue.template">		
      </div>
  </@s.else>
    </td>
    </tr>
		</table>
  </div>
	</td>
</table>
</div>
</@s.if>
<@s.else> <#include "/ftl/layout/no.user.ftl"></@s.else>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
