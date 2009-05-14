<#assign n = newsItem>
<#escape x as x?js_string>
var _nr_newsitem = {
  title  : "${n.title}",
  url    : "${n.getURL()}",
  source : { name: "${n.feed.name}", url: "${n.feed.url}" },
  date   : "${n.dateString}",
  desc   : "${n.description}"
  categories : [
  <#foreach c in categories>
    {
      name  : "${c.name}",
      uid   : "${c.user.uid}",
      topic : "${c.issue.name}",
      catId : "${c.catId}"
    },
  </#foreach>
    '' // Last item -- needed because previous item ends with a comma
  ]
}
</#escape>
