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
                    INT=>"bigint(20) default '0'",
                    DECIMAL=>"decimal(10,2) default '0.00'",
                    FLOAT=>"double default '0'",
                    LINK=>"longtext default ''",
                    MEMO=>"longtext default ''",
                    DATE=>"date default '0000-00-00'",
                    TIME=>"time default '00:00:00'",
                    ACCOUNT=>"longtext default ''",
                    OWN_ACCOUNT=>"varchar(250) default ''",
                    BOOLEAN=>"char(1) default 'N'",
                    AUTO=>"bigint(20) default '0'",
						  RELATION =>"bigint(20) default '0'",
						  CALCULATED=>"varchar(250)default ''"
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
         		$string.="CREATE TABLE IF NOT EXISTS `DoABoo`."."`@$id[3]` ( ";
         		my $query=$dbh->prepare("select * from doaboo_attributes where topic=\'@$id[0]\'");
         		$query->execute;
         		my @columns=$query->fetchall_arrayref;
         		foreach my $column(@columns) {
            		foreach my $name (@$column) {
							if ($i != 0) {
                     	$string.=", ";
                  	}
							$i++;
							$string.="`@$name[19]`";
							if ((defined @$name[3]) and (@$name[3] ne '')) {
								my $type=$dbh->BBREAD::_type(@$name[3]);
               			$string.=" $type";
							}
               		if (@$name[5] eq 'Y') {
                  			$string.=" NOT NULL ";
               		}
							if (@$name[4] eq 'Y') {
									if (length(@$name[19]) > 50) {
										$string.= ",  UNIQUE KEY `PRIMKEY` (`@$name[19]`(50))";
									}
									else {
										$string.= ",  UNIQUE KEY `PRIMKEY` (`@$name[19]`)";
									}
							}
							if (defined @$name[17]) {
									if (length(@$name[19]) > 50) {
										$string.=", KEY `REL_@$name[19]` (`@$name[19]`(50))";
									}
									else {
										$string.=", KEY `REL_@$name[19]` (`@$name[19]`)";
									}
							}
						}
         		}
   				$string.=" \) ENGINE=MyISAM DEFAULT CHARSET=latin1";
   				print "$string\n";
   				}
				}	
			  }

sub _init {
	my $dbh=DBI->connect("DBI:mysql:spatest:localhost",'spatest','spatest') or die "Cannot connect to database: $DBI::errstr";
	return $dbh;
}
1;
