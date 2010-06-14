#!/usr/bin/perl
use strict;
use CGI;
use HTML::Template;

my $cgi = CGI->new;
my $template;

print $cgi->header;
$template = 'opcion2';
my $t = HTML::Template->new(filename => "$template.tmpl", associate =>
+ $cgi);
print $t->output;
