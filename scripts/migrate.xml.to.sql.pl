#!/usr/bin/perl

require Encode;
use utf8;
use DBI;

##### main program
$user   = $ARGV[0];
$passwd = $ARGV[1];
#$dbpath = "dbi:mysql:nr_test;mysql_socket=/tmp/mysql.sock";
$dbpath = "dbi:mysql:newsrack";
$dbh = DBI->connect($dbpath, $user, $passwd) or die "Can't open database: $DBI::errstr";
my $sql = qq{SET NAMES 'utf8';};
$dbh->do($sql) || die "Failed to set connection to utf-8";
print "Successful MySQL DB Connection\n";

## Prepare statements
$q = "SELECT niKey FROM news_index_table WHERE feedId = ? AND dateString = ?";
$gniKey_st = $dbh->prepare($q) || die $dbh->errstr;
$q = "SELECT nKey FROM news_item_table WHERE urlRoot = ? AND urlTail = ?";
$gni_st= $dbh->prepare($q) || die $dbh->errstr;
$q = "INSERT INTO news_index_table (feedId, dateString, dateStamp) VALUES (?, ?, ?)";
$inidx_st = $dbh->prepare($q) || die $dbh->errstr;
$q = "INSERT INTO news_item_table (niKey, urlRoot, urlTail, localName, title, description, author) VALUES (?, ?, ?, ?, ?, ?, ?)";
$ini_st = $dbh->prepare($q) || die $dbh->errstr;
$q = "INSERT INTO shared_news_table (niKey, nKey) VALUES (?, ?)";
$isnt_st = $dbh->prepare($q) || die $dbh->errstr;

$home   = "/var/lib";
$gna    = "$home/tomcat5.5/webapps/ROOT/news.archive";
#$home   = "/usr/local/resin/webapps/newsrack.v2";
#$gna    = "$home/ffdb.global.news.archive";
$filt   = "$gna/filtered";
opendir ARCHIVE, "$filt" || die "could not open directory $filt";
chdir $filt;
@allYears = grep !/^\.\.?/, readdir ARCHIVE;
foreach $year (@allYears) {
   next if -f $year;

   opendir YEARDIR, "$year" || die "could not open directory $year";
   chdir $year;
   @allMonths = grep !/^\.\.?/, readdir YEARDIR;
   foreach $month (@allMonths) {
      next if -f $month;

      opendir MONTHDIR, "$month" || die "could not open directory $month";
      chdir $month;
      @allDates = grep !/^\.\.?/, readdir MONTHDIR;
      foreach $day (@allDates) {
         next if -f $day;

      	opendir DATEDIR, "$day" || die "could not open directory $day";
			chdir $day;
      	@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
			foreach $src (@allSrcs) {
				$idir = "$year/$month/$day/$src";
				print "-- PROCESSING $idir\n";
				$idxF = "$src/index/index.xml";
				open INDEX, "$idxF";
				while (<INDEX>) {
					if (m{<item>}) {
						$url  = ""; $path = ""; $title = ""; $auth = ""; $desc = ""; $feedId = ""; $date = "";
					}
					elsif (m{<source id="(.*)".*>}) {
						$feedId = $1;
					}
					elsif (m{<date val="(.*)".*>}) {
						$date = $1;
					}
					elsif (m{<title val="(.*)".*>}) {
						$title = $1;
					}
					elsif (m{<author name="(.*)".*>}) {
						$auth = $1;
					}
					elsif (m{<description val="(.*)".*>}) {
						$desc = $1;
					}
					elsif (m{<url val="(.*)".*>}) {
						$url = $1;
						$url =~ s{&amp;}{&}g;
					}
					elsif (m{<localcopy path="(.*)".*>}) {
						$path = $1;
						$path =~ s{filtered/}{}g;
						$path =~ s{&amp;}{&}g;
						
					}
					elsif (m{</item>}) {
						$title = Encode::decode_utf8($title);
						$auth = Encode::decode_utf8($auth);
						$desc = Encode::decode_utf8($desc);
						&ProcessNewsItem($src, "$day.$month.$year", $feedId, $date, $title, $auth, $desc, $url, $path);
					}
				}
			}

			close DATEDIR;
			chdir "..";
		}
		close MONTHDIR;
		chdir "..";
	}
	close YEARDIR;
	chdir "..";
}
$dbh->disconnect;
exit 0;

sub GetNewsIndexKey
{
	(my $src, my $date) = ($_[0], $_[1]);
	$gniKey_st->execute($src, $date) || die $dbh->errstr;
	$val = -1;
	while (@row = $gniKey_st->fetchrow_array())  {
		$val = $row[0];
	}
	return $val;
}

sub GetNewsIndexKey_INSERT
{
	(my $src, my $date) = ($_[0], $_[1]);
	my $niKey = &GetNewsIndexKey($src, $date);
	if ($niKey == -1) {
		$ts = &GetTimeStamp($date);
		$inidx_st->execute($src, $date, $ts) || die $dbh->errstr;
		$niKey = $dbh->{'mysql_insertid'};
		print "New index entry: $niKey =  $src, $date\n";
	}
#	print "RETURNING index entry: $niKey =  $src, $date\n";
	return $niKey;
}

sub GetNewsItem
{
	(my $root, my $tail) = ($_[0], $_[1]);
	$gni_st->execute($root, $tail) || die $dbh->errstr;
	$val = -1;
	while (@row = $gni_st->fetchrow_array())  {
		$val = $row[0];
	}
	return $val;
}

sub GetTimeStamp
{
	my $date = $_[0];
	($d, $m, $y) = ($1, $2, $3) if ($date =~ /(\d+)\.(\d+)\.(\d+)/);
	$m = "0".$m if ($m < 10);
	$d = "0".$d if ($d < 10);
	return "$y$m$d"."000000";
}

sub ProcessNewsItem
{
	(my $src, my $ddir, my $feedId, my $date, my $title, my $author, my $desc, my $url, my $path) = ($_[0], $_[1], $_[2], $_[3], $_[4], $_[5], $_[6], $_[7], $_[8]);
	($urlRoot, $urlTail) = ($1, $2) if ($url =~ m{^(http://.*?/)(.*)$});
	($nDate, $nFeedId, $pathBase) = ($1, $2, $3) if ($path =~ m{^(.*)/(.*)/(.*)$});

#	print "CHECKING: <$src, $date, $title, $author, $desc, $url, $path>\n";
#	print "CHECKING: <$urlRoot, $urlTail, $nSrc, $nDate, $pathBase>\n";

		# Fetch the news index key for the news item (insert if necessary)
	$niKey = &GetNewsIndexKey_INSERT($nFeedId, $nDate);

		# Insert into the news item table
	$nKey = &GetNewsItem($urlRoot, $urlTail);
	if ($nKey == -1) {
#		$title = "CONVERT(_utf8'$title' USING utf8)";
#		$desc = "CONVERT(_utf8'$desc' USING utf8)";
#		$auth = "CONVERT(_utf8'$auth' USING utf8)";
		$ini_st->execute($niKey, $urlRoot, $urlTail, $pathBase, $title, $desc, $auth) || die $dbh->errstr;
		$nKey = $dbh->{'mysql_insertid'};
		print "New news item entry for $urlRoot, $urlTail, $pathBase\n";
	}

		# Check if the news index for the news item is different from the new index
		# to which the news item belongs!  If so, add a shared news entry.
	if (($src ne $nFeedId) || ($ddir ne $nDate) || ($feedId ne $nFeedId) || ($date ne $nDate)) {
		print "(src,ddir) - ($src,$ddir); (feedId, date) - ($feedId,$date); (nFeedId, nDate) - ($nFeedId, $nDate)\n";
		$niKey = &GetNewsIndexKey_INSERT($src, $ddir);
		$isnt_st->execute($niKey, $nKey) || die $dbh->errstr;
	}
}
