#!/usr/bin/perl
#use strict;
#use warnings;
use DATETIME;

my $date='2010-06-01';
my $prev_date=DATETIME::EXDate_Add($date,'-7days');
print "D:$prev_date\n";

