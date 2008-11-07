var _nr_metadata = {
  site_base_url : "${siteUrl}",
  issue_name    : "${Parameters.issue}",
  category_name : "${category.name}",
  listing_url   : "/browse?owner=${Parameters.owner}&issue=${Parameters.issue}&catID=${Parameters.catID}"
}
var _nr_stories = [
<#foreach n in news>
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
