create table recent_news_title_hashes(
  n_key       bigint(20),
  title_hash  char(32),
  story_date  date,        
  constraint fk_recent_news_title_hashes_1 foreign key(n_key) references news_items(n_key),
  index title_hash_index(title_hash)
);

-- Uncomment and use to initialize table  
-- insert into recent_news_title_hashes(n_key,title_hash,story_date) (select news_items.n_key, md5(news_items.title), news_indexes.created_at from news_items, news_indexes where news_items.primary_ni_key = news_indexes.ni_key and created_at > '2010-02-25');
