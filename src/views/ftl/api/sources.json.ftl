<#escape x as x?js_string>
{
  name       : "${issue.name}",
  created_by : "${issue.user.uid}",
  sources    : [
  <#foreach src in issue.monitoredSources>
    {
      name : ${src.name},
      tag  : ${src.tag},
      feed : ${src.feed.url}
    }
  </#foreach>
  '' # Last item -- needed because previous item ends with a comma
  ]
}
</#escape>
