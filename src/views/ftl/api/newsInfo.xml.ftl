<#assign n = newsItem>
<?xml version="1.0" encoding="UTF-8" ?>
<#escape x as x?xml>
<newsitem>
  <title val="${n.title}" />
  <url val="${n.getURL()}" />
  <date val="${n.date.toString()}" />
  <source val="${n.feed.name}" url="${n.feed.url}" />
  <author val="${n.author}" />
  <desc val="${n.description}" />
  <score val="${n.categories.size()}" />
  <categories>
  <#foreach c in categories>
    <category uid="${c.user.uid}" topic="${c.issue.name}" catId="${c.catId}" name="${c.name}" />
  </#foreach>
  </categories>
</newsitem>
</#escape>
