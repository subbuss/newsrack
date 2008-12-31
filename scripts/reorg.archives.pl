#!/usr/bin/perl

# import packages
use File::Copy;

$home    ="/services/floss/fellows/subbu";
#$home    ="/usr/local";
$gna     ="$home/resin/webapps/newsrack/global.news.archive";
$orig    ="$gna/orig";
$filtered="$gna/filtered";

mkdir $orig;
mkdir $filtered;

opendir ARCHIVE, "$gna" || die "could not open directory $gna";
chdir $gna;
@allDates = grep !/^\.\.?/, readdir ARCHIVE;
foreach $date (@allDates) {
	next if -f $date;
	next if ($date =~ /orig/);
	next if ($date =~ /filtered/);

	print "--- DATE: $date ---\n";
	chdir $date || die "could not chdir to $date" ;
	mkdir "$orig/$date";
	mkdir "$filtered/$date";

	opendir DATEDIR, "." || die "could not open directory $date";
	@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
	foreach $src (@allSrcs) {
		next if -f $src;

		print "\tSRC: $src ---\n";
		chdir $src || die "could not chdir to $src";
			# Create the new destination directories
		mkdir "$filtered/$date/$src";
		mkdir "$filtered/$date/$src/index";

			# Compress the original articles into its new destination
		if (-d "orig/") {
			rename("orig/", "$src");
			system("tar czf $orig/$date/$src.tgz $src");
			rename("$src", "orig/");
		}

			# Move the filtered article to their new destination
		chdir "filtered/";
		opendir FILTDIR, "." || die "could not open directory filtered";
		@allfiles = grep !/^\.\.?/, readdir FILTDIR;
		foreach $f (@allfiles) {
			next if -d $f;
			rename("$f", "$filtered/$date/$src/$f");
#			copy("$f", "$filtered/$date/$src/$f");
		}
		close FILTDIR;
		chdir "..";
			# Remove the old organization
		system("rm -rf orig/ filtered/");
			# Move the index files to their new destination
		opendir DIR, "." || die "could not open directory filtered";
		@allfiles = grep !/^\.\.?/, readdir DIR;
		foreach $f (@allfiles) {
			next if -d $f;
			rename("$f", "$filtered/$date/$src/index/$f");
#			copy("$f", "$filtered/$date/$src/index/$f");
		}
		close DIR;

		chdir "..";
	}
	close DATEDIR;
	chdir "..";
}
close ARCHIVE;
