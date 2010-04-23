#!/usr/bin/perl

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft';

my $user=DO->new(login=>'aspower',password=>'123');
if ($user->{error}) #if (not $user->{error})
{
	print "User: $user->{login}\n";
	print "Group: $user->{group}\n";
	#my $q=$user->query('select DATE from ALARMS limit 1');
	
	my $topic='LIBRARY_PPP_';
	print "Topic: $topic\n";
	
	print "Views: ".$user->getviews($topic)."\n";
	print "Reports:".$user->getreports($topic)."\n";
}
