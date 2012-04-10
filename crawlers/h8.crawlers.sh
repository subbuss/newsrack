#!/bin/sh

for paper in dna.bangalore kanglaonline epao starofmysore hindustan.dainik #midday lebanonfiles journaladdiyar elnashra
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat6/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
