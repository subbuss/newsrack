#!/usr/bin/perl

use DateTime::Duration;

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
$newspaper      = "The Outlook";
$prefix         = "outlook";
my $today       = DateTime->today();
$siteDomain     = "outlookindia.com";
$defSiteRoot    = "http://www.$siteDomain";
$url            = "$defSiteRoot/index.asp";
##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("", $url);

my $now = DateTime->now();
print LOG "Started at: $now\n";

## Add any additional urls in addition to the root URL
$altRootUrl = "$defSiteRoot/"; ## Alternative ROOT URL
$urlList[1] = $altRootUrl;
$links{$altRootUrl} = "ALT ROOT";
print "ALT ROOT URL - $altRootUrl\n";

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
      # The next line uses information about The Outlook's site organization
   if ($url =~ m{$siteDomain/full.asp\?.*fodname=(\d*).*$}) {
      ($y,$m,$d) = ($1,$2,$3) if ($url =~ m{fodname=(\d\d\d\d)(\d\d)(\d\d).*});
		my $twoWeeks = DateTime::Duration->new(days=>14);	## Retain only 2 weeks worth of stuff at most!
		my $artDate  = DateTime->new(year=>$y, month=>$m, day=>$d);
		if ($artDate + $twoWeeks < $today) {
			print "Skipping $url because older than 2 weeks!\n";
			next;
		}
      ($title, $desc) = &ReadTitleAndDesc($url, "<title>", "</title>", "<strong>", "</strong>");
		$title =~ s/<.*?>//g;
		$title =~ s/\s*:\s*outlookindia.com\s*/ /ig;
		$desc =~ s/<.*?>//g;
      if ($title =~ /^\s*outlookindia.com\s*$/) {
		   print LOG "Skipping URL $url\n";
      }
		else {
		   print "TITLE of $url is $title; DESC is $desc\n";
		   $dateStr = &GetRFC822Date($y,$m,$d);
		   &PrintRSSItem($dateStr);
		}
   }
## rants.asp    -- letters to editor
## submain1.asp -- discussions
## archiveindex -- archives
## pti_.*       -- pti news
## author.asp   -- author pages

   elsif (($url =~ m{$siteDomain/.*fodname=\d+.*$}) || ($url =~ /nextsubsection.asp/) || ($url =~ /pti_\w*.asp/) || ($url =~ /\&pn=\d*/) || ($url =~ /sectionpolls.asp/) || ($url =~ /\&cp=\d*/) || ($url =~ /photoessays/) || ($url =~ /archive\w*.asp/) || ($url =~ /subsecauthor.asp/) || ($url =~ /submain1.asp/) || ($url =~ /rants.asp/) || ($url =~ /author.asp/) || ($url =~ /quiz.asp/) || ($url =~ /web.aspx\?date=/)) {
	   print "Skipping URL $url\n";
   }
##
## END CUSTOM CODE 2
##
   else {
	   print LOG "Crawling URL $url\n";
		&CrawlWebPage($url);
   }
}

my $now = DateTime->now();
print LOG "Ended at: $now\n";

&FinalizeRSSFeed();
&PrintStatsAndCleanup();
