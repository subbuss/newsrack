var _nr_metadata = {
  site_base_url : "${siteUrl}",
  issue_name    : "${Parameters.issue}",
<#if category??>
  category_name : "${category.name}",
  listing_url   : "/stories/${Parameters.owner}/${Parameters.issue}/${Parameters.catID}"
<#else>
  category_name : "",
  listing_url   : "/topics/${Parameters.owner}/${Parameters.issue}"
</#if>
}
var _nr_stories = [
<#foreach n in newsList>
  <#escape x as x?js_string>
  {
    title  : "${n.title}",
    url    : "${n.getURL()}",
    source : "${n.feed.name}",
    date   : "${n.dateString}",
    desc   : "${n.description}"
  },
  </#escape>
</#foreach>
  '' // Last item -- needed because previous item ends with a comma
]
