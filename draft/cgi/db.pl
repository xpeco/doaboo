#!/usr/bin/perl
use strict;
use warnings;
use DBCONN;
use CGI;
use HTML::Template;

my $dbh = DBCONN->new;
my $cgi = CGI->new;
print $cgi->header;

#Defaults
my $tmplfile = 'table1.tmpl';
my $table      = 'ADM_USERS'; #Default
my $sql = "SELECT * FROM $table limit 30";
my $recbypage  = 15;
my $userchoice;

#Read Params
$table      = $cgi->param('table') if (defined $cgi->param('table'));
$recbypage  = $cgi->param('recbypage') if (defined $cgi->param('recbypage'));
$userchoice = $cgi->param('userchoice') if (defined $cgi->param('userchoice'));

if (defined $userchoice) {
 #$tmplfile = ...	
 if ($userchoice eq 'Nextpage') { 
 	$sql = "SELECT * FROM ADM_RESTRICTIONS LIMIT 30" ;
    # $sql = "SELECT * FROM ADM_USERS WHERE ID>=INDEX" ;
 }   	
}


######################
# Template Definition
######################
my $t = HTML::Template->new(filename => $tmplfile,
                            path     => "$ENV{DOABOOPATH}",
                            die_on_bad_params => 1,
                            case_insensitive => 1,
                            loop_context_vars =>1
                            #associate => $cgi
                            );

###############
# General Data
###############
 $t->param(TITLE => "Datos obtenidos");
                            
###########
# Query
###########
if ($sql ne '') {
 my $sth = $dbh->prepare($sql) or die "Prepare exception: $DBI::errstr";
 $sth->execute() or die "Execute exception: $DBI::errstr";
 $t->param(INSTANCES_NUMBER =>  $sth->rows);
 $t->param(COLUMNS_NUMBER =>  $sth->{NUM_OF_FIELDS});
 #DEBUG
 #my $rows = DBI::dump_results($sth);
 #$sth->{TYPE} NAME, NAME_uc, NAME_lc, NAME_hash, NAME_lc_hash and NAME_uc_HASH.


 ########################
 # Fields 
 ########################
 my @headings;
 foreach (sort @{$sth->{NAME}}) {
         my %rowh;
         $rowh{Nombre} = $_;
         push @headings, \%rowh;
 }
 $t->param(Campos=>\@headings);

 ###########################
 # Instances
 ###########################
 my @instances;
 my $i=0;
 while ((my $row = $sth->fetchrow_hashref)&&($i < $recbypage)) 
 {
   for my $col (sort keys %$row) {          
      my %rowh;
      $rowh{Valor} = $row->{$col};
      #$rowh{Index} = $i; #PTTD This "Index" value would work inside Valores TMPL_LOOP, where "Valor" value 
      push @instances, \%rowh;
   }
   $i++;
   push @instances, {Newline => '1', Index=> $i};
 }
 $t->param(Valores=>\@instances);
 $t->param(Recbypage => $i);

} #End of if defined $sql

################
#TMPL output
################
print $t->output;


#############
# DEBUG - OK
#############
#print "Field0: $headings[0]->{Nombre}<br>";
#print "Field1: $headings[1]->{Nombre}<br>";
#print "Field2: $headings[2]->{Nombre}<br>";
#print "<br>";

#####################################################################
# Registers - IT WORKS FOR TABLE BUT IT'S TOO COMPLICATED / TWISTY
#####################################################################
#my @results;
#my @registers;
#my $instances = $sth->fetchall_arrayref({});
#my $i=0;
#foreach (@$instances) {
#  foreach (@{$sth->{NAME}}) {
#  	    push @registers, {Valor => \@$instances};	    
#	    my %rowh;
#	    #print "DATA: $i: $registers[$i]->{Valor}[$i]->{$_} <br>";
#       $rowh{Valor} = $registers[$i]->{Valor}[$i]->{$_};
#       push @results, \%rowh;
#	    #print "$i: $rowh{Valor}<br>";
#  }
#  #Marker for new lines
#  push @results, {newline => '1'};
#  #Markes for odd/even lines -- LOOP __ODD__ non valid 'cause it's a single loop
#  #if (($i > 1) && ($i % 2 != 0)) { push @results, {oddline => '1'}; }
#  $i++;
#}
#$t->param(Valores=>\@results);


##########################
# PREVIOUS TESTS
##########################
#################
# Values OK
#################
# my $values = $sth->fetchall_hashref('serialn');
# foreach my $val (keys %$values) {
# print "$values->{$val}->{id},$val,$values->{$val}->{type} <br>";
# }
# print "<br>";
##########################
# With the HTML wired OK
# print "<tr><th>$sth->{NAME}->[0]</th><th>$sth->{NAME}->[1]</th></tr>";
# while (my @row = $sth->fetchrow_array) {
#    print "<tr><td> $row[0] </td><td> $row[1] </td> <td> $row[2] </td></tr>\n";
# }
##################################

##############################################################
# Short Notation
###############################################################
# In the .tmpl it is necessary to write the fields name (serialn, id... DB COLUMNS)
# $t->param(ROWS => $dbh->selectall_arrayref('SELECT * FROM machines LIMIT 20', { Slice => {} }));
#############################################################
# Long Notation
#############################################################
# my @rows;
# while (my @data_row = $sth->fetchrow_array) {
#        my %row;
#        $row{PRODUCTCODE} = $data_row[0];
#        $row{PRODUCT} = $data_row[1];
#        push @rows, \%row;
# }
# $template->param(ROWS=>\@rows);
############################################################
# PINTUS.pm sub Table:
# my $result;
# $result->{fields} = [];
# foreach $field (@$fields) {
#      if ($field->{SHOW} ne 'N') {
#        if (PULSERA::CheckAccess({element=>'field',object=>$in_params->{object},detail=>$field->{NAME}})) {
#          $result->{fields}->[$i]->{name} = $field->{NAME};
#          $result->{fields}->[$i]->{desc} = $field->{DESC};
##############################################################
# TESTS non valid HTML::Template
###############################################################
# $t->param(
#    Campos => [
#      { Nombre => 'Uno'},
#      { Nombre => 'Dos'},
#    ]
# );
# my $i=0; my $var;
# foreach my $val (@{$sth->{NAME}}) {
# 	 $var.="{Nombre=> $val},";
#    $i++;
# }
# print "VAR: $var <br>";
#########################################
# TESTS OK 
#########################################
# print "<br>Table Fields:<br>\n";
# foreach my $valor (@{$sth->{NAME}}) {
#   print "$valor <br>";
# }
# #OR
# print join ", ", @{$sth->{NAME}}; 
##########################################


