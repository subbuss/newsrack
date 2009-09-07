#!/bin/sh

for paper in toi kanglaonline epao starofmysore central.chronicle pib nie business.standard fe
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
