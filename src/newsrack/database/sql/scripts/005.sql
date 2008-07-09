alter table news_indexes change column created_at created_at date default 0, drop index feed_date_index, drop column date_string, add index feed_index(feed_key);
alter table cat_news change column date_stamp date_stamp date not null;
