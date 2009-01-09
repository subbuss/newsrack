#!/bin/sh

for paper in oheraldo telegraph.ne dainik.bhaskar dainik.jagran
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
