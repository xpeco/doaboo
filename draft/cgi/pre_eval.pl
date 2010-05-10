#!/usr/bin/perl -w
use strict;
use warnings;

sub _preeval
# Subroutine to extract the edited, stored and options from code
{
	my $source=shift;
	my @edited=();
	my @options=();
	my @stored=();

	while($source=~/(\$edited->{\w*})|(\$stored->{\w*})|(\$options->{\w*})/cg)
	{
		my $var=$&;
		#if($var=~s/^(\$edited->{)&&(\}\Z)//g){print "edited: $var\n";}
		if($var=~s/^(\$edited->{)//g)
		{
			$var=~s/\}\Z//;
			push(@edited,$var) if (not grep(/$var$/,@edited))
		}
		elsif($var=~s/^(\$stored->{)//g)
		{
			$var=~s/\}\Z//;
			push(@stored,$var) if (not grep(/$var$/,@stored))
		}
		elsif($var=~s/^(\$options->{)//g)
		{
			$var=~s/\}\Z//;
			push(@options,$var) if (not grep(/$var$/,@options))
		}
	}
	return (\@edited,\@stored,\@options);
}



my $code=' print hola;
$edited->{e1}=aa;
$stored->{s1}=$edited->{e2}+34;
EXGet_Instance(HH,{$options->{o1},$edited->{e3}}';

my ($refform,$refdb,$refarg)=_preeval($code);

print "Edited:\n";
foreach my $e(@$refform)
{
	print "$e\n";
}
print "Options:\n";
foreach my $e(@$refarg)
{
	print "$e\n";
}
