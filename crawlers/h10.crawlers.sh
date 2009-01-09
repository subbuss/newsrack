#!/bin/sh

for paper in assam.tribune kannada.prabha
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
