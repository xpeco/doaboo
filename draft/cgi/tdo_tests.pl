#!/usr/bin/perl

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft'; # recursive config

my $user=DO->new(login=>'spa',password=>'123');
if ($user->{error}) #if (not $user->{error})
{
	my $topics=$user->gettopics;
	foreach my $topic(@$topics)
	{
#my $topic;
#$topic->{name}='ALERTS_LOG';

		print "Topic $topic->{name}\n";
		my $views=$user->getviews($topic->{name});
		foreach my $view(@$views)
		{
			print "	View: $view->{NAME}\n";
			my $query=$user->getrecords($topic->{name},$view->{NAME},'10');
#			print "$query\n";
			#print "Running...";
			my $q=$user->query($query);
			#print "Done\n\n";
		}
	}
}
