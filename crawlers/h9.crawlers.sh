#!/bin/sh

for paper in toi telegraph.ne dainik.jagran dainik.bhaskar #oheraldo
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat6/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
