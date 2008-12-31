#!/usr/bin/perl

# import packages
use File::Copy;

#$home = "/services/floss/fellows/subbu";
#$orig = "$gna/orig";
#$home = "/usr/local";
#$gna  = "$home/resin/webapps/newsrack/global.news.archive";
$home = "/var/lib";
$gna  = "$home/tomcat5.5/webapps/ROOT/news.archive";
$filt = "$gna/filtered";

$numArticles   = 0;
$numUnique     = 0;
$numFiles      = 0;
$numMissing    = 0;

%articles = "";

#open DLOG, ">/tmp/duplicates.log.TEST" || die "could not open log file for output";
#open MLOG, ">/tmp/missing.log.TEST" || die "could not open log file for output";
open DLOG, ">/tmp/duplicates.log" || die "could not open log file for output";
open MLOG, ">/tmp/missing.log" || die "could not open log file for output";
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
      foreach $date (@allDates) {
         next if -f $date;

      	opendir DATEDIR, "$date" || die "could not open directory $date";
			chdir $date;
      	@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
			foreach $src (@allSrcs) {
				$idir = "$year/$month/$date/$src";
				print "-- PROCESSING $idir\n";
				$if1 = "$src/index/index.xml";
#				$if2 = "$src/index/index.xml.NODUP";
				$if2 = "adsbsdfm";
				if (-f $if2) {
					$idxf = $if2;
				}
				else {
					$idxf = $if1;
				}
				open INDEX, "$idxf";
				while (<INDEX>) {
					if (m{<item>}) {
						$url  = "";
						$path = "";
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
						$numArticles++;
						$str = $idir."##".$path;
						if ($articles{$url}) {
							$firstEntry = @{$articles{$url}}[0];
							($fd, $fs, $flp) = ($1, $2, $3) if ($firstEntry =~ m{(\d+/\d+/\d+)/(.*)##(.*)});
								## If the localcopy path is the same as the existing entry,
								## then the new index entry is simply pointing to the existing entry
								## and is not really a duplicate!
							if ($path ne $flp) {
								push(@{$articles{$url}}, $str);
								$indexEntries{$path} = "1";
#								$indexEntries{$path} = $url;
#								print MLOG "Adding path $path = $url\n";
							}
						}
						else {
							$numUnique++;
							$articles{$url} = [ ($str) ];
						}
					}
				}

					## Check if index entries exists for all files
				opendir SRCDIR, "$src" || die "could not open directory $src";
				@allFiles = grep !/^\.\.?/, readdir SRCDIR;
				foreach $f (@allFiles) {
					next if !(-f "$src/$f");

					$numFiles++;
					$p = "$date.$month.$year/$src/$f";
					if (!$indexEntries{$p}) {
						$numMissing++;
						print MLOG "MISSING Index entry for file $p in $idir/index/index.xml\n";
					}
				}
				close SRCDIR;
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

my $u = 0;
my $a = 0;
my $skipped = 0;
my $numSkipped = 0;
my $numDuplicates = 0;
foreach my $url (keys %articles) {
	print "-- PROCESSING $url\n";
	$a++;
	my @urlStrs = @{$articles{$url}};
	my $numEntries = @urlStrs;
	if ($numEntries > 1) {
		$minDS = 99999999;
		$minE  = "";
		foreach my $e (@urlStrs) {
			$dir = ""; $path = "";
			$d = ""; $m = ""; $y = "";
				# Extract directory and path for the entry
			($dir, $path) = ($1, $2) if ($e =~ m{^(.*)##(.*)$});
				# Extract date string from the path
			($d, $m, $y) = ($1,$2,$3) if ($path =~ m{(\d+)\.(\d+)\.(\d+)/.*});
			$m = "0".$m if ($m < 10);
			$d = "0".$d if ($d < 10);
			$ds = $y.$m.$d;
				# Check if this entry has been added before others seen so far!
			if ($ds < $minDS) {
				$minDS = $ds;
				$minE  = $e;
			}
		}

		if (!$url || ($url =~ /dailypioneer/) || ($minE =~ /breaking.news/)) {
			$skipped += @urlStrs;
			$numSkipped++;
		}
		else {
			print DLOG "##############\n";
			print DLOG "URL: $url\n";
			print DLOG "RETAIN: $minE\n";
			foreach my $e (@urlStrs) {
				if ($e ne $minE) {
					print DLOG "DEL: $e\n";
					$numDuplicates++;
				}
			}
		}
	}
	else {
		$u++;
	}
}

print DLOG "Total items              - $numArticles\n";
print DLOG "Total unique URLs        - ($numUnique, $a) \n";
print DLOG "Total URLs with 1 entry  - $u\n";
print DLOG "Total duplicate articles - $numDuplicates\n";
$x = $skipped + $numDuplicates + $a;
print DLOG "TEST: x - $x; numSkipped - ($numSkipped, $skipped)\n";

print MLOG "Total files found     - $numFiles\n";
print MLOG "Total entries missing - $numMissing\n";

close DLOG;
close MLOG;
