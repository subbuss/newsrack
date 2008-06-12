-- Identify unique news indexes
create table unique_news_indexes (
	ni_key bigint, 
	date_string char(10), 
	created_at timestamp, 
	feed_key bigint,
	unique abcd(feed_key, date_string)
);
insert ignore into unique_news_indexes (select * from news_indexes where feed_key > 0);
alter table unique_news_indexes add index efgh(ni_key);

-- Identify duplicate entries
create table duplicates (
	feed_key bigint, 
	date_string char(10), 
	ni_key bigint
);
insert into duplicates select feed_key, date_string, ni_key from news_indexes ni where feed_key > 0 and ni_key not in (select ni_key from unique_news_indexes);

-- Set up canonical news index values for the duplicates
alter table duplicates add column canonical_ni_key bigint;
update duplicates d set canonical_ni_key = (select t.ni_key from unique_news_indexes t where t.feed_key = d.feed_key and t.date_string = d.date_string);

-- Update all tables that use news_indexes to eliminate refs to the duplicates
update news_items ni, duplicates d set ni.primary_ni_key = d.canonical_ni_key where ni.primary_ni_key=d.ni_key;
update ignore news_collections ni, duplicates d set ni.ni_key = d.canonical_ni_key where ni.ni_key=d.ni_key;
update cat_news ni, duplicates d set ni.ni_key = d.canonical_ni_key where ni.ni_key=d.ni_key;

-- Fix up the news index table last!
delete from news_indexes where feed_key > 0;
insert into news_indexes (select * from unique_news_indexes);

-- Drop the temporary tables
drop table unique_news_indexes;
drop table duplicates;
