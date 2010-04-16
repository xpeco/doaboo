#!/usr/bin/perl

package DBCONN;
use strict;
use warnings;
use lib '/home/cdoblado/doaboo/draft/cgi/';
use DBCONN;
use CGI;
use HTML::Template;

my $dbh =GetDBH();
my $cgi = CGI->new;
my $t = HTML::Template->new(filename => "../db.tmpl");

$t->param(TITLE => "Datos de la tabla 'machines'");
$t->param(ROWS => $dbh->selectall_arrayref('SELECT * FROM machines LIMIT 20', { Slice => {} }));

print $cgi->header;
print $t->output;

