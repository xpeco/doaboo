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
		if($ranges->{$range}=~/\.\*/)
		{
			$where.=" $range like \'%\' and";
		}
		elsif($ranges->{$range}=~/\(.*\)/)
		{
			if($ranges->{$range} ne '()')
			{
				$ranges->{$range}=~s/w*/'/g;$ranges->{$range}=~s/(\A')|('\Z)//g;
				$where.=" $range in \'$ranges->{$range}\' and";
			}
			else
			{
				$where.=" $range in () and";
			}
		}
		elsif($ranges->{$range}=~/^\!.*/)
		{
			$ranges->{$range}=~s/^\!//;
			$where.=" $range not in (\'$ranges->{$range}\') and";
		}
		elsif($ranges->{$range}=~/^\(\!.*\)/)
		{
			$ranges->{$range}=~s/^\(\!/\(/;
			$where.=" $range not in \'$ranges->{$range}\' and";
		}

		else
		{
			$where.=" $range = \'$ranges->{$range}\' and";
		}
	}
	$where=~s/ and\Z//;
	my $query='';
	if ($where!~/where \Z/)
	{
		$query="select * from $table $where";
	}
	else
	{
		$query="select * from $table";
	}
	my $data=$user->DO::query($query);
print "$where\n";
	# Add evaluates
	# build edited/stored variables
#	my $stored=$user->DO::query("select * from \'$table\' $where");
#	my $fields=$user->DO::query("select * from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$table\'\) and type <> 'CALCULATED'");

#	my $stored;
#	foreach my $field(@$field)
#	{
#		foreach my $st(@$stored)
#		{
#				$stored->{$field->{name}}=$st->{$field->{name}};
#		}
#	}
#	$fields=$user->DO::query("select name,calculated_logic from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$table\'\) and type='CALCULATED'");
#	foreach my $d(@$data)
#	{
#		foreach my $field(@$fields)
#		{
#			$d->{$field->{name}}=eval $field->{calculated_logic};
#		}
#	}
	return $data;
}

sub EXGet_Instance
{
	my ($table, $ranges, $orders, $speed) = @_;
	my $where='where ';
	foreach my $range(keys %$ranges)
	{
		if($ranges->{$range}=~/\.\*/)
		{
			$where.=" $range like \'%\' and";
		}
		elsif($ranges->{$range}=~/\(.*\)/)
		{
			if($ranges->{$range} ne '()')
			{
				$ranges->{$range}=~s/w*/'/g;$ranges->{$range}=~s/(\A')|('\Z)//g;
				$where.=" $range in \'$ranges->{$range}\' and";
			}
			else
			{
				$where.=" $range in () and";
			}
		}
		elsif($ranges->{$range}=~/^\!.*/)
		{
			$ranges->{$range}=~s/^\!//;
			$where.=" $range not in (\'$ranges->{$range}\') and";
		}
		elsif($ranges->{$range}=~/^\(\!.*\)/)
		{
			$ranges->{$range}=~s/^\(\!/\(/;
			$where.=" $range not in \'$ranges->{$range}\' and";
		}

		else
		{
			$where.=" $range = \'$ranges->{$range}\' and";
		}
	}
	$where=~s/ and\Z//;
	my $order='order by ';
	foreach my $ord(keys %$orders)
	{
		$order.=" $ord $orders->{$ord} and";
	}
	$order=~s/ and\Z//;
	my $query='';
	if ($where!~/where \Z/)
	{
		$query="select * from $table $where";
	}
	else
	{
		$query="select * from $table";
	}
	if ($order!~/order by \Z/)
	{
		$query.=" $order";
	}
	my $data= $user->DO::query($query);
	# Add evaluates
	my $fields=$user->DO::query("select name,calculated_logic from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$table\'\) and type='CALCULATED'");
	foreach my $d(@$data)
	{
		foreach my $field(@$fields)
		{
			$d->{$field->{name}}=eval $field->{calculated_logic};
		}
	}
	return $data;
}

sub EXGet_Range_List
{
	my ($table, $ranges, $orders, $speed) = @_;
	my $where='where ';
	foreach my $range(keys %$ranges)
	{
		if($ranges->{$range}=~/\.\*/)
		{
			$where.=" $range like \'%\' and";
		}
		elsif($ranges->{$range}=~/\(.*\)/)
		{
			$where.=" $range in \'$ranges->{$range}\' and";
		}
		elsif($ranges->{$range}=~/^\!.*/)
		{
			$ranges->{$range}=~s/^\!//;
			$where.=" $range not in (\'$ranges->{$range}\') and";
		}
		elsif($ranges->{$range}=~/^\(\!.*\)/)
		{
			$ranges->{$range}=~s/^\(\!/\(/;
			$where.=" $range not in \'$ranges->{$range}\' and";
		}
		else
		{
			$where.=" $range = \'$ranges->{$range}\' and";
		}
	}
	$where=~s/ and\Z//;
	my $query='';
	if ($where!~/where \Z/)
	{
		$query="select * from $table $where";
	}
	else
	{
		$query="select * from $table";
	}
print "Query: $query\n";
	return $user->DO::query($query,'ARRAY');
}


#my $r=EXGet_Instance_List('ADM_USERS',{ADM_LOGIN=>$actual_user},'NONE');
#if ($r->[0]->{ADM_LOGIN} ne ''){print "$r->[0]->{ADM_GROUP}\n";}
#$r=EXGet_Instance('ADM_USERS',{ADM_LOGIN=>'amassey',ADM_GROUP=>'.*'},{ADM_GROUP=>'ASC'},'NONE');
#if ($r->[0]->{ADM_LOGIN} ne ''){print "$r->[0]->{ADM_GROUP}\n";}

#$r=EXGet_Range_List('CONTRACT',{CUSTOMER=>$r->[0]->{ADM_ORG}});
#print "$r\n";





my $filers=EXGet_Range_List('FILER',{STATUS=>'Active',IN_DATE=>'0000-00-00',START_DATE=>'!0000-00-00'});
print "$filers\n";
