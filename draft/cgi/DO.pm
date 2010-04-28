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
	print "Group2: $self->{group}\n";

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
	my $result=$self->{db}->DBCONN::rawget("select NAME from ADM_VIEWS where OBJECT=\'$topic\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\)",'ARRAY');
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
