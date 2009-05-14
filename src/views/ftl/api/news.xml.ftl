<?xml version="1.0" encoding="UTF-8" ?>
<news>
<#foreach n in newsList>
  <#escape x as x?xml>
  <newsitem>
    <title val="${n.title}" />
    <url val="${n.getURL()}" />
    <source val="${n.feed.name}" />
    <date val="${n.dateString}" />
  </newsitem>
  </#escape>
</#foreach>
</news>
