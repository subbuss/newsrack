#!/usr/bin/perl

use utf8;
require Encode;
use DBI;

## -- read the rename table --
open('UR', 'users.rename') || die "cannot open users.rename";
%rename = ();
while (<UR>) {
  chop;
  if (/(.*?)\s*=\s*(.*)/) {
	  $rename{$1} = $2;
  }
}
close UR;

$db     = $ARGV[0]; shift;
$user   = $ARGV[0]; shift;
$passwd = $ARGV[0]; shift;
$dbpath = "dbi:mysql:$db";
$dbh = DBI->connect($dbpath, $user, $passwd) or die "Can't open database: $DBI::errstr";
my $sql = qq{SET NAMES 'utf8';};
$dbh->do($sql) || die "Failed to set connection to utf-8";
#print "Successful MySQL DB Connection\n";

$q = "SELECT u_key FROM users WHERE uid = ?";
$find_user_key = $dbh->prepare($q) || die $dbh->errstr;
#$q = "INSERT INTO user_files VALUES(?, ?)";
#$add_user_file = $dbh->prepare($q) || die $dbh->errstr;

while (<>) {
	if (m{uid="(.*)"}) {
		$uid = $1;
		if ($rename{$uid}) {
			$uid = $rename{$uid};
		}
		$find_user_key->execute($uid) || die $dbh->errstr;
		$u_key = -1;
		while (@row = $find_user_key->fetchrow_array()) {
			$u_key = $row[0];
		}
	}
	if (m{file name="(.*)"}) {
		#$add_user_file->execute($uid, Encode::decode_utf8($1)) || die $dbh->errstr;
		$f = $1;
		$f =~ s/'/\\'/g;
		print "INSERT INTO user_files(u_key, file_name) VALUES($u_key, '$f');\n";
	}
}

$dbh->disconnect;
exit 0;
