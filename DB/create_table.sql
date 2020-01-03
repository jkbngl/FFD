drop table ffd.user_dim;
drop table ffd.group_dim;
drop table ffd.company_dim;
drop table ffd.user_in_group;
drop table ffd.user_in_company;
drop table ffd.costtype_dim;
drop table ffd.account_dim;
drop table ffd.act_data;
drop table ffd.bdg_data;

CREATE TABLE ffd.user_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.group_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.company_dim (
        id SERIAL PRIMARY KEY
      , name text
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.user_in_group (
        user_fk integer REFERENCES ffd.user_dim(id)
      , group_fk integer REFERENCES ffd.group_dim(id)
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.user_in_company (
        user_fk integer REFERENCES ffd.user_dim(id)
      , company_fk integer REFERENCES ffd.company_dim(id)
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );
    
    CREATE TABLE ffd.costtype_dim (
        id SERIAL PRIMARY KEY
      , name text
      , comment text
      , user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id) 
      , group_fk integer DEFAULT -1 REFERENCES ffd.group_dim(id) 
      , company_fk integer DEFAULT -1 REFERENCES ffd.company_dim(id) 
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.account_dim (
        id SERIAL PRIMARY KEY
      , name text
      , comment text
      , level_type integer
      , user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id) 
      , group_fk integer DEFAULT -1 REFERENCES  ffd.group_dim(id)
      , company_fk integer DEFAULT -1 REFERENCES ffd.company_dim(id)
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
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
      , level1_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , level2_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , level3_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , costtype_fk integer DEFAULT -1 REFERENCES ffd.costtype_dim(id)
      , user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id)
      , group_fk integer DEFAULT -1 REFERENCES ffd.group_dim(id)
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
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
      , level1_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , level2_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , level3_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , costtype_fk integer DEFAULT -1 REFERENCES ffd.costtype_dim(id)
      , user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id)
      , group_fk integer DEFAULT -1 REFERENCES ffd.group_dim(id)
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );