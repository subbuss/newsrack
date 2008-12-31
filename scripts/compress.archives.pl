#!/usr/bin/perl

# import packages
use File::Copy;

$gna  = "/home/newsrack/data/news.archive";
$orig = "$gna/orig";

opendir ARCHIVE, "$orig" || die "could not open directory $orig";
chdir $orig;
@allYears = grep !/^\.\.?/, readdir ARCHIVE;
foreach $year (@allYears) {
	next if -f $year;
	next if !($year =~ 2008);

	opendir YEARDIR, "$year" || die "could not open directory $year";
	chdir $year;
	@allMonths = grep !/^\.\.?/, readdir YEARDIR;
	foreach $month (@allMonths) {
		next if -f $month;
		next if !($month =~ 12);

		opendir MONTHDIR, "$month" || die "could not open directory $month";
		chdir $month;
		@allDates = grep !/^\.\.?/, readdir MONTHDIR;
		foreach $date (@allDates) {
			next if -f $date;
 			next if !(($date =~ /^[1-9]$/));

			print "--- DATE: $date ---\n";
			chdir $date || die "could not chdir to $date" ;

			opendir DATEDIR, "." || die "could not open directory $date";
			@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
			foreach $src (@allSrcs) {
            next if ($src =~ /var/);
            if (-f "$src") {
               $src =~ s/.tgz//g;
               if (-d "var/lib/tomcat5.5/webapps/ROOT/news.archive/orig/$year/$month/$date/$src") {
                  print "NEW SRC: $src\n";
                  system("tar xzf $src.tgz");
                  system("mkdir -p $src; mv var/lib/tomcat5.5/webapps/ROOT/news.archive/orig/$year/$month/$date/$src/* $src; rm -rf var/lib/tomcat5.5/webapps/ROOT/news.archive/orig/$year/$month/$date/$src");
                  print "EXEC: tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'\n";
                  system("tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'");
                  print "EXEC: rm -rf $orig/$year/$month/$date/$src\n" ;
                  system("rm -rf '$orig/$year/$month/$date/$src'");
               }
            }
            else {
         #		next if !(($src =~ /fe_frontpage/) || ($src =~ /fe.crawler/));
         #		next if !($src =~ /at.crawler/);
               print "\tSRC: $src ---\n";

               if (-f "$src.tgz") {
                  system("tar xzf $src.tgz");
                  system("mv var/lib/tomcat5.5/webapps/ROOT/news.archive/orig/$year/$month/$date/$src/* $src");
                  system("rm -rf var/lib/tomcat5.5/webapps/ROOT/news.archive/orig/$year/$month/$date/$src");
               }

                  # Compress the original articles into its new destination
               print "EXEC: tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'\n";
               system("tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'");
               print "EXEC: rm -rf $orig/$year/$month/$date/$src\n" ;
               system("rm -rf '$orig/$year/$month/$date/$src'");
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
close ARCHIVE;
