#!/bin/sh

for paper in ie dna.bangalore navhindtimes kanglaonline epao starofmysore midday hindustan.dainik
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
