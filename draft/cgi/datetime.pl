#!/usr/bin/perl
use strict;
use warnings;
use DATETIME;
my $date;
my $month=DATETIME::EXDate_Month(DATETIME::EXDate_Today());
my $year=DATETIME::EXDate_Year(DATETIME::EXDate_Today());
if ($month==1){$year--;$month=12}
else{$month--;}

print "D:$month - $year\n";

