alter table news_collections add column feed_key bigint;
insert ignore into news_collections(n_key, ni_key) (select n_key, primary_ni_key from news_items);
update news_collections nc, news_indexes ni set nc.feed_key = ni.feed_key where nc.ni_key = ni.ni_key;
alter table cat_news drop index d_index, add index cdn_index(c_key, date_stamp, n_key);
