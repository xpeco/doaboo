#!/usr/bin/perl

use strict;
use warnings;
use DBCONN;
use CGI;
use HTML::Template;

my $dbh = DBCONN->new;
my $cgi = CGI->new;
print $cgi->header;

my $t = HTML::Template->new(filename => "db.tmpl",
                            path     => "$ENV{DOABOOPATH}",
                            die_on_bad_params => 1,
                            case_insensitive => 1
                            #associate => $cgi
                            );
#$t->param(TITLE => "Datos de la tabla 'machines'");

my $sql = 'SELECT * FROM machines';
my $sth = $dbh->prepare($sql) or die "Prepare exception: $DBI::errstr";
$sth->execute() or die "Execute exception: $DBI::errstr";

print "<br>Table Fields:<br>\n";
print join ", ", @{$sth->{NAME}};
print "<br><br>";

my $values = $sth->fetchall_hashref('serialn');
foreach my $val (keys %$values) {
 print "$values->{$val}->{id},$val,$values->{$val}->{type} <br>";
}

print "<br>";
foreach my $valor (@{$sth->{NAME}}) {
 print "HERE: $valor <br>";
} 

#$t->param(
#    Campos => [
#      { Nombre => 'Uno'},
#      { Nombre => 'Dos'},
#    ]
#);


#my $i=0; my $var;
#foreach my $val (@{$sth->{NAME}}) {
#	$var.="{Nombre=> $val},";
#    $i++;
#}
#print "VAR: $var <br>";

#$t->param(
#    Campos => [$var]
#);	
 
my @headings;
foreach (@{$sth->{NAME}}) {
        my %rowh;
        $rowh{Nombre} = $_;
        push @headings, \%rowh;
}
$t->param(Campos=>\@headings);
 
 
 
#TMPL output
print $t->output;


##############################################################
#Short Notation
#In the .tmpl it is necessary to write the fields name (serialn, id... DB COLUMNS)
#$t->param(ROWS => $dbh->selectall_arrayref('SELECT * FROM machines LIMIT 20', { Slice => {} }));
#############################################################
#Long Notation
#my @rows;
#while (my @data_row = $sth->fetchrow_array) {
#        my %row;
#        $row{PRODUCTCODE} = $data_row[0];
#        $row{PRODUCT} = $data_row[1];
#        push @rows, \%row;
#}
#$template->param(ROWS=>\@rows);
############################################################
# PINTUS.pm sub Table:
#my $result;
#$result->{fields} = [];
#foreach $field (@$fields) {
#      if ($field->{SHOW} ne 'N') {
#        if (PULSERA::CheckAccess({element=>'field',object=>$in_params->{object},detail=>$field->{NAME}})) {
#          $result->{fields}->[$i]->{name} = $field->{NAME};
#          $result->{fields}->[$i]->{desc} = $field->{DESC};
##############################################################



