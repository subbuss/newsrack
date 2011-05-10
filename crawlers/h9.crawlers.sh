#!/bin/sh

for paper in toi telegraph.ne dainik.jagran dainik.bhaskar #oheraldo
do
   echo "---- generating rss for $paper ----"
   /var/lib/tomcat5.5/webapps/newsrack.crawlers/gen.$paper.rss.pl > /tmp/$paper.out
done
