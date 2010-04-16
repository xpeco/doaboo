#!/usr/bin/perl

package DBCONN;

use strict;
use warnings;
use lib '/home/cdoblado/doaboo/draft/cgi/'; #like this when changed to mod_perl by changing doaboo.conf
use DBCONN;
use CGI;
my $cgi = CGI->new;
print $cgi->header;

print "<H3>Testing platform - Persistent DB connection</H3>\n";

my $dbh=GetDBH();
my $sth = $dbh->prepare('SELECT serialn FROM machines');
$sth->execute();
my $result = $sth->fetchrow_hashref();
print "Value returned: $result->{serialn} <br>";


