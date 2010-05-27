#!/usr/bin/perl

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft'; # recursive config

my $user=DO->new(login=>'spa',password=>'123');
#my $fields=$user->DO::query("select type from doaboo_attributes where topic in \(select id from doaboo_topics where name='CUSTOMER'\)");
#print "F: $fields->[0]->{NAME}\n";
print "error:$user->{error}\n";
if ($user->{error}) #if (not $user->{error})
{
	print "User: $user->{login}\n";
	print "Group: $user->{group}\n";
	#my $q=$user->query('select DATE from ALARMS limit 1');
	
	my $topic='FILER';
	print "Topic: $topic\n";
	
	print "Views:\n";
	my $views=$user->getviews($topic);
	foreach my $view(@$views)
	{
		print "	$view->{DESC}\n";
	}
	print "View Detail:\n";
	my $viewdet=$user->getview($topic,'9991_ASUP_MISSING');
	foreach my $view(@$viewdet)
	{
		print "	$view->{DESC}\n";
	}
	print "Actions:\n";
	my $actions=$user->getactions($topic);
	foreach my $action(@$actions)
	{
		print "	$action->{description}\n";
	}

#	print "Reports:".$user->getreports($topic)."\n";
	print "Relations (zoom in):\n";
	my $relations=$user->getrelationsto($topic);
	foreach my $relation(@$relations)
	{
		print "	$relation->{description}\n";
	}
	print "Relations (zoom out):\n";
	$relations=$user->getrelationsfrom($topic);
	foreach my $relation(@$relations)
	{
		print "	$relation->{description}\n";
	}


#	my $id="NUMBER='1'";
#	print "Stored: ".$user->getstored($topic,$id)."\n";

	print "--".$user->getrecords($topic,'9991_ASUP_MISSING')."\n";
}
