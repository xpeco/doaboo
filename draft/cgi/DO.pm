#!/usr/bin/perl

package DO;
use strict;
use warnings;
use DBCONN;
use USERS;

sub new{
	my $class=shift;
   my $self={@_};
   bless($self, $class);
   $self->_initdb; # Creates the db connection
	$self->_inituser; # Check pass and store the basic user info
   return $self;
}

sub query{
	my $self=shift;
	my $query=shift;
	my $format=shift;
	#print "At q, user: $self->{login} -- here we should check permissions\n";
	# $query->_cleanquery;
	my $result=$self->{db}->DBCONN::rawget($query,$format);
	return $result;
}

sub getviews{
	my $self=shift;
	my $topic=shift;
	my $result=$self->{db}->DBCONN::rawget("select NAME from ADM_VIEWS where OBJECT=\'$topic\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\)",'ARRAY');
	return $result;
}

sub getview{
	my $self=shift;
	my $topic=shift;
	my $view=shift;
	my $result=$self->{db}->DBCONN::rawget("select ADM_VIEW_FIELDS.NAME from ADM_VIEW_FIELDS,ADM_VIEWS where ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or (USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\)",'ARRAY');
	return $result;
}

sub getrecords{
	my $self=shift;
	my $topic=shift;
	my $view=shift;
	my $limit=shift;

# Step 1: get fields and its types from View. No permissions, if the user can see the view also he can see its fields.
# Description should be eq to desc at doaboo!
	my $fields=$self->{db}->DBCONN::rawget("select ADM_VIEW_FIELDS.NAME as name, ADM_VIEW_FIELDS.RANGE_TYPE as range,ADM_VIEW_FIELDS.ORDER as `order`, ADM_VIEW_FIELDS.SHOW as `show`, doaboo_attributes.type as type from ADM_VIEW_FIELDS,ADM_VIEWS,doaboo_attributes where ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\) and doaboo_attributes.description=ADM_VIEW_FIELDS.DESC order by ADM_VIEW_FIELDS.POSITION ASC");

# Step 2: compose fields section of the query. Add the calculated ('' as calculated). Which fields of the View are calculated?... doaboo_attributes. NOT!
# Step 3: improve fields with caption and relationships (?). Relationships should be automanage by foreign keys, but for the captions is a 'pseudo-calculated'... Maybe this is the last step.
	my $select_topics=$topic;
	my $select_fields='';
	my $select_where='';

	foreach my $f(@$fields)
	{
		if ($f->{show} ne 'N')
		{
			if ($f->{'type'} eq 'CALCULATED')
			{
				$select_fields.="'' as $f->{name},";
			}
			elsif ($f->{'type'} eq 'RELATION')
			{
				#$select_fields.="$f->{'ADM_VIEW_FIELDS.NAME'} as ,";
			}
			else
			{
				$select_fields.="$f->{name},";
			}
		}
		if ($f->{range} eq 'EXPRESSION')
		{
				$select_where.=' and $f->{name} in ('.$f->{range}.')';
		}
	}
	$select_fields=~s/\,\Z//;

print "SELECT FIELDS: $select_fields\n";
# Step 3: improve fields with caption and relationships (?). Relationships should be automanage by foreign keys, but for the captions is a 'pseudo-calculated'... Maybe this is the last step.

# Step 4: get restricions by instance, composing the where section of the query. The result of an eval restrictions.
#$self->{group} instead of Customer
	my $restrictions=$self->{db}->DBCONN::rawget("select ADM_RESTRICTION_DETAIL,ADM_RESTRICTION_CODE from ADM_RESTRICTIONS where ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'Customer\' and ADM_RESTRICTION_ELEMENT=\'INSTANCE\'");
	foreach my $r(@$restrictions)
	{
		my $eval;#=eval $r->{ADM_RESTRICTION_CODE};
		print $r->{ADM_RESTRICTION_CODE};

		$select_where.="and $r->{ADM_RESTRICTION_DETAIL} in $eval";
	}

# Step 6: run the query with limit 0,15
# Maybe we should return the query instead of the result in order to make these calcs once by query instead of
# once by 15 records ??

# Step 7: calculated the calculates = eval and the captions

	#my $data= $user->DO::query($query);
   # Add evaluates
   #my $fields=$user->DO::query("select name,calculated_logic from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$table\'\) and type='CALCULATED'");
   #foreach my $d(@$data)
   #{
      #foreach my $field(@$fields)
      #{
      #   $d->{$field->{name}}=eval $field->{calculated_logic};
      #}
   #}
   #return $data;




# WE AVOID restrictions based on Calculates. We avoid loops


	return '1';
}

sub getallrecords{
	my $self=shift;
	my $topic=shift;
	my $result=$self->{db}->DBCONN::rawget("select * from $topic");

	return $result;
}

sub getstored{
	my $self=shift;
	my $topic=shift;
	my $where=shift; # where key='xx'

	my $fields;
	if($self->{factions} eq 'ALLOWANCE')
	{
		print "list of fields allowed - \n";
		$fields=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic=\'$topic\' and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=name and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)",'ARRAY'); 
	}
	else
	{
		$fields=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic=\'$topic\' and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=doaboo_attributes.name and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)",'ARRAY'); 
	}
	$fields=~s/(^\()|(\)\Z)//g;

	my $query="select $fields from $topic where $where limit 1;\n";
	my $result=$self->{db}->DBCONN::rawget($query,'ARRAY');
	return $result;
}

sub getreports{
	my $self=shift;
	my $topic=shift;
	my $result=$self->{db}->DBCONN::rawget("select NAME from ADM_REPORTS where OBJECT=\'$topic\' and \(\(USER_REPORT=\'$self->{login}\' or GROUP_REPORT IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_REPORT=\'\' and GROUP_REPORT=\'\'\)\)",'ARRAY');
	return $result;
}

sub getactions{
	my $self=shift;
	my $topic=shift;
	my $result='';
	if($self->{ractions} eq 'ALLOWANCE')
	{
		print "list of actions allowed - [all actions of the topic - actions listed here]\n";
		$result=$self->{db}->DBCONN::rawget("select NAME from ADM_REPORTS where OBJECT=\'$topic\' and \(\(USER_REPORT=\'$self->{login}\' or GROUP_REPORT IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_REPORT=\'\' and GROUP_REPORT=\'\'\)\)",'ARRAY');
	}
	else
	{
		print "list of actions - [all actions listed here]\n";
	}
	return $result;
}

sub _initdb{
	my $self=shift;
	my $dbh;
	$self->{db}=DBCONN->new();
	return $self;
}

sub _inituser{
	my $self=shift;
	my $user=USERS->new(db=>$self->{db},login=>$self->{login},password=>$self->{password});
	# Compose $self
	foreach my $field (keys %$user){
		$self->{$field}=$user->{$field};
	}
	return $self;
}

sub logout{
	my $self=shift;
	# remove the hash?
	undef $self;
}
1;
