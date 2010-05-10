#!/usr/bin/perl

use strict;
use warnings;
use DBCONN;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft';

my $dbh=DBCONN->new(); # connect
my $r=$dbh->DBCONN::rawget('select NUMBER from CONTRACT limit 1','ARRAY'); # query
print "$r\n"; # show

$r=$dbh->DBCONN::rawget("select NUMBER,'' as nn.a from CONTRACT limit 1"); # query
print "$r->[0]->{nn.a}\n"; # show

# Access by DBI
$r=$dbh->prepare('select NUMBER from CONTRACT')->execute; # plain
#print "$r->[0]->{NUMBER}\n"; # show
