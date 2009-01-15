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
   else {
      $siteRoot = $defSiteRoot;
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
      elsif ($urlRef =~ m{^/}) {
         $newUrl = $siteRoot.$urlRef;
			if ($rejectAbsoluteUrls) {
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

$newspaper   = "Manipur E-Pao";
$prefix      = "epao";
$defSiteRoot = "http://e-pao.net";
$url         = "$defSiteRoot/index.html";

##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("", $url);

## Special case -- crawl just the main page and nothing else!
&CrawlWebPage($url);

## Process the url list while crawling the site
while (@urlList) {
   $total++;
   $url = shift @urlList;

      # Canonicalize urls
   $url =~ s{epRelatedNews.asp}{ge.asp}i;
   $url =~ s{\&mx=}{}i;

   next if ($urlMap{$url});       # Skip if this URL has already been processed;
   next if (! ($url =~ /http/i)); # Skip if this URL is not valid

      # Get the new page and process it
   $processed++;
   print     "PROCESSING $url ==> $links{$url}\n";
   print LOG "PROCESSING $url ==> $links{$url}\n";
   $urlMap{$url} = $url;

      ## The next line uses information about E-Pao's site structure
		## http://www.e-pao.net/ge.asp?heading=1&src=161206
   if ($url =~ m{ge.asp\?heading=(\d+)\&src=(\d+)}i) {
      $origUrl = $url;
##    print "MATCH for $url\n";
##    $dateStr = $2;
##    ($y,$m,$d) = ($3,$2,$1) if ($dateStr =~ /(\d\d)(\d\d)(\d\d)/);
##    $y = "20$y";
		$title = $links{$url};
		$title =~ s/<.*?>//g;
		$title =~ s/^\s*//g;
		$title =~ s/\s*$//g;
      if (!$title || ($title =~ m{^\s*$})) {
         $title = &ReadTitle($url);
         $title =~ s{:.*$}{};
      }
		print "TITLE of $url is \'$title\'\n";
      $desc  = $title;
##		$dateStr = &GetRFC822Date($y,$m,$d);
##		&PrintRSSItem($dateStr);
		&PrintRSSItem();

         ## TEMPORARY!
##		&CrawlWebPage($origUrl);
   }
	else {
##      print "SKIPPING $url\n";
##		&CrawlWebPage($url);
	}
}

&FinalizeRSSFeed();
&PrintStatsAndCleanup();
