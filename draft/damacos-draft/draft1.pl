#!/usr/bin/perl
use strict;
use DBI;
use CGI;
use HTML::Template;
use XML::Simple;

#DB queries for getting the language and user_group
my $xmlosito=XML::Simple::XMLin("../../../osito/osito.xml");
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
my $t = HTML::Template->new(filename => "draft1.tmpl");

my $serialn="00:00:48:D7:0B:E9";
$serialn = $cgi->param("serialnum") if (defined $cgi->param("serialnum"));
#$t->param(TITLE => "Datos de la tabla MACHINES");
$t->param(ROWS => $dbh->selectall_arrayref('SELECT SN,MODEL,IP FROM MACHINES WHERE SN=\'$serialn\'', { Slice => {} }));

$dbh->disconnect;
print $cgi->header;
print $t->output(print_to => *STDOUT); #param of output: optionally supply a filehandle to print to automatically as the template is generated. This may improve performance and lower memory consumption

