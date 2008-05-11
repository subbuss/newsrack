<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<div class="ie_center_hack">
<div class="main">
<h1> No user signed in! </h1>
<p> 
You can do one of the following:
<ul>
<li> If you were signed in, then the session has probably expired!  Please
    <a href=${vsLink.setForward("signin.failure")}>sign in</a> again to access your 
	 user space. </li>
<li> If you do not have an user account, you can <a href="${vsLink.setForward("goto.register")}">register</a> for one. </li>
<#--<li> Else, you can <a href="$vsLink.setAction("Search")">search</a> the
--><#--	  news archives made publicly available by other users. </li>
--><li> Or, you can <a href="${vsLink.setAction("Browse")}">browse</a> the publicly available news archives instead.</li>
</ul>
</p>
</div> <!-- class = "main" -->
</div>
