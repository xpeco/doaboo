#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use XML::Simple;

my $local   = '/tmp/data.xml';        
my $email   = XMLin($local); #the only datum present in the xml file is the email/login
my $remote  = "http://localhost/doaboo-cgi/macmod.pl?email=$email&mod=hp00";    
my $outfile = '/tmp/see.xml';    

#Remote request
my $content = get($remote) || "Couldn't get it! \n";
print $content if (defined $content); #DEBUG

#Store answer in local XML file
if (is_success(getstore($remote,$outfile))) {
 print "\n File $outfile written \n"; #DEBUG
}
