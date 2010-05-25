#!/usr/bin/perl
use strict;
use warnings;
use DBCONN;
use CGI;
use CGI::Session;
use HTML::Template;

my $dbh = DBCONN->new;
my $cgi = CGI->new;
print $cgi->header();
 
#######################
#Get Data from Session
#######################
my $ses_id  = $cgi->cookie("CGISESSID") || undef; 
if (not defined $ses_id) {
    my $url = "/doaboo-cgi/login.pl";
    print $cgi->redirect( -URL => $url);	
}
my $session = new CGI::Session(undef, $ses_id, {Directory=>'/tmp'});
my $user    = $session->param("UserStruct");

#DEBUG
print "Session: $ses_id - \n";
for my $datum (sort keys %$user) {          
 print "$datum=$user->{$datum} / \n";
}

##################
#Defaults #DEBUG
##################
my $tmplfile  = 'table1.tmpl';
my $table     = 'ADM_USERS';
my $tab       = 't1';
my $init      = 0;
my $end;
my $totalrecords = '50'; #DEBUG
#my $userchoice;

##############
#Read Params
##############
$table       = $cgi->param('table') if (defined $cgi->param('table'));
$tab         = $cgi->param('tab')   if (defined $cgi->param('tab'));
$init        = $cgi->param('init')  if (defined $cgi->param('init'));
$end         = $cgi->param('end')   if (defined $cgi->param('end'));
#$userchoice  = $cgi->param('userchoice') if (defined $cgi->param('userchoice'));


################################################################
#DEBUG: get FIELDS and other data. It will come in $user struct
################################################################
my $recbypage = 6;
my $fields; 
if ($table eq 'FILER')       {$fields = 'SYSTEM_ID, STATUS, STATUS_DATE, SERIAL_NUM, LOCATION_REL';}
if ($table eq 'ADM_VIEWS' )  {$fields = 'BASE_VIEW,USER_VIEW,GROUP_VIEW,OBJECT,NAME';}
if ($table eq 'ADM_USERS' )  {$fields = 'ADM_LOGIN,ADM_GROUP,ADM_NAME';}
if ($table eq 'ADM_GROUPS')  {$fields = '*';}


###########################################################
# PageUp / PageDown processing: it depends on user choices
###########################################################
if ((not defined $end)||($end eq "")) { $end = 0; }
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

#####################
#Build the DB query
#####################
my $db_sql;
$db_sql  = "SELECT $fields FROM $table LIMIT $init,$end"; #DEBUG: given by DO function


##############
#USERCHOICES
##############
#if (defined $userchoice) {
 #$tmplfile = ...		
#}

######################
# Template Definition
######################
#global_vars to 1 if we want to share them inside/outside loops i.e.
my $template = HTML::Template->new(filename => $tmplfile,
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
$template->param(Activetab => $tab);
$template->param(Table     => $table);
$template->param(user      => $user->{login});

######################################################
#Get Records and Fill Table template with the results
######################################################
if (defined $db_sql) {
 GetRecs_FillTable($template,$db_sql);
}

################
#TMPL output
################
print $template->output;           
                            
################################
# SUBROUTINES
################################
sub GetRecs_FillTable {
  my $t   = shift;
  my $sql = shift;
  #if ($sql ne '') {
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
   #} #End of if $sql ne ''

} #sub GetRecs_FillTable



