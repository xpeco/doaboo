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
# Step 1: get fields from View. No permissions, if the user can see the view also he can see its fields.

#select ADM_VIEW_FIELDS.NAME from ADM_VIEW_FIELDS,ADM_VIEWS where ADM_VIEWS.OBJECT='ALARMS' and ADM_VIEWS.NAME='ALARMS_NEW_ORGANISED' and ((USER_VIEW='aspower' or GROUP_VIEW IN (select ADM_GROUP from ADM_USERS where ADM_LOGIN='aspower')) or (USER_VIEW='' and GROUP_VIEW='')) and ADM_VIEW_FIELDS.ADM_VIEW=concat('[[',ADM_VIEWS.OBJECT,']][[',ADM_VIEWS.NAME,']]');

# Step 2: compose fields section of the query. Add the calculated ('' as calculated). Which fields of the View are calculated?... doaboo_attributes

# Step 3: improve fields with caption and relationships (?). Relationships should be automanage by foreign keys, but for the captions is a 'pseudo-calculated'... Maybe this is the last step.

# Step 4: get restricions by instance, composing the where section of the query. The result of an eval restrictions.

# Step 6: run the query with limit 0,15

# Step 7: calculated the calculates = eval and the captions

# WE AVOID restrictions based on Calculates. We avoid loops


	my $result=$self->{db}->DBCONN::rawget("select NAME.ADM_VIEW_FIELDS from ADM_VIEW_FIELDS,ADM_VIEW where OBJECT.ADM_VIEW=\'$topic\' and NAME.ADM_VIEW=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\)",'ARRAY');
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
#		$result=$self->{db}->DBCONN::rawget("select NAME from ADM_REPORTS where OBJECT=\'$topic\' and \(\(USER_REPORT=\'$self->{login}\' or GROUP_REPORT IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_REPORT=\'\' and GROUP_REPORT=\'\'\)\)",'ARRAY');
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
