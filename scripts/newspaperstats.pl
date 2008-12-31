#!/usr/bin/perl

$HOME="/services/floss/fellows/subbu";
$UDIR="$HOME/resin/webapps/newsrack/users";
system("find $UDIR -name news.xml.STATS | grep -v _attic > /tmp/filenames");
open(FLIST, "/tmp/filenames");
while (<FLIST>) {
	chop;
	$i = $_;
	open(S, "$i") || warn "cannot open $i";
	print "opened CAT $i\n";
	($cat = $i) =~ s{$UDIR/}{};
	$cat =~ s{/news.xml.STATS}{};
	$cat =~ s{^(.+?)/issues/}{$1 : };
	while (<S>) {
		s/\s+/ /g;
		($dummy, $count, $paper) = split(/ /);
#		$paper =~ s{^www.}{};
#		print "$paper :: $cat -- $count\n";
		$stats{$paper}{$cat} = $count;
	}
	close S;
}
close FLIST;

print " -- HERE == \n";

for my $paper (keys %stats) {
	print "paper is $paper\n";
	open (P, ">/tmp/$paper.TMP");
	for my $cat (keys %{$stats{$paper}}) {
		print P "$cat : $stats{$paper}{$cat}\n";
	}
	close P;
	system("sort -k 5 -n -r /tmp/$paper.TMP > STATS/$paper.STATS");
}

open(PS, ">/tmp/paper.stats");
close PS;
