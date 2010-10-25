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
# Raw SQL query without permissions
	my $self=shift;
	my $query=shift;
	my $format=shift;
	my $result=$self->{db}->DBCONN::rawget($query,$format);
	$result="Error in query: $DBI::errstr" if $DBI::err;
	return $result;
}

sub _checktopic
{
	my $self=shift;
	my $topic=shift;
	my $result;
	if($self->{rtopics} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select id, name as NAME, hint as HINT, description as `DESC` from doaboo_topics where name=\'$topic\' and name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'OBJECT\' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
		if ($result->[0]->{id} ne '') {return $result->[0];}
		else { return 'DENIED';}
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select id, name as NAME, hint as HINT, description as `DESC` from doaboo_topics where name=\'$topic\' and name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'OBJECT\' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
		if ($result->[0]->{id} ne '') {return $result->[0];}
		else { return 'DENIED';}
	}
}

sub _checkfields
{
	my $self=shift;
	my $topic_id=shift;
	my $result;
	if($self->{rfields} eq 'ALLOWANCE')
	{
		$result->{ATTRIBUTE}=$self->{db}->DBCONN::rawget("select *,name as NAME,description as `DESC`, hint as HINT from doaboo_attributes where topic=\'$topic_id\' and  name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'FIELD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result->{ATTRIBUTE}=$self->{db}->DBCONN::rawget("select *,name as NAME,description as `DESC`, hint as HINT from doaboo_attributes where topic=\'$topic_id\' and  name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'FIELD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
}

sub _checkfield
{
	my $self=shift;
	my $topic_id=shift;
	my $field_id=shift;
	my $result;
	if($self->{rfields} eq 'ALLOWANCE')
	{
		$result->{ATTRIBUTE}=$self->{db}->DBCONN::rawget("select *,name as NAME,description as `DESC`, hint as HINT from doaboo_attributes where topic=\'$topic_id\' and id=\'$field_id\' and name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'FIELD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
		if ($result->[0]->{id} ne '') {return $result->[0];}
		else { return 'DENIED';}
	}
	else
	{
		$result->{ATTRIBUTE}=$self->{db}->DBCONN::rawget("select *,name as NAME,description as `DESC`, hint as HINT from doaboo_attributes where topic=\'$topic_id\' and id=\'$field_id\' and name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'FIELD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
		if ($result->[0]->{id} ne '') {return $result->[0];}
		else { return 'DENIED';}
	}
}

sub _checkactions
{
	my $self=shift;
	my $topic_id=shift;
	my $result;
	if($self->{ractions} eq 'ALLOWANCE')
	{
		$result->{METHOD}=$self->{db}->DBCONN::rawget("select *, name as NAME,description as `DESC`, hint as HINT from doaboo_actions where topic=\'$topic_id\' and name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'METHOD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result->{METHOD}=$self->{db}->DBCONN::rawget("select *, name as NAME,description as `DESC`, hint as HINT from doaboo_actions where topic=\'$topic_id\' and name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'METHOD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
}

sub _checkaction
{
	my $self=shift;
	my $topic_id=shift;
	my $action_id=shift;
	my $result;	
	if($self->{ractions} eq 'ALLOWANCE')
	{
		$result->{METHOD}=$self->{db}->DBCONN::rawget("select *, name as NAME,description as `DESC`, hint as HINT from doaboo_actions where topic=\'$topic_id\' and id=\'$action_id\' name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'METHOD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
		if ($result->[0]->{id} ne '') {return $result->[0];}
		else { return 'DENIED';}
	}
	else
	{
		$result->{METHOD}=$self->{db}->DBCONN::rawget("select *, name as NAME,description as `DESC`, hint as HINT from doaboo_actions where topic=\'$topic_id\' and id=\'$action_id\' name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'METHOD\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
		if ($result->[0]->{id} ne '') {return $result->[0];}
		else { return 'DENIED';}
	}
}

sub gettopics{
# Returns the list of available Topics
	my $self=shift;
	my $result;
	if($self->{rtopics} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select *,name AS NAME,description as `DESC` from doaboo_topics where name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'OBJECT\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select *,name as NAME,description as `DESC` from doaboo_topics where name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'OBJECT\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}

sub gettopic{
# Returns the structure of a Topic
	my $self=shift;
	my $topic=shift;
	my $result;

	$result=$self->checktopic($topic);
	if($result ne 'DENIED')
	{
		$result->{ATTRIBUTE}=$self->_checkfields($result->{id});
		$result->{METHOD}=$self->_checkactions($result->{id});
	}
	return $result;
}


sub getviews{
# Returns the list of available Views
	my $self=shift;
	my $topic=shift;
	my $result=$self->{db}->DBCONN::rawget("select `OBJECT`,`NAME`,`DESC`,`HINT` from ADM_VIEWS where OBJECT=\'$topic\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\)");
	return $result;
}

sub getview{
# Returns the details of a View
	my $self=shift;
	my $topic=shift;
	my $view=shift;
	my $result=$self->{db}->DBCONN::rawget("select ADM_VIEW_FIELDS.NAME as NAME,ADM_VIEW_FIELDS.POSITION as POSITION, ADM_VIEW_FIELDS.DESC as `DESC`,ADM_VIEW_FIELDS.HINT from ADM_VIEW_FIELDS,ADM_VIEWS where ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or (USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\)");
	return $result;
}

sub getrelationsto{
# Returns the relationships to where the topic points
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
# Returns the relationships from where the topic points
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

sub getscripts{
# Returns the list of available Scripts
	my $self=shift;
	my $result;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_scripts where name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'SCRIPT\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_scripts where name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'SCRIPT\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}

sub getalarms{
# Returns the list of available Alarms
	my $self=shift;
	my $result;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_alarms where name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'ALARM\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_alarms where name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'ALARM\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
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
	my $result;

	my $check=$self->_checktopic($topic);
	if($check ne 'DENIED')
	{
		$result=$self->_checkactions($check->{id});
	}
	return $result;
}

sub getaction{
	my $self=shift;
	my $topic=shift;
	my $action=shift;
	my $result='DENIED';

	my $check=$self->_checktopic($topic);
#	if($check ne 'DENIED')
#	{
		$result=$self->_checkaction($check->{id},$action);
		return $result;
#	}
#	return $result;
}


sub _calcexp{
	my $field=shift;
	my $expression=shift;

	my $select_where;
	if($expression=~/\[.*\]/) #[2010-05-01,2010]
	{
		my $first=$expression;
		$first=~s/\!|\[|\,.*//g;
		my $second=$expression;
		$second=~s/\!|\[.*\,|\]//g;
		if($expression=~/\!.*/)
		{
			$select_where.="`$field` <= \'$first\' and `$field` >= \'$second\' and ";
   	}
		else
		{
			$select_where="`$field` >= \'$first\' and `$field` <= \'$second\' and ";
		}
	}
	else
	{
		$expression=~s/\,/\|/g;
		$select_where.="`$field` regexp \'$expression\' and ";
	}

	return $select_where;
}

sub _calccode{
	my $login=shift;
	my $field=shift;
	my $expression=shift;

	my $select_where;

	$expression="use FEXIN;use DATETIME;my \$actual_user='$login';".$expression;
	$expression=~s/EXGet/FEXIN::EXGet/g;
	$expression=~s/EXDate/DATETIME::EXDate/g;

	my $eval=eval $expression;

	#FIX (,) by ( )
	$eval=~s/\(\,\)/\( \)/;
	#
	return _calcexp($field,$eval);
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
	# disconnect DB?
	undef $self;
}
1;
