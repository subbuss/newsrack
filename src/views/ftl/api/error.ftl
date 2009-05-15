<#if Parameters.output?exists>
<#assign isXML = Parameters.output.equals("xml")>
<#else>
<#assign isXML = true>
</#if>
<#if isXML>
<?xml version="1.0" encoding="UTF-8" ?>
<error val="${errorMsg?xml}" />
<#else>
{ error: "${errorMsg?js_string}" }
</#if>
