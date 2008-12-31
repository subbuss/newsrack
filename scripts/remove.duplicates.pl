#!/usr/bin/perl

use strict;

# import packages
use File::Copy;

#$home = "/services/floss/fellows/subbu";
#my $home = "/usr/local";
#my $gna  = "$home/resin/webapps/newsrack/global.news.archive";
#$orig = "$gna/orig";
my $home = "/var/lib";
my $gna  = "$home/tomcat5.5/webapps/ROOT/news.archive";
my $filt = "$gna/filtered";

my %filesToFix = ();
my $url = "";
open DLOG, "/tmp/duplicates.log" || die "could not open duplicates file";
while (<DLOG>) {
	if (/URL:\s*(http.*)$/) {
		$url = $1;
	}
## Now remove $url with path $localCopy from file $idxFile
	if (/DEL:\s*(.*)##(.*)$/) {
		my $idxFile   = $1;
		my $localCopy = $2;
		print "... IDX: $idxFile ...\n";
		my $delString = "$url##$localCopy";
		$delString =~ s{filtered/}{}g;
		$delString =~ s{&amp;}{\&}g;
		if ($filesToFix{$idxFile}) {
			my $n = @{$filesToFix{$idxFile}};
			print "2## [$n] Added $delString\n";
			push(@{$filesToFix{$idxFile}}, $delString);
		}
		else {
			print "1## Added $delString\n";
			$filesToFix{$idxFile} = [ ($delString) ];
		}
	}
}
close DLOG;

chdir $filt;
my $skipme = "";
my $url    = "";
for my $idxFile (keys %filesToFix) {
	print "******** PROCESSING $idxFile ******* \n";
	open IDX, "$idxFile/index/index.xml";
	open NEWIDX, ">$idxFile/index/index.xml.NODUP" || warn "ERROR ERROR ERROR .. cannot open file $idxFile NODUP\n";
	my $buf = "";
	while (<IDX>) {
		if (m{<item>}) {
			if (!($buf =~ /^\s*$/)) {
				print NEWIDX $buf;
#				print "4## Adding $buf to NODUP file\n";
			}
			$buf = $_;	## INIT
		}
		elsif (m{<url val="(.*)".*>}) {
			$buf .= $_;
			$url = $1;
		}
		elsif (m{<localcopy path="(.*)".*>}) {
			$buf .= $_;
			my $path = $1;
			my $tocheck = "$url##$path";
			$tocheck =~ s{filtered/}{}g;
			$tocheck =~ s{&amp;}{\&}g;
			$tocheck =~ s{\?}{\\?}g;
#			print "3## $tocheck -- ";
#			print "CHECKING in @{$filesToFix{$idxFile}}\n";
			if (grep /^$tocheck$/, @{$filesToFix{$idxFile}}) {
#				print "found it!\n"; 
				$skipme = "1";
				print "#### For $url, removing $path ####\n";
			}
			else {
#				print "NOT PRESENT\n"; 
			}
		}
		elsif (m{</item>}) {
			if ($skipme) {
				$buf = "";
				$skipme = "";
			}
			else {
				$buf .= $_;
			}
		}
		else {
			$buf .= $_;
		}
	}
	print NEWIDX $buf;
	close IDX;
	close NEWIDX;
}
