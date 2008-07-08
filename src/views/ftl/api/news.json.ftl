[
<#foreach n in news>
  <#escape x as x?js_string>
  {
    title  : "${n.title}",
    url    : "${n.getURL()}",
    source : "${n.feed.name}",
    date   : "${n.dateString}"
  },
  </#escape>
</#foreach>
  '' # Last item -- needed because previous item ends with a comma
]
