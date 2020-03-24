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
		id serial NOT NULL,
		"name" text NULL,
		created date NULL DEFAULT now(),
		updated date NULL DEFAULT now(),
		created_by text NULL DEFAULT 'UNDEFINED'::text,
		updated_by text NULL DEFAULT 'UNDEFINED'::text,
		mail text NULL,
		CONSTRAINT user_dim_mail_key UNIQUE (mail),
		CONSTRAINT user_dim_pkey PRIMARY KEY (id)
	);

    CREATE TABLE ffd.group_dim (
        id SERIAL PRIMARY KEY,
        name text,
        created date DEFAULT now(),
        updated date DEFAULT now(),
        created_by text DEFAULT 'UNDEFINED',
        updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.company_dim (
        id SERIAL PRIMARY KEY,
        name text,
        created date DEFAULT now(),
        updated date DEFAULT now(),
        created_by text DEFAULT 'UNDEFINED',
        updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.user_in_group (
        user_fk integer REFERENCES ffd.user_dim(id),
        group_fk integer REFERENCES ffd.group_dim(id),
        created date DEFAULT now(),
        updated date DEFAULT now(),
        created_by text DEFAULT 'UNDEFINED',
        updated_by text DEFAULT 'UNDEFINED'
    );

    CREATE TABLE ffd.user_in_company (
        user_fk integer REFERENCES ffd.user_dim(id),
        company_fk integer REFERENCES ffd.company_dim(id),
        created date DEFAULT now(),
        updated date DEFAULT now(),
        created_by text DEFAULT 'UNDEFINED',
        updated_by text DEFAULT 'UNDEFINED'
    );
    
    CREATE TABLE ffd.costtype_dim (
		id serial NOT NULL,
		"name" text NULL,
		"comment" text NULL,
		user_fk int4 NULL DEFAULT '-1'::integer,
		group_fk int4 NULL DEFAULT '-1'::integer,
		company_fk int4 NULL DEFAULT '-1'::integer,
		active int4 NULL DEFAULT 1,
		created date NULL DEFAULT now(),
		updated date NULL DEFAULT now(),
		created_by text NULL DEFAULT 'UNDEFINED'::text,
		updated_by text NULL DEFAULT 'UNDEFINED'::text,
		CONSTRAINT costtype_dim_pkey PRIMARY KEY (id),
		CONSTRAINT costtype_user_uq UNIQUE (name, user_fk),
		CONSTRAINT costtype_dim_company_fk_fkey FOREIGN KEY (company_fk) REFERENCES ffd.company_dim(id),
		CONSTRAINT costtype_dim_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id),
		CONSTRAINT costtype_dim_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id)
	);


    CREATE TABLE ffd.account_dim (
		id serial NOT NULL,
		"name" text NULL,
		"comment" text NULL,
		level_type int4 NULL,
		parent_account int4 NULL,
		user_fk int4 NULL DEFAULT '-1'::integer,
		group_fk int4 NULL DEFAULT '-1'::integer,
		company_fk int4 NULL DEFAULT '-1'::integer,
		created date NULL DEFAULT now(),
		updated date NULL DEFAULT now(),
		created_by text NULL DEFAULT 'UNDEFINED'::text,
		updated_by text NULL DEFAULT 'UNDEFINED'::text,
		active int4 NULL DEFAULT 1,
		CONSTRAINT account_company_uq UNIQUE (name, level_type, company_fk),
		CONSTRAINT account_dim_pkey PRIMARY KEY (id),
		CONSTRAINT account_group_uq UNIQUE (name, level_type, group_fk),
		CONSTRAINT account_user_uq UNIQUE (name, level_type, user_fk),
		CONSTRAINT account_dim_company_fk_fkey FOREIGN KEY (company_fk) REFERENCES ffd.company_dim(id),
		CONSTRAINT account_dim_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id),
		CONSTRAINT account_dim_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id)
	);

   

    CREATE TABLE ffd.act_data (
		id serial NOT NULL,
		amount numeric NULL,
		"comment" text NULL,
		data_date date NULL,
		"year" int4 NULL,
		"month" int4 NULL,
		"day" int4 NULL,
		level1 text NULL DEFAULT 'UNDEFINED'::text,
		level1_fk int4 NULL DEFAULT '-1'::integer,
		level2 text NULL DEFAULT 'UNDEFINED'::text,
		level2_fk int4 NULL DEFAULT '-1'::integer,
		level3 text NULL DEFAULT 'UNDEFINED'::text,
		level3_fk int4 NULL DEFAULT '-1'::integer,
		costtype text NULL DEFAULT 'UNDEFINED'::text,
		costtype_fk int4 NULL DEFAULT '-1'::integer,
		user_fk int4 NULL DEFAULT '-1'::integer,
		group_fk int4 NULL DEFAULT '-1'::integer,
		created timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
		updated timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
		created_by text NULL DEFAULT 'UNDEFINED'::text,
		updated_by text NULL DEFAULT 'UNDEFINED'::text,
		active int4 NULL DEFAULT 1,
		CONSTRAINT act_data_pkey PRIMARY KEY (id),
		CONSTRAINT act_data_costtype_fk_fkey FOREIGN KEY (costtype_fk) REFERENCES ffd.costtype_dim(id),
		CONSTRAINT act_data_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id),
		CONSTRAINT act_data_level1_fk_fkey FOREIGN KEY (level1_fk) REFERENCES ffd.account_dim(id),
		CONSTRAINT act_data_level2_fk_fkey FOREIGN KEY (level2_fk) REFERENCES ffd.account_dim(id),
		CONSTRAINT act_data_level3_fk_fkey FOREIGN KEY (level3_fk) REFERENCES ffd.account_dim(id),
		CONSTRAINT act_data_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id)
	);

    CREATE TABLE ffd.bdg_data (
		id serial NOT NULL,
		amount numeric NULL,
		"comment" text NULL,
		data_date date NULL,
		"year" int4 NULL,
		"month" int4 NULL,
		"day" int4 NULL,
		level1 text NULL DEFAULT 'UNDEFINED'::text,
		level1_fk int4 NULL DEFAULT '-1'::integer,
		level2 text NULL DEFAULT 'UNDEFINED'::text,
		level2_fk int4 NULL DEFAULT '-1'::integer,
		level3 text NULL DEFAULT 'UNDEFINED'::text,
		level3_fk int4 NULL DEFAULT '-1'::integer,
		costtype text NULL DEFAULT 'UNDEFINED'::text,
		costtype_fk int4 NULL DEFAULT '-1'::integer,
		user_fk int4 NULL DEFAULT '-1'::integer,
		group_fk int4 NULL DEFAULT '-1'::integer,
		created timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
		updated timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
		created_by text NULL DEFAULT 'UNDEFINED'::text,
		updated_by text NULL DEFAULT 'UNDEFINED'::text,
		active int4 NULL DEFAULT 1,
		CONSTRAINT bdg_data_pkey PRIMARY KEY (id),
		CONSTRAINT bdg_data_costtype_fk_fkey FOREIGN KEY (costtype_fk) REFERENCES ffd.costtype_dim(id),
		CONSTRAINT bdg_data_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id),
		CONSTRAINT bdg_data_level1_fk_fkey FOREIGN KEY (level1_fk) REFERENCES ffd.account_dim(id),
		CONSTRAINT bdg_data_level2_fk_fkey FOREIGN KEY (level2_fk) REFERENCES ffd.account_dim(id),
		CONSTRAINT bdg_data_level3_fk_fkey FOREIGN KEY (level3_fk) REFERENCES ffd.account_dim(id),
		CONSTRAINT bdg_data_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id)
	);
          
   CREATE TABLE ffd.preference_dim (
        user_fk integer DEFAULT -1 REFERENCES ffd.user_dim(id) UNIQUE,
        group_fk integer DEFAULT -1 REFERENCES  ffd.group_dim(id),
        company_fk integer DEFAULT -1 REFERENCES ffd.company_dim(id),
        costtypes_active bool default true,
        accounts_active bool default true,
        accountsLevel1_active bool default true,
        accountsLevel2_active bool default true,
        accountsLevel3_active bool default true,
        created date DEFAULT now(),
        updated date DEFAULT now(),
        created_by text DEFAULT 'UNDEFINED',
        updated_by text DEFAULT 'UNDEFINED'
   );