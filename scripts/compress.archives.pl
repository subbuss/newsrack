#!/usr/bin/perl

# import packages
use File::Copy;

$numargs  = @ARGV;
$YEAR     = @ARGV[0] if $numargs > 0;
$MONTH    = @ARGV[1] if $numargs > 1;
$D_REGEXP = @ARGV[2] if $numargs > 2;

#$gna  = "/data/newsrack/archive.test";
$gna  = "/home/newsrack/data/news.archive";
$gna2 = $gna;
$gna2 =~ s{^/}{};
$orig = "$gna/orig";

opendir ARCHIVE, "$orig" || die "could not open directory $orig";
chdir $orig;
@allYears = grep !/^\.\.?/, readdir ARCHIVE;
foreach $year (@allYears) {
	next if -f $year;
#	print "got $year; testing against $YEAR\n";
	next if $YEAR && !($year == $YEAR);

	print "--- YEAR: $year ---\n";

	opendir YEARDIR, "$year" || die "could not open directory $year";
	chdir $year;
	@allMonths = grep !/^\.\.?/, readdir YEARDIR;
	foreach $month (@allMonths) {
		next if -f $month;
#		print "got $month; testing against $MONTH\n";
		next if $MONTH && !($month == $MONTH);

		print "--- MONTH: $month ---\n";

		opendir MONTHDIR, "$month" || die "could not open directory $month";
		chdir $month;
		@allDates = grep !/^\.\.?/, readdir MONTHDIR;
		foreach $date (@allDates) {
			next if -f $date;
#		   print "got $date; testing against $D_REGEXP\n";
 			next if $D_REGEXP && !($date =~ /$D_REGEXP/);

			print "--- DATE: $date ---\n";
			chdir $date || die "could not chdir to $date" ;

			opendir DATEDIR, "." || die "could not open directory $date";
			@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
         system("tar xzf home.tgz") if -f "home.tgz";
			foreach $src (@allSrcs) {
            next if ($src =~ /^home$/);
            next if ($src =~ /^var$/);
            if (-f "$src") {
               $src =~ s/.tgz//g;

						# DUE TO SOME BUGS IN EARLIER VERSION OF THE SCRIPT
               $x = "$gna2/orig/$year/$month/$date";
               if (-d "$x/$gna2/orig/$year/$month/$date/$src") {
                  system("mkdir -p \'$src\'; mv $x/$gna2/orig/$year/$month/$date/$src/* $src");
                  system("rm -rf $x/$gna2/orig/$year/$month/$date/$src");
#                  print "EXEC: cd $orig/$year/$month/$date; tar czf \'$src.tgz\' \'$src\'\n";
                  system("cd $orig/$year/$month/$date; tar czf \'$src.tgz\' \'$src\'");
#                  print "EXEC: rm -rf \'$orig/$year/$month/$date/$src\'\n" ;
                  system("rm -rf \'$orig/$year/$month/$date/$src\'");
               }
            }
            else {
               print "\tSRC: $src ---\n";

               if (-f "$src.tgz") {
                  system("tar xzf \'$src.tgz\'; rm -f \'$src.tgz\'");

							# DUE TO SOME BUGS IN EARLIER VERSION OF THE SCRIPT
						if (-d "$gna2/orig$year/$month/$date/$src") {
							system("mv \'$gna2/orig/$year/$month/$date/$src/*\' \'$src\'");
							system("rm -rf \'$gna2/orig/$year/$month/$date/$src\'");
							$x = "$gna2/orig/$year/$month/$date";
							if (-d "$x/$gna2/orig/$year/$month/$date/$src") {
								system("mv \'$x/$gna2/orig/$year/$month/$date/$src/*\' \'$src\'");
								system("rm -rf \'$x/$gna2/orig/$year/$month/$date/$src\'");
							}
						}
               }

                  # Compress the original articles into its new destination
#               print "EXEC: cd $orig/$year/$month/$date; tar czf \'$src.tgz\' \'$src\'\n";
               system("cd $orig/$year/$month/$date; tar czf \'$src.tgz\' \'$src\'");
#               print "EXEC: rm -rf \'$orig/$year/$month/$date/$src\'\n" ;
               system("rm -rf \'$orig/$year/$month/$date/$src\'");
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
