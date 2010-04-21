#!/usr/bin/perl

use strict;
use warnings;
use DBCONN;
use CGI;
use HTML::Template;

my $dbh = DBCONN->new;
my $cgi = CGI->new;
my $t = HTML::Template->new(filename => "$ENV{DOABOOPATH}/db.tmpl");

$t->param(TITLE => "Datos de la tabla 'machines'");
$t->param(ROWS => $dbh->selectall_arrayref('SELECT * FROM machines LIMIT 20', { Slice => {} }));

print $cgi->header;
print $t->output;

