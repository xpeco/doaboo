#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use XML::Simple;
        
##############
#Read Params
##############
my $cgi = CGI->new;
my $email;
my $model;
$email = $cgi->param('email') if (defined $cgi->param('email'));
$model = $cgi->param('mod') if (defined $cgi->param('mod'));

#######################
# DEBUG Generate Data 
########################
#a) FROM DB:
#my $recs = $dbh->selectall_arrayref('SELECT * FROM contents',{ Columns => {} }); # Get an array of hashes
#my $xml  = XMLout( {record => $recs}, NoAttr => 1 ); # Convert to XML where each hash element becomes an XML element
#b) WIRED:          
my @struct = { 'user' => {
                         'login' => $email ,
                         'host'=> [ $ENV{'HTTP_HOST'} ],
                         'oid' => [
                                   {'model'=>$model, 'oid1'=>'.1.2.3', 'oid2'=>'4.5.6'},
                                   {'model'=>'model2', 'oid1'=>'.3.4.5'},
                                   {'model'=>'model3', 'oid1'=>'.4.5.6'} 
                                  ]
                         }        
        };         
          
#############
# XML Output
#############
print $cgi->header('text/xml; charset=utf-8');
my $xs = XML::Simple->new(NoAttr=>0, RootName=>'data', ForceArray=>1);
my $xmlout = $xs->XMLout(\@struct);
print $xmlout;           
                            