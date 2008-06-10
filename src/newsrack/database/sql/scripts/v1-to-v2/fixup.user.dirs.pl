#!/usr/bin/perl

use utf8;
require Encode;

## -- read the rename table --
open('UR', 'users.rename') || die "cannot open users.rename";
%rename = ();
while (<UR>) {
  chop;
  if (/(.*?)\s*=\s*(.*)/) {
	  $rename{$1} = $2;
  }
}
close UR;

$home = $ARGV[0]; shift;
while (<>) {
	print;
	if (m{uid="(.*)"}) {
		$uid = $1;
		if ($rename{$uid}) {
			$uid_renamed = $rename{$uid};
			system("cd $home; mv $uid $uid_renamed");
			$uid = $uid_renamed;
		}
		system("mkdir $home/$uid/files/attic; mv $home/$uid/files/* $home/$uid/files/attic; mkdir $home/$uid/files/generated");
	}
	if (m{file name="(.*)"}) {
		$file = $1;
		system("mv '$home/$uid/files/attic/$file' $home/$uid/files");
	}
	if (m{</user>}) {
		system("cd $home/$uid/files/attic/; mv *.jflex *.java *.xml *.tokens *.class ../generated");
	}
}
