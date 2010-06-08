#!/usr/bin/perl
use strict;
use warnings;

use DBDOABOO;
use XML::Simple;
use Data::Dumper;


my $xs = new XML::Simple(forcearray =>['SOURCE','ADDON']);
my $xfile = $xs->XMLin("application.xml",SuppressEmpty=>'');
my @source_XMLs;
my @XMLin;
my $list=$xfile->{SOURCE};
foreach my $source(@$list){;push(@source_XMLs,$source);}
my $i=0;
foreach my $file (@source_XMLs) {
   my $xs1= new XML::Simple (keeproot=>1, forcearray=>['OBJECT','ATTRIBUTE','METHOD','FIELD','BLOCK','MENU','SCRIPT']);
   my $result=eval{$XMLin[$i]=$xs1->XMLin($file,SuppressEmpty=>'') || die "can't XMLin $file: $!";};
   if($result==0){print "$@";if(<STDIN>){};exit();}
   $i++;
}
my $xs1= new XML::Simple (keeproot=>1, forcearray=>['OBJECT','ATTRIBUTE','METHOD','FIELD','BLOCK','MENU','SCRIPT']);
my $result=eval{$XMLin[$i]=$xs1->XMLin("ADMIN.XML",SuppressEmpty=>'') || die "can't XMLin ADMIN.XML: $!";};
if($result==0){print "$@";if(<STDIN>){};exit();}

my $dbh = DBDOABOO ->new();
for ($i=0;$i<@XMLin;$i++) {
	my $objects= $XMLin[$i]->{MODULE}->{OBJECT};
   	foreach my $object (@$objects) {
		my $object_id=$dbh->DBDOABOO::get_id($object,'topics');
		$dbh->DBDOABOO::record($object,$object_id,'topics');
		$object_id=$dbh->DBDOABOO::get_id($object,'topics');
		my $attributes = $object->{ATTRIBUTE};
      		foreach my $attrib (@$attributes) {
			my $attribute_id=$dbh->DBDOABOO::get_id($attrib,'attributes',$object_id);
			$dbh->DBDOABOO::record($attrib,$attribute_id,'attributes',$object_id);
			$attribute_id=$dbh->DBDOABOO::get_id($attrib,'attributes');
      		}
		my $methods = $object->{METHOD};
		foreach my $method (@$methods) {
			my $method_id=$dbh->DBDOABOO::get_id($method,'actions',$object_id);
			$dbh->DBDOABOO::record($method,$method_id,'actions',$object_id);
			$method_id=$dbh->DBDOABOO::get_id($method,'actions');
			my $fields = $method->{FIELD};
         		foreach my $field (@$fields) {
				my $field_id=$dbh->DBDOABOO::get_id($field,'fields');
				$dbh->DBDOABOO::record($field,$field_id,'fields',$object_id,$method_id);
			}
		}
	}
}

for ($i=0;$i<@XMLin;$i++) {
	my $objects= $XMLin[$i]->{MODULE}->{OBJECT};
	foreach my $object (@$objects) {
   	my $object_id=$dbh->DBDOABOO::get_id($object,'topics');
   	my $attributes = $object->{ATTRIBUTE};
   	foreach my $attrib (@$attributes) {
   		my $attribute_id=$dbh->DBDOABOO::get_id($attrib,'attributes',$object_id);
      	$dbh->DBDOABOO::relation($attrib,$attribute_id,$object_id);
      }
   }
}

for ($i=0;$i<@XMLin;$i++) {
	my $menus=$XMLin[$i]->{MODULE}->{MENU};
	foreach my $menu(@$menus) {
		my $menu_id=$dbh->DBDOABOO::get_id($menu,'menus');
		$dbh->DBDOABOO::record($menu,$menu_id,'menus');
	}
}
for ($i=0;$i<@XMLin;$i++) {
	my $scripts=$XMLin[$i]->{MODULE}->{SCRIPT};
   	foreach my $script(@$scripts) {
      		my $script_id=$dbh->DBDOABOO::get_id($script,'scripts');
      		$dbh->DBDOABOO::record($script,$script_id,'scripts');
   	}
}

$xs= new XML::Simple (keeproot=>1, forcearray=>['OBJECT','ATTRIBUTE','METHOD','FIELD','BLOCK','MENU','SCRIPT']);
$xfile = $xs->XMLin("ADMIN.XML",SuppressEmpty=>'');


