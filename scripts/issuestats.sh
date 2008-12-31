#!/bin/sh

HOME="/services/floss/fellows/subbu"
UDIR="$HOME/resin/webapps/newsrack/users"
UTABLE="$UDIR/user.table.xml"
for i in `grep uid $UTABLE | cut -f2 -d'"'`
do
	for j in `find $UDIR/$i -name news.xml | grep -v _attic`
	do
		echo "###### $j ######"
		grep "<url" $j | cut -f2 -d" " | cut -f2 -d'"' | sed 's/.*php5.file=http/http/g;'| cut -f3 -d"/" | sort | uniq -c | sort -nr >  $j.STATS
	done
done
