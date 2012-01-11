#!/bin/sh

for paper in hindu.todays_paper dainik.jagran assam.tribune 
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat6/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
