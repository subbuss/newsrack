#!/usr/bin/perl

########################################################################
#  Copyright 2005 Subramanya Sastry
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
########################################################################
# This script can be used to generate RSS feeds for certain
# newspapers that do not provide RSS feeds (yet).  It needs to be
# customized for different newspapers -- there are two sections
# in the code below marked prominently between sections
# "BEGIN CUSTOM CODE" and "END CUSTOM CODE"
#
# This script will not work for all newspapers, but only for
# those newspapers that use date-specific site organization.
########################################################################

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
   "1035" => "1", ## Contact us
   "1040" => "1",
   "1043" => "1",
   "1046" => "1",
   "1050" => "1",
   "1055" => "1", ## FAQs
   "1238" => "1",	## archives
   "2045" => "1", ## hindustan dainik
   "2225" => "1", ## hindustan dainik
   "5704" => "1",	## image galleries
   "5926" => "1",	## weekly scan
   "6475" => "1", ## specials
   "7703" => "1",	## videos
);

%monthMap = (
	"January"   => "01", 
	"01"   => "01", 
	"February"  => "02", 
	"02"  => "02", 
	"March"     => "03", 
	"03"     => "03", 
	"April"     => "04", 
	"04"     => "04", 
	"May"       => "05", 
	"05"       => "05", 
	"June"      => "06", 
	"06"      => "06", 
	"July"      => "07", 
	"07"      => "07", 
	"August"    => "08", 
	"08"    => "08", 
	"September" => "09", 
	"09" => "09", 
	"October"   => "10", 
	"10"   => "10", 
	"November"  => "11", 
	"11"  => "11", 
	"December"  => "12",
	"12"  => "12",
);

#Fri, 08 Dec 2006 01:24:42 +0530

$count = 0;
$totSize = 0;
$links = "";

# -- Download a page from a specified URL
sub GetPage
{
   use LWP;
   use LWP::Simple;
   my $url      = $_[0];
   my $fileName = $1 if ($url =~ m{.*/(.*)$}i);
#   @hdrs = head($url);
#   print "HEADERS LENGTH - $#hdrs\n";
#   ($ctype, $len, $lastModTime, $expires, $server) = @hdrs;
#   $currTime = time();

   $browser = LWP::UserAgent->new();
   $browser->agent("NewsRack/1.0");
   $webpage = $browser->request(new HTTP::Request GET => $url);
   if ($webpage->is_success) {
      $count++;
      open (OUT, ">$fileName");
#     print     "Storing in file $fileName\n";
      print LOG "Storing in file $fileName\n";
      print OUT $webpage->content;
      close OUT;
      return $fileName;
   }
   else {
      print     ($webpage->message)."; Bad luck\n";
      print LOG ($webpage->message)."; Bad luck\n";
      return "";
   }
}

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
   undef $/;
   open (FILE, "<$fileName");
   $content = <FILE>;
   close FILE;

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
      else {
         $link =~ s/\s+/ /g;
         print LOG "ADDING NEW - $newUrl\n";
         $urlList[scalar(@urlList)] = $newUrl; 
         $links{$newUrl} = $link;
      }
   }

   return $urlList;
}

sub GetDate
{
   my $url      = $_[0];
	if (!$startTag) {
		$startTag = "<font color=777777>";
		$endTag   = "</font>";
	}

#	print "starttag is $startTag\n";
#	print "endtag is $endTag\n";

   $fileName = &GetPage($url);
#	print "file is $fileName\n";

   open (FILE, "<$fileName");
	$dateString = "2006-12-07";  ## default date!
	while (<FILE>) {
			# Get the datestring on the page
		if (m|<font color=777777|i) {
			($mon, $date, $year) = ($1,$2,$3) if (m|$startTag.*$startTag.*$startTag(\w+)\s+(\d+)\s*,\s*(\d+)$endTag|i);
			print "##### DATE is $mon, $date, $year\n";
			$date = $1 if ($date =~ m|0*(.*)|);
			$mon = $monthMap{$mon};
                     ####<dc:date>2006-12-06</dc:date>
			if (($year > 0) && ($mon > 0) && ($date > 0)) {
				$date="0".$date if ($date < 10);
				$dateString="$year-$mon-$date;
			}
			print "### fixed date string is $dateString\n";
			last;
		}
	}
   close FILE;

	@fAttrs = stat $fileName;
	$totSize += $fAttrs[7];
   unlink $fileName;
#   system("rm -f '$fileName'");

		## Extract the title from the title string
	return $dateString;
}

sub ReadTitle
{
   my $url      = $_[0];
	my $startTag = $_[1];
	my $endTag   = $_[2];
	if (!$startTag) {
		$startTag = "<title>";
		$endTag   = "</title>";
	}

#	print "starttag is $startTag\n";
#	print "endtag is $endTag\n";

   $fileName = &GetPage($url);
#	print "file is $fileName\n";

   open (FILE, "<$fileName");
	$titleString = "";
	while (<FILE>) {
			# Get the title of the page
		if (m|$startTag|i) {
			do {
				chop;
				$titleString.= $_." ";
				last if (m|$endTag|i);
			} while ($_ = <FILE>);
## PERL BUG: Control does not reach here in case the
## above loop is never executed beyond the 1st iteration!
			last;
		}
	}
	$title =~ s/\s+/ /g;
   close FILE;

	@fAttrs = stat $fileName;
	$totSize += $fAttrs[7];
   unlink $fileName;
#   system("rm -f '$fileName'");

		## Extract the title from the title string
	$title = $1 if ($titleString =~ m{$startTag(.*?)$endTag}i);
#	print "title - $title\n";

	return $title;
}

sub ChangeWorkingDir()
{
	$scriptPath = $0;
	$scriptDir  = $1 if ($scriptPath =~ m{(.*)/(.*)});
	if (!$scriptDir) {
		$scriptDir = ".";
	}
	$dir = `pwd`;
	chop $dir;
	print "scriptPath   - $scriptPath\n";
	print "scriptDir    - $scriptDir\n";
	print "currDir      - $dir\n";
	chdir($scriptDir);
	print "CHANGED Working directory to $scriptDir\n";
}

############################### MAIN ################################
&ChangeWorkingDir();

##
## BEGIN CUSTOM CODE 1: This section needs to be customized for every
## newspaper depending on how their site is structured.
##
$newspaper          = "Hindustan Times";
$prefix             = "ht";
$rssFile            = "$prefix.rss.xml";
#$date               = `date +"%d %b %y"`;
#($day, $mon, $year) = ($date =~ /(\d+) (\w+) (\d+)/);
#$mon                = lcfirst $mon;
#$urlDateString      = "$mon$day$year";
#$urlDateString      = "dec0105";
#$date = "Sat, 1 Dec 2005 21:37:03 +0530";
$defSiteRoot        = "http://www.hindustantimes.com";
$url                = "$defSiteRoot/news/124_0,0000.htm";

## In the file, the max-art-id from previous 2 runs of crawling is stored
## say, run(k-1) and run(k-2), where run(k-1) is more recent than run(k-2).
##
## So, when the script is run again, run(k), max-art-id from run(k-2) is used to
## seed the starting id for run(k)
##
## At the end, the script stores max-art-id from run(k) and run(k-1) in this file
##
if (-f "$prefix.lastfetched") {
	open(ARTNUM, "<$prefix.lastfetched");
	$artnum1 = <ARTNUM>;
	chop $artnum1;
	$artnum2 = <ARTNUM>;
	chop $artnum2;
	close ARTNUM;
	$startingArtNum = $artnum2;
}
else {
	$startingArtNum = 100000;
}

print "STARTING art num is $startingArtNum\n";
$maxArtNum          = $startingArtNum;
##
## END CUSTOM CODE 1
##

$urlList[0]  = $url;
$urlList[scalar(@urlList)] = $url; 
$links{$url} = "ROOT";
$rootURL     = $url;
print "ROOT URL - $url\n";

## Get the index page	
#my $fileName=&GetPage($url);
#@newUrls = &ProcessPage($fileName, $url);
#system("rm -f '$fileName'");
open(LOG, ">$prefix.logfile");
$total     = 0;
$processed = 0;

## Output the RSS header
$currDir = `pwd`;
chop $currDir;
$home    = "$currDir/../crawled.feeds";
$tmpRSS  = "$home/$rssFile.tmp";
$date    = `date -R`;
chop $date;
open (RSS, ">$tmpRSS") || die "cannot open RSS file - $tmpRSS\n";
print RSS <<RSSHDR;
<?xml version="1.0" encoding="ISO-8859-1"?>
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
   <channel>
      <title> RSS feed for $newspaper </title>
      <link> $defSiteRoot </link>
      <description> Generated by NewsRack crawler </description>
      <pubDate> $date </pubDate>
RSSHDR

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

		if ($artNum > $maxArtNum) {
			$maxArtNum = $artNum;
		}
##
## END CUSTOM CODE 2
##

      $title = $links{$url};
		$dateString = &GetDate($url);
		if (($title =~ m{<.*>.*</.*>}) || ($title =~ m{</.*>.*<.*>})) {
      	$title = &ReadTitle($url);
		}
      $desc  = $title;

			## Make title XML-friendly
		$title =~ s/&/&amp;/g;
		$title =~ s/</&lt;/g;
		$title =~ s/>/&gt;/g;
		$title =~ s/"/&quot;/g;
		$title =~ s/'/&apos;/g;

			## Make description XML-friendly
		$desc =~ s/&/&amp;/g;
		$desc =~ s/</&lt;/g;
		$desc =~ s/>/&gt;/g;
		$desc =~ s/"/&quot;/g;
		$desc =~ s/'/&apos;/g;

		print LOG "ADD-TO-RSS: Article number = $artNum; Sec num - $secNum\n";

      print RSS <<RSSITEM;
      <item>
         <title> $title </title>
         <link> $url </link>
         <description> $desc </description>
         <guid> $url </guid>
         <dc:date> $dateString </dc:date>
      </item>
RSSITEM
   }
   elsif (($artNum ==0) && (!$skipSections{$secNum})) {
      $fileName = &GetPage($url);
         # Process the new page and get a list of new ursl to follow 
      @newUrls  = &ProcessPage($fileName, $url);
         # Add the new urls to the list
      push(@urlList, @newUrls);
#      system("rm -f '$fileName'");
		@fAttrs = stat $fileName;
		$totSize += $fAttrs[7];
      unlink $fileName;
   }
	else {
		print "Skipping $url\n";
		print LOG "Skipping $url\n";
	}
}

## Output the RSS footer
print RSS <<RSSFOOTER;
   </channel>
</rss>
RSSFOOTER

## close the temporary RSS file
close RSS;

## Rename the temporary file to the new file
system("mv $tmpRSS $home/$rssFile");

open(ARTNUM, ">$prefix.lastfetched");
print ARTNUM "$maxArtNum\n";
print ARTNUM "$artnum1\n";
close ARTNUM;
print     "Max art num - $maxArtNum\n";
print     "Found $total urls, processed $processed unique ones\n";
print     "Total bytes downloaded - $totSize\n";
print LOG "Max art num - $maxArtNum\n";
print LOG "Found $total urls, processed $processed unique ones\n";
print LOG "Total bytes downloaded - $totSize\n";
close LOG;
