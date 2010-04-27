#!/usr/bin/perl
use strict;
use warnings;
use DBCONN;
use CGI;
use HTML::Template;

my $dbh = DBCONN->new;
my $cgi = CGI->new;
print $cgi->header;

######################
# Template Definition
######################
my $t = HTML::Template->new(filename => "db.tmpl",
                            path     => "$ENV{DOABOOPATH}",
                            die_on_bad_params => 1,
                            case_insensitive => 1,
                            loop_context_vars =>1
                            #associate => $cgi
                            );
                            
###############################################################
#Will be substituted by DO.pm functions
my $sql = 'SELECT * FROM machines';
my $sth = $dbh->prepare($sql) or die "Prepare exception: $DBI::errstr";
$sth->execute() or die "Execute exception: $DBI::errstr";
########################################################################

###############
# General Data
###############
$t->param(TITLE => "Datos de la tabla 'machines'");
print "Numero de registros: ", $sth->rows."<br>";

#########
# Fields 
#########
my @headings;
foreach (@{$sth->{NAME}}) {
        my %rowh;
        $rowh{Nombre} = $_;
        push @headings, \%rowh;
}
$t->param(Campos=>\@headings);

#############
# DEBUG - OK
#############
#print "Field0: $headings[0]->{Nombre}<br>";
#print "Field1: $headings[1]->{Nombre}<br>";
#print "Field2: $headings[2]->{Nombre}<br>";
#print "<br>";

###############
# Registers
###############
my @results;
my @registers;
my $instances = $sth->fetchall_arrayref({});
my $i=0;
foreach (@$instances) {
  foreach (@{$sth->{NAME}}) {
  	    push @registers, {Valor => \@$instances};	    
	    my %rowh;
	    #print "DATA: $i: $registers[$i]->{Valor}[$i]->{$_} <br>";
        $rowh{Valor} = $registers[$i]->{Valor}[$i]->{$_};
        push @results, \%rowh;
	    #print "$i: $rowh{Valor}<br>";
  }
  push @results, {newline => '1'};
  $i++;
}
$t->param(Valores=>\@results);


################
#TMPL output
################
print $t->output;


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


