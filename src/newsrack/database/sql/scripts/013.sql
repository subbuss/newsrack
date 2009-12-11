alter table feeds add column url varchar(2048) not null;
update feeds set url=concat(url_root,url_tail);
alter table feeds drop column url_root, drop column url_tail;
