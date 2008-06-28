/**
 * This is a table that temporarily holds the list of downloaded news for all feeds
 */
create table if not exists downloaded_news (
   feed_key bigint not null,
	n_key    bigint not null,
   constraint fk_downloaded_news_1 foreign key(feed_key) references feeds(feed_key),
   constraint fk_downloaded_news_2 foreign key(n_key) references news_items(n_key)
);
