#!/bin/sh

WEBAPP="/var/lib/tomcat5.5/webapps/ROOT"
echo "######################"
ls -lt $WEBAPP/crawled.feeds
echo "######################"
grep "Total bytes downloaded" $WEBAPP/WEB-INF/crawlers/*.logfile
echo "######################"
ls -lt $WEBAPP/WEB-INF/crawlers/*.logfile
