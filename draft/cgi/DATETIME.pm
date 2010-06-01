#!/usr/bin/perl -w
use strict;
use warnings;

use Date::Manip;
use Time::HiRes;
use Time::Local;
use Date::Calc;

package DATETIME;

sub EXDate_Nice
{
 if ($_[0] eq '') {$_[0]="today"};
 my $date=&UnixDate($_[0],"%d/%m/%Y");
 return $date;
};

# Today's date (YYYY-MM-DD)
# It returns a variable with today's date with format YYYY-MM-DD
sub EXDate_Today
{
 return Date::Manip::UnixDate("today","%Y-%m-%d");
}


# Date year (YYYY)
# It returns a year with four digits format
# If there is an argument (date YYYY-MM-DD), it returns the corresponding year
# If there's no argument, it returns the present year
sub EXDate_Year
{
 if ($_[0] eq '') {$_[0]="today"};
 return Date::Manip::UnixDate($_[0],"%Y");
}


# Date month (MM)
# It returns a month with two digits format
# If there is an argument (date YYYY-MM-DD), it returns the corresponding month
# If there's no argument, it returns the present month
sub EXDate_Month
{
 if ($_[0] eq '') {$_[0]="today";}
 return Date::Manip::UnixDate($_[0],"%m");
}

# Date month string (MM)
# It returns a month string in English
# If there is an argument (date YYYY-MM-DD), it returns the corresponding month
sub EXDate_MonthString
{
 my $date='Unknown';
 if ($_[0] ne '')
 {
	 $date=Date::Manip::UnixDate($_[0],"%m");
	 $date = Date::Calc::Month_to_Text($date);
 }
 return $date;
}

# It returns the number of month receiving the string (name of the month in english)
sub EXDate_MonthNumber
{
	my $month=shift;
	if($month eq 'January'){return '01';}
	elsif($month eq 'February'){return '02';}
	elsif($month eq 'March'){return '03';}
	elsif($month eq 'April'){return '04';}
	elsif($month eq 'May'){return '05';}
	elsif($month eq 'June'){return '06';}
	elsif($month eq 'July'){return '07';}
	elsif($month eq 'August'){return '08';}
	elsif($month eq 'September'){return '09';}
	elsif($month eq 'October'){return '10';}
	elsif($month eq 'November'){return '11';}
	elsif($month eq 'December'){return '12';}
	else{return 'Unknown';}
}

# Date day (DD)
# It returns a day with two digits format
# If there is an argument (date YYYY-MM-DD), it returns the corresponding day
# If there's no argument, it returns the present day
sub EXDate_Day
{
 if ($_[0] eq '') {$_[0]="today"};
 my $date=Date::Manip::UnixDate($_[0],"%d");
 return $date;
};


# Present something
# It returns a variable with either year, month, day or all of them
# as indicated in the call to the function (OPTIONS:"d","m","Y","%Y-%m-%d")
sub EXDate_Present
{
 my $date=Date::Manip::UnixDate("today","%@_");
 return $date;
};


# COMPARE two dates
# It returns a number =-1,=0,=1 if first date is earlier,
# equal or older than second date, respectively.
# It returns -2 if any of the arguments is an invalid date or amount of time
sub EXDate_Compare
{
 if ( !(&ParseDate($_[0])) || !(&ParseDate($_[1])) ) {return -2;} 
 my $flag=&Date_Cmp($_[0],$_[1]);
 return $flag;
};


## ADD days, months, years, (hours, mins...) to a given date.
## Even add only "business days" (no weekends nor holidays specified into
##  a configuration file). They must be in English by default.
## Response format: %Y-%m-%d by using UnixDate function.
##
## Examples:
## EDate_Add("2003-04-10","-5days");
## EXDate_Add("today","+ 3hours 12minutes 6 seconds",\$err);
## EXDate_Add("12 hours ago","12:30 6Jan90",\$err);
## EXDate_Add("today","+ 3 business days",\$err);
##
## Note: if this function receives 2 dates, it calculates the difference between them, but it's
## not logical to call it from PUMA with 2 dates, because it's not logical to add 2 dates. For ## the time_add function is different, and Delta_Transfrom function is necessary (see below).
sub EXDate_Add
{
 my $date=Date::Manip::UnixDate(Date::Manip::DateCalc($_[0],$_[1]),"%Y-%m-%d");
 return $date;
};


# HOW MANY DAYS between two dates
# DateCalc returns a variable with format: (-)YY:MM:WK:DD:HH:MM:SS
# We extract days, weeks, months and years fields and multiply in each case
# by the corresponding value, to obtain the amount of days (7,30,365).
# For months, when the difference is only one month, we get the exact amount of days
# by getting the days the corresponding month, but when the difference is more than
# 1 month, we multiply by 30, so we get the average.

#sub EXDate_Howmany
#{
# my $err;
# my $delta=&DateCalc($_[0],$_[1],\$err,1);  # (-)YY:MM:WK:DD:HH:MM:SS
# #print "HERE: ".$delta."\n";		            # For DEBUGGING
# my @delta = split(":",$delta);            # UnixDate doesn't work fine here
# 
# my $days=$delta[3];      # Days field
# $days=$days+$delta[2]*7; # Weeks field
# 
 # Months field
# if ($delta[1] eq '1') {		# With only 1 month difference, days exactly.
#   my $eom = EXDate_EOM($_[0]);	# End of month (days in month) of date1
#   $days=$days+$delta[1]*$eom;
#  }
# else {				# With 2 months or more, days approximately
#   $days=$days+$delta[1]*30;
# }

# # Analyse sign (+-) and Transform years into days
# if ($delta[0] =~ /-/) {
#   $days = $days-$delta[0]*365;
#   $days = "-".$days;
# }
# if ($delta[0] =~ /\+/) {
#   $days=$days+$delta[0]*365;
#  } 

#return $days; # Integer
#};

sub EXDate_Howmany
{
	my @date1 = split('-',$_[0]);
	my @date2 = split('-',$_[1]);
	my $days = Date::Calc::Delta_Days(@date1, @date2);   

	return $days  # Returns integer (negative if date2 is earlier than date1)
}


sub EXDate_Howmany_Text
{

   my @date1 = split('-',$_[0]);
   my @date2 = split('-',$_[1]);
   my ($yyyy,$mm,$dd) = Date::Calc::Delta_YMD(@date1, @date2); # return  YYYY,MM,DD
	my $date_in_text="$yyyy years" if ($yyyy !=0);  
	$date_in_text=~s/years/year/ if ($yyyy ==1);

	$date_in_text.=", $mm months" if ($mm !=0);
	$date_in_text=~s/months/month/ if ($mm ==1);
   $date_in_text=~s/,// if ($yyyy ==0);

	$date_in_text.=", $dd days " if ($dd !=0);	
   $date_in_text=~s/days/day/ if ($dd ==1);
   $date_in_text=~s/,// if ($mm ==0);

   return $date_in_text;  # returns   YYYY year(s), MM month(s), DD day(s)
}



# HOW MANY TIME between two dates, specified as a text expression
# (for example: "2 years 4 months 16 days"
# DateCalc returns a variable with format: (-)YY:MM:WK:DD:HH:MM:SS
# and we extract each field and concatenate the corresponding word (month,year...)
# For weeks, we calculate the number of days by multiplying by 7.
#sub EXDate_Howmany_Text
#{
# my $err;
# my $delta=&DateCalc($_[0],$_[1],\$err,1);  # (-)YY:MM:WK:DD:HH:MM:SS
# #print "HERE: ".$delta."\n";		    # DEBUGGING
# my @delta = split(":",$delta);            # UnixDate doesn't work fine here
#
# my $days=$delta[3];		# Days field not null
# if ($delta[2] ne '0') {	# Weeks not null
#   $days=$days+$delta[2]*7;
#  }
#
# if ($delta[1] ne '0') {			    # Months not null
#   $days=$delta[1]." months, ".$days;
# }
#
# if (($delta[0] ne '+0')&&($delta[0] ne '-0')) {   # Years not null
#  $days=$delta[0]." years, ".$days;
# }

# $days = $days." days";
# return $days; # String
#}


# Returns the DAY OF the WEEK of a given date
# 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri 6=Sat 7=Sun
# Processes date in PUMA format in order to
# extract separated fields: year, month, day.
sub EXDate_DOW
{
 my @date=split("-",$_[0]);
 my $year=$date[0];
 my $month=$date[1];
 my $day=$date[2];
 my $dayweek=&Date_DayOfWeek($month,$day,$year);

 if ($dayweek eq '1') { $dayweek="Monday"; }
 elsif ($dayweek eq '2')  { $dayweek="Tuesday"; }
 elsif ($dayweek eq '3') { $dayweek="Wednesday"; }
 elsif ($dayweek eq '4') { $dayweek="Thursday"; }
 elsif ($dayweek eq '5') { $dayweek="Friday"; }
 elsif ($dayweek eq '6') { $dayweek="Saturday"; }
 elsif ($dayweek eq '7') { $dayweek="Sunday"; }
 else   { $dayweek=""; }

 return $dayweek;
};



## Week of Year 
# Use: EXDate_WOY ("Sunday",date) if Week starts on Sunday; date format should be YYYY-MM-DD
# Use: EXDate_WOY ("Monday",date) if Week starts on Monday; date format should be YYYY-MM-DD
# Use: EXDate_WOY ("Sunday") if Week starts on Sunday; date is today
# Use: EXDate_WOY ("Monday") if Week starts on Monday; date is today
## Returns the number of the week,
## Values 01-53 
sub EXDate_WOY
{
	my $init;
	if ($_[0] eq 'Sunday'){$init='%U';}
	if ($_[0] eq 'Monday'){$init='%W';}
	if ($_[1] eq ''){$_[1]="today"};
	my $date=&UnixDate( $_[1],$init);
 return $date;
};
# Returns the DAY OF the WEEK of a given date
# Returns 1 if Mon; 2 if Tue; 3 if Wed; 4 if Thu; 5 if Fri; 6 ifSat; 7 if Sun

sub EXDate_DOW_Number
{
	if ($_[0] eq '') {$_[0]="today"};
	return Date::Manip::UnixDate( $_[0],"%w");
}


# Returns the date of the last Sunday of a given date
# If given date is already sunday, returns given date

sub EXDate_Last_Sunday {
	my $date=shift;
	
	my $dow=EXDate_DOW_Number($date);
	$dow=0 if $dow==7;
	my $days='-'.$dow.'days';
	my $sunday=EXDate_Add($date,$days);
	return $sunday;
}

# Returns the date of the last Monday of a given date
# If given date is already Monday, returns given date

sub EXDate_Last_Monday {
	my $date=shift;
	
	my $dow=EXDate_DOW_Number($date)-1;
	my $days='-'.$dow.'days';
	my $monday=EXDate_Add($date,$days);
	return $monday;
}



# Returns the LAST DAY of the given MONTH (in given year)
# (which is the same as the number of days of the month)
# Processes date in PUMA format in order to
# extract separated fields: year, month.
sub EXDate_EOM
{
 my @date=split("-",$_[0]);
 my $year=$date[0];
 my $month=$date[1];
 my $days=&Date_DaysInMonth($month,$year);
 return $days;
};

#Useful function for obtaining a unique number based on the
#current date / time; with this autonumbering on tables is
#simple and time efficient.
sub EXTimestamp
{
 my $stamp=Time::HiRes::time();
 return $stamp;
};

# Same than last, but now we also add and ID to the timestamp in order
# to be able to identified the node of the Cluster.
# In case of a Cluster with two nodes, in order to write the LOG, we
# need to be sure that both can do it (non duplicate KEY (timestamp of two
# machines can be equals at specific time!)) and the admin can identified
# them.
sub EXTimestampC
{
 my $stamp=Time::HiRes::time();
 return $stamp.'::'.$OSITO::cluster_id;
}


# Present time (HH:MN:SS)
# H=00-23. M=00-59, S=00-59
# It returns a variable with present time with format HH:MN:SS
sub EXTime_Present
{
	return Date::Manip::UnixDate("now","%H:%M:%S");
}


# Time hour: HH=00-23
# It returns an hour with format HH
# If there is an argument (time HH-MN-SS), it returns the corresponding hour
# If there's no argument, it returns the present hour
sub EXTime_Hour
{
 if ($_[0] eq '') {$_[0]="today"};
 return Date::Manip::UnixDate($_[0],"%H");
}

# Time minutes: MN=00-59
# It returns minutes with format MN
# If there is an argument (time HH-MN-SS), it returns the corresponding minutes field
# If there's no argument, it returns the present time's minutes field
sub EXTime_Minutes
{
 if ($_[0] eq '') {$_[0]="today"};
 return Date::Manip::UnixDate($_[0],"%M");
}


#Time seconds: SS=00-59
# It returns seconds with format SS
# If there is an argument (time HH-MN-SS), it returns the corresponding seconds field
# If there's no argument, it returns the present time's seconds field
sub EXTime_Seconds
{
 if ($_[0] eq '') {$_[0]="today"};
 return Date::Manip::UnixDate($_[0],"%S");
}



# Delta transform
# Function DateCalc arguments are: "date/time" and "delta" where "delta" is an amount of time,
# for example, "2hours 12minutes". So we transform second argument of EXTime_Add (which
# is a time in PUMA format) into a delta. Otherwise, DateCalc would calculate the difference
# between the two dates/times.
sub Delta_transform
{
 my @datum = split(":",$_[0]);
  # If time format (split returns more than 1 value)
  # Transformation of "time" into "delta"
  if (@datum ne '1') {
    $datum[0] = $datum[0]."hours";
    $datum[1] = $datum[1]."minutes";
    $datum[2] = $datum[2]."seconds";
    my $datum = $datum[0]." ".$datum[1]." ".$datum[2];
    return $datum;
  }
  else {
   return $_[0];
  }
}


# ADD Time
#
# Add hours/mins/secs: 23:00 + 03:00 = 02:00
# Returns the result in format HH:MN
# (HH=00-23,  MN=00-59, SS=00-59)
# Examples:
# $response = EXTime_Add("20:59","01:02");
# $response = EXTime_Add("today","-2hours");
# $response = EXTime_Add("today","+ 3hours 12minutes 6 seconds",\$err);
# $response = EXTime_Add("12 hours ago","12:30 6Jan90",\$err);
# $response = EXTime_Add("today","uytrpoi",\$err);
sub EXTime_Add
{
  my $datum = Delta_transform($_[1]);
  return Date::Manip::UnixDate(Date::Manip::DateCalc($_[0],$datum),"%H:%M:%S");
}


# Accumulate time
#
# Accumulate hours/mins: 23:00 + 03:00 = 26:00 hours
# Returns the result in format HH:MN
# Both arguments must be time arguments (HH:MN), not "amount of time"
sub EXTime_Accumulate
{
 my @datum1 = split(":",$_[0]);
 my @datum2 = split(":",$_[1]);
 my $time="";
 my $hours=0;
 my $minutes=0;

 $minutes = $datum1[1]+$datum2[1];
 $minutes = $minutes-60;

 if ($minutes >= 0) {
  $hours = 1+$datum1[0]+$datum2[0];  		# Add 1 hour more because minutes > 60
  if ($minutes <= 9) {$minutes = '0'.$minutes;} # Write minutes in two-digits format
 }
 else {
  $hours = $datum1[0]+$datum2[0];
  $minutes=$minutes+60;
 }

 $time = $hours.":".$minutes;
 return $time;
}

# Transform a time value: 00:00:00 in an amount of minutes (decimal).
# The idea is to operate with time values as ints.
sub EXTime_Decimal
{
 my $hora=shift;
 my @cad=split(":",$hora);
 (defined $cad[-1])?$cad[-1]/=3600:0;
 (defined $cad[-2])?$cad[-2]/=60:0;
 (defined $cad[-3])?$cad[-3]/=1:0;
 return EXRound($cad[-3]+$cad[-2]+$cad[-1],2);
}

# Transform a time value: 00:00:00 in an aumount of seconds (int).
# The idea is to operate with time values as ints.
sub EXTime2Int
{
 my $hora=shift;
 my @cad=split(":",$hora);
 (defined $cad[-2])?$cad[-2]*=60:0;
 (defined $cad[-3])?$cad[-3]*=3600:0;
 return $cad[-3]+$cad[-2]+$cad[-1];
}

# From a number of seconds (int) this function returns a time 
# value (00:00:00)
sub EXInt2Time
{
 my $int=shift;
 if($int < 60)
  { 
	if($int=~/^\d$/){$int='0'.$int;}
	my $time="00:".$int;return $time;
  }
 elsif(($int < 3600)and($int > 59))
  {
	my $min=int($int/60);
	if($min=~/^\d$/){$min='0'.$min;}
	my $seg=($int%60);
	if($seg=~/^\d$/){$seg='0'.$seg;}
	my $time=$min.":".$seg;
	return $time;
  }
 elsif($int > 3600)
  {
	my $hour=int($int/3600);
	if($hour=~/^\d$/){$hour='0'.$hour;}
	my $min=int($int/60);
	if($min=~/^\d$/){$min='0'.$min;}
  	my $seg=($int%60);
	if($seg=~/^\d$/){$seg='0'.$seg;}
	my $time=$hour.':'.$min.':'.$seg;
	return $time;
  }
}

sub EXDatetoTimestamp
{
 my $date=shift;
 my ($year,$month,$day)=split(/-/,$date);
 my $ts=timelocal("00","00","00",$day,$month-1,$year);
 return $ts;
}

################# MAIN #####################

# For W32 operating systems, an initialization
# of variable TimeZone is necessary.
if ($^O eq 'MSWin32') {
 Date_Init('TZ=UTC');
}

1;
