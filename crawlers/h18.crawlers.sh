#!/bin/sh

for paper in navhindtimes kanglaonline epao starofmysore central.chronicle pib nie business.standard fe
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
