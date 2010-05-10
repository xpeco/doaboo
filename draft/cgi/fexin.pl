#!/usr/bin/perl
use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft'; # recursive config
my $user=DO->new(login=>'roessler',password=>'123');
my $actual_user='spa';

sub EXGet_Instance_List
{
	my ($table, $ranges, $speed) = @_;
	my $where='where ';
	foreach my $range(keys %$ranges)
	{
		$where.="$range = $ranges->{$range} and\n";
	}
	$where=~s/ and\Z//;
	my $query='';
	if ($where=~/where \Z/)
	{
		$query="select * from $table where $where";
	}
	else
	{
		$query="select * from $table";
	}
	return $user->DO::query($query);
}

my $r=EXGet_Instance_List('ADM_USERS',{ADM_LOGIN=>$actual_user},'NONE');
if ($r->[0]->{ADM_LOGIN} ne ''){print "$r->[0]->{ADM_LOGIN}\n";}
#return EXGet_Range_List('CONTRACT',{CUSTOMER=>$user->[0]->{ADM_ORG}});

