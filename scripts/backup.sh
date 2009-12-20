#!/bin/sh

dirname=`date +'%d.%m.%y'`;
BKPDIR="/home/newsrack/backup/$dirname"
mkdir -p $BKPDIR
mysqldump --user=newsrack --password=123news newsrack users | gzip > $BKPDIR/users.gz
mysqldump --user=newsrack --password=123news newsrack feeds | gzip > $BKPDIR/feeds.gz
mysqldump --user=newsrack --password=123news newsrack topics | gzip > $BKPDIR/topics.gz
mysqldump --user=newsrack --password=123news newsrack sources | gzip > $BKPDIR/sources.gz
mysqldump --user=newsrack --password=123news newsrack topic_sources | gzip > $BKPDIR/topic_sources.gz
mysqldump --user=newsrack --password=123news newsrack concepts | gzip > $BKPDIR/concepts.gz
mysqldump --user=newsrack --password=123news newsrack categories | gzip > $BKPDIR/categories.gz
mysqldump --user=newsrack --password=123news newsrack filters | gzip > $BKPDIR/filters.gz
mysqldump --user=newsrack --password=123news newsrack filter_rule_terms | gzip > $BKPDIR/filter_rule_terms.gz
mysqldump --user=newsrack --password=123news newsrack user_files | gzip > $BKPDIR/user_files.gz
mysqldump --user=newsrack --password=123news newsrack import_dependencies | gzip > $BKPDIR/import_dependencies.gz
mysqldump --user=newsrack --password=123news newsrack user_collections | gzip > $BKPDIR/user_collections.gz
mysqldump --user=newsrack --password=123news newsrack collection_entries | gzip > $BKPDIR/collection_entries.gz
mysqldump --user=newsrack --password=123news newsrack cat_news | gzip > $BKPDIR/cat_news.gz
mysqldump --user=newsrack --password=123news newsrack news_indexes | gzip > $BKPDIR/news_indexes.gz
mysqldump --user=newsrack --password=123news newsrack news_items | gzip > $BKPDIR/news_items.gz
mysqldump --user=newsrack --password=123news newsrack news_collections | gzip > $BKPDIR/news_collections.gz
mysqldump --user=newsrack --password=123news newsrack news_item_url_md5_hashes | gzip > $BKPDIR/news_item_url_md5_hashes.gz
##mysqldump --user=newsrack --password=123news newsrack news_item_localnames | gzip > $BKPDIR/news_item_localnames.gz
