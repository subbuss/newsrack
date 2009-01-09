#!/bin/sh

for paper in dh statesman projectsmonitor fline chandigarh.tribune central.chronicle pib nie business.standard pioneer nbt fe
do
   echo "---- generating rss for $paper ----"
   perl gen.$paper.rss.pl
done
