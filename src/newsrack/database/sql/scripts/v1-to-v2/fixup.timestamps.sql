update categories set last_update = (select lastUpdate from cat_table c, v1_to_v2_catmap m where c.cKey=m.oldkey and m.newkey=cat_key);
update topics t set last_update = (select lastUpdate from cat_table c, users u where c.catId=0 and c.issue=t.name and u.u_key=t.u_key and u.uid=c.uid);
