#!/usr/bin/perl
use strict;
use warnings;

use DB_UPDATE;
use XML::Simple;
use Data::Dumper;


my $xs = new XML::Simple(forcearray =>['SOURCE','ADDON']);
my $xfile = $xs->XMLin("application.xml");
my @source_XMLs;
my @XMLin;
my $list=$xfile->{SOURCE};
foreach my $source(@$list){;push(@source_XMLs,$source);}
my $i=0;
foreach my $file (@source_XMLs) {
   my $xs1= new XML::Simple (keeproot=>1, forcearray=>['OBJECT','ATTRIBUTE','METHOD','FIELD','BLOCK']);
   my $result=eval{$XMLin[$i]=$xs1->XMLin($file) || die "can't XMLin $file: $!";};
   if($result==0){print "$@";if(<STDIN>){};exit();}
   $i++;
}
my $dbh = DB_UPDATE ->new();
for ($i=0;$i<@XMLin;$i++) {
   my $objects= $XMLin[$i]->{MODULE}->{OBJECT};
   foreach my $object (@$objects) {
		my $object_id=$dbh->DB_UPDATE::get_id($object);
		if (defined $object_id) {
			$dbh->DB_UPDATE::update($object,$object_id);
		}
		else {
			$dbh->DB_UPDATE::create($object);
			$object_id=$dbh->DB_UPDATE::get_id($object);
		}
		my $attributes = $object->{ATTRIBUTE};
      foreach my $attrib (@$attributes) {
			### GRABAR ATTRIBUTE ###
			########################
			### get id_attribute
			### if defined id_attribute
			###	update_attribute
			### else 
			### 	insert_attribute
			###	get_attribute
			#######################
		}
		my $methods = $object->{METHOD};
      foreach my $method (@$methods) {
			### GRABAR ACTION ###
			#####################
			### get id_action
			### if defined id_action
			### 	update_action
			### else
			### 	insert_action
			### 	get id_action
			#####################
			my $fields = $method->{FIELD};
         foreach my $field (@$fields) {
				### GRABAR FIELD ###
				####################
				### get id_field
				### get id_attribute
				### if defined id_field 
				### 	update_field
				### else
				### 	insert_field
				####################
			}
		}
	}	
 }
