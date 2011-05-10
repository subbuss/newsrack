#!/bin/sh

for paper in dna.bangalore #lebanonfiles journaladdiyar elnashra
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat6/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
