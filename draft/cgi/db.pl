#!/usr/bin/perl
use strict;
use warnings;
use DBCONN;
use CGI;
use HTML::Template;

my $dbh = DBCONN->new;
my $cgi = CGI->new;

#Defaults
my $tmplfile  = 'table1.tmpl';
my $table     = 'ADM_USERS';
my $tab       = 't1';
my $recbypage = 10;
my $init      = 0;
my $end;
my $sql;
#my $userchoice;
my $totalrecords = '50'; #DEBUG

#Read Params
$table       = $cgi->param('table') if (defined $cgi->param('table'));
$tab         = $cgi->param('tab')   if (defined $cgi->param('tab'));
$init        = $cgi->param('init')  if (defined $cgi->param('init'));
$end         = $cgi->param('end')   if (defined $cgi->param('end'));
$recbypage   = $cgi->param('recbypage')  if (defined $cgi->param('recbypage'));
#$userchoice  = $cgi->param('userchoice') if (defined $cgi->param('userchoice'));


#################################
# PageUp / PageDown processing
#################################
if ((defined $end)&&($end eq "")) { $end =0;} #PTTD REVIEW!!! 
#print "END:$end - RCP:$recbypage\n";
if ($end > $recbypage) {
  #the user clicked on up_records
  $init = $end - $recbypage;
}	
else {
  $end  = $init + $recbypage;
}
#last page: select only the latest records
if ($end > $totalrecords) { 
  $end       = $totalrecords; 
  $recbypage = $totalrecords-$init; 
}

########
#DEBUG
########
my $fields; 
if ($table eq 'FILER')       {$fields = 'SYSTEM_ID, STATUS, STATUS_DATE, SERIAL_NUM, LOCATION_REL';}
if ($table eq 'ADM_VIEWS' )  {$fields = 'BASE_VIEW,USER_VIEW,GROUP_VIEW,OBJECT,NAME';}
if ($table eq 'ADM_USERS' )  {$fields = 'ADM_LOGIN,ADM_GROUP,ADM_NAME';}
if ($table eq 'ADM_GROUPS')  {$fields = '*';}

##############
#USERCHOICES
##############
#if (defined $userchoice) {
 #$tmplfile = ...		
#}

#In every option except "Object Change" or "Unmark All", the selected checkboxes must be saved in Cookie
#In those other two cases, the cookie must be cleaned: PTTD: TO DO
my $cookie_value = '';
my $cookie_name  = 'recs_'.$tab.'_'.$table;
my $cookie_sel   = $cgi->cookie($cookie_name); #Read the established cookie
#If necessary, update the cookie with new values
#if (NOT ObjectChange NOT UnmarkAll) { #PTTD
   my @selected = $cgi->param('record');
   if (defined $cookie_sel) {
     $cookie_value = $cookie_sel; #accumulate previous selected records (stored in cookie before)
   }
   #Include new selected records but not those already present in the cookie value list (format a,b,c,...z,)
   foreach my $record (@selected) {
      if (not grep(/$record,/, $cookie_value)) { 
        	$cookie_value .= $record.',';
        }
   }
   @selected = split(/,/,$cookie_value); #for the records loop, to mark those selected records
#}
#Finally set the cookie
$cookie_sel = $cgi->cookie (-name =>$cookie_name,
    -value  =>$cookie_value,
    -expires=>'+4h',
    -path   =>'/');
#Print header including cookies
print $cgi->header(-cookie=>"$cookie_sel"); #PTTD detect if not defined, avoid warning


######################
# Template Definition
######################
#global_vars to 1 if we want to share them inside/outside loops i.e.
my $t = HTML::Template->new(filename => $tmplfile,
                            path     => "$ENV{DOABOOPATH}",
                            die_on_bad_params => 1,
                            global_vars       => 0,
                            case_insensitive  => 1,
                            loop_context_vars => 1
                            #associate => $cgi
                            );

###############
# General Data
###############
#$t->param(TITLE => "Datos obtenidos");
$t->param(TAB   => $tab);
$t->param(Table => $table);
                            
###########
# DB Query
###########
$sql  = "SELECT $fields FROM $table LIMIT $init,$end";
if ($sql ne '') {
 my $sth = $dbh->prepare($sql) or die "Prepare exception: $DBI::errstr";
 $sth->execute() or die "Execute exception: $DBI::errstr";
 #$t->param(INSTANCES_NUMBER => $sth->rows); #Change by the total records of the table/query #PTTD
 $t->param(RECORDS_NUMBER => $totalrecords); #Change by the total records of the table/query #PTTD
 $t->param(COLUMNS_NUMBER => $sth->{NUM_OF_FIELDS});
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
 # Records
 ###########################
 my @records;
 my $i=$init;  
 my $z=$init+$recbypage;
 my $sel=0;
 while ((my $row = $sth->fetchrow_hashref)&&($i < $z)) {
   for my $col (sort keys %$row) {          
      my %rowh;
      $rowh{Valor} = $row->{$col};
      #$rowh{Index} = $i; #PTTD This "Index" value would work inside Valores TMPL_LOOP, where "Valor" value 
      push @records, \%rowh;
   }
   #Counter increment
   $i++;
   #Check if the record must appear as selected
   if ( grep(/^$i$/, @selected) ) { $sel = 1; } else { $sel = 0; } 
   #In the last page, this link should not be shown
   if ($i != $totalrecords) {
    #The Index TMPL_VAR is used for the down_records link  
    push @records, {Newline => '1', Index => $i, Selected => $sel};
   }
   else {
   	push @records, {Newline => '1', Norecords => 1};
   }
 }
 $t->param(Valores    => \@records);
 #Check if the record must appear as selected
 if ( grep(/^$init$/, @selected) ) { $sel = 1; } else { $sel = 0; } 
 $t->param(Initrecord => $init, Selected => $sel);
 $t->param(Endrecord  => $z);
 $t->param(Showfrom   => $init+1); #counter starts by 1 for the user ("Showing from" message)
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
###########################################################
#PTTD ELIMINATE
#my $cookie_name; 
#$cookie_name = $table.'_SELECTED';
#my $recordcheckedCookie  = $cgi->cookie($cookie_name);
#print "COOKIE: $cookie_name -- $recordcheckedCookie \n";
#$cookie_name = $table.'_UNSELECTED';
#my $recorduncheckedCookie = $cgi->cookie($cookie_name);
#print "COOKIE: $cookie_name -- $recorduncheckedCookie \n";
#############################################################

