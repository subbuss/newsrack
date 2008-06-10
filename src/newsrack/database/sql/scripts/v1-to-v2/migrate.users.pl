#!/usr/bin/perl

# use utf8;
# require Encode;

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

while (<>) {
	if (m{<user name="(.*)"}) {
		$name = $1; #Encode::decode_utf8($1);
		$validated = 0;
	}
	if (m{uid="(.*)"}) {
		$uid = $1;
		if ($rename{$uid}) {
			$uid = $rename{$uid};
		}
	}
	if (m{password="(.*)"}) {
		$password = $1;
	}
	if (m{email="(.*)"}) {
		$email = $1;
	}
	if (m{profile-validated val="true"}) {
		$validated = 1;
	}
	if (m{</user>}) {
		$name =~ s/'/\\'/g;
		if ($uid =~ /admin/) {
			print "-- IGNORING admin";
		}
		else {
			print "insert into users(uid, password, name, email, validated) values('$uid', '$password', '$name', '$email', $validated);\n";
		}
	}
}
