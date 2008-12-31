#!/usr/bin/perl

# import packages
use Cwd;
use File::Copy;

$home    ="/services/floss/fellows/subbu";
$gna     ="$home/resin/webapps/newsrack/global.news.archive";
$filt    ="$gna/filtered";

opendir ARCHIVE, "$filt" || die "could not open directory $filt";
chdir $filt;
@allDates = grep !/^\.\.?/, readdir ARCHIVE;
foreach $date (@allDates) {
	next if -f $date;
	$_ = $date;
	next if !(/[23][0-9].5.2006/ || /1[89].5.2006/ || /.[67].2006/ || /^[1-8].8.2006/);
	next if (/26.6.2006/ || /28.6.2006/);

	print "--- DATE: $date ---\n";
	chdir $date || die "could not chdir to $date" ;

	opendir DATEDIR, "." || die "could not open directory $date";
	@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
	foreach $src (@allSrcs) {
		next if -f $src;
		next if !(($src =~ /fe.crawler/) || ($src =~ /fe_frontpage/));

		print "\tSRC: $src ---\n";
		chdir $src || die "could not chdir to $src" ;

			## NOW, process the files!
#		open (INDEX, "index/index.xml");
#		while (<INDEX>) {
#				# <localcopy path="8.7.2006/51.fe.crawler/ni5.fe_full_story.php_content_id=133166" />
#			if (m{localcopy path="$date/$src/(ni\d+).(.*)"}) {
#				$file = "$1\.$2";
#				($f1 = $2) =~ s/php_/php?/g;
#				$url = "http://www.financialexpress.com/$f1";
#				print "file is $file\n";
#				print "url is $url\n";
#				system("java news_rack.archiver.HTMLFilter -o /tmp/ -u $url");
#				system("mv '/tmp/$f1' $file");
#			}
#		}
#		close INDEX;

		$tgz = "$src.tgz";
		$osrc = $src;
		if (!copy("../../../orig/$date/$src.tgz", $tgz)) {
			if ($src =~ /fe.crawler/) {
				$osrc = "fe.crawler";
			}
			else {
				$osrc = "fe_frontpage";
			}
			$tgz = "$osrc.tgz";
			copy("../../../orig/$date/$tgz", $tgz) || warn("Could not copy $tgz"); 
		}
		sleep 2;
		system("tar xvzf $tgz");
		$mydir = getcwd;
		print "current directory is $mydir\n";
		$dtC = `find services/ -type d | tail -1`;
		chop $dtC;
		print "dtc is ##$dtC##\n";
		chdir $dtC || warn "could not change to dir $dtC";
		opendir ORIG, "." || die "could not open directory .";
		@allFiles = grep !/^\.\.?/, readdir ORIG;
		foreach $file (@allFiles) {
			next if !(-f $file);

			print "will process $file now ..... ";
			($n, $f) = ($file =~ /(ni\d+).(.*)/);
			($f1 = $f) =~ s/php_/php?/g;
			$url = "http://www.financialexpress.com/$f1";
			print "url is $url\n";
			system("java news_rack.archiver.HTMLFilter -o /tmp/ -url $url $file");
			system("mv '/tmp/$file' '$mydir/$file'");
		}

			## Move back!
		chdir "$mydir" or warn "could not change back to $mydir\n";
		system("rm -rf $tgz services/");

		sleep 2;
		chdir "..";
	}
	close DATEDIR;
	chdir "..";
}
close ARCHIVE;
