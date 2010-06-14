#!/usr/bin/perl
use strict;
use DBI;
use CGI;
use HTML::Template;
use XML::Simple;

#DB queries for getting the language and user_group
my $xmlosito=XML::Simple::XMLin("../../../../osito/osito.xml");
my $data_base=$xmlosito->{DDBB}->{NAME};
my $user=$xmlosito->{DDBB}->{USER};
my $password=$xmlosito->{DDBB}->{PASS};
my $server=$xmlosito->{DDBB}->{HOST};

my $dbh=DBI->connect("DBI:mysql:$data_base:$server",$user,$password);
if (not $dbh){
         print STDERR "Connection failed \n";
         exit(0);
}

my $cgi = CGI->new;
my $t = HTML::Template->new(filename => "db.tmpl");

$t->param(TITLE => "Datos de la tabla MACHINES");
$t->param(ROWS => $dbh->selectall_arrayref('SELECT SN,MODEL,IP FROM MACHINES LIMIT 20', { Slice => {} }));

$dbh->disconnect;
print $cgi->header;
print $t->output(print_to => *STDOUT); #param of output: optionally supply a filehandle to print to automatically as the template is generated. This may improve performance and lower memory consumption

#TRY THIS
# we don't need no stinkin' column names
# my $rows = $DBH->selectall_arrayref('select * from songs');
#
# # don't croak on template names that don't exist
# my $template = HTML::Template->new(
#     filename          => 'mp3.tmpl',
#         die_on_bad_params => 0,
#         );
#         $template->param(ROWS => $rows);



