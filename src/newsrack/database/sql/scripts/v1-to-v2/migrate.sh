#!/bin/sh

if [ $# -lt 6 ]
then
	echo "Usage: $0 <new-db-name> <db-user> <db-password> <db-bkp-dir> <users-bkp-dir> <new-users-dir>"
	exit 0;
fi

db=$1
db_user=$2
db_password=$3
db_bkp_dir=$4
users_bkp_dir=$5
# users_bkp_dir = /media/backup/newsrack/users
users_home=$6
# users_home="/home/subbu/newsrack/webapp/nr.users"
user_table="$users_home/user.table.xml"
feed_table="$users_home/feed.map.xml"
mysql_client="mysql -u$db_user -p$db_password $db"

# 0. initialize
#for i in `ls $users_bkp_dir`
#do
#	cp -r $users_bkp_dir/$i $users_home
#done
#
## 1. create the db and populate it
## echo "create database $db; grant all on $db.* to $db_user@localhost;" | mysql -u root -p
##for i in `ls $db_bkp_dir/*_table.gz`
##do
##	gunzip < $i | $mysql_client
##done
#
## 2. create missing tables
#$mysql_client < create.new.tables.sql
#
## 3. populate the feeds database
#migrate.feeds.pl < $feed_table | $mysql_client
#
## 4. populate the user database
#migrate.users.pl < $user_table | $mysql_client
#
## 5. migrate user file info
#migrate.user.files.pl $db $db_user $db_password < $user_table | $mysql_client
#
### 6. fix up user directories!
#fixup.user.dirs.pl $users_home < $user_table
#
## 7. run the other migrations -- require root privileges
#mysql -uroot -p $db < migrate.sql
#
## 8. run the java program to migrate everything else!
#java newsrack.database.sql.scripts.UserMigration migration.properties migrate

# 9. fixup category keys
$mysql_client < migrate.categories.sql

# 10. eliminate duplicates in news_indexes
$mysql_client < remove.news_index.duplicates.sql

# 11. post-migration modifications to the db
$mysql_client < ../003.sql

# 12. update article counts for categories & topics
java newsrack.database.sql.scripts.UserMigration migration.properties update

# 13. fixup timestamps for categories & topics 
$mysql_client < fixup.timestamps.sql
