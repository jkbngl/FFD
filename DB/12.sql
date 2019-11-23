CREATE SCHEMA ffd
    CREATE TABLE cost_types (id SERIAL PRIMARY KEY, name text, created date, update date, create_by text, updated_by text);

select * from ffd.cost_types;