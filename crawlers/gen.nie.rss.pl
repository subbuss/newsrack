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
   while ($content =~ m{<a.*?href.*?=.*?(['|"]?).*?([^ '"<>]+)\1.*?>(.+?)</a>}isg) {
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
         $msg    = "-ABSOLUTE-";
         $ignore = 1;
      }
      elsif ($urlRef =~ /^\./) {
         $newUrl = $baseHref;
         $msg    = "-./ SAME -";
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

$newspaper   = "New Indian Express";
$prefix      = "nie";
$date        = `date +"%Y%m%d"`;
chop $date;
print "Date is $date\n";
$defSiteRoot = "http://www.newindpress.com";
$url         = "$defSiteRoot/topHeadlines.asp";

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
	next if (($url =~ /\#/i));		 # Skip if the URL has a # in it

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
      ## The next line uses information about New Indian Express' URL structure
   if (  ($url =~ m{NewsItems.asp\?ID=\w+\d+&})
      || ($url =~ m{newspages.asp\?page=.*}) 
      || ($url =~ m{Column.asp\?ID=IE\d+$}))
	{
			# Skip uninteresting articles ...
			# I am not interested in articles about stars, their treks, or their lifestyles!
##		next if (!($url =~ m{$date}));
		next if ($url =~ /Title=Startrek/);
		next if ($url =~ /Title=Features+%2D+People+%26+Lifestyle/);

			# For most sites, the next line suffices!
		$title = $links{$url};

			# These lines below are also specific to Indian Express
			# For Indian Express -- process the page to get the title of the page
			# Otherwise, all titles become 'Full Story' if this is picked from the
			# <a href=""> ... </a> links
		$title =~ s/- Newindpress.com//g;
		$title =~ s/Newindpress.com//g;
		$title =~ s/<.*?>//g;
      if (!$title || ($title =~ m{^\s*$}) || ($title =~ m/\s*HEADLINE\s*/i) || ($title =~ m/Full Story/)) {
         $title = &ReadTitle($url, "<font face=\"Arial\" color=\"black\">", "</font>");
         $title =~ s/- Newindpress.com//g;
         $title =~ s/Newindpress.com//g;
			$title =~ s/<.*?>//g;
         if (!$title || ($title =~ m{^\s*$}) || ($title =~ m/\s*HEADLINE\s*/i) || ($title =~ m/Full Story/)) {
            $title = &ReadTitle($url, "<font face=\"Arial\" color=\"#804040\">", "</font>");
				$title =~ s/- Newindpress.com//g;
				$title =~ s/Newindpress.com//g;
				$title =~ s/<.*?>//g;
            if (!$title || ($title =~ m{^\s*$}) || ($title =~ m/\s*HEADLINE\s*/i) || ($title =~ m/Full Story/)) {
               $title = "ERROR: NewsRack could not identify title";
            }
         }
      }

			# Skip the article if it is not current and is from the archives;
		next if ($title =~ /Login Archives/);

			# For NIE, URL junk after the news id is unnecessary
			# and get rid of it.
		$url =~ s/\&.*//g;
		if ($title =~ m{^\s*$}) {
         $title = "ERROR: NewsRack could not identify title";
		}
##
## END CUSTOM CODE 2
##

		print "TITLE of $url is $title\n";
      $desc = $title;
		&PrintRSSItem();
   }
   elsif (($url =~ m{News.asp\?}) || ($url =~ m{Column.asp.*old$}) || ($url =~ m{colItems.asp}) || ($url =~ m{Topic=.*?\d+}) || ($url =~ m{Archives})) {
      ## Skip these!!
	}
#   elsif ($url =~ $rootURL) {
   else {
		&CrawlWebPage($url);
   }
}

&FinalizeRSSFeed();
&PrintStatsAndCleanup();
