#!/usr/bin/perl

use strict;
use warnings;
use DBCONN;
use CGI;

my $dbh = DBCONN->new;
my $cgi = CGI->new;
print $cgi->header;

print "<H3>Testing platform - Persistent DB connection</H3>\n";

my $sth = $dbh->prepare('SELECT serialn FROM machines');
$sth->execute();
my $result = $sth->fetchrow_hashref();
print "Value returned: $result->{serialn} <br>";


