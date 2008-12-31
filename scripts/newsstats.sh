#!/bin/sh

HOME="/var/lib/tomcat5.5"
UDIR="$HOME/webapps/ROOT/users"
UTABLE="$UDIR/user.table.xml"
echo > /tmp/localpath
echo > /tmp/news.urls
for i in `grep uid $UTABLE | cut -f2 -d'"'`
do
	if [ $i != "admin" ]
	then
	find $UDIR/$i -name news.xml -exec grep -H "<localcopy " {} \; | grep -v _attic | cut -f2- -d":" >> /tmp/localpath
	find $UDIR/$i -name news.xml -exec grep -H "<url " {} \; | grep -v _attic | cut -f2- -d":" >> /tmp/news.urls
	fi
done
sort /tmp/news.urls | uniq > /tmp/uniq.urls
echo "TOTAL        (1) - " `wc -l /tmp/localpath`
echo "TOTAL UNIQUE (1) - " `sort /tmp/localpath | uniq | wc -l`
echo "TOTAL        (2) - " `wc -l /tmp/news.urls`
echo "TOTAL UNIQUE (2) - " `wc -l /tmp/uniq.urls`
cut -f2 -d'"' /tmp/uniq.urls | cut -f1-3 -d'/' | sed 's/www\.//g;' | sort | uniq -c | sort -nr
