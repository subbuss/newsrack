alter table news_collections add column feed_key bigint;date_stamp date_stamp date not null;
insert into news_collections(n_key, ni_key) (select n_key, primary_ni_key from news_items);
update news_collections nc, news_indexes ni set nc.feed_key = ni.feed_key where nc.ni_key = ni.ni_key;
