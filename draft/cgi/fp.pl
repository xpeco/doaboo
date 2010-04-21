#!/usr/bin/perl -w
use strict;
use warnings;
use SQLPARSER;
use DBCONN;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft';

my $dbh=DBCONN->new(); # connect
my $ptables=$dbh->DBCONN::rawget('select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_GROUP=\'User\' and ADM_RESTRICTION_ELEMENT=\'OBJECT\'','ARRAY');
my $pfields=$dbh->DBCONN::rawget('select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_GROUP=\'User\' and ADM_RESTRICTION_ELEMENT=\'FIELD\'','ARRAY');

print $ptables;
print $pfields;

my $m='select X,Y from ADM_GROUP where X=\'10\'';


	print "------------------------------------------------\n";
	print "Parsing: $m\n";
	my $query=SQLPARSER->new(input=>$m);
	if($query->only_select eq 'OK'){
		print "Tables:".$query->parse_tables."\n";
		my @tables=split(',',$query->parse_tables);
		foreach my $table(@tables)
		{
			if(grep(/\b$table\b/,$ptables))
			{
				print "Table $table restricted! (query fails)\n";
			}
		}
		print "Fields:".$query->parse_fields."\n";
		my @fields=split(',',$query->parse_fields);
		foreach my $field(@fields)
		{
			if(grep(/\b$field\b/,$pfields))
			{
				print "Field $field restricted! (field removed)\n";
				#
				#my $a='uno,dos,tres';
				#print "$a\n";
				#$a=~s/(uno\,?)//gi;$a=~s/(\,\Z)//gi;
				#print "$a\n";
			}
		}

		print "Where Fields:".$query->parse_where_fields."\n";
		print "Limit section:".$query->parse_limit."\n";
	}
	print "------------------------------------------------\n";


