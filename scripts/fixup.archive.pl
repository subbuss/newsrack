#!/usr/bin/perl

opendir DIR, ".";
@allDates = grep !/^\.\.?/, readdir DIR;
foreach $date (@allDates) {
	if ($date =~ /(\d+)\.(\d+)\.(\d+)/) {
		($d, $m, $y) = ($1, $2, $3);
#		print "mkdir -p $y/$m/$d\n";
#		print "mv $date/* $y/$m/$d/\n";
		system("mkdir -p $y/$m/$d");
		system("mv $date/* $y/$m/$d/");
	}
}
