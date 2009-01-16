#!/bin/sh

for paper in dh statesman projectsmonitor fline chandigarh.tribune central.chronicle pib nie business.standard pioneer nbt fe
do
   echo "---- generating rss for $paper ----"
   perl /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done