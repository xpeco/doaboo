#!/usr/bin/perl
use strict;
use warnings;
use FEXIN;

my $code='
use FEXIN;use DATETIME;my $actual_user=\'spa\';
my $date;
my $month=EXDate_Month(EXDate_Today());
my $year=EXDate_Year(EXDate_Today());
if ($month==1){
	$year=$year-1;
	$month=12;
}
else{$month--;}
return $month;
my $range="(";
for (my $i=1;$i <=31; $i++) {
$range.=$year.\'-\'.$month.\'-\'.$i.\',\';
}
$range=~s/\,$/\)/;
my $id=EXGet_Range_List(\'SUPPORT\',{CLOSE_DATE=>$range,STATUS=>\'(CLOSED,MOVE TO PRODUCTION,MOVED)\'});
my
$id2=EXGet_Range_List(\'SUPPORT\',{SOLUTION_DATE=>$range,STATUS=>\'(SOLUTION PROVIDED,MOVE TO PRODUCTION,MOVED)\'});
$id.=$id2;
$id=~s/\)\(/\,/;
return $id;
';

$code=~s/EXGet/FEXIN::EXGet/g;
$code=~s/EXDate/DATETIME::EXDate/g;

my $eval=eval $code;
print "R:$eval\n";
