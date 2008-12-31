#!/usr/bin/perl

sub MakeDir()
{
	my $dir = $_[0]; 
	if (!(-d "$dir")) {
		mkdir("$dir") || die "cannot make $dir";
	}
}

sub InitIndex()
{
	my $dir = $_[0]; 
	$indexDir  = "$dir/index";
	$indexFile = "$indexDir/index.xml";
	&MakeDir($indexDir);
	if (!(-f $indexFile)) {
		open(INDEX, ">$indexFile");
		print INDEX "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
		print INDEX "<news>\n";
		close INDEX;
	}
}

sub AddItemToIndex()
{
	my $dir   = $_[0];
	my $date  = $_[1];
	my $url   = $_[2];
	my $lpath = $_[3];

	$url   = &MakeXMLFriendly($url);
	$lpath = &MakeXMLFriendly($lpath);
	$title = &MakeXMLFriendly($title);

	$indexDir  = "$dir/index";
	$indexFile = "$indexDir/index.xml";
	&MakeDir($indexDir);
	open(INDEX, ">>$indexFile");
	print INDEX "\t<item>\n";
	print INDEX "\t\t<source id=\"48.bs.crawler\" />\n";
	print INDEX "\t\t<date val=\"$date\" />\n";
	print INDEX "\t\t<title val=\"$title\" />\n";
	print INDEX "\t\t<description val=\"$title\" />\n";
	print INDEX "\t\t<url val=\"$url\" />\n";
	print INDEX "\t\t<localcopy path=\"$lpath\" />\n";
	print INDEX "\t</item>\n";
	close INDEX;
}

sub MakeXMLFriendly
{
   local $_ = shift;

   s/(\x91|\x92)/'/g;
   s/(\x93|\x94)/"/g;
   s/(\x95)//g;
   s/(\x96)/-/g;
   s/&/&amp;/g;
   s/</&lt;/g;
   s/>/&gt;/g;
   s/"/&quot;/g;
   s/'/&apos;/g;

   return $_;
}

%monthMap = (
	"January"   => 1, 
	"Jan"       => 1, 
	"February"  => 2, 
	"Feb"       => 2, 
	"March"     => 3, 
	"Mar"       => 3, 
	"April"     => 4, 
	"Apr"       => 4, 
	"May"       => 5, 
	"June"      => 6, 
	"Jun"       => 6, 
	"July"      => 7, 
	"Jul"       => 7, 
	"August"    => 8, 
	"Aug"       => 8, 
	"September" => 9, 
	"Sep"       => 9, 
	"October"   => 10, 
	"Oct"       => 10, 
	"November"  => 11, 
	"Nov"       => 11, 
	"December"  => 12, 
	"Dec"       => 12, 
);

open (BSREAD, "all.bs.url.numbers");
while (<BSREAD>) {
	chop;
	$artId{$_} = $_;
}
close BSREAD;

#$start = 97007;
#$end   = 99200;
#$start = 99201;
#$end   = 103201;
$start   = 220000;
$end     = 221514;
#$start   = 221514;
#$end     = 224113;
$id      = $start;
$urlBase = "http://www.business-standard.com/general/storypage.php?autono=";
while ($id < $end) {
	if ($artId{$id}) {
		print "PRESENT .. Skipping $id\n";
	}
	else {
		$url      = $urlBase.$id;
		$filename = $url;
		$filename =~ s{(.*/)*}{};
		$filename =~ s{\?}{_};
		system("wget '$url' -O $filename");
		print "filename is $filename\n";
		$gotDate  = 0;
		$gotTitle = 0;
		$skip     = 0;
		open (ART, "$filename") || die "cannot open $filename";
		while (<ART>) {
			last if (($gotDate == 1) && ($gotTitle == 1));

				# check if this is a non-existent article
			if (/Sorry\s*News\s*Not\s*Av..lable/i) {
				print "Sorry News Not Available for $id ... ";
				unlink($filename);
				$skip = 1;
				last;
			}

				# check for "<td class=author> ... </td>" for date of article
			if (/<td class=author>/) {
				$dateline = $_;
				($month, $date, $year) = ($dateline =~ m{<td class=author>.*?\&nbsp;(.*?)\s*(\d+)\s*,\s*(\d+).*});
				print "Month is $month; Date is $date; Year is $year ... ";
				if ($year != 2006) {
					$skip = 1;
					last;
				}
				$date =~ s/^0*//;
				$dateStr    = "$date.$monthMap{$month}.$year";
				$pathPrefix = "$dateStr/48.bs.crawler";
				if (!($x = $artCount{$dateStr})) {
					$x = 1;
				}
				$artCount{$dateStr} = $x+1;
				$pathString = "$pathPrefix/ni$x.$filename";
				print "\ndate string is $dateStr\n";
				print "path string is $pathString\n";
				&MakeDir("orig/$dateStr");
				&MakeDir("filtered/$dateStr");
				&MakeDir("orig/$pathPrefix");
				&MakeDir("filtered/$pathPrefix");
				&InitIndex("filtered/$pathPrefix");
				$gotDate = 1;
			}
			if (/<td class=heading>/) {
				($title) = ($_ =~ m{<td class=heading>(.*?)</td>}i);
				$gotTitle = 1;
			}
		}
		close ART;

		if ($skip == 0) {
			$origDestFile = "orig/$pathString";
			$filtDestFile = "filtered/$pathString";
			rename($filename, $origDestFile) || die "cannot rename $filename to $origDestFile";
			$cmd = "java news_rack.archiver.HTMLFilter -o filtered/$pathPrefix -url $url $origDestFile";
			system($cmd);
			&AddItemToIndex("filtered/$pathPrefix", $dateStr, $url, $filtDestFile);
		}
		else {
			print "SKIPPING ... \n";
			unlink($filename);
		}
	}
	$id++;
}

foreach $key (keys %artCount) {
	$indexFile = "filtered/$key/48.bs.crawler/index/index.xml";
	print "INDEX file is $indexFile\n";
	open(INDEX, ">>$indexFile") || die "cannot open $indexFile";
	print INDEX "</news>\n";
	close INDEX;
}
