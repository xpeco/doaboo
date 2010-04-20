#!/usr/bin/perl

use strict;
use warnings;
use DBCONN;

my $dbh=DBCONN->new(); # connect
my $r=$dbh->DBCONN::rawget('select DATE from ALARMS limit 1','ARRAY'); # query
print "$r\n"; # show

# Access by DBI
$r=$dbh->prepare('show fields from ALARMS')->execute; # plain
print "$r\n"; # show


