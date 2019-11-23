CREATE SCHEMA ffd
    CREATE TABLE cost_types (id SERIAL PRIMARY KEY, name text, created date, update date, create_by text, updated_by text);

select * from ffd.cost_types;

insert into ffd.cost_types (name, created, update, create_by, updated_by) values ('fun', now(), null, 'jakob.engl', null)