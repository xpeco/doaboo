#!/usr/bin/perl

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft'; # recursive config

my $user=DO->new(login=>'roessler',password=>'123');
print "error:$user->{error}\n";
if ($user->{error}) #if (not $user->{error})
{
	print "User: $user->{login}\n";
	print "Group: $user->{group}\n";
	#my $q=$user->query('select DATE from ALARMS limit 1');
	
	my $topic='FILER';
	print "Topic: $topic\n";
	
#	print "Views: ".$user->getviews($topic,'ARRAY')."\n";
#	print "Reports:".$user->getreports($topic)."\n";
#	print "Actions:".$user->getactions($topic)."\n";

#	print "View details:".$user->getview($topic,'DAIMLER_V1')."\n";

	print "--".$user->getrecords($topic,'DAIMLER_V1')."\n";


}
