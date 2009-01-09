#!/bin/sh

for paper in hindustan.dainik
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
