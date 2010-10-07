#!/usr/bin/perl

package DO;
use strict;
use warnings;
use DBCONN;
use USERS;

sub new{
	my $class=shift;
   my $self={@_};
   bless($self, $class);
   $self->_initdb; # Creates the db connection
	$self->_inituser; # Check pass and store the basic user info
   return $self;
}

sub query{
# Raw SQL query without permissions
	my $self=shift;
	my $query=shift;
	my $format=shift;
	my $result=$self->{db}->DBCONN::rawget($query,$format);
	$result="Error in query: $DBI::errstr" if $DBI::err;
	return $result;
}

sub gettopics{
# Returns the list of available Topics
	my $self=shift;
	my $result;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_topics where name not in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'OBJECT\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_topics where name in \(select ADM_RESTRICTION_OBJECTS from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=\'OBJECT\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}

sub getviews{
# Returns the list of available Views
	my $self=shift;
	my $topic=shift;
	my $result=$self->{db}->DBCONN::rawget("select `OBJECT`,`NAME`,`DESC`,`HINT` from ADM_VIEWS where OBJECT=\'$topic\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\)");
	return $result;
}

sub getview{
# Returns the details of a View
	my $self=shift;
	my $topic=shift;
	my $view=shift;
	my $result=$self->{db}->DBCONN::rawget("select ADM_VIEW_FIELDS.NAME as NAME,ADM_VIEW_FIELDS.POSITION as POSITION, ADM_VIEW_FIELDS.DESC as `DESC`,ADM_VIEW_FIELDS.HINT from ADM_VIEW_FIELDS,ADM_VIEWS where ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or (USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\)");
	return $result;
}

sub getrelationsto{
# Returns the relationships to where the topic points
	my $self=shift;
	my $topic=shift;
	my $result;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and topic in (select id from doaboo_topics where name=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and topic in (select id from doaboo_topics where name=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}

sub getrelationsfrom{
# Returns the relationships from where the topic points
	my $self=shift;
	my $topic=shift;
	my $result;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and relation in (select id from doaboo_topics where name=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select * from doaboo_attributes where type=\'RELATION\' and relation in (select id from doaboo_topics where name=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='FIELD' and ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}


sub getrecords{
# Returns the complete SQL to fill Table
	my $self=shift;
	my $topic=shift;
	my $view=shift;
	my $limit=shift;

# Step 1: get fields and its types from View. No permissions, if the user can see the view also he can see its fields.
# Description should be eq to desc at doaboo!
	my $qq="select ADM_VIEW_FIELDS.NAME as `name`, ADM_VIEW_FIELDS.RANGE_TYPE as `range`, ADM_VIEW_FIELDS.RANGE as `expression`, ADM_VIEW_FIELDS.ORDER as `order`, ADM_VIEW_FIELDS.SHOW as `show`, doaboo_attributes.type as `type`, `relation`, `topic` from ADM_VIEW_FIELDS,ADM_VIEWS,doaboo_attributes where doaboo_attributes.type <> \'CALCULATED\' and ADM_VIEWS.OBJECT=\'$topic\' and ADM_VIEWS.NAME=\'$view\' and \(\(USER_VIEW=\'$self->{login}\' or GROUP_VIEW IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_VIEW=\'\' and GROUP_VIEW=\'\'\)\) and ADM_VIEW_FIELDS.ADM_VIEW=concat\(\'[[\',ADM_VIEWS.OBJECT,\']][[\',ADM_VIEWS.NAME,\']]\'\) and doaboo_attributes.name=ADM_VIEW_FIELDS.NAME and doaboo_attributes.topic in \(select id from doaboo_topics where name=ADM_VIEWS.OBJECT\) order by ADM_VIEW_FIELDS.POSITION ASC";


	my $fields=$self->{db}->DBCONN::rawget($qq);
#print "########################\n";
#print "$qq\n";
#print "########################\n";

	my @topics;
	push(@topics,$topic);
	my $select_topics='';#$topic;
	my $select_fields='';
	my $select_where='';
	my $select_order='';

# compose where adding more tables

	foreach my $f(@$fields)
	{
		if ($f->{show} ne 'N')
		{
			my $field='';
			my $tn=$topic;
			if ($f->{type} eq 'RELATION')
			{
				# Get the keys to the where
				my $topicname=$self->{db}->DBCONN::rawget("select name,id from doaboo_topics where id=\'$f->{relation}\' limit 1");
				my $topickeys=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic=\'$topicname->[0]->{id}\' and clave=\'Y\'");
				foreach my $topickey(@$topickeys)
				{
					$select_where.="`$topicname->[0]->{name}`.`$topickey->{name}` = `$topic`.`$f->{name}` and ";
					$select_order.="`$topicname->[0]->{name}`.`$topickey->{name}` $f->{order}, " if $f->{order} ne '';
				}
				# Get the fields from the related_table to compose the cap
				my $topicaps=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic=\'$topicname->[0]->{id}\' and key_caption=\'Y\'");
				$tn=$topicname->[0]->{name};
				my $alias=$f->{name};
				foreach my $topicap(@$topicaps)
				{
					$field.="`$topicname->[0]->{name}`.`$topicap->{name}`,' - ', ";
				}
				$field=~s/\,\' \- \'\, \Z//;
				$field="concat($field) as `$alias`";
				push(@topics,$topicname->[0]->{name}) if (not grep(/^$topicname->[0]->{name}$/,@topics));
				# rename f->{name} adding its topic to calc expressions to not being ambiguous
				$f->{name}="$topicname->[0]->{name}`.`$topickeys->[0]->{name}"; # avoid expressions/code into relation fields pointing to multiple keys
			}
			else
			{print "No rel\n";
				$field="`$topic`.`$f->{name}` as `$f->{name}`";
				$f->{name}="$tn`.`$f->{name}"; print "Adding $f->{name}\n";
				$select_order.="`$f->{name}` $f->{order}, " if ($f->{order} ne '');
			}

			$select_fields.="$field, ";

			if ($f->{range} eq 'EXPRESSION')
			{
				$select_where.=_calcexp($f->{name},$f->{expression});
			}
			if ($f->{range} eq 'CODE')
			{
				$select_where.=_calccode($self->{login},$f->{name},$f->{expression});
			}
#			if ($f->{order} ne '')
#			{
#				$select_order.="`$f->{name}` $f->{order}, ";
#			}
		}
	}

	foreach my $t(@topics)
	{
		$select_topics.="`$t`, ";
	}
	$select_topics=~s/\, \Z//;


#print "SELECT FIELDS: $select_fields\n";
# Step 3: improve fields with caption and relationships (?). Relationships should be automanage by foreign keys, but for the captions is a 'pseudo-calculated'... Maybe this is the last step.

# Step 4: get restricions by instance, composing the where section of the query. The result of an eval restrictions.
#$self->{group} instead of Customer

	my $restrictions=$self->{db}->DBCONN::rawget("select ADM_RESTRICTION_DETAIL,ADM_RESTRICTION_CODE from ADM_RESTRICTIONS where ADM_RESTRICTION_OBJECTS=\'$topic\' and ADM_RESTRICTION_GROUP=\'Customer\' and ADM_RESTRICTION_ELEMENT=\'INSTANCE\'");
	foreach my $r(@$restrictions)
	{
		# Add Fake PulsAGo
		$r->{ADM_RESTRICTION_DETAIL}="$topic`.`$r->{ADM_RESTRICTION_DETAIL}";
		$select_where.=_calccode($self->{login},$r->{ADM_RESTRICTION_DETAIL},$r->{ADM_RESTRICTION_CODE});
	}
	
	$select_where=~s/(and \Z)//;
	$select_fields=~s/\, \Z//;
	$select_order=~s/\, \Z//;

   $select_where='where '.$select_where if ($select_where ne '');

	my $query="select SQL_CALC_FOUND_ROWS $select_fields from $select_topics $select_where";
#then execute select FOUND_ROWS();

	if ($select_order ne '')
	{
		$query.=" order by $select_order";
	}
	
	if(defined $limit)
	{
		$query.=" limit $limit";
	}
	return $query;
}


#sub getallrecords{
#	my $self=shift;
#	my $topic=shift;
#	my $result=$self->{db}->DBCONN::rawget("select * from $topic");
#	return $result;
#}

sub getstored{
# Returns the record_details
# No implementa permisos por instancia porque entiendo que un usuario ve lo que puede
# ver y por tanto no le daria a un instance_details de un registro que no ve...
# Pero podría trucar la llamada pasando un ID distinto!!
# Se soluciona agregando al where la seccion del where en base a los permisos.
	my $self=shift;
	my $topic=shift;
	my $where=shift; # where key1='xx' and key2='yy'

	my $fields;
	if($self->{factions} eq 'ALLOWANCE')
	{
		$fields=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=name and ADM_RESTRICTION_GROUP=\'$self->{group}\'\) and type<>\'CALCULATED\'",'SQL'); 
	}
	else
	{
		$fields=$self->{db}->DBCONN::rawget("select name from doaboo_attributes where topic in \(select id from doaboo_topics where name=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT=doaboo_attributes.name and ADM_RESTRICTION_GROUP=\'$self->{group}\'\) and type<>\'CALCULATED\'",'SQL'); 
	}

	my $query="select $fields from $topic where $where limit 1;";
print "Query: $query\n";

	my $result=$self->{db}->DBCONN::rawget($query);
	return $result;
}

sub getreports{
	my $self=shift;
	my $topic=shift;
	my $result=$self->{db}->DBCONN::rawget("select NAME,OBJECT,`DESC`,HINT from ADM_REPORTS where OBJECT=\'$topic\' and \(\(USER_REPORT=\'$self->{login}\' or GROUP_REPORT IN \(select ADM_GROUP from ADM_USERS where ADM_LOGIN=\'$self->{login}\'\)\) or \(USER_REPORT=\'\' and GROUP_REPORT=\'\'\)\)");
	return $result;
}

sub getactions{
	my $self=shift;
	my $topic=shift;
	my $result='';
	if($self->{ractions} eq 'ALLOWANCE')
	{
		$result=$self->{db}->DBCONN::rawget("select `id`,`description`,`hint` from doaboo_actions where topic in \(select id from doaboo_topics where `NAME`=\'$topic\'\) and name not in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='METHOD' and ADM_RESTRICTION_OBJECTS='FILER' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	else
	{
		$result=$self->{db}->DBCONN::rawget("select `id`,`description`,`hint` from doaboo_actions where topic in \(select id from doaboo_topics where `NAME`=\'$topic\'\) and name in \(select ADM_RESTRICTION_DETAIL from ADM_RESTRICTIONS where ADM_RESTRICTION_ELEMENT='METHOD' and ADM_RESTRICTION_OBJECTS='FILER' and ADM_RESTRICTION_GROUP=\'$self->{group}\'\)");
	}
	return $result;
}

sub _calcexp{
	my $field=shift;
	my $expression=shift;

	my $select_where;
	if($expression=~/\[.*\]/) #[2010-05-01,2010]
	{
		my $first=$expression;
		$first=~s/\!|\[|\,.*//g;
		my $second=$expression;
		$second=~s/\!|\[.*\,|\]//g;
		if($expression=~/\!.*/)
		{
			$select_where.="`$field` <= \'$first\' and `$field` >= \'$second\' and ";
   	}
		else
		{
			$select_where="`$field` >= \'$first\' and `$field` <= \'$second\' and ";
		}
	}
	else
	{
		$expression=~s/\,/\|/g;
		$select_where.="`$field` regexp \'$expression\' and ";
	}

	return $select_where;
}

sub _calccode{
	my $login=shift;
	my $field=shift;
	my $expression=shift;

	my $select_where;

	$expression="use FEXIN;use DATETIME;my \$actual_user='$login';".$expression;
	$expression=~s/EXGet/FEXIN::EXGet/g;
	$expression=~s/EXDate/DATETIME::EXDate/g;

	my $eval=eval $expression;

	#FIX (,) by ( )
	$eval=~s/\(\,\)/\( \)/;
	#
	return _calcexp($field,$eval);
}

sub _initdb{
	my $self=shift;
	my $dbh;
	$self->{db}=DBCONN->new();
	return $self;
}

sub _inituser{
	my $self=shift;
	my $user=USERS->new(db=>$self->{db},login=>$self->{login},password=>$self->{password});
	# Compose $self
	foreach my $field (keys %$user){
		$self->{$field}=$user->{$field};
	}
	return $self;
}

sub logout{
	my $self=shift;
	# remove the hash?
	# disconnect DB?
	undef $self;
}
1;
