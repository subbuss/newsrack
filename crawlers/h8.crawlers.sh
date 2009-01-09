#!/bin/sh

for paper in ie dna.bangalore navhindtimes kanglaonline epao starofmysore hindustan.dainik
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
