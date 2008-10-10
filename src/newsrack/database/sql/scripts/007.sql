alter table news_items add index url_index(url_root, url_tail);
--alter table news_collections drop column feed_key;
--alter table cat_news add column feed_key bigint not null, add constraint fk_cat_news_4 foreign key(feed_key) references feeds(feed_key), drop index unique_index, add unique unique_index(c_key, n_key);
--update cat_news cn, news_indexes ni set cn.feed_key = ni.feed_key where cn.ni_key = ni.ni_key;
