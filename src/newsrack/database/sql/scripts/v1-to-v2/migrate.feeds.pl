#!/usr/bin/perl

while (<>) {
	if ($_ =~ m{<feed id="(\d*)" dir="\d*\.(.*)" url="(http://[^/]*/)(.*)" />}i) {
		$f = $1;
		$d = $2;
		$ur = $3;
		$ut = $4;
		$ut =~ s/&amp;/\&/g;
		$ut =~ s/&quot;//g;
		if ($f == 329 && ($d =~ /jpost/)) {
			$f = 313;
		}
		elsif ($f == 330 && ($d =~ /jpost/)) {
			$f = 314;
		}
		elsif ($f == 331 && ($d =~ /jpost/)) {
			$f = 315;
		}
		elsif ($f == 695 && ($d =~ /india.stories/)) {
			$f = 692;
		}
		print "insert into feeds values($f, '$f.$d', '', '$ur', '$ut', 1, 1, 120);\n";
	}
}

## Manually fixup the feed key for 0.et.jobs -- it gets a non-zero entry
print "update feeds set feed_key=0 where feed_tag='0.et.jobs';\n";

## After some url fixes (&quot --> ""), it turns out there will be 2 feeds with the same url.  Remove one of them!
print "delete from feeds where feed_key=464;\n"
