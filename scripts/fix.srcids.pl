#!/usr/bin/perl

sub FixId
{
	local $_     = shift;
	local $oldId = shift;

	$origOldId = $oldId;

	$oldId =~ s/&amp;/\&/g;
	$oldId =~ s/&lt;/</g;
	$oldId =~ s/&gt;/>/g;
	$oldId =~ s/&quot;/"/g;
	$oldId =~ s/&apos;/'/g;

	$newId = $rmap{$oldId};
	if ($origOldId && $newId) {
		s|$origOldId|$newId|;
	}
	return $_;
}

$home = "/var/lib/tomcat5.5/webapps/ROOT";
$users = "$home/users";
$gna   = "$home/news.archive";
$orig  = "$gna/orig";
$filt  = "$gna/filtered";

## READ rename map
@rmap="";
open (RMAP, "$users/rename.map.xml") || die "cannot open $users/rename.map.xml";
while (<RMAP>) {
	if (/<rename /) {
		($old, $new) = /old="(.*)" new="(.*)"/;
		print "OLD - $old; NEW - $new\n";
		$rmap{$old} = $new;
	}
}
close RMAP;

## RENAME all index files in the archive!
$indexFile = "index/index.xml";
chdir $filt;
opendir ARCHIVE, "." || die "could not open directory $filt";

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

			print "--- DATE: $year/$month/$date ---\n";
			chdir $date || die "could not chdir to $date" ;

			opendir DATEDIR, "." || die "could not open directory $date";
			@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
			foreach $src (@allSrcs) {
				next if -f $src;
				$newSrc = $rmap{$src};
				if (!$newSrc) {
					$unchanged{$src} = 1;
					next;
				}

				print "\tSRC: $src ---\n";
				chdir $src || die "could not chdir to $src";
				open (INDEX, $indexFile);
				open (INDEXNEW, ">$indexFile.NEW");
				while (<INDEX>) {
					if (/<source /) {
						($oldId) = m{id="(.*)"};
						$_ = FixId($_, $oldId);
						print INDEXNEW;
					}
					elsif (/<localcopy /) {
						($oldId) = m{path=".*?/(.*?)/.*"};
						$_ = FixId($_, $oldId);
						print INDEXNEW;
					}
					else {
						print INDEXNEW;
					}
				}
				close INDEX;
				close INDEXNEW;

				rename "$indexFile", "$indexFile.ORIG";
				rename "$indexFile.NEW", "$indexFile";

				chdir "..";
			
				print "Rename $src to $newSrc\n";
				rename $src, $newSrc;
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
close ARCHIVE;

## Change directory back to root
chdir "$gna";

## Print list of unchanged sources!
open (UNCH, ">unchanged.srcs");
foreach $src (keys %unchanged) {
	print UNCH "Unchanged -- $src\n";
}
close UNCH;

## RENAME the cache.file
$cacheFile = "cache.xml";
open (CACHE, $cacheFile);
open (CACHENEW, ">$cacheFile.NEW");
while (<CACHE>) {
	if (/<item /) {
		($oldId) = m{path=".*?/(.*?)/.*"};
		$_ = FixId($_, $oldId);
		print CACHENEW;
	}
	else {
		print CACHENEW;
	}
}
close CACHE;
close CACHENEW;
rename "$cacheFile", "$cacheFile.ORIG";
rename "$cacheFile.NEW", "$cacheFile";

## Fix all categorized news index files
chdir $users;
opendir USERS, "." || die "could not open directory ./";
@allUsers = grep !/^\.\.?/, readdir USERS;
foreach $user (@allUsers) {
	next if -f $user;
	next if (!(-d "$user/issues"));

	print "PROCESSING USER $user\n";
	open (NFILES, "find $user/issues -name news.xml |");
	while (<NFILES>) {
		chop;
		$newsFile = $_;
		print "\t--> news.xml file $newsFile\n";
		open (INDEX, $newsFile);
		open (INDEXNEW, ">$newsFile.NEW");
		while (<INDEX>) {
			if (/<source /) {
				($oldId) = m{id="(.*)"};
				$_ = FixId($_, $oldId);
				print INDEXNEW;
			}
			elsif (/<localcopy /) {
				($oldId) = m{path=".*?/(.*?)/.*"};
				$_ = FixId($_, $oldId);
				print INDEXNEW;
			}
			else {
				print INDEXNEW;
			}
		}
		close INDEX;
		close INDEXNEW;
		rename "$newsFile", "$newsFile.ORIG";
		rename "$newsFile.NEW", "$newsFile";
	}
	close NFILES;
}
close USERS;
