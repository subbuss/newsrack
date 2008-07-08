<#escape x as x?js_string>
{
  name       : "${issue.name}",
  created_by : "${issue.user.uid}",
  categories : [
  <#foreach cat in issue.categories>
    <#call displayCat(cat)>
  </#foreach>
  '' # Last item -- needed because previous item ends with a comma
  ]
}
</#escape>

<#-- Macro for displaying a category -->
<#macro displayCat(cat)>
<#escape x as x?js_string>
  {
    name : "${cat.name}",
    id   : ${cat.catId},
  <#if cat.isLeafCategory()>
    rule : "${cat.filter.ruleString}"
  <#else>
    <#foreach c in cat.children>
      <#call displayCat(c)>
    </#foreach>
    '' # Last item -- needed because previous item ends with a comma
  </#if>
  },
</#escape>
</#macro>
