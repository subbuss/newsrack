#!/bin/sh

for paper in projectsmonitor fline chandigarh.tribune pib business.standard nbt fe #nie pioneer statesman central.chronicle
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
