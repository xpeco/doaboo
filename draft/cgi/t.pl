#!/usr/bin/perl

use strict;
use warnings;
use DBCONN;

my $dbh=DBCONN->new; # connect
my $r=$dbh->DBCONN::rawget('SELECT * FROM machines LIMIT 1','ARRAY'); # query
#my $r=$dbh->prepare('show fields from machines')->execute; # plain

print "$r\n"; # show


