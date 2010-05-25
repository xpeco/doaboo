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
	my $result=$self->{db}->DBCONN::rawget("select `OBJECT`,`NAME`,`DESC`,`HINT` from ADM_VIEWS where OBJECT=\'$topic\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\)");
	return $result;
}

sub getview{
	my $self=shift;
	my $topic=shift;
	my $view=shift;
	my $result=$self->{db}->DBCONN::rawget("select ADM_VIEW_FIELDS.NAME as NAME,ADM_VIEW_FIELDS.POSITION as POSITION, ADM_VIEW_FIELDS.DESC as `DESC`,ADM_VIEW_FIELDS.HINT from ADM_VIEW_FIELDS,ADM_VIEWS where ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or (USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\)");
	return $result;
}

sub getrelationsto{
	my $self=shift;
	my $topic=shift;
	my $result;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and topic in (select id from doaboo_topics where name=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and topic in (select id from doaboo_topics where name=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}

sub getrelationsfrom{
	my $self=shift;
	my $topic=shift;
	my $result;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and relation in (select id from doaboo_topics where name=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and relation in (select id from doaboo_topics where name=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}


sub getrecords{
	my $self=shift;
	my $topic=shift;
	my $view=shift;
	my $limit=shift;

# Step 1: get fields and its types from View. No permissions, if the user can see the view also he can see its fields.
# Description should be eq to desc at doaboo!
	my $fields=$self->{db}->DBCONN::rawget("select ADM_VIEW_FIELDS.NAME as name, ADM_VIEW_FIELDS.RANGE_TYPE as range, ADM_VIEW_FIELDS.RANGE as expression, ADM_VIEW_FIELDS.ORDER as `order`, ADM_VIEW_FIELDS.SHOW as `show`, doaboo_attributes.type as type, relation, topic from ADM_VIEW_FIELDS,ADM_VIEWS,doaboo_attributes where doaboo_attributes.type <> 'CALCULATED\' and ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\) and doaboo_attributes.description=ADM_VIEW_FIELDS.DESC order by ADM_VIEW_FIELDS.POSITION ASC");
#print "########################\n";
#print "select ADM_VIEW_FIELDS.NAME as name, ADM_VIEW_FIELDS.RANGE_TYPE as range, ADM_VIEW_FIELDS.RANGE as expression, ADM_VIEW_FIELDS.ORDER as `order`, ADM_VIEW_FIELDS.SHOW as `show`, doaboo_attributes.type as type, relation, topic from doaboo_topics,ADM_VIEW_FIELDS,ADM_VIEWS,doaboo_attributes where doaboo_attributes.type <> 'CALCULATED\' and ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\) and doaboo_attributes.description=ADM_VIEW_FIELDS.DESC order by ADM_VIEW_FIELDS.POSITION ASC\n";

#print "########################\n";

# Step 2: compose fields section of the query. Add the calculated ('' as calculated). Which fields of the View are calculated?... doaboo_attributes. NOT!
# Step 3: improve fields with caption and relationships (?). Relationships should be automanage by foreign keys, but for the captions is a 'pseudo-calculated'... Maybe this is the last step.
	my @topics;
	push(@topics,$topic);
	my $select_topics='';
	my $select_fields='';
	my $select_where='';

	foreach my $f(@$fields)
	{
		if ($f->{show} ne 'N')
		{
			if ($f->{type} eq 'RELATION')
			{
				my $topicname=$self->{db}->DBCONN::rawget("select name from doaboo_topics where id=\'$f->{relation}\' limit 1");
				$select_fields.="$topicname->[0]->{name}.$f->{name}, ";
				push(@topics,$topicname->[0]->{name}) if (not grep(/^$topicname->[0]->{name}$/,@topics));

				if ($f->{range} eq 'EXPRESSION')
				{print "DENT: $topicname->[0]->{name}\n";
					$select_where.="$topicname->[0]->{name}.$f->{name} in (\'$f->{expression}\') and";
				}
			}
			else
			{
				$select_fields.="$topic.$f->{name}, ";
				if ($f->{range} eq 'EXPRESSION')
				{print "DENTRO\n";
					$select_where.="$topic.$f->{name} in (\'$f->{expression}\') and";
				}
			}
		}
	}

	$select_where=~s/and\Z//;
	$select_fields=~s/\, \Z//;
	foreach my $t(@topics)
	{
		$select_topics.=$t.',';
	}
	$select_topics=~s/\,\Z//;
#print "SELECT FIELDS: $select_fields\n";
# Step 3: improve fields with caption and relationships (?). Relationships should be automanage by foreign keys, but for the captions is a 'pseudo-calculated'... Maybe this is the last step.

# Step 4: get restricions by instance, composing the where section of the query. The result of an eval restrictions.
#$self->{group} instead of Customer
	my $restrictions=$self->{db}->DBCONN::rawget("select ADM_RESTRICTION_DETAIL,ADM_RESTRICTION_CODE from ADM_RESTRICTIONS where ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'Customer\' and ADM_RESTRICTION_ELEMENT=\'INSTANCE\'");
	foreach my $r(@$restrictions)
	{
		my $eval='EE';#=eval $r->{ADM_RESTRICTION_CODE};
		print "-------------\n";
		print "$r->{ADM_RESTRICTION_CODE}\n";
		print "-------------\n";
		$select_where.="and $r->{ADM_RESTRICTION_DETAIL} in $eval";

	}

	my $query="select $select_fields from $select_topics where $select_where";
	return $query;
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
		$fields=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=name and ADM_RESTRICTION_GROUP=\'$self->{group}\'\) and type<>\'CALCULATED\'",'SQL'); 
	}
	else
	{
		$fields=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=doaboo_attributes.name and ADM_RESTRICTION_GROUP=\'$self->{group}\'\) and type<>\'CALCULATED\'",'SQL'); 
	}

	my $query="select $fields from $topic where $where limit 1;";
print "Query: $query\n";

	my $result=$self->{db}->DBCONN::rawget($query,'ARRAY');
	return $result;
}

sub getreports{
	my $self=shift;
	my $topic=shift;
	my $result=$self->{db}->DBCONN::rawget("select NAME,OBJECT,`DESC`,HINT from ADM_REPORTS where OBJECT=\'$topic\' and \(\(USER_REPORT=\'$self->{login}\' or GROUP_REPORT IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_REPORT=\'\' and GROUP_REPORT=\'\'\)\)");
	return $result;
}

sub getactions{
	my $self=shift;
	my $topic=shift;
	my $result='';
	if($self->{ractions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select `id`,`description`,`hint` from doaboo_actions where topic in \(select id from doaboo_topics where `NAME`=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='METHOD' and ADM_RESTRICTION_OBJECTS='FILER' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select `id`,`description`,`hint` from doaboo_actions where topic in \(select id from doaboo_topics where `NAME`=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='METHOD' and ADM_RESTRICTION_OBJECTS='FILER' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
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
