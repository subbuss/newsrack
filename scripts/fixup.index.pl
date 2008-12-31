#!/usr/bin/perl

# import packages
use XML::RSS;
use LWP::Simple;

%monthMap = (
	"1" => "jan",
	"2" => "feb",
	"3" => "mar",
	"4" => "apr",
	"5" => "may",
	"6" => "jun",
	"7" => "jul",
	"8" => "aug",
	"9" => "sep",
	"10" => "oct",
	"11" => "nov",
	"12" => "dec",
);

%guardianMap = (
	"0,12271," => "http://www.guardian.co.uk/usa/story/#fix_html_artname",
	"0,3604,"  => "http://www.guardian.co.uk/international/story/#fix_html_artname",
	"0,6903,"  => "http://www.guardian.co.uk/Observer/international/story/#fix_html_artname",
	"0,12559," => "http://www.guardian.co.uk/india/story/#fix_html_artname",
	"0,15671," => "http://www.guardian.co.uk/tsunami/story/#fix_html_artname",
	"0,7369,"  => "http://www.guardian.co.uk/naturaldisasters/story/#fix_html_artname",
);

%rssMap = (
	"bbc_sa"               => "rss091.xml",
	"bbc_health"           => "rss.xml",
	"guardian_world"       => "0,,12,00.xml",
	"guardian_front_page"  => "0,,1,00.xml",
	"india_together"       => "home.xml",
	"rediff.news"          => "newsrss.xml",
	"rediff.us.topstories" => "usrss.xml",
	"rediff.columns"       => "columnistrss.xml",
	"rediff.interviews"    => "interviewsrss.xml",
	"rediff"               => "newsrss.xml",
	"indiainfo"            => "news.xml",
	"indiainfo.news"       => "news.xml",
	"newkerala.gujarat"    => "_id=28",
	"newkerala.india.news" => "_id=2",
	"newkerala.health.news" => "_id=9",
	"newkerala.business.india" => "_id=4",
	"telegraph.nation"     => "rss.asp_id=4",
	"telegraph.business"   => "rss.asp_id=9",
	"sify"                 => "news.php",
	"sify.news"            => "news.php",
	"bs.crawler"           => "bs.rss.xml",
	"nie.crawler"          => "nie.rss.xml",
	"statesman.crawler"    => "statesman.rss.xml",
	"pioneer.crawler"      => "pioneer.rss.xml",
	"dh.crawler"           => "dh.rss.xml",
	"goi.pib"      		  => "goi.pib.rss.xml",
	"at.crawler"           => "at.rss.xml",
	"oseng.crawler"        => "oseng.rss.xml",
	"cc.crawler"           => "cc.rss.xml",
	"ht.crawler"           => "ht.rss.xml",
	"dna.topnews"          => "rss,catID-0.xml",
	"dna.mumbai"           => "rss,catID-1.xml",
	"dna.india"            => "rss,catID-2.xml",
	"dna.money"            => "rss,catID-4.xml",
	"hindu.karnataka"      => "22hdline.xml",
	"ie"                   => "ie.xml",
	"ei"                   => "ei.xml",
	"fe"                   => "fe.xml",
	"ie_frontpage"         => "ie.xml",
	"ei_frontpage"         => "ei.xml",
	"fe_frontpage"         => "fe.xml",
	"toi.ahmedabad"        => "1245388434.cms",
	"toi.bangalore"        => "1769582659.cms",
	"toi.bombay"           => "1225119221.cms",
	"toi.cities"           => "-2128932452.cms",
	"toi.columnists"       => "12051364.cms",
	"toi.delhi"            => "1306468042.cms",
	"toi.edits"            => "-2128669051.cms",
	"toi.entertainment"    => "1081479906.cms",
	"toi.india"            => "-2128936835.cms",
	"toi.india.business"   => "-2128682902.cms",
	"toi.indo_pak"         => "222022.cms",
	"toi.interviews"       => "-2128565703.cms",
	"toi.intl.business"    => "-2128680634.cms",
	"toi.nri"              => "222023.cms",
	"toi.sports"           => "671208.cms",
	"toi.us"               => "30359486.cms",
	"et.advertising"       => "13357077.cms",
	"et.agriculture"       => "1202099874.cms",
	"et.banking"           => "13358319.cms",
	"et.biotech"           => "13358090.cms",
	"et.bpo"               => "26865660.cms",
	"et.brand.equity"      => "287662.cms",
	"et.consultancy"       => "13357085.cms",
	"et.corporate.dossier" => "121385957.cms",
	"et.economy"           => "1286551815.cms",
	"et.education"         => "25466841.cms",
	"et.electronics"       => "13358854.cms",
	"et.engineering"       => "13357919.cms",
	"et.entertainment"     => "13357410.cms",
	"et.finance"           => "13358311.cms",
	"et.food"              => "13358793.cms",
	"et.foreign.trade"     => "1200949414.cms",
	"et.gadgets"           => "129134.cms",
	"et.global.markets"    => "12872390.cms",
	"et.iets"              => "40274504.cms",
	"et.indicators"        => "344531568.cms",
	"et.infotech"          => "13357549.cms",
	"et.infrastructure"    => "1135557951.cms",
	"et.insurance"         => "13358304.cms",
	"et.investment"        => "2026181286.cms",
	"et.ipos"              => "14655708.cms",
	"et.jobs"              => "107115.cms",
	"et.mutual.funds"      => "1107225967.cms",
	"et.oil"               => "13358368.cms",
	"et.petrochem"         => "13357719.cms",
	"et.policy"            => "1106944246.cms",
	"et.power"             => "13358361.cms",
	"et.services"          => "13357077.cms",
	"et.software"          => "13357555.cms",
	"et.telecom"           => "542990.cms",
);

%urlMap = (
# These ones are not going to be perfect (some urls will bomb)
	"bbc_sa"               => "http://news.bbc.co.uk/go/rss/-/2/hi/south_asia/#artname",
	"bbc_health"           => "http://news.bbc.co.uk/go/rss/-/2/hi/health/#artname",
# This will be partially fixed up
	"guardian_world"       => "#fixupGuardianMap",
# This needs month name in the url (some urls will bomb)
	"india_together"       => "http://www.indiatogether.org/#yyyy/#MMM/#artname",
# About 10-15% urls will bomb
	"rediff.news"          => "http://www.rediff.com/money/#yyyy/#MMM/#artname",
# This needs month name in the url
	"rediff"               => "http://www.rediff.com/news/#yyyy/#MMM/#artname",
	"rediff.news"          => "http://www.rediff.com/news/#yyyy/#MMM/#artname",
	"rediff.business"      => "http://www.rediff.com/news/#yyyy/#MMM/#artname",
# This needs date in the URL
	"indiainfo"            => "http://news.indiainfo.com/#yyyy/#mm/#dd/#artname",
	"indiainfo.news"       => "http://news.indiainfo.com/#yyyy/#mm/#dd/#artname",
	"telegraph.nation"     => "http://telegraphindia.com/1#yy#mm#dd/asp/nation/#artname",
	"telegraph.business"   => "http://telegraphindia.com/1#yy#mm#dd/asp/nation/#artname",
	"telegraph.north.bengal"  => "http://telegraphindia.com/1#yy#mm#dd/asp/nation/#artname",
	"hindu.karnataka"      => "http://www.thehindu.com/#yyyy/#mm/#dd/stories/#artname",
	"dh.crawler"           => "http://www.deccanherald.com/deccanherald/#MMM#dd#yyyy/#artname",
	"at.crawler"           => "http://www.assamtribune.com/#MMM#dd#yy/#artname",
	"cc.crawler"           => "http://www.centralchronicle.com/#yyyy#mm#dd/#artname",
# These ones require the replacement of "php_" by "php?"
	"ie"                   => "http://www.indianexpress.com/#fix_php_artname",
	"ei"                   => "http://www.expressindia.com/#fix_php_artname",
	"fe"                   => "http://www.financialexpress.com/#fix_php_artname",
	"ie_frontpage"         => "http://www.indianexpress.com/#fix_php_artname",
	"ei_frontpage"         => "http://www.expressindia.com/#fix_php_artname",
	"fe_frontpage"         => "http://www.financialexpress.com/#fix_php_artname",
	"newkerala.gujarat"    => "http://www.newkerala.com/#fix_php_artname",
	"newkerala.india.news" => "http://www.newkerala.com/#fix_php_artname",
	"newkerala.business.india" => "http://www.newkerala.com/#fix_php_artname",
	"newkerala.kerala.news" => "http://www.newkerala.com/#fix_php_artname",
	"newkerala.health.news" => "http://www.newkerala.com/#fix_php_artname",
	"newkerala.world.news" => "http://www.newkerala.com/#fix_php_artname",
	"newkerala.cricket.news" => "http://www.newkerala.com/#fix_php_artname",
	"newkerala.hollywood.news" => "http://www.newkerala.com/#fix_php_artname",
	"sify"                 => "http://sify.com/news/#fix_php_artname",
	"sify.news"            => "http://sify.com/news/#fix_php_artname",
	"sify.finance"         => "http://sify.com/finance/#fix_php_artname",
	"bs.crawler"           => "http://www.business-standard.com/bsonline/#fix_php_artname",
	"statesman.crawler"    => "http://www.thestatesman.net/#fix_php_artname",
# These ones require the replacement of "asp_" by "asp?"
	"nie.crawler"          => "http://www.newindpress.com/#fix_asp_artname",
	"goi.pib"      		  => "http://www.pib.nic.in/release/#fix_asp_artname",
	"pioneer.crawler"      => "http://www.thestatesman.net/#fix_asp_artname",
	"oseng.crawler"        => "http://www.assamtribune.com/english/#fix_asp_artname",
	"dna.topnews"          => "http://www.dnaindia.com/#fix_asp_artname",
	"dna.mumbai"           => "http://www.dnaindia.com/#fix_asp_artname",
	"dna.india"            => "http://www.dnaindia.com/#fix_asp_artname",
	"dna.money"            => "http://www.dnaindia.com/#fix_asp_artname",
# These work well as is  
	"ht.crawler"           => "http://www.hindustantimes.com/#artname",
	"toi.ahmedabad"        => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.bangalore"        => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.bombay"           => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.cities"           => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.columnists"       => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.delhi"            => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.edits"            => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.entertainment"    => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.india"            => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.india.business"   => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.indo_pak"         => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.interviews"       => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.intl.business"    => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.nri"              => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.sports"           => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"toi.us"               => "http://timesofindia.indiatimes.com/articleshow/#artname",
	"et.advertising"       => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.agriculture"       => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.banking"           => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.biotech"           => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.bpo"               => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.brand.equity"      => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.consultancy"       => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.corporate.dossier" => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.economy"           => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.education"         => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.electronics"       => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.engineering"       => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.entertainment"     => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.finance"           => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.food"              => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.foreign.trade"     => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.gadgets"           => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.global.markets"    => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.iets"              => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.indicators"        => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.infotech"          => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.infrastructure"    => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.insurance"         => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.investment"        => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.ipos"              => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.jobs"              => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.mutual.funds"      => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.media"      	 	  => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.oil"               => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.petrochem"         => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.policy"            => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.power"             => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.services"          => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.software"          => "http://economictimes.indiatimes.com/articleshow/#artname",
	"et.telecom"           => "http://economictimes.indiatimes.com/articleshow/#artname",
);

## $filterString="";
## open(TMP, "/tmp/fixmi");
## while (<TMP>) {
## 	$filterString .= $_;
## }
## close TMP;
## print $filterString;

$home      = "/services/floss/fellows/subbu";
$gna       = "$home/resin/webapps/newsrack/global.news.archive";
$indexFile = "index/index.xml";
$archDir   = "$gna/filtered";
opendir ARCHIVE, $archDir || die "could not open directory $archDir";
chdir $archDir || die "could not chdir to $archDir";
@allDates = grep !/^\.\.?/, readdir ARCHIVE;
foreach $date (@allDates) {
	next if -f $date;
   next if (!($date =~ m{6.6.2006}));       ## Skip non April-2006 dates

	print "--- DATE: $date ---\n";
	chdir "$date" || die "could not chdir to $date" ;
	opendir DATEDIR, "." || die "could not open directory $date";
	@allSrcs = grep !/^\.\.?/, readdir DATEDIR;
	foreach $src (@allSrcs) {
		next if -f $src;
   next if (!($src =~ m{55.nie.crawler}));       ## Skip non-IE
## 		next if (($src =~ m{rediff.us.topstories})); ## Ignore this source
		if ($src =~ /tsunami.location/) {
			print "SKIPPING tsunami.location\n";
			next;
		}
## 		next if (! ($filterString =~ m{$date/$src}));

		print "\tSRC: $src ---\n";
		chdir $src || die "could not chdir to $src";
		%currentArts = "";
		if (-e $indexFile) {
			open(INDEX, $indexFile) || warn "could not open $indexFile for $date/$src";
			while (<INDEX>) {
				if (/localcopy.*\/(.*)"/) {
					$baseName = $1;
					$baseName =~ s/&amp;/&/g;
					$currentArts{$baseName} = 1;
				}
			}
			close INDEX;
		}

			## Read the list of files in the filtered directory
			## and find out which files are missing from the index
#		opendir FILTDIR, "filtered";
		opendir FILTDIR, ".";
		@allFiles = grep !/^\.\.?/, readdir FILTDIR;
		@missingFiles = "";
		$count = 0;
		foreach $file (@allFiles) {
			next if -d $file;
			if ($currentArts{$file}) {
#				print "$file already exists in index file\n";
			}
			else {
				print "\t\t$file DOES NOT EXIST in index file\n";
				$missingFiles[$count++] = $file;
			}
		}

		if ($count > 0) {
			print "CREATING new file index.xml.fixed for $date/$src with $count missing files\n";
			open(INDEX_FIXED, ">$indexFile".".fixed");
				## First spit out the existing index file as is
			if (-e $indexFile) {
				open(INDEX, $indexFile) || warn "could not open $indexFile for $date/$src";
				while (<INDEX>) {
					last if /<\/news>/;
					print INDEX_FIXED;
				}
				close INDEX;
			}
			else {
				print INDEX_FIXED "<news>\n";
			}

				## Next, output fixed index entries for the missing files
			foreach $file (@missingFiles) {
#				print "\t\t ==> Trying to fix $date/$src/filtered/$file";
				print "\t\t ==> Trying to fix filtered/$date/$src/$file";
				$artName = $2 if ($file =~ /(ni[0-9]+\.)?(.*)/); 	# Article name as it appears in the URL
				print " ==> ARTNAME - $artName";
				$newArtName = $artName;
				$newArtName =~ s/php_/php\?/g;
				$newArtName =~ s/asp_/asp\?/g;
				$newArtName =~ s/html_/html\?/g;
				$newArtName =~ s/%2C/,/g;
				$newArtName =~ s/%3D/=/g;
				print " ==> NEW_ARTNAME - $newArtName\n";

					### First check if the RSS feed file has
					### has an entry for this file .. If so, simply use it.
				$found   = 0;
				$rssFile = &GetRSSFile($src);
				if (-e $rssFile) {
						## Do a quick and dirty check if the article is present in the RSS file
					$save = $/;
					undef $/;
					open(RSS, $rssFile);
					@content=<RSS>;
					close RSS;
					$/ = $save;

					$x_res1       = $artName;
					$x_res1       =~ s/&/&amp;/g;
					$x_res1       =~ s/\?/\\\?/g;
					$x_res1       =~ s/\*/\\\*/g;
					$x_res1       =~ s/\./\\\./g;
					$x_res1       =~ s/\+/\\\+/g;
					$x_artName    = $x_res1;
					$x_artName    =~ s/&amp;/&/g;

					$x_res2       = $newArtName;
					$x_res2       =~ s/&/&amp;/g;
					$x_res2       =~ s/\?/\\\?/g;
					$x_res2       =~ s/\*/\\\*/g;
					$x_res2       =~ s/\./\\\./g;
					$x_res2       =~ s/\+/\\\+/g;
					$x_newArtName = $x_res2;
					$x_newArtName =~ s/&amp;/&/g;

					$res1 = grep (/$x_res1/, @content);
					$res2 = grep (/$x_res2/, @content);
					print "n - $artName; nan - $newArtName\n";
					print "n - $x_artName; nan - $x_newArtName\n";
					print "n - $x_res1; nan - $x_res2; res1 - $res1; res2 - $res2\n";

						## If present, then parsing
					if ($res1 || $res2) {
						print " ==> SHOULD BE PRESENT HERE ";
						$rss = new XML::RSS(); 		# initialize object
						$rss->parsefile($rssFile); # parse RSS feed
							# print titles and URLs of news items
						foreach my $item (@{$rss->{'items'}}) {
							$title = $item->{'title'};
							$url   = $item->{'link'};
							$desc  = $item->{'description'};
							if (   ($url =~ /$x_artName/) 
							    || ($url =~ /$x_newArtName/))
							{
								print " ==> FOUND in RSS FILE\n";
								$found = 1;
								last;
							}
						}
					}
				}

					## If we did not find what we want in the RSS file, try to
					## reconstruct the item information as best as we can!
				if (!$found) {
					($dd, $mm, $yyyy) = split /\./, $date;			# Various components of the date 
					$MMM = $monthMap{$mm};								# Month name
					$url = $urlMap{$src};						# fixup string for the url
#					print "yyyy - $yyyy, mm - $mm, dd - $dd, MMM - $MMM, url - $url\n";
					if (!$url) {
						print " ==> CANNOT FIX\n";
					}
					else {
						print " ==> will fix\n";
					}

						# Do this in the beginning
					if ($url =~ /#fixupGuardianMap/) {
						$prefix = $1 if ($newArtName =~ /^(\d*,\d*,)/);
						$url = $guardianMap{$prefix};
					}

						# Do various fixups of the URL string
					if ($url =~ /#yyyy/) {
						$url =~ s/#yyyy/$yyyy/;
					}
					elsif ($url =~ /#yy/) {
						$url =~ s/#yy/$yyyy[2..3]/;
					}
					if ($url =~ /#mm/) {
						if ($mm < 10) {
							$url =~ s/#mm/0$mm/;
						}
						else {
							$url =~ s/#mm/$mm/;
						}
					}
					if ($url =~ /#MMM/) {
						$url =~ s/#MMM/$MMM/;
					}
					if ($url =~ /#dd/) {
						$url =~ s/#dd/$dd/;
					}
					if ($url =~ /#fix_asp_artname/) {
						$artName =~ s/asp_/asp?/;
						$url =~ s/#fix_asp_artname/$artName/;
					}
					if ($url =~ /#fix_php_artname/) {
						$artName =~ s/php_/php?/;
						$url =~ s/#fix_php_artname/$artName/;
					}
					if ($url =~ /#fix_html_artname/) {
						$artName =~ s/html_/html?/;
						$url =~ s/#fix_html_artname/$artName/;
					}
					if ($url =~ /#artname/) {
						$url =~ s/#artname/$artName/;
					}

						# Get title
					$titleString ="";
				#	open(ARTICLE, "filtered/$file") || warn "unable to open filtered/$file";
					open(ARTICLE, "$file") || warn "unable to open $file";
					while (<ARTICLE>) {
						if (/<title>/) {
							do {
								chop;
								$titleString .= $_." ";
								print "TITLESTRING - $titleString\n";
								last if (/<\/title>/);
							} while ($_ = <ARTICLE>);
							last;
						}
					}
					close ARTICLE;
					$title = $1 if ($titleString =~ /<title>(.*)<\/title>/);
					print "FINAL TITLESTRING - $titleString\n";

						# We set description to be the same title
					$desc = $title;
				}

						# Do fixup of '&' characters
				$file =~ s/&amp;/&/g;
				$file =~ s/&/&amp;/g;
						# Do fixup of '&' characters
				$url =~ s/&amp;/&/g;
				$url =~ s/&/&amp;/g;
						# Do fixup of '&' and other XML entities
				$title =~ s/&amp;/&/g;
				$title =~ s/&/&amp;/g;
				$title =~ s/'/&apos;/g;
				$title =~ s/"/&quot;/g;
				$title =~ s/</&lt;/g;
				$title =~ s/>/&gt;/g;
						# Do fixup of '&' and other XML entities
				$desc =~ s/&amp;/&/g;
				$desc =~ s/&/&amp;/g;
				$desc =~ s/'/&apos;/g;
				$desc =~ s/"/&quot;/g;
				$desc =~ s/</&lt;/g;
				$desc =~ s/>/&gt;/g;


				print "\t\t  URL: $url;\n";
				print "\t\t  TITLE: $title\n";

				print INDEX_FIXED "\t<item>\n";
				print INDEX_FIXED "\t\t<source id=\"$src\" />\n";
				print INDEX_FIXED "\t\t<date val=\"$date\" />\n";
				print INDEX_FIXED "\t\t<title val=\"$title\" />\n";
				print INDEX_FIXED "\t\t<description val=\"$desc\" />\n";
				print INDEX_FIXED "\t\t<url val=\"$url\" />\n";
#				print INDEX_FIXED "\t\t<localcopy path=\"$date/$src/filtered/$file\" />\n";
				print INDEX_FIXED "\t\t<localcopy path=\"$date/$src/$file\" />\n";
				print INDEX_FIXED "\t</item>\n\n";
			}
			print INDEX_FIXED "</news>\n";
			close INDEX_FIXED;
		}
		close FILTDIR;
		close INDEX;
		chdir "..";
	}
	close DATEDIR;
	chdir "..";
}
close ARCHIVE;

sub GetRSSFile
{
	my $src = $_[0];
	$rssBase = $rssMap{$src}; 							# Get the name of the RSS feed
	$rssFile = "index/$rssBase";
	if (!$rssBase || !(-e $rssFile)) {
		opendir INDEXDIR, "index/" || die "could not open directory index/";
		@allFiles = grep !/^\.\.?/, readdir INDEXDIR;
		foreach $f (@allFiles) {
			if ($f =~ /^rss\./) {
				$rssFile = "index/$f";
				last;
			}
		}
		close INDEXDIR;
	}

	print "returning $rssFile for $src\n";

	return $rssFile;
}
