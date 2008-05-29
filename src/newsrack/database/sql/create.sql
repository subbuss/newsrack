--drop database newsrack;
create database newsrack;
grant all on newsrack.* to newsrack@localhost;
set password for newsrack@localhost = password('123news');
