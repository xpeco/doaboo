#!/usr/bin/perl
use strict;
use warnings;

use DB_UPDATE;
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
my $dbh = DB_UPDATE ->new();
for ($i=0;$i<@XMLin;$i++) {
	my $objects= $XMLin[$i]->{MODULE}->{OBJECT};
   	foreach my $object (@$objects) {
		my $object_id=$dbh->DB_UPDATE::get_id($object,'topics');
		$dbh->DB_UPDATE::record($object,$object_id,'topics');
		$object_id=$dbh->DB_UPDATE::get_id($object,'topics');
		my $attributes = $object->{ATTRIBUTE};
      		foreach my $attrib (@$attributes) {
			my $attribute_id=$dbh->DB_UPDATE::get_id($attrib,'attributes');
			$dbh->DB_UPDATE::record($attrib,$attribute_id,'attributes',$object_id);
			$attribute_id=$dbh->DB_UPDATE::get_id($attrib,'attributes');
      		}
		my $methods = $object->{METHOD};
		foreach my $method (@$methods) {
			my $method_id=$dbh->DB_UPDATE::get_id($method,'actions');
			$dbh->DB_UPDATE::record($method,$method_id,'actions',$object_id);
			$method_id=$dbh->DB_UPDATE::get_id($method,'actions');
			my $fields = $method->{FIELD};
         		foreach my $field (@$fields) {
				my $field_id=$dbh->DB_UPDATE::get_id($field,'fields');
				$dbh->DB_UPDATE::record($field,$field_id,'fields',$object_id,$method_id);
			}
		}
	}	
}
for ($i=0;$i<@XMLin;$i++) {
	my $menus=$XMLin[$i]->{MODULE}->{MENU};
	foreach my $menu(@$menus) {
		my $menu_id=$dbh->DB_UPDATE::get_id($menu,'menus');
		$dbh->DB_UPDATE::record($menu,$menu_id,'menus');
	}
}
for ($i=0;$i<@XMLin;$i++) {
	my $scripts=$XMLin[$i]->{MODULE}->{SCRIPT};
   	foreach my $script(@$scripts) {
      		my $script_id=$dbh->DB_UPDATE::get_id($script,'scripts');
      		$dbh->DB_UPDATE::record($script,$script_id,'scripts');
   	}
}
