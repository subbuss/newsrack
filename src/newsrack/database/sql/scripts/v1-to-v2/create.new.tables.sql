create table if not exists feeds (
   feed_key         bigint        not null auto_increment,
   feed_tag         varchar(64)   not null,	/* arbitrary */
	feed_name        varchar(128)  not null,	/* obtained from the feed */
      /* Q: Is this dumb optimization below -- of splitting url -- really necessary? */
   url_root         varchar(256)  not null,
   url_tail         varchar(2048) not null,
	cacheable        boolean  default true,
	show_cache_links boolean  default false,
	mins_between_downloads int default 120,
   primary key(feed_key),
	unique(feed_tag)
) charset=utf8 collate=utf8_bin;

create table if not exists users (
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
   unique(uid)
) charset=utf8 collate=utf8_bin;

insert into users (u_key, uid, password, name, email) values(1, "admin", "uw9odiJ0EBx2gsdEXIg1gA==", "Administrator", "subbu@newsrack.in");
insert into users (u_key, uid, password, name, email) values(2, "library", "uw9odiJ0EBx2gsdEXIg1gA==", "Library", "subbu@newsrack.in");

create table if not exists import_dependencies (
	importing_user_key  bigint not null,
   from_user_key       bigint not null,
   constraint fk_import_dependencies_2 foreign key(importing_user_key) references users(u_key),
   constraint fk_import_dependencies_1 foreign key(from_user_key) references users(u_key),
	unique(importing_user_key, from_user_key)
);

create table if not exists topics (
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
   constraint fk_topics_1 foreign key(u_key) references users(u_key)
) charset=utf8 collate=utf8_bin;

create table if not exists user_files (
   u_key      bigint       not null,
   file_name  varchar(256) not null,
   add_time   timestamp   default current_timestamp,
   constraint fk_user_files_1 foreign key(u_key) references users(u_key)
) charset=utf8 collate=utf8_bin;

create table if not exists news_collections (
   ni_key bigint not null,
   n_key  bigint not null,
	unique(ni_key, n_key),
   constraint fk_news_collections_1 foreign key(ni_key) references news_indexes(ni_key),
   constraint fk_news_collections_2 foreign key(n_key) references news_items(n_key)
) charset=utf8 collate=utf8_bin;

create table if not exists cat_news (
   c_key    bigint not null,
   n_key    bigint not null,
   ni_key   bigint not null,
   constraint fk_cat_news_1 foreign key(c_key) references categories(cat_key),
   constraint fk_cat_news_2 foreign key(n_key) references news_items(n_key),
   constraint fk_cat_news_3 foreign key(ni_key) references news_indexes(ni_key)
);

create table if not exists user_collections (
   coll_key  bigint      not null auto_increment,
   coll_name varchar(64) not null, /* name of the collection */
   coll_type char(3)     not null, /* type of the collection - SRC, CPT, FIL */
   u_key     bigint      not null, /* User who has defined the collection */
   uid       char(32)    not null, /* copied from user table in cases where uid is used to fetch collections */
	primary key(coll_key),
   constraint fk_user_collections_1 foreign key(u_key) references users(u_key)
) charset=utf8 collate=utf8_bin;

create table if not exists collection_entries (
   coll_key  bigint not null,  /* collection key */
   entry_key bigint not null,  /* key for the entry; sKey / cat_key / cpt_key */ 
   constraint fk_collection_entries_1 foreign key(coll_key) references collections(coll_key)
);

create table if not exists sources (
   src_key  bigint       not null auto_increment,
   feed_key bigint       not null,   /* The feed that this source references */
   u_key    bigint       not null,   /* The user who has defined this source */
   src_name varchar(256) not null,   /* This is the display name the user has used for the source */
   src_tag  varchar(256) not null,   /* This is the script tag the user has specified for the source */
	cacheable        boolean  default true,	/** DUPLICATED from feeds to save an extra join **/
	show_cache_links boolean  default false,  /** DUPLICATED from feeds to save an extra join **/
	primary key(src_key),
   constraint fk_sources_1 foreign key(feed_key) references feeds(feed_key),
   constraint fk_sources_2 foreign key(u_key) references users(u_key)
) charset=utf8 collate=utf8_bin;

create table if not exists topic_sources (
   t_key      bigint not null,
   src_key    bigint not null,
	feed_key   bigint not null,  /* Duplicated from sources to avoid a join on sources */
   max_ni_key bigint default 0, /* Max id of news item processed for this <t_key,src_key> combination */
   constraint fk_topic_sources_1 foreign key(t_key) references users(t_key),
   constraint fk_topic_sources_2 foreign key(src_key) references sources(src_key)
);

create table if not exists concepts (
   cpt_key  bigint        not null auto_increment,
	u_key    bigint        not null,		/* the user that defined this concept */
   name     varchar(64)   not null,
   defn     text          not null,		/* the definition string for the concept */
	keywords text          not null,    /* all keyword strings that match this concept -- \n separated */
	token    varchar(128),					/* token name used in the lexical scanners */
	primary key(cpt_key),
   constraint fk_concepts_1 foreign key(u_key) references users(u_key)
) charset=utf8 collate=utf8_bin;

create table if not exists categories (
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
   index uid_issue_index(u_key, t_key),
   constraint fk_categories_1 foreign key(f_key) references cat_filters(f_key),
   constraint fk_categories_2 foreign key(u_key) references users(u_key)
) charset=utf8 collate=utf8_bin;

create table if not exists filters (
   f_key        bigint       not null auto_increment,
   u_key        bigint       not null,	/* the user that defined this filter */
   name         varchar(256) not null,	/* name of the filter */
   rule_string  text         not null, /* the rule string for this filter */
	rule_key     bigint,						/* root of the rule tree */
	primary key(f_key)
) charset=utf8 collate=utf8_bin;

create table if not exists filter_rule_terms (
	rt_key	 bigint not null auto_increment,
	f_key     bigint not null,		/* filter that this rule term belongs to */
	term_type int  not null,		/* operator: AND, OR, LEAF_CPT, LEAF_CAT, NOT, ... A value of 0 implies that this a context term entry */
	arg1_key  bigint not null,		/* another rule term, or concept, or category */
	arg2_key  bigint,					/* can be null */
	primary key(rt_key),
   constraint fk_filter_rule_terms_1 foreign key(f_key) references filters(f_key)
) charset=utf8 collate=utf8_bin;
