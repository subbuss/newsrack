#!/bin/sh

if [ $# -lt 3 ]
then
	echo "Usage: $0 <new-db-name> <db-user> <db-password>"
	exit 0;
fi

db=$1
db_user=$2
db_password=$3
users_home="/home/subbu/newsrack/webapp/nr.users"
user_table="$users_home/user.table.xml"
feed_table="$users_home/feed.map.xml"
mysql_client="mysql -u$db_user -p$db_password $db"

$mysql_client < x.sql
migrate.users.pl < $user_table | $mysql_client
migrate.user.files.pl $db $db_user $db_password < $user_table | $mysql_client
java newsrack.UserMigration migration.properties
#java newsrack.UserMigration migration.properties users.to.migrate.attempt2
