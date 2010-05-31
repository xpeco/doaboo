#!/usr/bin/perl

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft'; # recursive config

my $user=DO->new(login=>'spa',password=>'123');
if ($user->{error}) #if (not $user->{error})
{
	my $topic='FILER';
	
	my $views=$user->getviews($topic);
	foreach my $view(@$views)
	{
		print "View: $view->{NAME}\n";
		my $query=$user->getrecords($topic,$view->{NAME});
		print "$query\n\n";
	}
}
