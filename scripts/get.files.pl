#!/usr/bin/perl

$dir    = "../users";
$utable = "$dir/user.table.xml";
$uid    = "";
$file   = "";
$prefix = "";
$odir   = "/tmp/vocab";
system("mkdir -p $odir");
open UT, "$utable" || die "could not open $utable for reading\n";
while (<UT>) {
	if (m{\s*uid="(.*)"\s*$}) {
		$uid = $1;
		$prefix = $uid;
	}
	if (m{\s*file name="(.*?)"\s*}) {
		$f = $1;
		$file = "$dir/$uid/files/$f";
		system("cp '$file' '$odir/$prefix.$1'");
	}
}
close UT;
