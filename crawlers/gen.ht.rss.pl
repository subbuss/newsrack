#!/usr/bin/perl

$scriptPath = $0;
$scriptDir  = $1 if ($scriptPath =~ m{(.*)/(.*)});
if (!$scriptDir) {
	$scriptDir = ".";
}
require "$scriptDir/crawler.lib.pl";

%artSections = (
   "181"  => "1", ## regular
   "5922" => "1",	## print edition
);

%skipSections = (
   "420"  => "1",	## photos
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
   "2031" => "1", ## hindustan dainik
   "2045" => "1", ## hindustan dainik
   "2054" => "1",	## cinema
   "2225" => "1", ## hindustan dainik
   "5704" => "1",	## image galleries
   "5926" => "1",	## weekly scan
   "6225" => "1", ## party zone
   "6226" => "1", ## leisure
   "6230" => "1", ## wheels
   "6413" => "1", ## ht specials
   "6475" => "1", ## specials
   "6496" => "1", ## ht specials
   "7703" => "1",	## videos
);

# -- Process a downloaded page
sub ProcessPage
{
   my ($fileName, $url) = ($_[0], $_[1]);
   ($baseHref) = ($url =~ m{(http://.*?)(\/[^/]*)?$}i);
   $baseHref .= "/";
	$siteRoot = $defSiteRoot;
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
   if ($content =~ m{<title>(.*?)</title>}is) {
      $title = $1;
      $title =~ s/\s+/ /g;
      print "TITLE of $url is $title\n";
      $links{$url} = $title;
   }

      # Process base href declaration
   if ($content =~ m{base\s+href=(["|']?)([^'"]*/)[^/]*\1}i) {
      ($baseHref) = $2;
      print LOG "BASE HREF         - $baseHref\n";
      ($siteRoot) = $1.$2 if ($baseHref =~ m{(http://)?([^/]*)}i);
      print LOG "SITE ROOT         - $siteRoot\n";
   }

      # Check if absolute URLs are okay with this page 
   ($x) = ($baseHref    =~ m{^(http://[^/]*)/*$}i);
   ($y) = ($defSiteRoot =~ m{^(http://[^/]*)/*$}i);
   $rejectAbsoluteUrls = 1;
   if ($x eq $y) {
      $rejectAbsoluteUrls = 0; 
   }

      # Initialize the list of new urls
   my $urlList = ();

      # Match anchors -- across multiple lines, and match all instances
   while ($content =~ m{<a.*?href=(['|"]?)([^ '"<>]+)\1.*?>(.+?)</a>}isg) {
      ($urlRef, $link) = ($2, $3);
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
			if (!($urlRef =~ m{^/news/})) {
				$msg    = "-ABSOLUTE-";
				$ignore = 1;
			}
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
		elsif ($urlRef =~ m{/news/}) {
			if ($urlRef =~ m{/news/\d+}) {
         	$newUrl = $baseHref.$urlRef;
			}
			else {
				$newUrl = $baseHref.$urlRef;
				$msg    = "Uninteresting news index";
				$ignore = 1;
			}
		}
      else {
         $newUrl = $baseHref.$urlRef;
      }

			# Special check for uninteresting news indexes
		if ($newUrl =~ m{/news/\D+}) {
			$msg    = "Uninteresting news index";
			$ignore = 1;
		}

      ($newUrl =~ s{://}{###}g); 
      ($newUrl =~ s{//}{/}g); 
      ($newUrl =~ s{###}{://}g); 

         # Add or ignore, as appropriate
      if ($ignore) {
         print LOG "IGNORING NEW ($msg) - $newUrl\n"
      }
      elsif (!($newUrl =~ /.*\s*#$/) && !$links{$newUrl}) {
         $link =~ s/\s+/ /g;
         print LOG "ADDING NEW - $newUrl\n";
         $urlList[scalar(@urlList)] = $newUrl; 
         $links{$newUrl} = $link;
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

$newspaper   = "Hindustan Times";
$prefix      = "ht";
$defSiteRoot = "http://www.hindustantimes.com";
$url         = "$defSiteRoot/news/124_0,0000.htm";
$artnum1     = &OpenArtNumFile("180000");

##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("", $url);

## Process the url list while crawling the site
while (@urlList) {
   $total++;
   $url = shift @urlList;
   next if ($urlMap{$url});       # Skip if this URL has already been processed;
   next if (! ($url =~ /http/i)); # Skip if this URL is not valid
   next if ($url =~ /#/); 		 	 # Skip if this URL is a javascript link

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
      # The next line uses information about Hindustan Times site organization
		# All news items have the url structure:
		# http://www.hindustantimes.com/news/181_....htm   <-- Web edition
		# http://www.hindustantimes.com/news/5299_....htm  <-- online edition
	($secNum, $artNum) = ($1, $2) if ($url =~ m{/news/(\d+)_(\d+),.*});
   if ($artSections{$secNum}) {
		print LOG "Article number = $artNum; Sec num - $secNum\n";
		next if ($artNum < $startingArtNum);

			## Skip spurious updates to the max art. number
		if (($artNum > $maxArtNum) && (($artNum - $maxArtNum) < 10000)) {
			$maxArtNum = $artNum;
		}
##
## END CUSTOM CODE 2
##

      $title = $links{$url};
		if (($title =~ /more/) || ($title =~ m{<.*>.*</.*>}) || ($title =~ m{</.*>.*<.*>})) {
      	$title = &ReadTitle($url);
			$title =~ s/\s*:\s*Hindustantimes.com//i;
		}
      $desc = $title;
		print LOG "ADD-TO-RSS: Article number = $artNum; Sec num - $secNum\n";
		&PrintRSSItem();
   }
   elsif (($artNum ==0) && (!$skipSections{$secNum})) {
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
