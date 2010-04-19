#!/usr/bin/perl

use strict;
use warnings;
use USERS;
use DBCONN;


my $dbh=DBCONN->new(); # connect

my $user=USERS->new(db=>$dbh,login=>'admin',password=>'12345678ikk'); # connect
if ($user->check() ne 'OK'){
	print "Not valid user:\n";
	print "	Login: ".$user->login."\n";
	print "	Password: ".$user->password."\n";
	print "	Group: ".$user->group."\n";

}
$user=USERS->new(login=>'admin',password=>'12345678ikk'); # connect
#if ($user->check() ne 'OK'){
#	print "Not valid user:\n";
#	print "	Login: ".$user->login."\n";
#	print "	Password: ".$user->password."\n";
#	print "	Group: ".$user->group."\n";
#}

print "U1: ".$user->login."\n";
my $r=$dbh->DBCONN::rawget('select DATE from ALARMS limit 1','ARRAY'); 
print "$r\n"; # show


