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
      , active integer DEFAULT 1
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
      , CONSTRAINT costtype_user_uq UNIQUE (name, user_fk)
	  , CONSTRAINT costtype_group_uq UNIQUE (name, group_fk)
      , CONSTRAINT costtype_company_uq UNIQUE (name, company_fk)

    );

    CREATE TABLE ffd.account_dim (
        id SERIAL PRIMARY KEY
      , name text
      , comment text
      , level_type integer
      , parent_account integer
      , user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id) 
      , group_fk integer DEFAULT -1 REFERENCES  ffd.group_dim(id)
      , company_fk integer DEFAULT -1 REFERENCES ffd.company_dim(id)
      , active integer DEFAULT 1
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
      , CONSTRAINT account_user_uq UNIQUE (name, level_type, user_fk)
	  , CONSTRAINT account_group_uq UNIQUE (name, level_type, group_fk)
      , CONSTRAINT account_company_uq UNIQUE (name, level_type, company_fk)
    );
   


    CREATE TABLE ffd.act_data (
        id SERIAL PRIMARY KEY
      , amount NUMERIC
      , comment text
      , data_date date
      , year integer
      , month integer
      , day integer
      , level1 text DEFAULT 'UNDEFINED'
      , level1_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , level2 text DEFAULT 'UNDEFINED'
	  , level2_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
	  , level3 text DEFAULT 'UNDEFINED'
	  , level3_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
	  , costtype text DEFAULT 'UNDEFINED'
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
      , amount NUMERIC
      , comment text
      , data_date date
      , year integer
      , month integer
      , day integer
      , level1 text DEFAULT 'UNDEFINED'
      , level1_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
      , level2 text DEFAULT 'UNDEFINED'
	  , level2_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
	  , level3 text DEFAULT 'UNDEFINED'
	  , level3_fk integer DEFAULT -1 REFERENCES ffd.account_dim(id)
	  , costtype text DEFAULT 'UNDEFINED'
      , costtype_fk integer DEFAULT -1 REFERENCES ffd.costtype_dim(id)
      , user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id)
      , group_fk integer DEFAULT -1 REFERENCES ffd.group_dim(id)
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );
       
   CREATE TABLE ffd.preference_dim (
         user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id) 
      , group_fk integer DEFAULT -1 REFERENCES  ffd.group_dim(id)
      , company_fk integer DEFAULT -1 REFERENCES ffd.company_dim(id)
      , costtypes_active bool default true
      , accounts_active bool default true
      , accountsLevel1_active bool default true
      , accountsLevel2_active bool default true
      , accountsLevel3_active bool default true
      , created date DEFAULT now()
      , updated date DEFAULT now()
      , created_by text DEFAULT 'UNDEFINED'
      , updated_by text DEFAULT 'UNDEFINED'
    );