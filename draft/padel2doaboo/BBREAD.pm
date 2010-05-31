#!/usr/bin/perl

package BBREAD;

use strict;
use warnings;
use DBI;


sub new{
        my $class=shift;
        my $self={@_};
        bless($self, $class);
        my $dbh=$self->_init;
        return $dbh;
}

sub _type{
					 my $dbh=shift;
   				 unless (ref $dbh){ print "Error, should call rawget() with an object, not a class\n";};
				    my $type=shift;
					 my $mysql_types = {
						  CHAR=>"varchar(250) default ''",
                    INT=>'bigint(20)',
                    DECIMAL=>'decimal(10,2)',
                    FLOAT=>'double',
                    LINK=>'longtext',
                    MEMO=>'longtext',
                    DATE=>'date',
                    TIME=>"time default '00:00:00'",
                    ACCOUNT=>'longtext',
                    OWN_ACCOUNT=>'varchar(250)',
                    BOOLEAN=>'char(1)',
                    AUTO=>'bigint(20)',
						  RELATION =>'varchar(250)',
						  CALCULATED=>'varchar(250)'
						  };
					  my $db_type=$mysql_types->{$type};
					  return $db_type;

}

sub create {
				my $dbh=shift;
				unless (ref $dbh){ print "Error, should call rawget() with an object, not a class\n";};
				my $query=$dbh->prepare("select * from doaboo_topics");
				$query->execute;
				my @topics=$query->fetchall_arrayref;
				foreach my $topic(@topics) {
					foreach my $id(@$topic) {
					my $string='';
					my $i=0;
         		$string.="CREATE TABLE IF NOT EXISTS doaboo_"."@$id[3] ( ";
         		my $query=$dbh->prepare("select * from doaboo_attributes where topic=\'@$id[0]\'");
         		$query->execute;
         		my @columns=$query->fetchall_arrayref;
         		foreach my $column(@columns) {
            		foreach my $name (@$column) {
							if ($i != 0) {
                     	$string.=", ";
                  	}
							$i++;
							$string.="@$name[19]";
							if ((defined @$name[3]) and (@$name[3] ne '')) {
								print "Tipo en XML es: @$name[3]\n";
								my $type=$dbh->BBREAD::_type(@$name[3]);
               			$string.=" $type";
							}
               		if (@$name[5] eq 'Y') {
                  			$string.=" NOT NULL ";
               		}
						}
         		}
   				$string.=" \)";
   				print "$string\n";
   				}
				}	
			  }

sub _init {
	my $dbh=DBI->connect("DBI:mysql:spatest:localhost",'spatest','spatest') or die "Cannot connect to database: $DBI::errstr";
	return $dbh;
}
1;
