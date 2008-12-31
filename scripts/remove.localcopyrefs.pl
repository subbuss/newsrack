#!/usr/bin/perl

#$home = "/var/lib/tomcat5.5/webapps/ROOT";
#$users = "$home/users";
#$gna   = "$home/news.archive";
#$orig  = "$gna/orig";
#$filt  = "$gna/filtered";

$YEAR = "2007";
$file = $ARGV[0];
open(F, $file);	# Open the file
@localCopiesToRemove = <F>;		# Read it into an array
close(F);

@allRefsToRemove= ();
my %filesToFix = ();
foreach $lc (@localCopiesToRemove) {
	($y, $m, $d, $src, $base) = ($2, $3, $4, $5, $6) if ($lc =~ m{^(\./)?(.*?)/(.*?)/(.*?)/(.*?)/(.*)$});
	$y = $YEAR  if ($y eq "");
	$base =~ s{filtered/}{}g;
	$base =~ s{&amp;}{\&}g;
	print "y - $y; m - $m; d - $d; s - $src; b - $base\n";
	$idxFile = "$y/$m/$d/$src/index/index.xml";
	$str = "$d.$m.$y/$src/$base";
	if ($filesToFix{$idxFile}) {
		push(@{$filesToFix{$idxFile}}, $str);
	}
	else {
		$filesToFix{$idxFile} = [ ($str) ];
	}
	push(@allRefsToRemove, $str);
}

	## Fix cache.xml
open(F, "../cache.xml");
my $buf = "";
while (<F>) {
	if (m{<item .* path="(.*)" />}i) {
		my $path = $1;
		$tocheck = $path;
		$tocheck =~ s{filtered/}{}g;
		$tocheck =~ s{&amp;}{\&}g;
		$tocheck =~ s{\?}{\\?}g;
		$tocheck =~ s{\+}{\\+}g;
#			print "CHECKING $tocheck in @allRefsToRemove}\n";
#			print "CHECKING $tocheck\n";
		if (grep /^$tocheck$/, @allRefsToRemove) {
			print "#### Removing $path ####\n";
		}
		else {
#				print "NOT PRESENT\n"; 
			$buf .= $_;
		}
	}
	else {
		$buf .= $_;
	}
}
close F;

open(NEWF, ">../cache.xml.FIXED");
print NEWF $buf;
close NEWF;

	## Fix index files in GNA
for my $idxFile (keys %filesToFix) {
	&FixFile($idxFile, "$idxFile.FIXED", \@{$filesToFix{$idxFile}});
}

	## Fix index files in user directory
$file = $ARGV[1];
open(F, $file);	# Open the file
@userIndexFiles = <F>;		# Read it into an array
close(F);

chdir ("../../users");
for my $f (@userIndexFiles) {
	chop $f;
	&FixFile($f, "$f.FIXED", \@allRefsToRemove);
}

sub FixFile {
	$f    = $_[0];
	$newF = $_[1];
	$refsToRemove = $_[2];
#	print "GOT array: @{$refsToRemove}\n";
	$changed = 0;
	print "******** PROCESSING $f -> $newF ******* \n";
	open F, "$f";
	open NEWF, ">$newF" || warn "ERROR ERROR ERROR .. cannot open file $newF\n";
	my $buf = "";
	while (<F>) {
		if (m{<item>}) {
			if (!($buf =~ /^\s*$/)) {
				print NEWF $buf;
			}
			$buf = $_;	## INIT
		}
		elsif (m{<url val="(.*)".*>}) {
			$buf .= $_;
		}
		elsif (m{<localcopy path="(.*)".*>}) {
			$buf .= $_;
			my $path = $1;
			$tocheck = $path;
			$tocheck =~ s{filtered/}{}g;
			$tocheck =~ s{&amp;}{\&}g;
			$tocheck =~ s{\?}{\\?}g;
			$tocheck =~ s{\+}{\\+}g;
#			print "CHECKING $tocheck in @{$refsToRemove}\n";
#			print "CHECKING $tocheck\n";
			if (grep /^$tocheck$/, @{$refsToRemove}) {
				$skipme = "1";
				print "#### Removing $path ####\n";
				$changed = 1;
			}
			else {
#				print "NOT PRESENT\n"; 
			}
		}
		elsif (m{</item>}) {
			if ($skipme) {
				$buf = "";
				$skipme = "";
			}
			else {
				$buf .= $_;
			}
		}
		else {
			$buf .= $_;
		}
	}
	print NEWF $buf;
	close F;
	close NEWF;

	if (!$changed) {
		print "NO CHANGES for $f; removed $newF\n";
		unlink $newF;
	}
}
