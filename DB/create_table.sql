CREATE SCHEMA ffd
    CREATE TABLE user_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE group_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE company_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE user_in_group (
        user_fk numeric REFERENCES user_dim(id),
      , group_fk numeric REFERENCES group_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE user_in_company (
        user_fk numeric REFERENCES user_dim(id),
      , company_fk numeric REFERENCES company_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );
    
    CREATE TABLE costtype_dim (
        id SERIAL PRIMARY KEY
      , name text
      , user_fk numeric REFERENCES user_dim(id),
      , group_fk numeric REFERENCES group_dim(id)
      , company_fk numeric REFERENCES company_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE account_dim (
        id SERIAL PRIMARY KEY
      , name text
      , level_type numeric
      , user_fk numeric REFERENCES user_dim(id),
      , group_fk numeric REFERENCES group_dim(id)
      , company_fk numeric REFERENCES company_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE act_data (
        id SERIAL PRIMARY KEY
      , amount numeric
      , comment text
      , date date
      , year numeric
      , month numeric
      , day numeric
      , level_type numeric
      , level1_fk numeric REFERENCES account_dim(id)
      , level2_fk numeric REFERENCES account_dim(id)
      , level3_fk numeric REFERENCES account_dim(id)
      , costtype_fk numeric REFERENCES costtype_dim(id)
      , user_fk numeric REFERENCES user_dim(id),
      , group_fk numeric REFERENCES group_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );

    CREATE TABLE act_data (
        id SERIAL PRIMARY KEY
      , amount numeric
      , comment text
      , date date
      , year numeric
      , month numeric
      , day numeric
      , level_type numeric
      , level1_fk numeric REFERENCES account_dim(id)
      , level2_fk numeric REFERENCES account_dim(id)
      , level3_fk numeric REFERENCES account_dim(id)
      , costtype_fk numeric REFERENCES costtype_dim(id)
      , user_fk numeric REFERENCES user_dim(id),
      , group_fk numeric REFERENCES group_dim(id)
      , created date
      , updated date
      , created_by text
      , updated_by text
    );




insert into ffd.costtype_dim (name, created, updated, created_by, updated_by) values ('invest', now(), null, 'jakob.engl', null);



