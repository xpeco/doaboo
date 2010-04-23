#!/usr/bin/perl -w
use strict;
use warnings;
use SQLPARSER;
use DBCONN;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft';

my $dbh=DBCONN->new(); # connect
my $ptables=$dbh->DBCONN::rawget('select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_GROUP=\'User\' and ADM_RESTRICTION_ELEMENT=\'OBJECT\'','ARRAY');
my $pfields=$dbh->DBCONN::rawget('select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_GROUP=\'User\' and ADM_RESTRICTION_ELEMENT=\'FIELD\'','ARRAY');


$ptables='(ADM_USERS,ADM_LOG_INSTANCES,ADM_USERS,ADM_RESTRICTIONS,ADM_GROUPS,MREQUEST_M_,MREQUEST_PPP_)';
$pfields='(X)';


print $ptables;
print "\n";
print $pfields;



my $m='select X,Y from ADM_USER where X=\'10\'';

my $result=$m;
$result=~s/from.*//i;

	print "\n------------------------------------------------\n";
	print "Parsing: $m\n";
	my $query=SQLPARSER->new(input=>$m);
	if($query->_only_select eq 'OK'){
		print "Tables:".$query->_parse_tables."\n";
		my @tables=split(',',$query->_parse_tables);
		foreach my $table(@tables)
		{
			if(grep(/\b$table\b/,$ptables))
			{
				print "Table $table restricted! (query fails)\n";exit;

			}
		}
		print "Fields:".$query->_parse_fields."\n";
		my @fields=split(',',$query->_parse_fields);
		foreach my $field(@fields)
		{
			if(grep(/\b$field\b/,$pfields))
			{
				print "Field $field restricted! (field removed)\n";exit;
				#$pfields=~s/(\A\(|\)\Z)//g;
				#$pfields=~s/(uno\,?)//gi;$pfields=~s/(\,\Z)//gi;
				#$pfields='('.$pfields.')';
			}
		}
		print "Where Fields:".$query->_parse_where_fields."\n";
		my @wfields=split(',',$query->_parse_where_fields);
		foreach my $field(@wfields)
		{
			if(grep(/\b$field\b/,$pfields))
			{
				print "Where Field $field restricted! (query fails)\n";exit;
			}
		}
		print "Limit section:".$query->_parse_limit."\n";
	}
	print "------------------------------------------------\n";


