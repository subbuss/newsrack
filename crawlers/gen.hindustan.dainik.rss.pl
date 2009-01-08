#!/usr/bin/perl

require Encode;
$scriptPath = $0;
$scriptDir  = $1 if ($scriptPath =~ m{(.*)/(.*)});
if (!$scriptDir) {
	$scriptDir = ".";
}
require "$scriptDir/crawler.lib.pl";

%artSections = (
   "2031"  => "1", ## regular
);

%skipSections = (
   "0"  => "1",	## no section
   "181"  => "1",	## hindustan times
   "228"  => "1",	## hindustan times
   "376"  => "1",
   "420"  => "1",	## photos
   "611"  => "1",	## hindustan times
   "648"  => "1",	## hindustan times
   "781"  => "1",	## hindustan times
   "886"  => "1",	## tabloid
   "901"  => "1",	## chat
   "945"  => "1",	## discuss
   "1011" => "1", ## About us
   "1019" => "1", ## About us
   "1035" => "1", ## Contact us
   "1040" => "1",
   "1043" => "1",
   "1046" => "1",
   "1050" => "1",
   "1055" => "1", ## FAQs
   "1238" => "1",	## archives
   "2054" => "1",	## cinema
   "2060" => "1",	## hindustan times
   "5704" => "1",	## image galleries
   "5922" => "1",	## hindustan times
   "5926" => "1",	## weekly scan
   "5983" => "1",
   "6225" => "1", ## party zone
   "6226" => "1", ## leisure
   "6230" => "1", ## wheels
   "6413" => "1", ## ht specials
   "6475" => "1", ## ht specials
   "6492" => "1", ## ht specials
   "6496" => "1", ## ht specials
   "6923" => "1",
   "7087" => "1",	## hindustan times
   "7097" => "1",	## hindustan times
   "7099" => "1",
   "7170" => "1",	## hindustan times
   "7242" => "1",	## hindustan times
   "7430" => "1",	## hindustan times
   "7590" => "1",	## hindustan times
   "7599" => "1",	## hindustan times
   "7703" => "1",	## videos
   "7752" => "1",
   "7830" => "1",
);

sub FixupTitle
{
   my $title = $_[0];
   $title =~ s/\s+/ /g;
   $title =~ s/News:\s*HindustanDainik.com\s*//i;
   $title =~ s/\s*HindustanDainik.com\s*//i;
	$title =~ s/AddMyLinkImage.*//i;
   $title =~ s{<script>.*</script>}{}ig;
	$title =~ s/<.*?>//g;
	$title =~ s{[^\s]*("/.*").*$}{}g;
   return $title;
}

# -- Process a downloaded page
sub ProcessPage
{
   my ($fileName, $url) = ($_[0], $_[1]);
   ($baseHref) = ($url =~ m{(http://.*?)(\/[^/]*)?$}i);
	$baseHref = &FIX_URL($baseHref);
   $baseHref .= "/";
   print LOG "URL               - $url\n";
   print LOG "FILE              - $fileName\n";
   print LOG "DEFAULT BASE HREF - $baseHref\n";

      # Suck in the entire file into 1 line
   $x=$/;
   undef $/;
   open (FILE, "<$fileName");
   $content = <FILE>;
   close FILE;
   $/=$x;

      # Get the title of the page
   if (!$links{$url} && ($content =~ m{<title>(.*?)</title>}is)) {
      $title = &FixupTitle($1);
      if ($title) {
         $title = Encode::decode_utf8($title);
         print "PAGE TITLE of $url is $title\n";
         $links{$url} = $title;
      }
   }

      # Process base href declaration
   if ($content =~ m{base\s+href=(["|']?)([^'"]*/)[^/]*\1}i) {
      ($baseHref) = $2;
      print LOG "BASE HREF         - $baseHref\n";
      ($siteRoot) = $1.$2 if ($baseHref =~ m{(http://)?([^/]*)}i);
      print LOG "SITE ROOT         - $siteRoot\n";
   }

      # Check if absolute URLs are okay with this page 
	$rejectAbsoluteUrls = &AbsoluteUrlsOkay($baseHref, $defSiteRoot);

      # Initialize the list of new urls
   my $urlList = ();

      # Match anchors -- across multiple lines, and match all instances
   while ($content =~ m{<a.*?href=(['|"]?)([^ '"<>]+)\1.*?>(.+?)</a>}isg) {
      ($urlRef, $link) = ($2, $3);
      $link = &FixupTitle($link);
		$link = Encode::decode_utf8($link);
		$urlRef = &FIX_URL($urlRef);
      print LOG "REF - $urlRef; LINK - $link; "; 
      $msg="";
      $ignore = 0;
         # Check this before the "^http" check because
         # some urls might be absolute even though they
         # have the base href in them
      if ($urlRef =~ /$baseHref/oi) {
         $newUrl = $urlRef;
      }
		elsif ($urlRef =~ /^\#/) {
			$thisUrl = $url;
			$thisUrl =~ s/\#.*//;
         $newUrl  = $thisUrl.$urlRef;
		}
      elsif ($urlRef =~ /^http/i) {
         $newUrl = $urlRef;
         $msg    = "-http-";
         $ignore = 1;
      }
      elsif ($rejectAbsoluteUrls && ($urlRef =~ /^\//)) {
         $newUrl = $siteRoot.$urlRef;
         $msg    = "-ABSOLUTE-";
         $ignore = 1;
      }
      elsif ($urlRef =~ /^\.\./) {
         $newUrl = $baseHref.$urlRef;
         $msg    = "-..-";
         $ignore = 1;
      }
      elsif ($urlRef =~ /^mailto/i) {
         $newUrl = $urlRef;
         $msg    = "-mailto-";
         $ignore = 1;
      }
      else {
         $newUrl = $baseHref.$urlRef;
      }

		$newUrl = &FIX_URL($newUrl);
      ($newUrl =~ s{://}{###}g); 
      ($newUrl =~ s{//}{/}g); 
      ($newUrl =~ s{###}{://}g); 
		$newUrl = $UNICODE_GATEWAY_PREFIX.$newUrl;

         # Add or ignore, as appropriate
      if ($ignore) {
         print LOG "IGNORING NEW ($msg) - $newUrl\n"
      }
      elsif ($newUrl =~ /.*\s*#.*$/) {
         $msg    = "-local anchor-";
         print LOG "IGNORING NEW ($msg) - $newUrl\n"
      }
      elsif (!$links{$newUrl}) {
         ($secNum, $artNum) = ($1, $2) if ($newUrl =~ m{/news/(\d+)_(\d+),.*});
         if (!$skipSections{$secNum}) {
            print LOG "ADDING NEW - $newUrl\n";
            $urlList[scalar(@urlList)] = $newUrl; 
            $links{$newUrl} = $link;
         }
      }
   }

   return $urlList;
}

############################### MAIN ################################
## This should be the first thing to do!!
&ChangeWorkingDir();

##
## BEGIN CUSTOM CODE 1: This section needs to be customized for every
## newspaper depending on how their site is structured.
##

$newspaper   = "Hindustan Dainik";
$prefix      = "hd";
$defSiteRoot = "http://www.hindustandainik.com";
$url         = "$defSiteRoot/news/2045_0,0100.htm";
$artnum1     = &OpenArtNumFile("180000");

##
## END CUSTOM CODE 1
##

## Initialize
$UNICODE_GATEWAY_PREFIX="http://uni.medhas.org/unicode.php5?file=";
&Initialize("utf8", $UNICODE_GATEWAY_PREFIX.$url);

## Process the url list while crawling the site
while (@urlList) {
   $total++;
   $url = shift @urlList;
   next if ($urlMap{$url});       # Skip if this URL has already been processed;
   next if (! ($url =~ /http/i)); # Skip if this URL is not valid

      # Get the new page and process it
   $processed++;
   print     "PROCESSING $url ==> $links{$url}\n";
   print LOG "PROCESSING $url ==> $links{$url}\n";
   $urlMap{$url} = $url;

##
## BEGIN CUSTOM CODE 2: This section needs to be customized for every
## newspaper depending on how their site is structured.  This line
## tries to identify URLs that pertain to news stories (as opposed to
## index pages).  This check crucially relies on knowledge of the site
## structure and organization and needs to be customized for different
## newspapers.
##
      ## The next line uses information about Hindustan Dainik's URL structure
		# All news items have the url structure:
		# http://www.hindustandainik.com/news/2031_....htm   <-- Web edition
	$secNum = 0; $artNum = 0;
	($secNum, $artNum) = ($1, $2) if ($url =~ m{/news/(\d+)_(\d+),.*});
	print     "Article number = $artNum; Sec num - $secNum\n";
	print LOG "Article number = $artNum; Sec num - $secNum\n";
   if ($artSections{$secNum}) {
		next if ($artNum < $startingArtNum);

		if ($artNum > $maxArtNum) {
			$maxArtNum = $artNum;
		}

			# For most sites, the next line suffices!
		$title = $links{$url};

			# But, not for Hindustan Dainik
		if ($title =~ /^\s*$/) {
         $title = &FixupTitle(&ReadTitle($url, "<td class=\"bkhd1\" colspan=\"2\">", "</td>"));
			$title = Encode::decode_utf8(title);
         print "READTITLE-DECODE: $title\n";
		}
      else {
		   print "PRESET TITLE: $title\n";
      }
##
## END CUSTOM CODE 2
##
      $desc  = $title;
		print "ADDING: TITLE of $url is $title\n";
		print LOG "ADD-TO-RSS: Article number = $artNum; Sec num - $secNum\n";
		&PrintRSSItem();
   }
   elsif (($artNum == 0) && (!$skipSections{$secNum})) {
		next if ($url =~ /specials/);
		&CrawlWebPage($url);
   }
	else {
		print "Skipping $url\n";
		print LOG "Skipping $url\n";
	}
}

&FinalizeRSSFeed();
&SaveArtNumFile();
&PrintStatsAndCleanup();
