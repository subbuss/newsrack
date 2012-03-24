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
   ($baseHref) = ($url =~ m{(http://.*?)(\/[^/]*)?(\?.*)?$}i);
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
   $rejectAbsoluteUrls = 0; #&AbsoluteUrlsOkay($baseHref, $defSiteRoot);

      # Initialize the list of new urls
   my $urlList = ();

      # Match anchors -- across multiple lines, and match all instances
   while ($content =~ m{<a.*?href\s*=\s*(['|"]?)([^ "<>]+)\1.*?>(.+?)</a>}isg) {
      ($urlRef, $link) = ($2, $3);
      print LOG "REF - $urlRef; LINK - $link; \n"; 
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
         if ($rejectAbsoluteUrls) {
            $msg    = "-http-";
            $ignore = 1;
         }
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
      ($newUrl =~ s{\\}{/});

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
      else {
         print LOG "Trishanku swarga $newUrl\n";
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
$newspaper          = "The Hindu: Today's Paper";
$prefix             = "hindu.todayspaper";
$defSiteRoot        = "http://www.thehindu.com/todays-paper/tp-index/";
$url                = "$defSiteRoot";
##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("", $url);

# Crawl root page
&CrawlWebPage($url);

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
   next if ($url !~ m{todays-paper.*article\d+.ece});

##
## END CUSTOM CODE 2
##
	$title = $links{$url};
	$desc  = $title;
	&PrintRSSItem();
}

&FinalizeRSSFeed();
&PrintStatsAndCleanup();
