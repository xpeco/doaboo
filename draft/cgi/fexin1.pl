#!/usr/bin/perl
use strict;
use warnings;
use FEXIN;

my $code='
use FEXIN;use DATETIME;
my $actual_user=\'spa\';
my $messages=EXGet_Instance(\'MESSAGE\',{},{IN_DATE=>\'DESC\',NUMBER=>\'ASC\'},\'NONE\',1);
my $prev_date=EXDate_Add($messages->[0]->{IN_DATE},\'-7days\');
return $prev_date;
#return $messages;
';

$code=~s/EXGet/FEXIN::EXGet/g;
$code=~s/EXDate/DATETIME::EXDate/g;
my $eval=eval $code;
print "R:$eval\n";
