#!/usr/bin/perl

package USERS;
use DBCONN;
use Crypt::CBC;
use strict;
use warnings;

sub new{
	my $class=shift;
   my $self={@_};
   bless($self, $class);
   $self->_init($self->{db});
   return $self;
}

#sub login {
#	my $self=shift;
#	unless (ref $self){
#      print "Error, should call login() with an object, not a class";
#   }
#	my $login=shift;
#	$self->{login}=$login if defined $login;
#	return $self->{login};
#} 

#sub password {
#	my $self=shift;
#	unless (ref $self){
#      print "Error, should call password() with an object, not a class";
#   }
#	my $password=shift;
#	$self->{password}=$password if defined $password;
#	return $self->{password};
#} 

#sub group {
#	my $self=shift;
#	unless (ref $self){
#      print "Error, should call group() with an object, not a class";
#   }
#	my $group=shift;
#	$self->{adm_group}=$group if defined $group;
#	return $self->{group};
#} 

sub _encrypt
{
	my $self=shift;
	unless (ref $self){
      print "Error, should call setuser() with an object, not a class";
   }
	my $cipher = Crypt::CBC->new(-key => 'my secret key',-cipher => 'Blowfish');
	return  $cipher->encrypt($self->{password});
}


sub check {
	my $self=shift;
	if($self->{adm_password} eq $self->_encrypt){print "Eq\n";}
	else {return "FAIL";}
	return 'OK';
}

sub _init{
	my $self=shift;
	my $user=$self->{db}->DBCONN::rawget('select ADM_PASSWORD,ADM_GROUP,ADM_NAME,ADM_RESTRICTIONS_METHOD,ADM_RESTRICTIONS_FIELD,INITIAL_OBJECT,INITIAL_VIEW,INITIAL_METHOD,INIT_FUNCTION,WIKI_USER,ADM_LANGUAGE,ADM_INST_PER_PAGE,ADM_AUTOMARK_REL,ADM_INIT_EDITOR from ADM_USERS,ADM_GROUPS where ADM_LOGIN=\''.$self->{login}.'\' and ADM_GROUP=ADM_GROUP_NAME and ADM_ENABLE=\'Y\' limit 1');
	$self->{error}=1;
	$self->{adm_password}=$user->[0]->{ADM_PASSWORD};
	if ($self->check() ne 'OK'){ 
		$self->{error}='Not valid user';
		print "Not valid user\n";
	}

	$self->{name}=$user->[0]->{ADM_NAME};
	$self->{group}=$user->[0]->{ADM_GROUP};
	$self->{adm_password}=$user->[0]->{ADM_PASSWORD};
	$self->{ractions}=$user->[0]->{ADM_RESTRICTIONS_METHOD};
	$self->{factions}=$user->[0]->{ADM_RESTRICTIONS_FIELD};
	$self->{itopic}=$user->[0]->{INITIAL_OBJECT};
	$self->{iview}=$user->[0]->{INITIAL_VIEW};
	$self->{language}=$user->[0]->{ADM_LANGUAGE};
	$self->{ipp}=$user->[0]->{ADM_INST_PER_PAGE};

	return $self;
}
1;
