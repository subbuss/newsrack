----------------  Migration of cat_news_table --------------------------
create table if not exists v1_to_v2_catmap(
   oldkey bigint, 
	newkey bigint, 
	name varchar(255),
	index(oldkey)
);

insert into v1_to_v2_catmap (select old.cKey, new.cat_key, new.name from cat_table old, categories new, topics t, users u where old.name=new.name and old.catId=new.cat_id and new.t_key=t.t_key and t.name=old.issue and new.u_key=u.u_key and u.uid=old.uid);

insert into cat_news(c_key, n_key, ni_key) (select mapping.newkey, cn.nKey, n.primary_ni_key from cat_news_table cn, v1_to_v2_catmap mapping, news_items n where cn.cKey=mapping.oldkey and cn.nKey = n.n_key);
alter table cat_news add index cdn_index(c_key, n_key, ni_key), add index n_index(n_key);

update categories set num_articles = (select count(c_key) from cat_news where cat_key=c_key);

--drop table cat_news_table;
--drop table v1_to_v2_catmap;
