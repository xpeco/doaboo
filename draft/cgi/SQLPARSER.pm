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

sub _only_select
{
	my $self=shift;
	my $result='OK';
	if($self->{input}!~/\A\s*select.*/i){print "Try only select\n";$result='ERROR';}
	elsif($self->{input}=~/(\w+.*select)/i){print "subselect not supported yet\n";$result='ERROR';}
	elsif($self->{input}=~/\;.*\w+/){print "only one command please\n";$result='ERROR';}
	return $result;
}

sub _parse_tables
{
	my $self=shift;
	my $q=$self->{input};
	$q=~s/(.*from )|(where.*)|(limit.*)|(\s*)//ig;
	return $q;
}

sub _parse_fields
{
	my $self=shift;
	my $q=$self->{input};
	$q=~s/(select )|(from.*)|(\s*)//ig;
	return $q;
}

sub _parse_where_fields
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

sub _parse_limit
{
	my $self=shift;
	my $q=$self->{input};
	
	$q=~s/(.*limit )//ig;
	if ($&) {$q=~s/\;//;return $q;}
	else {return '';}
}

sub test_sql_parser
{
	my $input=shift;
	print "------------------------------------------------\n";
   print "Parsing: $input\n";
   my $query=SQLPARSER->new(input=>$input);
   if($query->_only_select eq 'OK'){
      print "Tables:".$query->_parse_tables."\n";
      print "Fields:".$query->_parse_fields."\n";
      print "Where Fields:".$query->_parse_where_fields."\n";
      print "Limit section:".$query->_parse_limit."\n";
   }
   print "------------------------------------------------\n";

}
1;
