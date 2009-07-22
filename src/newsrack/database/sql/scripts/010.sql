alter table user_files add column file_key int not null auto_increment, change column add_time created_at timestamp default current_timestamp, add constraint primary key(file_key);
alter table user_collections add column file_key int not null, add constraint fk_user_collections_2 foreign key(file_key) references user_files(file_key);
alter table categories change column cat_key c_key bigint not null auto_increment;
