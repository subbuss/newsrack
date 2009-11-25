#!/bin/sh

for paper in statesman projectsmonitor fline chandigarh.tribune pib nie business.standard pioneer nbt fe #central.chronicle
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
