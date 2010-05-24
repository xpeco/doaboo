#!/usr/bin/perl

use strict;
use warnings;
use DBCONN;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft';

my $dbh=DBCONN->new(); # connect

sub foo
{
	my $parent=shift;
	my $subentries=$dbh->DBCONN::rawget("select * from doaboo_menus where parent=\'$parent\'"); # query
	foreach my $subentry(@$subentries)
	{
		print "	$subentry->{description}\n";
		foo($subentry->{name});
	}
}

my $entries=$dbh->DBCONN::rawget('select * from doaboo_menus where parent=\'ROOT\''); # query

foreach my $entry(@$entries)
{
	print "$entry->{description}\n";
	foo($entry->{name});
}
