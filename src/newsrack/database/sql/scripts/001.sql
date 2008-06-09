alter table news_collections add unique(ni_key, n_key);
alter table sources add unique(u_key, feed_key, src_tag);

create table if not exists news_item_url_md5_hashes (
   n_key    bigint   not null,
	url_hash char(32) not null,
	constraint fk_1 foreign key(n_key) references news_items(n_key)
);

insert into news_item_url_md5_hashes select n_key, md5(concat(url_root, url_tail)) from news_items;
alter table news_item_url_md5_hashes add index url_hash_index(url_hash);

/** This table is present for backward compability purposes **/
create table if not exists news_item_localnames (
  local_file_name varchar(256) not null, /* FIXME: Deprecate references by full path and progressively get rid of this field! */
  n_key           bigint       not null,
  constraint fk_1 foreign key(n_key) references news_items(n_key)
) charset=utf8 collate=utf8_bin;

insert into news_item_localnames select cached_item_name, n_key from news_items;
alter table news_item_localnames add index file_name_index(local_file_name);

drop index url_index on news_items;
drop index cached_item_name_index on news_items;

alter table news_items drop column cached_item_name;
