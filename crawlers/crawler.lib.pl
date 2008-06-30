sub GetRFC822Date
{
   use DateTime;
   use DateTime::Format::Mail;

   my $dt = DateTime->new(year => $_[0], month => $_[1], day => $_[2]);
   my $str = DateTime::Format::Mail->format_datetime($dt);
   return $str;
}

sub FIX_URL
{
	local $_ = shift;

	s{http://uni.medhas.org/unicode.php5\?file=}{}g;
	s{%26}{\&}g;
	s{%2C}{,}g;
	s{%2F}{/}g;
	s{%3A}{:}g;
	s{%3D}{=}g;
	s{%3F}{?}g;

	return $_;
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

# -- Download a page from a specified URL
sub GetPage
{
   use LWP;
   use LWP::Simple;
   my $url      = $_[0];
   my $fileName = $1 if ($url =~ m{.*/(.*)$}i);
#   @hdrs = head($url);
#   print "HEADERS LENGTH - $#hdrs\n";
#   ($ctype, $len, $lastModTime, $expires, $server) = @hdrs;
#   $currTime = time();

	if (!$fileName) {
		$fileName = "file.htm";
	}

   $browser = LWP::UserAgent->new();
   $browser->agent("NewsRack/1.0");
   $webpage = $browser->request(new HTTP::Request GET => $url);
   if ($webpage->is_success) {
      $count++;
      open (OUT, ">$fileName");
#     print     "Storing in file $fileName\n";
      print LOG "Storing in file $fileName\n";
      print OUT $webpage->content;
      close OUT;
      return $fileName;
   }
   else {
      print     ($webpage->message)."; Bad luck\n";
      print LOG ($webpage->message)."; Bad luck\n";
      return "";
   }
}

sub ExtractString
{
   my $fileName = $_[0];
	my $startTag = $_[1];
	my $endTag   = $_[2];

   open (FILE, "<$fileName");
	$fullString = "";
	while (<FILE>) {
			# Get the title of the page
		if (m|$startTag|i) {
			do {
				chop;
				$fullString.= $_." ";
				last if (m|$endTag|i);
			} while ($_ = <FILE>);
## PERL BUG??? Control does not reach here in case the
## above loop is never executed beyond the 1st iteration!
			last;
		}
	}
	$fullString =~ s/\s+/ /g;
   close FILE;

		## Extract the 'string' from the full string
	my $string = $1 if ($fullString =~ m{$startTag(.*?)$endTag}i);
#	print "fullString - $fullString; string - $string\n";

   return $string;
}

sub ReadTitleAndDesc
{
   my $url       = $_[0];
	my $tStartTag = $_[1];
	my $tEndTag   = $_[2];
	my $dStartTag = $_[3];
	my $dEndTag   = $_[4];

   $fileName = &GetPage($url);

   $title = &ExtractString($fileName, $tStartTag, $tEndTag);
   $desc = &ExtractString($fileName, $dStartTag, $dEndTag);

	@fAttrs = stat $fileName;
	$totalBytes += $fAttrs[7];
   unlink $fileName;

   return ($title, $desc);
}

sub ReadTitle
{
   my $url      = $_[0];
	my $startTag = $_[1];
	my $endTag   = $_[2];
	if (!$startTag) {
		$startTag = "<title>";
		$endTag   = "</title>";
	}

   $fileName = &GetPage($url);

   $title = &ExtractString($fileName, $startTag, $endTag);

	@fAttrs = stat $fileName;
	$totalBytes += $fAttrs[7];
   unlink $fileName;

	return $title;
}

sub ChangeWorkingDir
{
	$scriptPath = $0;
	$scriptDir  = $1 if ($scriptPath =~ m{(.*)/(.*)});
	if (!$scriptDir) {
		$scriptDir = ".";
	}
	$dir = `pwd`;
	chop $dir;
	print "scriptPath   - $scriptPath\n";
	print "scriptDir    - $scriptDir\n";
	print "currDir      - $dir\n";
	chdir($scriptDir);
	print "CHANGED Working directory to $scriptDir\n";
}

sub Initialize
{
	local $encoding = $_[0];
	local $startUrl = $_[1];
	local $date     = $_[2];	## OPTIONAL!

	print "Encoding is #$encoding#\n";
	print "startURL is #$startUrl#\n";

	if ($encoding =~ /utf8/) {
			## Set stdout to be outputting utf-8 data
		binmode STDOUT, ":utf8";
			## Open the log file
		open(LOG, ">:encoding(utf8)", "$prefix.logfile") || warn "cannot open utf8 log file $prefix.logfile";
	}
	else {
		open(LOG, ">$prefix.logfile") || warn "cannot open log file $prefix.logfile";;
	}

		## Output the RSS header
	$currDir = `pwd`;
	chop $currDir;
	$home    = "$currDir/../../crawled.feeds";
   $rssFile = "$prefix.rss.xml";
	$tmpRSS  = "$home/$rssFile.tmp";
	if (!$date) {
	   $date = `date -R`;
	   chop $date;
	}
	if ($encoding =~ /utf8/) {
		open (RSS, ">:encoding(utf8)", $tmpRSS) || die "cannot open UTF-8 RSS file - $tmpRSS\n";
		&PrintRSSHeader("utf-8");
	}
	else {
		open (RSS, ">$tmpRSS") || die "cannot open RSS file - $tmpRSS\n";
		&PrintRSSHeader();
	}

		## Initialize
	$count      = 0;
	$totalBytes = 0;
	$links      = "";
	$total      = 0;
	$processed  = 0;

		## Add any top-level urls to start crawling.
	$urlList[0] = $startUrl;
	$urlList[scalar(@urlList)] = $startUrl;
	$links{$startUrl} = "ROOT";
	$rootURL     = $startUrl;
	print "ROOT URL - $startUrl\n";
}

sub OpenArtNumFile
{
	$defaultStart = $_[0];
	if (!$defaultStart) {
		$defaultStart = 1000;
	}

## In the file, the max-art-id from previous 2 runs of crawling is stored
## say, run(k-1) and run(k-2), where run(k-1) is more recent than run(k-2).
##
## So, when the script is run again, run(k), max-art-id from run(k-2) is used to
## seed the starting id for run(k)
##
## At the end, the script stores max-art-id from run(k) and run(k-1) in this file
##
	if (-f "$prefix.lastfetched") {
		open(ARTNUM, "<$prefix.lastfetched");
		$artnum1 = <ARTNUM>;
		chop $artnum1;
		$artnum2 = <ARTNUM>;
		chop $artnum2;
		close ARTNUM;
		$startingArtNum = $artnum2;
	}
	else {
		$startingArtNum = $defaultStart;
	}

	print "STARTING art num is $startingArtNum\n";
	$maxArtNum = $startingArtNum;

	return $artnum1;
}

sub SaveArtNumFile
{
	print "GOT art num 1 - $artnum1\n";
	print "GOT max art num - $maxArtNum\n";
	print     "Max art num - $maxArtNum\n";
	open(ARTNUM, ">$prefix.lastfetched");
	print ARTNUM "$maxArtNum\n";
	print ARTNUM "$artnum1\n";
	close ARTNUM;
}

sub PrintRSSHeader
{
	local $encoding = $_[0];
	local $nsString = $_[1];
	if (!$encoding) {
		$encoding = "ISO-8859-1";
	}
   print RSS <<RSSHDR;
<?xml version="1.0" encoding="$encoding"?>
<rss $nsString version="2.0">
   <channel>
      <title> RSS feed for $newspaper </title>
      <link> $defSiteRoot </link>
      <description> Generated by NewsRack crawler </description>
      <pubDate> $date </pubDate>
RSSHDR
}

sub PrintRSSItem
{
   my $dateStr = $_[0];
   if ($dateStr) {
      $dateStr = "\n         <pubDate>$dateStr</pubDate>";
   }

			## Make title, url, and desc XML-friendly
	$title = &MakeXMLFriendly($title);
	$url   = &MakeXMLFriendly($url);
	$desc  = &MakeXMLFriendly($desc);

   print RSS <<RSSITEM;
      <item>
         <title> $title </title>
         <link> $url </link>
         <description> $desc </description>
         <guid> $url </guid>$dateStr
      </item>
RSSITEM
}

sub FinalizeRSSFeed
{
   print RSS <<RSSFOOTER;
   </channel>
</rss>
RSSFOOTER

   close RSS;
   system("mv $tmpRSS $home/$rssFile");
}

sub CrawlWebPage
{
      # Process a new page, get a list of new urls to follow,
      # and add the new urls to the list

	local $url      = $_[0];
   local $fileName = &GetPage($url);
   local @newUrls  = &ProcessPage($fileName, $url);
         push(@urlList, @newUrls);
	local @fAttrs = stat $fileName;
	      $totalBytes += $fAttrs[7];
         unlink $fileName;
}

sub PrintStatsAndCleanup
{
	print     "Found $total urls, processed $processed unique ones\n";
	print     "Total bytes downloaded - $totalBytes\n";
	print LOG "Found $total urls, processed $processed unique ones\n";
	print LOG "Total bytes downloaded - $totalBytes\n";
   close LOG;
}

1;
