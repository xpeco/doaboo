#!/usr/bin/perl
use strict;
use warnings;

use XML::Simple;
use DBI;

use constant VERSION=>'0.1';

# Load the source files checking the -x arg if any.
my $xfile=XMLin("application.xml",'forcearray',['SOURCE','ADDON']);
my @source_XMLs;
my @XMLin;

my $list=$xfile->{SOURCE};
foreach my $source(@$list){;push(@source_XMLs,$source);}

my $i=0;
foreach my $file (@source_XMLs) {
	my $result=eval{$XMLin[$i]=XML::Simple::XMLin($file, ('keeproot', 1, 'forcearray', ['MENU','SCRIPT','VIEW','METHOD','OBJECT','ATTRIBUTE','METHOD','REPORT','VIEW_FIELD','REPORT_FIELD','CONSTRAINT','OPTION','FIELD','BLOCK','LINEA','NEEDED_MODULE','ADD_ON','ALARM','ONLY_FIX_DAY','WEEKDAY','FROM_TIME','TO_TIME','FROM_DATE','TO_DATE','BLOCKING','ANCHOR_CHANGE'])) || die "can't XMLin $file: $!";};
	 if($result==0){print "$@";if(<STDIN>){};exit();}
	 $i++;
	}

my $dbh = DBI->connect("DBI:mysql:spatest:localhost", 'spatest','spatest') or die "Cannot connect to database: $DBI::errstr";

my $r=$dbh->prepare('show tables;')->execute;
print "Tables: $r\n\n";

for ($i=0;$i<@XMLin;$i++) {
	my $objects= $XMLin[$i]->{MODULE}->{OBJECT};
	foreach my $object (@$objects) {
		# Insert TOPIC details
		$object->{DESC} = $object->{NAME} if not defined $object->{DESC};
		$object->{HINT} = $object->{NAME} if not defined $object->{HINT};
		print "Topic: $object->{DESC}\n";
		print "Topic: $object->{HINT}\n";
		my $attributes = $object->{ATTRIBUTE};
		foreach my $attrib (@$attributes) {
			# Insert Attribute details
			$attrib->{DESC} = $attrib->{NAME} if not defined $attrib->{DESC};
			print "	Attributes\n";
			print "		$attrib->{DESC}\n";
			print "		$attrib->{TYPE}\n";

		}
		my $methods = $object->{METHOD};
		foreach my $method (@$methods) {
			# Insert Action details
			$method->{DESC} = $method->{NAME} if not defined $method->{DESC};
			print "	Methods:\n";
			print "		$method->{DESC}\n";
			print "		$method->{TYPE}\n";
			my $fields = $method->{FIELD};
			foreach my $field (@$fields) {
				print "			Fields:\n";
				print "				$field->{NAME}\n";
			}
    	}
	}
}
