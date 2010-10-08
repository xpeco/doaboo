#!/usr/bin/perl
use strict;
use warnings;
use DBCONN;
use DO;
use CGI;
use CGI::Session;
use HTML::Template;

my $cgi_h = CGI->new;
print $cgi_h->header();

sub GetRecsForTable_TEST {
    my $t   = shift;
    my $sql = shift;
    my $cgi = shift;
 
  	#####################
  	#User params
  	#####################
  	my $init = 0;
        my $end; #undef as default 
  	my $recbypage    = '6';  #DEBUG: given by Session param
  	my $totalrecords = '50'; #DEBUG: given by DO function
  	$init = $cgi->param('init')  if (defined $cgi->param('init'));
	$end  = $cgi->param('end')   if (defined $cgi->param('end'));
	
    ###########################################################
    # PageUp / PageDown processing: it depends on user choices
    ###########################################################    
    if ((not defined $end)||($end eq "")) { $end = 0; }
    #GoUp / GoDown page by page (Go to init included)
    if ($end > $recbypage) {
      #the user clicked on up_records
      $init = $end - $recbypage;
    }	
    else {
      $end  = $init + $recbypage;
    }
    #Last page reached: select only the latest records
    if ($end > $totalrecords) { 
      $end       = $totalrecords; 
      $recbypage = $totalrecords-$init; 
    }

    #Add the limits to the DB query
    if (($init!=0)||($end!=0)) {
     $sql = $sql." LIMIT $init,$end";
    }
    
    #DEBUG
    my @time = scalar(localtime(time));
    open (FILE, ">>/tmp/getrecordslog.txt") || die("Cannot open file");
    print FILE "@time --- $sql \n";
    close (FILE);

    #Execute query
    my $dbh = DBCONN->new;
    my $sth = $dbh->prepare($sql) or die "Prepare exception: $DBI::errstr";
    $sth->execute() or die "Execute exception: $DBI::errstr";
    #$t->param(INSTANCES_NUMBER => $sth->rows); #Change by the total records of the table/query #PTTD
    $t->param(RECORDS_NUMBER => $totalrecords); #Change by the total records of the table/query #PTTD
    $t->param(COLUMNS_NUMBER => $sth->{NUM_OF_FIELDS});
    ##DEBUG
    ##my $rows = DBI::dump_results($sth);
    ##$sth->{TYPE} NAME, NAME_uc, NAME_lc, NAME_hash, NAME_lc_hash and NAME_uc_HASH.

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
    my $sel_recs = $cgi->cookie('sel_recs') if (defined $cgi->cookie('sel_recs')); #Read the sel_recs cookie
    my @selected = split(/,/,$sel_recs) if (defined $sel_recs);
    my @records;
    my $i=$init;  
    my $z=$init+$recbypage;
    my $sel=0;
    while ((my $row = $sth->fetchrow_hashref)&&($i < $z)) {
      my $j=0; #column counter
      my $iskey=0;	
      for my $col (sort keys %$row) {          
         my %rowh;
         $rowh{Valor} = $row->{$col};
         #$rowh{Index} = $i; #PTTD This "Index" value would work inside Valores TMPL_LOOP, where "Valor" value
         ###CDA
         $j++; #Attention! COUNTER Loop of fields starts on 1, not in zero
         $rowh{ColNum} = $j;
         $rowh{RowNum} = $i; 
         ###$rowh{CellNum} = $i."_".$j; #row index + col index
         if ($j==2) { $iskey = 1; } #DEBUG Detect Column / Fields which are Key
         else { $iskey = 0; }
         $rowh{Iskey}  = $iskey; 
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
   	   $t->param(Norecords  => 1);
      }
    }
    $t->param(Valores    => \@records);
    #Check if the record must appear as selected
    if ( grep(/^$init$/, @selected) ) { $sel = 1; } else { $sel = 0; } 
    $t->param(Initrecord => $init, Selected => $sel);
    $t->param(Endrecord  => $z);
    $t->param(Showfrom   => $init+1); #counter starts by 1 for the user ("Showing from" message)
    $t->param(Totalselec => $#selected+1);

} #end of sub

                       

    
################################
# SUBROUTINES
################################
sub GetRecsForTable {
    my $t   = shift;
    my $sql = shift;
    my $cgi = shift;
  
  	#####################
  	#User params
  	#####################
  	my $init = 0;
        my $end; #undef as default 
  	my $recbypage    = '6';  #DEBUG: given by Session param
  	my $totalrecords = '50'; #DEBUG: given by DO function
  	$init = $cgi->param('init')  if (defined $cgi->param('init'));
	$end  = $cgi->param('end')   if (defined $cgi->param('end'));
	
    ###########################################################
    # PageUp / PageDown processing: it depends on user choices
    ###########################################################    
    if ((not defined $end)||($end eq "")) { $end = 0; }
    #GoUp / GoDown page by page (Go to init included)
    if ($end > $recbypage) {
      #the user clicked on up_records
      $init = $end - $recbypage;
    }	
    else {
      $end  = $init + $recbypage;
    }
    #Last page reached: select only the latest records
    if ($end > $totalrecords) { 
      $end       = $totalrecords; 
      $recbypage = $totalrecords-$init; 
    }
    #Add the limits to the DB query
  	$sql = $sql." LIMIT $init,$end";
  	
  	
    my $dbh = DBCONN->new;
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
    my $sel_recs = $cgi->cookie('sel_recs') if (defined $cgi->cookie('sel_recs')); #Read the sel_recs cookie
    my @selected = split(/,/,$sel_recs) if (defined $sel_recs);
    my @records;
    my $i=$init;  
    my $z=$init+$recbypage;
    my $sel=0;
    while ((my $row = $sth->fetchrow_hashref)&&($i < $z)) {
      my $j=0; #column counter
      my $iskey=0;	
      for my $col (sort keys %$row) {          
         my %rowh;
         $rowh{Valor} = $row->{$col};
         #$rowh{Index} = $i; #PTTD This "Index" value would work inside Valores TMPL_LOOP, where "Valor" value
         ###CDA
         $j++; #Attention! COUNTER Loop of fields starts on 1, not in zero
         $rowh{ColNum} = $j;
         $rowh{RowNum} = $i; 
         ###$rowh{CellNum} = $i."_".$j; #row index + col index
         if ($j==2) { $iskey = 1; } #DEBUG Detect Column / Fields which are Key
         else { $iskey = 0; }
         $rowh{Iskey}  = $iskey; 
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
   	   $t->param(Norecords  => 1);
      }
    }
    $t->param(Valores    => \@records);
    #Check if the record must appear as selected
    if ( grep(/^$init$/, @selected) ) { $sel = 1; } else { $sel = 0; } 
    $t->param(Initrecord => $init, Selected => $sel);
    $t->param(Endrecord  => $z);
    $t->param(Showfrom   => $init+1); #counter starts by 1 for the user ("Showing from" message)
    $t->param(Totalselec => $#selected+1);

} #end of sub



##########################################################
# Main
##########################################################

#######################
#Get Data from Session
#######################
my $ses_id  = $cgi_h->cookie("CGISESSID") || undef; 
if (not defined $ses_id) {
    my $url = "/doaboo-cgi/login.pl";
    print $cgi_h->redirect( -URL => $url);	
}
my $session = new CGI::Session(undef, $ses_id, {Directory=>'/tmp'});
my $user    = $session->param("UserStruct");

#DEBUG
#print "Session: $ses_id - \n" if (defined $ses_id);
#for my $datum (sort keys %$user) {          
 #print "$datum=$user->{$datum} / \n";
#}

##################
#Defaults #DEBUG
##################
my $tmplfile  = 'table.tmpl';
my $table     = 'ADM_USERS';
#my $tab       = 't1';
#my $userchoice;

##############
#Read Params
##############
$table       = $cgi_h->param('table') if (defined $cgi_h->param('table'));
#$tab         = $cgi_h->param('tab')   if (defined $cgi_h->param('tab'));
#$userchoice  = $cgi_h->param('userchoice') if (defined $cgi_h->param('userchoice'));


################################################################
#DEBUG: get FIELDS and other data. It will come in $user struct
################################################################
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
                            #associate => $cgi_h
                            );
                            
###############
# General Data
###############
#$template->param(Activetab => $tab);
$template->param(Table     => $table);
$template->param(user      => $user->{login});
#Browser size adjustment	
if ((defined $ENV{'HTTP_REFERER'})&&($ENV{'HTTP_REFERER'} =~ m/login.pl/)) { 
  $template->param(Adjust => 1);
}

#################
# User structure
#################
my $usuario=DO->new(login=>$user->{login},$user->{password}); #DEBUG

########################
# Topics in Menubar
########################
#my @tops;
#my $topics=$usuario->gettopics;
#foreach my $topic(@$topics)
#{
# my %rowh;
# $rowh{Topic} = $topic->{name};
# push @tops, \%rowh;
#}
#$template->param(Topics=>\@tops);

####################################
# Views of the topic in the Menubar
####################################
my @vistas;
my $views=$usuario->getviews($table);
foreach my $view(@$views)
{
 my %rowh;
 $rowh{View} = $view->{NAME};
 push @vistas, \%rowh;
 #print " View: $view->{NAME}\n";
 #my $query=$usuario->getrecords($table,$view->{NAME},'10');
 #my $q=$user->query($query);
}
$template->param(Views=>\@vistas);

######################################
# Reports of the topic in the Menubar
######################################
my @reps;
my $reports=$usuario->getreports($table);
foreach my $report(@$reports)
{
 my %rowh;
 $rowh{Report} = $report->{description}; #DEBUG: desc, name, NAME???
 push @reps, \%rowh;
}
$template->param(Reports=>\@reps);


######################################
# Actions of the topic in the Menubar
######################################
my @mets;
my $actions=$usuario->getactions($table);
foreach my $action(@$actions)
{
 my %rowh;
 $rowh{Action} = $action->{description};
 push @mets, \%rowh;
}
$template->param(Actions=>\@mets);



#####################
#Build the DB query
#####################
######################################################
#Get Records and Fill Table template with the results
######################################################
if (defined $table) {
  my $sqlt = $usuario->getrecords($table,'CUSTOMER');  #DEBUG: VIEW given by DO (the default). Others given by CGI param
  #print "SQLT: $sqlt <br>\n";
  GetRecsForTable_TEST($template,$sqlt,$cgi_h);
  #my $db_sql= "SELECT $fields FROM $table"; #DEBUG: given by DO function
  #GetRecsForTable($template,$db_sql,$cgi_h);
}


################
#TMPL output
################
print $template->output;           
                            


