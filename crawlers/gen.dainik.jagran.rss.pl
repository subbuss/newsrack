#!/usr/bin/perl

require Encode;
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
      print "BASE HREF         - $baseHref\n";
   }

   ($siteRoot) = $1.$2 if ($baseHref =~ m{(http://)?([^/]*)}i);
#   print "SITE ROOT - $siteRoot\n";

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
   while ($content =~ m{<a.*?href=(['|"]?)([^ "'<>]+)\1.*?>(.+?)</a>}isg) {
      ($urlRef, $link) = ($2, $3);
		$link = Encode::decode_utf8($link);
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
      elsif ($urlRef =~ /^\//) {
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

$newspaper   = "Dainik Jagaran";
$prefix      = "dj";
##$defSiteRoot = "http://ind.jagran.com/news";
$defSiteRoot = "http://in.jagran.yahoo.com/news";
$url         = "$defSiteRoot/";
$startUrl    = $url;
$artnum1     = &OpenArtNumFile("100000");

##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("utf8", $url);

## Process the url list while crawling the site
while (@urlList) {
   $total++;
   $url = shift @urlList;
   next if ($urlMap{$url});       # Skip if this URL has already been processed;
   next if (! ($url =~ /http/i)); # Skip if this URL is not valid
   next if ($url =~ /#/); 		 	 # Skip if this URL has javascript or local anchors

      ## For now, only tracking national, opinion, and editorial news!
   next if (!($url eq $startUrl) && !($url =~ m{/(national|editorial|opinion)[/\.]}));

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
      # The next line uses information about Dainik Jagran's site organization
		# OLD DJ: http://ind.jagran.com/news/citynews.aspx?id=2928246&stateid=1&cityid=23
		# NEW DJ: http://in.jagran.yahoo.com/news/national/general/5_1_3775825.html
      #         http://in.jagran.yahoo.com/news/entertainment/news/210_230_203531.html
   if ($url =~ m{$defSiteRoot/.*/(\d*)_(\d*)_(\d+).*$}) {
      $secNum = $1;
      if (($1 != 210) && ($1 != 15) && ($1 != 16) && ($1 != 4)) {  # 210 is entertainment .. we'll let that be ...
         $artNum = $3;
         print "Article number = $artNum\n";
         next if ($artNum < $startingArtNum);

         if ($artNum > $maxArtNum) {
            $maxArtNum = $artNum;
         }
      }

			# For most sites, the next line suffices!
      $title = $links{$url};
		$title =~ s/<.*?>//g;
      if (!$title || ($title =~ m{^\s*$})) {
         $title = Encode::decode_utf8(&ReadTitle($url, "<h1[^<>]*>", "</h1>"));
      }
##
## END CUSTOM CODE 2
##
		print     "TITLE of $url is $title\n";
		print LOG "TITLE of $url is $title\n";
      $desc  = $title;
		&PrintRSSItem();
   }
   else {
		&CrawlWebPage($url);
   }
}

&FinalizeRSSFeed();
&SaveArtNumFile();
&PrintStatsAndCleanup();
