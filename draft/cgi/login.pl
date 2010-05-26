#!/usr/bin/perl
use strict;
use warnings;
use DO;
use CGI;
use CGI::Session;
use HTML::Template;

my $cgi  = CGI->new;
my $tmpl = 'login.tmpl'; 
my $user;   #user struct given by DO user function
my $cookie; #session cookie 
my $login;  #form value
my $passw;  #form value

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

#############
#Read Params
#############
#Clear former session if it exists, i.e. after a Logout operation
if (defined $cgi->cookie('CGISESSID')) {
  my $sess = new CGI::Session(undef, $cgi, {Directory=>'/tmp'});
  $sess->clear();
  $cookie =  $cgi->cookie('CGISESSID' => '');
}
#Get user data when login form fullfilled
else {
  $login = $cgi->param('login') if (defined $cgi->param('login'));
  $passw = $cgi->param('pass')  if (defined $cgi->param('pass'));
}

############
#User check 
############
if ((defined $login)&&(defined $passw)) {
   #Check user and get user struct
   $user = DO->new(login=>$login,password=>$passw);
   #DEBUG, always enter
   $user->{error} = 0;
   #User OK => start session, save user struct on it and redirect output 
   if (not $user->{error}) {
     #Define session: passing the $cgi object, it will try to retrieve the session id from either the cookie 
     #or query string and initialize the session accordingly (not creating a new one each time). 
     #The name of the cookie and query string parameters are assumed to be CGISESSID  by default.
     #The default storing method is File (undef as 1st param) but MYSQL is also available (see docs)
     my $session = new CGI::Session(undef, $cgi, {Directory=>'/tmp'});
     #Store data into the session
     $session->param("UserStruct", \%$user);
     #Expiration time #CDA: or specific element only $session->expire(login, '+10m');
     $session->expire('+2h');
     #Store session ID in a cookie
     $cookie =  $cgi->cookie(CGISESSID => $session->id);
     #Redirect output:
     #my $url = "/doaboo-cgi/db.pl?table=$user->{itopic}&tab=t1"; #DEBUG
     my $url = "/doaboo-cgi/db.pl?table=ADM_USERS&tab=t1";
     print $cgi->header( -cookie=> $cookie );
     print $cgi->redirect( -URL => $url);       
   }
   else {
   	 $t->param(Message => 'Error in Login');
   } 
}
else {
  $t->param(Message => 'Space for the logo');	
} 

                          
##############
#Print output
##############
print $cgi->header( -cookie=> $cookie );
print $t->output;
