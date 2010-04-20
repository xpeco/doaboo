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
	print "At q, user: $self->{login} -- here we should check permissions\n";
	# $query->_cleanquery;
	my $result=$self->{db}->DBCONN::rawget($query,$format);
	return $result;
}

sub _cleanquery{
# This subroutine receives a Query from Pulso to process it according to the permissions.
# 1.- Remove the Q to forbidden Tables/Objects
# 2.- Remove forbidden fields from Q
# 3.- Add calculated values
# 4.- Add ranges (permissions based on INSTANCES)
# Finally, it returns a cleaned Q or 1 if it fails. 
	my $query=shift;
	my $object=$query;
	$object=~s/.*FROM //s;
 	$object=~s/( WHERE.*| ORDER.*)//s; # got the Object from the Q
	my $result=$self->{db}->DBCONN::rawget('select ADM',$format);



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
	if ($user->check() ne 'OK'){ 
		print "not valid user...\n";
	}
	$self->{login}=$user->{user}->[0]->{ADM_LOGIN};
	$self->{group}=$user->{user}->[0]->{ADM_GROUP};
	$self->{name}=$user->{user}->[0]->{ADM_NAME};
#	$self->{organization}=$user->{user}->[0]->{ADM_ORG};
#	$self->{status}=$user->{user}->[0]->{ADM_STATUS};
	return $self;
}
1;
