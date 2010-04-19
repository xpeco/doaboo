#!/usr/bin/perl

use strict;
use warnings;
use DO;

my $user=DO->new(login=>'admin',password=>'123'); # connect
print "Group: ".$user->{group}."\n";

my $q=$user->query('select * from ADM_USERS limit 1');
print "Q_: $q->[0]->{ADM_LOGIN}\n";
