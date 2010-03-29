<!DOCTYPE HTML PUBLIC "-//W2C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<title>Classify news from archive</title>
</head>

<body>

<#assign months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]>
<#assign privileged = ["neitham", "admin", "subbu", "lalremlein"]>
<#if privileged?seq_contains(user.uid)>
  <#assign yearRange = 2004..2010>
<#else>
  <#assign yearRange = 2010..2010>
</#if>

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
	<h1 class="underline">Reclassify news from archive</h1>
	<p>
	You can reclassify news from the available news archive.  You might be interested
	in this, for example, if you have added a new issue or a new category recently and
	want to find any related news items from the archive. 
	</p>

<#assign user = stack.findValue("#user")>
<#if !Parameters.issue?exists>
  <#--
   # If no issues are specified as a parameter
   # simply display a list of issues that are defined for this user
   # and let the user pick one!
   # -->
<div class="ie_center_hack">
	<form class="ie_center_hack" method="post" action="<@s.url value="ftl/reclassify.ftl" />">
	<table class="dates">
	<tr> <td class="tblhdr center bold"> Issues </td> </tr>
	<tr>
	<td>
		<center>
    <select name="issue" size="5">
	<#foreach i in user.issues>
    <option value="${i.name}">${i.name}</option>
	</#foreach>
    </select>
    </center>
	</td>
	</tr>
	<tr> <td class="brownish center"> <input type="submit" name="Reclassify" value="Reclassify News"> </td> </tr>
	</table>
	</form>
	</div>
<#else>
  <#assign issue = Parameters.issue>
  <#--
   # If some issues is specified as a parameter,
   # simply display the list of sources that are defined for the issue
   # and let the user pick the sources and dates for reclassification.
   # -->
<div class="ie_center_hack">
	<form class="ie_center_hack" method="post" action="<@s.url namespace="/news" action="reclassify" />">
	<table class="dates">

	<tr> <td class="tblhdr center bold" colspan="2"> Issue: ${issue} </td> </tr>
	<tr> <td class="brownish center" colspan="2">
	<b> Reset all categories </b> <input type="checkbox" name="resetCats">
	<hr />
	</td>
	</tr>

	<tr> <td class="tblhdr center bold" colspan="2"> Sources </td> </tr>
	<tr> <td class="brownish center" colspan="2">
	<b>All Sources</b> <input type="checkbox" name="allSources"> <hr />
	<select name="srcs" multiple size="10">
  <#assign srcs = user.getIssue(issue).monitoredSources>
  <#foreach s in srcs>
  <option value="${s.key?c}">${s.name}</option>
  </#foreach>
  </select>
	</tr>

	<tr> <td class="tblhdr bold"> From </td> <td class="tblhdr bold"> To </td> </tr>
	<tr>
	<td class="brownish">
	<select name="sd">
  <#foreach num in 1..31>
    <option value="${num}">${num}</option>
  </#foreach>
  </select>
	<select name="sm">
  <#foreach month in months>
    <option value="${1+months?seq_index_of(month)}">${month}</option>
  </#foreach>
	</select>
	<select name="sy">
  <#foreach num in yearRange>
    <option value="${num?c}">${num?c}</option>
  </#foreach>
  </select>
	</td>

	<!-- NOW, the END DATE -->
	<td class="brownish">
	<select name="ed">
  <#foreach num in 1..31>
    <option value="${num}">${num}</option>
  </#foreach>
  </select>
	<select name="em">
  <#foreach month in months>
    <option value="${1+months?seq_index_of(month)}">${month}</option>
  </#foreach>
	</select>
	<select name="ey">
  <#foreach num in yearRange>
    <option value="${num?c}">${num?c}</option>
  </#foreach>
	</select>
	</td>
	</tr>

	<tr>
	<td colspan="2" class="brownish center">
<#--
	<hr /> <b>Entire archive</b> <input type="checkbox" name="completeArchive"> <hr />
-->
	<input type="hidden" name="issue" value="${issue}">
	<input type="submit" class="submit" name="Reclassify" value="Reclassify News">
	</td>
	</tr>
	</table>
	</form>
	</div>
</#if>
	<p>
	<b class="underline">Note:</b>
	<ul>
	<li style="color:#ff4400; font-weight: bold">
	In the current design and implementation of NewsRack, this is a VERY slow process!
	So, start this process, do other work and 
	come back to check on this ... This design is fixable and will be fixed in time when
	more programmer resources become available ... 
	<li>
	For the dates selected, articles from the news sources you select are used.
	The set of news sources displayed are whatever you specified in your profile
	</li>
<#--
	<li>
	Select the dates between which archived news articles have to be classified.
	If you check the "<b>Entire Archive</b>" radio button, all articles from the
	archive are used.
	</li>
	<li>
	Unless you choose a date range of a few weeks, this process will take several
	minutes.  Work is ongoing to make this more efficient and faster.
	</li>
-->
	<li>
	If you check the "Reset Categories" radio button, all the articles currently
	classified in your categories will be removed.  So, if over the course of
	editing your profile, you have removed some news sources, news that was
	originally classified from those sources will be lost (unless you edit the
	profile and add them back).  So, be cautious about checking this buttion.
	If you leave the radio button unchecked, all your original articles will
	remain as is, and new articles, if any, will get added.
	</li>
	</ul>
	</p>

</tr>
</table>
</div>
</@s.if>
<@s.else> <#include "/ftl/layout/no.user.ftl"> </@s.else>
<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
