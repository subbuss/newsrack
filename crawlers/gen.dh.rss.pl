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
#   print "URL               - $url\n";
#   print "FILE              - $fileName\n";
#   print "DEFAULT BASE HREF - $baseHref\n";

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
#      print "BASE HREF         - $baseHref\n";
#      ($siteRoot) = $1.$2 if ($baseHref =~ m{(http://)?([^/]*)}i);
#      print "SITE ROOT         - $siteRoot\n";
   }

      # Check if absolute URLs are okay with this page 
	$rejectAbsoluteUrls = &AbsoluteUrlsOkay($baseHref, $defSiteRoot);

      # Initialize the list of new urls
   my $urlList = ();

      # Match anchors -- across multiple lines, and match all instances
   while ($content =~ m{<a.*?href=(['|"]?)([^ "'<>]+)\1.*?>(.+?)</a>}isg) {
      ($urlRef, $link) = ($2, $3);
#     print LOG "REF - $urlRef; LINK - $link; "; 
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
         $nu = $baseHref.$urlRef;
         $b = $1 if ($baseHref =~ m{(.*/)(.+)/?});
         $u = $1 if ($urlRef =~ m{\.\./(.*)});
         $newUrl = $b.$u;
         if ($newUrl =~ m{$defSiteRoot}i) {
            $ignore = 0;
         }
         else {
            $msg    = "-..-";
            $ignore = 1;
         }
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
$newspaper          = "Deccan Herald";
$prefix             = "dh";
## Sometimes, the URL structure for the site has the date string in it
$date               = `date -R`;
($day, $mon, $year) = ($date =~ /.*, 0*(\d+) (\w+) (\d+) .*/);
$mon                = lcfirst $mon;
$urlDateString      = "$mon$day$year";
#$urlDateString      = "jun102008";
$defSiteRoot        = "http://www.deccanherald.com/Content/$urlDateString";
$url                = "$defSiteRoot/index.asp";
##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("", $url);
#&Initialize("", $url, "Tue, 10 Jun 2008 06:43:49 +0530");

## Add any additional urls in addition to the root URL
## this is necessary for Deccan Herald, for instance
$altRootUrl = "$defSiteRoot/update.asp"; ## Alternative ROOT URL
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
      # The next line uses information about Deccan's site organization
   if ($url =~ m{$defSiteRoot/\w+\d+.asp}i) {
			# For most sites, the next line suffices!
      $title = $links{$url};
##
## END CUSTOM CODE 2
##
		$title =~ s/<.*?>//g;
		print "TITLE of $url is $title\n";
      $desc  = $title;
		&PrintRSSItem();
   }
   else {
		&CrawlWebPage($url);
   }
}

&FinalizeRSSFeed();
&PrintStatsAndCleanup();
