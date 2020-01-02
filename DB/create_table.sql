CREATE SCHEMA ffd
CREATE TABLE ffd.user_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE ffd.group_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE ffd.company_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE ffd.user_in_group (
        user_fk integer REFERENCES ffd.user_dim(id)
      , group_fk integer REFERENCES ffd.group_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE ffd.user_in_company (
        user_fk integer REFERENCES ffd.user_dim(id)
      , company_fk integer REFERENCES ffd.company_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );
    
    CREATE TABLE ffd.costtype_dim (
        id SERIAL PRIMARY KEY
      , name text
      , user_fk integer REFERENCES ffd.user_dim(id)
      , group_fk integer REFERENCES ffd.group_dim(id)
      , company_fk integer REFERENCES ffd.company_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE ffd.account_dim (
        id SERIAL PRIMARY KEY
      , name text
      , level_type integer
      , user_fk integer REFERENCES ffd.user_dim(id)
      , group_fk integer REFERENCES ffd.group_dim(id)
      , company_fk integer REFERENCES ffd.company_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE ffd.act_data (
        id SERIAL PRIMARY KEY
      , amount integer
      , comment text
      , data_date date
      , year integer
      , month integer
      , day integer
      , level_type integer
      , level1_fk integer REFERENCES ffd.account_dim(id)
      , level2_fk integer REFERENCES ffd.account_dim(id)
      , level3_fk integer REFERENCES ffd.account_dim(id)
      , costtype_fk integer REFERENCES ffd.costtype_dim(id)
      , user_fk integer REFERENCES ffd.user_dim(id)
      , group_fk integer REFERENCES ffd.group_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE ffd.bdg_data (
        id SERIAL PRIMARY KEY
      , amount integer
      , comment text
      , data_date date
      , year integer
      , month integer
      , day integer
      , level_type integer
      , level1_fk integer REFERENCES ffd.account_dim(id)
      , level2_fk integer REFERENCES ffd.account_dim(id)
      , level3_fk integer REFERENCES ffd.account_dim(id)
      , costtype_fk integer REFERENCES ffd.costtype_dim(id)
      , user_fk integer REFERENCES ffd.user_dim(id)
      , group_fk integer REFERENCES ffd.group_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );




-- insert into ffd.costtype_dim (name, created, updated, created_by, updated_by) values ('invest', now(), null, 'jakob.engl', null);



