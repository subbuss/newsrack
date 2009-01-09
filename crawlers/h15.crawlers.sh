#!/bin/sh

for paper in telegraph.ne
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
