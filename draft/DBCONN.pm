#!/usr/bin/perl

package DBCONN;

use strict;
use warnings;
use Apache::DBI;

$Apache::DBI::DEBUG = 2; #it works under mod_perl only

sub new{
	my $class=shift;
   my $self={@_};
   bless($self, $class);
   $self->_init; # make the connection
   return $self;
}

sub _init {
 my $dbh = DBI->connect
 ("DBI:mysql:doaboo:localhost", 'doaboo', 'doaboo',
   {
    PrintError => 1, # warn() on errors
    RaiseError => 0, # don't die on error
    AutoCommit => 1, # commit executes immediately
   }
 ) or die "Cannot connect to database: $DBI::errstr";
 return $dbh;
}
1;
