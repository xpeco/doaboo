#!/usr/bin/perl

package DBCONN;

use strict;
use warnings;
use Apache::DBI;
use XML::Simple;

$Apache::DBI::DEBUG = 2; #it works under mod_perl only

sub new{
	my $class=shift;
   my $self={@_};
   bless($self, $class);
   $self->_init; # make the connection
   return $self;
}

sub rawget
# Makes queries to the database (db) returning the rows in the
# same way the EXIN functions do.
{
	my $dbh=shift;
	unless (ref $self){
      print "Error, should call surname() with an object, not a class";
   }
	my $query=shift;
	my $format=shift;
 	my $do=$dbh->prepare($query);
 	$do->execute;
	if (not defined $format){return $do->fetchall_arrayref({});}
	elsif ($format eq 'ARRAY'){
		my $list='(';
		while(my @e=$do->fetchrow_array){$list.=$e[0].',';}
		$list=~s/\,\Z/\)/;
		if($list eq '('){$list='()';} # if no results come from the Q
		return $list;
 	}
	elsif ($format eq 'YARRA'){
   	my $list=')';
		while(my @e=$do->fetchrow_array){$list=','.$e[0].$list;}
		$list=~s/\A\,/\(/;
		if($list eq ')'){$list='()';} # if no results come from the Q
		return $list;
	}
	else {return $do->fetchall_arrayref({});}
}

sub _init {
	my $conf=XML::Simple::XMLin("./doaboo.conf");
	my $dbh = DBI->connect("DBI:mysql:$conf->{DDBB}->{NAME}:$conf->{DDBB}->{HOST}", $conf->{DDBB}->{USER},$conf->{DDBB}->{PASS},
		{
			PrintError => 1, # warn() on errors
			RaiseError => 0, # don't die on error
			AutoCommit => 1, # commit executes immediately
   	}
 		) or die "Cannot connect to database: $DBI::errstr";
	return $dbh;
}
1;
