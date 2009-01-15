#!/bin/sh

for paper in hindustan.dainik
do
   echo "---- generating rss for $paper ----"
   perl /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
