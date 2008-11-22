-- MySQL dump 10.11
--
-- Host: localhost    Database: obra_development
-- ------------------------------------------------------
-- Server version	5.0.51a

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aliases`
--

DROP TABLE IF EXISTS `aliases`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `aliases` (
  `id` int(11) NOT NULL auto_increment,
  `alias` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `racer_id` int(11) default NULL,
  `team_id` int(11) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_id` (`alias`),
  KEY `idx_racer_id` (`racer_id`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `aliases_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `aliases_ibfk_2` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3690 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `aliases_disciplines`
--

DROP TABLE IF EXISTS `aliases_disciplines`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `aliases_disciplines` (
  `discipline_id` int(11) NOT NULL default '0',
  `alias` varchar(64) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  KEY `idx_alias` (`alias`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `aliases_disciplines_ibfk_1` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bids` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `email` varchar(255) NOT NULL default '',
  `phone` varchar(255) NOT NULL default '',
  `amount` int(11) NOT NULL default '0',
  `approved` tinyint(1) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `position` int(11) NOT NULL default '0',
  `name` varchar(64) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `parent_id` int(11) default NULL,
  `ages_begin` int(11) default '0',
  `ages_end` int(11) default '999',
  `friendly_param` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `categories_name_index` (`name`),
  KEY `parent_id` (`parent_id`),
  KEY `index_categories_on_friendly_param` (`friendly_param`),
  CONSTRAINT `categories_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1570 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `discipline_bar_categories`
--

DROP TABLE IF EXISTS `discipline_bar_categories`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `discipline_bar_categories` (
  `category_id` int(11) NOT NULL default '0',
  `discipline_id` int(11) NOT NULL default '0',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  UNIQUE KEY `discipline_bar_categories_category_id_index` (`category_id`,`discipline_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_discipline_id` (`discipline_id`),
  CONSTRAINT `discipline_bar_categories_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `discipline_bar_categories_ibfk_2` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `disciplines`
--

DROP TABLE IF EXISTS `disciplines`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `disciplines` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(64) NOT NULL default '',
  `bar` tinyint(1) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `numbers` tinyint(1) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `duplicates`
--

DROP TABLE IF EXISTS `duplicates`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `duplicates` (
  `id` int(11) NOT NULL auto_increment,
  `new_attributes` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `duplicates_racers`
--

DROP TABLE IF EXISTS `duplicates_racers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `duplicates_racers` (
  `racer_id` int(11) default NULL,
  `duplicate_id` int(11) default NULL,
  UNIQUE KEY `index_duplicates_racers_on_racer_id_and_duplicate_id` (`racer_id`,`duplicate_id`),
  KEY `index_duplicates_racers_on_racer_id` (`racer_id`),
  KEY `index_duplicates_racers_on_duplicate_id` (`duplicate_id`),
  CONSTRAINT `duplicates_racers_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `duplicates_racers_ibfk_2` FOREIGN KEY (`duplicate_id`) REFERENCES `duplicates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `events` (
  `id` int(11) NOT NULL auto_increment,
  `promoter_id` int(11) default NULL,
  `parent_id` int(11) default NULL,
  `city` varchar(128) default NULL,
  `date` date default NULL,
  `discipline` varchar(32) default NULL,
  `flyer` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  `notes` varchar(255) default '',
  `sanctioned_by` varchar(255) default NULL,
  `state` varchar(64) default NULL,
  `type` varchar(32) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `flyer_approved` tinyint(1) NOT NULL default '0',
  `cancelled` tinyint(1) default '0',
  `oregon_cup_id` int(11) default NULL,
  `notification` tinyint(1) default '1',
  `number_issuer_id` int(11) default NULL,
  `first_aid_provider` varchar(255) default '-------------',
  `pre_event_fees` float default NULL,
  `post_event_fees` float default NULL,
  `flyer_ad_fee` float default NULL,
  `cat4_womens_race_series_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_date` (`date`),
  KEY `idx_disciplined` (`discipline`),
  KEY `parent_id` (`parent_id`),
  KEY `idx_promoter_id` (`promoter_id`),
  KEY `idx_type` (`type`),
  KEY `oregon_cup_id` (`oregon_cup_id`),
  KEY `events_number_issuer_id_index` (`number_issuer_id`),
  KEY `cat4_womens_race_series_id` (`cat4_womens_race_series_id`),
  CONSTRAINT `events_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `events_ibfk_2` FOREIGN KEY (`promoter_id`) REFERENCES `promoters` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_ibfk_3` FOREIGN KEY (`oregon_cup_id`) REFERENCES `events` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_ibfk_4` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `events_ibfk_5` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`),
  CONSTRAINT `events_ibfk_6` FOREIGN KEY (`cat4_womens_race_series_id`) REFERENCES `events` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13378 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `images` (
  `id` int(11) NOT NULL auto_increment,
  `caption` varchar(255) default NULL,
  `html_options` varchar(255) default NULL,
  `link` varchar(255) default NULL,
  `name` varchar(255) NOT NULL default '',
  `source` varchar(255) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `images_name_index` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mailing_lists`
--

DROP TABLE IF EXISTS `mailing_lists`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mailing_lists` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `friendly_name` varchar(255) NOT NULL default '',
  `subject_line_prefix` varchar(255) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `description` text,
  PRIMARY KEY  (`id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `news_items`
--

DROP TABLE IF EXISTS `news_items`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `news_items` (
  `id` int(11) NOT NULL auto_increment,
  `date` date NOT NULL default '0000-00-00',
  `text` varchar(255) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `news_items_date_index` (`date`),
  KEY `news_items_text_index` (`text`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `number_issuers`
--

DROP TABLE IF EXISTS `number_issuers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `number_issuers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `number_issuers_name_index` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `posts` (
  `id` int(11) NOT NULL auto_increment,
  `body` text NOT NULL,
  `date` timestamp NOT NULL default '0000-00-00 00:00:00',
  `sender` varchar(255) NOT NULL default '',
  `subject` varchar(255) NOT NULL default '',
  `topica_message_id` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `mailing_list_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_topica_message_id` (`topica_message_id`),
  KEY `idx_date` (`date`),
  KEY `idx_sender` (`sender`),
  KEY `idx_subject` (`subject`),
  KEY `idx_mailing_list_id` (`mailing_list_id`),
  KEY `idx_date_list` (`date`,`mailing_list_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`mailing_list_id`) REFERENCES `mailing_lists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `promoters`
--

DROP TABLE IF EXISTS `promoters`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `promoters` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) default NULL,
  `name` varchar(255) default '',
  `phone` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `promoter_info` (`name`,`email`,`phone`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `race_numbers`
--

DROP TABLE IF EXISTS `race_numbers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `race_numbers` (
  `id` int(11) NOT NULL auto_increment,
  `racer_id` int(11) NOT NULL default '0',
  `discipline_id` int(11) NOT NULL default '0',
  `number_issuer_id` int(11) NOT NULL default '0',
  `value` varchar(255) NOT NULL default '',
  `year` int(11) NOT NULL default '0',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `racer_id` (`racer_id`),
  KEY `discipline_id` (`discipline_id`),
  KEY `number_issuer_id` (`number_issuer_id`),
  KEY `race_numbers_value_index` (`value`),
  CONSTRAINT `race_numbers_ibfk_1` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `race_numbers_ibfk_2` FOREIGN KEY (`discipline_id`) REFERENCES `disciplines` (`id`),
  CONSTRAINT `race_numbers_ibfk_3` FOREIGN KEY (`number_issuer_id`) REFERENCES `number_issuers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31706 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `racers`
--

DROP TABLE IF EXISTS `racers`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `racers` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(64) default NULL,
  `last_name` varchar(255) default NULL,
  `city` varchar(128) default NULL,
  `date_of_birth` date default NULL,
  `license` varchar(64) default NULL,
  `notes` text,
  `state` varchar(64) default NULL,
  `team_id` int(11) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `cell_fax` varchar(255) default NULL,
  `ccx_category` varchar(255) default NULL,
  `dh_category` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `gender` char(2) default NULL,
  `home_phone` varchar(255) default NULL,
  `mtb_category` varchar(255) default NULL,
  `member_from` date default NULL,
  `occupation` varchar(255) default NULL,
  `road_category` varchar(255) default NULL,
  `street` varchar(255) default NULL,
  `track_category` varchar(255) default NULL,
  `work_phone` varchar(255) default NULL,
  `zip` varchar(255) default NULL,
  `member_to` date default NULL,
  `print_card` tinyint(1) default '0',
  `print_mailing_label` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  KEY `idx_last_name` (`last_name`),
  KEY `idx_first_name` (`first_name`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `racers_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19424 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `races`
--

DROP TABLE IF EXISTS `races`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `races` (
  `id` int(11) NOT NULL auto_increment,
  `standings_id` int(11) NOT NULL default '0',
  `category_id` int(11) NOT NULL default '0',
  `city` varchar(128) default NULL,
  `distance` int(11) default NULL,
  `state` varchar(64) default NULL,
  `field_size` int(11) default NULL,
  `laps` int(11) default NULL,
  `time` float default NULL,
  `finishers` int(11) default NULL,
  `notes` varchar(255) default '',
  `sanctioned_by` varchar(255) default 'OBRA',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `result_columns` varchar(255) default NULL,
  `bar_points` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_standings_id` (`standings_id`),
  CONSTRAINT `races_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `races_ibfk_2` FOREIGN KEY (`standings_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=99846 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `results` (
  `id` int(11) NOT NULL auto_increment,
  `category_id` int(11) default NULL,
  `racer_id` int(11) default NULL,
  `race_id` int(11) NOT NULL default '0',
  `team_id` int(11) default NULL,
  `age` int(11) default NULL,
  `city` varchar(128) default NULL,
  `date` datetime default NULL,
  `date_of_birth` datetime default NULL,
  `is_series` tinyint(1) default NULL,
  `license` varchar(64) default '',
  `notes` varchar(255) default NULL,
  `number` varchar(16) default '',
  `place` varchar(8) default '',
  `place_in_category` int(11) default '0',
  `points` float default '0',
  `points_from_place` float default '0',
  `points_bonus_penalty` float default '0',
  `points_total` float default '0',
  `state` varchar(64) default NULL,
  `status` char(3) default NULL,
  `time` double default NULL,
  `time_bonus_penalty` double default NULL,
  `time_gap_to_leader` double default NULL,
  `time_gap_to_previous` double default NULL,
  `time_gap_to_winner` double default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `time_total` double default NULL,
  `laps` int(11) default NULL,
  `members_only_place` varchar(8) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_race_id` (`race_id`),
  KEY `idx_racer_id` (`racer_id`),
  KEY `idx_team_id` (`team_id`),
  CONSTRAINT `results_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `results_ibfk_3` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE,
  CONSTRAINT `results_ibfk_4` FOREIGN KEY (`racer_id`) REFERENCES `racers` (`id`),
  CONSTRAINT `results_ibfk_5` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6620589 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `schema_info`
--

DROP TABLE IF EXISTS `schema_info`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `scores`
--

DROP TABLE IF EXISTS `scores`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `scores` (
  `id` int(11) NOT NULL auto_increment,
  `competition_result_id` int(11) default NULL,
  `source_result_id` int(11) default NULL,
  `points` double default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `scores_competition_result_id_index` (`competition_result_id`),
  KEY `scores_source_result_id_index` (`source_result_id`),
  CONSTRAINT `scores_ibfk_1` FOREIGN KEY (`competition_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE,
  CONSTRAINT `scores_ibfk_2` FOREIGN KEY (`source_result_id`) REFERENCES `results` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20796661 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `standings`
--

DROP TABLE IF EXISTS `standings`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `standings` (
  `id` int(11) NOT NULL auto_increment,
  `event_id` int(11) NOT NULL default '0',
  `bar_points` int(11) default '1',
  `name` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `ironman` tinyint(1) default '1',
  `position` int(11) default '0',
  `discipline` varchar(32) default NULL,
  `notes` varchar(255) default '',
  `source_id` int(11) default NULL,
  `type` varchar(32) default NULL,
  PRIMARY KEY  (`id`),
  KEY `event_id` (`event_id`),
  KEY `source_id` (`source_id`),
  CONSTRAINT `standings_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `standings_ibfk_2` FOREIGN KEY (`source_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `standings_ibfk_3` FOREIGN KEY (`source_id`) REFERENCES `standings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10768 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `city` varchar(128) default NULL,
  `state` varchar(64) default NULL,
  `notes` varchar(255) default NULL,
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `member` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5615 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `username` varchar(255) NOT NULL default '',
  `password` varchar(255) NOT NULL default '',
  `lock_version` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `idx_alias` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-03-10 15:29:19
