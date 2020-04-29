--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md5be6dd5330ee8023e3960b80d23eed325';






--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1 (Debian 12.1-1.pgdg100+1)
-- Dumped by pg_dump version 12.1 (Debian 12.1-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1 (Debian 12.1-1.pgdg100+1)
-- Dumped by pg_dump version 12.1 (Debian 12.1-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ffd; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ffd;


ALTER SCHEMA ffd OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_dim; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.account_dim (
    id integer NOT NULL,
    name text,
    comment text,
    level_type integer,
    parent_account integer,
    user_fk integer DEFAULT '-1'::integer,
    group_fk integer DEFAULT '-1'::integer,
    company_fk integer DEFAULT '-1'::integer,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text,
    active integer DEFAULT 1
);


ALTER TABLE ffd.account_dim OWNER TO postgres;

--
-- Name: account_dim_id_seq; Type: SEQUENCE; Schema: ffd; Owner: postgres
--

CREATE SEQUENCE ffd.account_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ffd.account_dim_id_seq OWNER TO postgres;

--
-- Name: account_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: ffd; Owner: postgres
--

ALTER SEQUENCE ffd.account_dim_id_seq OWNED BY ffd.account_dim.id;


--
-- Name: act_data; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.act_data (
    id integer NOT NULL,
    amount numeric,
    comment text,
    data_date date,
    year integer,
    month integer,
    day integer,
    level1 text DEFAULT 'UNDEFINED'::text,
    level1_fk integer DEFAULT '-1'::integer,
    level2 text DEFAULT 'UNDEFINED'::text,
    level2_fk integer DEFAULT '-1'::integer,
    level3 text DEFAULT 'UNDEFINED'::text,
    level3_fk integer DEFAULT '-1'::integer,
    costtype text DEFAULT 'UNDEFINED'::text,
    costtype_fk integer DEFAULT '-1'::integer,
    user_fk integer DEFAULT '-1'::integer,
    group_fk integer DEFAULT '-1'::integer,
    created timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text,
    active integer DEFAULT 1
);


ALTER TABLE ffd.act_data OWNER TO postgres;

--
-- Name: act_data_id_seq; Type: SEQUENCE; Schema: ffd; Owner: postgres
--

CREATE SEQUENCE ffd.act_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ffd.act_data_id_seq OWNER TO postgres;

--
-- Name: act_data_id_seq; Type: SEQUENCE OWNED BY; Schema: ffd; Owner: postgres
--

ALTER SEQUENCE ffd.act_data_id_seq OWNED BY ffd.act_data.id;


--
-- Name: bdg_data; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.bdg_data (
    id integer NOT NULL,
    amount numeric,
    comment text,
    data_date date,
    year integer,
    month integer,
    day integer,
    level1 text DEFAULT 'UNDEFINED'::text,
    level1_fk integer DEFAULT '-1'::integer,
    level2 text DEFAULT 'UNDEFINED'::text,
    level2_fk integer DEFAULT '-1'::integer,
    level3 text DEFAULT 'UNDEFINED'::text,
    level3_fk integer DEFAULT '-1'::integer,
    costtype text DEFAULT 'UNDEFINED'::text,
    costtype_fk integer DEFAULT '-1'::integer,
    user_fk integer DEFAULT '-1'::integer,
    group_fk integer DEFAULT '-1'::integer,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text,
    active integer DEFAULT 1
);


ALTER TABLE ffd.bdg_data OWNER TO postgres;

--
-- Name: bdg_data_id_seq; Type: SEQUENCE; Schema: ffd; Owner: postgres
--

CREATE SEQUENCE ffd.bdg_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ffd.bdg_data_id_seq OWNER TO postgres;

--
-- Name: bdg_data_id_seq; Type: SEQUENCE OWNED BY; Schema: ffd; Owner: postgres
--

ALTER SEQUENCE ffd.bdg_data_id_seq OWNED BY ffd.bdg_data.id;


--
-- Name: company_dim; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.company_dim (
    id integer NOT NULL,
    name text,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text
);


ALTER TABLE ffd.company_dim OWNER TO postgres;

--
-- Name: company_dim_id_seq; Type: SEQUENCE; Schema: ffd; Owner: postgres
--

CREATE SEQUENCE ffd.company_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ffd.company_dim_id_seq OWNER TO postgres;

--
-- Name: company_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: ffd; Owner: postgres
--

ALTER SEQUENCE ffd.company_dim_id_seq OWNED BY ffd.company_dim.id;


--
-- Name: costtype_dim; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.costtype_dim (
    id integer NOT NULL,
    name text,
    comment text,
    user_fk integer DEFAULT '-1'::integer,
    group_fk integer DEFAULT '-1'::integer,
    company_fk integer DEFAULT '-1'::integer,
    active integer DEFAULT 1,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text
);


ALTER TABLE ffd.costtype_dim OWNER TO postgres;

--
-- Name: costtype_dim_id_seq; Type: SEQUENCE; Schema: ffd; Owner: postgres
--

CREATE SEQUENCE ffd.costtype_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ffd.costtype_dim_id_seq OWNER TO postgres;

--
-- Name: costtype_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: ffd; Owner: postgres
--

ALTER SEQUENCE ffd.costtype_dim_id_seq OWNED BY ffd.costtype_dim.id;


--
-- Name: group_dim; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.group_dim (
    id integer NOT NULL,
    name text,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text
);


ALTER TABLE ffd.group_dim OWNER TO postgres;

--
-- Name: group_dim_id_seq; Type: SEQUENCE; Schema: ffd; Owner: postgres
--

CREATE SEQUENCE ffd.group_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ffd.group_dim_id_seq OWNER TO postgres;

--
-- Name: group_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: ffd; Owner: postgres
--

ALTER SEQUENCE ffd.group_dim_id_seq OWNED BY ffd.group_dim.id;


--
-- Name: preference_dim; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.preference_dim (
    user_fk integer DEFAULT '-1'::integer,
    group_fk integer DEFAULT '-1'::integer,
    company_fk integer DEFAULT '-1'::integer,
    costtypes_active boolean DEFAULT true,
    accounts_active boolean DEFAULT true,
    accountslevel1_active boolean DEFAULT true,
    accountslevel2_active boolean DEFAULT true,
    accountslevel3_active boolean DEFAULT true,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text
);


ALTER TABLE ffd.preference_dim OWNER TO postgres;

--
-- Name: user_dim; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.user_dim (
    id integer NOT NULL,
    name text,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text,
    mail text
);


ALTER TABLE ffd.user_dim OWNER TO postgres;

--
-- Name: user_dim_id_seq; Type: SEQUENCE; Schema: ffd; Owner: postgres
--

CREATE SEQUENCE ffd.user_dim_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ffd.user_dim_id_seq OWNER TO postgres;

--
-- Name: user_dim_id_seq; Type: SEQUENCE OWNED BY; Schema: ffd; Owner: postgres
--

ALTER SEQUENCE ffd.user_dim_id_seq OWNED BY ffd.user_dim.id;


--
-- Name: user_in_company; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.user_in_company (
    user_fk integer,
    company_fk integer,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text
);


ALTER TABLE ffd.user_in_company OWNER TO postgres;

--
-- Name: user_in_group; Type: TABLE; Schema: ffd; Owner: postgres
--

CREATE TABLE ffd.user_in_group (
    user_fk integer,
    group_fk integer,
    created date DEFAULT now(),
    updated date DEFAULT now(),
    created_by text DEFAULT 'UNDEFINED'::text,
    updated_by text DEFAULT 'UNDEFINED'::text
);


ALTER TABLE ffd.user_in_group OWNER TO postgres;

--
-- Name: account_dim id; Type: DEFAULT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.account_dim ALTER COLUMN id SET DEFAULT nextval('ffd.account_dim_id_seq'::regclass);


--
-- Name: act_data id; Type: DEFAULT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data ALTER COLUMN id SET DEFAULT nextval('ffd.act_data_id_seq'::regclass);


--
-- Name: bdg_data id; Type: DEFAULT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data ALTER COLUMN id SET DEFAULT nextval('ffd.bdg_data_id_seq'::regclass);


--
-- Name: company_dim id; Type: DEFAULT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.company_dim ALTER COLUMN id SET DEFAULT nextval('ffd.company_dim_id_seq'::regclass);


--
-- Name: costtype_dim id; Type: DEFAULT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.costtype_dim ALTER COLUMN id SET DEFAULT nextval('ffd.costtype_dim_id_seq'::regclass);


--
-- Name: group_dim id; Type: DEFAULT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.group_dim ALTER COLUMN id SET DEFAULT nextval('ffd.group_dim_id_seq'::regclass);


--
-- Name: user_dim id; Type: DEFAULT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.user_dim ALTER COLUMN id SET DEFAULT nextval('ffd.user_dim_id_seq'::regclass);


--
-- Data for Name: account_dim; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.account_dim (id, name, comment, level_type, parent_account, user_fk, group_fk, company_fk, created, updated, created_by, updated_by, active) FROM stdin;
466	BO		1	\N	1	-1	-1	2020-04-19	2020-04-19	UNDEFINED	UNDEFINED	1
467	BOBO		2	466	1	-1	-1	2020-04-19	2020-04-19	UNDEFINED	UNDEFINED	1
67	FLIXBUS	flixbus costs, seperate from abo+ bus costs	2	51	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
42	PIMS	yy	2	1	1	-1	-1	2020-01-21	2020-01-21	UNDEFINED	UNDEFINED	1
54	CRYPTO	all investements in crypto	2	53	1	-1	-1	2020-02-04	2020-02-04	UNDEFINED	UNDEFINED	1
73	TRAVEL	travel costs	1	\N	1	-1	-1	2020-02-17	2020-04-05	UNDEFINED	UNDEFINED	1
1	EATING OUT	costs for eating at restaurants and so	1	\N	1	-1	-1	2020-01-05	2020-01-05	UNDEFINED	UNDEFINED	1
86	CONTRACT	costs for the contract	2	85	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
-100	UNDEFINED	default account for level 2	2	-1	-1	-1	-1	2020-01-05	2020-01-05	UNDEFINED	UNDEFINED	1
-99	UNDEFINED	default account for level 1	1	\N	-1	-1	-1	2020-01-05	2020-01-05	UNDEFINED	UNDEFINED	1
7	FOR ME	all groceries bought for me	2	2	1	-1	-1	2020-01-10	2020-01-10	UNDEFINED	UNDEFINED	1
8	FOR FAM	all groceries bought for my family	2	2	1	-1	-1	2020-01-10	2020-01-10	UNDEFINED	UNDEFINED	1
87	PRODUCTIVITY	productivity investments like new hardware	2	53	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
-101	UNDEFINED	default account for level 3	3	-2	-1	-1	-1	2020-01-05	2020-01-05	UNDEFINED	UNDEFINED	1
5	MOTOR	costs for motor repairs	3	4	1	-1	-1	2020-01-05	2020-01-05	UNDEFINED	UNDEFINED	1
2	GROCERIES	costs for buying groceries	1	\N	1	-1	-1	2020-01-05	2020-01-05	UNDEFINED	UNDEFINED	1
9	FOR OTHER	all groceries bought for other people	2	2	1	-1	-1	2020-01-10	2020-01-10	UNDEFINED	UNDEFINED	1
88	TECHNOLOGY	technology investments	3	87	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
63	PRESENTS	all costs for presents	1	\N	1	-1	-1	2020-02-12	2020-02-12	UNDEFINED	UNDEFINED	1
64	FUN	fun stuff like cinema or so	1	\N	1	-1	-1	2020-02-16	2020-02-16	UNDEFINED	UNDEFINED	1
66	RADIO	radio repairs	3	4	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
65	CINEMA	cinema stuff like tickets drinks and so	2	64	1	-1	-1	2020-02-16	2020-02-16	UNDEFINED	UNDEFINED	1
360	HOODIES		2	81	1	-1	-1	2020-04-05	2020-04-05	UNDEFINED	UNDEFINED	0
6	GAS	costs for gas for the car	2	3	1	-1	-1	2020-01-06	2020-01-06	UNDEFINED	UNDEFINED	1
4	REPAIRS	costs for repairs	2	3	1	-1	-1	2020-01-05	2020-01-05	UNDEFINED	UNDEFINED	1
46	COFFEE	all coffee bar related costs	1	\N	1	-1	-1	2020-01-23	2020-01-23	UNDEFINED	UNDEFINED	1
47	CHINESE	chinese costs	2	1	1	-1	-1	2020-01-23	2020-01-23	UNDEFINED	UNDEFINED	1
48	PIZZA		2	1	1	-1	-1	2020-01-25	2020-01-25	UNDEFINED	UNDEFINED	1
49	BODY	friseur, cremen ...	1	\N	1	-1	-1	2020-01-25	2020-01-25	UNDEFINED	UNDEFINED	1
50	FRISEUR	carmen	2	49	1	-1	-1	2020-01-25	2020-01-25	UNDEFINED	UNDEFINED	1
44	COOFEE	hh	3	42	1	-1	-1	2020-01-21	2020-01-21	UNDEFINED	UNDEFINED	0
43	BURGER	hh	3	42	1	-1	-1	2020-01-21	2020-01-21	UNDEFINED	UNDEFINED	0
52	SUBURBAN	all external suburban costs for trips to munich, london, etc	2	51	1	-1	-1	2020-02-03	2020-02-03	UNDEFINED	UNDEFINED	1
53	INVEST	accounts for investing in crypto or real estate or whatever	1	\N	1	-1	-1	2020-02-04	2020-02-04	UNDEFINED	UNDEFINED	1
72	FORFAM	present for fam	2	63	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
74	HOTEL	hotel costs at travels	2	63	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
75	TRANSPORTATION COSTS	costs for busrides, plane tickets and so	2	73	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
76	GF	present costs for gf	2	63	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
77	BURGER	burger costs	2	1	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
78	BREAKFAST	eating out breakfast	2	1	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
79	INSURANCE	car inscurance costs	2	3	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
80	TAX	car tax costs	2	3	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
81	CLOTHES	clothes costs	1	\N	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
82	SHOES	shoe costs	2	81	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
83	SHIRTS	shirt costs	2	81	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
84	TROUSERS	trousers costs	2	81	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
85	PHONE	phone costs	1	\N	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
89	TICKETS	speeding or parking tickets	2	3	1	-1	-1	2020-02-17	2020-02-17	UNDEFINED	UNDEFINED	1
90	BREAKS	costs for break repairs	3	4	1	-1	-1	2020-02-22	2020-02-22	UNDEFINED	UNDEFINED	1
3	CAR	all car related costs	1	\N	1	-1	-1	2020-01-05	2020-04-13	UNDEFINED	UNDEFINED	1
94	KEBAB	kebab costs	2	1	1	-1	-1	2020-02-27	2020-02-27	UNDEFINED	UNDEFINED	1
95	FITNESS	fitness costs like protein or straps or stuff like this	2	53	1	-1	-1	2020-03-01	2020-03-01	UNDEFINED	UNDEFINED	1
96	PROTEIN	protein buying costs	3	95	1	-1	-1	2020-03-01	2020-03-01	UNDEFINED	UNDEFINED	1
97	PROTECTION	hülle und folie und so	2	85	1	-1	-1	2020-03-18	2020-03-18	UNDEFINED	UNDEFINED	1
468	BOBOBO		3	467	1	-1	-1	2020-04-19	2020-04-19	UNDEFINED	UNDEFINED	1
204	CAR	all car related costs	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
205	GAS	all gas costs for the car	2	204	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
206	INSURANCE	all insurcance costs for the car	2	204	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
207	TAX	all tac costs for the car	2	204	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
208	TIRES	all costs for tires for the car	2	204	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
209	OTHER	other car related costs	2	204	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
210	REPAIRS	all car related repair costs	2	204	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
211	MOTOR	all motor repairs costs for the car	3	210	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
212	BREAKS	all breaks repairs costs for the car	3	210	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
213	WINDOWS	all windows repairs costs for the car	3	210	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
214	OTHER	all other repairs costs for the car	3	210	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
215	CLOTHES	all clothes related costs	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
216	SHOES	all costs for shoes	2	215	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
217	SHIRTS	all costs for shoes	2	215	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
218	TROUSERS	all costs for trousers	2	215	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
219	HOODIES	all costs for hoodies	2	215	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
220	CAPS	all costs for caps	2	215	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
221	OTHER	all other clothes related costs	2	215	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
222	EATING OUT	all costs related to eating out	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
223	PIZZA	all costs for eating out when eating pizza	2	222	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
224	BURGER	all costs for eating out when eating burger	2	222	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
225	HEALTHY	all costs for eating out when eating healthy	2	222	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
226	OTHER	all costs for eating out when eating other stuff	2	222	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
227	GROCERIES	all costs related to groceries	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
228	FOR FAM	all costs for groceries for the family	2	227	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
229	FOR ME	all costs for groceries for myself	2	227	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
230	OTHER	all other groceries related costs	2	227	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
231	PHONE	all phone related costs	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
232	CONTRACT	all phone costs for contracts	2	231	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
233	NEW PHONE	all costs for new phones	2	231	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
234	ACCESSOIRES	all costs for accessoires of the phone, like covers	2	231	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
235	OTHER	all other phone related costs	2	231	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
236	PRESENTS	all costs for presents	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
237	FOR MAM	all costs for presents for mam	2	236	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
238	FOR DAD	all costs for presents for dad	2	236	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
239	FOR GF	all costs for presents for gf	2	236	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
240	FOR FRIENDS	all costs for presents for friends	2	236	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
241	OTHER	all presents for other people	2	236	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
242	TRAVEL	all travel related costs	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
243	HOTEL	all hotel related costs	2	242	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
244	FLIGHTS	all flight related costs	2	242	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
245	EXCURSIONS	all excursions related costs	2	242	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
246	OTHER	all other related costs for travels	2	242	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
247	PUBLIC TRANSPORTATION	all public transportations related costs	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
248	TRAIN	all train related costs	2	247	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
249	BUS	all bus related costs	2	247	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
250	CABLE CAR	all cable car related costs	2	247	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
251	CAR	cost for e.g. carsharing	2	247	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
252	SUBURBAN	all suburban related costs	2	247	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
253	OTHER	all other public transportations related costs	2	247	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
254	OTHER	all other   costs	1	\N	24	-1	-1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	1
255	CAR	all car related costs	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
256	GAS	all gas costs for the car	2	255	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
257	INSURANCE	all insurcance costs for the car	2	255	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
258	TAX	all tac costs for the car	2	255	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
259	TIRES	all costs for tires for the car	2	255	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
260	OTHER	other car related costs	2	255	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
261	REPAIRS	all car related repair costs	2	255	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
262	MOTOR	all motor repairs costs for the car	3	261	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
263	BREAKS	all breaks repairs costs for the car	3	261	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
264	WINDOWS	all windows repairs costs for the car	3	261	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
265	OTHER	all other repairs costs for the car	3	261	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
266	CLOTHES	all clothes related costs	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
267	SHOES	all costs for shoes	2	266	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
268	SHIRTS	all costs for shoes	2	266	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
269	TROUSERS	all costs for trousers	2	266	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
270	HOODIES	all costs for hoodies	2	266	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
271	CAPS	all costs for caps	2	266	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
272	OTHER	all other clothes related costs	2	266	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
273	EATING OUT	all costs related to eating out	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
274	PIZZA	all costs for eating out when eating pizza	2	273	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
275	BURGER	all costs for eating out when eating burger	2	273	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
276	HEALTHY	all costs for eating out when eating healthy	2	273	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
277	OTHER	all costs for eating out when eating other stuff	2	273	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
278	GROCERIES	all costs related to groceries	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
279	FOR FAM	all costs for groceries for the family	2	278	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
280	FOR ME	all costs for groceries for myself	2	278	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
281	OTHER	all other groceries related costs	2	278	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
282	PHONE	all phone related costs	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
283	CONTRACT	all phone costs for contracts	2	282	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
284	NEW PHONE	all costs for new phones	2	282	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
285	ACCESSOIRES	all costs for accessoires of the phone, like covers	2	282	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
286	OTHER	all other phone related costs	2	282	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
287	PRESENTS	all costs for presents	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
288	FOR MAM	all costs for presents for mam	2	287	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
289	FOR DAD	all costs for presents for dad	2	287	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
290	FOR GF	all costs for presents for gf	2	287	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
291	FOR FRIENDS	all costs for presents for friends	2	287	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
292	OTHER	all presents for other people	2	287	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
293	TRAVEL	all travel related costs	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
294	HOTEL	all hotel related costs	2	293	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
295	FLIGHTS	all flight related costs	2	293	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
296	EXCURSIONS	all excursions related costs	2	293	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
297	OTHER	all other related costs for travels	2	293	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
298	PUBLIC TRANSPORTATION	all public transportations related costs	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
299	TRAIN	all train related costs	2	298	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
300	BUS	all bus related costs	2	298	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
301	CABLE CAR	all cable car related costs	2	298	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
302	CAR	cost for e.g. carsharing	2	298	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
303	SUBURBAN	all suburban related costs	2	298	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
304	OTHER	all other public transportations related costs	2	298	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
305	OTHER	all other   costs	1	\N	25	-1	-1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	1
309	CAR	all car related costs	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
310	GAS	all gas costs for the car	2	309	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
311	INSURANCE	all insurcance costs for the car	2	309	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
312	TAX	all tac costs for the car	2	309	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
313	TIRES	all costs for tires for the car	2	309	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
314	OTHER	other car related costs	2	309	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
315	REPAIRS	all car related repair costs	2	309	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
316	MOTOR	all motor repairs costs for the car	3	315	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
317	BREAKS	all breaks repairs costs for the car	3	315	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
318	WINDOWS	all windows repairs costs for the car	3	315	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
319	OTHER	all other repairs costs for the car	3	315	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
320	CLOTHES	all clothes related costs	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
321	SHOES	all costs for shoes	2	320	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
322	SHIRTS	all costs for shoes	2	320	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
323	TROUSERS	all costs for trousers	2	320	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
324	HOODIES	all costs for hoodies	2	320	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
325	CAPS	all costs for caps	2	320	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
326	OTHER	all other clothes related costs	2	320	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
327	EATING OUT	all costs related to eating out	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
328	PIZZA	all costs for eating out when eating pizza	2	327	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
329	BURGER	all costs for eating out when eating burger	2	327	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
330	HEALTHY	all costs for eating out when eating healthy	2	327	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
331	OTHER	all costs for eating out when eating other stuff	2	327	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
332	GROCERIES	all costs related to groceries	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
333	FOR FAM	all costs for groceries for the family	2	332	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
334	FOR ME	all costs for groceries for myself	2	332	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
335	OTHER	all other groceries related costs	2	332	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
336	PHONE	all phone related costs	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
337	CONTRACT	all phone costs for contracts	2	336	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
338	NEW PHONE	all costs for new phones	2	336	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
339	ACCESSOIRES	all costs for accessoires of the phone, like covers	2	336	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
340	OTHER	all other phone related costs	2	336	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
341	PRESENTS	all costs for presents	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
342	FOR MAM	all costs for presents for mam	2	341	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
343	FOR DAD	all costs for presents for dad	2	341	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
344	FOR GF	all costs for presents for gf	2	341	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
345	FOR FRIENDS	all costs for presents for friends	2	341	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
346	OTHER	all presents for other people	2	341	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
347	TRAVEL	all travel related costs	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
348	HOTEL	all hotel related costs	2	347	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
349	FLIGHTS	all flight related costs	2	347	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
350	EXCURSIONS	all excursions related costs	2	347	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
351	OTHER	all other related costs for travels	2	347	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
352	PUBLIC TRANSPORTATION	all public transportations related costs	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
353	TRAIN	all train related costs	2	352	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
354	BUS	all bus related costs	2	352	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
355	CABLE CAR	all cable car related costs	2	352	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
51	PUBLIC TRANSPORTATION	all costs for public transportation	1	\N	1	-1	-1	2020-02-03	2020-04-05	UNDEFINED	UNDEFINED	0
469	TESTER 47		1	\N	1	-1	-1	2020-04-19	2020-04-19	UNDEFINED	UNDEFINED	0
356	CAR	cost for e.g. carsharing	2	352	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
357	SUBURBAN	all suburban related costs	2	352	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
358	OTHER	all other public transportations related costs	2	352	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
359	OTHER	all other   costs	1	\N	26	-1	-1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	1
362	CAR	all car related costs	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
363	GAS	all gas costs for the car	2	362	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
364	INSURANCE	all insurcance costs for the car	2	362	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
365	TAX	all tac costs for the car	2	362	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
366	TIRES	all costs for tires for the car	2	362	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
367	OTHER	other car related costs	2	362	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
368	REPAIRS	all car related repair costs	2	362	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
369	MOTOR	all motor repairs costs for the car	3	368	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
370	BREAKS	all breaks repairs costs for the car	3	368	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
371	WINDOWS	all windows repairs costs for the car	3	368	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
372	OTHER	all other repairs costs for the car	3	368	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
373	CLOTHES	all clothes related costs	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
374	SHOES	all costs for shoes	2	373	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
375	SHIRTS	all costs for shoes	2	373	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
376	TROUSERS	all costs for trousers	2	373	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
377	HOODIES	all costs for hoodies	2	373	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
378	CAPS	all costs for caps	2	373	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
379	OTHER	all other clothes related costs	2	373	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
380	EATING OUT	all costs related to eating out	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
381	PIZZA	all costs for eating out when eating pizza	2	380	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
382	BURGER	all costs for eating out when eating burger	2	380	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
383	HEALTHY	all costs for eating out when eating healthy	2	380	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
384	OTHER	all costs for eating out when eating other stuff	2	380	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
385	GROCERIES	all costs related to groceries	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
386	FOR FAM	all costs for groceries for the family	2	385	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
387	FOR ME	all costs for groceries for myself	2	385	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
388	OTHER	all other groceries related costs	2	385	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
389	PHONE	all phone related costs	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
390	CONTRACT	all phone costs for contracts	2	389	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
391	NEW PHONE	all costs for new phones	2	389	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
392	ACCESSOIRES	all costs for accessoires of the phone, like covers	2	389	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
393	OTHER	all other phone related costs	2	389	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
394	PRESENTS	all costs for presents	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
395	FOR MAM	all costs for presents for mam	2	394	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
396	FOR DAD	all costs for presents for dad	2	394	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
397	FOR GF	all costs for presents for gf	2	394	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
398	FOR FRIENDS	all costs for presents for friends	2	394	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
399	OTHER	all presents for other people	2	394	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
400	TRAVEL	all travel related costs	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
401	HOTEL	all hotel related costs	2	400	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
402	FLIGHTS	all flight related costs	2	400	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
403	EXCURSIONS	all excursions related costs	2	400	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
404	OTHER	all other related costs for travels	2	400	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
405	PUBLIC TRANSPORTATION	all public transportations related costs	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
406	TRAIN	all train related costs	2	405	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
407	BUS	all bus related costs	2	405	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
408	CABLE CAR	all cable car related costs	2	405	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
409	CAR	cost for e.g. carsharing	2	405	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
410	SUBURBAN	all suburban related costs	2	405	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
411	OTHER	all other public transportations related costs	2	405	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
412	OTHER	all other   costs	1	\N	27	-1	-1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	1
470	CAR	all car related costs	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
471	GAS	all gas costs for the car	2	470	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
472	INSURANCE	all insurcance costs for the car	2	470	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
473	TAX	all tac costs for the car	2	470	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
474	TIRES	all costs for tires for the car	2	470	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
475	OTHER	other car related costs	2	470	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
476	REPAIRS	all car related repair costs	2	470	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
477	MOTOR	all motor repairs costs for the car	3	476	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
478	BREAKS	all breaks repairs costs for the car	3	476	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
479	WINDOWS	all windows repairs costs for the car	3	476	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
480	OTHER	all other repairs costs for the car	3	476	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
481	CLOTHES	all clothes related costs	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
482	SHOES	all costs for shoes	2	481	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
483	SHIRTS	all costs for shoes	2	481	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
484	TROUSERS	all costs for trousers	2	481	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
485	HOODIES	all costs for hoodies	2	481	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
486	CAPS	all costs for caps	2	481	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
487	OTHER	all other clothes related costs	2	481	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
488	EATING OUT	all costs related to eating out	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
489	PIZZA	all costs for eating out when eating pizza	2	488	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
490	BURGER	all costs for eating out when eating burger	2	488	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
491	HEALTHY	all costs for eating out when eating healthy	2	488	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
492	OTHER	all costs for eating out when eating other stuff	2	488	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
493	GROCERIES	all costs related to groceries	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
494	FOR FAM	all costs for groceries for the family	2	493	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
495	FOR ME	all costs for groceries for myself	2	493	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
496	OTHER	all other groceries related costs	2	493	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
497	PHONE	all phone related costs	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
498	CONTRACT	all phone costs for contracts	2	497	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
446	TE		2	445	1	-1	-1	2020-04-15	2020-04-15	UNDEFINED	UNDEFINED	1
499	NEW PHONE	all costs for new phones	2	497	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
500	ACCESSOIRES	all costs for accessoires of the phone, like covers	2	497	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
501	OTHER	all other phone related costs	2	497	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
502	PRESENTS	all costs for presents	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
503	FOR MAM	all costs for presents for mam	2	502	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
504	FOR DAD	all costs for presents for dad	2	502	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
505	FOR GF	all costs for presents for gf	2	502	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
506	FOR FRIENDS	all costs for presents for friends	2	502	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
507	OTHER	all presents for other people	2	502	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
508	TRAVEL	all travel related costs	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
509	HOTEL	all hotel related costs	2	508	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
510	FLIGHTS	all flight related costs	2	508	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
511	EXCURSIONS	all excursions related costs	2	508	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
512	OTHER	all other related costs for travels	2	508	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
513	PUBLIC TRANSPORTATION	all public transportations related costs	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
514	TRAIN	all train related costs	2	513	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
515	BUS	all bus related costs	2	513	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
462	CHUC		3	461	1	-1	-1	2020-04-16	2020-04-16	UNDEFINED	UNDEFINED	1
516	CABLE CAR	all cable car related costs	2	513	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
517	CAR	cost for e.g. carsharing	2	513	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
518	SUBURBAN	all suburban related costs	2	513	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
519	OTHER	all other public transportations related costs	2	513	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
520	OTHER	all other   costs	1	\N	29	-1	-1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	1
\.


--
-- Data for Name: act_data; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.act_data (id, amount, comment, data_date, year, month, day, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk, group_fk, created, updated, created_by, updated_by, active) FROM stdin;
74	14.26	rice milk and cornflakes	2020-02-26	2020	2	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-26 00:00:00	2020-02-26 00:00:00	UNDEFINED	UNDEFINED	1
75	19	26.02	2020-02-26	2020	2	\N	BODY	49	FRISEUR	50	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-26 00:00:00	2020-02-26 00:00:00	UNDEFINED	UNDEFINED	1
76	9	kuchengabilan	2020-02-26	2020	2	\N	GROCERIES	2	FOR ME	7	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-26 00:00:00	2020-02-26 00:00:00	UNDEFINED	UNDEFINED	1
77	9	27th feb kebab and pommes	2020-02-27	2020	2	\N	EATING OUT	1	KEBAB	94	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-27 00:00:00	2020-02-27 00:00:00	UNDEFINED	UNDEFINED	1
78	14.62	for tiramisu and milk zuggolan and leckerlies	2020-02-27	2020	2	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-27 00:00:00	2020-02-27 00:00:00	UNDEFINED	UNDEFINED	1
79	57	28th feb at brenner	2020-02-28	2020	2	\N	CAR	3	GAS	6	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-28 00:00:00	2020-02-28 00:00:00	UNDEFINED	UNDEFINED	1
80	23	zahnbürsten und labello	2020-02-28	2020	2	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-28 00:00:00	2020-02-28 00:00:00	UNDEFINED	UNDEFINED	1
81	6.2	ruetz bar 2x cappu (bar)	2020-02-28	2020	2	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-28 00:00:00	2020-02-28 00:00:00	UNDEFINED	UNDEFINED	1
82	6	reismilch und infektionsmittel	2020-02-28	2020	2	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-28 00:00:00	2020-02-28 00:00:00	UNDEFINED	UNDEFINED	1
83	62.83	5kg protein + free bag	2020-03-01	2020	3	\N	INVEST	53	FITNESS	95	PROTEIN	96	INVEST	4	1	-1	2020-03-01 00:00:00	2020-03-01 00:00:00	UNDEFINED	UNDEFINED	1
84	13.19	mozarella salat schnitzel...	2020-03-07	2020	3	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-07 00:00:00	2020-03-07 00:00:00	UNDEFINED	UNDEFINED	1
85	19.49	blumen fuer frauentag	2020-03-07	2020	3	\N	PRESENTS	63	FORFAM	72	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-07 00:00:00	2020-03-07 00:00:00	UNDEFINED	UNDEFINED	1
90	5.6	brantweiner 2x caffee 2x limoral	2020-03-09	2020	3	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-09 00:00:00	2020-03-09 00:00:00	UNDEFINED	UNDEFINED	1
32	29.33		2020-01-17	2020	1	\N	TRAVEL	73	HOTEL	74	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
66	5.4		2020-02-21	2020	2	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-21 00:00:00	2020-02-21 00:00:00	UNDEFINED	UNDEFINED	1
67	50		2020-02-22	2020	2	\N	CLOTHES	81	SHOES	82	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-22 00:00:00	2020-02-22 00:00:00	UNDEFINED	UNDEFINED	1
68	11		2020-02-22	2020	2	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-22 00:00:00	2020-02-22 00:00:00	UNDEFINED	UNDEFINED	1
120	100	corona krisis invests	2020-03-21	2020	3	\N	INVEST	53	CRYPTO	54	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-03-21 13:43:50.29193	2020-03-21 13:43:50.29193	UNDEFINED	UNDEFINED	1
108	50	aufladen	2020-03-17	2020	3	\N	PHONE	85	CONTRACT	86	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-17 19:06:39.359418	2020-03-17 19:06:39.359418	UNDEFINED	UNDEFINED	1
110	9.99	handyfolie	2020-02-18	2020	2	\N	PHONE	85	PROTECTION	97	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-18 23:14:18.724655	2020-03-18 23:14:18.724655	UNDEFINED	UNDEFINED	1
111	30.76	entkalker	2020-02-18	2020	2	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-18 23:14:49.770357	2020-03-18 23:14:49.770357	UNDEFINED	UNDEFINED	1
112	54	tablet edith	2020-03-19	2020	3	\N	PRESENTS	63	FORFAM	72	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-19 22:36:27.368153	2020-03-19 22:36:27.368153	UNDEFINED	UNDEFINED	1
1	1.5		2020-01-23	2020	1	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-01-23 00:00:00	2020-01-23 00:00:00	UNDEFINED	UNDEFINED	1
3	19		2020-01-25	2020	1	\N	BODY	49	FRISEUR	50	UNDEFINED	-101	FIX	1	1	-1	2020-01-25 00:00:00	2020-01-25 00:00:00	UNDEFINED	UNDEFINED	1
4	1.38		2020-01-25	2020	1	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-01-25 00:00:00	2020-01-25 00:00:00	UNDEFINED	UNDEFINED	1
5	40		2020-01-26	2020	1	\N	CAR	3	GAS	6	UNDEFINED	-101	VARIABLE	2	1	-1	2020-01-26 00:00:00	2020-01-26 00:00:00	UNDEFINED	UNDEFINED	1
6	30		2020-02-03	2020	2	\N	PUBLIC TRANSPORTATION	51	SUBURBAN	52	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-03 00:00:00	2020-02-03 00:00:00	UNDEFINED	UNDEFINED	1
7	35		2020-02-03	2020	2	\N	EATING OUT	1	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-03 00:00:00	2020-02-03 00:00:00	UNDEFINED	UNDEFINED	1
8	7		2020-02-04	2020	2	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-04 00:00:00	2020-02-04 00:00:00	UNDEFINED	UNDEFINED	1
16	30		2020-02-08	2020	2	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-08 00:00:00	2020-02-08 00:00:00	UNDEFINED	UNDEFINED	1
41	12.41		2020-01-17	2020	1	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
17	70		2020-02-11	2020	2	\N	CAR	3	GAS	6	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-11 00:00:00	2020-02-11 00:00:00	UNDEFINED	UNDEFINED	1
19	100		2020-02-12	2020	2	\N	PRESENTS	63	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-12 00:00:00	2020-02-12 00:00:00	UNDEFINED	UNDEFINED	1
22	6		2020-02-15	2020	2	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-15 00:00:00	2020-02-15 00:00:00	UNDEFINED	UNDEFINED	1
24	4.70		2020-02-16	2020	2	\N	COFFEE	46	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-16 00:00:00	2020-02-16 00:00:00	UNDEFINED	UNDEFINED	1
26	20		2020-02-16	2020	2	\N	FUN	64	CINEMA	65	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-16 00:00:00	2020-02-16 00:00:00	UNDEFINED	UNDEFINED	1
29	175		2020-02-04	2020	2	\N	CAR	3	REPAIRS	4	RADIO	66	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
11	10		2020-02-04	2020	2	\N	INVEST	53	CRYPTO	54	UNDEFINED	-101	INVEST	4	1	-1	2020-02-04 00:00:00	2020-02-04 00:00:00	UNDEFINED	UNDEFINED	1
42	192.28		2020-01-17	2020	1	\N	CAR	3	TAX	80	UNDEFINED	-101	FIX	1	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
43	70		2020-01-17	2020	1	\N	CLOTHES	81	SHOES	82	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
44	50		2020-01-17	2020	1	\N	CLOTHES	81	SHIRTS	83	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
45	6.20		2020-01-17	2020	1	\N	EATING OUT	1	BREAKFAST	78	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
46	11.47		2020-01-17	2020	1	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
31	15.99		2020-01-17	2020	1	\N	PRESENTS	63	GF	76	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
33	45.63		2020-01-17	2020	1	\N	TRAVEL	73	TRANSPORTATION COSTS	75	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
34	26		2020-02-17	2020	2	\N	EATING OUT	1	PIZZA	48	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
35	24		2020-02-17	2020	2	\N	EATING OUT	1	PIZZA	48	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
36	25.30		2020-02-17	2020	2	\N	EATING OUT	1	BURGER	77	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
37	21		2020-02-17	2020	2	\N	EATING OUT	1	BREAKFAST	78	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
38	20.30		2020-02-17	2020	2	\N	EATING OUT	1	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
39	401.70		2020-02-17	2020	2	\N	CAR	3	INSURANCE	79	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
40	29.30		2020-01-17	2020	1	\N	EATING OUT	1	PIZZA	48	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
47	10		2020-01-17	2020	1	\N	CAR	3	GAS	6	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
48	5		2020-01-17	2020	1	\N	PHONE	85	CONTRACT	86	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
49	19.28		2020-01-17	2020	1	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
50	33.65		2020-01-17	2020	1	\N	EATING OUT	1	PIZZA	48	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
51	102		2019-12-17	2019	12	\N	INVEST	53	PRODUCTIVITY	87	TECHNOLOGY	88	INVEST	4	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
53	119.99		2019-12-17	2019	12	\N	PRESENTS	63	GF	76	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
54	30		2019-12-17	2019	12	\N	PRESENTS	63	FORFAM	72	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
55	15.18		2019-12-17	2019	12	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
56	60		2019-12-17	2019	12	\N	CAR	3	GAS	6	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
57	28.30		2019-12-17	2019	12	\N	EATING OUT	1	CHINESE	47	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
58	14.92		2019-12-17	2019	12	\N	GROCERIES	2	FOR FAM	8	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
59	35.45		2019-12-17	2019	12	\N	CAR	3	GAS	6	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
60	35.40		2019-12-17	2019	12	\N	EATING OUT	1	PIMS	42	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
61	33.60		2019-12-17	2019	12	\N	EATING OUT	1	PIZZA	48	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
62	22.40		2019-12-17	2019	12	\N	EATING OUT	1	PIZZA	48	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
63	30.01		2019-12-17	2019	12	\N	CAR	3	GAS	6	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
64	30.00		2019-12-17	2019	12	\N	CAR	3	TICKETS	89	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-17 00:00:00	2020-02-17 00:00:00	UNDEFINED	UNDEFINED	1
139	11.99	hülle tablet edith	2020-04-06	2020	4	\N	PRESENTS	63	FORFAM	72	UNDEFINED	-101	VARIABLE	2	1	-1	2020-04-06 20:52:23.522316	2020-04-06 20:52:23.522316	UNDEFINED	UNDEFINED	1
140	20.30	hülle handy weiß	2019-11-06	2019	11	\N	PHONE	85	PROTECTION	97	UNDEFINED	-101	VARIABLE	2	1	-1	2020-04-06 20:55:27.985016	2020-04-06 20:55:27.985016	UNDEFINED	UNDEFINED	1
141	19.70	hülle handy schwarz	2019-07-06	2019	7	\N	PHONE	85	PROTECTION	97	UNDEFINED	-101	VARIABLE	2	1	-1	2020-04-06 20:56:14.655214	2020-04-06 20:56:14.655214	UNDEFINED	UNDEFINED	1
132	15	aufladen 	2020-04-05	2020	4	\N	PHONE	85	CONTRACT	86	UNDEFINED	-101	VARIABLE	2	1	-1	2020-04-05 13:57:26.475409	2020-04-05 13:57:26.475409	UNDEFINED	UNDEFINED	1
138	11.13	hülle navy blau	2020-04-06	2020	4	\N	PHONE	85	PROTECTION	97	UNDEFINED	-101	VARIABLE	2	1	-1	2020-04-06 20:50:31.450989	2020-04-06 20:50:31.450989	UNDEFINED	UNDEFINED	1
157	1	rio branco	2020-04-06	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-06 17:16:28	2020-04-06 22:10:35.974102	UNDEFINED	UNDEFINED	0
156	1		2020-04-06	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-06 17:16:18	2020-04-06 22:10:47.266857	UNDEFINED	UNDEFINED	0
327	5	 - SCHEDULED	2022-04-20	2022	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-20 19:06:52.202011	2020-04-20 22:25:56.336667	UNDEFINED	UNDEFINED	0
324	5		2020-04-20	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-20 18:59:47.57587	2020-04-20 22:26:16.331631	UNDEFINED	UNDEFINED	0
330	5		2020-04-21	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	-1	-1	2020-04-21 16:10:57.981538	2020-04-21 16:10:59.189482	UNDEFINED	UNDEFINED	1
328	6		2020-04-20	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	28	-1	2020-04-20 20:41:01.93069	2020-04-20 20:41:02.19238	UNDEFINED	UNDEFINED	1
325	5		2020-04-20	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-20 19:06:47.814935	2020-04-20 22:26:21.198506	UNDEFINED	UNDEFINED	0
331	100		2020-04-23	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	29	-1	2020-04-23 19:50:41.727394	2020-04-23 19:50:42.593589	UNDEFINED	UNDEFINED	1
18	1.50		2020-02-12	2020	2	\N	EATING OUT	1	PIMS	42	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-12 00:00:00	2020-04-14 22:06:32.129444	UNDEFINED	UNDEFINED	0
326	5	 - SCHEDULED	2021-04-20	2021	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-20 19:06:52.202011	2020-04-20 22:26:09.580555	UNDEFINED	UNDEFINED	0
329	5		2020-04-21	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	-1	-1	2020-04-21 16:09:53.924025	2020-04-21 16:09:55.11995	UNDEFINED	UNDEFINED	1
332	6		2020-04-25	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-25 19:50:20.616839	2020-04-25 19:58:34.044608	UNDEFINED	UNDEFINED	0
\.


--
-- Data for Name: bdg_data; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.bdg_data (id, amount, comment, data_date, year, month, day, level1, level1_fk, level2, level2_fk, level3, level3_fk, costtype, costtype_fk, user_fk, group_fk, created, updated, created_by, updated_by, active) FROM stdin;
75	1000		2020-04-23	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	29	-1	2020-04-23 19:50:47.471362+00	2020-04-23 19:50:48.348707+00	UNDEFINED	UNDEFINED	1
14	2200	march luan, to adjust	2020-03-01	2020	3	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-29 23:00:00+00	2020-02-29 23:00:00+00	UNDEFINED	UNDEFINED	0
76	50		2020-04-26	2020	4	\N	PRESENTS	63	UNDEFINED	-100	UNDEFINED	-101	UNDEFINED	-99	1	-1	2020-04-26 18:21:13.631984+00	2020-04-26 18:21:16.002054+00	UNDEFINED	UNDEFINED	1
15	1881.18	real february luan	2020-03-10	2020	3	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	FIX	1	1	-1	2020-03-09 23:00:00+00	2020-03-09 23:00:00+00	UNDEFINED	UNDEFINED	1
18	3212.95	decembo 2019 luan	2019-12-28	2019	12	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-03-28 22:37:50.95716+00	2020-03-28 22:37:50.95716+00	UNDEFINED	UNDEFINED	1
32	1914.42	real march luan	2020-04-10	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-04-10 06:39:06.760434+00	2020-04-10 06:39:07.795783+00	UNDEFINED	UNDEFINED	1
31	1500	march corona luan	2020-04-09	2020	4	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-04-09 20:49:42.137379+00	2020-04-10 06:39:13.12696+00	UNDEFINED	UNDEFINED	0
12	3212	january luan	2020-01-29	2020	1	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-28 23:00:00+00	2020-04-15 20:03:24.758071+00	UNDEFINED	UNDEFINED	1
13	1550	february luan	2020-02-29	2020	2	\N	UNDEFINED	-99	UNDEFINED	-100	UNDEFINED	-101	VARIABLE	2	1	-1	2020-02-28 23:00:00+00	2020-04-15 20:03:32.719275+00	UNDEFINED	UNDEFINED	1
\.


--
-- Data for Name: company_dim; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.company_dim (id, name, created, updated, created_by, updated_by) FROM stdin;
-1	UNDEFINED	2020-01-03	2020-01-03	UNDEFINED	UNDEFINED
\.


--
-- Data for Name: costtype_dim; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.costtype_dim (id, name, comment, user_fk, group_fk, company_fk, active, created, updated, created_by, updated_by) FROM stdin;
60	7F7		1	-1	-1	0	2020-04-16	2020-04-16	UNDEFINED	UNDEFINED
61	UFFU		1	-1	-1	0	2020-04-16	2020-04-16	UNDEFINED	UNDEFINED
62	 HC		1	-1	-1	0	2020-04-16	2020-04-16	UNDEFINED	UNDEFINED
24	NANI	nani	1	-1	-1	0	2020-02-22	2020-02-22	UNDEFINED	UNDEFINED
46	VARIABLE	variable costs like eating out once a week	24	-1	-1	1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED
47	FIX	fix costs like rent	24	-1	-1	1	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED
48	VARIABLE	variable costs like eating out once a week	25	-1	-1	1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED
49	FIX	fix costs like rent	25	-1	-1	1	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED
11	INVEST MYSELF	investment in myself like books instead of in real estate	1	-1	-1	0	2020-01-14	2020-01-14	UNDEFINED	UNDEFINED
63	BOBOBOBO		1	-1	-1	0	2020-04-19	2020-04-19	UNDEFINED	UNDEFINED
4	INVEST	costtype for all stuff related to investements, like real estate	1	-1	-1	1	2020-01-14	2020-01-14	UNDEFINED	UNDEFINED
51	VARIABLE	variable costs like eating out once a week	26	-1	-1	1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED
2	VARIABLE	costtype for all variable costs, like gas	1	-1	-1	1	2020-01-14	2020-01-14	UNDEFINED	UNDEFINED
52	FIX	fix costs like rent	26	-1	-1	1	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED
1	FIX	costtype for all fix costs, like rent	1	-1	-1	1	2020-01-14	2020-04-05	UNDEFINED	UNDEFINED
53	TESTUTC2		1	-1	-1	0	2020-04-06	2020-04-06	UNDEFINED	UNDEFINED
54	VARIABLE	variable costs like eating out once a week	27	-1	-1	1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED
55	FIX	fix costs like rent	27	-1	-1	1	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED
56	BOOOOO		1	-1	-1	0	2020-04-13	2020-04-13	UNDEFINED	UNDEFINED
-99	UNDEFINED	default costtype	-1	-1	-1	1	2020-01-14	2020-01-14	UNDEFINED	UNDEFINED
64	TEST 42		1	-1	-1	0	2020-04-20	2020-04-20	UNDEFINED	UNDEFINED
3	FUN	costtype for all stuff related to fun stuff, like skiing	1	-1	-1	0	2020-01-14	2020-01-14	UNDEFINED	UNDEFINED
65	VARIABLE	variable costs like eating out once a week	29	-1	-1	1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED
66	FIX	fix costs like rent	29	-1	-1	1	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED
57	BOOOO		1	-1	-1	0	2020-04-16	2020-04-16	UNDEFINED	UNDEFINED
58	GI		1	-1	-1	0	2020-04-16	2020-04-16	UNDEFINED	UNDEFINED
59	UFF		1	-1	-1	0	2020-04-16	2020-04-16	UNDEFINED	UNDEFINED
\.


--
-- Data for Name: group_dim; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.group_dim (id, name, created, updated, created_by, updated_by) FROM stdin;
-1	UNDEFINED	2020-01-03	2020-01-03	UNDEFINED	UNDEFINED
\.


--
-- Data for Name: preference_dim; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.preference_dim (user_fk, group_fk, company_fk, costtypes_active, accounts_active, accountslevel1_active, accountslevel2_active, accountslevel3_active, created, updated, created_by, updated_by) FROM stdin;
29	-1	-1	t	t	t	t	t	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED
-1	-1	-1	t	t	t	t	t	2020-03-18	2020-03-18	UNDEFINED	UNDEFINED
1	-1	-1	t	t	t	t	t	2020-02-23	2020-04-21	UNDEFINED	UNDEFINED
27	-1	-1	t	t	t	t	t	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED
26	-1	-1	t	t	t	t	t	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED
25	-1	-1	t	t	t	t	t	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED
28	-1	-1	t	t	t	t	t	2020-04-20	2020-04-20	UNDEFINED	UNDEFINED
24	-1	-1	t	t	t	t	t	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED
\.


--
-- Data for Name: user_dim; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.user_dim (id, name, created, updated, created_by, updated_by, mail) FROM stdin;
-1	UNDEFINED	2020-01-03	2020-01-03	UNDEFINED	UNDEFINED	\N
1	jakob.engl	2020-01-03	2020-01-03	UNDEFINED	UNDEFINED	jakob.engl.je@gmail.com
24	PM WORKERBASE2	2020-03-27	2020-03-27	UNDEFINED	UNDEFINED	pm.workerbase2@gmail.com
25	JOSEF ENGL	2020-03-29	2020-03-29	UNDEFINED	UNDEFINED	josefengl.je@gmail.com
26	JAKOB ENGL	2020-04-04	2020-04-04	UNDEFINED	UNDEFINED	jakob.engl.gknpm@gmail.com
27	EDITH ENGL	2020-04-11	2020-04-11	UNDEFINED	UNDEFINED	edith.engl67@gmail.com
28	jakob.engl	2020-04-20	2020-04-20	UNDEFINED	UNDEFINED	jakob.engl@hotmail.de
29	jakob.engl	2020-04-21	2020-04-21	UNDEFINED	UNDEFINED	jakob.engl@gknpm.com
\.


--
-- Data for Name: user_in_company; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.user_in_company (user_fk, company_fk, created, updated, created_by, updated_by) FROM stdin;
\.


--
-- Data for Name: user_in_group; Type: TABLE DATA; Schema: ffd; Owner: postgres
--

COPY ffd.user_in_group (user_fk, group_fk, created, updated, created_by, updated_by) FROM stdin;
\.


--
-- Name: account_dim_id_seq; Type: SEQUENCE SET; Schema: ffd; Owner: postgres
--

SELECT pg_catalog.setval('ffd.account_dim_id_seq', 520, true);


--
-- Name: act_data_id_seq; Type: SEQUENCE SET; Schema: ffd; Owner: postgres
--

SELECT pg_catalog.setval('ffd.act_data_id_seq', 332, true);


--
-- Name: bdg_data_id_seq; Type: SEQUENCE SET; Schema: ffd; Owner: postgres
--

SELECT pg_catalog.setval('ffd.bdg_data_id_seq', 76, true);


--
-- Name: company_dim_id_seq; Type: SEQUENCE SET; Schema: ffd; Owner: postgres
--

SELECT pg_catalog.setval('ffd.company_dim_id_seq', 1, false);


--
-- Name: costtype_dim_id_seq; Type: SEQUENCE SET; Schema: ffd; Owner: postgres
--

SELECT pg_catalog.setval('ffd.costtype_dim_id_seq', 66, true);


--
-- Name: group_dim_id_seq; Type: SEQUENCE SET; Schema: ffd; Owner: postgres
--

SELECT pg_catalog.setval('ffd.group_dim_id_seq', 1, false);


--
-- Name: user_dim_id_seq; Type: SEQUENCE SET; Schema: ffd; Owner: postgres
--

SELECT pg_catalog.setval('ffd.user_dim_id_seq', 29, true);


--
-- Name: account_dim account_dim_pkey; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.account_dim
    ADD CONSTRAINT account_dim_pkey PRIMARY KEY (id);


--
-- Name: account_dim account_user_level_parent_uq; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.account_dim
    ADD CONSTRAINT account_user_level_parent_uq UNIQUE (name, level_type, user_fk, parent_account);


--
-- Name: act_data act_data_pkey; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data
    ADD CONSTRAINT act_data_pkey PRIMARY KEY (id);


--
-- Name: bdg_data bdg_data_pkey; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data
    ADD CONSTRAINT bdg_data_pkey PRIMARY KEY (id);


--
-- Name: company_dim company_dim_pkey; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.company_dim
    ADD CONSTRAINT company_dim_pkey PRIMARY KEY (id);


--
-- Name: costtype_dim costtype_dim_pkey; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.costtype_dim
    ADD CONSTRAINT costtype_dim_pkey PRIMARY KEY (id);


--
-- Name: costtype_dim costtype_user_uq; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.costtype_dim
    ADD CONSTRAINT costtype_user_uq UNIQUE (name, user_fk);


--
-- Name: group_dim group_dim_pkey; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.group_dim
    ADD CONSTRAINT group_dim_pkey PRIMARY KEY (id);


--
-- Name: preference_dim preference_dim_user_fk_key; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.preference_dim
    ADD CONSTRAINT preference_dim_user_fk_key UNIQUE (user_fk);


--
-- Name: user_dim user_dim_mail_key; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.user_dim
    ADD CONSTRAINT user_dim_mail_key UNIQUE (mail);


--
-- Name: user_dim user_dim_pkey; Type: CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.user_dim
    ADD CONSTRAINT user_dim_pkey PRIMARY KEY (id);


--
-- Name: account_dim account_dim_company_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.account_dim
    ADD CONSTRAINT account_dim_company_fk_fkey FOREIGN KEY (company_fk) REFERENCES ffd.company_dim(id);


--
-- Name: account_dim account_dim_group_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.account_dim
    ADD CONSTRAINT account_dim_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id);


--
-- Name: account_dim account_dim_user_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.account_dim
    ADD CONSTRAINT account_dim_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id);


--
-- Name: act_data act_data_costtype_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data
    ADD CONSTRAINT act_data_costtype_fk_fkey FOREIGN KEY (costtype_fk) REFERENCES ffd.costtype_dim(id);


--
-- Name: act_data act_data_group_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data
    ADD CONSTRAINT act_data_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id);


--
-- Name: act_data act_data_level1_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data
    ADD CONSTRAINT act_data_level1_fk_fkey FOREIGN KEY (level1_fk) REFERENCES ffd.account_dim(id);


--
-- Name: act_data act_data_level2_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data
    ADD CONSTRAINT act_data_level2_fk_fkey FOREIGN KEY (level2_fk) REFERENCES ffd.account_dim(id);


--
-- Name: act_data act_data_level3_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data
    ADD CONSTRAINT act_data_level3_fk_fkey FOREIGN KEY (level3_fk) REFERENCES ffd.account_dim(id);


--
-- Name: act_data act_data_user_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.act_data
    ADD CONSTRAINT act_data_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id);


--
-- Name: bdg_data bdg_data_costtype_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data
    ADD CONSTRAINT bdg_data_costtype_fk_fkey FOREIGN KEY (costtype_fk) REFERENCES ffd.costtype_dim(id);


--
-- Name: bdg_data bdg_data_group_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data
    ADD CONSTRAINT bdg_data_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id);


--
-- Name: bdg_data bdg_data_level1_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data
    ADD CONSTRAINT bdg_data_level1_fk_fkey FOREIGN KEY (level1_fk) REFERENCES ffd.account_dim(id);


--
-- Name: bdg_data bdg_data_level2_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data
    ADD CONSTRAINT bdg_data_level2_fk_fkey FOREIGN KEY (level2_fk) REFERENCES ffd.account_dim(id);


--
-- Name: bdg_data bdg_data_level3_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data
    ADD CONSTRAINT bdg_data_level3_fk_fkey FOREIGN KEY (level3_fk) REFERENCES ffd.account_dim(id);


--
-- Name: bdg_data bdg_data_user_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.bdg_data
    ADD CONSTRAINT bdg_data_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id);


--
-- Name: costtype_dim costtype_dim_company_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.costtype_dim
    ADD CONSTRAINT costtype_dim_company_fk_fkey FOREIGN KEY (company_fk) REFERENCES ffd.company_dim(id);


--
-- Name: costtype_dim costtype_dim_group_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.costtype_dim
    ADD CONSTRAINT costtype_dim_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id);


--
-- Name: costtype_dim costtype_dim_user_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.costtype_dim
    ADD CONSTRAINT costtype_dim_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id);


--
-- Name: preference_dim preference_dim_company_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.preference_dim
    ADD CONSTRAINT preference_dim_company_fk_fkey FOREIGN KEY (company_fk) REFERENCES ffd.company_dim(id);


--
-- Name: preference_dim preference_dim_group_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.preference_dim
    ADD CONSTRAINT preference_dim_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id);


--
-- Name: preference_dim preference_dim_user_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.preference_dim
    ADD CONSTRAINT preference_dim_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id);


--
-- Name: user_in_company user_in_company_company_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.user_in_company
    ADD CONSTRAINT user_in_company_company_fk_fkey FOREIGN KEY (company_fk) REFERENCES ffd.company_dim(id);


--
-- Name: user_in_company user_in_company_user_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.user_in_company
    ADD CONSTRAINT user_in_company_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id);


--
-- Name: user_in_group user_in_group_group_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.user_in_group
    ADD CONSTRAINT user_in_group_group_fk_fkey FOREIGN KEY (group_fk) REFERENCES ffd.group_dim(id);


--
-- Name: user_in_group user_in_group_user_fk_fkey; Type: FK CONSTRAINT; Schema: ffd; Owner: postgres
--

ALTER TABLE ONLY ffd.user_in_group
    ADD CONSTRAINT user_in_group_user_fk_fkey FOREIGN KEY (user_fk) REFERENCES ffd.user_dim(id);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

