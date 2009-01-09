#!/bin/sh

for paper in ie dna.bangalore
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
