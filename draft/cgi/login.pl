#!/usr/bin/perl
use strict;
use warnings;
use DO;
use CGI;
use CGI::Session;
use HTML::Template;

my $cgi  = CGI->new;
my $tmpl = 'login.tmpl'; 
my $user;
my $cookie; 

#############
#Read Params
#############
my $login = $cgi->param('login') if (defined $cgi->param('login'));
my $passw = $cgi->param('pass')  if (defined $cgi->param('pass'));

####################################
#User check and start session if OK
####################################
if ((defined $login)&&(defined $passw)) {
   #Check user and get user struct
   $user = DO->new(login=>$login,password=>$passw);
   #DEBUG, always enter
   $user->{error} = 0;
   #User OK => start session, save user struct, set table.tmpl as output 
   if (not $user->{error}) {
     $tmpl  = "table1.tmpl";	
     #Define session: passing the $cgi object, it will try to retrieve the session id from either the cookie 
     #or query string and initialize the session accordingly (not creating a new one each time). 
     #The name of the cookie and query string parameters are assumed to be CGISESSID  by default.
     #The default storing method is File (undef as 1st param) but MYSQL is also available (see docs)
     my $session = new CGI::Session(undef, $cgi, {Directory=>'/tmp'});
     #Store data into the session
     $session->param("UserStruct", \%$user);
     $session->param('UserLogin',$login);#DEBUG
     #Store session ID in a cookie
     $cookie =  $cgi->cookie(CGISESSID => $session->id);
     #Expiration time #CDA: or specific element only $session->expire(login, '+10m');
     $session->expire('+2h');       
   } 
} 

######################
# Template Definition
######################
#Global_vars to 1 if we want to share them inside/outside loops i.e.
my $t = HTML::Template->new(filename => $tmpl,
                            path     => "$ENV{DOABOOPATH}",
                            die_on_bad_params => 1,
                            global_vars       => 0,
                            case_insensitive  => 1,
                            loop_context_vars => 1
                            #associate => $session
                            );
                            
####################
#Generate output
####################
#Initial screen
if (not defined $user->{error}) {
	$t->param(Message => 'Space for the logo');		
}
else {
  #Error in user authentication, back to the login screen	
  if ($user->{error}) {
    $t->param(Message => 'Error in Login');		
  }
  #User correct, define the parameters for table.tmpl
  else {
  	#Parameters for table.tmpl and do initial user query
    #my $init_db_query = DO->InitUserTable($user);
    #$t->param(Username    => $user->{name});
    #$t->param(Initable    => $user->{itopic});
    #$t->param(Initview    => $user->{iview});
    #$t->param(Recsperpage => $user->{ipp});
    #$t->param(Language    => $user->{language});
    #Or redirect output:
    #print Location... db.pl?table=itopic&tab=t1 #CDA
  }
}

##############
#Print output
##############
print $cgi->header( -cookie=>$cookie );
#print $cgi->header(); #DEBUG  
print $t->output;
