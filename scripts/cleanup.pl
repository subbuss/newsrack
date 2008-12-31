#!/usr/bin/perl 

while (<>) {
	$line = $_;
	if (!($line =~ />/)) {
		while (<>) {
			$line.=$_;
			last if />/;
		}
	}
	$line =~ s{(<.*?=)"(.*)"(\s*/>\s*)}{\1#\2#\3}s;
	$line =~ s/"/&quot;/sg;
	$line =~ s/'/&apos;/sg;
	$line =~ s/&amp;/&/sg;
	$line =~ s/&/&amp;/sg;
	$line =~ s{(<.*?=)#(.*)#(\s*/>\s*)}{\1"\2"\3}s;
	print $line;
}
