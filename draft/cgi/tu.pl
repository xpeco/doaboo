#!/usr/bin/perl

use strict;
use warnings;
use USERS;

my $user=USERS->new(login=>'admin',password=>'12345678ikk'); # connect
#print "$user->{adm_password}\n";
if ($user->check() ne 'OK'){
	print "Not valid user:\n";
	print "	Login: ".$user->login."\n";
	print "	Password: ".$user->password."\n";
	print "	Group: ".$user->group."\n";

}
