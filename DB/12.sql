CREATE SCHEMA ffd
    CREATE TABLE cost_types (id SERIAL PRIMARY KEY, name text, created date, update date, create_by text, updated_by text);

select * from ffd.cost_types;

insert into ffd.cost_types (name, created, updated, created_by, updated_by) values ('invest', now(), null, 'jakob.engl', null);


ALTER TABLE ffd.cost_types
RENAME update TO updated;

ALTER TABLE ffd.cost_types
RENAME create_by TO created_by;

