#!/usr/bin/perl

package DB_UPDATE;

#use strict;
use warnings;
use DBI;


sub new{
        my $class=shift;
        my $self={@_};
        bless($self, $class);
        my $dbh=$self->_init; # make the connection
        return $dbh;
}

sub get_id {
				my $dbh=shift;
        		unless (ref $dbh){ print "Error, should call rawget() with an object, not a class\n";};
				my $item=shift;
            my $query=$dbh->prepare("select id from doaboo_topics where name=\'$item->{NAME}\'");
      		$query->execute;
      		my @id_item=$query->fetchrow_array;
				return $id_item[0];
}

sub create {
				my $dbh=shift;
				unless (ref $dbh){ print "Error, should call rawget() with an object, not a class\n";};
				my $item=shift;
				$item->{DESC} = $item->{NAME} if not defined $item->{DESC};
				$item->{HINT} = '' if not defined $item->{HINT};
				my $query=$dbh->prepare("insert into doaboo_topics set name=\'$item->{NAME}\',description=\'$item->{DESC}\',hint=\'$item->{HINT}\'")->execute;
				}

sub update {
				my $dbh=shift;
				unless (ref $dbh){ print "Error, should call rawget() with an object, not a class\n";};
	         my $item=shift;
				my $id=shift;
   	      $item->{DESC} = $item->{NAME} if not defined $item->{DESC};
      	   $item->{HINT} = '' if not defined $item->{HINT};
 				my $query=$dbh->prepare("update doaboo_topics set name=\'$item->{NAME}\',description=\'$item->{DESC}\',hint=\'$item->{HINT}\' where id=\'$id'")->execute;
				}


sub _init {
			  my $dbh=DBI->connect("DBI:mysql:spatest:localhost",'spatest','spatest') or die "Cannot connect to database: $DBI::errstr";
			  return $dbh;
			 }
1;
