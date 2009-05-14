<?xml version="1.0" encoding="UTF-8" ?>
<#escape x as x?xml>
<issue>
  <name>${issue.name}</name>
  <createdBy>${issue.user.uid}</createdBy>
  <#foreach src in issue.monitoredSources>
    <source>
      <name>${src.name}</name>
      <tag>${src.tag}</tag>
      <feed>${src.feed.url}</feed>
    </source>
  </#foreach>
</issue>
</#escape>
