#!/bin/sh

for paper in pib
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
