set global myisam_sort_buffer_size=128*1024*1024;
set global sort_buffer_size=128*1024*1024;
set global read_buffer_size=4*1024*1024;

----------------  Migration of news index table --------------------------

alter table news_index_table rename news_indexes;

-- Do the easy things first
alter table news_indexes convert to character set utf8 collate utf8_bin, change column niKey ni_key bigint not null auto_increment, change column dateString date_string char(10) not null, change column dateStamp date_stamp timestamp default 0, add column feed_key bigint not null;

-- Now, need to add feed_key values 
update news_indexes ni set feed_key = (select feed_key from feeds f where f.feed_tag = ni.feedId);

-- Now, drop the feedId column feedId
alter table news_indexes drop column feedId;

alter table news_indexes add index time_stamp_index(date_stamp);

----------------  Migration of news_items table --------------------------

alter table news_item_table rename news_items;

create table if not exists news_item_url_md5_hashes (
   n_key    bigint   not null,
	url_hash char(32) not null,
	constraint fk_1 foreign key(n_key) references news_items(n_key)
);

insert into news_item_url_md5_hashes select nKey, md5(concat(urlRoot, urlTail)) from news_items;
alter table news_item_url_md5_hashes add index url_hash_index(url_hash);

/** This table is present for backward compability purposes **/
create table if not exists news_item_localnames (
  local_file_name varchar(256) not null,
  n_key           bigint       not null,
  constraint fk_1 foreign key(n_key) references news_items(n_key)
) charset=utf8 collate=utf8_bin;

insert into news_item_localnames select localName, nKey from news_items;
alter table news_item_localnames add index file_name_index(local_file_name);

drop index urlIndex on news_items;

-- lastly, change the columns of news_items
alter table news_items delete column localName, convert to character set utf8 collate utf8_bin, change column nKey n_key bigint not null auto_increment, change column niKey primary_ni_key bigint not null, change column urlRoot url_root varchar(128) not null, change column urlTail url_tail varchar(256) not null,  change column title title text not null, change column description description text, change column author author text;

----------------  Migration of shared_news_table --------------------------

insert into news_collections select distinct niKey, nKey from shared_news_table;
-- drop table shared_news_table;
