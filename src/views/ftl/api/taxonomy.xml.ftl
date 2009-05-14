<?xml version="1.0" encoding="UTF-8" ?>
<#escape x as x?xml>
<issue>
  <name>${issue.name}</name>
  <createdBy>${issue.user.uid}</createdBy>
  <#foreach cat in issue.categories>
    <#call displayCat(cat)>
  </#foreach>
</issue>
</#escape>

<#-- Macro for displaying a category -->
<#macro displayCat(cat)>
<#escape x as x?xml>
<category uid="${cat.user.uid}" topic="${cat.issue.name}" catId="${cat.catId}" name="${cat.name}">
  <#if cat.isLeafCategory()>
  <rule>${cat.filter.ruleString}</rule>
  <#else>
    <#foreach c in cat.children>
      <#call displayCat(c)>
    </#foreach>
  </#if>
</category>
</#escape>
</#macro>
