#!/usr/bin/perl

$indexFile = "index/index.xml";
chdir "global.news.archive/filtered/";
opendir ARCHIVE, "." || die "could not open directory filtered/";
@allDates = grep !/^\.\.?/, readdir ARCHIVE;
foreach $date (@allDates) {
	next if -f $date;

	print "--- DATE: $date ---\n";
	chdir $date || die "could not chdir to $date" ;
	opendir DATEDIR, "." || die "could not open directory $date";
	@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
	foreach $src (@allSrcs) {
		next if -f $src;

		print "\tSRC: $src ---\n";
		chdir $src || die "could not chdir to $src";

		rename "$indexFile.orig", "$indexFile";

		chdir "..";
	}
	close DATEDIR;
	chdir "..";
}
close ARCHIVE;
