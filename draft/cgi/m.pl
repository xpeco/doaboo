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
		if(defined ($subentry->{description})){
				print "	$subentry->{description}\n";
		}
		else{
				print "	$subentry->{name}\n";
		}
		foo($subentry->{name});
	}
}

my $entries=$dbh->DBCONN::rawget('select * from doaboo_menus where parent=\'ROOT\''); # query

foreach my $entry(@$entries)
{
	if(defined ($entry->{description})){
			print "	$entry->{description}\n";
	}
	else{
			print "	$entry->{name}\n";
	}
	foo($entry->{name});
}
