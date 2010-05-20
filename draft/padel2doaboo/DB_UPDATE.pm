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
	my $format=shift;
	my $query=$dbh->prepare("select id from doaboo_"."$format"." where name=\'$item->{NAME}\'");
      	$query->execute;
      	my @id_item=$query->fetchrow_array;
	return $id_item[0];
}

sub record {
	my $dbh=shift;
	unless (ref $dbh){ print "Error, should call rawget() with an object, not a class\n";};
	my $item=shift;
	my $id=shift;
	my $format=shift;
	my $topic_id=shift;
	my $action_id=shift;
	my $string='';
	$item->{DESC} = $item->{NAME} if not defined $item->{DESC};
	if (defined $item->{DESC}) {
		my $code='';
		$code=$item->{DESC};
		$code=~s/\'/\\\'/g;
		$string=" description=\"$code\"";
	}
	my @list=('NAME','HINT','TYPE','REQUIRED','RECALCULATE','KEY_CAPTION','LIST','SUBTYPE','PRIVATE');
	foreach my $elem (@list){
		my $table=lc($elem);
		if (defined $item->{$elem}) {
			$string="$string".", $table=\'$item->{$elem}\'";
		}
	}
	if (defined $item->{KEY}) {
		$string="$string".", clave=\'$item->{KEY}\'";
	}
	@list=('RANGE','HIDE','CAPTION');
	foreach my $elem(@list){
               $table=lc($elem);
               if (defined $item->{$elem}->{BLOCK}[0]) {
		       my $code='';
		       $code= $item->{$elem}->{BLOCK}[0];
		       $code=~s/\'/\\\'/g;
		       $code=~s/\"/\\\"/g;
		       $code=~s/\./\\\./g;
		       $code=~s/\*/\\\*/g;
		       my @code = split(/;/, $code);
		       foreach $code(@code) {
			       $code=~s/\n/ /g;
			       $code=~s/^\s+//;
			       $code=~s/\s+$//;
		       }
		       $code = join("; ", @code);
		       @code = split(/{/, $code);
		       foreach $code(@code) {
		 	       $code=~s/\n/ /g;
			       $code=~s/^\s+//;
			       $code=~s/\s+$//;
		       }
		       $code = join("\{ ", @code);
		       @code = split(/}/, $code);
		       foreach $code(@code) {
			       $code=~s/\n/ /g;
			       $code=~s/^\s+//;
			       $code=~s/\s+$//;
		       }
		       $code = join("\} ", @code);
		       $string="$string"." ,$table='Y', $table"."_logic=\"$code\"";
               }
       }
       if (defined $item->{VALUE}->{BLOCK}[0]) {
	       $code='';
	       $code= $item->{VALUE}->{BLOCK}[0];
	       $code=~s/\\/\\\\/g;
               $code=~s/\'/\\\'/g;
               $code=~s/\"/\\\"/g;
               $code=~s/\./\\\./g;
               $code=~s/\*/\\\*/g;
	       my @code = split(/;/, $code);
	       foreach $code(@code) {
		 $code=~s/\n/ /g;
		 $code=~s/^\s+//;
		 $code=~s/\s+$//;
	       }
	       $code = join("; ", @code);
	       @code = split(/{/, $code);
	       foreach $code(@code) {
		 $code=~s/\n/ /g;
	         $code=~s/^\s+//;
	         $code=~s/\s+$//;
	       }
	       $code = join("\{ ", @code);
	       @code = split(/}/, $code);
	       foreach $code(@code) {
	         $code=~s/\n/ /g;
	         $code=~s/^\s+//;
		 $code=~s/\s+$//;
	       }
	       $code = join("\} ", @code);
               $string="$string"." ,calculated_logic=\"$code\"";
       }
       if ((defined $topic_id) and (($format eq 'attributes') or ($format eq 'actions'))) {
	       $string="$string"." ,topic=\'$topic_id\'";
       }
       if ((defined $action_id) and ($format eq 'fields')) {
	       my $att=$dbh->prepare("select id from doaboo_attributes where name=\'$item->{NAME}\' and topic=\'$topic_id\'");
	       $att->execute;
	       my @att=$att->fetchrow_array;
	       if (defined $att[0]) {
		       $string="$string"." ,attribute=\'$att[0]\', action=\'$action_id\'";
	       }
       }
       if ((defined $item->{TYPE}) and ($format eq 'menus') and ($item->{TYPE} eq 'TOPIC')) {
	       my $topic=$dbh->prepare("select id from doaboo_topics where name=\'$item->{NAME}\'");
               $topic->execute;
               my @topic=$topic->fetchrow_array;
	       if (defined $topic[0]) {
		       $string="$string".", topic=\'$topic[0]\'";
               }
       }
       if (defined $item->{RELATION}) {
	       my $relation=$dbh->prepare("select id from doaboo_topics where name=\'$item->{RELATION}\'");
	       $relation->execute;
	       my @relation=$relation->fetchrow_array;
	       if (defined $relation[0]) {
		       $string="$string".", relation=\'$relation[0]\'";
	       }
       }
       @list=('PRESCRIPT','POSTSCRIPT','ENDSCRIPT');
       my $i=0;
       foreach my $elem(@list){
	       $i++;
	       if (defined $item->{$elem}->{BLOCK}[0]) {
		       my $code='';
		       $code= $item->{$elem}->{BLOCK}[0];
		       $code=~s/\\/\\\\/g;
		       $code=~s/\'/\\\'/g;
		       $code=~s/\"/\\\"/g;
		       $code=~s/\./\\\./g;
		       $code=~s/\*/\\\*/g;
		       my @code = split(/;/, $code);
		       foreach $code(@code) {
		           $code=~s/\n/ /g;
		           $code=~s/^\s+//;
		           $code=~s/\s+$//;
	               }
	               $code = join("; ", @code);
	               @code = split(/{/, $code);
	               foreach $code(@code) {
		           $code=~s/\n/ /g;
	                   $code=~s/^\s+//;
	                   $code=~s/\s+$//;
	               }
	               $code = join("\{ ", @code);
	               @code = split(/}/, $code);
	               foreach $code(@code) {
	                   $code=~s/\n/ /g;
	                   $code=~s/^\s+//;
		           $code=~s/\s+$//;
	               }
	               $code = join("\} ", @code);
		       $string="$string"." , step"."$i"."=\"$code\"";
	       }
       }
       if (defined $item->{BLOCK}[0]) {
	       my $code='';
	       $code= $item->{BLOCK}[0];
	       $code=~s/\\/\\\\/g;
	       $code=~s/\'/\\\'/g;
	       $code=~s/\"/\\\"/g;
	       $code=~s/\./\\\./g;
	       $code=~s/\*/\\\*/g;
	       my @code = split(/;/, $code);
	       foreach $code(@code) {
		 $code=~s/\n/ /g;
		 $code=~s/^\s+//;
		 $code=~s/\s+$//;
	       }
	       $code = join("; ", @code);
	       @code = split(/{/, $code);
	       foreach $code(@code) {
		 $code=~s/\n/ /g;
	         $code=~s/^\s+//;
	         $code=~s/\s+$//;
	       }
	       $code = join("\{ ", @code);
	       @code = split(/}/, $code);
	       foreach $code(@code) {
	         $code=~s/\n/ /g;
	         $code=~s/^\s+//;
		 $code=~s/\s+$//;
	       }
	       $code = join("\} ", @code);
	       $string="$string"." , logic=\"$code\"";
       }
       if (defined $item->{PARENT}) {
	       $string="$string"." ,parent=\'$item->{PARENT}\'";
       }
       if (defined $item->{URL}) {
	       my $code='';
	       $code= $item->{URL};
	       $code=~s/\\/\\\\/g;
	       $code=~s/\'/\\\'/g;
	       $code=~s/\"/\\\"/g;
	       $code=~s/\./\\\./g;
	       $code=~s/\//\\\//g;
	       $code=~s/\:/\\\:/g;
	       $code=~s/\-/\\\-/g;
	       $code=~s/\_/\\\_/g;
	       $string="$string"." ,url=\"$code\"";
       }
       if (defined $id) {
	       my $query=$dbh->prepare("update doaboo_"."$format"." set "."$string"." where id=\'$id\'")->execute;
       }
       else {
	       my $query=$dbh->prepare("insert into doaboo_"."$format"." set "."$string")->execute;
       }
}

sub _init {
	my $dbh=DBI->connect("DBI:mysql:spatest:localhost",'spatest','spatest') or die "Cannot connect to database: $DBI::errstr";
	return $dbh;
}
1;
