#!/usr/bin/perl
package FEXIN;
use strict;
use warnings;
use DBCONN;

sub EXGet_Instance_List
{
	my ($table, $ranges, $speed) = @_;
   my $dbh=DBCONN->new(); # connect

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
	my $data=$dbh->DBCONN::rawget($query);
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
   my $dbh=DBCONN->new(); # connect

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
	my $data= $dbh->DBCONN::rawget($query);
	# Add evaluates
	my $fields=$dbh->DBCONN::rawget("select name,calculated_logic from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$table\'\) and type='CALCULATED'");
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
   my $dbh=DBCONN->new(); # connect

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
	return $dbh->DBCONN::rawget($query,'ARRAY');
}
$ENV{DOABOOPATH}='/home/peco/doaboo/draft';
print "Using FEXIN\n";
1;
