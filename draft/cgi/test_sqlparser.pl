#!/usr/bin/perl -w
use strict;
use warnings;
use SQLPARSER;

while(my $m=<STDIN>)
{
	SQLPARSER::test_sql_parser($m);
}


