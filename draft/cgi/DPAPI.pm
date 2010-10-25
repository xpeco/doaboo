#!/usr/bin/perl
package DPAPI;

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/peco/doaboo/draft'; # recursive config


sub Init_XML
{
	print "Calling Init_XML - Nothing to do? or init user?\n";
}

sub SearchList
{
	print "NIY\n";
}

sub GetApplication
{
	return $user->{language};
}

sub GetObjects
{
	return $user->gettopics;
}

sub GetMenus
{
	my $parent=shift;
	print "NIY\n";
}

sub GetScripts
{
	return $user->getscripts;
}

sub GetAlarms
{
	return $user->getalarms;
}

sub GetObject
{
	my $topic=shift;
	print "NIY\n";
#	return $user->gettopic($topic);
}

sub GetScript
{
	print "NIY\n";
}

sub GetAlarm
{
	print "NIY\n";
}

sub GetMenu
{
	print "NIY\n";
}

sub GetObjectAttributes
{
	print "NIY\n";
}

sub GetObjectAttribute
{
	print "NIY\n";
}

sub GetObjectAttributesOfView
{
	my $topic=shift;
	my $view=shift;
	return $user->getview($topic,$view);
}

sub GetObjectRelation
{
	print "Not sure...\n";
}

sub GetObjectReports
{
	my $topic=shift;
	return $user->getreports($topic);
}

sub GetObjectUserReports
{
	my $topic=shift;
	return $user->getreports($topic);
}
sub GetObjectReport
{
	my $topic=shift;
	return $user->getreports($topic);
}

sub GetObjectKeys
{
	print "NIY\n";
}

sub GetObjectAccounts
{
	print "NIY\n";
}

sub GetDataOnlyAlarms
{
	print "NIY\n";
}

sub GetDataOnlyUserAlarms
{
	print "NIY\n";
}

sub GetObjectKeyCaptions
{
	print "NIY\n";
}

sub GetObjectMethods
{
	my $topic=shift;
	return $user->getactions($topic);
}

sub GetMethodFields
{
	print "NIY\n";
}

sub GetObjectViews
{
	my $topic;
	return $user->getviews($topic);
}

sub GetObjectUserViews
{
	my $topic;
	return $user->getviews($topic);
}

sub GetObjectView
{
	my $topic;
	my $view;
	return $user->getview($topic,$view);
}

# Temporal Views
