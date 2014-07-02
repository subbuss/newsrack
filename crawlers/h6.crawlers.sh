#!/bin/sh

for paper in cgnet hindu.todays_paper chandigarh.tribune pib business.standard nbt #projectsmonitor fline fe nie pioneer statesman central.chronicle
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat6/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
