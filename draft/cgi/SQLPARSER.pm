#!/usr/bin/perl -w

package SQLPARSER;
use strict;
use warnings;

sub new{
	my $class=shift;
	my $self={@_};
	bless($self, $class);
   return $self;
}

sub only_select
{
	my $self=shift;
	my $result='OK';
	if($self->{input}!~/\A\s*select.*/i){print "Try only select\n";$result='ERROR';}
	elsif($self->{input}=~/select{2,}/i){print "subselect not supported yet\n";$result='ERROR';}
	elsif($self->{input}=~/\;.*\w+/){print "only one command please\n";$result='ERROR';}
	return $result;
}

sub parse_tables
{
	my $self=shift;
	my $q=$self->{input};
	$q=~s/(.*from )|(where.*)|(\s*)//ig;
	return $q;
}

sub parse_fields
{
	my $self=shift;
	my $q=$self->{input};
	$q=~s/(select )|(from.*)|(\s*)//ig;
	return $q;
}

sub parse_where_fields
{
	my $self=shift;
	my $result='';
	my $q=$self->{input};
	$q=~s/(.*where )|(order.*)|(limit.*)//ig;
	my @where=split(/(\w* *\= *|\w* *\<\> *|\w* *AND *|\w* *OR *|\w* *\<\= *|\w* *\>\= *|\w* *\< *|\w* *\> *|\w* *LIKE *|\w* *CLIKE *|\w* *IS *|\w* *IN *|\w* *BETWEEN *)/i,$q);
	foreach my $w(@where)
	{
		$w=~s/\(|\)| //;
		if ($w=~/(\=|\<\>|AND|OR|\<\=|\>\=|\<|\>|LIKE|CLIKE|IS|IN|BETWEEN)/i)
		{
			$w=~s/(\=|\<\>|AND|OR|\<\=|\>\=|\<|\>|LIKE|CLIKE|IS|IN|BETWEEN| )//gi;
			$result.=$w.',' if $w;
		}
	}
	$result=~s/\,\Z//;
	return $result;
}
1;
