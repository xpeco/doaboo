#!/usr/bin/perl

use strict;
use warnings;
use DBCONN; 
use CGI;

my $dbh = DBCONN->new;
my $cgi = CGI->new;
print $cgi->header;

print "<H3>Testing platform</H3>\n";

my $result = $dbh->DBCONN::rawget('SELECT serialn FROM machines LIMIT 1','ARRAY');
print "Value returned: $result <br><br>";

my $sth = $dbh->prepare('SELECT serialn FROM machines');
$sth->execute();
my $res = $sth->fetchrow_hashref();
print "Value returned: $res->{serialn} <br><br>";

my $results = $dbh->selectall_hashref('SELECT * FROM machines', 'serialn');
foreach my $serialn (keys %$results) {
 print "The type of serialn $serialn is $results->{$serialn}->{type} <br>";
}

print "<br>";
print "<form action='ex2.pl' method='post'>\n";
print "<input type='submit' value=' Test ' \n";
print "</form>\n";






