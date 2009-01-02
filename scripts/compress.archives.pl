#!/usr/bin/perl

# import packages
use File::Copy;

$gna  = "/home/newsrack/data/news.archive";
$gna2 = "home/newsrack/data/news.archive";
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
#		next if -f $month;
		next if !($month =~ 7);

		opendir MONTHDIR, "$month" || die "could not open directory $month";
		chdir $month;
		@allDates = grep !/^\.\.?/, readdir MONTHDIR;
		foreach $date (@allDates) {
			next if -f $date;
# 			next if !($date =~ /^2?[0-6]$/);

			print "--- DATE: $date ---\n";
			chdir $date || die "could not chdir to $date" ;

			opendir DATEDIR, "." || die "could not open directory $date";
			@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
         system("tar xzf home.tgz") if -f "home.tgz";
			foreach $src (@allSrcs) {
            next if ($src =~ /home/);
            if (-f "$src") {
               $src =~ s/.tgz//g;
               $x = "$gna2/orig/$year/$month/$date";
               $y = "$x";
               if (-d "$y/$gna2/orig/$year/$month/$date/$src") {
                  print "NEW SRC: $src\n";
                  system("mkdir -p $src; mv $y/$gna2/orig/$year/$month/$date/$src/* $src");
                  system("rm -rf $y/$gna2/orig/$year/$month/$date/$src");
                  print "EXEC: tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'\n";
                  system("tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'");
                  print "EXEC: rm -rf $orig/$year/$month/$date/$src\n" ;
                  system("rm -rf '$orig/$year/$month/$date/$src'");
               }
            }
            else {
               print "\tSRC: $src ---\n";

               if (-f "$src.tgz") {
                  system("tar xzf $src.tgz; rm -f $src.tgz");
                  system("mv $gna2/orig/$year/$month/$date/$src/* $src");
                  system("rm -rf $gna2/orig/$year/$month/$date/$src");
                  system("mv $y/$gna2/orig/$year/$month/$date/$src/* $src");
                  system("rm -rf $y/$gna2/orig/$year/$month/$date/$src");
               }

                  # Compress the original articles into its new destination
               print "EXEC: tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'\n";
               system("tar czf '$orig/$year/$month/$date/$src.tgz' '$orig/$year/$month/$date/$src'");
               print "EXEC: rm -rf $orig/$year/$month/$date/$src\n" ;
               system("rm -rf '$orig/$year/$month/$date/$src'");
            }
			}
         system("rm -rf home; rm -f xzf home.tgz") if -d "home";
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
