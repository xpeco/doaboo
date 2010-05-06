

CREATE TABLE  `spatest`.`doaboo_actions` (
  `id` bigint(20) NOT NULL auto_increment,
  `description` varchar(250) character set latin1 default NULL,
  `hint` varchar(250) character set latin1 default NULL,
  `step0` varchar(200) character set latin1 default NULL,
  `step1` varchar(200) character set latin1 default NULL,
  `step2` varchar(200) character set latin1 default NULL,
  `step3` varchar(200) character set latin1 default NULL,
  `fields` text character set latin1,
  `topic` bigint(20) NOT NULL,
  `private` enum('Y','N') character set latin1 NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `topic` (`topic`),
  CONSTRAINT `topic` FOREIGN KEY (`topic`) REFERENCES `doaboo_topics` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8

CREATE TABLE  `spatest`.`doaboo_attributes` (
  `id` bigint(20) NOT NULL auto_increment,
  `description` varchar(250) character set latin1 default NULL,
  `hint` varchar(250) character set latin1 default NULL,
  `type` enum('AUTO','CHAR','INT','FLOAT','LINK','ACCOUNT','OWN_ACCOUNT','RELATION','MEMO','TIME','DATE','BOOLEAN','CALCULTATED') character set latin1 NOT NULL,
  `key` enum('Y','N') character set latin1 NOT NULL,
  `required` enum('Y','N') character set latin1 NOT NULL,
  `key_caption` enum('Y','N') character set latin1 NOT NULL,
  `recalculated` enum('Y','N') character set latin1 NOT NULL,
  `list` enum('Y','N') character set latin1 NOT NULL,
  `range` enum('Y','N') character set latin1 NOT NULL,
  `range_logic` varchar(200) character set latin1 default NULL,
  `hide` enum('Y','N') character set latin1 NOT NULL,
  `hide_logic` varchar(200) character set latin1 default NULL,
  `caption` enum('Y','N') character set latin1 NOT NULL,
  `caption_logic` varchar(200) character set latin1 default NULL,
  `subtype` enum('AUTO','CHAR','INT','FLOAT','LINK','ACCOUNT','OWN_ACCOUNT','RELATION','MEMO','TIME','DATE','BOOLEAN') character set latin1 default NULL,
  `calculated_logic` varchar(200) character set latin1 default NULL,
  `relation` bigint(20) default NULL,
  `topic` bigint(20) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `relation` (`relation`),
  CONSTRAINT `relation` FOREIGN KEY (`relation`) REFERENCES `doaboo_topics` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8

CREATE TABLE  `spatest`.`doaboo_fields` (
  `id` bigint(20) NOT NULL auto_increment,
  `action` bigint(20) NOT NULL,
  `attribute` bigint(20) NOT NULL,
  `logic` varchar(200) character set latin1 NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `attribute` (`attribute`),
  KEY `action` (`action`),
  CONSTRAINT `action` FOREIGN KEY (`action`) REFERENCES `doaboo_actions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attribute` FOREIGN KEY (`attribute`) REFERENCES `doaboo_attributes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8

CREATE TABLE  `spatest`.`doaboo_menu` (
  `id` bigint(20) NOT NULL auto_increment,
  `type` enum('FOLDER','TOPIC','URL') character set latin1 NOT NULL,
  `entry` bigint(20) default NULL,
  `description` varchar(200) character set latin1 default NULL,
  `parent` varchar(200) character set latin1 default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8

CREATE TABLE  `spatest`.`doaboo_scripts` (
  `id` bigint(20) NOT NULL auto_increment,
  `description` varchar(250) character set latin1 NOT NULL,
  `hint` varchar(250) character set latin1 default NULL,
  `step0` varchar(200) character set latin1 default NULL,
  `step2` varchar(200) character set latin1 default NULL,
  `type` enum('NEW','NORMAL','DELETE') character set latin1 NOT NULL,
  `fields` text character set latin1,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8

CREATE TABLE  `spatest`.`doaboo_topics` (
  `id` bigint(20) NOT NULL auto_increment,
  `description` varchar(250) character set latin1 default NULL,
  `hint` varchar(250) character set latin1 default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=234 DEFAULT CHARSET=utf8


