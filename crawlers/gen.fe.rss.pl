#!/usr/bin/perl

$scriptPath = $0;
$scriptDir  = $1 if ($scriptPath =~ m{(.*)/(.*)});
if (!$scriptDir) {
	$scriptDir = ".";
}
require "$scriptDir/crawler.lib.pl";

# -- Process a downloaded page
sub ProcessPage
{
   my ($fileName, $url) = ($_[0], $_[1]);
   ($baseHref) = ($url =~ m{(http://.*?)(\/[^/]*)?$}i);
   ($baseHref2) = ($url =~ m{(http://[^/]*)(.*)?$}i);
   $baseHref .= "/";
   $baseHref2 .= "/";
   print LOG "URL               - $url\n";
   print LOG "FILE              - $fileName\n";
   print LOG "DEFAULT BASE HREF - $baseHref\n";
   print LOG "DEFAULT BASE HREF 2 - $baseHref2\n";

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
	$rejectAbsoluteUrls = &AbsoluteUrlsOkay($baseHref, $defSiteRoot);

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
			if ($urlRef =~ /^\/bsonline\//) {
				$newUrl = $baseHref2.$urlRef;
			}
			else {
				$newUrl = $siteRoot.$urlRef;
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
      else {
         $newUrl = $baseHref.$urlRef;
      }

      ($newUrl =~ s{://}{###}g); 
      ($newUrl =~ s{//}{/}g); 
      ($newUrl =~ s{###}{://}g); 

         # Add or ignore, as appropriate
      if ($ignore) {
         print LOG "IGNORING NEW ($msg) - $newUrl\n"
      }
      elsif (!($newUrl =~ /.*\s*#$/)) {
         $link =~ s/\s+/ /g;
         print LOG "ADDING NEW - $newUrl\n";
			if ($links{$newUrl} && ($link =~ /full story/i)) {
				print LOG "Skipping already existing link - $link; $newUrl\n";
			}
			else {
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

$newspaper   = "Financial Express";
$prefix      = "fe";
$defSiteRoot = "http://www.financialexpress.com";
$startPage   = "$defSiteRoot/feprint.php";
$artnum1     = &OpenArtNumFile("200000");

##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("", $startPage);

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
      ## The next line uses information about Financial Standard's URL structure
   if ($url =~ m{/news/.*/(\d+)/}) {
			# For most sites, the next line suffices!
      $artNum = $1;
		print "Article number = $artNum\n";
		next if ($artNum < $startingArtNum);

		if ($artNum > $maxArtNum) {
			$maxArtNum = $artNum;
		}

		$title = $links{$url};
##
## END CUSTOM CODE 2
##
		$title =~ s/<.*?>//g;
		print "TITLE of $url is \'$title\'\n";
      $desc  = $title;
		&PrintRSSItem();
   }
      ## Ignore php pages
   elsif (($url =~ $startPage) || !($url =~ /\.php/)) {
		&CrawlWebPage($url);
   }
}

&FinalizeRSSFeed();
&SaveArtNumFile();
&PrintStatsAndCleanup();
