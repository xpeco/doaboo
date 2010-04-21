#!/usr/bin/perl -w
use strict;
use warnings;
use SQLPARSER;

while(my $m=<STDIN>)
{
	print "------------------------------------------------\n";
	print "Parsing: $m\n";
	my $query=SQLPARSER->new(input=>$m);
	if($query->only_select eq 'OK'){
		print "Tables:".$query->parse_tables."\n";
		print "Fields:".$query->parse_fields."\n";
		print "Where Fields:".$query->parse_where_fields."\n";
	}
	print "------------------------------------------------\n";
}
