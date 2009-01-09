#!/bin/sh

for paper in assam.tribune dainik.jagran
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
