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
my $recbypage = 6;
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
if ((not defined $end)||($end eq "")) { $end = 0; }
#if ($end eq "") { $end =0;} #PTTD REVIEW APACHE LOG WARNINGS UNDEFINED!!! 
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

#####################
#Print HTTP header
#####################
print $cgi->header(); 

#DEBUG
my $ses_id  = $cgi->cookie("CGISESSID") || undef; 
my $session = new CGI::Session(undef, $ses_id, {Directory=>'/tmp'});
my $user    = $session->param("UserStruct");
my $login   = $session->param('UserLogin'); #DEBUG
print "USER DATA in db.pl: Session: $ses_id  <br>\n"; #DEBUG
for my $datum (sort keys %$user) {          
 print "$datum=$user->{$datum} / \n";
}


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
$t->param(Activetab => $tab);
$t->param(Table     => $table);
                            
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
 my $sel_recs = $cgi->cookie('sel_recs'); #Read the established cookie
 my @selected = split(/,/,$sel_recs);
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
   if ( grep(/^$i$/, @selected) ) { $sel = 1;} else { $sel = 0; }  
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

