-- Change name of the date_stamp column to created_at
alter table news_indexes change column date_stamp created_at timestamp default 0;

-- Add a date_stamp column to cat_news to aid no-join sorting (this will be a duplicate of that in news_indexes)
alter table cat_news add column date_stamp timestamp not null, drop index cdn_index, add unique unique_index(c_key, ni_key, n_key), add index d_index(date_stamp);
update cat_news cn set date_stamp = (select ni.created_at from news_indexes ni where cn.ni_key = ni.ni_key);
