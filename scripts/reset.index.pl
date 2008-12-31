#!/usr/bin/perl

$home = "/var/lib/tomcat5.5";
$gna  = "$home/webapps/ROOT/news.archive";
$filt = "$gna/filtered";

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

			print "--- DATE: $date ---\n";
			chdir $date || die "could not chdir to $date" ;

			opendir DATEDIR, "." || die "could not open directory $date";
			@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
			foreach $src (@allSrcs) {
				next if -f $src;
				print "\tSRC: $src ---\n";

					# Compress the original articles into its new destination
				if (chdir "$src/index") {
					if (-f "index.xml.NODUP") {
						rename "index.xml", "index.xml.old";
						rename "index.xml.NODUP", "index.xml";
					}
					chdir "../..";
				}
				else {
					warn "could not chdir to $src/index";
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
