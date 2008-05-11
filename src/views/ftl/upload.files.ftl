<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Upload Profile files</title>
</head>

<body>

<#if user><div class="bodymain">
<table class="userhome" cellspacing="0">
	<#include "/ftl/user.header.ftl"><tr>
	<#include "/ftl/left.menu.ftl">	<td class="user_space">
		<h1>Upload profile files</h1>
	<#include "/ftl/errors.ftl">		<div class="description" style="left:12px; width:600px">
	<#if uploadedFiles>		<p> The following files were uploaded:
		<ul>
		<#foreach file in uploadedFiles>			<li> ${file} </li>
		</#foreach>		</ul>
		</p>
	</#if>
		<p>
		Upload definitions of news sources, concepts, and categories that
		you will use in your profile.  Note that it is not necessary to have
		definitions of news sources, concepts, and categories in separate files.
		You can define all of these in the profile definition file.  However,
		it is recommended that you provide these definitions in separate files.
		Alternatively, you can download files from other users and use them
		without modification or edit them to suit your needs.
		</p>
		</div>

		<!-- Position the upload from and the public files element in a single div
			  one next to each other -->
		<div style="position:relative; left:12px; width:600px; height:150px;">

				<!-- File upload form -->
			<form class="register" style="width:330px; position:absolute; left:10px" action="<@s.url namespace="/" action="upload" />" enctype="multipart/form-data" method="post">
			<div class="formelt"> Sources    <input class="file_browse" name="sources" type="file" /> </div>
			<div class="formelt"> Concepts   <input class="file_browse" name="concepts" type="file"> </div>
			<div class="formelt"> Categories <input class="file_browse" name="categories" type="file"> </div>
			<div class="formelt"> Profile    <input class="file_browse" name="profile" type="file"> </div>
			<div align="center"> <input class="submit" name="submit" value="Upload Files" type="submit"> </div>
			</form>

				<!-- Listing of public profile files -->
			<div style="position: absolute; right:10px; top:20px;" class="public_files">
			<h2> Public files of other users</h2>
			<ul>
			<li> <a href="<@s.url namespace="/" action="public-files" class="sources" />">News Source definitions</a> </li>
			<li> <a href="<@s.url namespace="/" action="public-files" class="concepts" />">Concept definitions</a> </li>
			<li> <a href="<@s.url namespace="/" action="public-files" class="cats" />">Category definitions</a> </li>
			<li> <a href="<@s.url namespace="/" action="public-files" class="profiles" />">Profile definitions</a> </li>
			</ul>
			</div>
		</div>
	</td>
</tr>
</table>
</div>
<#else>	<#include "/ftl/no.user.ftl"></#if>
<#include "/ftl/footer.ftl" parse="n">
</body>
</html>
