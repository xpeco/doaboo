#!/usr/bin/perl

use strict;
use warnings;
use lib '/home/cdoblado/doaboo/draft/cgi/'; #like this when changed to mod_perl by changing doaboo.conf
use DBCONN; 
use CGI;
use HTML::Template;

#$Apache::DBI::DEBUG = 2; #it works under mod_perl only

my $dbh = DBCONN->new;
my $cgi = CGI->new;
print $cgi->header;

print "<H3>Testing platform</H3>\n";

my $sth = $dbh->prepare('SELECT serialn FROM machines');
$sth->execute();
my $result = $sth->fetchrow_hashref();
print "Value returned: $result->{serialn} <br>";

#Populate entire column TYPE with DATA
#MySQL: update machines SET type='B';

my $results = $dbh->selectall_hashref('SELECT * FROM machines', 'serialn');
foreach my $serialn (keys %$results) {
   print "The type of serialn $serialn is $results->{$serialn}->{type} <br>";
}

print "<form action='ex2.pl' method='post'>\n";
print "<input type='submit' value=' Test ' \n";
print "</form>\n";






