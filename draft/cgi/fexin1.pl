#!/usr/bin/perl
use strict;
use warnings;
use FEXIN;

my $code='use FEXIN;my $actual_user=\'roessler\';my $user=EXGet_Instance_List(\'ADM_USERS\',{ADM_LOGIN=>$actual_user},\'NONE\');
if ($user->[0]->{ADM_ORG} ne \'\'){return EXGet_Range_List(\'CONTRACT\',{CUSTOMER=>$user->[0]->{ADM_ORG}});}';

$code=~s/EXGet/FEXIN::EXGet/g;

my $eval=eval $code;
print "R:$eval\n";
