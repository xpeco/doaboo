#!/usr/bin/perl

use strict;
use warnings;
use XML::Simple;
use DBCONN;

my $dbh=DBCONN->new; # connect
my $r=$dbh->DBCONN::rawget('select DATE from ALARMS limit 1','ARRAY'); # query
#my $r=$dbh->prepare('show fields from ALARMS')->execute; # plain

print "$r\n"; # show


