#!/bin/sh

for paper in toi kanglaonline epao starofmysore pib business.standard #central.chronicle fe nie 
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat6/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
