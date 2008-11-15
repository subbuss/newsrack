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

			# Strip useless stuff from the url
		$newUrl =~ s{(&Title=[^&?]*).*}{$1};

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
#$defSiteRoot = "http://www.newindpress.com";
$defSiteRoot = "http://www.expressbuzz.com";
$url         = "$defSiteRoot/edition/default.aspx";

##
## END CUSTOM CODE 1
##

## Initialize
&Initialize("", $url);

$titleMap = {};
$urlMap = {};

## Process the url list while crawling the site
while (@urlList) {
   $total++;
   $url = shift @urlList;
   $url =~ s/(&artid=.*?)&.*/\1/;    # all crap except for artid is useless in the url

   print "URL is $url\n";

   next if ($urlMap{$url});       # Skip if this URL has already been processed;
   next if (! ($url =~ /http/i)); # Skip if this URL is not valid
	next if (($url =~ /\#/i));		 # Skip if the URL has a # in it

      # Get the new page and process it
   $processed++;
   print     "PROCESSING $url ==> $links{$url}\n";
   print LOG "PROCESSING $url ==> $links{$url}\n";
   $urlMap{$url} = $url;

      ## The next line uses information about New Indian Express' URL structure
   if ($url =~ m{/edition/story.aspx}) {
			# Skip uninteresting articles ...
			# I am not interested in articles about stars, their treks, or their lifestyles!
##		next if (!($url =~ m{$date}));
		next if ($url =~ /Title=Startrek/);
		next if ($url =~ /Title=Features+%2D+People+%26+Lifestyle/);

			# For most sites, the next line suffices!
		$title = $links{$url};
		$title =~ s/Express Buzz -//g;
		$title =~ s/<.*?>//g;

			# Skip the article if it is not current and is from the archives;
		next if ($title =~ /Login Archives/);

      if (!$title || ($title =~ m{^\s*$}) || ($title =~ m/\s*\.\.\.Read\s*/i)) {
			$title = $1 if ($url =~ /Title=(.*)/);
			$title =~ s/\+/ /g;
      	if (!$title || ($title =~ m{^\s*$})) {
				$title = &ReadTitle($url, "<span id=\"ctl00_ContentPlaceHolder1_lblStoryHeadline1\">", "</span>");
			}
		}

         # get rid of crud in the title
      $title =~ s/&artid=.*//g;
      $title =~ s/(^\s+|\s+$)//g;

         # Error condition?
      $title = "ERROR: NewsRack could not identify title" if ($title =~ m{^\s*$});

         # filter dupes by title too!
      next if !($title =~ /ERROR:/) && $titleMap{$title};
      $titleMap{$title} = 1;
		print "TITLE of $url is $title\n";
      $desc = $title;
		&PrintRSSItem();
   }
   elsif (($url =~ m{gallery(view)?.aspx}) || ($url =~ m{aspx.*aspx.*}) || ($url =~ m{content.aspx})) {
      ## Skip these!!
	}
   else {
		&CrawlWebPage($url);
   }
}

&FinalizeRSSFeed();
&PrintStatsAndCleanup();
