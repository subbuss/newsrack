/* *****************************************************************
 * The set of tables below are used to store feed information, news
 * indexes, news items, and collections of news items.  They have
 * no connection with users or topics and have an independent existence!
 * ***************************************************************** */

/** --- feed_table ---
 * This table tracks all unique feeds that have been registered
 * across all users and across all collections.
 */
create table if not exists feed_table (
   feed_key         bigint          not null auto_increment,
   feed_tag         varchar(64)   not null,	/* arbitrary */
	feed_name        varchar(128)  not null,	/* obtained from the feed */
      /* Q: Is this dumb optimization below -- of splitting url -- really necessary? */
   url_root         varchar(256)  not null,
   url_tail         varchar(2048) not null,
	cacheable        boolean  default true,
	show_cache_links boolean  default false,
	mins_between_downloads int default 120,
   primary key(feed_key)
) charset=utf8 collate=utf8_unicode_ci;

/** --- news_index_table ---
 * This is the table that stores information about news indexes.
 * A news index stores information about a (feed, date) pair.
 * SIZE: Big. There will be (X * Y) rows where X is # of feeds
 *       and Y is # of days for which news exists.  So, with 1000 feeds
 *       and 100 days, you have 100,000 rows.
 * UPDATED: Frequently!  X new rows a day where X is # of feeds
 * QUERIED: Frequently!  Whenever a category page is displayed for any user!
 *          (and also for other things like reclassification, browse by source, etc.)
 *          Hence the indexes on (a) key (b) feedid (c) date string
 */
create table if not exists news_index_table (
   ni_key      bigint        not null auto_increment,
   feed_key    bigint        not null,
   date_string char(10)    not null,
      /* date_stamp used primarily for sorting (because ordering by dateStr will be expensive) */
   date_stamp  timestamp   default 0,
   primary key(ni_key),
   constraint fk_news_index_table_1 foreign key(feed_key) references feed_table(feed_key),
   index keyIndex(ni_key),
   index feedDateIndex(feed_key, date_string)
) charset=utf8 collate=utf8_unicode_ci;

/** --- news_item_table ---
 * This is the table that stores information about news items.
 * Note that a news item can be part of multiple indexes ...
 * because news feeds reference the same news item.
 *
 * 'primary_ni_key' is the key to the index that initiated
 * the download of this news item.
 *
 * SIZE: Biggest of the lot!
 * UPDATED: Frequently!  Several times a day!
 * QUERIED: Frequently!  Whenever a category page is displayed for any user!
 *          (and also for other things like reclassification, browse by source, etc.)
 *          Hence the indexes on (a) key (b) url_root, url_tail (c) cached_item_name
 */
create table if not exists news_item_table (
   n_key            bigint not null auto_increment,
   primary_ni_key   bigint not null,
--   feed_key         bigint not null,		/* feed_key is duplicated from news_index_table to reduce joins */
      /* Q: Is this dumb optimization below -- of splitting url -- really necessary? */
   url_root         varchar(128) not null,
   url_tail         varchar(256) not null,
		/* Q: should this simply be an encoded id instead? */
   cached_item_name varchar(256) not null,
   title            text not null,
   description      text,
   author           text,
   primary key(n_key),
   constraint fk_news_item_table_1 foreign key(primary_ni_key) references news_index_table(ni_key),
--   constraint fk_news_item_table_2 foreign key(feed_key) references feed_table(feed_key),
   index key_index(n_key),
   index url_index(url_root(64), url_tail(128)),
   index cached_item_name_index(cached_item_name)
) charset=utf8 collate=utf8_unicode_ci;

/** --- news_collections_table
 * This table keeps track of news items that belong to various
 * news indexes.
 *
 * Q: should this contain all mappings, or only mappings for
 * those news items that belong to multiple indexes?  It seems
 * simpler to have ALL mappings, but, wastes space ... but the
 * additional space usage is perhaps not significant?
 */
create table if not exists news_collections_table (
   ni_key bigint not null,
   n_key  bigint not null,
   constraint fk_news_collections_table_1 foreign key(ni_key) references news_index_table(ni_key),
   constraint fk_news_collections_table_2 foreign key(n_key) references news_item_table(n_key)
);

/* *****************************************************************
 * The set of tables below are used to store user information, topics,
 * taxonomies, news categories, and news items that are classified
 * in there.
 * ***************************************************************** */

/** --- user_table ---
 * SIZE: Smallest!
 * UPDATED: Not so frequently!
 * QUERIED: Frequently!
 */
create table if not exists user_table (
   u_key       bigint       not null auto_increment,
   uid         char(32)     not null,
   password    varchar(32)  not null,
   name        varchar(256) not null,
   email       varchar(256) not null,
	validated   boolean      default false,
	regn_date   timestamp    default current_timestamp,	/* registration date */
	last_update timestamp,
	last_login  timestamp,
   primary key(u_key),
   index uidIndex(uid)
) charset=utf8 collate=utf8_unicode_ci;

/**
 * Reserved user accounts -- add them to the db
 */
insert into user_table (u_key, uid, password, name, email) values(1, "admin", "uw9odiJ0EBx2gsdEXIg1gA==", "Administrator", "subbu@newsrack.in");
insert into user_table (u_key, uid, password, name, email) values(2, "library", "uw9odiJ0EBx2gsdEXIg1gA==", "Library", "subbu@newsrack.in");

/*
 * This table tracks which user accounts import collctions
 * from other users
 */
create table if not exists import_dependency_table (
	importing_user_key  bigint not null,
   from_user_key       bigint not null,
   constraint fk_import_dependency_table_2 foreign key(importing_user_key) references user_table(u_key),
   constraint fk_import_dependency_table_1 foreign key(from_user_key) references user_table(u_key),
	unique(importing_user_key, from_user_key)
);

/** --- topic_table ---
 * SIZE: One of the smallest!
 * UPDATED: Not so frequently!
 * QUERIED: Frequently!
 */
create table if not exists topic_table (
   t_key        bigint       not null auto_increment,
   u_key        bigint       not null,
   name         varchar(256) not null,
   num_articles int          default 0,
   last_update  timestamp    default current_timestamp,
   validated    boolean      default false,
   frozen       boolean      default false,
   private      boolean      default false,
	taxonomy_path text        default null, /* taxonomy path for display on news listing pages */
   primary key(t_key),
   constraint fk_topic_table_1 foreign key(u_key) references user_table(u_key)
) charset=utf8 collate=utf8_unicode_ci;

/** --- cat_table ---
 * This is the table that stores information about categories.
 * IMPORTANT: Categories as containers, not categories as filters!!
 *
 * SIZE: Not too big, since total # of categories across all users will be
 *       relatively small when compared to number of news indexes or number
 *       of news items.
 * UPDATED: Infrequently!  Only when a user adds / modifies any of his issues
 * QUERIED: Frequently!  Whenever a category page is displayed for any user!
 *          Hence the indexes on (a) category key (b) (uid, issue) pair
 */
create table if not exists cat_table (
   cat_key      bigint   not null auto_increment,
   valid        boolean  default true,		/* can be invalid when its containing topic is invalidated */
   name         varchar(256) not null,
   u_key        bigint   not null,   		/* duplicate info from issue table to eliminate joins in some queries */
   t_key        bigint,							/* can be null for categories not assigned to any topic */
   cat_id       int      not null,			/* cat id -- unique within a topic */
   parent_cat   bigint   not null default -1,	/* This is the db key for the parent category, -1 for top-level categories */
	f_key        bigint, 						/* can be null for non-leaf categories, and -1 when it is invalidated */
   last_update  timestamp default current_timestamp,
   num_articles int      default 0,
	taxonomy_path text    default null, 	/* taxonomy path for display on news listing pages */
   primary key(cat_key),
   index keyIndex(cat_key),
   index uidIssueIndex(u_key, t_key),
   constraint fk_cat_table_1 foreign key(f_key) references cat_filter_table(f_key),
   constraint fk_cat_table_2 foreign key(u_key) references user_table(u_key)
) charset=utf8 collate=utf8_unicode_ci;

/** --- cat_news_table ---
 * This is the table that stores information about which categories
 * contain which news items.
 * SIZE: Big!
 * UPDATED: Frequently!  Several times a day!
 * QUERIED: Frequently!  Whenever a category page is displayed for any user!
 *          Hence the composite index on (n_key, c_key).  n_key is used first
 *          because the same index can be used for queries solely on "n_key"
 *          which also occur a lot.
 */
create table if not exists cat_news_table (
   c_key    bigint not null,
   n_key    bigint not null,
   ni_key   bigint not null,
   primary key(c_key, n_key, ni_key),
   constraint fk_cat_news_table_1 foreign key(c_key) references cat_table(cat_key),
   constraint fk_cat_news_table_2 foreign key(n_key) references news_item_table(n_key),
   constraint fk_cat_news_table_3 foreign key(ni_key) references news_index_table(ni_key),
      /* This index is the index that will be most commonly used to respond to browse queries! */
   index cdnIndex(c_key, n_key, ni_key),
   index nIndex(n_key)
);

/* *****************************************************************
 * The set of tables below are tables that are used to support user
 * profiles, information sharing between users, and for defining
 * various kinds of collections (concepts, filters, sources)
 * ***************************************************************** */

/** --- user_files_table ---
 * This table tracks all profile files that a user has defined
 */
create table if not exists user_files_table (
   u_key      bigint       not null,
   file_name  varchar(256) not null,
   add_time   timestamp   default current_timestamp,
   constraint fk_user_files_table_1 foreign key(u_key) references user_table(u_key)
) charset=utf8 collate=utf8_unicode_ci;

/** --- user_collections_table ---
 * This table tracks user-defined collections of various kinds
 */
create table if not exists user_collections_table (
   coll_key  bigint      not null auto_increment,
   coll_name varchar(64) not null, /* name of the collection */
   coll_type char(3)     not null, /* type of the collection - SRC, CPT, FIL */
   u_key     bigint      not null, /* User who has defined the collection */
   uid       char(32)    not null, /* copied from user table in cases where uid is used to fetch collections */
	primary key(coll_key),
   constraint fk_user_collections_table_1 foreign key(u_key) references user_table(u_key)
) charset=utf8 collate=utf8_unicode_ci;

/** --- collection_entries_table ---
 * This table tracks entries belonging to various collections.
 * Assumes that the collection entries have a separate presence
 * in other db tables.
 */
create table if not exists collection_entries_table (
   coll_key  bigint not null,  /* collection key */
   entry_key bigint not null,  /* key for the entry; sKey / cat_key / cpt_key */ 
   constraint fk_collection_entries_table_1 foreign key(coll_key) references collection_table(coll_key)
);

/** --- user_source_table ---
 * This table tracks feed names across all users.
 * Note that users can references the same feed with different
 * tags and different names.  This table tracks those tags.
 */
create table if not exists user_source_table (
   src_key  bigint       not null auto_increment,
--   coll_key     bigint   not null,   /* the collection that this source belongs to */
   feed_key bigint       not null,   /* The feed that this source references */
   u_key    bigint       not null,   /* The user who has defined this source */
   src_name varchar(256) not null,   /* This is the display name the user has used for the source */
   src_tag  varchar(256) not null,   /* This is the script tag the user has specified for the source */
	cacheable        boolean  default true,	/** DUPLICATED from feed_table to save an extra join **/
	show_cache_links boolean  default false,  /** DUPLICATED from feed_table to save an extra join **/
	primary key(src_key),
   constraint fk_user_source_table_1 foreign key(feed_key) references feed_table(feed_key),
   constraint fk_user_source_table_2 foreign key(u_key) references user_table(u_key)
--   constraint fk_user_source_table_3 foreign key(coll_key) references user_collections_table(coll_key)
) charset=utf8 collate=utf8_unicode_ci;

/** --- topic_source_table ---
 * This table tracks what feeds are being used by what topics
 * and what is the last news item processed for a particular
 * source for that topic.
 *
 * Note that ni_id might not necessarily be co-related with
 * n_key of news_item_table .  These values might be generated
 * between reloads of a web application.  But, if we can guarantee
 * that news item keys monotonically increase, this id can
 * reference n_key of news_item_table.
 */
create table if not exists topic_source_table (
   t_key      bigint not null,
   src_key    bigint not null,
	feed_key   bigint not null,  /* Duplicated from user_source_table to avoid a join on user_source_table */
   max_ni_key bigint default 0, /* Max id of news item processed for this <t_key,src_key> combination */
   constraint fk_topic_source_table_1 foreign key(t_key) references user_table(t_key),
   constraint fk_topic_source_table_2 foreign key(src_key) references user_source_table(src_key)
);

/** --- concept_table ---
 * This table tracks all defined concepts across all collections across all users
 * The concept definition is retained unparsed "as is" ... In some cases (where
 * concept definitions are inherited), the set of strings that are matched are
 * dependent on the context within which the concept is expanded.  The strings
 * that match this concept also depend on the matching engine .. i.e. whether
 * the engine implements stemming, pluralization, etc.
 */
create table if not exists concept_table (
   cpt_key  bigint        not null auto_increment,
--   coll_key     bigint   not null,   /* the collection that this concept belongs to */
	u_key    bigint        not null,		/* the user that defined this concept */
   name     varchar(64)   not null,
   defn     text          not null,		/* the definition string for the concept */
	keywords text          not null,    /* all keyword strings that match this concept -- \n separated */
	token    varchar(128),					/* token name used in the lexical scanners */
	primary key(cpt_key),
   constraint fk_concept_table_1 foreign key(u_key) references user_table(u_key)
--   constraint fk_concept_table_2 foreign key(coll_key) references user_collections_table(coll_key)
) charset=utf8 collate=utf8_unicode_ci;

/** --- filter_table ---
 * This table tracks all defined filters across all collections across all users
 * The filter rule is retained unparsed "as is" ... The semantics of the filter
 * will vary depending on the context within which it is parsed.  For example
 * a rule: "x AND y" will mean different things depending on the available
 * concept definitions for 'x' and 'y'
 */
create table if not exists filter_table (
   f_key        bigint       not null auto_increment,
--   coll_key     bigint   not null,  	/* the collection that this filter belongs to */
   u_key        bigint       not null,	/* the user that defined this filter */
   name         varchar(256) not null,	/* name of the filter */
   rule_string  text         not null, /* the rule string for this filter */
	rule_key     bigint,						/* root of the rule tree */
	primary key(f_key)
--   constraint fk_filter_table_3 foreign key(coll_key) references user_collections_table(coll_key)
) charset=utf8 collate=utf8_unicode_ci;

create table if not exists filter_rule_term_table (
	rt_key	 bigint not null auto_increment,
	f_key     bigint not null,		/* filter that this rule term belongs to */
	term_type int  not null,		/* operator: AND, OR, LEAF_CPT, LEAF_CAT, NOT, ... A value of 0 implies that this a context term entry */
	arg1_key  bigint not null,		/* another rule term, or concept, or category */
	arg2_key  bigint,					/* can be null */
	primary key(rt_key),
   constraint fk_filter_rule_term_table_1 foreign key(f_key) references filter_table(f_key)
) charset=utf8 collate=utf8_unicode_ci;

/* *****************************************************************
 * The set of tables below are tables that are used to support various
 * statistical tasks: rating, popularity, etc.
 * ***************************************************************** */
create table if not exists topic_rating_table (
	t_key    bigint not null,
	u_key    bigint not null,
	numVotes int not null,
	numViews int not null,
	constraint fk_topic_rating_table_1 foreign key(t_key) references topic_table(t_key),
	constraint fk_topic_rating_table_2 foreign key(u_key) references user_table(u_key)
);
