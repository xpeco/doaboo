#!/usr/bin/perl

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft';

my $user=DO->new(login=>'admin',password=>'123');
if ($user->{error}) #if (not $user->{error})
{
	print "Group: ".$user->{group}."\n";
	#my $q=$user->query('select DATE from ALARMS limit 1');
	
	my $topic='ALARMS';
	my $q=$user->getviews($topic);
	print $q;
}
	#my $q=$user->getaction('xx');
