#!/usr/bin/perl

#$dir    = "../../newsrack/users";
$dir    = "../users";
$utable = "$dir/ut.xml.old";
#$dir    = "/var/lib/tomcat5.5/webapps/newsrack/users";
#$utable = "$dir/user.table.xml";
$uid    = "";
$file   = "";
open UT, "$utable" || die "could not open $utable for reading\n";
while (<UT>) {
	if (m{\s*uid="(.*)"\s*$}) {
		$uid = $1;
		$odir = "$dir/$uid/files";
		system("mkdir -p $odir");
	}
	if (m{\s*file name="(.*?)"\s*}) {
		$file = "$dir/$uid/info/$1";
	}
	next if (!$file);

	print "FILE IS $file\n";

	$collName = $file;
	$collName =~ s{.*/}{};
	$collName =~ s/.xml$//g;

	$usedSrcsList = "";
	$comment = "";
	$nesting = "";
	$insideIssue = "";

	open F, "$file" || die "could not open $file for reading\n";
	open OF, ">$odir/$collName" || die "could not open $odir/$collName for writing\n";
	while(<F>) {
			## Catch single-line comments first
		if (m{<!-- .* -->}) {
			s/<!-- .* -->//g;
		}

		if (m{<!--}) {
			$comment = "1";
		}
		if ($comment && m{-->}) {
			$comment = "";
			s/.*-->//g;
		}

		next if $comment;
####### PATTERNS FOR SOURCES ##########
		if (m{<news?-sources>}) {
			print OF "define sources {$collName}\n";
		}
		if (m{</news?-sources>}) {
			print OF "end sources\n\n";
		}
		if (m{<source>}) {
			$source = "1";
		}
		if (m{</source>}) {
			if ($id && !($feed =~ "none")) {
				print OF "\t$id = \"$name\", $feed\n";
			}
			$id = "";
			$name = "";
			$feed = "";
			$source = "";
		}
		if ($source && m{<id>}) {
			$id = $1 if (m{<id>\s*(.*?)\s*</id>});
		}
		if ($source && m{<name>}) {
			$name = $1 if (m{<name>\s*(.*?)\s*</name>});
			$name =~ s/&amp;/&/g;
		}
		if ($source && m{<rss-feed>}) {
			$feed = $1 if (m{<rss-feed>\s*(.*?)\s*</rss-feed>});
		}

####### PATTERNS FOR CONCEPTS ##########
		if (m{<def-concepts>}) {
			print OF "define concepts {$collName}\n";
		}
		if (m{</def-concepts>}) {
			print OF "end concepts\n\n";
		}
		if (m{<concept>}) {
			$cpt = "1";
			$first = "1";
		}
		if ($cpt && m{<name>}) {
			$name = $1 if (m{<name>\s*(.*?)\s*</name>});
			print OF "\t<$name> = ";
		}
		if ($cpt && m{<use-concept>}) {
			$cname = $1 if (m{<use-concept>\s*(.*?)\s*</use-concept>});
			if ($first) {
				print OF "<$cname>";
			}
			else {
				print OF ", <$cname>";
			}
			$first = "";
		}
		if ($cpt && m{<keyword>}) {
			$kwd = $1 if (m{<keyword>\s*(.*?)\s*</keyword>});
			$kwd =~ s/&amp;/&/;
			if (($kwd =~ /&/) || ($kwd =~ m{\s+and\s+}i) || ($kwd =~ m{\.})) {
				$kwd = "\"$kwd\"";
			}
			if ($first) {
				print OF "$kwd";
			}
			else {
				print OF ", $kwd";
			}
			$first = "";
		}
		if (m{</concept>}) {
			print OF "\n";
			$name = "";
			$cpt = "";
		}

####### PATTERNS FOR USE-SOURCES #########
		if (m{<use-sources>}) {
			$useSrcs = "1";
		}
		if (m{</use-sources>}) {
			$useSrcs = "";
		}
		if ($useSrcs && m{<id>}) {
			$id = $1 if (m{<id>\s*(.*?)\s*</id>});
			if (!($id =~ /archive/)) {
				if ($usedSrcsList) {
					$usedSrcsList .= ", $id";
				}
				else {
					$usedSrcsList = $id;
				}
			}
		}
		if ($useSrcs && m{<all-from-file>}) {
			$file = $1 if (m{<all-from-file>\s*(.*?)\s*</all-from-file>});
			$file =~ s/.xml$//g;
			if ($usedSrcsList) {
				$usedSrcsList .= "\{$file\}";
			}
			else {
				$usedSrcsList = "\{$file\}";
			}
		}

####### PATTERNS FOR CATEGORIES ##########
		if (m{<def-categories>}) {
			if ($insideIssue) {
				$nesting = 1;
			}
			else {
				print OF "define categories {$collName}\n";
				$nesting = 0;
			}
		}
		if (m{</def-categories>}) {
			if (!$insideIssue) {
				print OF "end categories\n\n";
			}
		}
		if ($insideIssue && m{<all-from-file>}) {
			$file = $1 if (m{<all-from-file>\s*(.*?)\s*</all-from-file>});
			$file =~ s/.xml$//g;
			$nesting++;
			$i = 0;
			$tabs = "";
			while ($i < $nesting) {
				$tabs .= "\t";
				$i++;
			}
			print OF "$tabs\{$file\}\n";
			$nesting--;
		}
		if (m{<category>}) {
			if ($cat) {
				print OF "{\n";
			}
			$cat = "1";
			$nesting++;
		}
		if ($cat && m{<name>}) {
			$name = $1 if (m{<name>\s*(.*?)\s*</name>});
			$i = 0;
			$tabs = "";
			while ($i < $nesting) {
				$tabs .= "\t";
				$i++;
			}
			print OF "$tabs\[$name\] = ";
		}
		if ($cat && m{<rule>}) {
			$rule = $1 if (m{<rule>\s*(.*?)\s*</rule>});
			$rule =~ s/{(.*?)}/|\1|/g;
			$rule =~ s/\w+://g;
			print OF "$rule\n";
		}
		if (m{</category>}) {
			if (!$rule) {
				$i = 0;
				$tabs = "";
				while ($i < $nesting) {
					$tabs .= "\t";
					$i++;
				}
				print OF "$tabs\}\n";
			}
			$nesting--;
			$rule = "";
			$name = "";
			$cat = "";
		}

####### PATTERNS FOR IMPORTS ##########
		if (m{<import-sources>}) {
			$import = "import sources";
		}
		if (m{</import-sources>}) {
			$import = "";
		}
		if (m{<import-categories>}) {
			$import = "import categories";
		}
		if (m{</import-categories>}) {
			$import = "";
		}
		if (m{<import-concepts>}) {
			$import = "import concepts";
		}
		if (m{</import-concepts>}) {
			$import = "";
		}
		if ($import && m{<name>}) {
			$file = $1 if (m{<name>\s*(.*?)\s*</name>});
		}
		if ($import && m{<nstag>}) {
			$tag = $1 if (m{<nstag>\s*(.*?)\s*</nstag>});
			$file =~ s/.xml$//g;
			if ($tag != "\.") {
				print OF "\{$tag\} = $import $file\n\n";
			}
			else {
				print OF "\{$file\} = $import $file\n\n";
			}
		}

####### PATTERNS FOR ISSUES ##########
		if (m{<issue>}) {
			print OF "define issue";
			$issue = "1";
		}
		if ($issue && m{<name>}) {
			$issue = "";
			$insideIssue = "1";
			$name = $1 if (m{<name>\s*(.*?)\s*</name>});
			print OF " $name\n";
			print OF "\tmonitor sources $usedSrcsList\n";
			print OF "\torganize news into categories\n\t{\n";
		}
		if (m{</issue>}) {
			print OF "\t}\nend issue\n\n";
			$insideIssue = "0";
		}
	}

	close F;
	$file = "";
}
close UT;
