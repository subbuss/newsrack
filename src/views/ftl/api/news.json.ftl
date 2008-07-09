var _nr_metadata = {
  site_base_url: "http://localhost:8180/newsrack",
  listing_name : "${Parameters.issue} news",
  listing_url  : "/browse?owner=${Parameters.owner}&issue=${Parameters.issue}&catID=${Parameters.catID}"
}
var _nr_stories = [
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
  '' // Last item -- needed because previous item ends with a comma
]
