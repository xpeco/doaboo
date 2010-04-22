#!/usr/bin/perl

use strict;
use warnings;
use DO;

my $user=DO->new(login=>'admin',password=>'123'); # connect
print "Group: ".$user->{group}."\n";

my $q=$user->query('select DATE from ALARMS limit 1','ARRAY');
print "Q_: $q\n";

#my $q=$user->getview('xx');
#my $q=$user->getaction('xx');


