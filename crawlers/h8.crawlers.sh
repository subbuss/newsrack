#!/bin/sh

for paper in dna.bangalore kanglaonline epao starofmysore midday hindustan.dainik #lebanonfiles journaladdiyar elnashra
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
