#!/usr/bin/perl
package DPAPI;

use strict;
use warnings;

use DO;
$ENV{DOABOOPATH}='/home/aire/doaboocgi'; # recursive config


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
	my $user=shift;
	return $user->{language};
}

sub GetObjects
{
	my $user=shift;
	return $user->gettopics;
}
sub GetObject
{
	my $user=shift;
	my $topic=shift;
	return $user->gettopic($topic);
}
sub GetMenus
{
	my $user=shift;
	my $parent=shift;
	print "NIY\n";
}

sub GetScripts
{
	my $user=shift;
	return $user->getscripts;
}

sub GetAlarms
{
	my $user=shift;
	return $user->getalarms;
}

sub GetScript
{
	my $user=shift;
	print "NIY\n";
}

sub GetAlarm
{
	my $user=shift;
	print "NIY\n";
}

sub GetMenu
{
	my $user=shift;
	print "NIY\n";
}

sub GetObjectAttributes
{
	my $user=shift;
	print "NIY\n";
}

sub GetObjectAttribute
{
	my $user=shift;
	print "NIY\n";
}

sub GetObjectAttributesOfView
{
	my $user=shift;
	my $topic=shift;
	my $view=shift;
	return $user->getview($topic,$view);
}

sub GetObjectRelation
{
	my $user=shift;
	print "Not sure...\n";
}

sub GetObjectReports
{
	my $user=shift;
	my $topic=shift;
	return $user->getreports($topic);
}

sub GetObjectUserReports
{
	my $user=shift;
	my $topic=shift;
	return $user->getreports($topic);
}
sub GetObjectReport
{
	my $user=shift;
	my $topic=shift;
	return $user->getreports($topic);
}

sub GetObjectKeys
{
	my $user=shift;
	print "NIY\n";
}

sub GetObjectAccounts
{
	my $user=shift;
	print "NIY\n";
}

sub GetDataOnlyAlarms
{
	my $user=shift;
	print "NIY\n";
}

sub GetDataOnlyUserAlarms
{
	my $user=shift;
	print "NIY\n";
}

sub GetObjectKeyCaptions
{
	my $user=shift;
	print "NIY\n";
}

sub GetObjectMethods
{
	my $user=shift;
	my $topic=shift;
	return $user->getactions($topic);
}
sub GetObjectMethod
{
	my $user=shift;
	my $topic=shift;
	my $action=shift;
print "HOLA?\n";
	return $user->getaction($topic,$action);
}




sub GetMethodFields
{
	my $user=shift;
	print "NIY\n";
}

sub GetObjectViews
{
	my $user=shift;
	my $topic;
	return $user->getviews($topic);
}

sub GetObjectUserViews
{
	my $user=shift;
	my $topic;
	return $user->getviews($topic);
}

sub GetObjectView
{
	my $user=shift;
	my $topic;
	my $view;
	return $user->getview($topic,$view);
}

# Temporal Views
