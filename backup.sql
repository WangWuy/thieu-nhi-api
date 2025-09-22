--
-- PostgreSQL database dump
--

\restrict KVr9oJKxPlh87P38OPaEUbkQ5Gq8fWP808edZfhJu7bDAxMSTBPUqpjAigBkfkw

-- Dumped from database version 16.10 (Debian 16.10-1.pgdg13+1)
-- Dumped by pg_dump version 16.10 (Homebrew)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: AttendanceType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."AttendanceType" AS ENUM (
    'thursday',
    'sunday'
);


ALTER TYPE public."AttendanceType" OWNER TO postgres;

--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."UserRole" AS ENUM (
    'ban_dieu_hanh',
    'phan_doan_truong',
    'giao_ly_vien'
);


ALTER TYPE public."UserRole" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: academic_years; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.academic_years (
    id integer NOT NULL,
    name text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    total_weeks integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_current boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.academic_years OWNER TO postgres;

--
-- Name: academic_years_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.academic_years_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.academic_years_id_seq OWNER TO postgres;

--
-- Name: academic_years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.academic_years_id_seq OWNED BY public.academic_years.id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    id integer NOT NULL,
    student_id integer NOT NULL,
    attendance_date date NOT NULL,
    attendance_type public."AttendanceType" NOT NULL,
    is_present boolean NOT NULL,
    note text,
    marked_by integer,
    marked_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_id_seq OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance.id;


--
-- Name: class_teachers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_teachers (
    id integer NOT NULL,
    class_id integer NOT NULL,
    user_id integer NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.class_teachers OWNER TO postgres;

--
-- Name: class_teachers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_teachers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_teachers_id_seq OWNER TO postgres;

--
-- Name: class_teachers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_teachers_id_seq OWNED BY public.class_teachers.id;


--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    name text NOT NULL,
    department_id integer NOT NULL,
    teacher_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: classes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classes_id_seq OWNER TO postgres;

--
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id integer NOT NULL,
    student_code text NOT NULL,
    qr_code text,
    saint_name text,
    full_name text NOT NULL,
    birth_date timestamp(3) without time zone,
    phone_number text,
    parent_phone_1 text,
    parent_phone_2 text,
    address text,
    class_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    academic_year_id integer,
    attendance_average numeric(4,2) DEFAULT 0 NOT NULL,
    exam_hk1 numeric(3,1) DEFAULT 0 NOT NULL,
    exam_hk2 numeric(3,1) DEFAULT 0 NOT NULL,
    final_average numeric(4,2) DEFAULT 0 NOT NULL,
    study_45_hk1 numeric(3,1) DEFAULT 0 NOT NULL,
    study_45_hk2 numeric(3,1) DEFAULT 0 NOT NULL,
    study_average numeric(4,2) DEFAULT 0 NOT NULL,
    sunday_attendance_count integer DEFAULT 0 NOT NULL,
    thursday_attendance_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.students_id_seq OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    role public."UserRole" NOT NULL,
    saint_name text,
    full_name text NOT NULL,
    birth_date timestamp(3) without time zone,
    phone_number text,
    address text,
    department_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: weekly_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weekly_stats (
    id integer NOT NULL,
    week_start_date date NOT NULL,
    week_end_date date NOT NULL,
    department_id integer,
    class_id integer,
    total_students integer NOT NULL,
    thursday_attendance integer NOT NULL,
    sunday_attendance integer NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.weekly_stats OWNER TO postgres;

--
-- Name: weekly_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.weekly_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weekly_stats_id_seq OWNER TO postgres;

--
-- Name: weekly_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weekly_stats_id_seq OWNED BY public.weekly_stats.id;


--
-- Name: academic_years id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_years ALTER COLUMN id SET DEFAULT nextval('public.academic_years_id_seq'::regclass);


--
-- Name: attendance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: class_teachers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_teachers ALTER COLUMN id SET DEFAULT nextval('public.class_teachers_id_seq'::regclass);


--
-- Name: classes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weekly_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_stats ALTER COLUMN id SET DEFAULT nextval('public.weekly_stats_id_seq'::regclass);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
6f1c1e0b-199e-4ffc-8b72-3a0618328543	ae71cf1f0243ceb5aeb32af4efe9e2c83f16ae89afe69fc5983ae56275276863	2025-09-10 16:14:14.619755+00	20250727031916_init	\N	\N	2025-09-10 16:14:14.179688+00	1
b25a3f02-bc67-4177-8b3b-7f9619d2cc8d	2b88fa9896344b97c2bc41c712acc4f5a14b6a391f7d818100345212cf71839b	2025-09-10 16:14:15.076368+00	20250730025503_auto_migration	\N	\N	2025-09-10 16:14:14.740232+00	1
\.


--
-- Data for Name: academic_years; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.academic_years (id, name, start_date, end_date, total_weeks, is_active, is_current, created_at, updated_at) FROM stdin;
1	2025-2026	2025-09-14	2026-05-31	37	t	t	2025-09-10 16:23:18.992	2025-09-10 16:23:29.089
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, student_id, attendance_date, attendance_type, is_present, note, marked_by, marked_at) FROM stdin;
1351	111	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.82
1352	136	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.83
1353	371	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.839
1354	769	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.847
1581	1265	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.907
1582	1288	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.915
1583	1256	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.924
1584	1255	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.933
1585	1332	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.941
1586	1333	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.95
1587	1324	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.958
1588	1325	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.966
1589	394	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.973
1590	306	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.983
1593	378	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.019
1594	333	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.027
1595	384	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.036
1596	375	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.044
1597	393	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.052
1598	396	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.061
1599	330	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.07
1600	335	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.078
1096	89	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.085
189	90	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.094
1603	86	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.103
1604	276	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.112
1605	475	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.121
1607	552	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.137
1608	544	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.145
1609	444	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.152
1610	445	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.16
1611	611	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.168
1613	618	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.187
1615	566	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.206
1616	559	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.215
1617	609	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.224
1618	656	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.233
1619	659	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.241
1620	686	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.254
334	755	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.262
1622	798	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.272
1623	822	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.281
1624	857	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.289
1040	876	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.298
1626	932	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.307
1627	934	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.317
1628	852	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.326
1629	985	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.335
1630	1168	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.343
1632	1189	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.359
1633	1038	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.369
1635	1116	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.391
1636	1130	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.405
1637	1137	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.413
1638	1246	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.421
1639	1247	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.429
1640	1301	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.438
1641	1306	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.446
1642	1335	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.453
1643	1330	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.465
1644	346	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.472
1645	400	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.479
1359	768	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.858
1360	898	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.87
1361	1070	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.878
1362	1044	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.887
1363	1041	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.894
1364	1057	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.902
1365	1235	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.912
1366	1282	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.919
1367	5	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.926
1368	4	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.938
1369	1192	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.946
1370	1086	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.953
1371	11	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.974
1372	10	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:20.992
1373	6	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21
1374	47	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.009
1375	7	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.033
1376	138	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.043
1102	234	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.068
1378	388	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.09
1379	456	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.099
1380	581	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.118
1381	638	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.131
1382	846	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.141
1383	946	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.15
1384	966	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.158
1385	1152	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.166
1386	1105	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.175
1387	209	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.185
1389	212	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.199
1390	216	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.207
1391	440	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.214
1392	507	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.221
1393	457	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.228
1394	791	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.236
1112	734	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.242
1396	696	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.251
1397	793	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.26
1398	899	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.267
1400	965	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.284
1401	996	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.293
1402	1064	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.301
1404	1028	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.316
1405	1053	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.324
1406	1229	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.332
1407	1106	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.341
1408	1200	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.349
1409	1238	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.357
1410	1321	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.368
1411	54	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.376
1412	1	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.383
1413	142	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.391
1414	253	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.398
1415	361	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.407
1416	413	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.415
1417	323	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.425
1418	640	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.433
1419	834	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.441
1420	901	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.448
1421	915	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.461
1422	1092	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.469
1423	1046	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.476
1425	63	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.494
1426	60	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.504
1427	12	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.512
1774	713	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:05:53.051
1428	15	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.519
1429	64	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.527
1430	144	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.535
1432	191	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.553
1433	223	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.561
1434	243	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.569
1435	510	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.578
201	1195	2025-09-14	sunday	t	QR Scan - Maria Vu Thu Trang	20	2025-09-14 00:59:01.108
1109	529	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.586
1438	602	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.603
1439	643	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.612
1440	743	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.62
192	469	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.109
209	122	2025-09-14	sunday	t	QR Scan - Maria Nguyen Ngac Heng An	20	2025-09-14 00:59:31.77
193	540	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.142
190	477	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.128
212	250	2025-09-14	sunday	t	Manual Present Entry - Trần Thùy Linh Đan	20	2025-09-14 01:00:18.496
188	666	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.389
215	418	2025-09-14	sunday	t	QR Scan - Gioakim Tran Tuan Hung	73	2025-09-14 01:01:41.337
216	1208	2025-09-14	sunday	t	QR Scan - Phero Hoang Anh Tri	73	2025-09-14 01:01:47.382
217	506	2025-09-14	sunday	t	QR Scan - Phero Dang Lam Gia Khiem	73	2025-09-14 01:01:52.618
218	96	2025-09-14	sunday	t	QR Scan - Giuse Tren Khac Tinh Anh	73	2025-09-14 01:01:57.898
219	169	2025-09-14	sunday	t	QR Scan - Vinh Son Trenh Thien Bao	73	2025-09-14 01:02:04.2
220	597	2025-09-14	sunday	t	QR Scan - Giuse Bui Gia Long	73	2025-09-14 01:02:19.371
221	1049	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Le Duc Tuan	73	2025-09-14 01:02:23.244
222	1055	2025-09-14	sunday	t	QR Scan - Matheu Tran Thanh Tung	73	2025-09-14 01:02:26.357
223	350	2025-09-14	sunday	t	QR Scan - Maria Tran Hoang Gia Han	73	2025-09-14 01:02:35.412
224	845	2025-09-14	sunday	t	QR Scan - Teresa Nguyen Tuyet Nhung	73	2025-09-14 01:02:44.227
225	109	2025-09-14	sunday	t	QR Scan - Maria Ngo Ngoc Anh	73	2025-09-14 01:02:46.131
226	178	2025-09-14	sunday	t	QR Scan - Maria Vu Thu Binh	73	2025-09-14 01:03:03.981
227	293	2025-09-14	sunday	t	QR Scan - Giuse Vu Hoang Gia	73	2025-09-14 01:03:09.524
228	800	2025-09-14	sunday	t	QR Scan - Gioan Baotixita Le Quang Nhat	73	2025-09-14 01:03:15.235
229	681	2025-09-14	sunday	t	QR Scan - Maria Nguyen Ngoc Tra My	73	2025-09-14 01:03:32.762
230	776	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Đức Khôi Nguyên	20	2025-09-14 01:07:13.9
231	910	2025-09-14	sunday	t	Universal QR Scan	16	2025-09-14 02:24:37.764
232	1007	2025-09-14	sunday	t	QR Scan - Teresa Linh Ngac An Sa	29	2025-09-14 02:27:48.448
234	383	2025-09-14	sunday	t	QR Scan - Maria E Ngac Heng	29	2025-09-14 02:27:50.834
235	853	2025-09-14	sunday	t	QR Scan - Teresa Tran My Nhu	29	2025-09-14 02:27:59.363
236	242	2025-09-14	sunday	t	QR Scan - Teresa Do Hai Dan	29	2025-09-14 02:28:02.586
237	819	2025-09-14	sunday	t	QR Scan - Teresa Nguyen Truc Nhi	29	2025-09-14 02:28:05.01
238	322	2025-09-14	sunday	t	QR Scan - Anne Ho Ngoc Han	29	2025-09-14 02:28:06.172
240	1161	2025-09-14	sunday	t	QR Scan - Maria Nguyen Ngoc Anh Thu	29	2025-09-14 02:28:10.007
241	460	2025-09-14	sunday	t	Manual Present Entry - Lê Phúc Khang	73	2025-09-14 02:28:11.406
242	1066	2025-09-14	sunday	t	QR Scan - Teresa Nguyen Doan Dan Thanh	29	2025-09-14 02:28:12.445
243	319	2025-09-14	sunday	t	QR Scan - Maria Doan Nguyen Gia Han	29	2025-09-14 02:28:17.236
245	521	2025-09-14	sunday	t	Manual Present Entry - Phạm Duy Khoa	73	2025-09-14 02:28:28.359
246	1100	2025-09-14	sunday	t	QR Scan - Anton Tran Nguyen Phuc Thien	29	2025-09-14 02:28:28.977
247	247	2025-09-14	sunday	t	QR Scan - Giuse Pham Ngoc Huy Dan	29	2025-09-14 02:28:33.717
249	779	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Minh Nguyên	73	2025-09-14 02:28:37.323
250	546	2025-09-14	sunday	t	QR Scan - Luy Phan Anh Khoi	12	2025-09-14 02:28:39.72
251	367	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Trung Hiau	29	2025-09-14 02:28:41.302
252	278	2025-09-14	sunday	t	Universal QR Scan	16	2025-09-14 02:28:42.164
253	410	2025-09-14	sunday	t	Universal QR Scan	16	2025-09-14 02:28:42.166
254	614	2025-09-14	sunday	t	Universal QR Scan	16	2025-09-14 02:28:42.169
255	784	2025-09-14	sunday	t	Universal QR Scan	16	2025-09-14 02:28:42.185
256	549	2025-09-14	sunday	t	QR Scan - Giuse Tran Hoang Minh Khoi	29	2025-09-14 02:28:44.881
257	661	2025-09-14	sunday	t	QR Scan - Giuse Phan Eng Ac Minh	12	2025-09-14 02:28:45.604
258	261	2025-09-14	sunday	t	QR Scan - Giuse Tren Thanh Et	29	2025-09-14 02:28:48.077
259	859	2025-09-14	sunday	t	QR Scan - Da Minh Bui Gia Phat	12	2025-09-14 02:28:50.444
260	804	2025-09-14	sunday	t	QR Scan - A Minh Nguyen Phem Minh Nhet	29	2025-09-14 02:28:51.328
261	962	2025-09-14	sunday	t	QR Scan - Phero Nguyen Vinh Quang	29	2025-09-14 02:28:57.492
262	201	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Thành Danh	73	2025-09-14 02:29:01.988
263	409	2025-09-14	sunday	t	QR Scan - Giuse Vu Hoang Huy	12	2025-09-14 02:29:04.109
264	945	2025-09-14	sunday	t	QR Scan - Martino Tran Hoang Thien Phuoc	29	2025-09-14 02:29:04.275
265	369	2025-09-14	sunday	t	Manual Present Entry - Vũ Ngọc Hoan	29	2025-09-14 02:29:17.777
266	297	2025-09-14	sunday	t	QR Scan - Maria Duong Quynh Giao	12	2025-09-14 02:29:22.341
268	835	2025-09-14	sunday	t	Manual Present Entry - Hoàng Lê Hạo Nhiên	73	2025-09-14 02:29:29.385
269	290	2025-09-14	sunday	t	Manual Present Entry - Vũ Việt Đức	29	2025-09-14 02:29:29.893
270	1260	2025-09-14	sunday	t	QR Scan - Maria Nguyen Tuong Vi	12	2025-09-14 02:29:32.964
267	751	2025-09-14	sunday	t	QR Scan - Maria Nguyen Le Bao Ngoc	12	2025-09-14 02:29:39.796
272	1185	2025-09-14	sunday	t	QR Scan - Maria Nguyen Dinh Khanh Thy	12	2025-09-14 02:29:54.357
239	722	2025-09-14	sunday	t	QR Scan - Rosa Trenh Hoang Thuy Ngan	29	2025-09-14 02:33:02.775
248	1122	2025-09-14	sunday	t	QR Scan - Vinh Son Huynh Hung Thinh	29	2025-09-14 02:33:05.007
244	1191	2025-09-14	sunday	t	QR Scan - Maria Truong Pham Minh Thy	29	2025-09-14 02:33:13.906
197	299	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.446
208	310	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.449
184	244	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.691
185	763	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.712
186	1209	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.732
187	1337	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.737
273	939	2025-09-14	sunday	t	Manual Present Entry - Trương Thiên Phúc	29	2025-09-14 02:29:54.39
274	1003	2025-09-14	sunday	t	Manual Present Entry - Trần Ngọc Phương Quỳnh	73	2025-09-14 02:30:08.017
275	1176	2025-09-14	sunday	t	Manual Present Entry - Trần Thị Minh Thư	12	2025-09-14 02:30:16.033
276	348	2025-09-14	sunday	t	QR Scan - Maria Thach Ngac Han	12	2025-09-14 02:30:26.376
277	175	2025-09-14	sunday	t	QR Scan - Da Minh Pham Thanh Binh	12	2025-09-14 02:30:33.387
278	580	2025-09-14	sunday	t	QR Scan - Maria Bui Thi Ngoc Linh	73	2025-09-14 02:30:36.716
279	49	2025-09-14	sunday	t	QR Scan - Rosa Ao The Kim Anh	73	2025-09-14 02:30:39.529
280	740	2025-09-14	sunday	t	QR Scan - Maria Le Nguyen Bao Ngoc	73	2025-09-14 02:30:41.486
281	51	2025-09-14	sunday	t	QR Scan - Da Minh Dinh Nguyen The Anh	12	2025-09-14 02:30:42.956
282	145	2025-09-14	sunday	t	QR Scan - Gioan Le Trieu Thien Bao	73	2025-09-14 02:30:53.68
283	1230	2025-09-14	sunday	t	QR Scan - Phero Vo Ten Trung	73	2025-09-14 02:31:01.487
284	651	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Truong Quac Minh	73	2025-09-14 02:31:04.899
285	184	2025-09-14	sunday	t	Manual Present Entry - Trương Quốc Cường	12	2025-09-14 02:31:06.286
286	358	2025-09-14	sunday	t	Universal QR Scan	79	2025-09-14 02:31:09.774
287	812	2025-09-14	sunday	t	Universal QR Scan	79	2025-09-14 02:31:09.776
288	1036	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Hoang Hau Tien	73	2025-09-14 02:31:13.686
289	363	2025-09-14	sunday	t	Manual Present Entry - Đỗ Minh Hiếu	12	2025-09-14 02:31:17.814
290	415	2025-09-14	sunday	t	QR Scan - Phero Nguyen Phem Minh Hung	73	2025-09-14 02:31:18.859
291	467	2025-09-14	sunday	t	QR Scan - Gioan Baotixita Nguyen Hau Khang	73	2025-09-14 02:31:23.737
292	171	2025-09-14	sunday	t	QR Scan - Gierado Vu Thien Bao	73	2025-09-14 02:31:30.15
293	398	2025-09-14	sunday	t	QR Scan - Phaolo Phem Oan Gia Huy	73	2025-09-14 02:31:35.079
294	1051	2025-09-14	sunday	t	QR Scan - Phero Nguyen Thien Tuen	73	2025-09-14 02:31:41.187
295	675	2025-09-14	sunday	t	QR Scan - Maria Nguyen Cat Ha My	73	2025-09-14 02:31:43.226
296	105	2025-09-14	sunday	t	QR Scan - Teresa Tran Vu Dong Anh	73	2025-09-14 02:31:46.622
297	131	2025-09-14	sunday	t	Universal QR Scan	79	2025-09-14 02:31:50.913
298	572	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Hoang Lam	12	2025-09-14 02:32:21.515
233	850	2025-09-14	sunday	t	QR Scan - Madalena Nguyen Thi Bao Nhu	29	2025-09-14 02:32:59.492
303	579	2025-09-14	sunday	t	Manual Present Entry - Phạm Nguyễn Gia Liêm	29	2025-09-14 02:33:32.501
304	1224	2025-09-14	sunday	t	QR Scan - Maria Ho Ngoc Thanh Truc	29	2025-09-14 02:34:35.113
306	294	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hương Giang	29	2025-09-14 02:34:45.921
198	314	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.452
194	463	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.453
206	545	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.455
214	533	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.457
200	630	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.458
207	680	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.46
196	797	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.462
210	851	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.464
204	909	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.465
205	942	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.467
195	1117	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.468
199	1188	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.47
213	1216	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.472
211	1334	2025-09-14	sunday	t	Universal QR Scan	36	2025-09-14 02:34:53.474
1441	811	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.633
1442	697	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.645
1443	730	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.66
1444	837	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.685
191	867	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.71
1447	864	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.72
1449	947	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.738
1450	923	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.747
1451	987	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.755
1452	983	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.77
1453	998	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.783
1454	1047	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.792
1455	1107	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.801
1456	1054	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.809
339	379	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Văn Hoàng	29	2025-09-14 02:38:40.139
342	508	2025-09-14	sunday	t	Manual Present Entry - Đỗ Tân Khoa	29	2025-09-14 02:39:13.646
365	843	2025-09-14	sunday	t	Manual Present Entry - Trương Nguyễn Tường Nhiên	92	2025-09-14 02:46:26.44
366	46	2025-09-14	sunday	t	Manual Present Entry - Chu Bảo Anh	92	2025-09-14 02:46:55.903
345	627	2025-09-14	sunday	t	QR Scan - Anna Phan Vu Khanh Ly	87	2025-09-14 03:35:22.812
346	214	2025-09-14	sunday	t	QR Scan - Teresa Vu He Thanh Dung	87	2025-09-14 03:35:30.281
347	526	2025-09-14	sunday	t	QR Scan - Toma Tren Ang Khoa	87	2025-09-14 03:35:34.825
349	772	2025-09-14	sunday	t	QR Scan - Teresa Le Hoang Thao Nguyen	87	2025-09-14 03:35:44.43
350	302	2025-09-14	sunday	t	QR Scan - Maria Phem Minh Ha	87	2025-09-14 03:35:49.221
351	555	2025-09-14	sunday	t	QR Scan - Maria Nguyen Cat Phuong Lam	87	2025-09-14 03:35:52.677
352	948	2025-09-14	sunday	t	QR Scan - Teresa Nguyen Ha Phuong	87	2025-09-14 03:35:56.13
364	260	2025-09-14	sunday	t	QR Scan - Giuse Tren Tuen Et	87	2025-09-14 03:36:08.195
358	370	2025-09-14	sunday	t	QR Scan - Gioan Baotixita Bui Gia Hoang	87	2025-09-14 03:36:12.671
357	452	2025-09-14	sunday	t	QR Scan - Vincente Nguyen Tren Quang Khai	87	2025-09-14 03:36:17.186
354	99	2025-09-14	sunday	t	QR Scan - Maria Tren Ngac Bao Anh	87	2025-09-14 03:36:27.575
355	62	2025-09-14	sunday	t	QR Scan - Maria Le Nguyen Tam Anh	87	2025-09-14 03:36:37.228
356	628	2025-09-14	sunday	t	QR Scan - Maria Eng Anh Mai	87	2025-09-14 03:36:41.433
353	42	2025-09-14	sunday	t	QR Scan - Maria Vu Ngac Bao An	87	2025-09-14 03:36:45.158
362	408	2025-09-14	sunday	t	QR Scan - Giuse Maria Vo Quang Huy	87	2025-09-14 03:36:48.658
361	483	2025-09-14	sunday	t	QR Scan - Vincente Tren Duy Khang	87	2025-09-14 03:36:52.141
359	924	2025-09-14	sunday	t	QR Scan - Giuse Luong Hoang Phuc	87	2025-09-14 03:36:57.2
363	863	2025-09-14	sunday	t	QR Scan - Gioan Kim Huenh Tuen Phat	87	2025-09-14 03:37:11.315
360	1248	2025-09-14	sunday	t	QR Scan - Maria Goretti Teng Minh Uyen	87	2025-09-14 03:37:19.627
367	1312	2025-09-14	sunday	t	QR Scan - Maria Tren Ngac Thao Vy	28	2025-09-14 02:53:45.248
368	301	2025-09-14	sunday	t	QR Scan - Agnes Phem Khanh Ha	28	2025-09-14 02:53:49.012
369	790	2025-09-14	sunday	t	QR Scan - Giuse Le Nguyen	28	2025-09-14 02:57:04.052
370	332	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ngọc Hân	28	2025-09-14 02:57:49.638
371	690	2025-09-14	sunday	t	Manual Present Entry - Trần Thị Hà My	10	2025-09-14 03:01:52.888
372	274	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Trung Định	10	2025-09-14 03:02:05.236
373	927	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hoài Phúc	10	2025-09-14 03:02:13.758
374	547	2025-09-14	sunday	t	Universal QR Scan	79	2025-09-14 03:02:20.123
375	626	2025-09-14	sunday	t	QR Scan - Teresa Phem Tren Khanh Ly	10	2025-09-14 03:03:16.121
376	1129	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Văn Công Thịnh	28	2025-09-14 03:03:26.452
377	154	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Lê Gia Bảo	28	2025-09-14 03:04:09.771
378	695	2025-09-14	sunday	t	QR Scan - Gioakim Do Bao Nam	28	2025-09-14 03:04:14.575
379	179	2025-09-14	sunday	t	QR Scan - Maria Nguyen Trinh Son Ca	10	2025-09-14 03:07:43.962
380	69	2025-09-14	sunday	t	QR Scan - Maria Nguyen Ngoc Lan Anh	10	2025-09-14 03:08:21.33
381	612	2025-09-14	sunday	t	QR Scan - Gioan Baotixita Phung Bao Long	28	2025-09-14 03:10:20.301
382	1033	2025-09-14	sunday	t	Manual Present Entry - Trần Ngọc Thủy Tiên	28	2025-09-14 03:10:48.773
384	307	2025-09-14	sunday	t	QR Scan - Anna Nguyen Ngac Heng Henh	51	2025-09-14 03:12:24.689
385	933	2025-09-14	sunday	t	QR Scan - Vinh Son Pham Thien Phuc	51	2025-09-14 03:12:34.549
386	1307	2025-09-14	sunday	t	QR Scan - Maria Phan Vu Nhet Vy	51	2025-09-14 03:12:40.942
387	76	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Nhật Anh	10	2025-09-14 03:12:46.498
389	180	2025-09-14	sunday	t	QR Scan - Madalena Nguyen Hoang Gia Cat	51	2025-09-14 03:13:35.21
390	1035	2025-09-14	sunday	t	QR Scan - Micae Bui Le Minh Tien	51	2025-09-14 03:15:02.281
391	619	2025-09-14	sunday	t	QR Scan - Daminh Vu Tan Loc	10	2025-09-14 03:16:50.61
392	270	2025-09-14	sunday	t	QR Scan - Gierado Truong Phem Minh Ang	51	2025-09-14 03:17:22.082
393	756	2025-09-14	sunday	t	QR Scan - Maria Quang Thi Hong Ngoc	10	2025-09-14 03:17:56.697
394	858	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hoàng Yến Oanh	51	2025-09-14 03:18:16.872
395	416	2025-09-14	sunday	t	QR Scan - Vinh Son Nguyen Quoc Hung	51	2025-09-14 03:18:22.377
396	1029	2025-09-14	sunday	t	Manual Present Entry - Hà Phan Cát Tiên	51	2025-09-14 03:18:54.86
397	1309	2025-09-14	sunday	t	Manual Present Entry - Trần Ai Vy	51	2025-09-14 03:19:06.932
398	866	2025-09-14	sunday	t	Manual Present Entry - Lê Sỹ Gia Phát	51	2025-09-14 03:19:24.983
400	391	2025-09-14	sunday	t	Manual Present Entry - Hoàng Gia Huy	51	2025-09-14 03:19:31.368
383	571	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.701
402	70	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ngọc Phương Anh	51	2025-09-14 03:19:51.36
403	331	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ngọc Hân	51	2025-09-14 03:19:58.416
405	729	2025-09-14	sunday	t	Manual Present Entry - Đinh Phạm Thảo Nghi	28	2025-09-14 03:20:38.566
406	1234	2025-09-14	sunday	t	Manual Present Entry - Hoàng Thanh Anh Uy	51	2025-09-14 03:20:47.666
407	1011	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Trần Thanh Sang	51	2025-09-14 03:21:02.532
408	77	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Nhật Anh	51	2025-09-14 03:21:06.595
409	795	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hoàng Nhân	51	2025-09-14 03:22:02.902
410	525	2025-09-14	sunday	t	Manual Present Entry - Thái Minh Khoa	51	2025-09-14 03:22:33.687
411	906	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hữu Gia Phú	51	2025-09-14 03:22:47.691
412	264	2025-09-14	sunday	t	Manual Present Entry - Vũ Trọng Tuấn Đạt	51	2025-09-14 03:23:01.561
413	227	2025-09-14	sunday	t	Manual Present Entry - Phạm Minh Duy	51	2025-09-14 03:23:21.08
414	1218	2025-09-14	sunday	t	Manual Present Entry - Trần Phạm Minh Triết	51	2025-09-14 03:23:57.462
415	406	2025-09-14	sunday	t	QR Scan - Giuse Tran Minh Huy	28	2025-09-14 03:24:26.067
416	1183	2025-09-14	sunday	t	QR Scan - Teresa Inh Khanh Thy	10	2025-09-14 03:27:11.25
417	982	2025-09-14	sunday	t	QR Scan - Phero Vo Hoang Quan	10	2025-09-14 03:28:05.482
418	83	2025-09-14	sunday	t	QR Scan - Maria Nguyen Xuan Anh	6	2025-09-14 03:30:56.391
420	1139	2025-09-14	sunday	t	QR Scan - A Minh Bui Ac Thuen	6	2025-09-14 03:31:01.233
421	241	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Nhet Am	6	2025-09-14 03:31:03.376
422	1186	2025-09-14	sunday	t	QR Scan - Maria Nguyen Hoang Nha Thy	57	2025-09-14 03:31:05.049
423	1138	2025-09-14	sunday	t	QR Scan - Maria Pham Nguyen Anh Tho	57	2025-09-14 03:31:06.664
424	1252	2025-09-14	sunday	t	QR Scan - Maria Bui Ngac Khanh Van	57	2025-09-14 03:31:10.689
425	315	2025-09-14	sunday	t	QR Scan - Anna Eng Gia Bao Han	6	2025-09-14 03:31:11.554
426	1294	2025-09-14	sunday	t	QR Scan - Anna Nguyen Ngoc Tuong Vy	57	2025-09-14 03:31:21.901
427	423	2025-09-14	sunday	t	QR Scan - Maria Inh Tren Lan Huong	6	2025-09-14 03:31:24.596
428	187	2025-09-14	sunday	t	QR Scan - Maria Nguyen Ngoc Bao Chau	57	2025-09-14 03:31:29.446
429	1108	2025-09-14	sunday	t	QR Scan - Micae Le Phan Minh Thien	6	2025-09-14 03:31:30.844
430	713	2025-09-14	sunday	t	QR Scan - Maria Hoang Pham Khanh Ngan	57	2025-09-14 03:31:32.627
431	531	2025-09-14	sunday	t	QR Scan - Gioan Baotixita Le Nguyen Minh Khoi	6	2025-09-14 03:31:39.18
432	771	2025-09-14	sunday	t	QR Scan - Maria Le An Nguyen	57	2025-09-14 03:31:39.445
433	88	2025-09-14	sunday	t	QR Scan - Pham Nguyen Hai Anh	28	2025-09-14 03:31:39.788
434	197	2025-09-14	sunday	t	QR Scan - Maria Nguyen Ngoc Linh Chi	57	2025-09-14 03:31:42.525
435	53	2025-09-14	sunday	t	QR Scan - Teresa Do Ha Bao Anh	57	2025-09-14 03:31:52.412
436	753	2025-09-14	sunday	t	QR Scan - Anna Nguyen Nhu Bao Ngac	57	2025-09-14 03:31:54.81
437	592	2025-09-14	sunday	t	QR Scan - Teresa Trinh Truc Linh	57	2025-09-14 03:31:59.064
438	19	2025-09-14	sunday	t	QR Scan - Teresa Nguyen Hoai An	57	2025-09-14 03:32:02.789
439	678	2025-09-14	sunday	t	QR Scan - Maria Nguyen Giang My	57	2025-09-14 03:32:07.606
440	1104	2025-09-14	sunday	t	QR Scan - Aminh Vu Quac Thien	57	2025-09-14 03:32:11.637
441	622	2025-09-14	sunday	t	QR Scan - Philipphe Nguyen Hau Luong	57	2025-09-14 03:32:23.868
442	530	2025-09-14	sunday	t	QR Scan - Martino Le Hoang Dang Khoi	57	2025-09-14 03:32:26.012
443	868	2025-09-14	sunday	t	QR Scan - Phero Luong Hoang Gia Phat	10	2025-09-14 03:32:27.464
444	485	2025-09-14	sunday	t	QR Scan - Phanxico Tren Huy Khang	57	2025-09-14 03:32:34.502
445	181	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Thanh Cong	57	2025-09-14 03:32:37.207
446	606	2025-09-14	sunday	t	QR Scan - Aminh Nguyen Inh Long	57	2025-09-14 03:32:44.382
447	282	2025-09-14	sunday	t	QR Scan - Daminh Hoang Thien Duc	57	2025-09-14 03:32:50.247
448	156	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Quac Bao	57	2025-09-14 03:32:52.404
449	1015	2025-09-14	sunday	t	QR Scan - Le Phem Van Tai	57	2025-09-14 03:32:56.125
399	441	2025-09-14	sunday	t	QR Scan - Maria Luong Gia Kim	51	2025-09-14 03:36:18.762
404	431	2025-09-14	sunday	t	QR Scan - Giuse Tren Ac Kien	51	2025-09-14 03:38:07.722
388	746	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.992
419	519	2025-09-14	sunday	t	Manual attendance marking	18	2025-09-14 13:11:42.199
450	430	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Hoang Kien	57	2025-09-14 03:33:04.105
451	664	2025-09-14	sunday	t	QR Scan - Giuse Tren Nguyen Quang Minh	57	2025-09-14 03:33:06.01
452	1331	2025-09-14	sunday	t	QR Scan - Maria Luu Nguyen Hai Yen	28	2025-09-14 03:33:08.081
453	928	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hoàng Phúc	57	2025-09-14 03:33:19.163
454	1278	2025-09-14	sunday	t	QR Scan - Phaolo Do Thien Vuong	28	2025-09-14 03:33:52.418
455	1078	2025-09-14	sunday	t	QR Scan - Nguyen Hoang Phuong Thao	51	2025-09-14 03:34:32.805
456	373	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Bảo Hoàng	92	2025-09-14 03:34:45.447
457	655	2025-09-14	sunday	t	Manual Present Entry - Phạm Đức Anh Minh	92	2025-09-14 03:34:51.252
458	254	2025-09-14	sunday	t	QR Scan - Luy He Thanh Et	10	2025-09-14 03:34:59.287
344	355	2025-09-14	sunday	t	QR Scan - Maria Vu Gia Han	87	2025-09-14 03:35:18.017
348	481	2025-09-14	sunday	t	QR Scan - Giuse Tren Bao Khang	87	2025-09-14 03:35:43.615
470	886	2025-09-14	sunday	t	QR Scan - Giuse Oan Chen Phong	87	2025-09-14 03:36:04.744
401	741	2025-09-14	sunday	t	QR Scan - Maria Le Nguyen Lan Ngac	51	2025-09-14 03:36:15.673
477	807	2025-09-14	sunday	t	QR Scan - Duong Gia Bao Nhi	28	2025-09-14 03:36:31.399
479	318	2025-09-14	sunday	t	QR Scan - Maria Oan Ngac Han	10	2025-09-14 03:36:40.944
485	1076	2025-09-14	sunday	t	QR Scan - Raphaen Vu Duy Thanh	10	2025-09-14 03:36:59.251
489	237	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.037
490	329	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.04
491	501	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.042
492	576	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.044
493	582	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.047
494	607	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.052
495	670	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.056
496	673	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.058
497	711	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.06
498	714	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.062
499	762	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.064
500	887	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.066
501	914	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.068
502	1074	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.07
503	1115	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.072
504	1202	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.074
505	1236	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.076
506	1272	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.078
469	146	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.544
508	268	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:40:44.081
509	719	2025-09-14	sunday	t	QR Scan - Matta Nguyen Thi Kim Ngan	28	2025-09-14 03:41:14.627
510	568	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:41:28.55
511	968	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:41:28.552
512	336	2025-09-14	sunday	t	Universal QR Scan	88	2025-09-14 03:41:44.422
513	1094	2025-09-14	sunday	t	QR Scan - Giuse Phem Nhet Thien	10	2025-09-14 03:42:15.162
514	994	2025-09-14	sunday	t	QR Scan - Maria Tren Nguyen Xuan Quyen	10	2025-09-14 03:42:17.748
515	34	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.897
516	37	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.902
517	50	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.906
518	123	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.908
519	139	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.91
520	186	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.912
521	366	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.914
522	470	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.915
523	586	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.917
524	610	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.919
525	727	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.921
526	775	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.922
527	841	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.925
528	844	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.927
529	1127	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.929
530	1284	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.931
531	639	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.933
532	225	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 03:43:50.934
533	224	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Khánh Duy	7	2025-09-14 03:44:15.797
534	721	2025-09-14	sunday	t	Manual Present Entry - Trần Vũ Thiên Ngân	7	2025-09-14 03:44:28.841
535	450	2025-09-14	sunday	t	QR Scan - Phaolo Tren Heng Ke	28	2025-09-14 03:44:33.136
536	429	2025-09-14	sunday	t	Manual Present Entry - Bùi Nguyễn Trung Kiên	7	2025-09-14 03:44:55.093
537	963	2025-09-14	sunday	t	QR Scan - Da Minh Tran Minh Quang	10	2025-09-14 03:45:30.214
538	484	2025-09-14	sunday	t	QR Scan - Vinh Son Tran Gia Khang	28	2025-09-14 03:45:46.961
539	454	2025-09-14	sunday	t	QR Scan - Phaolo Truong Quang Khai	10	2025-09-14 03:46:35.882
540	397	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Vũ Hoàng Huy	10	2025-09-14 03:47:04.516
541	1056	2025-09-14	sunday	t	QR Scan - Anna Nguyen Minh Kim Tuyen	10	2025-09-14 03:48:15.818
542	1123	2025-09-14	sunday	t	QR Scan - Phaolo Luu Khanh Hung Thenh	28	2025-09-14 03:48:39.841
543	1014	2025-09-14	sunday	t	QR Scan - Giuse Nguyen Trung Son	28	2025-09-14 03:49:48.464
544	1149	2025-09-14	sunday	t	QR Scan - Maria Cao Song Thu	28	2025-09-14 03:49:51.162
545	539	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Minh Khôi	10	2025-09-14 03:50:13.233
546	647	2025-09-14	sunday	t	QR Scan - Phero Nguyen Son Nhat Minh	10	2025-09-14 03:50:26.777
547	168	2025-09-14	sunday	t	QR Scan - Inhaxio Trinh Hieu Bao	28	2025-09-14 03:50:41.612
548	115	2025-09-14	sunday	t	Manual Present Entry - Mai Minh Ân	10	2025-09-14 03:50:43.858
549	325	2025-09-14	sunday	t	Manual Present Entry - Kiều Việt Gia Hân	10	2025-09-14 03:51:11.348
550	498	2025-09-14	sunday	t	Manual Present Entry - Đăng Quốc Khánh	10	2025-09-14 03:52:34.406
551	936	2025-09-14	sunday	t	QR Scan - Giuse Tren Lam Thien Phuc	10	2025-09-14 03:52:42.522
552	155	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ngọc Bảo	10	2025-09-14 03:53:06.102
553	1026	2025-09-14	sunday	t	QR Scan - Maria Vu He Thac Tam	10	2025-09-14 03:54:23.871
554	981	2025-09-14	sunday	t	Manual Present Entry - Võ Hoàng Quân	7	2025-09-14 06:05:11.918
555	828	2025-09-14	sunday	t	Manual Present Entry - Trần Phương Nhi	7	2025-09-14 06:05:23.806
556	840	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ngọc An Nhiên	7	2025-09-14 06:05:41.479
557	125	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.949
558	194	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.953
559	200	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.956
560	228	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.958
561	246	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.961
562	277	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.963
563	339	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.965
564	386	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.97
565	443	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.972
566	447	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.976
567	616	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.978
568	646	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.982
569	702	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.985
570	715	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.987
571	731	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.99
573	978	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.996
574	979	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:53.999
575	992	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:54.001
576	1001	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:54.005
577	1024	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:54.012
578	1134	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:54.015
579	1243	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:54.018
580	1283	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:54.021
581	688	2025-09-14	sunday	t	Manual attendance marking	69	2025-09-14 06:12:54.023
582	1132	2025-09-14	sunday	t	Manual Present Entry - Phan Hưng Thịnh	7	2025-09-14 06:22:32.729
583	249	2025-09-14	sunday	t	Manual Present Entry - Trần Thị Linh Đan	7	2025-09-14 06:23:02.321
584	912	2025-09-14	sunday	t	Manual Present Entry - Đinh Đức Phúc	7	2025-09-14 06:23:54.615
585	813	2025-09-14	sunday	t	Manual Present Entry - Lương Thiện Nhi	7	2025-09-14 06:24:12.872
586	1042	2025-09-14	sunday	t	Manual Present Entry - Lê Trung Tín	7	2025-09-14 06:24:23.946
587	1178	2025-09-14	sunday	t	Manual Present Entry - Võ Ngân Thư	6	2025-09-14 06:24:36.473
588	999	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Khánh Quỳnh	7	2025-09-14 06:24:43.528
589	1019	2025-09-14	sunday	t	Manual Present Entry - Đoàn Minh Tâm	6	2025-09-14 06:24:47.606
590	809	2025-09-14	sunday	t	Manual Present Entry - Hoàng Nguyễn Tuệ Nhi	6	2025-09-14 06:24:58.467
592	873	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Lê Gia Phát	6	2025-09-14 06:26:46.29
593	1005	2025-09-14	sunday	t	Manual Present Entry - Vũ Ngọc Ngân Quỳnh	7	2025-09-14 06:26:56.306
594	313	2025-09-14	sunday	t	Manual Present Entry - Dương Đỗ Gia Hân	7	2025-09-14 06:27:15.414
595	48	2025-09-14	sunday	t	Manual Present Entry - Đàm Trần Trâm Anh	7	2025-09-14 06:27:28.686
596	860	2025-09-14	sunday	t	Manual Present Entry - Đàm Việt Phát	6	2025-09-14 06:27:31.208
597	632	2025-09-14	sunday	t	Manual Present Entry - Phạm Thị Quỳnh Mai	6	2025-09-14 06:27:40.981
598	1067	2025-09-14	sunday	t	Manual Present Entry - Phạm Thị Diệu Thanh	7	2025-09-14 06:27:49.164
599	252	2025-09-14	sunday	t	Manual Present Entry - Đoàn Tấn Đạt	6	2025-09-14 06:27:49.686
600	347	2025-09-14	sunday	t	Manual Present Entry - Tạ Cát Gia Hân	7	2025-09-14 06:28:31.178
601	116	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Đức Thiên Ân	7	2025-09-14 06:29:22.907
602	1142	2025-09-14	sunday	t	Manual Present Entry - Phan Trần Kim Thuỷ	6	2025-09-14 06:29:35.994
603	286	2025-09-14	sunday	t	Manual Present Entry - Trần Minh Đức	7	2025-09-14 06:29:42.055
604	569	2025-09-14	sunday	t	Manual Present Entry - Đỗ Phúc Lâm	6	2025-09-14 06:30:17.479
605	654	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ý Minh	7	2025-09-14 06:30:22.367
606	1308	2025-09-14	sunday	t	Manual Present Entry - Từ Lưu Yến Vy	7	2025-09-14 06:30:48.366
607	919	2025-09-14	sunday	t	Manual Present Entry - Huỳnh Vĩnh Phúc	7	2025-09-14 06:32:07.192
608	692	2025-09-14	sunday	t	Manual Present Entry - Vũ Thị Khởi My	6	2025-09-14 06:32:37.815
609	157	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Trần Gia Bảo	7	2025-09-14 06:33:03.229
610	405	2025-09-14	sunday	t	Manual Present Entry - Trần Minh Huy	6	2025-09-14 06:33:11.099
611	564	2025-09-14	sunday	t	Manual Present Entry - Hà Thái Hoàng Lan	7	2025-09-14 06:33:36.395
612	1207	2025-09-14	sunday	t	Manual Present Entry - Thái Phương Trân	7	2025-09-14 06:34:02.278
613	1296	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Nhật Vy	7	2025-09-14 06:34:40.518
614	739	2025-09-14	sunday	t	Manual Present Entry - Lê Nguyễn Bảo Ngọc	7	2025-09-14 06:36:20.08
615	770	2025-09-14	sunday	t	Manual Present Entry - Huỳnh Khôi Nguyên	7	2025-09-14 06:36:46.52
616	1110	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Chí Thiện	57	2025-09-14 07:33:51.301
617	124	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Thiên Ân	57	2025-09-14 07:34:14.39
618	1061	2025-09-14	sunday	t	Manual Present Entry - Trần Quốc Thái	57	2025-09-14 07:34:28.413
619	1328	2025-09-14	sunday	t	Manual Present Entry - Vũ Đoàn Như Ý	57	2025-09-14 07:34:45.696
620	718	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ngọc Kim Ngân	57	2025-09-14 07:34:55.657
621	133	2025-09-14	sunday	t	Manual Present Entry - Trần Tùng Bách	57	2025-09-14 07:35:25.671
622	1010	2025-09-14	sunday	t	Manual Present Entry - Trần Ngọc Linh San	57	2025-09-14 07:35:38.244
623	1277	2025-09-14	sunday	t	Manual Present Entry - Vương Điền Vũ	57	2025-09-14 07:36:32.275
624	750	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Khương Ngọc	57	2025-09-14 07:36:48.438
625	511	2025-09-14	sunday	t	Manual Present Entry - Lưu Anh Khoa	57	2025-09-14 07:38:20.989
626	570	2025-09-14	sunday	t	Manual Present Entry - Mai Chi Lâm	57	2025-09-14 07:38:32.255
627	925	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Công Phúc	57	2025-09-14 07:44:31.254
628	918	2025-09-14	sunday	t	Manual Present Entry - Huỳnh Hữu Phúc	57	2025-09-14 07:44:45.607
629	891	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Duy Phong	57	2025-09-14 07:44:58.251
630	461	2025-09-14	sunday	t	Manual Present Entry - Lê Trần Hạo Khang	57	2025-09-14 07:45:04.326
631	635	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Mai Gia Mẫn	57	2025-09-14 07:45:39.511
632	132	2025-09-14	sunday	t	Manual Present Entry - Đỗ Quang Bách	57	2025-09-14 07:45:51.145
633	39	2025-09-14	sunday	t	Manual Present Entry - Võ Hoàng Bình An	57	2025-09-14 07:45:59.965
634	799	2025-09-14	sunday	t	Manual Present Entry - Trần Thiện Nhân	57	2025-09-14 07:46:09.394
635	1073	2025-09-14	sunday	t	Manual Present Entry - Phạm Tấn Thành	57	2025-09-14 07:47:42.592
636	897	2025-09-14	sunday	t	Manual Present Entry - Vũ Đình Phong	57	2025-09-14 07:50:46.685
591	869	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.729
1457	1240	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.817
1458	1287	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.825
1459	1077	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.843
1460	18	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.85
1461	79	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.857
1462	26	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.865
1465	66	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.888
1466	81	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.897
1467	21	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.904
1468	31	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.911
1469	82	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.918
1470	68	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.926
1471	29	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.937
1472	73	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.947
1473	119	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.954
331	193	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.961
1475	189	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.971
1476	195	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.98
1477	183	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.989
1478	199	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.997
1479	196	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.004
1100	202	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.013
1481	258	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.028
1482	226	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.037
1483	204	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.045
1484	275	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.053
744	317	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.754
743	235	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.759
740	147	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.767
694	1079	2025-09-14	sunday	t	Universal QR Scan	79	2025-09-14 11:18:16.234
695	434	2025-09-14	sunday	t	Manual Present Entry - Đàm Huỳnh Tuấn Kiệt	12	2025-09-14 13:07:37.72
700	56	2025-09-14	sunday	t	Manual attendance marking	18	2025-09-14 13:11:42.193
701	442	2025-09-14	sunday	t	Manual attendance marking	18	2025-09-14 13:11:42.197
703	634	2025-09-14	sunday	t	Manual attendance marking	18	2025-09-14 13:11:42.204
704	1089	2025-09-14	sunday	t	Manual attendance marking	18	2025-09-14 13:11:42.207
705	943	2025-09-14	sunday	t	Manual Present Entry - Vũ Thiên Phúc	57	2025-09-14 13:41:22.385
706	494	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Lê Nhã Khanh	57	2025-09-14 13:41:31.804
707	1198	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Ngọc Bảo Trâm	57	2025-09-14 13:41:44.313
708	1125	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Phúc Thịnh	57	2025-09-14 13:41:55.461
709	1262	2025-09-14	sunday	t	Manual Present Entry - Kiều Tuấn Việt	57	2025-09-14 13:42:25.534
710	13	2025-09-14	sunday	t	Manual Present Entry - Lê Mỹ An	57	2025-09-14 13:42:32.089
711	1021	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hoàng Tâm	57	2025-09-14 13:42:39.673
712	1095	2025-09-14	sunday	t	Manual Present Entry - Phan Quốc Thiên	57	2025-09-14 13:43:01.422
713	532	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Anh Khôi	57	2025-09-14 13:43:35.553
714	273	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Đình Đình	57	2025-09-14 13:44:11.247
715	114	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.525
716	151	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.53
717	231	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.532
718	288	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.534
719	289	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.536
720	308	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.538
721	390	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.541
722	436	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.543
723	476	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.546
724	516	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.548
725	1020	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.551
726	1045	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.553
727	1140	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.557
728	1199	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.559
729	1220	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.561
730	1213	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.564
731	1266	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.565
732	1317	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.571
733	1322	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.574
734	1336	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.576
735	1098	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.579
736	55	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.581
737	112	2025-09-14	sunday	t	Manual attendance marking	15	2025-09-14 13:45:20.584
762	515	2025-09-14	sunday	t	Manual Present Entry - Nguyễn Hoàng Anh Khoa	57	2025-09-14 13:46:07.48
638	9	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.67
639	59	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.677
640	74	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.68
641	110	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.682
643	160	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.686
644	221	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.688
646	341	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.693
647	407	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.695
649	439	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.698
650	491	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.701
761	148	2025-09-14	sunday	t	Manual Present Entry - Lý Gia Bảo	57	2025-09-14 13:45:53.13
763	913	2025-09-14	sunday	t	Manual Present Entry - Đỗ Hoàng Phúc	57	2025-09-14 13:46:21.521
764	613	2025-09-14	sunday	t	Manual Present Entry - Trần Đức Long	57	2025-09-14 13:46:30.859
765	838	2025-09-14	sunday	t	Manual Present Entry - Nguyễn An Nhiên	57	2025-09-14 13:46:44.304
766	492	2025-09-14	sunday	t	Manual Present Entry - Vũ Trọng Khang	57	2025-09-14 13:47:59.683
767	283	2025-09-14	sunday	t	Manual Present Entry - Phạm Trần Minh Đức	57	2025-09-14 13:48:19.13
768	1300	2025-09-14	sunday	t	Manual Present Entry - Phạm Khánh Vy	57	2025-09-14 13:48:38.301
769	311	2025-09-14	sunday	t	Manual Present Entry - Bùi Ngọc Bảo Hân	57	2025-09-14 13:48:44.971
770	1228	2025-09-14	sunday	t	Manual Present Entry - Vũ Nguyễn Thanh Trúc	57	2025-09-14 13:49:00.791
771	206	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 14:11:09.386
772	32	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 14:15:53.081
773	158	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 14:15:53.084
774	468	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 14:15:53.088
775	689	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 14:15:53.091
776	990	2025-09-14	sunday	t	Universal QR Scan	58	2025-09-14 14:15:53.094
828	265	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.191
324	964	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.275
826	27	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.872
1485	236	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.062
1486	266	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.07
1487	207	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.078
1488	267	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.086
1489	256	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.094
860	92	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.682
850	215	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.685
1490	550	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.102
862	251	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.688
1492	514	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.119
328	474	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.126
1496	471	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.151
1497	503	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.16
1498	465	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.169
652	585	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.703
651	573	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.706
653	652	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.708
654	698	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.71
656	833	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.714
657	961	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.716
658	993	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.719
659	1025	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.721
660	1111	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.723
662	1154	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.725
664	1326	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.734
661	1120	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.739
642	177	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.741
648	412	2025-09-14	sunday	t	Manual attendance marking	4	2025-09-14 16:17:24.743
1499	464	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.177
1500	541	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.186
1501	617	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.194
1502	557	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.203
849	22	2025-09-15	thursday	t	Manual Present Entry - Nguyễn Lê Khải An	45	2025-09-15 03:43:45.191
1503	584	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.216
326	821	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.35
340	931	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.469
332	973	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.562
341	1013	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.596
329	1112	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.717
851	280	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.69
335	340	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.99
327	625	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.177
338	548	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.72
852	338	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.693
836	785	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.833
333	669	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.381
758	1310	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.761
865	419	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.697
754	879	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.762
325	621	2025-09-14	sunday	t	Manual attendance marking	13	2025-09-16 07:41:47.886
853	522	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.699
866	523	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.701
868	565	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.705
343	878	2025-09-14	sunday	t	Manual attendance marking	13	2025-09-16 07:41:47.904
1504	605	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.23
1505	558	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.238
1506	636	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.246
1507	682	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.254
1508	677	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.262
1509	683	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.269
1111	679	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.296
1511	693	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.306
1512	684	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.315
1513	650	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.324
869	556	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.703
870	587	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.708
871	658	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.71
854	732	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.712
873	748	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.714
874	826	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.717
875	827	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.719
855	872	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.721
877	926	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.724
856	1008	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.726
878	986	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.728
880	1022	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.73
881	1040	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.732
882	1065	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.735
857	1156	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.737
884	1193	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.739
913	1327	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.741
859	496	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.743
885	1196	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.745
858	1201	2025-09-14	sunday	t	Manual attendance marking	23	2025-09-15 04:02:20.747
946	1282	2025-09-15	thursday	t	QR Scan - BV142180	45	2025-09-15 05:01:38.933
947	85	2025-09-14	sunday	t	Manual attendance marking	31	2025-09-15 07:41:44.533
948	365	2025-09-14	sunday	t	Manual attendance marking	31	2025-09-15 07:41:44.537
949	980	2025-09-14	sunday	t	Manual attendance marking	31	2025-09-15 07:41:44.54
950	1214	2025-09-14	sunday	t	Manual attendance marking	31	2025-09-15 07:41:44.543
951	988	2025-09-14	sunday	t	Manual attendance marking	31	2025-09-15 07:41:44.545
507	1281	2025-09-14	sunday	t	Manual attendance marking	31	2025-09-15 07:41:44.546
953	52	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.177
954	138	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.182
955	263	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.184
956	298	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.189
957	372	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.192
958	406	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.195
959	454	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.197
960	506	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.202
961	491	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.204
962	526	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.205
963	555	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.208
964	680	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.209
965	722	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.211
966	817	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.213
967	833	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.215
968	874	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.217
969	894	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.219
970	859	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.221
971	869	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.223
972	949	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.225
973	1008	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.227
974	1038	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.229
975	1163	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.231
976	1186	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.234
977	1188	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.235
978	1292	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.237
979	1313	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.239
980	112	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.242
981	567	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.243
982	661	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.246
983	289	2025-09-15	thursday	t	Universal QR Scan	88	2025-09-15 11:09:15.248
1514	653	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.336
1515	754	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.343
1032	589	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.195
337	1206	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.35
330	1169	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.382
1037	787	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.414
323	1291	2025-09-14	sunday	t	Manual attendance marking	13	2025-09-16 07:41:47.922
1053	155	2025-09-16	thursday	t	Manual Present Entry - Nguyễn Ngọc Bảo	87	2025-09-16 11:03:44.414
1054	176	2025-09-16	thursday	t	QR Scan - Giuse Tren Thanh Binh	87	2025-09-16 11:03:49.459
1055	92	2025-09-16	thursday	t	Manual Present Entry - Phan Ngọc Bảo Anh	87	2025-09-16 11:04:01.651
1056	512	2025-09-16	thursday	t	QR Scan - Gioan Baotixita Nguyen Anh Khoa	87	2025-09-16 11:04:09.501
1057	269	2025-09-16	thursday	t	Manual Present Entry - Trần Hải Đăng	87	2025-09-16 11:04:19.44
1058	930	2025-09-16	thursday	t	Manual Present Entry - Nguyễn Thiên Phúc	87	2025-09-16 11:04:31.82
1059	1087	2025-09-16	thursday	t	Manual Present Entry - Nguyễn Tạ Mạnh Thắng	87	2025-09-16 11:06:32.242
1060	1140	2025-09-16	thursday	t	Manual Present Entry - Bùi Minh Thuận	87	2025-09-16 11:06:43.897
1061	1002	2025-09-16	thursday	t	Universal QR Scan	88	2025-09-16 11:08:38.923
1062	273	2025-09-17	thursday	t	Manual Present Entry - Nguyễn Đình Đình	87	2025-09-17 02:11:01.474
1063	1170	2025-09-17	thursday	t	Manual Present Entry - Thạch Đoàn Anh Thư	87	2025-09-17 02:11:13.159
1064	25	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.308
1065	40	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.313
1066	30	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.316
1067	61	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.318
1068	44	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.32
1069	167	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.323
1070	292	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.325
1071	321	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.328
1072	344	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.331
1073	328	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.333
1074	489	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.335
1075	499	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.337
1076	517	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.339
1077	553	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.341
1078	631	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.344
1079	736	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.346
1080	710	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.349
1081	792	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.356
1082	920	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.363
1083	989	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.367
1084	1109	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.37
1085	1121	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.373
1086	1162	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.376
1087	1223	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.378
1088	1253	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.381
1089	836	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.383
1090	1323	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.386
1091	875	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.388
1092	84	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.39
1093	885	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.392
1094	453	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.394
1095	848	2025-09-14	sunday	t	Manual attendance marking	59	2025-09-17 09:54:41.396
1121	1014	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Trung Sơn	92	2025-09-18 10:16:45.96
1122	383	2025-09-18	thursday	t	QR Scan - Maria E Ngac Heng	86	2025-09-18 11:17:02.231
1123	550	2025-09-18	thursday	t	QR Scan - Giuse Nguyen Van Khai	86	2025-09-18 11:17:06.985
1124	169	2025-09-18	thursday	t	QR Scan - Vinh Son Trenh Thien Bao	86	2025-09-18 11:17:11.246
1125	1055	2025-09-18	thursday	t	QR Scan - Matheu Tran Thanh Tung	86	2025-09-18 11:17:13.388
1126	1130	2025-09-18	thursday	t	QR Scan - Anton Phem Phuc Thenh	86	2025-09-18 11:17:18.16
1127	964	2025-09-18	thursday	t	QR Scan - Giuse Dang Hoang Quan	86	2025-09-18 11:17:23.518
1129	1179	2025-09-18	thursday	t	QR Scan - Maria Vu Ngoc Anh Thu	86	2025-09-18 11:17:28.287
1130	1193	2025-09-18	thursday	t	QR Scan - Maria Nguyen Ngoc Van Trang	86	2025-09-18 11:17:30.676
1131	836	2025-09-18	thursday	t	QR Scan - Teresa Ho An Nhien	86	2025-09-18 11:17:33.347
1132	496	2025-09-18	thursday	t	QR Scan - Phaolo Duong Phuc An Khanh	86	2025-09-18 11:17:36.018
1133	941	2025-09-18	thursday	t	QR Scan - Giuse Vu Hong Phuc	86	2025-09-18 11:17:37.335
1134	346	2025-09-18	thursday	t	QR Scan - Teresa Phan Eng Gia Han	86	2025-09-18 11:17:44.289
1135	1314	2025-09-18	thursday	t	QR Scan - Maria Trinh Nguyen Tuong Vy	86	2025-09-18 11:17:46.155
1136	224	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Khánh Duy	90	2025-09-18 11:17:47.102
1137	1044	2025-09-18	thursday	t	QR Scan - Teresa Bui Tinh Tu	86	2025-09-18 11:17:48.276
1138	682	2025-09-18	thursday	t	QR Scan - Maria Nguyen Ngoc Tra My	86	2025-09-18 11:17:50.145
1139	580	2025-09-18	thursday	t	QR Scan - Maria Bui Thi Ngoc Linh	86	2025-09-18 11:17:51.506
1140	240	2025-09-18	thursday	t	QR Scan - Maria Tran Le Anh Duong	86	2025-09-18 11:17:55.254
1141	467	2025-09-18	thursday	t	QR Scan - Gioan Baotixita Nguyen Hau Khang	86	2025-09-18 11:17:58.185
1142	784	2025-09-18	thursday	t	QR Scan - Giuse Nguyen Phuc Nguyen	86	2025-09-18 11:18:00.296
1143	1190	2025-09-18	thursday	t	QR Scan - Teresa Pham Truong Bao Thy	86	2025-09-18 11:18:03.252
1144	66	2025-09-18	thursday	t	QR Scan - Maria Nguyen Bui Nhet Anh	86	2025-09-18 11:18:06.977
1145	901	2025-09-18	thursday	t	QR Scan - Anton Hoang Nguyen Thien Phu	86	2025-09-18 11:18:10.718
1146	726	2025-09-18	thursday	t	QR Scan - Maria Vu Ngac Thuy Ngan	90	2025-09-18 11:18:17.454
1147	1074	2025-09-18	thursday	t	QR Scan - Giuse Quach Phu Thanh	90	2025-09-18 11:18:20.773
1148	1175	2025-09-18	thursday	t	QR Scan - Maria Tran Thi Minh Thu	90	2025-09-18 11:18:28.741
1149	1137	2025-09-18	thursday	t	QR Scan - Maria Phem Anh Tho	90	2025-09-18 11:18:36.764
1150	271	2025-09-18	thursday	t	QR Scan - Giacobe Truong Vu Minh Ang	90	2025-09-18 11:18:39.873
1151	171	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.92
1152	307	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.922
1153	456	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.924
1154	546	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.926
1155	807	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.928
1156	623	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.93
1157	737	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.932
1158	547	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.933
1118	1153	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.308
1098	113	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.486
1105	462	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.594
1099	126	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:21.879
1108	518	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.134
1113	735	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.366
1119	1158	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.681
1117	1147	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.726
1104	334	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.009
1106	487	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.737
1114	937	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.925
1101	230	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.274
1103	272	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.281
1110	562	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.364
1116	1063	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.54
1159	1053	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.935
1160	1334	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.937
1161	1196	2025-09-18	thursday	t	Universal QR Scan	79	2025-09-18 11:18:42.939
1162	943	2025-09-18	thursday	t	QR Scan - Aminh Vu Thien Phuc	90	2025-09-18 11:18:44.815
1164	365	2025-09-18	thursday	t	QR Scan - Giuse Nguyen Minh Hiau	90	2025-09-18 11:18:58.013
1165	6	2025-09-18	thursday	t	QR Scan - Maria Duong Hoang Van An	90	2025-09-18 11:19:02.939
1166	839	2025-09-18	thursday	t	QR Scan - Teresa Nguyen An Nhien	90	2025-09-18 11:19:08.91
1168	396	2025-09-18	thursday	t	QR Scan - Phero Nguyen Phem Gia Huy	90	2025-09-18 11:19:29.323
1169	471	2025-09-18	thursday	t	QR Scan - Phero Nguyen Phem Gia Khang	90	2025-09-18 11:19:32.377
1170	404	2025-09-18	thursday	t	QR Scan - Phero Tren Gia Huy	90	2025-09-18 11:19:39.213
1171	745	2025-09-18	thursday	t	QR Scan - Teresa Ngo Bao Ngac	90	2025-09-18 11:19:42.653
1172	613	2025-09-18	thursday	t	Manual Present Entry - Trần Đức Long	90	2025-09-18 11:20:09.816
1173	913	2025-09-18	thursday	t	Manual Present Entry - Đỗ Hoàng Phúc	90	2025-09-18 11:20:27.141
1177	845	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Tuyết Nhung	86	2025-09-18 11:22:14.79
1178	786	2025-09-18	thursday	t	Manual Present Entry - Trần Thảo Nguyên	12	2025-09-18 11:22:17.375
1179	461	2025-09-18	thursday	t	Manual Present Entry - Lê Trần Hạo Khang	90	2025-09-18 11:22:22.051
1163	586	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.712
1517	794	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.359
1519	752	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.374
1520	818	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.381
1521	805	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.388
1522	780	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.396
1167	355	2025-09-18	thursday	t	Manual attendance marking	1	2025-09-18 12:49:53.057
1523	820	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.404
1524	783	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.412
1525	778	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.421
1526	803	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.432
1527	745	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.439
1528	817	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.447
1529	802	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.454
1530	839	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.462
1532	930	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.478
1533	894	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.487
1534	950	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.494
1535	959	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.502
1536	949	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.51
1537	905	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.518
1538	892	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.526
1539	929	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.535
1540	893	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.545
1541	874	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.554
1543	970	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.572
1544	971	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.581
1545	991	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.589
1547	1012	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.605
1548	1060	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.613
1045	1037	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.62
1550	1059	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.629
1551	1181	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.638
1552	1164	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.647
1553	1187	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.655
1554	1163	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.662
1555	1155	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.671
1557	1225	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.693
1120	1211	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.701
1559	1072	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.71
1562	1136	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.735
1563	1232	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.745
1564	1052	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.753
1565	1226	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.761
1566	1184	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.769
1567	1058	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.782
1568	1143	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.791
1569	1128	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.8
1570	1165	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.808
1571	1114	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.817
1572	1160	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.825
1573	1124	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.834
1574	1126	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.843
1575	1242	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.852
1174	1298	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Trần Khánh Vy	86	2025-09-18 11:21:39.86
1175	1261	2025-09-18	thursday	t	Manual Present Entry - Đỗ Quốc Việt	86	2025-09-18 11:21:49.9
1176	109	2025-09-18	thursday	t	Manual Present Entry - Ngô Ngọc Ánh	86	2025-09-18 11:22:07.928
1180	1079	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Ngọc Thanh Thảo	86	2025-09-18 11:22:43.689
1181	813	2025-09-18	thursday	t	Manual Present Entry - Lương Thiện Nhi	90	2025-09-18 11:23:20.701
1182	1139	2025-09-18	thursday	t	Manual Present Entry - Bùi Đức Thuận	90	2025-09-18 11:24:35.105
1183	85	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.684
1184	181	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.687
1185	236	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.69
1186	258	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.692
1187	249	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.694
1188	277	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.697
1189	345	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.699
1190	339	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.701
1191	381	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.704
1192	431	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.706
1193	486	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.708
1194	500	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.711
1196	595	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.714
1197	762	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.717
1198	847	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.72
1199	928	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.722
1200	1061	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.724
1201	1110	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.726
1202	1095	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.728
1203	1245	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.73
1204	1001	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.732
1205	848	2025-09-18	thursday	t	Universal QR Scan	18	2025-09-18 11:26:48.734
1210	46	2025-09-18	thursday	t	Manual attendance marking	1	2025-09-18 12:49:14.136
1206	370	2025-09-18	thursday	t	Manual attendance marking	1	2025-09-18 12:49:14.138
1215	797	2025-09-18	thursday	t	Manual Present Entry - Phạm Thành Nhân	90	2025-09-18 13:20:48.369
1217	896	2025-09-18	thursday	t	Manual Present Entry - Phạm Nguyễn Duy Phong	90	2025-09-18 13:21:07.106
1218	963	2025-09-18	thursday	t	Manual Present Entry - Trần Minh Quang	90	2025-09-18 13:21:15.538
1220	1217	2025-09-18	thursday	t	Manual Present Entry - Vũ Phan Minh Trí	90	2025-09-18 13:21:36.434
1221	1049	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Lê Đức Tuấn	90	2025-09-18 13:21:46.666
1222	1148	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Hoàng Tú Thuyên	12	2025-09-18 13:34:11.045
1223	1080	2025-09-18	thursday	t	Manual Present Entry - Trần Hương Thảo	12	2025-09-18 13:34:22.342
1225	56	2025-09-21	sunday	t	QR Scan - Maria Hoang Nguyen Tu Anh	92	2025-09-21 03:15:37.557
1226	878	2025-09-18	thursday	t	Manual web attendance	13	2025-09-19 04:08:28.886
1227	29	2025-09-19	thursday	t	QR Scan - Maria Nguyen Phuong Thuy An	87	2025-09-19 11:04:39.873
1228	119	2025-09-19	thursday	t	QR Scan - Maria Nguyen Heng An	87	2025-09-19 11:04:45.509
1229	934	2025-09-19	thursday	t	QR Scan - Teresa Phan Ngac Heng Phuc	87	2025-09-19 11:04:48.425
1230	492	2025-09-19	thursday	t	Manual Present Entry - Vũ Trọng Khang	87	2025-09-19 11:04:58.268
1231	640	2025-09-19	thursday	t	QR Scan - Giuse Hoang Nhet Minh	87	2025-09-19 11:05:02.025
1232	950	2025-09-19	thursday	t	QR Scan - Maria Teresa Nguyen Quynh Mai Phuong	87	2025-09-19 11:05:05.244
1233	125	2025-09-19	thursday	t	QR Scan - Anphongxo Maria Nguyen Thien An	87	2025-09-19 11:05:08.204
1234	1337	2025-09-19	thursday	t	QR Scan - Maria Vu Nguyen Hai Yen	87	2025-09-19 11:05:10.863
1235	587	2025-09-19	thursday	t	QR Scan - Teresa Nguyen Vu Thao Linh	87	2025-09-19 11:05:13.547
1236	426	2025-09-19	thursday	t	QR Scan - Maria Phem Hoang Thien Huong	92	2025-09-19 11:05:15.171
1237	556	2025-09-19	thursday	t	QR Scan - Maria Nguyen Hoang Quynh Lam	87	2025-09-19 11:05:16.192
1238	720	2025-09-19	thursday	t	QR Scan - Teresa Nguyen Vu Khanh Ngan	87	2025-09-19 11:05:19.081
1239	445	2025-09-19	thursday	t	QR Scan - Maria Phem Hoang Thien Kim	92	2025-09-19 11:05:19.471
1240	63	2025-09-19	thursday	t	QR Scan - Maria Le Phem Phuong Anh	92	2025-09-19 11:05:23.542
1241	1295	2025-09-19	thursday	t	QR Scan - Maria Nguyen Ngoc Tuong Vy	92	2025-09-19 11:05:26.359
1242	1072	2025-09-19	thursday	t	QR Scan - Phero Nguyen Tien Thanh	92	2025-09-19 11:05:28.92
1243	87	2025-09-19	thursday	t	QR Scan - Madalena Phem Huenh Quenh Anh	92	2025-09-19 11:05:32.622
1244	30	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Quốc An	87	2025-09-19 11:05:32.827
1245	96	2025-09-19	thursday	t	QR Scan - Giuse Tren Khac Tinh Anh	87	2025-09-19 11:05:37.618
1246	49	2025-09-19	thursday	t	QR Scan - Rosa Ao The Kim Anh	92	2025-09-19 11:05:41.12
1247	989	2025-09-19	thursday	t	QR Scan - Anna Nguyen Ngoc Duy Quyen	92	2025-09-19 11:05:44.082
1248	1241	2025-09-19	thursday	t	QR Scan - Teresa Nguyen Ngac Duy Uyen	92	2025-09-19 11:05:46.601
1249	306	2025-09-19	thursday	t	QR Scan - Maria Nguyen Heng Henh	87	2025-09-19 11:05:46.709
1250	850	2025-09-19	thursday	t	QR Scan - Madalena Nguyen Thi Bao Nhu	92	2025-09-19 11:05:49.313
1251	860	2025-09-19	thursday	t	QR Scan - Giuse Am Viet Phat	87	2025-09-19 11:05:50.747
1252	200	2025-09-19	thursday	t	QR Scan - Anton Nguyen Thanh Danh	92	2025-09-19 11:05:52.025
1253	344	2025-09-19	thursday	t	QR Scan - Maria Pham Nguyen Gia Han	87	2025-09-19 11:05:54.74
1254	864	2025-09-19	thursday	t	QR Scan - Giuse Le Gia Phat	92	2025-09-19 11:05:55.676
1255	1056	2025-09-19	thursday	t	QR Scan - Anna Nguyen Minh Kim Tuyen	87	2025-09-19 11:05:57.915
1256	924	2025-09-19	thursday	t	QR Scan - Giuse Luong Hoang Phuc	92	2025-09-19 11:05:58.75
1257	1191	2025-09-19	thursday	t	QR Scan - Maria Truong Pham Minh Thy	92	2025-09-19 11:06:01.205
1258	622	2025-09-19	thursday	t	QR Scan - Philipphe Nguyen Hau Luong	87	2025-09-19 11:06:01.39
1259	607	2025-09-19	thursday	t	QR Scan - Toma Nguyen Hau Long	87	2025-09-19 11:06:03.557
1260	800	2025-09-19	thursday	t	QR Scan - Gioan Baotixita Le Quang Nhat	92	2025-09-19 11:06:04.45
1261	922	2025-09-19	thursday	t	QR Scan - Giuse Le Huu Phuc	87	2025-09-19 11:06:08.305
1262	767	2025-09-19	thursday	t	QR Scan - Maria Vu The Anh Ngac	92	2025-09-19 11:06:10.784
1263	485	2025-09-19	thursday	t	QR Scan - Phanxico Tren Huy Khang	87	2025-09-19 11:06:10.984
1264	1094	2025-09-19	thursday	t	QR Scan - Giuse Phem Nhet Thien	87	2025-09-19 11:06:14.173
1265	1247	2025-09-19	thursday	t	QR Scan - Madalena Phem Kiau Van Uyen	92	2025-09-19 11:06:14.902
1266	187	2025-09-19	thursday	t	QR Scan - Maria Nguyen Ngoc Bao Chau	92	2025-09-19 11:06:20.445
1267	1299	2025-09-19	thursday	t	QR Scan - Teresa Pham Hoang Yen Vy	92	2025-09-19 11:06:27.233
1268	681	2025-09-19	thursday	t	QR Scan - Maria Nguyen Ngoc Tra My	92	2025-09-19 11:06:30.349
1269	437	2025-09-19	thursday	t	QR Scan - Tren Anh Kiet	92	2025-09-19 11:06:34.551
1270	443	2025-09-19	thursday	t	QR Scan - Teresa Nguyen Thien Kim	92	2025-09-19 11:06:36.812
1271	954	2025-09-19	thursday	t	QR Scan - Teresa Tren Nha Phuong	92	2025-09-19 11:06:39.987
1272	868	2025-09-19	thursday	t	Manual web attendance	87	2025-09-19 11:06:42.736
1273	953	2025-09-19	thursday	t	QR Scan - Anne Tren Bao Phuong	92	2025-09-19 11:06:43.071
1274	563	2025-09-19	thursday	t	QR Scan - Maria Bui Me Lan	92	2025-09-19 11:06:49.549
1275	1034	2025-09-19	thursday	t	Manual Present Entry - Trần Vũ Bảo Tiên	87	2025-09-19 11:06:53.173
1276	886	2025-09-19	thursday	t	QR Scan - Giuse Oan Chen Phong	92	2025-09-19 11:06:54.309
1277	1002	2025-09-19	thursday	t	QR Scan - Maria Tren Mai Nhu Quenh	92	2025-09-19 11:06:56.737
1278	593	2025-09-19	thursday	t	QR Scan - Teresa Vu Khanh Linh	92	2025-09-19 11:06:59.9
1279	812	2025-09-19	thursday	t	QR Scan - Maria Luong Ngac Uyen Nhi	92	2025-09-19 11:07:02.91
1280	1335	2025-09-19	thursday	t	QR Scan - Maria Pham Ngoc Hai Yen	87	2025-09-19 11:07:03.326
1281	300	2025-09-19	thursday	t	QR Scan - Cecilia Phem Duong Thuy Ha	92	2025-09-19 11:07:07.39
1282	544	2025-09-19	thursday	t	QR Scan - Micae Pham Minh Khoi	87	2025-09-19 11:07:07.594
1283	751	2025-09-19	thursday	t	QR Scan - Maria Nguyen Le Bao Ngoc	92	2025-09-19 11:07:09.39
1284	1232	2025-09-19	thursday	t	QR Scan - Giuse Ngo Xuan Trueng	87	2025-09-19 11:07:09.724
1285	454	2025-09-19	thursday	t	QR Scan - Phaolo Truong Quang Khai	87	2025-09-19 11:07:12.127
1286	906	2025-09-19	thursday	t	QR Scan - Giuse Nguyen Hau Gia Phu	87	2025-09-19 11:07:14.826
1287	1254	2025-09-19	thursday	t	QR Scan - Maria Nguyen Le Bao Van	92	2025-09-19 11:07:15.576
1288	499	2025-09-19	thursday	t	QR Scan - Maria Oan Nguyen Gia Khanh	87	2025-09-19 11:07:17.224
1289	1276	2025-09-19	thursday	t	QR Scan - Michael Vu Anh Vu	92	2025-09-19 11:07:18.342
1290	84	2025-09-19	thursday	t	QR Scan - Maria Nguyen Xuan Anh	87	2025-09-19 11:07:19.618
1291	1155	2025-09-19	thursday	t	QR Scan - Anna Nguyen Anh Thu	87	2025-09-19 11:07:22.268
1292	1136	2025-09-19	thursday	t	QR Scan - Ysave Nguyen Ngac Bao Tho	87	2025-09-19 11:07:24.673
1293	993	2025-09-19	thursday	t	QR Scan - Anna Tran Mai Nhat Quyen	87	2025-09-19 11:07:27.395
1294	887	2025-09-19	thursday	t	QR Scan - Phanxico Xavie Hoang Nam Phong	87	2025-09-19 11:07:30.765
1295	1161	2025-09-19	thursday	t	QR Scan - Maria Nguyen Ngoc Anh Thu	92	2025-09-19 11:07:32.45
1296	405	2025-09-19	thursday	t	QR Scan - Giuse Tren Minh Huy	87	2025-09-19 11:07:34.529
1297	270	2025-09-19	thursday	t	QR Scan - Gierado Truong Phem Minh Ang	87	2025-09-19 11:07:37.198
1298	687	2025-09-19	thursday	t	QR Scan - Maria Pham Ngoc Diem My	92	2025-09-19 11:07:38.256
1299	1037	2025-09-19	thursday	t	QR Scan - Benado Nguyen Minh Tien	87	2025-09-19 11:07:39.833
1301	1116	2025-09-19	thursday	t	QR Scan - Phero Phem Chi Thien	92	2025-09-19 11:07:56.263
1302	348	2025-09-19	thursday	t	QR Scan - Maria Thach Ngac Han	92	2025-09-19 11:08:00.759
1303	958	2025-09-19	thursday	t	QR Scan - Maria Do Ngoc Phuong	92	2025-09-19 11:08:19.578
1304	436	2025-09-19	thursday	t	Manual web attendance	87	2025-09-19 11:08:26.365
1305	666	2025-09-19	thursday	t	QR Scan - Da Minh Vu Dinh Gia Minh	87	2025-09-19 11:08:30.403
1306	920	2025-09-19	thursday	t	QR Scan - Giuse Lam Bao Phuc	87	2025-09-19 11:08:33.465
1307	1172	2025-09-19	thursday	t	QR Scan - Maria Tran Minh Thu	87	2025-09-19 11:08:36.42
1308	790	2025-09-19	thursday	t	QR Scan - Giuse Le Nguyen	87	2025-09-19 11:08:39.333
1309	457	2025-09-19	thursday	t	QR Scan - Anton E Gia Khang	87	2025-09-19 11:08:42.791
1310	771	2025-09-19	thursday	t	QR Scan - Maria Le An Nguyen	87	2025-09-19 11:08:48.384
1311	665	2025-09-19	thursday	t	QR Scan - Tren Phan Quang Minh	87	2025-09-19 11:08:53.47
1312	927	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Hoài Phúc	92	2025-09-19 11:08:53.611
1313	1306	2025-09-19	thursday	t	QR Scan - Anna Phan The Tueng Vy	87	2025-09-19 11:08:56.466
1314	1308	2025-09-19	thursday	t	QR Scan - Lucia Te Luu Yen Vy	87	2025-09-19 11:08:59.385
1315	983	2025-09-19	thursday	t	Manual Present Entry - Lâm Ngọc Quý	92	2025-09-19 11:09:02.14
1316	181	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Thành Công	92	2025-09-19 11:09:10.221
1317	48	2025-09-19	thursday	t	QR Scan - Maria Am Tren Tram Anh	87	2025-09-19 11:09:12.738
1318	716	2025-09-19	thursday	t	QR Scan - Maria Nguyen Gia Ngan	87	2025-09-19 11:09:15.075
1319	441	2025-09-19	thursday	t	QR Scan - Maria Luong Gia Kim	87	2025-09-19 11:09:17.495
1320	182	2025-09-19	thursday	t	Manual Present Entry - Đào Việt Cường	92	2025-09-19 11:09:18.378
1321	1213	2025-09-19	thursday	t	Manual Present Entry - Phạm Đắc Minh Trí	92	2025-09-19 11:09:26.917
1322	866	2025-09-19	thursday	t	Manual Present Entry - Lê Sỹ Gia Phát	92	2025-09-19 11:09:36.431
1323	379	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Văn Hoàng	92	2025-09-19 11:09:49.774
1324	638	2025-09-19	thursday	t	Manual Present Entry - Đào Thị Ánh Minh	87	2025-09-19 11:10:04.416
1325	1134	2025-09-19	thursday	t	Manual Present Entry - Đặng Văn Thọ	87	2025-09-19 11:11:13.038
1326	1011	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Trần Thanh Sang	92	2025-09-19 11:11:19.708
1327	659	2025-09-19	thursday	t	Manual Present Entry - Phạm Tuấn Minh	92	2025-09-19 11:11:26.025
1328	343	2025-09-19	thursday	t	Manual Present Entry - Phạm Ngọc Hân	87	2025-09-19 11:11:26.283
1329	475	2025-09-19	thursday	t	Manual Present Entry - Phạm Anh Khang	92	2025-09-19 11:11:32.776
1330	97	2025-09-19	thursday	t	Manual Present Entry - Trần Mai Quỳnh Anh	92	2025-09-19 11:11:42.385
1331	204	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Diệp Hân Di	87	2025-09-19 11:11:44.795
1332	192	2025-09-19	thursday	t	Manual Present Entry - Ngô Lan Chi	92	2025-09-19 11:11:48.885
1333	484	2025-09-19	thursday	t	QR Scan - Vinh Son Tran Gia Khang	87	2025-09-19 11:11:51.403
1334	693	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Thanh Du Mỹ	87	2025-09-19 11:12:05.382
1335	193	2025-09-19	thursday	t	Manual Present Entry - Ngô Phương Chi	92	2025-09-19 11:12:13.187
1337	1212	2025-09-19	thursday	t	Manual web attendance	87	2025-09-19 11:12:45.571
1338	170	2025-09-19	thursday	t	Manual Present Entry - Vũ Thiên Bảo	87	2025-09-19 11:13:30.077
1339	1226	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Như Trúc	87	2025-09-19 11:13:39.582
1340	1253	2025-09-19	thursday	t	Manual Present Entry - Bùi Ngọc Thiên Vân	87	2025-09-19 11:13:47.857
1341	895	2025-09-19	thursday	t	Manual Present Entry - Phạm Lê Hoàng Phong	92	2025-09-19 11:14:02.324
1342	146	2025-09-19	thursday	t	Manual Present Entry - Lương Gia Bảo	92	2025-09-19 11:14:12.266
1343	566	2025-09-19	thursday	t	Manual Present Entry - Phạm Thị Ngọc Lan	87	2025-09-19 11:14:13.835
1344	808	2025-09-19	thursday	t	Manual Present Entry - Đinh Thảo Nhi	92	2025-09-19 11:14:19.219
1345	532	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Anh Khôi	87	2025-09-19 11:14:23.546
1346	1257	2025-09-19	thursday	t	Manual Present Entry - Trần Thanh Vân	92	2025-09-19 11:14:32.063
1347	1339	2025-09-19	thursday	t	Manual Present Entry - Vũ Ngọc Phương Trinh	92	2025-09-19 11:14:41.953
1348	26	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Ngọc Bảo An	87	2025-09-19 11:15:26.581
1349	25	2025-09-19	thursday	t	Manual Present Entry - Nguyễn Ngọc Bảo An	87	2025-09-19 11:15:28.677
1350	189	2025-09-19	thursday	t	Manual web attendance	87	2025-09-19 11:15:47.426
1576	1241	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.861
1577	1245	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.871
1578	1292	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.879
1579	1279	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.888
1580	1254	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:22.897
1646	427	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.486
1647	345	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.495
1648	300	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.505
1649	426	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.512
1650	524	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.519
1651	478	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.526
1652	129	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.534
1653	101	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.542
1654	104	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.551
1655	38	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.558
1656	102	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.566
1657	94	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.574
1658	98	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.581
1659	36	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.589
1660	162	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.597
1661	176	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.606
1662	161	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.614
1663	165	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.622
1664	166	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.635
1665	173	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.646
1666	240	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.654
1667	269	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.663
1668	220	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.672
1670	279	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.689
1671	262	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.696
1672	259	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.705
1673	248	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.713
1675	480	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.73
1677	437	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.745
1678	488	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.754
1679	479	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.761
1680	482	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.768
1681	504	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.775
1682	561	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.783
1683	575	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.791
1684	560	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.799
1685	663	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.808
1686	665	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.815
1687	855	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.826
1689	830	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.842
1690	724	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.85
1691	733	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.858
1692	759	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.865
1693	723	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.875
1694	786	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.886
1695	824	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.894
1696	704	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.902
1697	825	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.91
1698	761	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.919
1700	953	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.934
1701	877	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.944
637	938	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.955
1703	954	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:23.98
1704	1002	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.005
1705	995	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.024
1706	1175	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.032
1707	1171	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.043
844	1118	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.058
1709	1101	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.071
1710	1102	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.089
1711	1221	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.107
1712	1080	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.114
1713	1096	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.127
1714	1069	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.134
1773	847	2025-09-11	thursday	t	Manual web attendance	18	2025-09-20 04:08:44.521
1715	1172	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.141
1716	1099	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.148
1717	1082	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.155
1718	1034	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.161
1719	1039	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.168
1720	1314	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.176
1721	1313	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.184
1722	1315	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.191
1723	1271	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.197
1724	303	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.204
1725	351	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.22
1726	353	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.228
1727	404	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.236
1728	354	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.243
1097	108	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.251
1730	41	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.259
1731	170	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.267
1734	213	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.289
1735	233	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.297
1736	357	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.305
1737	428	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.316
1738	421	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.328
1739	381	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.339
1107	505	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.347
1741	577	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.356
1743	578	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.373
1746	667	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.398
336	789	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.406
1749	767	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.424
1750	708	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.431
1751	726	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.439
1752	832	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.446
1753	831	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.454
1754	706	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.462
1755	941	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.471
1115	957	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.48
1757	940	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.489
1758	880	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.503
1759	1004	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.511
1760	1075	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.519
1761	1179	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.527
1762	1085	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.534
1764	1103	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.549
1765	1027	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.556
1766	1249	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.564
1767	1316	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.573
1768	1319	2025-09-14	sunday	t	Import từ Excel - Copy of GL1409.xlsx (8/9/2025 - 14/9/2025)	1	2025-09-19 15:36:24.582
1775	1154	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:09:06.857
1776	1316	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:10:44.891
1777	710	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:11:21.6
1778	308	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:11:57.818
1779	1069	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:12:25.141
1780	672	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:14:07.937
1781	960	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:14:14.989
1782	1003	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:16:47.346
1783	572	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:17:22.433
1784	294	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:17:57.937
1785	1224	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:18:11.159
1786	846	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:20:56.774
1787	828	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:24:30.498
1788	12	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 06:31:48.619
1790	639	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:13:29.181
1791	655	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:15:42.659
1792	1054	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:16:29.014
1793	262	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:17:02.819
1794	1128	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:21:26.584
1795	711	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:22:17.946
1796	968	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:22:33.105
1797	375	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:22:52.937
1798	509	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:24:56.721
1799	207	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:25:19.402
1800	336	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:25:40.914
1801	783	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:26:27.866
1802	260	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:27:30.647
1803	1126	2025-09-18	thursday	t	Manual web attendance	69	2025-09-20 08:28:08.52
1806	384	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:30:09.442
1807	805	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:30:50.455
1808	1327	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:31:15.626
1809	196	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:31:32.696
1810	897	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:31:49.396
1811	37	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:32:12.936
1812	488	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:32:27.936
1813	1300	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:32:56.849
1814	1278	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:33:14.858
1815	909	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:33:37.852
1816	521	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:34:04.541
1817	143	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:34:28.241
1818	1342	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:34:51.334
1821	420	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:36:01.738
1823	351	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:36:45.755
1824	872	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:37:19.832
1825	290	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 11:37:37.649
1826	570	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:21:16.016
1827	1200	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:21:30.841
1828	974	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:21:51.041
1829	980	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:23:26.198
1830	645	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:24:25.28
1831	936	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:24:43.621
1832	731	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:24:58.356
1833	275	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:25:34.758
1834	542	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:25:57.606
1835	1019	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:26:13.015
1836	208	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:29:13.027
1837	1271	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:29:48.647
1838	618	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:30:27.407
1839	363	2025-09-18	thursday	t	Manual web attendance	52	2025-09-20 13:30:57.373
1841	24	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Minh An	73	2025-09-20 16:46:52.264
1842	1290	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Hoàng Uyên Vy	73	2025-09-20 16:47:24.539
1843	448	2025-09-18	thursday	t	Manual Present Entry - WongThiên Kim	73	2025-09-20 16:47:38.676
1844	984	2025-09-18	thursday	t	Manual Present Entry - Nguyễn Lệ Quý	73	2025-09-20 16:47:55.711
1846	71	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.757
759	387	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.765
742	229	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.769
741	208	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.771
745	337	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.774
748	422	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.777
747	395	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.779
749	455	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.782
750	649	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.784
751	694	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.786
753	738	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.788
752	716	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.79
755	1146	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.792
756	1174	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.794
757	1297	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.797
760	563	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.799
746	343	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.802
1870	1350	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.805
1871	1352	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.808
1845	33	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.81
1847	1351	2025-09-14	sunday	t	Mark all present	15	2025-09-20 16:57:02.812
1874	1159	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:00:48.667
1875	1205	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:00:52.947
1876	629	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:01:06.584
1877	298	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:01:16.18
1878	758	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:01:33.349
1879	326	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:02:14.62
1880	633	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:02:31.303
1881	766	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:02:40.738
1882	1339	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:02:53.077
1883	958	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:03:14.953
1884	567	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:03:29.063
1885	185	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:03:46.929
1886	117	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:03:55.008
1887	904	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:04:03.731
1888	1276	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:04:21.643
1889	451	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:04:35.245
1890	1273	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:04:40.166
1891	728	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:05:00.925
1892	574	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:05:15.613
1893	997	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:05:25.455
1894	1145	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:05:30.193
1895	685	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 00:06:25.702
1896	25	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:09:50.891
1897	30	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:09:53.012
1898	40	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:09:57.42
1899	44	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:06.263
1900	61	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:09.094
1901	84	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:13.78
1902	167	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:20.02
1903	292	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:21.943
1904	321	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:25.721
1905	328	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:28.556
1906	344	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:32.671
1907	453	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:34.989
1908	489	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:38.873
1909	499	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:41.991
1910	517	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:10:46.59
1911	631	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:07.957
1912	736	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:10.858
1913	742	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:13.818
1914	792	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:27.067
1915	836	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:30.314
1916	848	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:33.295
1917	710	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:36.142
1918	875	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:39.292
1919	885	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:41.593
1920	920	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:46.894
1921	989	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:50.362
1922	1109	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:56.614
1923	1121	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:11:59.472
1924	1162	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:12:02.835
1925	1223	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:12:05.417
1926	1253	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:12:09.095
1927	1323	2025-09-21	sunday	t	Manual web attendance	59	2025-09-21 00:12:13.035
1928	1331	2025-09-21	sunday	t	QR Scan - Maria Luu Nguyen Hai Yen	28	2025-09-21 00:49:22.921
1929	309	2025-09-21	sunday	t	QR Scan - Maria Nguyen Minh Heng	28	2025-09-21 00:49:31.112
1930	729	2025-09-21	sunday	t	QR Scan - Maria Dinh Pham Thao Nghi	28	2025-09-21 00:49:40.535
1931	192	2025-09-21	sunday	t	QR Scan - Maria Ngo Lan Chi	28	2025-09-21 00:50:22.865
1932	1149	2025-09-21	sunday	t	QR Scan - Maria Cao Song Thu	28	2025-09-21 00:50:25.623
1933	1014	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Trung Son	28	2025-09-21 00:50:29.741
1934	719	2025-09-21	sunday	t	QR Scan - Matta Nguyen Thi Kim Ngan	28	2025-09-21 00:50:40.567
1935	484	2025-09-21	sunday	t	QR Scan - Vinh Son Tran Gia Khang	28	2025-09-21 00:51:10.017
1936	593	2025-09-21	sunday	t	QR Scan - Teresa Vu Khanh Linh	28	2025-09-21 00:51:27.693
1937	88	2025-09-21	sunday	t	QR Scan - Pham Nguyen Hai Anh	28	2025-09-21 00:51:28.663
1938	1278	2025-09-21	sunday	t	QR Scan - Phaolo Do Thien Vuong	28	2025-09-21 00:51:35.551
1939	301	2025-09-21	sunday	t	QR Scan - Agnes Phem Khanh Ha	28	2025-09-21 00:51:45.236
1940	450	2025-09-21	sunday	t	QR Scan - Phaolo Tren Heng Ke	28	2025-09-21 00:51:52.167
1941	1123	2025-09-21	sunday	t	QR Scan - Phaolo Luu Khanh Hung Thenh	28	2025-09-21 00:52:03.126
1942	1312	2025-09-21	sunday	t	QR Scan - Maria Tren Ngac Thao Vy	28	2025-09-21 00:52:21.758
1943	612	2025-09-21	sunday	t	QR Scan - Gioan Baotixita Phung Bao Long	28	2025-09-21 00:52:34.559
1944	695	2025-09-21	sunday	t	QR Scan - Gioakim Do Bao Nam	28	2025-09-21 00:52:39.175
1945	168	2025-09-21	sunday	t	Manual Present Entry - Trịnh Hiếu Bảo	28	2025-09-21 00:54:51.267
1946	1087	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Tạ Mạnh Thắng	20	2025-09-21 01:01:48.028
1947	797	2025-09-21	sunday	t	Manual Present Entry - Phạm Thành Nhân	20	2025-09-21 01:01:58.357
1953	942	2025-09-21	sunday	t	Manual Present Entry - Vũ Nguyễn Bảo Phúc	20	2025-09-21 01:02:43.54
1962	250	2025-09-21	sunday	t	Manual Present Entry - Trần Thùy Linh Đan	20	2025-09-21 01:03:37.947
1963	854	2025-09-21	sunday	t	Manual Present Entry - Trần Ngọc Quỳnh Như	20	2025-09-21 01:03:52.625
1965	55	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:05:54.374
1966	112	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:07.664
1967	151	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:17.42
1968	231	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:27.667
1969	288	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:30.388
1970	289	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:36.159
1971	308	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:39.691
1972	1257	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 01:06:40.602
1973	390	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:52.672
1974	459	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:56.18
1975	476	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:06:58.425
1976	516	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:04.468
1977	380	2025-09-21	sunday	t	Manual web attendance	49	2025-09-21 01:07:07.415
1978	615	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:10.227
1979	896	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:13.469
1980	1020	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:19.389
1981	1098	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:22.745
1982	1140	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:25.698
1983	1199	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:27.769
1984	1213	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:30.738
1985	1045	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:37.476
1986	1267	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:43.226
1987	1322	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:47.547
1988	1336	2025-09-21	sunday	t	Manual web attendance	34	2025-09-21 01:07:51.514
1993	1282	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:17:07.593
1995	1229	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:17:33.26
1996	38	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:17:44.357
1998	561	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:17:54.181
2000	566	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:18:01.425
2004	63	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:18:13.098
2007	723	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:18:27.627
2010	276	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:18:55.095
2014	1099	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:19:09.497
2020	420	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:19:27.12
2021	304	2025-09-21	sunday	t	QR Scan - Maria Tren Ngac Khanh Ha	73	2025-09-21 02:19:33.046
2023	350	2025-09-21	sunday	t	QR Scan - Maria Tran Hoang Gia Han	73	2025-09-21 02:19:36.223
2025	1055	2025-09-21	sunday	t	QR Scan - Matheu Tran Thanh Tung	73	2025-09-21 02:19:38.815
2026	544	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:19:43.973
2027	418	2025-09-21	sunday	t	QR Scan - Gioakim Tran Tuan Hung	73	2025-09-21 02:19:48.514
2029	506	2025-09-21	sunday	t	QR Scan - Phero Dang Lam Gia Khiem	73	2025-09-21 02:19:52.68
2032	800	2025-09-21	sunday	t	QR Scan - Gioan Baotixita Le Quang Nhat	73	2025-09-21 02:19:55.552
2033	1232	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:19:56.209
2035	96	2025-09-21	sunday	t	QR Scan - Giuse Tren Khac Tinh Anh	73	2025-09-21 02:20:01.24
2036	201	2025-09-21	sunday	t	QR Scan - Phanxico Xavie Nguyen Thanh Danh	73	2025-09-21 02:20:05.014
2039	169	2025-09-21	sunday	t	QR Scan - Vinh Son Trenh Thien Bao	73	2025-09-21 02:20:12.751
2040	597	2025-09-21	sunday	t	QR Scan - Giuse Bui Gia Long	73	2025-09-21 02:20:15.721
2042	460	2025-09-21	sunday	t	QR Scan - Phero Le Phuc Khang	73	2025-09-21 02:20:18.162
2043	1268	2025-09-21	sunday	t	QR Scan - Anton Gp Ii Le Hoang Quang Vinh	47	2025-09-21 02:20:19.111
2045	1049	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Le Duc Tuan	73	2025-09-21 02:20:21.14
2046	1208	2025-09-21	sunday	t	QR Scan - Phero Hoang Anh Tri	73	2025-09-21 02:20:24.449
2049	507	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:20:28.554
2050	524	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:20:30.292
2051	618	2025-09-21	sunday	t	QR Scan - A Minh Phem Phat Lac	47	2025-09-21 02:20:30.331
2052	864	2025-09-21	sunday	t	QR Scan - Giuse Le Gia Phat	47	2025-09-21 02:20:35.081
2055	195	2025-09-21	sunday	t	QR Scan - Maria Nguyen Linh Chi	47	2025-09-21 02:20:44.116
2058	614	2025-09-21	sunday	t	QR Scan - Phaolo Trenh Vu Long	73	2025-09-21 02:20:49.258
2059	784	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Phuc Nguyen	73	2025-09-21 02:20:51.554
2060	677	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:20:53.029
2061	410	2025-09-21	sunday	t	QR Scan - Giuse Vuong Gia Huy	73	2025-09-21 02:20:54.473
2062	383	2025-09-21	sunday	t	QR Scan - Maria E Ngac Heng	42	2025-09-21 02:20:55.35
2063	1028	2025-09-21	sunday	t	QR Scan - Maria Iau Hoang Lan Tien	47	2025-09-21 02:20:57.531
2064	1032	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:20:58.218
2068	671	2025-09-21	sunday	t	QR Scan - Anna Giong Thi Tra My	42	2025-09-21 02:21:03.82
2069	1136	2025-09-21	sunday	t	QR Scan - Ysave Nguyen Ngac Bao Tho	47	2025-09-21 02:21:04.089
2070	435	2025-09-21	sunday	t	QR Scan - Anton Phem Ha Anh Kiet	73	2025-09-21 02:21:05.554
2071	853	2025-09-21	sunday	t	QR Scan - Teresa Tran My Nhu	42	2025-09-21 02:21:06.48
2072	910	2025-09-21	sunday	t	QR Scan - Da Minh Vu Nguyen Gia Phu	73	2025-09-21 02:21:07.191
2073	994	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:21:07.831
2074	319	2025-09-21	sunday	t	QR Scan - Maria Doan Nguyen Gia Han	42	2025-09-21 02:21:08.869
2075	1072	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:21:10.143
2008	280	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.204
2022	522	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.209
2037	419	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.211
2015	215	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.216
2006	986	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.22
2057	826	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.223
2019	496	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.227
1997	1196	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.229
2066	338	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.233
2031	872	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.247
2044	827	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.249
2003	1022	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.253
2012	1040	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.255
2053	1193	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.258
2048	1327	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.26
1999	1201	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.262
2067	1085	2025-09-21	sunday	t	QR Scan - Maria Vu Thanh Thao	47	2025-09-21 02:26:30.514
2077	263	2025-09-21	sunday	t	QR Scan - Da Minh Vu Tien Dat	73	2025-09-21 02:21:11.889
2078	242	2025-09-21	sunday	t	QR Scan - Teresa Do Hai Dan	42	2025-09-21 02:21:12.119
2079	1155	2025-09-21	sunday	t	QR Scan - Anna Nguyen Anh Thu	47	2025-09-21 02:21:13.192
2081	377	2025-09-21	sunday	t	QR Scan - A Minh Nguyen Minh Hoang	73	2025-09-21 02:21:15.695
2083	1161	2025-09-21	sunday	t	QR Scan - Maria Nguyen Ngoc Anh Thu	42	2025-09-21 02:21:16.407
2084	756	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:21:17.331
2085	440	2025-09-21	sunday	t	QR Scan - Maria E Nguyen Thien Kim	47	2025-09-21 02:21:17.542
2086	1066	2025-09-21	sunday	t	QR Scan - Teresa Nguyen Doan Dan Thanh	42	2025-09-21 02:21:20.711
2088	1247	2025-09-21	sunday	t	QR Scan - Madalena Phem Kiau Van Uyen	47	2025-09-21 02:21:21.532
2089	626	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:21:22.169
2090	1007	2025-09-21	sunday	t	QR Scan - Teresa Linh Ngac An Sa	42	2025-09-21 02:21:22.363
2091	596	2025-09-21	sunday	t	QR Scan - Maria Phem The Bich Loan	73	2025-09-21 02:21:22.524
2092	1225	2025-09-21	sunday	t	QR Scan - Maria Nguyen Hoang Thanh Truc	47	2025-09-21 02:21:25.284
2093	892	2025-09-21	sunday	t	QR Scan - Gioan Baotixita Nguyen Tuen Phong	47	2025-09-21 02:21:27.121
2094	421	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:21:29.512
2095	188	2025-09-21	sunday	t	QR Scan - Maria Nguyen Ngoc Bao Chau	73	2025-09-21 02:21:29.873
2096	318	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:21:30.354
2097	223	2025-09-21	sunday	t	QR Scan - Micae Le Trang Bao Duy	47	2025-09-21 02:21:30.901
2098	1053	2025-09-21	sunday	t	QR Scan - Giuse Oan Quac Tung	47	2025-09-21 02:21:33.054
2099	1239	2025-09-21	sunday	t	QR Scan - Maria He Oan Phuong Uyen	73	2025-09-21 02:21:33.555
2100	623	2025-09-21	sunday	t	QR Scan - Maria Nguyen Khanh Ly	73	2025-09-21 02:21:37.077
2102	1079	2025-09-21	sunday	t	QR Scan - Maria Nguyen Ngac Thanh Thao	73	2025-09-21 02:21:41.43
2104	1026	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:21:41.872
2105	818	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:21:41.985
2106	737	2025-09-21	sunday	t	QR Scan - Maria Inh Bao Ngac	73	2025-09-21 02:21:45.794
2107	768	2025-09-21	sunday	t	QR Scan - Phaolo Bui Hau Nguyen	47	2025-09-21 02:21:46.933
2108	1191	2025-09-21	sunday	t	QR Scan - Maria Truong Pham Minh Thy	42	2025-09-21 02:21:47.009
2109	1166	2025-09-21	sunday	t	QR Scan - Maria Nguyen Vu Kim Thu	73	2025-09-21 02:21:48.173
2110	1335	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:21:48.562
2111	172	2025-09-21	sunday	t	QR Scan - Teresa Ngo Khanh Bang	42	2025-09-21 02:21:49.458
2112	514	2025-09-21	sunday	t	QR Scan - Emmanuel Nguyen Ang Khoa	47	2025-09-21 02:21:49.591
2113	850	2025-09-21	sunday	t	QR Scan - Madalena Nguyen Thi Bao Nhu	42	2025-09-21 02:21:51.351
2114	295	2025-09-21	sunday	t	QR Scan - Maria Tren Khanh Giang	73	2025-09-21 02:21:52.078
2115	1056	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:21:53.403
2116	146	2025-09-21	sunday	t	QR Scan - A Minh Luong Gia Bao	47	2025-09-21 02:21:54.401
2118	722	2025-09-21	sunday	t	QR Scan - Rosa Trenh Hoang Thuy Ngan	42	2025-09-21 02:21:56.968
2119	578	2025-09-21	sunday	t	QR Scan - Giuse Vu Inh Lam	47	2025-09-21 02:21:57.882
2121	1122	2025-09-21	sunday	t	QR Scan - Vinh Son Huynh Hung Thinh	42	2025-09-21 02:22:00.689
2122	191	2025-09-21	sunday	t	QR Scan - Maria Le Khanh Chi	47	2025-09-21 02:22:01.323
2124	690	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:22:07.69
2125	819	2025-09-21	sunday	t	QR Scan - Teresa Nguyen Truc Nhi	42	2025-09-21 02:22:08.461
2126	358	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.498
2127	52	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.501
2128	372	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.503
2129	956	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.505
2130	1182	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.507
2131	908	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.509
2132	218	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.511
2133	810	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.513
2134	725	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.515
2135	590	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.517
2136	149	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.519
2137	14	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.52
2138	257	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.522
2139	398	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.524
2140	707	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.528
2141	812	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.53
2142	1295	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.532
2143	1298	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.533
2144	23	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:22:09.535
2146	333	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:22:13.987
2148	179	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:22:16.527
2150	521	2025-09-21	sunday	t	Manual Present Entry - Phạm Duy Khoa	73	2025-09-21 02:22:20.743
2152	69	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:22:24.367
2153	905	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:22:24.864
2155	939	2025-09-21	sunday	t	QR Scan - Gioan Baotixita Truong Thien Phuc	42	2025-09-21 02:22:29.729
2156	24	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Minh An	73	2025-09-21 02:22:30.384
2157	41	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:22:30.75
2158	1217	2025-09-21	sunday	t	Manual Present Entry - Vũ Phan Minh Trí	47	2025-09-21 02:22:30.893
2160	962	2025-09-21	sunday	t	QR Scan - Phero Nguyen Vinh Quang	42	2025-09-21 02:22:31.353
2161	945	2025-09-21	sunday	t	QR Scan - Martino Tran Hoang Thien Phuoc	42	2025-09-21 02:22:34.044
2162	322	2025-09-21	sunday	t	QR Scan - Anne Ho Ngoc Han	42	2025-09-21 02:22:35.653
2163	1183	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:22:35.829
2164	549	2025-09-21	sunday	t	QR Scan - Giuse Tran Hoang Minh Khoi	42	2025-09-21 02:22:39.577
2165	367	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Trung Hiau	42	2025-09-21 02:22:42.765
2166	508	2025-09-21	sunday	t	QR Scan - Giuse Do Tan Khoa	42	2025-09-21 02:22:44.373
2167	253	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:22:45.673
2168	1235	2025-09-21	sunday	t	Manual Present Entry - Bùi Phương Uyên	47	2025-09-21 02:22:47.123
2147	724	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.222
2087	732	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.202
2117	658	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.218
2159	1148	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.222
2103	1065	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.225
2149	565	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.235
2076	556	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.241
2169	779	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Minh Nguyên	73	2025-09-21 02:22:47.183
2018	1181	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.206
2028	733	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.208
2173	190	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.211
2030	79	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.212
2175	890	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.215
2176	150	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.217
2034	428	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.225
2154	987	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.229
2005	1047	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.233
2182	1240	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.236
2017	1102	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.238
2038	830	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.24
2056	636	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.242
2013	1092	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.247
2047	306	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.249
2011	550	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.251
2024	617	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.253
2041	1179	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.255
2065	759	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.257
2145	855	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.259
2002	510	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.261
2151	950	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.263
2001	1059	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.265
2101	1241	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.267
2198	1068	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.27
2016	1101	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.271
2009	1279	2025-09-21	sunday	t	Mark all present	61	2025-09-21 02:22:47.275
2203	290	2025-09-21	sunday	t	QR Scan - Da Minh Vu Viet Duc	42	2025-09-21 02:22:48.053
2204	115	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:22:48.837
2207	926	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.207
2208	239	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.209
2211	251	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.213
2212	1156	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.215
2221	92	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.232
2224	523	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.24
2080	587	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.243
2227	748	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.246
2123	1008	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.251
2233	1097	2025-09-21	sunday	t	Mark all present	67	2025-09-21 02:22:52.257
2237	1100	2025-09-21	sunday	t	QR Scan - Anton Tran Nguyen Phuc Thien	42	2025-09-21 02:22:52.351
2238	247	2025-09-21	sunday	t	QR Scan - Giuse Pham Ngoc Huy Dan	42	2025-09-21 02:22:53.714
2239	793	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:22:56.543
2240	927	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:22:58.436
2241	1106	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:23:02.153
2242	1048	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:23:02.747
2243	808	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:23:02.75
1948	463	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.619
1956	851	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.621
1949	1117	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.623
1964	1188	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.625
1957	314	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.627
1959	122	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.629
1954	1334	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.631
1961	299	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.633
1952	545	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.635
1955	630	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.637
1960	680	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.64
1950	909	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.642
1958	1195	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.644
1951	1216	2025-09-21	sunday	t	Universal QR Scan	36	2025-09-21 02:23:04.646
2258	274	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:23:08.091
2259	930	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Thiên Phúc	47	2025-09-21 02:23:09.543
2260	835	2025-09-21	sunday	t	Manual Present Entry - Hoàng Lê Hạo Nhiên	73	2025-09-21 02:23:11.702
2261	437	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:23:17.997
2262	1076	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:23:22.97
2263	640	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:23:25.996
2264	579	2025-09-21	sunday	t	QR Scan - Phanxico Assisi Phem Nguyen Gia Liem	42	2025-09-21 02:23:27.381
2265	709	2025-09-21	sunday	t	QR Scan - Phero Vu Quac Nam	47	2025-09-21 02:23:31.666
2266	619	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:23:33.501
2267	104	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:23:34.166
2268	1023	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:23:44.27
2269	454	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:23:53.941
2270	1265	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Quoc Viet	47	2025-09-21 02:23:55.17
2271	161	2025-09-21	sunday	t	Manual web attendance	11	2025-09-21 02:24:02.941
2272	1094	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:24:05.689
2273	232	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:24:09.164
2274	401	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:24:09.167
2275	672	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:24:09.169
2276	960	2025-09-21	sunday	t	Universal QR Scan	79	2025-09-21 02:24:09.171
2277	705	2025-09-21	sunday	t	QR Scan - Gioan Baotixita Tren Bao Nam	73	2025-09-21 02:24:17.386
2278	868	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:24:20.445
2279	325	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:24:32.053
2290	155	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:25:13.811
2283	963	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:24:40.625
2281	1105	2025-09-21	sunday	t	QR Scan - Aminh Ao Ac Thien	47	2025-09-21 02:25:01.736
2280	1082	2025-09-21	sunday	t	QR Scan - Anna Tren Phuong Thao	47	2025-09-21 02:24:45.38
2286	254	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:24:50.361
2289	982	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:25:04.813
2291	539	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:25:30.57
2292	397	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:25:33.638
2293	1224	2025-09-21	sunday	t	QR Scan - Maria Ho Ngoc Thanh Truc	42	2025-09-21 02:25:35.446
2294	498	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:25:39.885
2295	647	2025-09-21	sunday	t	Manual web attendance	10	2025-09-21 02:25:47.836
2296	294	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Hương Giang	42	2025-09-21 02:26:00.244
2298	804	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Phạm Minh Nhật	42	2025-09-21 02:27:27.563
2353	1069	2025-09-21	sunday	t	Manual web attendance	45	2025-09-21 02:36:28.412
2355	1250	2025-09-21	sunday	t	Manual web attendance	45	2025-09-21 02:36:39.995
2356	1246	2025-09-21	sunday	t	Manual web attendance	45	2025-09-21 02:36:41.172
2357	113	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:40:14.763
2358	126	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:40:15.232
2359	202	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:40:46.293
2360	230	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:40:52.444
2361	272	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:40:56.755
2362	334	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:41:03.415
2363	399	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:42:11.562
2364	462	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:42:23.362
2365	487	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:42:24.422
2366	529	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:42:36.493
2367	518	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:42:49.932
2368	599	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:42:58.438
2369	679	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:43:00.029
2370	734	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:43:00.749
2371	735	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:43:14.692
2372	937	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:43:15.67
2373	957	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:43:17.543
2374	1063	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:43:18.15
2375	1158	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:43:55.882
2376	1258	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:44:19.471
2377	1211	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 02:44:20.6
2378	834	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.006
2379	921	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.011
2380	968	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.015
2381	501	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.017
2382	762	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.02
2383	268	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.023
2384	237	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.025
2385	1115	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.027
2386	1074	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.029
2387	714	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.031
2388	1197	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.033
2389	336	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.035
2390	329	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.037
2391	568	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.039
2392	576	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.041
2393	624	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.043
2394	607	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.045
2395	670	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.047
2396	711	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.049
2397	720	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.051
2398	887	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.053
2399	914	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.055
2400	1272	2025-09-21	sunday	t	Universal QR Scan	88	2025-09-21 03:12:35.057
2401	300	2025-09-21	sunday	t	QR Scan - Cecilia Phem Duong Thuy Ha	92	2025-09-21 03:15:34.773
2403	745	2025-09-21	sunday	t	QR Scan - Teresa Ngo Bao Ngac	92	2025-09-21 03:15:45.598
2404	64	2025-09-21	sunday	t	QR Scan - Teresa Luong Ngac Bao Anh	92	2025-09-21 03:15:49.83
2405	916	2025-09-21	sunday	t	Manual Present Entry - Hồ Nguyễn Gia Phúc	92	2025-09-21 03:16:00.759
2406	519	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Nguyen Khoa	6	2025-09-21 03:16:06.726
2408	923	2025-09-21	sunday	t	Manual Present Entry - Lê Nguyễn Thiên Phúc	92	2025-09-21 03:16:20.626
2410	46	2025-09-21	sunday	t	QR Scan - Maria Chu Bao Anh	92	2025-09-21 03:16:30.947
2412	1330	2025-09-21	sunday	t	QR Scan - Giuse Phem An Yen	92	2025-09-21 03:16:38.956
2413	1233	2025-09-21	sunday	t	QR Scan - Nguyen Nhet Trueng	92	2025-09-21 03:16:43.331
2414	825	2025-09-21	sunday	t	QR Scan - Anna Tren Bao Nhi	92	2025-09-21 03:16:47.451
2415	1039	2025-09-21	sunday	t	QR Scan - Batolomeo Tren Minh Tien	92	2025-09-21 03:16:49.316
2416	173	2025-09-21	sunday	t	QR Scan - Maria Tren Ngac Bich	92	2025-09-21 03:16:53.217
2417	609	2025-09-21	sunday	t	QR Scan - Giuse Phem Nguyen Long	6	2025-09-21 03:16:54.972
2419	1124	2025-09-21	sunday	t	Manual web attendance	52	2025-09-21 03:17:06.617
2420	893	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Thanh Phong	92	2025-09-21 03:17:07.937
2407	83	2025-09-21	sunday	t	QR Scan - Maria Nguyen Xuan Anh	92	2025-09-21 03:17:31.475
2411	464	2025-09-21	sunday	t	QR Scan - Martino Nguyen Duy Khang	92	2025-09-21 03:18:13.064
2418	802	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Minh Nhật	6	2025-09-21 03:19:20.756
2422	691	2025-09-21	sunday	t	QR Scan - Maria Tren Vu Yen My	92	2025-09-21 03:17:33.972
2423	1345	2025-09-21	sunday	t	Manual Present Entry - Huỳnh Kim Ánh Dương	6	2025-09-21 03:17:34.348
2424	1019	2025-09-21	sunday	t	Manual Present Entry - Đoàn Minh Tâm	6	2025-09-21 03:17:41.848
2409	1248	2025-09-21	sunday	t	QR Scan - Maria Goretti Teng Minh Uyen	92	2025-09-21 03:17:44.892
2426	634	2025-09-21	sunday	t	Manual web attendance	52	2025-09-21 03:17:50.716
2427	1178	2025-09-21	sunday	t	Manual Present Entry - Võ Ngân Thư	6	2025-09-21 03:17:51.258
2428	595	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Ngọc Tuyết Loan	6	2025-09-21 03:18:04.499
2429	45	2025-09-21	sunday	t	Manual Present Entry - Công Võ Phương Anh	92	2025-09-21 03:18:07.265
2431	536	2025-09-21	sunday	t	Manual web attendance	91	2025-09-21 03:18:24.212
2432	809	2025-09-21	sunday	t	Manual Present Entry - Hoàng Nguyễn Tuệ Nhi	92	2025-09-21 03:18:57.665
2435	107	2025-09-21	sunday	t	Manual web attendance	91	2025-09-21 03:19:21.729
2436	252	2025-09-21	sunday	t	Manual Present Entry - Đoàn Tấn Đạt	92	2025-09-21 03:19:30.432
2437	1305	2025-09-21	sunday	t	Manual Present Entry - Phan Nguyễn Minh Vy	6	2025-09-21 03:19:32.291
2438	368	2025-09-21	sunday	t	Manual Present Entry - Vương Trung Hiếu	6	2025-09-21 03:19:51.915
2439	873	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Lê Gia Phát	6	2025-09-21 03:20:12.853
2440	483	2025-09-21	sunday	t	Manual Present Entry - Trần Duy Khang	92	2025-09-21 03:21:02.311
2441	210	2025-09-21	sunday	t	Manual web attendance	92	2025-09-21 03:23:56.213
2443	1285	2025-09-21	sunday	t	QR Scan - Hoang Nguyen Nhet Vy	100	2025-09-21 03:27:31.901
2444	1138	2025-09-21	sunday	t	Manual Present Entry - Phạm Nguyễn Anh Thơ	57	2025-09-21 03:27:37.16
2445	58	2025-09-21	sunday	t	QR Scan - Maria He Ngac Quenh Anh	100	2025-09-21 03:27:38.85
2448	1144	2025-09-21	sunday	t	Manual Present Entry - Hoàng Thị Diệu Thùy	57	2025-09-21 03:27:52.185
2451	1252	2025-09-21	sunday	t	Manual Present Entry - Bùi Ngọc Khánh Vân	57	2025-09-21 03:28:11.277
2452	408	2025-09-21	sunday	t	QR Scan - Giuse Maria Vo Quang Huy	92	2025-09-21 03:28:14.645
2453	432	2025-09-21	sunday	t	QR Scan - Giuse Vu Trung Kien	87	2025-09-21 03:28:26.57
2455	632	2025-09-21	sunday	t	Manual Present Entry - Phạm Thị Quỳnh Mai	87	2025-09-21 03:28:40.61
2456	1186	2025-09-21	sunday	t	QR Scan - Maria Nguyen Hoang Nha Thy	57	2025-09-21 03:28:52.739
2433	245	2025-09-21	sunday	t	QR Scan - Anna Nguyen Ngac Linh An	87	2025-09-21 03:28:57.671
2458	19	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Hoài An	57	2025-09-21 03:29:17.412
2459	53	2025-09-21	sunday	t	QR Scan - Teresa Do Ha Bao Anh	57	2025-09-21 03:29:24.849
2460	753	2025-09-21	sunday	t	QR Scan - Anna Nguyen Nhu Bao Ngac	57	2025-09-21 03:29:26.308
2461	771	2025-09-21	sunday	t	QR Scan - Maria Le An Nguyen	57	2025-09-21 03:29:39.291
2462	275	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Ngọc Tâm Đoan	87	2025-09-21 03:29:43.275
2449	197	2025-09-21	sunday	t	QR Scan - Maria Nguyen Ngoc Linh Chi	57	2025-09-21 03:29:47.026
2464	485	2025-09-21	sunday	t	QR Scan - Phanxico Tren Huy Khang	57	2025-09-21 03:29:56.887
2465	181	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Thanh Cong	57	2025-09-21 03:29:58.307
2466	530	2025-09-21	sunday	t	QR Scan - Martino Le Hoang Dang Khoi	57	2025-09-21 03:30:02.84
2467	622	2025-09-21	sunday	t	QR Scan - Philipphe Nguyen Hau Luong	57	2025-09-21 03:30:04.734
2468	430	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Hoang Kien	57	2025-09-21 03:30:07.91
2469	922	2025-09-21	sunday	t	QR Scan - Giuse Le Hau Phuc	57	2025-09-21 03:30:12.19
2470	57	2025-09-21	sunday	t	QR Scan - Giuse Hoang Tri Anh	57	2025-09-21 03:30:16.196
2471	678	2025-09-21	sunday	t	QR Scan - Maria Nguyen Giang My	57	2025-09-21 03:30:18.309
2472	1104	2025-09-21	sunday	t	QR Scan - Aminh Vu Quac Thien	57	2025-09-21 03:30:22.329
2473	664	2025-09-21	sunday	t	QR Scan - Giuse Tren Nguyen Quang Minh	57	2025-09-21 03:30:28.667
2474	928	2025-09-21	sunday	t	QR Scan - Augustino Nguyen Hoang Phuc	57	2025-09-21 03:30:30.888
2475	884	2025-09-21	sunday	t	QR Scan - Giuse Dinh Hai Phong	57	2025-09-21 03:30:34.888
2476	865	2025-09-21	sunday	t	QR Scan - Anre Le Hoang Gia Phat	57	2025-09-21 03:30:36.47
2477	156	2025-09-21	sunday	t	QR Scan - Giuse Nguyen Quac Bao	57	2025-09-21 03:30:39.109
2478	282	2025-09-21	sunday	t	QR Scan - Daminh Hoang Thien Duc	57	2025-09-21 03:30:42.03
2479	606	2025-09-21	sunday	t	QR Scan - Aminh Nguyen Inh Long	57	2025-09-21 03:30:55.588
2480	271	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.024
2481	891	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.027
2482	635	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.029
2483	320	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.031
2484	1073	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.034
2485	404	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.036
2486	650	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.038
2487	897	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.04
2488	774	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.042
2489	248	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.043
2491	799	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.048
2492	196	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.05
2493	602	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.052
2494	94	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.054
2495	1	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.056
2496	12	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.058
2497	29	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.06
2498	132	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.062
2499	575	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.064
2500	461	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.066
2501	482	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.067
2502	534	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.069
2503	663	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.071
2504	837	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.073
2505	1165	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.075
2506	925	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.077
2507	918	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.079
2508	938	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.081
2509	1128	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.082
2510	1130	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.084
2511	1288	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.086
2512	1333	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.088
2513	39	2025-09-21	sunday	t	Mark all present	81	2025-09-21 03:31:07.09
2514	347	2025-09-21	sunday	t	QR Scan - Teresa Te Cat Gia Han	7	2025-09-21 03:32:11.622
2515	1151	2025-09-21	sunday	t	QR Scan - Maria Duong Huenh Anh Thu	7	2025-09-21 03:32:16.24
2516	569	2025-09-21	sunday	t	QR Scan - Philipphe E Phuc Lam	7	2025-09-21 03:32:24.047
2517	721	2025-09-21	sunday	t	QR Scan - Maria Teresa Tren Vu Thien Ngan	7	2025-09-21 03:32:27.342
2447	317	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.113
2442	879	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.122
2518	1207	2025-09-21	sunday	t	QR Scan - Maria Thai Phuong Tran	7	2025-09-21 03:32:37.015
2519	739	2025-09-21	sunday	t	QR Scan - Anna Le Nguyen Bao Ngac	7	2025-09-21 03:32:41.382
2520	405	2025-09-21	sunday	t	QR Scan - Giuse Tren Minh Huy	7	2025-09-21 03:32:45.162
2521	187	2025-09-21	sunday	t	QR Scan - Maria Nguyen Ngoc Bao Chau	57	2025-09-21 03:32:46.745
2454	713	2025-09-21	sunday	t	QR Scan - Maria Hoang Pham Khanh Ngan	57	2025-09-21 03:32:48.607
2523	564	2025-09-21	sunday	t	QR Scan - Maria Ha Thai Hoang Lan	7	2025-09-21 03:32:54.306
2524	840	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Ngọc An Nhiên	7	2025-09-21 03:33:17.358
2525	313	2025-09-21	sunday	t	QR Scan - Anna Duong E Gia Han	7	2025-09-21 03:33:37.487
2526	1005	2025-09-21	sunday	t	QR Scan - Maria Vu Ngac Ngan Quenh	7	2025-09-21 03:33:41.808
2527	770	2025-09-21	sunday	t	QR Scan - Giuse Huenh Khoi Nguyen	7	2025-09-21 03:33:44.517
2528	919	2025-09-21	sunday	t	QR Scan - Gioan Huenh Vinh Phuc	7	2025-09-21 03:33:46.418
2529	999	2025-09-21	sunday	t	QR Scan - Maria Nguyen Khanh Quenh	7	2025-09-21 03:33:51.28
2530	654	2025-09-21	sunday	t	QR Scan - Teresa Nguyen Y Minh	7	2025-09-21 03:33:53.94
2531	1308	2025-09-21	sunday	t	QR Scan - Lucia Te Luu Yen Vy	7	2025-09-21 03:33:55.81
2532	1067	2025-09-21	sunday	t	QR Scan - Maria Phem The Diau Thanh	7	2025-09-21 03:34:02.001
2533	157	2025-09-21	sunday	t	QR Scan - Phero Nguyen Tren Gia Bao	7	2025-09-21 03:34:05.029
2534	429	2025-09-21	sunday	t	QR Scan - Giuse Bui Nguyen Trung Kien	7	2025-09-21 03:34:07.18
2535	116	2025-09-21	sunday	t	QR Scan - Phaolo Nguyen Ac Thien An	7	2025-09-21 03:34:10.112
2536	860	2025-09-21	sunday	t	QR Scan - Giuse Am Viet Phat	7	2025-09-21 03:34:14.09
2537	286	2025-09-21	sunday	t	QR Scan - Phero Tren Minh Ac	7	2025-09-21 03:34:17.559
2538	828	2025-09-21	sunday	t	Manual Present Entry - Trần Phương Nhi	7	2025-09-21 03:34:40.837
2539	48	2025-09-21	sunday	t	QR Scan - Maria Am Tren Tram Anh	7	2025-09-21 03:34:45.225
2540	478	2025-09-21	sunday	t	Manual web attendance	80	2025-09-21 03:36:37.833
2541	148	2025-09-21	sunday	t	Manual Present Entry - Lý Gia Bảo	86	2025-09-21 03:36:46.082
2542	954	2025-09-21	sunday	t	Manual web attendance	80	2025-09-21 03:36:52.369
2543	224	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Khánh Duy	7	2025-09-21 03:37:27.134
2544	704	2025-09-21	sunday	t	Manual Present Entry - Trần Bảo Nam	86	2025-09-21 03:37:50.338
2545	515	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Hoàng Anh Khoa	86	2025-09-21 03:37:59.035
2546	913	2025-09-21	sunday	t	Manual Present Entry - Đỗ Hoàng Phúc	86	2025-09-21 03:38:07.24
2547	1256	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Thanh Vân	86	2025-09-21 03:38:14.789
2548	256	2025-09-21	sunday	t	Manual web attendance	77	2025-09-21 03:38:34.616
2549	813	2025-09-21	sunday	t	Manual Present Entry - Lương Thiện Nhi	7	2025-09-21 03:38:41.552
2552	186	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Bảo Châu	7	2025-09-21 04:22:12.321
2557	1132	2025-09-21	sunday	t	Manual Present Entry - Phan Hưng Thịnh	7	2025-09-21 04:40:20.319
2558	869	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:02:33.001
2559	1271	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:02:41.659
2560	1103	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:02:49.8
2561	778	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:03:04.257
2562	1324	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:03:13.577
2563	226	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:03:24.163
2564	1137	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:03:31.71
2565	940	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:03:48.212
2566	396	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:04:05.107
2567	456	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:04:19.994
2568	204	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:04:27.365
2569	98	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:05:07.477
2570	4	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:05:13.988
2571	613	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:05:30.897
2572	667	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:05:34.546
2573	947	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:05:46.542
2574	10	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:06:02.855
2575	504	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:06:18.584
2576	803	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:06:58.874
2577	822	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:07:10.553
2578	457	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:07:22.185
2579	93	2025-09-21	sunday	t	Manual web attendance	86	2025-09-21 05:07:34.666
2581	339	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:10.452
2582	646	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:16.072
2583	1134	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:22.643
2584	386	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:29.842
2585	447	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:33.351
2586	443	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:38.418
2587	200	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:51.968
2588	246	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:41:53.748
2589	1283	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:42:01.06
2590	1286	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:42:02.717
2591	616	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:42:09.778
2592	992	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:42:15.72
2593	979	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:42:41.533
2594	978	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:42:44.623
2595	1021	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:43:29.322
2596	1243	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:43:35.256
2597	125	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:43:42.969
2598	228	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:43:48.07
2599	715	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:44:09.261
2600	688	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:44:20.565
2601	1001	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:46:51.414
2602	731	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:46:53.868
2603	702	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:47:13.093
2604	1024	2025-09-21	sunday	t	Manual web attendance	69	2025-09-21 05:47:18.723
2605	966	2025-09-21	sunday	t	Manual Present Entry - Đỗ Nguyễn Đức Quân	7	2025-09-21 06:28:40.348
2554	455	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.137
2555	343	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.154
2556	563	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.156
2705	15	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:26.705
2706	31	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:28.402
2707	68	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:30.17
2708	82	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:31.682
2709	199	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:34.571
2710	259	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:35.581
2711	267	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:37.669
2712	323	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:40.297
2713	393	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:41.609
2714	425	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:42.289
2715	570	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:45.002
2716	584	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:47.833
2717	605	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:48.751
2718	718	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:23:50.451
2719	726	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:02.253
2720	750	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:03.986
2721	730	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:05.081
2722	824	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:17.39
2723	877	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:17.905
2724	974	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:19.877
2725	1010	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:21.421
2726	1086	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:23.65
2727	1061	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:24.249
2728	1110	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:26.077
2729	1200	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:33.229
2730	1277	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:37.516
2731	1328	2025-09-21	sunday	t	Manual web attendance	75	2025-09-21 08:24:39.886
2734	990	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:05.499
2735	205	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:25.462
2736	50	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:29.955
2737	158	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:33.819
2738	249	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:38.124
2739	281	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:40.572
2740	366	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:41.639
2741	1347	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:29:42.916
2743	1349	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:31:28.969
2744	1346	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:31:45.075
2745	775	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:32:30.366
2746	1348	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:32:43.32
2747	32	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:33:39.334
2748	34	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:33:44.552
2749	37	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:33:51.293
2750	139	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:34:00.206
2751	225	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:34:10.194
2754	468	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:35:08.898
2755	470	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:35:12.049
2756	610	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:35:20.485
2757	639	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:35:21.813
2758	653	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:35:23.239
2759	689	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:38:09.969
2760	727	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:38:11.528
2761	841	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:38:22.01
2762	844	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:38:22.677
2763	1284	2025-09-21	sunday	t	Manual web attendance	58	2025-09-21 08:39:06.923
2765	71	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.115
2776	1310	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.121
2446	387	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.124
2450	208	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.128
2782	337	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.132
2768	422	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.135
2771	649	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.139
2770	716	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.143
2772	738	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.145
2766	1146	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.147
2767	1174	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.15
2764	1297	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.152
2553	1352	2025-09-21	sunday	t	Mark all present	15	2025-09-21 09:16:18.165
2799	33	2025-09-21	sunday	t	Manual web attendance	15	2025-09-21 09:17:49.391
2801	511	2025-09-21	sunday	t	Manual web attendance	85	2025-09-21 11:00:27.386
2802	1321	2025-09-21	sunday	t	Manual Present Entry - Đoàn Ngọc Như Ý	57	2025-09-21 11:09:25.634
2803	917	2025-09-21	sunday	t	Manual Present Entry - Hợp Tiến Phúc	57	2025-09-21 11:09:58.651
2804	500	2025-09-21	sunday	t	Manual Present Entry - Lê Nguyễn Minh Khánh	57	2025-09-21 11:10:08.345
2805	645	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Hoàng Minh	57	2025-09-21 11:10:26.781
2806	89	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 11:37:01.746
2807	234	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 11:37:28.491
2808	1147	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 11:38:04.606
2809	1153	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 11:38:05.972
2810	1180	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 11:38:16.989
2811	108	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 11:38:49.845
2812	359	2025-09-21	sunday	t	Manual web attendance	1	2025-09-21 11:39:00.147
2813	193	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:24:55.136
2814	625	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:25:23.142
2815	821	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:25:49.854
2816	1169	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:25:58.41
2817	931	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:26:16.581
2818	340	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:26:31.536
2819	876	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:26:49.372
2820	1118	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:27:04.939
2821	669	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:27:20.413
2822	964	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:27:32.736
2823	1037	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:27:44.687
2824	474	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:27:54.999
2825	787	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:28:01.448
2826	789	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:28:12.982
2827	1206	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:28:20.622
2828	27	2025-09-21	sunday	t	Manual web attendance	71	2025-09-21 13:28:24.692
2829	924	2025-09-21	sunday	t	Manual web attendance	48	2025-09-21 14:35:17.149
2830	260	2025-09-21	sunday	t	Manual web attendance	48	2025-09-21 14:35:24.27
2831	655	2025-09-21	sunday	t	Manual web attendance	48	2025-09-21 14:35:48.915
2832	657	2025-09-21	sunday	t	Manual Present Entry - Phạm Khải Minh	86	2025-09-21 14:47:57.438
2833	370	2025-09-21	sunday	t	Manual Present Entry - Bùi Gia Hoàng	86	2025-09-21 14:48:19.946
2834	589	2025-09-21	sunday	t	Manual web attendance	13	2025-09-21 14:48:36.601
2835	273	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Đình Đình	86	2025-09-21 14:48:43.344
2836	265	2025-09-21	sunday	t	Manual web attendance	13	2025-09-21 14:48:45.919
2837	785	2025-09-21	sunday	t	Manual web attendance	13	2025-09-21 14:48:51.448
2838	878	2025-09-21	sunday	t	Manual web attendance	13	2025-09-21 14:49:00.835
2839	1170	2025-09-21	sunday	t	Manual Present Entry - Thạch Đoàn Anh Thư	86	2025-09-21 14:49:09.743
2840	1046	2025-09-21	sunday	t	Manual web attendance	13	2025-09-21 14:49:10.25
2841	621	2025-09-21	sunday	t	Manual web attendance	13	2025-09-21 14:49:16.946
2842	73	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Ngọc Tú Anh	86	2025-09-21 14:49:35.978
2843	1212	2025-09-21	sunday	t	Manual Present Entry - Nguyễn Trường Minh Trí	73	2025-09-21 15:20:41.772
2844	1190	2025-09-21	sunday	t	Manual Present Entry - Phạm Trương Bảo Thy	73	2025-09-21 15:21:42.842
2845	414	2025-09-21	sunday	t	Manual Present Entry - Ngô Gia Hưng	73	2025-09-21 15:22:10.802
\.


--
-- Data for Name: class_teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_teachers (id, class_id, user_id, is_primary, created_at) FROM stdin;
1	3	2	f	2025-09-10 16:15:38.753
2	51	3	f	2025-09-10 16:15:38.769
3	20	4	f	2025-09-10 16:15:38.786
4	12	5	f	2025-09-10 16:15:38.807
5	4	6	f	2025-09-10 16:15:38.824
6	12	7	f	2025-09-10 16:15:38.837
7	5	8	f	2025-09-10 16:15:38.85
8	14	9	f	2025-09-10 16:15:38.865
9	21	10	f	2025-09-10 16:15:38.881
10	28	11	f	2025-09-10 16:15:38.895
11	40	12	f	2025-09-10 16:15:38.91
12	34	13	f	2025-09-10 16:15:38.926
13	6	14	f	2025-09-10 16:15:38.941
14	19	15	f	2025-09-10 16:15:38.955
15	35	16	f	2025-09-10 16:15:38.967
16	50	17	f	2025-09-10 16:15:38.985
17	20	18	f	2025-09-10 16:15:39.008
18	38	19	f	2025-09-10 16:15:39.027
19	41	20	f	2025-09-10 16:15:39.049
20	21	21	f	2025-09-10 16:15:39.074
21	14	22	f	2025-09-10 16:15:39.089
22	26	23	f	2025-09-10 16:15:39.106
23	42	24	f	2025-09-10 16:15:39.134
24	50	25	f	2025-09-10 16:15:39.149
25	11	26	f	2025-09-10 16:15:39.164
26	30	27	f	2025-09-10 16:15:39.185
27	25	28	f	2025-09-10 16:15:39.202
28	36	30	f	2025-09-10 16:15:39.23
29	5	31	f	2025-09-10 16:15:39.246
30	3	32	f	2025-09-10 16:15:39.259
31	16	33	f	2025-09-10 16:15:39.274
32	31	34	f	2025-09-10 16:15:39.288
33	10	35	f	2025-09-10 16:15:39.307
34	41	36	f	2025-09-10 16:15:39.319
35	24	37	f	2025-09-10 16:15:39.333
36	32	38	f	2025-09-10 16:15:39.347
37	33	39	f	2025-09-10 16:15:39.36
38	22	40	f	2025-09-10 16:15:39.374
39	4	41	f	2025-09-10 16:15:39.389
40	22	43	f	2025-09-10 16:15:39.415
41	11	44	f	2025-09-10 16:15:39.428
42	28	45	f	2025-09-10 16:15:39.442
43	40	46	f	2025-09-10 16:15:39.456
44	29	47	f	2025-09-10 16:15:39.471
45	1	48	f	2025-09-10 16:15:39.487
46	51	49	f	2025-09-10 16:15:39.505
47	37	50	f	2025-09-10 16:15:39.52
48	23	51	f	2025-09-10 16:15:39.537
49	2	52	f	2025-09-10 16:15:39.552
50	23	53	f	2025-09-10 16:15:39.568
51	24	54	f	2025-09-10 16:15:39.585
52	6	55	f	2025-09-10 16:15:39.602
53	17	56	f	2025-09-10 16:15:39.617
54	15	57	f	2025-09-10 16:15:39.635
55	13	58	f	2025-09-10 16:15:39.648
56	27	59	f	2025-09-10 16:15:39.664
57	35	60	f	2025-09-10 16:15:39.681
58	42	61	f	2025-09-10 16:15:39.699
59	27	62	f	2025-09-10 16:15:39.72
60	36	63	f	2025-09-10 16:15:39.737
61	25	64	f	2025-09-10 16:15:39.753
62	38	65	f	2025-09-10 16:15:39.769
63	37	66	f	2025-09-10 16:15:39.783
64	26	67	f	2025-09-10 16:15:39.799
65	29	68	f	2025-09-10 16:15:39.814
66	18	69	f	2025-09-10 16:15:39.83
67	2	70	f	2025-09-10 16:15:39.844
68	34	71	f	2025-09-10 16:15:39.857
69	2	72	f	2025-09-10 16:15:39.872
70	37	73	f	2025-09-10 16:15:39.886
71	15	74	f	2025-09-10 16:15:39.901
72	17	75	f	2025-09-10 16:15:39.915
73	31	76	f	2025-09-10 16:15:39.929
74	10	77	f	2025-09-10 16:15:39.94
75	35	78	f	2025-09-10 16:15:39.952
76	38	79	f	2025-09-10 16:15:39.965
77	5	80	f	2025-09-10 16:15:39.979
78	11	81	f	2025-09-10 16:15:39.996
79	3	82	f	2025-09-10 16:15:40.012
80	5	83	f	2025-09-10 16:15:40.025
81	13	84	f	2025-09-10 16:15:40.038
82	12	85	f	2025-09-10 16:15:40.051
83	10	86	f	2025-09-10 16:15:40.067
84	1	87	f	2025-09-10 16:15:40.079
85	6	88	f	2025-09-10 16:15:40.091
86	36	89	f	2025-09-10 16:15:40.106
87	32	90	f	2025-09-10 16:15:40.119
88	4	91	f	2025-09-10 16:15:40.13
89	1	92	f	2025-09-10 16:15:40.143
90	18	93	f	2025-09-10 16:15:40.157
91	6	94	f	2025-09-10 16:15:40.171
92	33	95	f	2025-09-10 16:15:40.187
93	13	96	f	2025-09-10 16:15:40.203
94	30	97	f	2025-09-10 16:15:40.218
95	16	98	f	2025-09-10 16:15:40.232
96	19	99	f	2025-09-10 16:15:40.245
98	45	42	f	2025-09-10 16:43:18.752
99	45	29	f	2025-09-10 16:43:31.57
100	15	100	f	2025-09-14 14:03:59.524
101	19	101	f	2025-09-14 14:03:59.54
102	30	102	f	2025-09-14 14:03:59.554
103	32	103	f	2025-09-14 14:03:59.57
104	17	104	f	2025-09-14 14:03:59.589
105	33	105	f	2025-09-14 14:03:59.606
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes (id, name, department_id, teacher_id, is_active, created_at, updated_at) FROM stdin;
1	Ấu 1A	1	\N	t	2025-09-10 16:14:24.591	2025-09-10 16:14:24.591
2	Ấu 1B	1	\N	t	2025-09-10 16:14:24.77	2025-09-10 16:14:24.77
3	Ấu 1C	1	\N	t	2025-09-10 16:14:24.896	2025-09-10 16:14:24.896
4	Ấu 1D	1	\N	t	2025-09-10 16:14:25.022	2025-09-10 16:14:25.022
5	Khai Tâm A	1	\N	t	2025-09-10 16:14:25.144	2025-09-10 16:14:25.144
6	Khai Tâm B	1	\N	t	2025-09-10 16:14:25.268	2025-09-10 16:14:25.268
7	Khai Tâm C	1	\N	t	2025-09-10 16:14:25.406	2025-09-10 16:14:25.406
10	Ấu 2A	2	\N	t	2025-09-10 16:14:25.812	2025-09-10 16:14:25.812
11	Ấu 2B	2	\N	t	2025-09-10 16:14:25.939	2025-09-10 16:14:25.939
12	Ấu 2C	2	\N	t	2025-09-10 16:14:26.067	2025-09-10 16:14:26.067
13	Ấu 2D	2	\N	t	2025-09-10 16:14:26.19	2025-09-10 16:14:26.19
14	Ấu 2E	2	\N	t	2025-09-10 16:14:26.31	2025-09-10 16:14:26.31
15	Ấu 3A	2	\N	t	2025-09-10 16:14:26.431	2025-09-10 16:14:26.431
16	Ấu 3B	2	\N	t	2025-09-10 16:14:26.553	2025-09-10 16:14:26.553
17	Ấu 3C	2	\N	t	2025-09-10 16:14:26.676	2025-09-10 16:14:26.676
18	Ấu 3D	2	\N	t	2025-09-10 16:14:26.793	2025-09-10 16:14:26.793
19	Ấu 3E	2	\N	t	2025-09-10 16:14:26.916	2025-09-10 16:14:26.916
20	Thiếu 1A	3	\N	t	2025-09-10 16:14:27.038	2025-09-10 16:14:27.038
21	Thiếu 1B	3	\N	t	2025-09-10 16:14:27.159	2025-09-10 16:14:27.159
22	Thiếu 1C	3	\N	t	2025-09-10 16:14:27.281	2025-09-10 16:14:27.281
23	Thiếu 1D	3	\N	t	2025-09-10 16:14:27.4	2025-09-10 16:14:27.4
24	Thiếu 1E	3	\N	t	2025-09-10 16:14:27.518	2025-09-10 16:14:27.518
25	Thiếu 2A	3	\N	t	2025-09-10 16:14:27.637	2025-09-10 16:14:27.637
26	Thiếu 2B	3	\N	t	2025-09-10 16:14:27.756	2025-09-10 16:14:27.756
27	Thiếu 2C	3	\N	t	2025-09-10 16:14:27.877	2025-09-10 16:14:27.877
28	Thiếu 2D	3	\N	t	2025-09-10 16:14:28.276	2025-09-10 16:14:28.276
29	Thiếu 2E	3	\N	t	2025-09-10 16:14:28.399	2025-09-10 16:14:28.399
30	Thiếu 3A	3	\N	t	2025-09-10 16:14:28.522	2025-09-10 16:14:28.522
31	Thiếu 3B	3	\N	t	2025-09-10 16:14:28.644	2025-09-10 16:14:28.644
32	Thiếu 3C	3	\N	t	2025-09-10 16:14:28.762	2025-09-10 16:14:28.762
33	Thiếu 3D	3	\N	t	2025-09-10 16:14:28.882	2025-09-10 16:14:28.882
34	Thiếu 3E	3	\N	t	2025-09-10 16:14:29.002	2025-09-10 16:14:29.002
35	Nghĩa 1A	4	\N	t	2025-09-10 16:14:29.124	2025-09-10 16:14:29.124
36	Nghĩa 1B	4	\N	t	2025-09-10 16:14:29.243	2025-09-10 16:14:29.243
37	Nghĩa 1C	4	\N	t	2025-09-10 16:14:29.365	2025-09-10 16:14:29.365
38	Nghĩa 1D	4	\N	t	2025-09-10 16:14:29.481	2025-09-10 16:14:29.481
40	Nghĩa 2A	4	\N	t	2025-09-10 16:14:29.716	2025-09-10 16:14:29.716
41	Nghĩa 2B	4	\N	t	2025-09-10 16:14:29.834	2025-09-10 16:14:29.834
42	Nghĩa 2C	4	\N	t	2025-09-10 16:14:29.952	2025-09-10 16:14:29.952
50	Hiệp sĩ 1	4	\N	t	2025-09-10 16:14:31.191	2025-09-10 16:14:31.191
51	Hiệp sĩ 2	4	\N	t	2025-09-10 16:14:31.315	2025-09-10 16:14:31.315
45	Nghĩa 3	4	\N	t	2025-09-10 16:14:30.307	2025-09-10 16:43:32.085
49	Nghĩa 3E	4	\N	f	2025-09-10 16:14:31.069	2025-09-10 16:52:48.22
9	Ấu 1E	2	\N	f	2025-09-10 16:14:25.692	2025-09-16 15:43:04.171
8	Khai Tâm D	1	\N	f	2025-09-10 16:14:25.548	2025-09-16 15:43:15.756
39	Nghĩa 1E	4	\N	f	2025-09-10 16:14:29.598	2025-09-16 15:43:33.366
43	Nghĩa 2D	4	\N	f	2025-09-10 16:14:30.07	2025-09-16 15:43:43.242
44	Nghĩa 2E	4	\N	f	2025-09-10 16:14:30.189	2025-09-16 15:43:47.873
46	Nghĩa 3B	4	\N	f	2025-09-10 16:14:30.428	2025-09-16 15:43:53.241
47	Nghĩa 3C	4	\N	f	2025-09-10 16:14:30.546	2025-09-16 15:43:57.307
48	Nghĩa 3D	4	\N	f	2025-09-10 16:14:30.671	2025-09-16 15:44:00.897
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, display_name, description, is_active, created_at) FROM stdin;
1	CHIEN	Chiên Con	Nhóm Chiên Con (6-8 tuổi)	t	2025-09-10 16:14:22.972
2	AU	Ấu Nhi	Nhóm Ấu Nhi (9-11 tuổi)	t	2025-09-10 16:14:23.094
3	THIEU	Thiếu Nhi	Nhóm Thiếu Nhi (12-14 tuổi)	t	2025-09-10 16:14:23.156
4	NGHIA	Nghĩa Sĩ	Nhóm Nghĩa Sĩ (15-17 tuổi)	t	2025-09-10 16:14:23.483
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, student_code, qr_code, saint_name, full_name, birth_date, phone_number, parent_phone_1, parent_phone_2, address, class_id, is_active, created_at, updated_at, academic_year_id, attendance_average, exam_hk1, exam_hk2, final_average, study_45_hk1, study_45_hk2, study_average, sunday_attendance_count, thursday_attendance_count) FROM stdin;
61	LA122258	\N	Maria	Lê Ngọc Trâm Anh	2012-12-05 00:00:00	\N	0918386940	\N	352 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:38.296	2025-09-19 13:40:27.016	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
942	VP112174	\N	Phêrô	Vũ Nguyễn Bảo Phúc	2011-04-28 00:00:00	\N	0938047599	\N	152/21B Bình Long, Phú Thạnh, Tân Phú	41	t	2025-09-10 16:23:55.33	2025-09-19 13:40:55.859	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
380	TH082181	\N	Phêrô	Trương Lê Hoàng	2008-03-11 00:00:00	\N	0936343117	0936515340	118/48/16 Liên Khu 5-6, BHHB, Bình Tân	51	t	2025-09-10 16:23:44.282	2025-09-19 13:40:37.326	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
383	ĐH202123	\N	Maria	Đỗ Ngọc Hồng	2010-06-11 00:00:00	\N	0937671714	\N	189 Lê Sao, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:44.359	2025-09-19 13:40:36.958	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
356	VH122243	\N	Maria	Vũ Ngọc Gia Hân	2012-11-08 00:00:00	\N	\N	\N	\N	25	t	2025-09-10 16:23:42.941	2025-09-19 13:40:36.71	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
407	TH152283	\N	Giuse	Trần Quang Huy	2015-07-23 00:00:00	\N	0978311466	\N	21 Lê Lăng, Phú Thọ Hoà, Tân Phú	20	t	2025-09-10 16:23:44.772	2025-09-19 13:40:38.609	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1066	NT102274	\N	Têrêsa	Nguyễn Đoàn Đan Thanh	2010-07-19 00:00:00	\N	0902634566	\N	136A Hiền Vương, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:57.413	2025-09-19 13:40:59.558	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
600	DL182572	\N	Giuse	Đỗ Bảo Long	2018-03-31 00:00:00	\N	0984161792	0984161782	62/18D đường 5A, BHHA	4	t	2025-09-10 16:23:48.471	2025-09-19 13:40:44.13	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1239	HU112181	\N	Maria	Hồ Đoàn Phương Uyên	2011-12-24 00:00:00	\N	0909772722	\N	136A Hiền Vương, Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:59.769	2025-09-19 13:41:04.459	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
675	NM112189	\N	Maria	Nguyễn Cát Hà My	2011-04-29 00:00:00	\N	0903611911	\N	53 Nguyễn Sơn, Phú Thạnh	36	t	2025-09-10 16:23:49.707	2025-09-19 13:40:47.887	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
740	LN112154	\N	Maria	Lê Nguyễn Bảo Ngọc	2011-12-05 00:00:00	\N	0933172323	\N	282/57 Lê Văn Quới , BHHA	36	t	2025-09-10 16:23:50.819	2025-09-19 13:40:48.281	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
179	NC142192	\N	Maria	Nguyễn Trịnh Sơn Ca	2014-11-01 00:00:00	\N	0372349770	\N	102/16 Bình Long, Phú Thạnh, Tân Phú.	21	t	2025-09-10 16:23:39.939	2025-09-19 13:40:31.354	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
903	NP092122	\N	Matcellino	Nguyễn Anh Phú	2009-10-07 00:00:00	\N	0938739775	\N	29/8/30 ĐS 10 Giáo Họ Vô Nhiễm 	50	t	2025-09-10 16:23:54.611	2025-09-19 13:40:53.966	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1048	NT122145	\N	Giuse	Nguyễn Hoàng Anh Tuấn	2012-10-28 00:00:00	\N	0914848100	0978998938	332/42 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:57.158	2025-09-19 13:40:57.827	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
498	ĐK152283	\N	Giuse	Đăng Quốc Khánh	2015-04-13 00:00:00	\N	0896474313	\N	48/47 Phạm Văn Xảo, Phú Thọ Hòa, Tân Phú	21	t	2025-09-10 16:23:46.659	2025-09-19 13:40:40.899	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1084	VT122161	\N	Maria	Vũ Phương Thảo	2012-12-22 00:00:00	\N	0386344727	\N	413/11/12 Lê Văn Quới, BHHA, Bình Tân	22	t	2025-09-10 16:23:57.654	2025-09-19 13:40:59.327	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1150	CT152238	\N	Maria	Châu Ngọc Anh Thư	2015-05-27 00:00:00	\N	0933325415	\N	29 Đường Số 5A, BHHA, Bình Tân	20	t	2025-09-10 16:23:58.577	2025-09-19 13:41:01.367	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1258	VV132140	\N	Maria	Võ Nguyễn Hải Vân	2013-02-02 00:00:00	\N	0903990303	0906576038	148 Quách Đình Bảo, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:24:00.051	2025-09-19 13:41:05.036	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1266	VV102196	\N	Phêrô	Vũ Quốc Việt	2010-04-24 00:00:00	\N	0975330673	0967090567	121A Lê Lư, Phú Thọ Hòa, Tân Phú	31	t	2025-09-10 16:24:00.159	2025-09-19 13:41:06.467	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
595	NL182515	\N	Maria	Nguyễn Ngọc Tuyết Loan	2018-01-10 00:00:00	\N	0963171714	0977191714	459 Tân Kỳ Tân Quý, Tân Quý	4	t	2025-09-10 16:23:48.387	2025-09-19 13:40:45.87	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
771	LN162258	\N	Maria	Lê An Nguyên	2016-10-19 00:00:00	\N	0987988565	\N	18/55 Đường số 4, BHHA, Bình Tân	15	t	2025-09-10 16:23:51.51	2025-09-19 13:40:50.218	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1304	PV152246	\N	Maria	Phan Đặng Khải Vy	2015-01-24 00:00:00	\N	\N	\N	32/19 Kênh Nước Đen, BHHA, Bình Tân	17	t	2025-09-10 16:24:00.756	2025-09-21 08:19:32.584	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
20	NA162575	\N	Tômasô	Nguyễn Hoàng Phúc An	2016-09-05 00:00:00	\N	\N	\N	68/6/30 BHH	15	t	2025-09-10 16:23:37.737	2025-09-19 13:40:20.905	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
2	BA152253	\N	Maria	Bùi Đặng Gia An	2015-05-23 00:00:00	\N	0939811068	\N	72 Đường số 13A, BHH, Bình Tân	22	t	2025-09-10 16:23:37.469	2025-09-19 13:40:20.904	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
224	ND172419	\N	Giuse	Nguyễn Khánh Duy	2017-12-12 00:00:00	\N	\N	\N	118 Lê Niệm, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:23:40.548	2025-09-21 03:31:18.082	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
466	NK162417	\N	Vincente	Nguyễn Hoàng Phúc Khang	2016-02-17 00:00:00	\N	3682986687	0962159503	73/4 Miếu Bình Đông, BHH A, Tân Phú	13	t	2025-09-10 16:23:45.904	2025-09-21 08:35:09.857	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
32	NA162458	\N	Phêrô	Nguyễn Thiện An	2016-08-14 00:00:00	\N	\N	\N	\N	13	t	2025-09-10 16:23:37.899	2025-09-19 13:40:26.707	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1268	LV122349	\N	Antôn GioanPhaolô II	Lê Hoàng Quang Vinh	2012-03-07 00:00:00	\N	0909677867	\N	2/2/16A Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	29	t	2025-09-10 16:24:00.194	2025-09-19 13:41:05.128	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
78	NA112137	\N	Maria	Nguyễn Phương Anh	2011-10-19 00:00:00	\N	\N	\N	\N	31	t	2025-09-10 16:23:38.53	2025-09-19 13:40:26.706	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
91	PA092197	\N	Isave	Phan Ngọc Bảo Anh	2009-04-10 00:00:00	\N	0774283283	0987074910	49 Lê Vĩnh Hoà, Phú Thọ Hoà, Tân Phú	40	t	2025-09-10 16:23:38.703	2025-09-19 13:40:27.042	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
135	BB152249	\N	Đaminh	Bùi Gia Bảo	2015-11-20 00:00:00	\N	0902969625	\N	96 Đường số 4, BHHA, Bình Tân	22	t	2025-09-10 16:23:39.32	2025-09-19 13:40:28.771	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
963	TQ152184	\N	Đa Minh	Trần Minh Quang	2015-12-01 00:00:00	\N	0938697899	\N	240 Nguyễn Sơn, Phú Thọ Hoà, Tân Phú	21	t	2025-09-10 16:23:55.714	2025-09-19 13:40:55.927	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1026	VT152128	\N	Maria	Vũ Hồ Thục Tâm	2015-04-12 00:00:00	\N	0798241559	\N	111/47 ĐS 1, BHHA, Bình Tân	21	t	2025-09-10 16:23:56.829	2025-09-19 13:40:58.98	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
333	NH142121	\N	Têrêsa	Nguyễn Ngọc Hân	2014-02-12 00:00:00	\N	0934140359	\N	128/14 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	28	t	2025-09-10 16:23:42.559	2025-09-19 15:36:24.8	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1118	TT092243	\N	Phêrô	Trần Đức Thiện	2009-09-16 00:00:00	\N	0908329774	\N	25 Đường số 3, BHHA, Bình Tân	34	t	2025-09-10 16:23:58.138	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
732	PN142111	\N	Têrêsa	Phạm Lưu Phương Nghi	2014-07-23 00:00:00	\N	0908749785	0938861129	58 Trần Thủ Độ, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:50.675	2025-09-19 13:40:48.363	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
438	TK112134	\N	Gioakim	Trần Tuấn Kiệt	2010-12-04 00:00:00	\N	\N	\N	629 Kinh Dương Vương, An Lạc, Bình Tân	40	t	2025-09-10 16:23:45.351	2025-09-19 13:40:38.91	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
491	TK152149	\N	Giacôbê	Trịnh Nguyên Khang	2015-08-08 00:00:00	\N	0908385327	0909155935	B402 CC Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:46.526	2025-09-19 13:40:40.774	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
594	VL122141	\N	Maria	Vũ Trần Uyên Linh	2012-01-27 00:00:00	\N	0387799112	32939118	430 Phú Thọ Hoà,  Phú Thọ Hoà, Tân Phú	35	t	2025-09-10 16:23:48.368	2025-09-19 13:40:44.131	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
674	LM112418	\N	Maria	Lâm Thị Trà My	2011-03-15 00:00:00	\N	0984497209	\N	49A/13 Đường số 13, BHHA, Bình Tân	35	t	2025-09-10 16:23:49.689	2025-09-19 13:40:46.448	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
502	NK202151	\N	Maria	Nguyễn Như Kim Khánh	2011-02-06 00:00:00	\N	\N	0903346194	74 Lê Lăng, Phứ Thọ Hòa, Tân Phú	42	t	2025-09-10 16:23:46.731	2025-09-21 02:36:45.859	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
806	CN122157	\N	Têrêsa	Chu Thảo Nhi	2012-10-06 00:00:00	\N	0906342354	0932679994	155/8 Phú Thọ Hòa, Tân Phú	35	t	2025-09-10 16:23:53.041	2025-09-19 13:40:51.531	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
834	HN192533	\N	Maria	Hà Ngọc An Nhiên	2019-04-27 00:00:00	\N	93887231	0358386798	71/60/14 Phú Thọ Hoà, Phú Thọ Hoà	6	t	2025-09-10 16:23:53.481	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
993	TQ152145	\N	Anna	Trần Mai Nhật Quyên	2015-06-14 00:00:00	\N	0931152797	\N	186 Thạch Lam, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:56.326	2025-09-19 13:40:57.148	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1127	NT172371	\N	Giuse	Nguyễn Phước Thịnh	2017-08-26 00:00:00	\N	0908347599	0933291207	105 Trần Quang Cơ, Phú Thạnh, Tân Phú	13	t	2025-09-10 16:23:58.265	2025-09-19 13:41:00.941	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1293	NV112166	\N	Têrêsa	Nguyễn Minh Vy	2011-12-18 00:00:00	\N	0909210883	0944248824	35 Phan Văn Năm, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:24:00.562	2025-09-19 13:41:06.575	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1307	PV152316	\N	Maria	Phan Vũ Nhật Vy	2015-04-17 00:00:00	\N	0907297498	0778648805	357/5 Bình Long, Phú Thọ Hòa, Tân Phú	23	t	2025-09-10 16:24:00.827	2025-09-19 13:41:07.131	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1120	HT152174	\N	Micae	Hoàng Phước Thịnh	2015-09-02 00:00:00	\N	0938258946	\N	239C Quách Đình Bảo, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:58.165	2025-09-19 13:41:10.707	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
970	NQ142115	\N	Phanxico	Nguyễn Hoàng Quân	2014-10-13 00:00:00	\N	0967678212	\N	111/34 Đường số 1, BHHA, Bình Tân	22	t	2025-09-10 16:23:55.89	2025-09-19 13:40:55.491	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
165	TB152117	\N	Giuse	Trần Nguyễn Gia Bảo	2015-12-18 00:00:00	\N	0936200186	\N	150 Lê Niệm, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:39.729	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
43	VA152337	\N	Rosa	Vũ Ngọc Xuân An	2015-01-11 00:00:00	\N	0918816262	0946743456	Cc Ngọc Đông Dương, 119 Bình Long, BHHA, Bình Tân 	23	t	2025-09-10 16:23:38.055	2025-09-19 13:40:20.985	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
611	PL092122	\N	Phêrô	Phan Ngọc Long	2009-06-30 00:00:00	\N	0908222224	0906827102	168 Lê Sao, Phú Thạnh, Tân Phú 	50	t	2025-09-10 16:23:48.659	2025-09-19 15:36:24.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
985	PQ152246	\N	Giuse	Phan Bảo Quý	2015-11-16 00:00:00	\N	0911168488	\N	364/53/3 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:56.176	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
269	TD132414	\N	Giuse	Trần Hải Đăng	2013-11-03 00:00:00	\N	0981777508	\N	152 Lê Niệm, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:41.359	2025-09-19 15:36:24.8	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
426	PH192543	\N	Maria	Phạm Hoàng Thiên Hương	2019-10-14 00:00:00	\N	0935592118	0975935132	76/11 Miếu Bình Đông, BTĐ 	5	t	2025-09-10 16:23:45.11	2025-09-19 15:36:24.799	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1169	PT132162	\N	Anna	Phạm Thị Minh Thư	2013-02-04 00:00:00	\N	0937771503	0362997112	155/8 Phú Thọ Hòa, Tân Phú	34	t	2025-09-10 16:23:58.838	2025-09-19 15:36:24.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1290	NV112125	\N	Maria	Nguyễn Hoàng Uyên Vy	2011-11-19 00:00:00	\N	0767761631	0931451848	132A Lê Cao Lãng, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:24:00.524	2025-09-19 13:41:06.605	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	1
397	NH152223	\N	Phaolô	Nguyễn Vũ Hoàng Huy	2015-11-23 00:00:00	\N	0906658352	\N	53/5 Tân Thành, Hòa Thạnh, Tân Phú	21	t	2025-09-10 16:23:44.593	2025-09-19 13:40:39.029	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
152	NB132258	\N	Gioan Maria	Nguyễn Hoàng Khánh Bảo	2013-08-03 00:00:00	\N	0522069272	0587738783	27 Lê Văn Quới, BTĐ, Bình Tân	31	t	2025-09-10 16:23:39.546	2025-09-19 13:40:29.027	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
203	HD122122	\N	Anna	Hoàng Vũ An Di	2011-09-17 00:00:00	\N	0938885052	0934353638	318/5A CC Valeo Trịnh Đình Trọng, Hòa Thạnh, Tân Phú	38	t	2025-09-10 16:23:40.247	2025-09-19 13:40:30.782	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1336	VY122166	\N	Maria	Vũ Ngọc Yến	2012-05-15 00:00:00	\N	0908195495	\N	8/10 Đường 5C, BHHA, Bình Tân	31	t	2025-09-10 16:24:01.541	2025-09-19 13:41:08.823	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
160	TB152142	\N	Phanxico	Trần Duy Bảo	2015-08-18 00:00:00	\N	0909802819	\N	66/11 ĐS 12, BìNh Hưng HòA, Bình Tân,	20	t	2025-09-10 16:23:39.655	2025-09-19 13:40:31.132	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
261	TD102126	\N	Giuse	Trần Thành Đạt	2010-04-09 00:00:00	\N	\N	0906910328	151/73/56 Liên Khu 4-5, BHHB, Bình Tân	45	t	2025-09-10 16:23:41.143	2025-09-19 13:40:32.783	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
311	BH172481	\N	Maria	Bùi Ngọc Bảo Hân	2017-08-18 00:00:00	\N	0947064911	0947064511	271 Thạch Lam, Phú Thạnh, Tân Phú	14	t	2025-09-10 16:23:42.194	2025-09-19 13:40:34.458	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
364	NH082162	\N	Phêrô	Nguyễn Bùi Trọng Hiếu	2008-04-29 00:00:00	\N	0792167167	0909761347	251 Miếu Bình Đông, BHHA, Bình Tân	51	t	2025-09-10 16:23:43.064	2025-09-19 13:40:36.863	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
373	NH182475	\N	Giuse	Nguyễn Bảo Hoàng	2018-01-04 00:00:00	\N	0936740450	\N	26/10 Đường số 5, BHH A, Bình Tân	1	t	2025-09-10 16:23:43.228	2025-09-19 13:40:37.032	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
436	PK132136	\N	Phanxico Xavie	Phan Trần Anh Kiệt	\N	\N	\N	\N	\N	31	t	2025-09-10 16:23:45.308	2025-09-19 13:40:41.179	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
242	ĐD102138	\N	Têrêsa	Đỗ Hải Đan	2010-02-07 00:00:00	\N	0982300905	\N	18A Lê Khôi, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:40.838	2025-09-19 13:41:08.435	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1181	NT112193	\N	Antôn	Nguyễn Trung Thực	2011-10-18 00:00:00	\N	0968765177	0363630755	38/9 ĐS1 , BHHA, Bình Tân	42	t	2025-09-10 16:23:59.013	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
463	NK092344	\N	Phaolô	Nguyễn Bách Khang	2009-07-11 00:00:00	\N	0903125719	\N	61/16 Nguyễn Sơn, Phú Thạnh, Tân Phú	41	t	2025-09-10 16:23:45.824	2025-09-19 13:40:39.277	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
662	PM112160	\N	Giacôbê	Phùng Bảo Minh	2011-08-26 00:00:00	\N	0908111203	0902111203	47 Lê Đại, Phú Thọ, Tân Phú	40	t	2025-09-10 16:23:49.502	2025-09-19 13:40:46.285	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
271	TD172335	\N	Giacobe	Trương Vũ Minh Đăng	2017-12-23 00:00:00	\N	0852225888	0909314993	E08-06 CC Phú Thạnh, 53 Nguyễn Sơn, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:41.39	2025-09-19 13:40:32.987	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
902	LP122126	\N	Phêrô	Lê Hoàng Phú	2012-03-02 00:00:00	\N	0909739206	0983110333	135/1 Trần Quang Cơ, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:23:54.591	2025-09-19 13:40:53.946	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1108	LT182535	\N	Micae	Lê Phan Minh Thiện	2018-12-31 00:00:00	\N	0902480599	\N	65 Lê Quốc Trinh, Phú Thọ Hoà	4	t	2025-09-10 16:23:57.999	2025-09-19 13:41:01.504	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1194	PT112187	\N	Maria	Phạm Nguyễn Yến Trang	2011-03-08 00:00:00	\N	0977736322	0385188995	240//19 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:59.172	2025-09-19 13:41:02.764	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
598	BL162317	\N	\N	Bùi Hoàng Long	2016-10-14 00:00:00	\N	0908862988	\N	137/34 Bình Long, BHHA, Bình Tân	12	t	2025-09-10 16:23:48.435	2025-09-21 03:31:18.082	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
412	ĐH152116	\N	Phanxico Savie	Đỗ Hoàng Gia Hưng	2015-10-17 00:00:00	\N	0918977345	\N	266/14/11 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú	20	t	2025-09-10 16:23:44.874	2025-09-19 13:41:10.984	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
80	NA122256	\N	Agata	Nguyễn Thị Kim Anh	2012-01-07 00:00:00	\N	0349195814	\N	213 Nguyễn Sơn, Phú Thạnh, Tân Phú	31	t	2025-09-10 16:23:38.557	2025-09-19 13:40:20.883	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
347	TH172312	\N	Têrêsa	Tạ Cát Gia Hân	2017-03-30 00:00:00	\N	0399691222	0345534118	14/21A Đường số 20, BHHA, Bình Tân	12	t	2025-09-10 16:23:42.784	2025-09-21 03:31:18.082	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
570	ML142553	\N	Maria	Mai Chi Lâm	2014-03-17 00:00:00	\N	0938034377	0937031377	723A Luỹ Bán Bích, Phú Thọ Hoà	17	t	2025-09-10 16:23:47.951	2025-09-21 08:23:12.469	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
62	LA182434	\N	Maria	Lê Nguyễn Tâm Anh	2018-04-30 00:00:00	\N	0903312865	0932009265	60/71 Trương Phước Phan, BTĐ, Bình Tân	1	t	2025-09-10 16:23:38.313	2025-09-19 13:40:26.759	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
277	ND162402	\N	Phêrô	Nguyễn Huỳnh Đông	2016-08-02 00:00:00	\N	0906737364	0908929249	61/2/3 Nguyễn Sơn, Phú Thạnh, Tân Phú	18	t	2025-09-10 16:23:41.549	2025-09-19 13:40:34.451	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
615	VL102156	\N	Giuse	Vũ Nhất Long	2010-04-30 00:00:00	\N	0976876116	\N	195A Trần Thủ Độ	31	t	2025-09-10 16:23:48.722	2025-09-19 13:40:44.5	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
379	NH102152	\N	Phaolo	Nguyễn Văn Hoàng	2010-05-25 00:00:00	\N	0984044139	0387746742	194/3 ĐS 8, BHHA, Bình Tân	45	t	2025-09-10 16:23:43.446	2025-09-19 13:40:36.974	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1267	CV132141	\N	Gioan	Chí Quang Vinh	2013-01-15 00:00:00	\N	0972648278	0352571355	ĐS 1C, BHHA, Bình Tân	31	t	2025-09-10 16:24:00.175	2025-09-19 13:41:05.112	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1076	VT152247	\N	Raphaen	Vũ Duy Thành	2015-04-08 00:00:00	\N	0961948574	\N	411 Bình Trị Đông, BTĐ, Bình Tân	21	t	2025-09-10 16:23:57.541	2025-09-19 13:40:59.561	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
440	ĐK132366	\N	Maria	Đỗ Nguyễn Thiên Kim	2013-01-02 00:00:00	\N	0913790660	\N	26/19/2 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	29	t	2025-09-10 16:23:45.379	2025-09-19 13:40:39.22	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	2	0
733	TN112181	\N	Maria	Trần Nguyễn Xuân Nghi	2011-03-14 00:00:00	\N	0937542098	0364061971	242/64 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	42	t	2025-09-10 16:23:50.695	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
843	TN182465	\N	Giuse	Trương Nguyễn Tường Nhiên	2018-02-18 00:00:00	\N	0909093491	0937676181	787 Luỹ Bán Bích,Phú Thọ Hoà, Tân Phú	1	t	2025-09-10 16:23:53.63	2025-09-19 13:40:52.175	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
911	BP182516	\N	Giuse	Bùi Gia Phúc	2018-03-30 00:00:00	\N	0907969625	0902969625	96 đường số 4, BHHA	4	t	2025-09-10 16:23:54.746	2025-09-19 13:40:54.053	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1095	PT162274	\N	Giuse	Phan Quốc Thiên	2016-10-28 00:00:00	\N	0909833442	0932769788	307/2 Thạch Lam, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:57.811	2025-09-19 13:41:01.153	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1222	TT122153	\N	Gioan	Trần Đình Trọng	2012-11-08 00:00:00	\N	0908242070	\N	127/2/77 Lê Thúc Hoạch , Phú Thọ Hòa, Tân Phú	36	t	2025-09-10 16:23:59.539	2025-09-19 13:41:04.554	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1214	TT192548	\N	Anrê	Trần Đình Gia Trí	2019-07-31 00:00:00	\N	\N	\N	250/23 Phan Anh, Phú Thạnh	5	t	2025-09-10 16:23:59.432	2025-09-19 13:41:04.826	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1318	LV142259	\N	Giuse	Lê Hoàng Vỹ	2016-03-14 00:00:00	\N	0908722502	\N	77 Đường số 8, BHHA, Bình Tân	3	t	2025-09-10 16:24:01.121	2025-09-19 13:41:07.002	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
399	PH132258	\N	Vinh Sơn	Phạm Gia Huy	2013-07-19 00:00:00	\N	0905656900	0906677023	125 Đường số 14, BHHA, Bình Tân	30	t	2025-09-10 16:23:44.643	2025-09-19 13:40:37.342	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
119	NA192518	\N	Maria	Nguyễn Hồng Ân	2019-12-11 00:00:00	\N	0763666153	0934250393	100 Lê Cao Lãng, Phú Thạnh	5	t	2025-09-10 16:23:39.075	2025-09-19 13:40:29.079	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
921	LP192534	\N	Antôn	Lê Hoàng Phúc	2019-06-24 00:00:00	\N	0906794733	0822020297	50/2/7 Miếu Bình Đông, BHHA	6	t	2025-09-10 16:23:54.899	2025-09-19 13:41:08.905	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
378	NH132193	\N	Phêrô	Nguyễn Minh Hoàng	2013-11-14 00:00:00	\N	0901430250	\N	59/29 Nguyễn Sơn, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:43.305	2025-09-19 13:40:36.914	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
156	NB152437	\N	Giuse	Nguyễn Quốc Bảo	2015-01-10 00:00:00	\N	0982743051	0987155527	142/20 Đường số 3, BHH A, Bình Tân	15	t	2025-09-10 16:23:39.607	2025-09-19 13:40:30.624	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
786	TN142415	\N	Têrêsa	Trần Thảo Nguyên	2014-02-06 00:00:00	\N	0932010812	0909842702	122/4/7 Nguyễn Sơn, Phú Thọ Hoà, Tân Phú	24	t	2025-09-10 16:23:52.402	2025-09-19 15:36:24.8	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
118	NA072188	\N	Giuse Maria	Nguyễn Hồng Ân	2007-10-01 00:00:00	\N	0367198199	\N	76/10/7/7 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	51	t	2025-09-10 16:23:39.062	2025-09-19 13:40:20.85	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
120	NA192541	\N	Têrêsa	Nguyễn Hồng Ân	2019-08-05 00:00:00	\N	0908738189	0933992494	19/2D Liên khu 8-9, BHH	6	t	2025-09-10 16:23:39.09	2025-09-19 13:40:20.935	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
891	NP172565	\N	Giuse	Nguyễn Duy Phong	2017-04-28 00:00:00	\N	0344177991	0336950760	81 Kênh Nước Đen, BHHA	11	t	2025-09-10 16:23:54.426	2025-09-19 13:40:53.825	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
330	NH172515	\N	Maria	Nguyễn Ngọc Hân	2017-10-18 00:00:00	\N	0886266166	0943904287	12.16 Cc Ngọc Đông Dương, BTĐ	14	t	2025-09-10 16:23:42.503	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
899	ĐP162281	\N	Antôn	Đỗ Hoàng Thiên Phú	2016-05-04 00:00:00	\N	0966035785	\N	264/13 Lê Văn Quới, BHHA, Bình Tân	16	t	2025-09-10 16:23:54.543	2025-09-19 15:36:24.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
913	DP172541	\N	Vincente	Đỗ Hoàng Phúc	2017-07-26 00:00:00	\N	0902306919	0917565614	173/29 Thoại Ngọc Hầu, Phú Thạnh	10	t	2025-09-10 16:23:54.771	2025-09-19 13:40:55.25	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
813	LN162519	\N	Catarina	Lương Thiện Nhi	2016-10-21 00:00:00	\N	0703474118	\N	Sơ Mân Côi	14	t	2025-09-10 16:23:53.156	2025-09-19 13:40:51.994	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
447	TK142457	\N	\N	Trương Thiên Kim	2014-11-01 00:00:00	\N	\N	0886029797	104A Nguyễn Sơn, PTH, Tân Phú	18	t	2025-09-10 16:23:45.507	2025-09-19 13:41:10.433	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
616	NL162548	\N	Phêrô	Nguyễn Trần Ân Lộc	2016-07-24 00:00:00	\N	0374609013	0389600679	413/34B Lê Văn Quới, BTĐ	18	t	2025-09-10 16:23:48.737	2025-09-19 13:40:44.767	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
468	NK172351	\N	Gioakim	Nguyễn Minh Khang	2017-08-31 00:00:00	\N	0335163986	0379724611	114/3 đường số 6, BHHA, Bình Tân	13	t	2025-09-10 16:23:45.953	2025-09-19 13:40:40.95	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
130	TA112150	\N	Têrêsa	Trần Ngọc Thiên Ân	2011-03-10 00:00:00	\N	0902717465	\N	\N	41	t	2025-09-10 16:23:39.248	2025-09-19 13:40:28.872	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
93	TA172366	\N	\N	Tô Quỳnh Anh	2017-02-19 00:00:00	\N	0902412866	0902612866	285 Lê Sao, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:38.736	2025-09-19 13:40:27.055	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
317	DH122558	\N	Maria	Đinh Gia Hân	2012-08-30 00:00:00	\N	0906954980	0985659590	152/17/1B Lý Thánh Tông, Hiệp Tân	19	t	2025-09-10 16:23:42.278	2025-09-19 13:40:34.948	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
221	ĐD152241	\N	Phaolô	Đỗ Đức Duy	2015-05-18 00:00:00	\N	0933855466	\N	158/29 Phan Anh, Tân Thới Hòa, Bình Tân	20	t	2025-09-10 16:23:40.497	2025-09-19 13:40:32.892	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
362	BH152416	\N	Giuse	Bạch Trung Hiếu	\N	\N	\N	\N	\N	3	t	2025-09-10 16:23:43.04	2025-09-19 13:40:36.656	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
459	LK132259	\N	Giuse	Lâm Bảo Khang	2013-12-16 00:00:00	\N	0908435449	\N	13/26 Lương Thế Vinh, Tân Thới Hòa, Tân Phú	31	t	2025-09-10 16:23:45.723	2025-09-19 13:40:39.166	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
585	NL152119	\N	Maria	Nguyễn Trần Gia Linh	2015-02-10 00:00:00	\N	0916110864	\N	62/5/16 Đường 5D, BHHA, Bình Tân	20	t	2025-09-10 16:23:48.21	2025-09-19 13:40:44.089	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
974	NQ152211	\N	Phêrô	Nguyễn Thanh Quân	2015-11-11 00:00:00	\N	0349195814	\N	213 Nguyễn Sơn, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:23:55.971	2025-09-21 08:23:12.469	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
652	NM152238	\N	Đaminh	Nguyễn Văn Minh	2015-12-30 00:00:00	\N	0937246247	\N	59/5 Đường số 8, BHHA, Bình Tân	20	t	2025-09-10 16:23:49.336	2025-09-19 13:40:46.117	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
418	TH122129	\N	Gioakim	Trần Tuấn Hưng	2012-06-22 00:00:00	\N	0908925418	0909850485	214 Lê Cao Lãng, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:23:44.963	2025-09-19 13:41:10.427	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
410	VH122184	\N	Giuse	Vương Gia Huy	2012-11-15 00:00:00	\N	0913902830	\N	260A ĐS 8 , BHHA, Bình Tân	35	t	2025-09-10 16:23:44.842	2025-09-19 13:40:38.605	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
853	TN102177	\N	Têrêsa	Trần Mỹ Như	2010-10-16 00:00:00	\N	0938133550	0908897637	6/19 ĐS 14 A, BHHA, Bình Tân	45	t	2025-09-10 16:23:53.796	2025-09-19 13:40:52.166	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
358	VH122178	\N	Maria	Vương Nguyễn Ngọc Hân	2012-07-01 00:00:00	\N	0973816646	0933243467	128/4/31/1 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	38	t	2025-09-10 16:23:42.972	2025-09-19 13:40:36.927	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
952	PP122136	\N	Raphael	Phạm Hoàng Minh Phương	2012-11-07 00:00:00	\N	0906752157	64020959	343/20 Trần Thủ Độ	38	t	2025-09-10 16:23:55.507	2025-09-19 13:40:55.339	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1036	NT122173	\N	Giuse	Nguyễn Hoàng Hữu Tiến	2012-10-30 00:00:00	\N	\N	0983299231	136/9 Liên khu 10-11, Bình Trị Đông	36	t	2025-09-10 16:23:56.983	2025-09-19 13:40:59.098	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1078	NT152318	\N	Maria	Nguyễn Hoàng Phương Thảo	2015-08-01 00:00:00	\N	0909510438	0906872937	62 Đường số 14A, BHHA, Bình Tân	23	t	2025-09-10 16:23:57.569	2025-09-19 13:40:59.513	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1219	HT112271	\N	Maria	Hoàng Thị Bảo Trinh	2011-03-14 00:00:00	\N	0974514831	\N	273 Phan Anh, BTĐ, Bình Tân	31	t	2025-09-10 16:23:59.5	2025-09-19 13:41:04.512	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1264	NV132316	\N	Giuse	Nguyễn Bảo Việt	2013-05-28 00:00:00	\N	3848287967	\N	15/4 Ao Đôi, BTĐA, Bình Tân	25	t	2025-09-10 16:24:00.135	2025-09-19 13:41:05.142	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
41	VA132132	\N	Phêrô	Vũ An	2013-04-24 00:00:00	\N	0902737647	\N	165 Bình Long, BHHA, Bình Tân	28	t	2025-09-10 16:23:38.034	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
424	ĐH152273	\N	Têrêsa	Đỗ Trần Thiên Hương	2015-06-28 00:00:00	\N	0973500911	\N	49/29F Đường số 3, BHHA, Bình Tân	22	t	2025-09-10 16:23:45.074	2025-09-19 13:41:08.432	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1051	NT122116	\N	Phêrô	Nguyễn Thiên Tuấn	2012-01-02 00:00:00	\N	0938175253	\N	15P Đường số 6, BHHA, Bình Tân	36	t	2025-09-10 16:23:57.196	2025-09-19 13:41:10.73	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
968	LQ192548	\N	Giuse	Lê Hoàng Quân	\N	\N	0908255909	0988293719	150 Đỗ Bí, Phú Thạnh	6	t	2025-09-10 16:23:55.824	2025-09-19 13:40:55.923	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
501	NK192541	\N	Đaminh	Nguyễn Duy Khánh	2019-02-01 00:00:00	\N	0932160240	0938921514	22/6/7 đường 5C, BHHA	6	t	2025-09-10 16:23:46.715	2025-09-19 13:40:40.71	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
159	TB122189	\N	Giuse	Tăng Gia Bảo	2011-07-12 00:00:00	\N	\N	0989765911	\N	36	t	2025-09-10 16:23:39.643	2025-09-19 13:40:20.926	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
190	PC112439	\N	Anna	Phạm Ngọc Bảo Châu	2011-07-16 00:00:00	\N	\N	\N	\N	42	t	2025-09-10 16:23:40.073	2025-09-19 13:40:20.879	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
280	BĐ132113	\N	Phêrô	Bùi Minh Đức	2013-10-10 00:00:00	\N	0925436507	\N	43 Đường 5F, BHHA, Bình Tân	26	t	2025-09-10 16:23:41.621	2025-09-19 13:40:34.503	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1328	VY162319	\N	Maria	Vũ Đoàn Như Ý	2016-03-19 00:00:00	\N	0918232468	0967090567	6F Lê Quốc Trinh, Phú Thọ Hòa, Tân Phú	17	t	2025-09-10 16:24:01.405	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
186	NC172476	\N	Maria	Nguyễn Bảo Châu	2017-01-12 00:00:00	\N	0989446692	\N	104 Đỗ Bí, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:23:40.03	2025-09-21 03:31:18.082	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
50	ĐA162314	\N	Têrêsa	Đặng Hoàng Tú Anh	2016-01-20 00:00:00	\N	\N	\N	\N	13	t	2025-09-10 16:23:38.149	2025-09-19 13:40:26.759	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
133	TB162369	\N	Martino	Trần Tùng Bách	2016-10-12 00:00:00	\N	0975486281	0903150759	10/8 Thoại Ngọc Hầu, Tân Thành, Tân Phú	17	t	2025-09-10 16:23:39.291	2025-09-21 08:19:32.584	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1023	NT142235	\N	Phaolô	Nguyễn Phúc Tâm	2014-01-26 00:00:00	\N	0985700817	0938751324	212/1/8B Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:56.78	2025-09-19 13:40:57.686	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
232	TD122185	\N	Maria	Trần Hồng Duyên	2012-01-16 00:00:00	\N	0989111386	\N	128/3/14 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	38	t	2025-09-10 16:23:40.662	2025-09-19 13:40:31.346	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
100	TA182443	\N	Têrêsa	Trần Ngọc Trâm Anh	2018-01-25 00:00:00	\N	0909459928	0932080079	58B Văn Cao	3	t	2025-09-10 16:23:38.831	2025-09-19 13:40:27.259	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
154	NB122189	\N	Batôlômêô	Nguyễn Lê Gia Bảo	2012-02-02 00:00:00	\N	0907732891	\N	\N	25	t	2025-09-10 16:23:39.57	2025-09-19 13:40:29.285	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
868	LP152114	\N	Phêrô	Lương Hoàng Gia Phát	2015-09-30 00:00:00	\N	0909894457	0909817229	1 Văn Cao, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:54.05	2025-09-19 13:40:53.742	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
231	ND132177	\N	Maria	Nguyễn Quỳnh Duyên	2013-10-19 00:00:00	\N	0938362468	\N	20 ĐS 13A, BHHA, Bình Tân	31	t	2025-09-10 16:23:40.645	2025-09-19 13:40:32.322	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
374	NH122194	\N	Phaolo	Nguyễn Huy Hoàng	2012-12-16 00:00:00	\N	0986186619	0984461939	741/6 Hương Lộ 2, Btđa, Bình Tân	38	t	2025-09-10 16:23:43.242	2025-09-19 13:40:36.661	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
169	TB112163	\N	Vinh Sơn	Trịnh Thiên Bảo	2011-06-22 00:00:00	\N	0909860950	\N	24 ĐS 1A, Bhh, Bình Tân	37	t	2025-09-10 16:23:39.796	2025-09-19 13:41:10.374	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
416	NH152236	\N	Vinh Sơn	Nguyễn Quốc Hưng	2015-01-18 00:00:00	\N	0906086008	0979452760	152 Lê Văn Quới, BHHA, Bình Tân	22	t	2025-09-10 16:23:44.933	2025-09-19 13:40:38.561	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
895	PP122169	\N	Emmanuel	Phạm Lê Hoàng Phong	2011-09-06 00:00:00	\N	\N	\N	\N	38	t	2025-09-10 16:23:54.48	2025-09-19 13:40:38.979	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
671	GM102120	\N	Anna	Giòng Thị Trà My	2010-04-04 00:00:00	\N	0967878302	\N	2/3C Đường số 5, BHH A, Bình Tân	45	t	2025-09-10 16:23:49.642	2025-09-19 13:40:46.402	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
737	ĐN122137	\N	Maria	Đinh Bảo Ngọc	2012-08-14 00:00:00	\N	0909993202	0907797263	60/69 Trương Phước Phan, BTĐ, Bình Tân 	35	t	2025-09-10 16:23:50.762	2025-09-19 13:41:08.824	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
772	LN182480	\N	Têrêsa	Lê Hoàng Thảo Nguyên	2018-04-09 00:00:00	\N	0979690242	0383908499	230/28/06 Mã Lò, BTĐ A, BT	1	t	2025-09-10 16:23:51.531	2025-09-19 13:40:50.093	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
863	HP182401	\N	GioaKim	Huỳnh Tuấn Phát	\N	\N	0989011862	0933450876	32/15A đường số 13A, BHHA, BT	1	t	2025-09-10 16:23:53.948	2025-09-19 13:40:53.447	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
969	NQ122182	\N	Giuse	Nguyễn Hoàng Quân	\N	\N	\N	\N	\N	35	t	2025-09-10 16:23:55.847	2025-09-19 13:40:55.437	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
254	HD142177	\N	Luy	Hồ Thành Đạt	2014-04-04 00:00:00	\N	\N	\N	\N	21	t	2025-09-10 16:23:40.991	2025-09-19 13:40:32.905	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
79	NA102163	\N	Têrêsa	Nguyễn Quỳnh Anh	2010-11-12 00:00:00	\N	0906487087	0938362468	20 Đường 13A, BHHA, Bình Tân	42	t	2025-09-10 16:23:38.542	2025-09-21 02:16:28.44	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1177	TT122171	\N	Têrêsa	Trần Thùy Linh Thư	2012-10-23 00:00:00	\N	0902809345	\N	\N	36	t	2025-09-10 16:23:58.953	2025-09-19 13:41:02.764	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
539	NK152131	\N	Gioakim	Nguyễn Minh Khôi	2015-04-04 00:00:00	\N	0379724611	\N	114/3 đường số 6, BHHA, Bình Tân	21	t	2025-09-10 16:23:47.387	2025-09-19 13:40:42.352	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
804	NN102152	\N	Đa Minh	Nguyễn Phạm Minh Nhật	2010-06-08 00:00:00	\N	0933393825	\N	174A Lê Niêm, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:53.013	2025-09-19 13:40:51.692	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
828	TN172474	\N	Maria	Trần Phương Nhi	2017-01-03 00:00:00	\N	0982415495	\N	14 Nguyễn Lý, HT, Tân Phú	12	t	2025-09-10 16:23:53.372	2025-09-21 03:31:18.082	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1021	NT152348	\N	Augustino	Nguyễn Hoàng Tâm	2015-06-17 00:00:00	\N	0366013795	0366013795	113 Đỗ Bí, Phú Thạnh, Tân Phú	18	t	2025-09-10 16:23:56.757	2025-09-19 13:40:58.956	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
198	NC122170	\N	Anna	Nguyễn Thị Bảo Chi	2012-11-03 00:00:00	\N	0989902559	\N	155/8 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	36	t	2025-09-10 16:23:40.179	2025-09-19 13:40:20.93	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
873	NP182514	\N	Giuse	Nguyễn Lê Gia Phát	2018-08-24 00:00:00	\N	0937496229	0907732891	31/3 Phú Thọ Hoà, Phú Thọ Hoà	4	t	2025-09-10 16:23:54.121	2025-09-19 13:40:53.997	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
71	NA162337	\N	Maria	Nguyễn Ngọc Quỳnh Anh	2016-01-22 00:00:00	\N	0362115353	0948305959	29/9 Đình Tân Khai, BTĐ, Bình Tân	19	t	2025-09-10 16:23:38.435	2025-09-20 04:02:32.746	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	2	0
366	NH152315	\N	Gioan	Nguyễn Minh  Hiếu	2015-10-16 00:00:00	\N	\N	\N	168 Lê Thiệt, Phú Thọ Hòa, Tân Phú	13	t	2025-09-10 16:23:43.104	2025-09-19 13:40:37.093	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
103	TA092157	\N	Maria	Trần Quỳnh Anh	2009-01-01 00:00:00	\N	0913625805	\N	416/4 Thạch Lam, Phú Thạnh, q TP	45	t	2025-09-10 16:23:38.871	2025-09-19 13:40:27.232	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
131	VA122154	\N	Lucia	Vũ Hồng Ân	2012-04-30 00:00:00	\N	0938573546	0934010947	111/47 ĐS 1, BHHA, Bình Tân	38	t	2025-09-10 16:23:39.259	2025-09-19 13:40:29.13	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
222	LD122198	\N	Phêrô	Lê Nguyễn Anh Duy	2012-04-04 00:00:00	\N	0909527830	0906900392	356D Bình Long, BHHA, Bình Tân	35	t	2025-09-10 16:23:40.513	2025-09-19 13:40:31.242	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
847	DN122172	\N	Maria	Dương Quỳnh Như	2012-08-20 00:00:00	\N	0836973999	0933399050	\N	36	t	2025-09-10 16:23:53.692	2025-09-19 13:40:53.586	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	2
385	HH092273	\N	Giuse	Hoàng Duy Huấn	2009-05-29 00:00:00	\N	0974514831	\N	273 Phan Anh, BTĐ, Bình Tân	31	t	2025-09-10 16:23:44.387	2025-09-19 13:40:36.931	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
473	NK182512	\N	Phaolô	Nguyễn Phúc Khang	2018-12-30 00:00:00		0979738088	0977945093	22/4 đường số 9A, BHHA, Bình Tân	5	t	2025-09-10 16:23:46.069	2025-09-19 13:40:40.905	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
580	BL122117	\N	Maria	Bùi Thị Ngọc Linh	2012-10-06 00:00:00	\N	0903024022	\N	289 Nguyễn Sơn, Phú Thạnh	36	t	2025-09-10 16:23:48.127	2025-09-19 13:40:42.958	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
601	ĐL122197	\N	Gioan	Đỗ Ngọc Long	2012-08-15 00:00:00	\N	0933453287	\N	278 Hòa Bình, Hiệp Tân, Tân Phú	35	t	2025-09-10 16:23:48.491	2025-09-19 13:40:44.184	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
187	NC162251	\N	Maria	Nguyễn Ngọc Bảo Châu	2016-12-03 00:00:00	\N	0936432255	\N	257 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	15	t	2025-09-10 16:23:40.041	2025-09-19 13:40:30.523	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
489	TK132196	\N	Giuse 	Trần Vũ Hoàng Khang	\N	\N	\N	\N	\N	27	t	2025-09-10 16:23:46.485	2025-09-19 13:40:40.46	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
517	NK142293	\N	Phêrô	Nguyễn Minh Khoa	2014-12-13 00:00:00	\N	0931641463	\N	61/11 Miếu Bình Đông, BHHA, Bình Tân	27	t	2025-09-10 16:23:46.989	2025-09-19 13:40:42.612	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
854	TN112163	\N	Têrêsa	Trần Ngọc Quỳnh Như	2011-01-29 00:00:00	\N	0931149680	0906795529	38/6 ĐS 1A,  BHHA, Bình Tân	41	t	2025-09-10 16:23:53.815	2025-09-19 13:40:52.061	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
112	HA132149	\N	Phêrô	Hoàng Trần Thiên Ân	2013-11-15 00:00:00	\N	0909825891	0907914463	242/64 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	31	t	2025-09-10 16:23:38.986	2025-09-19 13:41:08.872	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
460	LK122113	\N	Phêrô	Lê Phúc Khang	2012-09-11 00:00:00	\N	0772989899	0775375472	42/24/47,16A,BHHA , Bình Tân	37	t	2025-09-10 16:23:45.757	2025-09-19 13:40:39.443	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1122	HT102173	\N	Vinh Sơn	Huỳnh Hưng Thịnh	2010-04-08 00:00:00	\N	0908784728	0961931748	73 Lê Quốc Trinh, Phú Thọ Hòa, Tân Phú	45	t	2025-09-10 16:23:58.19	2025-09-19 13:41:01.309	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
52	ĐA122139	\N	Maria	Đoàn Vy Anh	2012-11-08 00:00:00	\N	0775571977	0937076011	18 Đinh Liệt, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:38.177	2025-09-19 13:40:26.877	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
547	PK122172	\N	Maria	Phan Mai Khôi	2012-09-18 00:00:00	\N	0918336700	0937585533	165/11 Trần Quang Cơ, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:47.529	2025-09-19 13:41:08.59	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
372	LH122111	\N	Martino	Lê Phi Hoàng	2012-11-12 00:00:00	\N	0938925736	0383908499	92/3/9 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	38	t	2025-09-10 16:23:43.209	2025-09-19 13:40:37.117	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
354	TH182420	\N	Matta	Trương Khả Hân	2018-04-20 00:00:00	\N	0937696145	\N	572/2A Âu Cơ, Tân Bình	3	t	2025-09-10 16:23:42.907	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
294	NG102112	\N	Maria	Nguyễn Hương Giang	2010-04-05 00:00:00	\N	0915479037	0822359716	22 ĐS 5,  BHHA, Bình Tân	45	t	2025-09-10 16:23:41.908	2025-09-19 13:41:10.389	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
238	ND122143	\N	Luy	Nguyễn Thái Dương	2012-09-04 00:00:00	\N	0903961995	0917271238	116 Trần Thủ Độ, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:40.764	2025-09-19 13:40:20.908	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
926	NP142115	\N	Phaolo	Nguyễn Cửu Thiên Phúc	2014-08-25 00:00:00	\N	0909257327	0908684004	31/71/31 Đường số 3, BHHA, Bình Tân	26	t	2025-09-10 16:23:54.967	2025-09-19 13:40:55.338	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
239	PD122129	\N	Maria	Phạm Thùy Dương	\N	\N	\N	\N	\N	26	t	2025-09-10 16:23:40.794	2025-09-19 13:40:20.851	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
396	NH172313	\N	Phêrô	Nguyễn Phạm Gia Huy	2017-07-22 00:00:00	\N	0912527504	0933393825	174A Lê Niệm, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:44.574	2025-09-19 15:36:24.806	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
762	TN192535	\N	Têrêsa Maria	Trần Vũ Thiên Ngọc	2019-10-19 00:00:00	\N	0935158816	0901375992	5 đường số 5A, BHA	6	t	2025-09-10 16:23:51.347	2025-09-19 13:40:49.697	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
210	ND182417	\N	Maria	Nguyễn Huyền Diệu	2018-12-06 00:00:00	\N	0984948617	0353448345	222 Đường số 8, BHHA, BT	2	t	2025-09-10 16:23:40.347	2025-09-19 13:40:30.99	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
235	HD102443	\N	Phêrô	Hà Phùng Dương	2010-10-22 00:00:00	\N	0976166966	0967671869	292 Bình Trị Đông, BTĐ A, Bình Tân	19	t	2025-09-10 16:23:40.711	2025-09-21 09:18:29.528	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
721	TN172317	\N	Maria Têrêsa	Trần Vũ Thiên Ngân	2017-11-13 00:00:00	\N	0935158816	\N	5 Đường số 5A, BHHA, Bình Tân	12	t	2025-09-10 16:23:50.499	2025-09-21 03:31:18.082	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
653	NM172313	\N	Phêrô	Nguyễn Văn Công Minh	2017-07-20 00:00:00	\N	0935533144	0912436115	44/32/38A Trương Phước Phan, BTĐ, Bình Tân	13	t	2025-09-10 16:23:49.354	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
685	NM082150	\N	Têrêsa	Nguyễn Trần Hải My	2008-10-07 00:00:00	\N	0903171891	0764213606	341/44D Lạc Long Quân, 5, Q11	51	t	2025-09-10 16:23:49.88	2025-09-19 13:40:46.493	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
44	BA142130	\N	Maria	Bùi Trâm Anh	2014-08-05 00:00:00	0909993243	0909993243	0909993243	5/5 đường A, phường Phú Thạnh, quận Tân Phú, HCM \n	27	t	2025-09-10 16:23:38.066	2025-09-19 13:40:26.915	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
227	PD132394	\N	Giuse	Phạm Minh Duy	2013-11-26 00:00:00	\N	0938032832	\N	285/7A Lê Văn Quới, BTĐ, Bình Tân	23	t	2025-09-10 16:23:40.589	2025-09-19 13:40:32.421	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
264	VĐ152385	\N	Antôn	Vũ Trọng Tuấn Đạt	2015-01-13 00:00:00	\N	0907225586	0916584848	62/17/33A Đường số 5A, BHHA, Bình Tân	23	t	2025-09-10 16:23:41.216	2025-09-19 13:40:32.841	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
292	PG142119	\N	Martino	Phạm Hoàng Gia	2014-04-20 00:00:00	\N	0773000817	\N	337/4 Trần Thủ Độ, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:41.875	2025-09-19 13:40:34.664	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
433	NK182422	\N	Toma	Nguyễn Thế Kiện	\N	\N	0389910091	0909281086	267 Lê Sao, Phú Thạnh, Tân Phú	2	t	2025-09-10 16:23:45.253	2025-09-19 13:40:39.128	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1100	TT102179	\N	Antôn	Trần Nguyễn Phúc Thiên	2010-03-29 00:00:00	\N	0989784728	\N	3/20 Văn Cao, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:57.88	2025-09-19 13:41:00.89	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
614	TL122164	\N	Phaolo	Trịnh Vũ Long	2012-07-18 00:00:00	\N	0902882226	0982178401	2/10 ĐS 5E, BHHA, Bình Tân	35	t	2025-09-10 16:23:48.705	2025-09-19 13:40:44.64	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
319	ĐH102174	\N	Maria	Đoàn Nguyễn Gia Hân	2010-03-23 00:00:00	\N	0983390018	0983390018	4 Trần Thủ Độ, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:42.313	2025-09-19 13:40:35.026	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
549	TK092155	\N	Giuse	Trần Hoàng Minh Khôi	2009-03-24 00:00:00	\N	0903841919	0938936066	75 Đường 8B, BHHA, Bình Tân	45	t	2025-09-10 16:23:47.562	2025-09-19 13:40:42.904	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
900	HP102133	\N	Antôn	Hoàng Anh Phú	2010-08-27 00:00:00	\N	0933157379	0978000332	138B ĐS 8, BHHA, Bình Tân	35	t	2025-09-10 16:23:54.557	2025-09-19 13:40:54.001	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
890	NP112113	\N	Giuse	Nguyễn Chấn Phong	2011-03-09 00:00:00	\N	0986680247	0982556970	133/65 Gò Dầu, Tân Quý, Tân Phú	42	t	2025-09-10 16:23:54.405	2025-09-19 13:40:53.741	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1090	TT172337	\N	Maria	Trần Khánh Thi	2017-02-05 00:00:00	\N	0986046463	0978864253	179 Thạch Lam, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:57.737	2025-09-19 13:40:59.51	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
522	PK132257	\N	Gioan	Phạm Minh Khoa	2013-01-01 00:00:00	\N	0334668004	0343256559	1K Đường số 1A, BHHA, Bình Tân	26	t	2025-09-10 16:23:47.081	2025-09-19 13:40:42.309	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1224	HT102118	\N	Maria	Hồ Ngọc Thanh Trúc	2010-02-24 00:00:00	\N	0987685967	\N	15/27 Lô Tư, BHHA, Bình Tân	45	t	2025-09-10 16:23:59.565	2025-09-19 13:41:04.564	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
739	LN172494	\N	Anna	Lê Nguyễn Bảo Ngọc	2017-10-10 00:00:00	\N	0902007339	\N	205/36 Bình Trị Đông A, BT	12	t	2025-09-10 16:23:50.793	2025-09-21 03:31:18.085	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
584	NL162334	\N	Maria	Nguyễn Mỹ Linh	2016-07-09 00:00:00	\N	0963635000	0909675822	116 Trần Thủ Độ, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:23:48.192	2025-09-21 08:23:12.469	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
293	VG122134	\N	Giuse	Vũ Hoàng Gia	\N	\N	\N	\N	\N	37	t	2025-09-10 16:23:41.89	2025-09-19 13:40:20.851	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
767	VN132285	\N	Maria	Vũ Thị Ánh Ngọc	2013-07-05 00:00:00	\N	\N	\N	Sơ Mân Côi	33	t	2025-09-10 16:23:51.45	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1296	NV172406	\N	Maria	Nguyễn Nhật Vy	\N	\N	0909210883	0944248824	35 Phan Văn Năm, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:24:00.61	2025-09-21 02:35:41.62	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
529	LK132184	\N	Laurenxô	Lê Hoàng Duy Khôi	2013-05-02 00:00:00	\N	0903684479	90840930	146 Lê Lâm, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:23:47.196	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
268	ND192523	\N	Laurenso	Nguyễn Quang Đăng	2019-09-12 00:00:00	\N	0382733149	0783605614	152 Lê Cao Lãng, Phú Thạnh	6	t	2025-09-10 16:23:41.338	2025-09-19 13:41:10.428	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1305	PV182409	\N	Anna	Phan Nguyễn Minh Vy	2018-09-09 00:00:00	\N	0869070207	0965329686	49 Lê Vĩnh Hoà, Phú Thọ Hoà, Tân Phú	1	t	2025-09-10 16:24:00.775	2025-09-19 13:41:06.629	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
368	VH182419	\N	Phêrô	Vương Trung Hiếu	2018-02-19 00:00:00	\N	0933800265	0908892524	CC Phú Thạnh 53 Nguyễn Sơn, Phú Thạnh, Tân Phú	2	t	2025-09-10 16:23:43.138	2025-09-19 13:40:36.915	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1300	PV172486	\N	Maria	Phạm Khánh Vy	\N	\N	0909872905	0976610717	33 Thoại Ngọc Hầu, Hoà Thạnh, Tân Phú	14	t	2025-09-10 16:24:00.671	2025-09-19 13:41:07.261	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
241	ND172549	\N	Giuse	Nguyễn Nhất Đam	2017-12-18 00:00:00	\N	\N	\N	58/26 Miếu Gò Xoài, BHHA	4	t	2025-09-10 16:23:40.827	2025-09-19 13:40:32.895	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
348	TH112199	\N	Maria	Thạch Ngọc Hân	2011-09-23 00:00:00	\N	0902626030	0986503607	107/26 Phan Văn Năm, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:42.8	2025-09-19 13:40:35.05	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
449	PK132333	\N	Maria	Phạm Như Kỳ	2013-12-29 00:00:00	\N	0367193542	\N	186/60 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	23	t	2025-09-10 16:23:45.541	2025-09-19 13:40:39.061	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
452	NK182423	\N	Vincente	Nguyễn Trần Quang Khải	\N	\N	0932417286	0763139949	135/41 Lê Văn Quới, BTĐ, BT	1	t	2025-09-10 16:23:45.59	2025-09-19 13:40:39.299	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
298	NH082121	\N	Maria	Nguyễn Ngọc Hà	2008-01-08 00:00:00	\N	0383118098	0397660690	26/19 ĐS 1, BHHA, Bình Tân	51	t	2025-09-10 16:23:41.973	2025-09-19 13:40:34.699	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1331	LY142257	\N	Maria	Lưu Nguyễn Hải Yến	2014-02-07 00:00:00	\N	0833121952	\N	48/20 Phạm Văn Xảo, Phú Thọ Hòa, Tân Phú	25	t	2025-09-10 16:24:01.453	2025-09-19 13:41:08.817	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
483	TK182407	\N	Vincente	Trần Duy Khang	2018-05-10 00:00:00	\N	0988918885	0908110068	119 Bình Long, BHHA, BT	1	t	2025-09-10 16:23:46.321	2025-09-19 13:40:41.063	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
889	LP082141	\N	Gioan	Lê Thiên Phong	2008-01-22 00:00:00	\N	0909948014	0909243144	8/31 Lê Văn Quới, BHHA, Bình Tân,Tp	37	t	2025-09-10 16:23:54.39	2025-09-19 13:40:53.538	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
850	NN102137	\N	Madalêna	Nguyễn Thị Bảo Như	2010-10-30 00:00:00	\N	0949506410	0828866356	9/6 Miếu Bình Đông ,  BHHA, Bình Tân	45	t	2025-09-10 16:23:53.743	2025-09-19 13:40:52.118	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
419	TH142251	\N	Antôn	Trịnh Gia Hưng	2014-08-22 00:00:00	\N	0915383483	0348541674	704/60/16 Hương Lộ 2, BTĐA, Bình Tân	26	t	2025-09-10 16:23:44.976	2025-09-19 13:40:38.623	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1186	NT162246	\N	Maria	Nguyễn Hoàng Nhã Thy	2016-10-10 00:00:00	\N	0907970716	\N	7 Đỗ Đức Dục, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:59.076	2025-09-19 13:41:03.01	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1043	NT122192	\N	Lucia	Nguyễn Phan Tina	2012-11-01 00:00:00	\N	0925678112	\N	85 Đỗ Bí, Phú Thạnh, Tân Phú	36	t	2025-09-10 16:23:57.094	2025-09-19 13:40:57.822	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
635	NM172353	\N	Anna	Nguyễn Mai Gia Mẫn	2017-12-28 00:00:00	\N	\N	\N	\N	11	t	2025-09-10 16:23:49.061	2025-09-19 13:40:46.08	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
320	ĐH172311	\N	Maria	Đỗ Nguyễn Gia Hân	2017-11-03 00:00:00	\N	0939284730	\N	43 Lê Lăng, Phú Thọ Hòa, Tân Phú	11	t	2025-09-10 16:23:42.329	2025-09-19 13:40:20.87	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1303	PV092555	\N	Maria	Phạm Thảo Vy	2009-08-15 00:00:00	\N	0982922338	\N	303 Vườn Lài, Phú Thọ Hoà	34	t	2025-09-10 16:24:00.728	2025-09-19 13:41:06.661	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
831	VN182454	\N	Isave	Võ Hoàng Thiên Nhi	2018-05-28 00:00:00	\N	0944176190	0989720440	99/40 Đường số 14, BHH A, Bình Tân	2	t	2025-09-10 16:23:53.428	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
376	NH162451	\N	Phanxico	Nguyễn Minh Hoàng	2016-11-07 00:00:00	\N	9098738189	0933992494	22/6/5 Đường số 5C, BHH A, Bình Tân	17	t	2025-09-10 16:23:43.269	2025-09-21 08:19:32.584	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
316	ĐH092119	\N	Maria	Đặng Kim Gia Hân	2009-01-18 00:00:00	\N	0932929242	0906183268	 39/31/20 ĐS 3, BHHA, Bình Tân	50	t	2025-09-10 16:23:42.262	2025-09-19 13:40:20.958	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
225	ND172451	\N	Giuse	Nguyễn Khương Duy	2017-12-23 00:00:00	\N	0937147443	0933654240	334 Thạch Lam, PT, Tân Phú	13	t	2025-09-10 16:23:40.562	2025-09-19 13:41:08.428	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
470	NK172337	\N	Giuse	Nguyễn Như Phúc Khang	2017-06-12 00:00:00	\N	\N	\N	\N	13	t	2025-09-10 16:23:45.99	2025-09-21 08:34:58.361	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1061	TT142545	\N	Augustino	Trần Quốc Thái	2014-02-08 00:00:00	\N	0967526403	0986225253	26/3 Thạch Lam, Phú Thạnh	17	t	2025-09-10 16:23:57.342	2025-09-21 08:23:12.47	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
205	ND172492	\N	Maria	Nguyễn Ngọc Thiên Di	2017-04-08 00:00:00	\N	0772459279	0937731683	24/07 Trương Phước Phan, BTĐ, BT	13	t	2025-09-10 16:23:40.273	2025-09-21 08:38:43.795	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1310	TV142258	\N	Têrêsa	Trần Huỳnh Phương Vy	2014-08-22 00:00:00	\N	0911632424	\N	178 Lê Lâm, Phú Thạnh, Tân Phú	19	t	2025-09-10 16:24:00.916	2025-09-19 13:41:11.198	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
645	NM172533	\N	Phêrô	Nguyễn Hoàng Minh	2017-07-30 00:00:00	\N	0918533559	0903080507	233A Lê Cao Lãng, Phú Thạnh	14	t	2025-09-10 16:23:49.218	2025-09-19 13:40:45.913	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	1
370	BH182454	\N	Gioan Baotixita	Bùi Gia Hoàng	2018-04-03 00:00:00	\N	0931797811	0902780636	52/24 Đường số 12, BHHA, Bình Tân	1	t	2025-09-10 16:23:43.168	2025-09-19 13:40:36.984	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
729	ĐN142274	\N	Maria	Đinh Phạm Thảo Nghi	2014-10-25 00:00:00	\N	0907042398	\N	8/8 Hoàng Ngọc Phách, Phú Thọ Hòa, Tân Phú	25	t	2025-09-10 16:23:50.629	2025-09-19 13:40:48.271	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
484	TK142248	\N	Vinh Sơn	Trần Gia Khang	2014-10-26 00:00:00	\N	0972972780	\N	386A Lê Văn Quới, BHHA, Tân Phú	25	t	2025-09-10 16:23:46.357	2025-09-19 13:40:40.954	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
390	ĐH132157	\N	Phêrô	Đoàn Hoàng Gia Huy	2013-01-14 00:00:00	\N	0973336654	0354622774	31A Lê Thiệt, Phú Thọ Hoà, Tân Phú	31	t	2025-09-10 16:23:44.468	2025-09-19 13:40:38.568	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
800	LN122135	\N	Gioan Baotixita	Lê Quang Nhật	2012-05-14 00:00:00	\N	0982227427	\N	A710 Cc Phú Thạnh, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:23:52.942	2025-09-19 13:40:51.744	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
295	TG122187	\N	Maria	Trần Khánh Giang	2012-08-13 00:00:00	\N	0918011636	9174429932	4 Trịnh Đình Thảo	35	t	2025-09-10 16:23:41.928	2025-09-19 13:40:34.496	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
423	DH182574	\N	Maria	Đinh Trần Lan Hương	2018-06-23 00:00:00	\N	0908915197	0764631889	137/1 Bình Long, BHHA	4	t	2025-09-10 16:23:45.053	2025-09-19 13:40:38.874	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
819	NN102116	\N	Têrêsa	Nguyễn Trúc Nhi	2010-11-04 00:00:00	\N	0987789881	0989222701	14 Đường 1A, BHHA, Bình Tân	45	t	2025-09-10 16:23:53.238	2025-09-19 13:40:52.38	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
982	VQ152185	\N	Phêrô	Võ Hoàng Quân	2015-12-08 00:00:00	\N	0904088712	\N	29/12/34B ĐS 8, BHHA, Bình Tân	21	t	2025-09-10 16:23:56.128	2025-09-19 13:40:57.702	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1252	BV162273	\N	Maria	Bùi Ngọc Khánh Vân	2016-10-12 00:00:00	\N	0971098908	\N	323 Lê Sao, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:59.955	2025-09-19 13:41:06.566	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1104	VT162223	\N	Đaminh	Vũ Quốc Thiên	2016-09-25 00:00:00	\N	0902964665	\N	100/19 Đường 18B, BHHA, Bình Tân	15	t	2025-09-10 16:23:57.945	2025-09-19 13:41:01.338	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
869	LP172331	\N	Phaolô	Lưu Gia Phát	2017-04-14 00:00:00	\N	0979641792	0394719290	344/75/19 Chiến Lược, BTĐ A, Bình Tân	10	t	2025-09-10 16:23:54.064	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
886	DP182405	\N	Giuse	Đoàn Chấn Phong	2018-10-02 00:00:00	\N	0983410075	0902648749	184 Thạch Lam, Phú Thạnh, Tân Phú	1	t	2025-09-10 16:23:54.342	2025-09-19 13:40:53.837	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
613	TL172337	\N	Giuse	Trần Đức Long	2017-07-31 00:00:00	\N	0938954686	0819935718	10/1A Đường số 10, BHHA, Bình Tân	10	t	2025-09-10 16:23:48.692	2025-09-19 13:40:44.649	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1062	TT122238	\N	Giuse	Trịnh Công Thái	2013-06-17 00:00:00	\N	0979623351	\N	\N	25	t	2025-09-10 16:23:57.356	2025-09-19 13:40:59.092	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
125	NA162454	\N	Anphongxô Maria	Nguyễn Thiên Ân	2016-01-18 00:00:00	\N	0377554139	0377552439	294/2/2 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú	18	t	2025-09-10 16:23:39.175	2025-09-19 13:40:29.272	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1227	NT102133	\N	Maria	Nguyễn Trần Thanh Trúc	2010-05-21 00:00:00	\N	0779091067	0981803044	1/19/18A Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	40	t	2025-09-10 16:23:59.61	2025-09-19 13:41:04.509	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1263	NV122543	\N	Dominico	Ngô Quốc Việt	2012-02-05 00:00:00	\N	0903751147	0903145305	4/1 Miếu Bình Đông, BHHA	38	t	2025-09-10 16:24:00.121	2025-09-19 13:41:05.076	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
966	DQ092504	\N	Giuse	Đỗ Nguyễn Đức Quân	2009-11-16 00:00:00	\N	0906109103	\N	28C đường số 12, BHHA	33	t	2025-09-10 16:23:55.78	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
359	NH092473	\N	Maria	Nguyễn Ngọc Hảo Hiền	2009-05-18 00:00:00	\N	0344240310	\N	172a Thạch Lam	30	t	2025-09-10 16:23:42.989	2025-09-19 13:40:36.837	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
86	PA142236	\N	Maria	Phạm Hoàng Bảo Anh	2014-11-03 00:00:00	\N	\N	\N	\N	22	t	2025-09-10 16:23:38.639	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
352	TH122159	\N	Maria	Trần Nguyễn Gia Hân	2012-02-25 00:00:00	\N	0903886230	0898548122	161 Lê Sao, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:42.856	2025-09-19 13:40:20.932	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1249	VU132314	\N	Anna	Vũ Ngọc Phương Uyên	2013-05-24 00:00:00	\N	0919325485	\N	730/79A Hương Lộ 2, BTĐA, Bình Tân	33	t	2025-09-10 16:23:59.911	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
81	NA142151	\N	Anê	Nguyễn Trâm Anh	2014-02-02 00:00:00	\N	0971658620	0702435310	91/13 Miếu Bình Đông, BHHA, Bình Tân	16	t	2025-09-10 16:23:38.568	2025-09-19 15:36:24.8	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
780	NN142186	\N	Phêrô	Nguyễn Ngọc Khôi Nguyên	2014-01-01 00:00:00	\N	\N	\N	\N	22	t	2025-09-10 16:23:51.881	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
273	ND182556	\N	Anna	Nguyễn Đình Đình	2018-10-29 00:00:00	\N	0903690819	0909405064	5 Trần Thủ Độ, Phú Thạnh, Tân Phú	4	t	2025-09-10 16:23:41.428	2025-09-19 13:40:32.906	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1190	PT122140	\N	Têrêsa	Phạm Trương Bảo Thy	2012-09-11 00:00:00	\N	0948956695	0909448807	52 Nguyễn Sơn, CC Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:59.126	2025-09-19 13:41:04.463	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1208	HT122163	\N	Phêrô	Hoàng Anh Trí	2012-07-18 00:00:00	\N	0919062158	0932978234	18A Lê Lăng, Phú Thọ Hòa, Tân Phú	37	t	2025-09-10 16:23:59.356	2025-09-19 13:41:04.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
123	NA172448	\N	Anê	Nguyễn Phúc Thiên Ân	2017-07-13 00:00:00	\N	0983871542	0365588721	239 Hoà Bình, Hiệp Tân, Tân Phú	14	t	2025-09-10 16:23:39.149	2025-09-19 13:40:29.236	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
214	VD182481	\N	Têrêsa	Vũ Hồ Thanh Dung	2018-08-11 00:00:00	\N	0936528513	0798241559	111/47 Đường số 1, BHHA, Bình Tân	1	t	2025-09-10 16:23:40.399	2025-09-19 13:40:32.373	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
327	NH092191	\N	Anna	Ngô Gia Hân	2009-07-30 00:00:00	\N	0907861436	0387517898	94 Bình Long, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:42.457	2025-09-19 13:40:34.704	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
360	NH082125	\N	Antôn	Nguyễn Vinh Hiển	2008-05-20 00:00:00	\N	0778845203	0903597246	15/28/2 Lô Tư, BHHA, Bình Tân	50	t	2025-09-10 16:23:43.007	2025-09-19 13:40:36.671	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
365	NH192543	\N	Giuse	Nguyễn Minh Hiếu	2019-04-20 00:00:00	\N	0945451779	0909816369	204 Quách Đình Bảo, Phú Thạnh	5	t	2025-09-10 16:23:43.08	2025-09-19 13:40:37.06	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
143	HB092167	\N	Giacôbê	Hoàng Thiên Bảo	2009-06-28 00:00:00	\N	0979695579	0987799029	40/5 Trương Phước Phan, BTĐ, Bình Tân	50	t	2025-09-10 16:23:39.436	2025-09-19 13:40:28.821	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	1
841	NN172314	\N	Maria	Nguyễn Thái An Nhiên	2017-03-13 00:00:00	\N	0938068178	0866982253	237 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	13	t	2025-09-10 16:23:53.594	2025-09-19 13:40:52.219	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
796	NN072172	\N	Giuse	Nguyễn Thành Nhân	2007-03-26 00:00:00	\N	0911133332	0909911482	629 Kinh Dương Vương, Bình Tân	51	t	2025-09-10 16:23:52.876	2025-09-19 13:40:50.312	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
842	TN112182	\N	Giuse	Trương Nguyễn Hạo Nhiên	2011-01-28 00:00:00	\N	0909093491	0937676181	Cao Ốc An Bình, Phú Thọ Hòa, Tân Phú	38	t	2025-09-10 16:23:53.612	2025-09-19 13:40:52.051	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
731	NN162471	\N	Maria	Nguyễn Ngọc Tâm Nghi	2016-03-20 00:00:00	\N	0908286883	0708286883	88 Lê Lư, Phú Thọ Hoà, Tân Phú	18	t	2025-09-10 16:23:50.66	2025-09-19 13:40:48.349	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
167	TB132128	\N	Antôn	Trịnh Gia Bảo	2013-01-13 00:00:00	0915383483	0915383483	0915383483	704/80 Hương Lộ 2, Quận Bình Tân, HCM 	27	t	2025-09-10 16:23:39.76	2025-09-19 13:40:30.623	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1203	NT112116	\N	Maria	Nguyễn Ngọc Bảo Trân	2011-01-11 00:00:00	\N	0932131959	0932757578	209 Miếu Bình Đông, BHHA, Bình Tân	40	t	2025-09-10 16:23:59.297	2025-09-19 13:41:03.1	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1109	MT142115	\N	Laurenxo	Mai Bùi Xuân Thiện	2014-02-23 00:00:00	\N	0989311362	\N	216 Lê Cao Lãng, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:58.015	2025-09-19 13:41:01.37	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
192	NC142268	\N	Maria	Ngô Lan Chi	2014-10-27 00:00:00	\N	0982362840	\N	76/10/41 Nguyễn Sơn, Phú Thọ Hoà, Tân Phú	25	t	2025-09-10 16:23:40.101	2025-09-19 13:40:30.907	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1278	ĐV142155	\N	Phaolo	Đỗ Thiên Vương	2014-01-10 00:00:00	\N	0904315809	\N	343/48 Trần Thủ Độ, Phú Thạnh, Tân Phú	25	t	2025-09-10 16:24:00.351	2025-09-19 13:41:06.605	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
392	NH082187	\N	Antôn	Ngô Gia Huy	2008-03-21 00:00:00	\N	0907861436	0387517898	94 Bình Long, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:44.504	2025-09-19 13:40:21.245	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
956	TP122130	\N	Têrêsa	Trịnh Nguyễn Minh Phương	\N	\N	\N	\N	\N	38	t	2025-09-10 16:23:55.586	2025-09-19 13:40:55.683	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1182	BT122147	\N	Maria	Bùi Khánh Thy	2012-04-18 00:00:00	\N	0903760477	0909095430	2 Lê Quốc Trinh, Phú Thọ Hòa, Tân Phú	38	t	2025-09-10 16:23:59.027	2025-09-19 13:41:02.71	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1217	VT112319	\N	Giuse	Vũ Phan Minh Trí	2011-07-19 00:00:00	\N	0779083978	\N	343/35/9 Trần Thủ Độ, Phú Thạnh, Tân Phú	29	t	2025-09-10 16:23:59.475	2025-09-19 13:41:08.415	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
367	NH082215	\N	Giuse	Nguyễn Trung Hiếu	2008-03-17 00:00:00	\N	0918699559	\N	16/1 Trần Quang Cơ, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:43.12	2025-09-19 13:40:36.877	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
251	CD132170	\N	Giuse	Ca Thành Đạt	2014-08-31 00:00:00	\N	0376503073	\N	66 ĐS3, BHHA, Bình Tân	26	t	2025-09-10 16:23:40.953	2025-09-19 13:40:32.943	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
709	VN112145	\N	Phêrô	Vũ Quốc Nam	2011-07-11 00:00:00	\N	0975330673	0906967412	121A Lê Lư, Phú Thọ Hòa, Tân Phú	29	t	2025-09-10 16:23:50.314	2025-09-19 13:40:48.015	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
647	NM152114	\N	Phêrô	Nguyễn Sơn Nhật Minh	2015-07-11 00:00:00	\N	0945961714	\N	26/11 ĐS 5, BHHA, Bình Tân	21	t	2025-09-10 16:23:49.248	2025-09-19 13:40:45.872	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1019	DT182512	\N	Lucia	Đoàn Minh Tâm	2018-06-25 00:00:00	\N	0856892525	0906780344	121 Lê Lâm, Phú Thạnh	4	t	2025-09-10 16:23:56.731	2025-09-19 13:40:59.418	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
917	HP172516	\N	Phaolô	Hợp Tiến Phúc	2017-10-06 00:00:00	\N	0962855107	\N	449/33 Hương Lộ 2, BTĐ, Bình Tân	14	t	2025-09-10 16:23:54.837	2025-09-19 13:40:54.071	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
485	TK162234	\N	Phanxico	Trần Huy Khang	2016-03-05 00:00:00	\N	0988080383	\N	3/10 Hiền Vương, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:46.396	2025-09-19 13:40:40.721	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1073	PT152315	\N	Vinh Sơn	Phạm Tấn Thành	2015-10-21 00:00:00	\N	0961863500	\N	479/6/6 Hương Lộ 2, BTĐ, Bình Tân	11	t	2025-09-10 16:23:57.5	2025-09-19 13:40:59.6	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
260	TD182473	\N	Giuse	Trần Tuấn Đạt	2018-09-28 00:00:00	\N	0938929808	0909382788	98 Đường số 4, BHHA, Bình Tân	1	t	2025-09-10 16:23:41.129	2025-09-19 13:40:32.781	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
405	TH172435	\N	Giuse	Trần Minh Huy	2017-06-12 00:00:00	\N	0773445593	0989862137	260 Đường số 8, BHH A, Bình Tân	12	t	2025-09-10 16:23:44.741	2025-09-21 03:31:18.082	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
414	NH122173	\N	Giuse	Ngô Gia Hưng	\N	\N	\N	\N	\N	35	t	2025-09-10 16:23:44.903	2025-09-19 13:40:20.965	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
713	HN162213	\N	Maria	Hoàng Phạm Khánh Ngân	2016-12-08 00:00:00	\N	0938258946	\N	239C Quách Đình Bảo, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:50.377	2025-09-19 13:40:48.347	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
274	NĐ152243	\N	Dominico	Nguyễn Trung Định	2015-07-11 00:00:00	\N	0857539618	\N	Cc Lê Thành 198A Mã Lò, BTĐA, Bình Tân	21	t	2025-09-10 16:23:41.444	2025-09-19 13:41:08.597	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
980	TQ192546	\N	Giuse	Trần Minh Quân	2019-01-24 00:00:00	\N	0975271097	\N	33/2 đường số 1, BHHA	5	t	2025-09-10 16:23:56.095	2025-09-19 13:40:57.674	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
244	NĐ152247	\N	Lucia	Nguyễn Linh Đan	2015-09-20 00:00:00	\N	0919045026	\N	24/16/2A Miếu Gò Xoài, BHHA, Bình Tân	20	t	2025-09-10 16:23:40.861	2025-09-19 13:40:32.739	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
331	NH152338	\N	Maria	Nguyễn Ngọc Hân	2015-05-20 00:00:00	\N	0986680247	0982556970	133/6B Gò Dầu, Tân Quý, Tân Phú	23	t	2025-09-10 16:23:42.52	2025-09-19 13:40:35.101	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
728	ĐN082184	\N	Maria	Đặng Lê Bảo Nghi	2008-06-07 00:00:00	\N	0903086513	0388322790	152/19 Bình Long, Phú Thạnh, Tân Phú	51	t	2025-09-10 16:23:50.611	2025-09-19 13:40:47.974	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1145	NT082121	\N	Têrêsa	Nguyễn Ngọc Phương Thùy	2008-08-19 00:00:00	\N	\N	\N	\N	51	t	2025-09-10 16:23:58.51	2025-09-19 13:41:01.326	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
699	NN142376	\N	Giêrađô	Nguyễn Hoàng Nam	2014-04-11 00:00:00	\N	0988134600	\N	8/3 Đường số 5C, BHHA, Bình Tân	23	t	2025-09-10 16:23:50.142	2025-09-19 13:40:46.663	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
816	NN092143	\N	\N	Nguyễn Hồng Yến Nhi	2009-12-02 00:00:00	\N	0562601793	0933034520	449/1E Hương Lộ 2, BTĐ, Bình Tân	38	t	2025-09-10 16:23:53.197	2025-09-19 13:40:51.579	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
795	NN142371	\N	Vincente	Nguyễn Hoàng Nhân	2014-10-29 00:00:00	\N	0930601725	0903301057	19 Thạch Lam, Hiệp Tân, Tân Phú	23	t	2025-09-10 16:23:52.86	2025-09-19 13:40:51.895	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
155	NB152117	\N	Giuse	Nguyễn Ngọc Bảo	2015-04-10 00:00:00	\N	0982596909	0928234789	45 Trần Thủ Độ, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:39.59	2025-09-19 13:40:29.183	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1050	NT112176	\N	Giuse	Nguyễn Minh Tuấn	\N	\N	0773815227	\N	\N	36	t	2025-09-10 16:23:57.18	2025-09-19 13:40:57.858	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
420	VH142237	\N	Martino	Võ Trí Hưng	2014-05-04 00:00:00	\N	0962691938	\N	307/7A Thạch Lam, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:44.994	2025-09-19 13:40:38.516	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	1
1269	NV072115	\N	Phaolo 	Nguyễn Tấn Quang Vinh	2007-10-22 00:00:00	\N	0977239197	0358110809	81/12F ĐS 14,  BHHA, Bình Tân	50	t	2025-09-10 16:24:00.212	2025-09-19 13:41:05.145	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1302	PV152256	\N	Maria	Phạm Thảo Vy	2015-02-01 00:00:00	\N	0974321656	\N	10 Đường số 3D, BHHA, Bình Tân	22	t	2025-09-10 16:24:00.703	2025-09-19 13:41:06.656	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
988	NQ192588	\N	Maria	Nguyễn Ngọc Bảo Quyên	2019-07-01 00:00:00	\N	0938036754	0938036554	364/63/21 Thoại Ngọc Hầu, Phú Thạnh	5	t	2025-09-10 16:23:56.234	2025-09-19 13:41:08.887	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
180	NC142316	\N	Madalêna	Nguyễn Hoàng Gia Cát	2014-09-27 00:00:00	\N	0906881061	\N	173/45/3 Khuông Việt, Phú Trung, Tân Phú	23	t	2025-09-10 16:23:39.95	2025-09-19 13:41:10.379	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
377	NH122136	\N	Đa Minh	Nguyễn Minh Hoàng	\N	\N	\N	\N	\N	35	t	2025-09-10 16:23:43.282	2025-09-19 13:40:36.864	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
357	VH092113	\N	Maria	Vương Gia Hân	2009-02-13 00:00:00	\N	0913902830	0326816151	260A ĐS 8 , BHHA, Bình Tân	50	t	2025-09-10 16:23:42.96	2025-09-19 15:36:24.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
82	NA162331	\N	Micae	Nguyễn Trần Quốc Anh	2016-04-12 00:00:00	\N	0362802115	0972514997	304/4/5A Đường số 8, BHHA, Bình Tân	17	t	2025-09-10 16:23:38.58	2025-09-21 08:23:12.469	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
860	DP162413	\N	Giuse	Đàm Việt Phát	2016-08-01 00:00:00	\N	0978119507	\N	25/61 Văn Cao, Phú Thạnh, TP	12	t	2025-09-10 16:23:53.906	2025-09-21 03:31:18.084	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1156	NT142274	\N	Maria	Nguyễn Gia Anh Thư	2014-09-19 00:00:00	\N	0979895474	0965831127	107/23 Đường số 14, BHHA, Bình Tân	26	t	2025-09-10 16:23:58.66	2025-09-19 13:41:02.658	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
851	PN112145	\N	Anna	Phạm Quỳnh Như	2011-08-25 00:00:00	\N	0902852263	0902691163	31/3 Đường 3B, BHHA, Bình Tân	41	t	2025-09-10 16:23:53.761	2025-09-19 13:40:52.088	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
432	VK172433	\N	Giuse	Vũ Trung Kiên	2017-04-25 00:00:00	\N	0961844472	0988744047	81 Miếu Bình Đông, BHHA	3	t	2025-09-10 16:23:45.238	2025-09-19 13:40:20.958	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
158	PB172416	\N	Giuse	Phạm Gia Bảo	2017-10-21 00:00:00	\N	0969125025	0964288125	\N	13	t	2025-09-10 16:23:39.632	2025-09-21 08:28:52.482	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
599	ĐL122131	\N	Phêrô	Đoàn Lương Bảo Long	2012-11-21 00:00:00	\N	0908901070	0906901070	19/7 Đường 14B , BHHA, Bình Tân	30	t	2025-09-10 16:23:48.454	2025-09-19 13:40:44.234	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
237	ND192539	\N	Phêrô	Nguyễn Phan Phi Dương	2019-04-11 00:00:00	\N	0925678112	0845500877	85 Đỗ Bí, Phú Thạnh	6	t	2025-09-10 16:23:40.749	2025-09-19 13:40:32.942	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1115	NT192529	\N	Giuse	Nguyễn Văn Vũ Thiện	2019-03-08 00:00:00	\N	0909382788	\N	102 đường số 4, BHHA	6	t	2025-09-10 16:23:58.099	2025-09-19 13:41:00.962	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
500	LK172574	\N	Phêrô	Lê Nguyễn Minh Khánh	2017-06-08 00:00:00	\N	0901601265	\N	76/10/28 Nguyễn Sơn, Phú Thọ Hoà	14	t	2025-09-10 16:23:46.696	2025-09-19 13:40:40.996	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
664	TM162278	\N	Giuse	Trần Nguyễn Quang Minh	2016-01-20 00:00:00	\N	\N	\N	\N	15	t	2025-09-10 16:23:49.534	2025-09-19 13:40:45.964	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1180	VT132189	\N	Têrêsa	Vương Bảo Thư	2013-09-28 00:00:00	\N	0933800265	0908892524	Block C CC Phú Thạnh 53 Nguyễn Sơn, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:23:58.996	2025-09-19 13:41:02.855	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
908	TP122129	\N	Micae	Tăng Vinh Phú	2012-11-26 00:00:00	\N	0907357797	0938794749	26 ĐS 5A, BHHA, Bình Tân 	38	t	2025-09-10 16:23:54.694	2025-09-19 13:40:54.018	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
283	PD172552	\N	Giuse	Phạm Trần Minh Đức	2017-01-03 00:00:00	\N	0946759379	0907227349	36 Văn Cao, Phú Thọ Hoà	14	t	2025-09-10 16:23:41.687	2025-09-19 13:40:34.442	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
324	HH182453	\N	Anna	Huỳnh Nguyễn Khả Hân	2018-11-13 00:00:00	\N	0937066281	0931414365	2/5 Đường số 5, BHH A, Bình Tân	3	t	2025-09-10 16:23:42.394	2025-09-19 13:40:34.902	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
389	ĐH112154	\N	Phaolo	Đặng Gia Huy	2011-09-13 00:00:00	\N	0907957795	0912112506	11/29/16 Thoại Ngọc Hầu, Hoà Thạnh, Tân Phú 	35	t	2025-09-10 16:23:44.453	2025-09-19 13:40:36.874	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
710	PN142122	\N	Maria	Phạm Thị Trinh Nữ	2014-09-02 00:00:00	0989720440	0989720440	0989720440	145/63 Lê Văn Qưới, quận Bình Tân, HCM 	27	t	2025-09-10 16:23:50.328	2025-09-19 13:40:48.122	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
920	LP142273	\N	Giuse	Lâm Bảo Phúc	2014-12-11 00:00:00	\N	0908435449	\N	13/26 Lương Thế Vinh, Tân Thới Hòa, Tân Phú	27	t	2025-09-10 16:23:54.882	2025-09-19 13:40:55.391	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
415	NH122120	\N	Phêrô	Nguyễn Phạm Minh Hưng	2012-06-14 00:00:00	\N	0933393825	\N	174A Lê Niệm, Phú Thạnh	36	t	2025-09-10 16:23:44.919	2025-09-19 13:40:38.897	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1074	QT192564	\N	Giuse	Quách Phú Thành	2019-06-07 00:00:00	\N	0906673994	\N	87/22/5B Trần Quang Cơ, Phú Thạnh	6	t	2025-09-10 16:23:57.516	2025-09-19 13:40:59.582	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
494	NT162273	\N	Anna	Nguyễn Lê Nhã Khanh	2016-04-11 00:00:00	\N	0938264209	\N	113/20 Phú Thọ Hòa,  Phú Thọ Hòa, Tân Phú	16	t	2025-09-10 16:23:46.578	2025-09-19 13:40:40.9	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
591	TL112356	\N	Têrêsa	Trần Phương Linh	2011-07-07 00:00:00	\N	0969393958	0931966269	8/12/2 Lê Văn Quới, BHHA, Bình Tân	40	t	2025-09-10 16:23:48.324	2025-09-19 13:40:44.089	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
610	PL172364	\N	Đa Minh	Phạm Trần Quang Long	2017-12-11 00:00:00	\N	0902489979	0961216534	24/24 Miếu Gò Xoài, BHHA, Bình Tân	13	t	2025-09-10 16:23:48.643	2025-09-19 13:40:44.696	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1322	ĐY132113	\N	Anna	Đỗ Ngọc Như Ý	2013-04-12 00:00:00	\N	0918977345	\N	266/14/11 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú	31	t	2025-09-10 16:24:01.254	2025-09-19 13:41:08.798	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
566	PL142256	\N	Maria	Phạm Thị Ngọc Lan	2014-09-27 00:00:00	\N	0767580745	0909150170	12 Nguyễn Lý, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:47.886	2025-09-19 15:36:24.801	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
856	VN152234	\N	Maria	Võ Quỳnh Như	2015-02-02 00:00:00	\N	0938874572	\N	134 Trần Quang Cơ, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:53.847	2025-09-19 13:40:52.03	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
639	ĐM172341	\N	Phêrô	Đinh Bảo Minh	2017-03-04 00:00:00	\N	0909993202	0907797263	60/71 Trương Phước Phan, BTĐ, Bình Tân	13	t	2025-09-10 16:23:49.125	2025-09-19 13:41:08.482	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
201	ND122165	\N	Phanxico Xavie	Nguyễn Thành Danh	2011-10-11 00:00:00	\N	\N	0765782676	32/30 Nguyễn Nhữ Lãm	37	t	2025-09-10 16:23:40.221	2025-09-19 13:40:32.378	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1081	TT112150	\N	Maria	Trần Phương Thảo	\N	\N	\N	0944397281	\N	36	t	2025-09-10 16:23:57.613	2025-09-19 13:40:59.403	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
779	NN112144	\N	Đa Minh	Nguyễn Minh Nguyên	2011-01-26 00:00:00	\N	0909215635	0908230070	111/47 ĐS 1, BHHA, Bình Tân	37	t	2025-09-10 16:23:51.859	2025-09-19 13:40:49.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
150	NB092137	\N	Phêrô	Nguyễn Gia Bảo	2009-11-11 00:00:00	\N	0909545952	\N	175 Lê Lâm Phú Thạnh, Tân Phú	42	t	2025-09-10 16:23:39.521	2025-09-19 13:40:28.881	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
215	DD122573	\N	Phaolô	Dương Trung Dũng	2012-02-16 00:00:00	\N	0917733949	\N	34/18B Hoàng Ngọc Phách, Phú Thọ Hoà	26	t	2025-09-10 16:23:40.413	2025-09-19 13:40:32.788	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1117	TT112121	\N	Giuse	Trần Đức Thiện	2011-03-08 00:00:00	\N	0909570345	0903890836	296 ĐS 8, BHHA, Bình Tân	41	t	2025-09-10 16:23:58.127	2025-09-19 13:41:00.839	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1188	PT112112	\N	Têrêsa	Phạm Hoàng Khánh Thy	2011-11-16 00:00:00	\N	0903353757	0903446778	411A Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	41	t	2025-09-10 16:23:59.098	2025-09-19 13:41:03.01	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
472	NK142116	\N	Gioan Baotixita	Nguyễn Phúc An Khang	2014-01-30 00:00:00	\N	0938225737	\N	266/14/7 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	17	t	2025-09-10 16:23:46.054	2025-09-21 08:19:32.584	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
124	NA162338	\N	Martino	Nguyễn Thiên Ân	2016-07-12 00:00:00	\N	0983905494	\N	260/1 Phan Anh, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:23:39.162	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
363	ĐH112146	\N	Giuse	Đỗ Minh Hiếu	2011-10-05 00:00:00	\N	0909391559	0797443610	87 ĐS 8, BHHA, Bình Tân	35	t	2025-09-10 16:23:43.051	2025-09-19 13:40:36.958	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
153	NB122169	\N	Phêrô Phaolô	Nguyễn Khánh Bảo	2012-02-15 00:00:00	\N	0903162715	0908844485	282/9 Lê Văn Quới, Btđa, Bình Tân	38	t	2025-09-10 16:23:39.559	2025-09-19 13:40:29.077	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
574	TL082183	\N	Maria	Trần Hải Thùy Lâm	2008-06-16 00:00:00	\N	0982781083	\N	79B Phạm Văn Xảo, Phú Thạnh, Tân Phú	51	t	2025-09-10 16:23:48.025	2025-09-19 13:41:08.622	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
516	NK132199	\N	Giuse	Nguyễn Hoàng Anh Khoa	2013-06-07 00:00:00	\N	0906300343	\N	110/2/3 ĐS 4, BHHA, Bình Tân	31	t	2025-09-10 16:23:46.961	2025-09-19 13:40:42.578	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
994	TQ152319	\N	Maria	Trần Nguyễn Xuân Quyên	2015-03-19 00:00:00	\N	0933991308	0907642117	174 Thạch Lam, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:56.343	2025-09-19 13:40:57.192	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
467	NK122130	\N	Gioan Baotixita	Nguyễn Hữu Khang	2012-10-08 00:00:00	\N	0703593397	\N	49/77 Đường số 3, BHHA	36	t	2025-09-10 16:23:45.934	2025-09-19 13:40:39.278	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
188	NC122195	\N	Maria	Nguyễn Ngọc Bảo Châu	2012-05-19 00:00:00	\N	0938036754	\N	364/63/7 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:40.051	2025-09-19 13:40:30.579	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1284	DV172341	\N	Têrêsa	Doãn Nhã Vy	2017-09-11 00:00:00	\N	0903844318	0977142515	57 Đường số 4, BHHA, Bình Tân	13	t	2025-09-10 16:24:00.43	2025-09-19 13:41:07.236	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
218	ND122128	\N	Giuse	Nguyễn Ngọc Tiến Dũng	2012-07-27 00:00:00	\N	0375253440	0975023165	Hẻm Miếu Tiên Sư Kế Nhà A5/19V30 Tổ 11 Ấp 1B, Vĩnh Lộc, Bình Chánh	38	t	2025-09-10 16:23:40.449	2025-09-19 13:40:31.144	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
717	NN132573	\N	Anna	Nguyễn Kim Hoàng Ngân	2013-03-08 00:00:00	\N	0909548986	0988090885	162 Lê Sao, Phú Thạnh, Tân Phú	18	t	2025-09-10 16:23:50.436	2025-09-19 13:40:48.169	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
777	NN112196	\N	Martino	Nguyễn Gia Nguyên	2011-10-13 00:00:00	\N	0938688446	\N	26 Đường 1B, Bình Hưng Hòa, TP.HCM	36	t	2025-09-10 16:23:51.761	2025-09-19 13:40:49.605	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
810	LN112189	\N	Matta	Lê Bảo Nhi	2011-10-10 00:00:00	\N	0376050792	0987608483	187/42/10 ĐS 5A, BHHA, Bình Tân 	38	t	2025-09-10 16:23:53.107	2025-09-19 13:40:51.584	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
859	BP112116	\N	Đa Minh	Bùi Gia Phát	2011-05-14 00:00:00	\N	0909119034	0938098137	42/35 ĐS 5, Bình Tân	40	t	2025-09-10 16:23:53.89	2025-09-19 13:40:53.949	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
658	PM142180	\N	Têrêsa	Phạm Nguyễn Cát Minh	2014-07-13 00:00:00	\N	0907180481	0908180481	34/7 ĐS 22, BHHA, Bình Tân	26	t	2025-09-10 16:23:49.442	2025-09-19 13:40:46.248	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
655	PM172401	\N	Augustino	Phạm Đức Anh Minh	2017-04-01 00:00:00	\N	90330976	0932025202	3 Hoàng Ngọc Phách, Phú Thọ Hoà, Tân Phú	1	t	2025-09-10 16:23:49.388	2025-09-19 13:40:45.96	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
809	HN182519	\N	Maria	Hoàng Nguyễn Tuệ Nhi	2018-11-09 00:00:00	\N	0988885217	0938202378	198/28 Thoại Ngọc Hầu, Phú Thạnh	4	t	2025-09-10 16:23:53.086	2025-09-19 13:40:51.892	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1280	NV122193	\N	Giuse	Nguyễn Trần Khiết Vương	2012-12-02 00:00:00	\N	0934241543	0834456157	135/1 Tần Quang Cơ, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:24:00.374	2025-09-19 13:41:06.521	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1281	BV192517	\N	Têrêsa	Bùi Ngọc Đan Vy	2019-09-06 00:00:00	\N	0938656760	0938656860	210 Nguyễn Sơn, Phú Thọ Hoà	5	t	2025-09-10 16:24:00.389	2025-09-19 13:41:08.94	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
906	NP152351	\N	Giuse	Nguyễn Hữu Gia Phú	2015-11-22 00:00:00	\N	0774895557	0962482880	17 Lê Đại, Phú Thọ Hòa, Tân Phú	23	t	2025-09-10 16:23:54.662	2025-09-19 13:41:10.481	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
696	ĐN132152	\N	Giuse	Đỗ Nhật Nam	\N	\N	\N	\N	\N	33	t	2025-09-10 16:23:50.077	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
878	TP132189	\N	Phêrô	Trần Gia Phát	2013-10-13 00:00:00	\N	0989970370	\N	235 Miếu Bình Đông, BHHA, Bình Tân	34	t	2025-09-10 16:23:54.208	2025-09-19 13:40:53.538	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
513	NK122163	\N	Gioan 	Nguyễn Đăng Khoa	2012-11-20 00:00:00	\N	0933776658	0938211817	3 Đường 5A, Bình Hưng Hòa A, Bình Tân	38	t	2025-09-10 16:23:46.895	2025-09-19 13:40:20.96	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
564	HL162428	\N	Maria	Hà Thái Hoàng Lan	2016-11-11 00:00:00	\N	0907986496	0915042766	264 Lê Sao, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:23:47.852	2025-09-21 03:31:18.082	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
256	NĐ172381	\N	Giuse	Nguyễn Thành Đạt	2017-08-04 00:00:00	\N	0389175232	\N	178 Mã Lò, BTĐ A, Bình Tân	10	t	2025-09-10 16:23:41.039	2025-09-19 15:36:24.879	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
425	NH162369	\N	Maria	Nguyễn Hồng Nhiên Hương	2016-01-23 00:00:00	\N	0962211133	0968683611	100 Lê Niệm, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:23:45.095	2025-09-21 08:23:12.47	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
134	BB082185	\N	Giuse	Bùi Gia Bảo	2008-01-09 00:00:00	\N	0903737451	0902377059	444A Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	50	t	2025-09-10 16:23:39.306	2025-09-19 13:40:29.006	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
879	VP152239	\N	Giuse	Võ Minh Phát	2015-09-14 00:00:00	\N	9833196315	\N	81/8 Đường số 14, BHHA, Bình Tân	19	t	2025-09-10 16:23:54.227	2025-09-19 13:40:53.916	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
332	NH142248	\N	Anna	Nguyễn Ngọc Hân	2014-01-27 00:00:00	\N	0938343871	\N	86 Trần Thủ Độ, Phú Thạnh, Tân Phú	25	t	2025-09-10 16:23:42.539	2025-09-19 13:40:35.073	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
885	ĐP142110	\N	Giuse	Đinh Tiến Phong	2014-04-26 00:00:00	\N	0972068779	\N	24/29/18 Miếu Gò Xoài	27	t	2025-09-10 16:23:54.328	2025-09-19 13:41:10.781	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
151	NB112259	\N	Giuse	Nguyễn Gia Bảo	2011-08-08 00:00:00	\N	\N	\N	\N	31	t	2025-09-10 16:23:39.534	2025-09-19 13:40:29.322	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
441	LK152358	\N	Maria	Lương Gia Kim	2015-08-30 00:00:00	\N	0909171351	\N	127/2/64 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	23	t	2025-09-10 16:23:45.398	2025-09-19 13:40:39.382	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
481	TK182403	\N	Giuse	Trần Bảo Khang	\N	\N	0933960879	\N	92 Bình Long, Phú Thạnh, Tân Phú	1	t	2025-09-10 16:23:46.265	2025-09-19 13:40:41.035	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
512	NK142117	\N	Gioan Baotixita	Nguyễn Anh Khoa	2014-12-27 00:00:00	\N	0707153586	\N	307/6 Thạch Lam, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:46.879	2025-09-19 13:40:42.406	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
573	NL152275	\N	Cecilia	Nguyễn Nghi Lâm	2015-11-15 00:00:00	\N	0938343871	\N	84 Trần Thủ Độ, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:48.008	2025-09-19 13:40:44.179	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
676	NM162419	\N	Têrêsa	Nguyễn Diễm My	2016-11-19 00:00:00	\N	0985565545	0965579430	93 Miếu Bình Đông, BHHA, Bình Tân	13	t	2025-09-10 16:23:49.723	2025-09-19 13:40:46.414	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
626	PL152248	\N	Têrêsa	Phạm Trần Khánh Ly	2015-02-11 00:00:00	\N	0936637224	\N	452 Tân Hòa Đông, BTĐ, Bình Tân	21	t	2025-09-10 16:23:48.908	2025-09-19 13:40:45.933	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
764	VN102121	\N	Maria Têrêsa	Vũ Huỳnh Thanh Ngọc	2010-05-28 00:00:00	\N	0939339619	0932096121	246/34/12 Lê Văn Quới, BHH, Bình Tân	41	t	2025-09-10 16:23:51.389	2025-09-19 13:40:49.645	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
768	BN142318	\N	Phaolô	Bùi Hữu Nguyên	2014-11-15 00:00:00	\N	0903398171	\N	142 Trần Quang Cơ, Phú Thạnh, Tân Phú	29	t	2025-09-10 16:23:51.465	2025-09-19 15:36:24.805	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
858	NO152315	\N	\N	Nguyễn Hoàng Yến Oanh	2015-12-30 00:00:00	\N	0908642722	0908642722	111/9 Đường số 1, BHHA, Bình Tân	23	t	2025-09-10 16:23:53.877	2025-09-19 13:40:53.55	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
314	ĐH112112	\N	Maria	Đàm Huỳnh Ngọc Hân	2011-12-12 00:00:00	\N	0907667477	0989973449	127/14 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	41	t	2025-09-10 16:23:42.237	2025-09-19 13:41:10.48	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1311	TV112163	\N	Maria	Trần Ngọc Minh Vy	2011-10-28 00:00:00	\N	0903841919	0938936066	75 Đường 8B, BHHA, Bình Tân	35	t	2025-09-10 16:24:00.936	2025-09-19 13:41:06.666	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
404	TH172311	\N	Phêrô	Trần Gia Huy	2017-09-05 00:00:00	\N	0966950780	0326295059	42/16 Đường số 8, BHHA, Bình Tân	11	t	2025-09-10 16:23:44.723	2025-09-19 13:40:38.757	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	2	1
650	NM172311	\N	Maria Têrêsa	Nguyễn Trần Nguyệt Minh	2017-05-04 00:00:00	\N	0834456157	\N	135/1 Trần Quang Cơ, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:49.3	2025-09-19 15:36:24.804	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
552	PK132194	\N	Maria	Phạm Ngọc Châu Khuê	\N	\N	\N	\N	\N	32	t	2025-09-10 16:23:47.619	2025-09-19 15:36:24.804	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
551	GK112122	\N	Têrêsa	Giang Minh Khuê	2011-10-11 00:00:00	\N	0907958666	0908022926	215 Lê Lâm, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:47.596	2025-09-19 13:40:20.964	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
787	VN132114	\N	Martino	Vũ Gia Nguyên	2013-02-04 00:00:00	\N	0764798878	0909183004	24A Đường số 8, BHHA, Bình Tân	34	t	2025-09-10 16:23:52.422	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1067	PT172441	\N	Maria	Phạm Thị Diệu Thanh	2017-04-16 00:00:00	\N	0359553773	0977881036	6/1A Miếu Gò Xoài, BHHA, Bình Tân	12	t	2025-09-10 16:23:57.427	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
560	TL172415	\N	Anna	Trần Tường Lam	2017-09-15 00:00:00	\N	0933362362	0938888862	49 Lê Vĩnh Hoà, Phú Thọ Hoà, Tân Phú	14	t	2025-09-10 16:23:47.779	2025-09-19 15:36:24.804	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
755	PN132172	\N	Maria	Phạm Thị Bích Ngọc	2013-06-18 00:00:00	\N	0969125025	0964288125	155/29 Phú Thọ Hoà	34	t	2025-09-10 16:23:51.149	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
778	NN172317	\N	Maria	Nguyễn Hoàng Thảo Nguyên	2017-12-04 00:00:00	\N	0906300343	0903144654	110/2/3 Đường số 4, BHHA, Bình Tân	10	t	2025-09-10 16:23:51.775	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1005	VQ172450	\N	Maria	Vũ Ngọc Ngân Quỳnh	2017-10-14 00:00:00	\N	0968158110	0384104754	187 Hiền Vương, PT, Tân Phú	12	t	2025-09-10 16:23:56.519	2025-09-21 03:31:18.085	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
999	NQ172546	\N	Maria	Nguyễn Khánh Quỳnh	2017-06-03 00:00:00	\N	0368778836	0908361993	69/23 Phan Thị Hành, Phú Thọ Hoà	12	t	2025-09-10 16:23:56.413	2025-09-21 03:31:18.085	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
204	ND172348	\N	Maria	Nguyễn Diệp Hân Di	2017-01-14 00:00:00	\N	\N	\N	\N	10	t	2025-09-10 16:23:40.258	2025-09-19 15:36:24.803	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
246	PD152436	\N	Maria	Phạm Linh Đan	2015-01-10 00:00:00	\N	0355590456	0346164959	233 Lê Văn Quới, BTĐ, Bình Tân	18	t	2025-09-10 16:23:40.892	2025-09-19 13:40:32.933	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1283	CV152344	\N	\N	Cao Nguyễn Tường Vy	2015-09-25 00:00:00	\N	0938515758	0909700553	360/17/29 Tân Hòa Đông, BTĐ, Bình Tân	18	t	2025-09-10 16:24:00.419	2025-09-19 13:41:07.243	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
511	LK152364	\N	Gioan Baotixita	Lưu Anh Khoa	2015-08-11 00:00:00	\N	0934209121	\N	23/42 Đình Nghi Xuân, BTĐ, Bình Tân	12	t	2025-09-10 16:23:46.867	2025-09-21 03:31:18.084	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
369	VH092196	\N	Giuse 	Vũ Ngọc Hoan	2009-04-12 00:00:00	\N	0908119943	0908833449	88 Bùi Thị Xuân, P2, Tân Bình	45	t	2025-09-10 16:23:43.152	2025-09-19 13:40:36.907	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
391	HH142371	\N	Antôn	Hoàng Gia Huy	2014-10-17 00:00:00	\N	0937486584	0938969830	20/24 Đường số 3, BHHA, Bình Tân	23	t	2025-09-10 16:23:44.486	2025-09-19 13:40:38.567	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
904	NP082184	\N	Vinh Sơn	Nguyễn Đình Phú	2008-04-01 00:00:00	\N	0908283729	0983134652	124 Lê Lâm, Phú Thạnh, Tân Phú	51	t	2025-09-10 16:23:54.625	2025-09-19 13:40:53.977	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
608	NL132156	\N	Phêrô	Nguyễn Phùng Đức Long	2013-02-06 00:00:00	\N	0903144780	0908174183	34/31A Hoàng Ngọc Phách, Phú Thọ Hòa, Tân Phú	27	t	2025-09-10 16:23:48.608	2025-09-19 13:40:44.428	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
797	PN112163	\N	Giuse	Phạm Thành Nhân	2011-08-30 00:00:00	\N	0987717398	\N	33/13A Đường 16A, BHHA, Bình Tân	41	t	2025-09-10 16:23:52.892	2025-09-19 13:40:51.635	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
161	TB142185	\N	Antôn	Trần Gia Bảo	\N	\N	\N	\N	\N	28	t	2025-09-10 16:23:39.666	2025-09-19 13:40:20.932	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	2	0
288	TD122165	\N	Giuse	Trần Nguyễn Anh Đức	2012-02-23 00:00:00	\N	\N	\N	\N	31	t	2025-09-10 16:23:41.791	2025-09-19 13:40:34.596	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1212	NT122179	\N	Vinh Sơn	Nguyễn Trường Minh Trí	2012-09-26 00:00:00	\N	0972532456	\N	326/5 Thạch Lam, Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:59.407	2025-09-19 13:41:04.527	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
195	NC142338	\N	Maria	Nguyễn Linh Chi	2014-05-02 00:00:00	\N	0961024413	0898470326	74/2 Liên Khu 2-5, BTĐ, Bình Tân	29	t	2025-09-10 16:23:40.137	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
790	LN142119	\N	Giuse 	Lê Nguyễn	2014-05-25 00:00:00	\N	0368899762	\N	19/55 ĐS 4, BHHA, Bình Tân	25	t	2025-09-10 16:23:52.755	2025-09-19 13:41:08.653	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
915	HP192532	\N	Giuse	Hoàng Thiên Phúc	2019-09-06 00:00:00	\N	\N	\N	18A Lê Lư, Phú Thọ Hoà	6	t	2025-09-10 16:23:54.802	2025-09-19 13:40:54.049	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
129	TA102127	\N	Maria	Thái Nguyễn Hồng Ân	2010-08-03 00:00:00	\N	0939041473	0858700708	202/3 Tô Hiệu, Hiệp Tân, Tân Phú	42	t	2025-09-10 16:23:39.236	2025-09-21 02:22:57.321	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
588	PL122137	\N	Anna	Phạm Hoàng Yến Linh	2012-04-15 00:00:00	\N	0702084658	\N	14/15 Đường 20, BHHA, Bình Tân	35	t	2025-09-10 16:23:48.265	2025-09-19 13:40:21.013	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1233	NT182419	\N	Phêrô	Nguyễn Nhật Trường	\N	\N	\N	\N	\N	3	t	2025-09-10 16:23:59.686	2025-09-19 13:41:04.855	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1246	PU132241	\N	Maria	Phạm Gia Bảo Uyên	2013-04-08 00:00:00	\N	0908665825	\N	198 Hiền Vương, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:59.875	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
122	NA112165	\N	Maria	Nguyễn Ngọc Hồng Ân	2011-01-01 00:00:00	\N	\N	\N	\N	41	t	2025-09-10 16:23:39.137	2025-09-19 13:40:29.234	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
386	BH162413	\N	Phalo	Bùi Gia Huy	2016-11-13 00:00:00	\N	0931797811	0902780636	52/24 Đường số 12, BHHA, Bình Tân	18	t	2025-09-10 16:23:44.404	2025-09-19 13:40:37.067	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
825	TN182418	\N	Anna	Trần Bảo Nhi	2018-05-08 00:00:00	\N	0909077927	0909664655	71/21/3D Phú Thọ Hòa, Q. TP	3	t	2025-09-10 16:23:53.331	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
714	LN192513	\N	Maria	Lê Ngọc Khánh Ngân	2019-02-27 00:00:00	\N	0383359874	0387648393	343 Thạch Lam, Phú Thạnh	6	t	2025-09-10 16:23:50.391	2025-09-19 13:41:08.957	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
300	PH182474	\N	Cecilia	Phạm Dương Thuý Hà	2018-06-14 00:00:00	\N	0903380678	0913684665	223 Quách Đình Bảo, Phú Thạnh, Tân Phú	2	t	2025-09-10 16:23:42.001	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
590	TL122197	\N	Monica	Trần Phương Linh	2012-04-28 00:00:00	\N	0903068722	0908963655	12K,16A,BHHA, Bình Tân	38	t	2025-09-10 16:23:48.295	2025-09-19 13:40:21.01	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
725	VN122146	\N	Maria	Vũ Ngọc Bảo Ngân	2012-07-27 00:00:00	\N	0968158110	0384104754	403/23 Hương Lộ 3, BHH, Bình Tân 	38	t	2025-09-10 16:23:50.566	2025-09-19 13:40:47.924	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
986	ĐQ132319	\N	Maria	Đặng Nguyễn Lan Quyên	2013-04-19 00:00:00	\N	0907735588	\N	\N	26	t	2025-09-10 16:23:56.194	2025-09-19 13:40:57.716	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1148	NT142559	\N	Maria	Nguyễn Hoàng Tú Thuyên	2014-10-04 00:00:00	\N	0914246059	\N	14 Liên Khu 2-5, BTĐ	26	t	2025-09-10 16:23:58.555	2025-09-19 13:41:02.706	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
826	TN142247	\N	Maria	Trần Bảo Nhi	2014-07-15 00:00:00	\N	0907037569	\N	243 Bình Long, BHHA, Bình Tân	26	t	2025-09-10 16:23:53.344	2025-09-19 13:40:53.689	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1065	HT142160	\N	Maria	Huỳnh Đoàn Thiên Thanh	2014-03-22 00:00:00	\N	0989011862	0933450876	32/15A Đường 13A, BHHA, Bình Tân	26	t	2025-09-10 16:23:57.397	2025-09-19 13:40:59.525	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
691	TM182575	\N	Maria	Trần Vũ Yến My	2018-07-08 00:00:00	\N	0933593594	0969626359	6/3 đường số 14A, BHHA	4	t	2025-09-10 16:23:49.994	2025-09-19 13:40:46.501	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
897	VP172319	\N	Phêrô	Vũ Đình Phong	2017-11-16 00:00:00	\N	0902737647	0332465696	165 Bình Long, BHHA, Bình Tân	11	t	2025-09-10 16:23:54.514	2025-09-19 13:40:55.813	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
774	NN172319	\N	Phaolô	Nguyễn Cao Anh Nguyên	2017-11-04 00:00:00	\N	0983712900	0904777487	36/1A Đường 14,  BHHA, Bình Tân	11	t	2025-09-10 16:23:51.572	2025-09-19 13:40:49.695	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
248	TĐ172339	\N	Maria	Trần Song Nhã Đan	2017-11-14 00:00:00	\N	0916659900	0937941205	250/23 Phan Anh, Hiệp Tân, Tân Phú	11	t	2025-09-10 16:23:40.921	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1001	PQ162469	\N	Maria	Phạm Ngọc Bảo Quỳnh	2016-06-14 00:00:00	\N	0399605549	\N	29/8/18 Đường số 10, BHH A, Bình Tân	18	t	2025-09-10 16:23:56.451	2025-09-19 13:41:10.479	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
145	LB122166	\N	Gioan	Lê Triều Thiên Bảo	2012-05-26 00:00:00	\N	0911318738	0907853655	129/17 Lê Thiệt, Phú Thọ Hòa	36	t	2025-09-10 16:23:39.457	2025-09-19 13:40:29.254	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
384	NH142137	\N	Giuse	Nguyễn Quốc Huân	2014-04-29 00:00:00	\N	0944727177	0946727177	61 Hoàng Ngọc Phách, Phú Thọ Hòa, Tân Phú	28	t	2025-09-10 16:23:44.373	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
321	HH142127	\N	Maria	Hoàng Ngọc Bảo Hân	2014-07-06 00:00:00	\N	0932978224	\N	18A Đường Lê Lư, Phú Thọ Hòa, Tân Phú	27	t	2025-09-10 16:23:42.343	2025-09-19 13:40:34.952	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
270	TĐ152111	\N	Giêrađô	Trương Phạm Minh Đăng	2015-12-21 00:00:00	\N	0707590820	\N	33 đường 16A, BHHA, Bình Tân	22	t	2025-09-10 16:23:41.374	2025-09-19 13:40:32.73	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
382	NH102517	\N	Luca	Nguyễn Thiên Hội	2010-11-06 00:00:00	\N	0396225982	0865935145	31/78 đường số 3, BHHA	45	t	2025-09-10 16:23:44.342	2025-09-19 13:40:36.864	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1121	HT142190	\N	Giuse	Huỳnh Hà Phú Thịnh	2014-01-13 00:00:00	0936862465	0906971552	0936862465	52/23 ĐS 12, BHHA, Bình Tân	27	t	2025-09-10 16:23:58.176	2025-09-19 13:41:00.842	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
403	TH102237	\N	Đaminh	Trần Anh Huy	2010-06-16 00:00:00	\N	0922821277	\N	84/20 Đường số 14, BHHA, Bình Tân	45	t	2025-09-10 16:23:44.709	2025-09-19 13:40:38.611	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
612	PL142192	\N	Gioan Baotixita	Phùng Bảo Long	2014-05-20 00:00:00	\N	0902111203	\N	47 Lê Đại, Phú Thọ Hoà, Tân Phú	25	t	2025-09-10 16:23:48.677	2025-09-19 13:40:44.645	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
756	QN152113	\N	Maria	Quang Thị Hồng Ngọc	2015-11-08 00:00:00	\N	0902526583	0943548739	33A2 Bến Lội, p. Bình Trị Đông A, q. Bình Tân	21	t	2025-09-10 16:23:51.161	2025-09-19 13:40:50.148	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
623	NL112185	\N	Maria	Nguyễn Khánh Ly	2011-10-05 00:00:00	\N	0987573169	\N	282/3 Lê Văn Quới	35	t	2025-09-10 16:23:48.855	2025-09-19 13:41:01.178	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
801	LN092488	\N	Martino	Linh Hồng Nhật	2009-10-07 00:00:00	\N	0934236702	0909822375	144 Lê Lâm, Phú Thạnh	36	t	2025-09-10 16:23:52.957	2025-09-19 13:40:50.34	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
454	TK152119	\N	Phaolô	Trương Quang Khải	2015-11-06 00:00:00	\N	0933955445	\N	CC Phú Thạnh 53 Nguyễn Sơn, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:45.627	2025-09-19 13:40:40.461	1	0.38	0.0	0.0	0.15	0.0	0.0	0.00	2	2
945	TP102192	\N	Martino	Trần Hoàng Thiên Phước	2010-11-19 00:00:00	\N	0903382128	0989973449	20/27B ĐS 1, BHHA, Bình Tân	45	t	2025-09-10 16:23:55.382	2025-09-19 13:40:55.813	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
955	TP162352	\N	Anna	Trịnh Lan Phương	2016-04-19 00:00:00	\N	0979623351	\N	161/2A Bình Trị Đông, BTĐ A, Bình Tân	16	t	2025-09-10 16:23:55.57	2025-09-19 13:40:55.479	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1000	NQ112190	\N	Maria	Nguyễn Trần Trúc Quỳnh	2011-07-09 00:00:00	\N	0903383924	0908569966	133 Đỗ Bí, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:56.431	2025-09-19 13:40:57.189	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1088	TT122159	\N	Phêrô	Trần Bảo Thắng	2012-04-10 00:00:00	\N	0965691612	\N	119 BHHA, Bình Tân	36	t	2025-09-10 16:23:57.709	2025-09-19 13:40:59.457	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1209	NT152248	\N	Phêrô	Nguyễn Huy Trí	2015-12-23 00:00:00	\N	0909634607	\N	17/8/5 Đường số 3B, BHHA, Bình Tân	20	t	2025-09-10 16:23:59.367	2025-09-19 13:41:04.56	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
724	TN112171	\N	Maria	Trương Ngọc Kim Ngân	2011-11-16 00:00:00	\N	0904740799	0905235215	2/2/104 Lê Thúc Hoạch, Phú Thọ Hoà, Tân Phú	42	t	2025-09-10 16:23:50.551	2025-09-19 15:36:24.8	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
638	DM192528	\N	Faustina	Đào Thị Ánh Minh	2019-11-25 00:00:00	\N	0343880450	0338201133	181 đường số 1, BHHA	6	t	2025-09-10 16:23:49.11	2025-09-19 15:36:24.8	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
937	TP132143	\N	Giuse	Trần Nam Phúc	2013-05-24 00:00:00	\N	0908803839	0938803839	342/19 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:23:55.218	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
835	HN122111	\N	Giuse	Hoàng Lê Hạo Nhiên	2012-05-30 00:00:00	\N	0902565671	\N	129/12 Lê Lư, Phú Thọ Hòa, Tân Phú	37	t	2025-09-10 16:23:53.5	2025-09-19 13:40:52.373	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
644	NM122162	\N	Antôn	Nguyễn Bảo Minh	2012-10-04 00:00:00	\N	\N	0905284429	31/94 ĐS 3	32	t	2025-09-10 16:23:49.204	2025-09-19 13:40:21.014	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1197	MT192565	\N	Maria	Mai Ngọc Huyền Trâm	2019-04-16 00:00:00	\N	0971175784	0384383962	422 Hương Lộ 2, BTĐ	6	t	2025-09-10 16:23:59.223	2025-09-19 13:41:02.859	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
252	DD182544	\N	Phêrô	Đoàn Tấn Đạt	2018-06-11 00:00:00	\N	0909338587	0901445668	198 Thoại Ngọc Hầu, Phú Thạnh	4	t	2025-09-10 16:23:40.964	2025-09-19 13:40:32.939	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
632	PM182518	\N	Maria	Phạm Thị Quỳnh Mai	2018-01-12 00:00:00	\N	0906912360	0934444736	5D Lê Khôi, Phú Thạnh	4	t	2025-09-10 16:23:49.012	2025-09-19 13:40:46.08	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
530	LK162256	\N	Martino	Lê Hoàng Đăng Khôi	2016-10-06 00:00:00	\N	0772616263	\N	304/16 Đường số 8, BHHA, Bình Tân	15	t	2025-09-10 16:23:47.214	2025-09-19 13:40:42.318	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
799	TN172319	\N	Giuse	Trần Thiện Nhân	2017-12-18 00:00:00	\N	0916464819	0918370695	113 Đỗ Bí, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:52.924	2025-09-19 13:40:51.528	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
206	VD172374	\N	Catarina	Vũ Ngọc Thiên Di	2017-05-22 00:00:00	\N	0907225586	0916584848	62/17/33A Đường số 5A, BHHA, Bình Tân	11	t	2025-09-10 16:23:40.289	2025-09-21 03:31:15.134	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
978	PQ152364	\N	Phêrô	Phạm Minh Quân	2015-04-26 00:00:00	\N	0774148941	0931896478	38/5 Đường số 1A, BHHA, Bình Tân	18	t	2025-09-10 16:23:56.052	2025-09-19 13:40:57.687	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1337	VY152141	\N	Maria	Vũ Nguyễn Hải Yến	2015-06-14 00:00:00	\N	0815762058	\N	1N Văn Cao, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:24:01.557	2025-09-19 13:41:08.773	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
998	LQ172588	\N	Maria	Lê Ngọc Như Quỳnh	2017-05-30 00:00:00	\N	0949060031	0917118928	6 Lê Thúc Hoạch, Phú Thọ Hoà	14	t	2025-09-10 16:23:56.397	2025-09-19 13:40:57.912	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1319	VX182411	\N	Maria	Vũ Huỳnh Thanh Xuân	2018-01-04 00:00:00	\N	\N	\N	\N	2	t	2025-09-10 16:24:01.139	2025-09-19 13:41:06.969	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1085	VT112316	\N	Maria	Vũ Thanh Thảo	2011-10-19 00:00:00	\N	0972825997	0972825997	44/6 Đường số 4, BHHA, Bình Tân	29	t	2025-09-10 16:23:57.665	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
196	NC172381	\N	Catarina	Nguyễn Mai Diệp Chi	2017-06-17 00:00:00	\N	0918854963	0936842919	294/11 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	11	t	2025-09-10 16:23:40.155	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
602	LL172359	\N	Giuse	Lê Bảo Long	2017-11-14 00:00:00	\N	0907294966	0933250260	31/39/10B Đường số 3, BHHA, Bình Tân	11	t	2025-09-10 16:23:48.512	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
94	TA172339	\N	Giacobe	Trần Duy Anh	2017-01-03 00:00:00	\N	0988918885	0908110068	119 Bình Long, BHHA, Bình Tân	11	t	2025-09-10 16:23:38.75	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1256	NV172386	\N	Têrêsa	Nguyễn Thanh Vân	2017-12-22 00:00:00	\N	0988964846	0379762499	39 Miếu Bình Đông, BHHA, Bình Tân	10	t	2025-09-10 16:24:00.019	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
715	LN152427	\N	Anna	Lê Thảo Ngân	2015-06-27 00:00:00	\N	0908259258	0974929336	15/1 Đường 5A, BHHA, Bình Tân	18	t	2025-09-10 16:23:50.409	2025-09-19 13:41:10.436	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
199	NC162356	\N	Maria	Nguyễn Thị Yên Chi	2016-07-19 00:00:00	\N	0963388182	0906841417	54 Đường 16A, BHHA, Bình Tân	17	t	2025-09-10 16:23:40.195	2025-09-21 08:23:12.469	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
730	LN162363	\N	Têrêsa	Lê Trang Bảo Nghi	2016-01-23 00:00:00	\N	0918089110	0946309915	98 Lê Cao Lãng, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:23:50.644	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1112	NT132192	\N	Giuse	Nguyễn Đức Thiện	2013-09-17 00:00:00	\N	0933829595	0909391559	246/2/4 Lê Văn Quới, BHHA, Bình Tân	34	t	2025-09-10 16:23:58.056	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
668	VM122122	\N	Augustino	Vũ Hoàng Minh	\N	\N	\N	\N	\N	37	t	2025-09-10 16:23:49.598	2025-09-19 13:40:21.025	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1192	CT122112	\N	Maria	Cát Thanh Trang	2012-05-18 00:00:00	\N	0903962807	\N	12 Võ Văn Dũng, Phú Thạnh, Tân Phú 	32	t	2025-09-10 16:23:59.149	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
798	PN162217	\N	ĐaMinh	Phan Nguyễn Thiện Nhân	2016-03-02 00:00:00	\N	0902615041	\N	305/36/8 Lê Văn Quới, BTĐ, Bình Tân	16	t	2025-09-10 16:23:52.906	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
503	NK162439	\N	Phêrô	Nguyễn Quốc Khánh	2016-09-01 00:00:00	\N	0973299155	0908299155	172/6 Bình Long, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:46.75	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
684	NM152273	\N	Maria	Nguyễn Thảo My	2015-08-11 00:00:00	\N	0969178089	\N	232/25 Tô Hiệu, Hiệp Tân, Tân Phú	22	t	2025-09-10 16:23:49.862	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
400	PH142564	\N	Giuse	Phạm Ngọc Gia Huy	2014-09-02 00:00:00	\N	0982922338	\N	303 Vườn Lài, Phú Thọ Hoà	14	t	2025-09-10 16:23:44.66	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
351	TH132196	\N	Catarina	Trần Ngọc Gia Hân	2013-12-11 00:00:00	\N	0909121820	\N	319A Nguyễn Sơn, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:42.842	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
705	TN122137	\N	Gioan Baotixita	Trần Bảo Nam	2012-07-03 00:00:00	\N	0909664655	0909664655	71/21/9/6 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	35	t	2025-09-10 16:23:50.245	2025-09-19 13:40:21.044	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
518	NK132114	\N	Giuse	Nguyễn Minh Khoa	2013-06-09 00:00:00	\N	0906314368	0912233947	16/8 liên khu 8-9, p.BHHA, q.Bình Tân	30	t	2025-09-10 16:23:47.012	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
474	NK122465	\N	Gioan Baotixita	Nguyễn Viết Khang	2012-04-29 00:00:00	\N	0918555012	0942909423	92/3B Nguyễn Sơn, PTH, Tân Phú	34	t	2025-09-10 16:23:46.09	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1282	BV142180	\N	Têrêsa	Bùi Ngọc Khánh Vy	2014-11-29 00:00:00	\N	0938656760	\N	137 Hòa Bình, Hiệp Tân, Tân Phú	28	t	2025-09-10 16:24:00.405	2025-09-19 15:36:24.81	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
789	VN122133	\N	Maria	Vũ Ngọc Thảo Nguyên	2012-02-01 00:00:00	\N	0909678028	\N	266/4 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	34	t	2025-09-10 16:23:52.592	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1099	TT142251	\N	Đaminh	Trần Hạo Thiên	2014-03-04 00:00:00	\N	0798292900	\N	102/50 Bình Long, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:57.866	2025-09-19 13:41:01.151	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	2	0
428	VH102111	\N	Fautina	Vũ Quỳnh Hương	2010-02-10 00:00:00	\N	0707675683	0707675683	31/9 Đường 16, BHH, Bình Tân	42	t	2025-09-10 16:23:45.144	2025-09-21 01:22:56.518	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
965	ĐQ132199	\N	Giuse	Đoàn Minh Quân	2013-07-05 00:00:00	\N	0903784589	0938884285	10/1/3B ĐS 10, BHHA, Bình Tân	32	t	2025-09-10 16:23:55.756	2025-09-19 13:40:55.343	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
987	LQ112119	\N	Têrêsa	Lê Hoàng Trúc Quyên	2011-10-09 00:00:00	\N	0988959949	0966959936	28C, Phạm Vấn, Phú Thọ Hòa, Tân Phú	42	t	2025-09-10 16:23:56.217	2025-09-21 02:17:26.114	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1086	CT162317	\N	Martino	Cao Minh Thắng	2016-05-16 00:00:00	\N	0908526177	0908346908	285/106 Lê Văn Quới, BTĐ, Bình Tân	17	t	2025-09-10 16:23:57.677	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
839	NN192507	\N	Têrêsa	Nguyễn An Nhiên	2019-02-13 00:00:00	\N	0917220297	0909280907	26/35 đường số 1, BHHA, Bình Tân	5	t	2025-09-10 16:23:53.563	2025-09-19 15:36:24.802	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
959	NP132139	\N	Têrêsa	Nguyễn Bích Phượng	2013-05-02 00:00:00	\N	0977440933	\N	362 Bình Trị Đông, BTĐ, Bình Tân	33	t	2025-09-10 16:23:55.647	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1221	TT122146	\N	Maria	Thái Phương Trinh	2012-05-26 00:00:00	\N	0903042184	\N	305/54 Lê Văn Quới, BTĐ, Bình Tân	33	t	2025-09-10 16:23:59.526	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
683	NM122353	\N	Maria	Nguyễn Ngọc Yến My	2012-04-21 00:00:00	\N	0983905494	\N	260/1/1M Phan Anh, Hiệp Tân, Tân Phú	29	t	2025-09-10 16:23:49.843	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
111	BA192561	\N	Giuse	Bùi Hồng Ân	2019-12-13 00:00:00	\N	0906783980	0938931850	20/6 đường số 3, BHHA	5	t	2025-09-10 16:23:38.974	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
559	PL182420	\N	Cêcilia	Phạm Trần Trúc Lam	2018-07-05 00:00:00	\N	0908455056	0932939564	73/37 Đường số 12, KP29, BHHA, BT	2	t	2025-09-10 16:23:47.763	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
90	PA132136	\N	Gioan Baotixita	Phan Hải Anh	2013-05-23 00:00:00	\N	0774283283	0987074910	49 Lê Vĩnh Hòa, Phú Thọ Hòa, Tân Phú	32	t	2025-09-10 16:23:38.69	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
279	TD182464	\N	Matta	Thái Ngọc Nhã Đồng	2018-06-08 00:00:00	\N	0906294054	0911124670	201 Đường số 1, BHH A, Bình Tân	2	t	2025-09-10 16:23:41.594	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
852	PQ132299	\N	Têrêsa	Phạm Vũ Quỳnh Như	2013-06-03 00:00:00	\N	0937222029	\N	456 Lê Văn Quới, BHHA, Bình Tân	32	t	2025-09-10 16:23:53.78	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1004	VQ162273	\N	Maria	Vũ Hoàng Phương Quỳnh	2016-12-05 00:00:00	\N	0971649629	\N	325/12 Lê Văn Quới, BTĐ, Bình Tân	16	t	2025-09-10 16:23:56.5	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
353	TH162559	\N	Têrêsa	Trương Hoàng Khả Hân	2016-08-31 00:00:00	\N	0967427277	\N	Cc 53 Nguyễn Sơn, Phú Thạnh	14	t	2025-09-10 16:23:42.877	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
272	VD132137	\N	Phêrô	Vũ Minh Đăng	2013-01-03 00:00:00	\N	0902455106	\N	138/19 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	30	t	2025-09-10 16:23:41.408	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
734	ĐN132114	\N	Đa Minh	Đinh Phạm Hiếu Nghĩa	2013-05-11 00:00:00	\N	0777422439	0909075598	120/5/5A Lê Văn Quới, BHHA, Bình Tân	30	t	2025-09-10 16:23:50.711	2025-09-19 13:40:48.088	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
821	NN122117	\N	Maria	Nguyễn Yến Nhi	2012-04-14 00:00:00	\N	0938683586	\N	49/53 đường số 4, Bình Tân 	34	t	2025-09-10 16:23:53.263	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
478	SK192553	\N	Gioan Baotixita	Song Minh Khang	2019-01-27 00:00:00	\N	0909842026	0965882768	5 Nguyễn Sơn, Phú Thạnh	5	t	2025-09-10 16:23:46.192	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1247	PU142551	\N	Madalêna	Phạm Kiều Vân Uyên	2014-09-09 00:00:00	\N	0968283775	\N	111/9 đường số 1, BHHA	29	t	2025-09-10 16:23:59.886	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
421	VH132117	\N	Phaolo	Vũ Duy Hưng	2013-11-11 00:00:00	\N	0799096699	\N	20/47A ĐS 1, BHHA, Bình Tân	28	t	2025-09-10 16:23:45.013	2025-09-19 13:40:38.509	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	2	0
1335	PY122234	\N	Maria	Phạm Ngọc Hải Yến	2012-01-02 00:00:00	\N	0973864297	\N	20A Hiền Vương, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:24:01.529	2025-09-19 13:41:08.85	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	2	1
1047	LT112121	\N	Phanxico	Lưu Gia Tuấn	2011-06-29 00:00:00	\N	0979641792	0394719290	44/75/19 Chiến Lược, BTĐA, Bình Tân	42	t	2025-09-10 16:23:57.146	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1240	LU112185	\N	Maria	Lê Hoàng Bảo Uyên	2011-10-25 00:00:00	\N	0903920833	0983920833	21/12 Đường 5A, BHHA, Bình Tân	42	t	2025-09-10 16:23:59.79	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
793	ĐN142135	\N	Đa Minh	Đào Danh Nhân	2014-06-15 00:00:00	\N	0983884551	0972117228	364/14B Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:52.823	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
457	ĐK172363	\N	Antôn	Đỗ Gia Khang	2017-08-11 00:00:00	\N	0902780633	0937880986	840/147/6/16 Hương Lộ 2, BTĐ A, Bình Tân	10	t	2025-09-10 16:23:45.676	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1046	HT122190	\N	Giuse	Hoàng Nguyễn Anh Tuấn	2012-09-15 00:00:00	\N	0913977370	0906777370	337/2/10 Thạch Lam, Phú Thạnh, Tân Phú	34	t	2025-09-10 16:23:57.135	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
605	NL162338	\N	Phêrô	Nguyễn Duy Long	2016-11-14 00:00:00	\N	0367180909	0933001277	111/77 Đường số 1, BHHA, Bình Tân	17	t	2025-09-10 16:23:48.555	2025-09-21 08:23:12.469	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1187	NT122178	\N	Têrêsa	Nguyễn Huỳnh Anh Thy	2012-07-07 00:00:00	\N	0907709066	0908102080	37/8/2A ĐS 6, BHHA, Bình Tân	33	t	2025-09-10 16:23:59.086	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
686	PM192544	\N	Maria	Phạm Hoàng Khánh My	2019-10-10 00:00:00	\N	0903357778	0903446778	411A Phú Thọ Hoà, Phú Thọ Hoà	5	t	2025-09-10 16:23:49.896	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
791	ĐN092160	\N	Maria	Đỗ Thị Thanh Nhã	2009-07-20 00:00:00	\N	0909838124	\N	88 Lê Thiệt, Phú Thọ Hòa, Tân Phú	50	t	2025-09-10 16:23:52.781	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
743	LN122247	\N	Anê	Lê Thị Diễm Ngọc	2012-02-02 00:00:00	\N	\N	\N	\N	33	t	2025-09-10 16:23:50.874	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
371	BH182433	\N	Giuse	Bùi Nguyễn Trung Hoàng	2018-06-23 00:00:00	\N	0356622219	0394658876	\N	3	t	2025-09-10 16:23:43.183	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
345	PH162214	\N	Cecilia	Phạm Nguyễn Ngọc Hân	2016-06-13 00:00:00	\N	0373737347	\N	63/1 Đường số 13A, BHHA, Bình Tân	16	t	2025-09-10 16:23:42.754	2025-09-19 15:36:24.88	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
477	PK132117	\N	Giacôbê	Phạm Nguyễn Bảo Khang	2013-02-21 00:00:00	\N	0989798385	\N	119 Bình Long, BHHA, Bình Tân	32	t	2025-09-10 16:23:46.152	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
444	PK142327	\N	Maria	Phạm Đại Ngọc Kim	2014-08-15 00:00:00	\N	0937525608	\N	264 Lê Sao, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:45.459	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
176	TB132413	\N	Giuse	Trần Thanh Bình	2013-11-03 00:00:00	\N	0981777508	\N	152 Lê Niệm, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:39.893	2025-09-19 13:40:30.677	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1315	TV142239	\N	Maria	Trương Nguyễn Thảo Vy	2014-12-05 00:00:00	\N	0907337150	\N	240/15 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:24:01.05	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
785	TN102110	\N	Đa Minh	Tô Việt Nguyên	2010-02-13 00:00:00	\N	0919641005	0919987905	Cc 53 Nguyễn Sơn, Phú Thạnh	34	t	2025-09-10 16:23:52.298	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1265	NV152213	\N	Giuse	Nguyễn Quốc Việt	2015-09-13 00:00:00	\N	0786882385	\N	28 Lê Lăng, Phú Thọ Hòa, Tân Phú	24	t	2025-09-10 16:24:00.148	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
388	DH152247	\N	Gioan Baotixita	Dương Đỗ Gia Huy	2015-04-02 00:00:00	\N	0343750932	\N	42/49/10 Đường số 5, BHHA, Bình Tân	22	t	2025-09-10 16:23:44.439	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
704	TN172315	\N	Gioan	Trần Bảo Nam	2017-04-20 00:00:00	\N	0933991308	0907642117	174 Thạch Lam, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:50.231	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
667	VM172483	\N	Micae	Vũ Hải Sơn Minh	2017-12-15 00:00:00	\N	0938823211	0908961617	42 Lê Niệm, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:49.584	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1096	TT132111	\N	Giuse	Thạch Ngọc Thiên	2013-05-17 00:00:00	\N	0986503607	\N	107/26 Phan Văn Năm, Phú Thạnh, Tân Phú	32	t	2025-09-10 16:23:57.83	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1301	PV172428	\N	Têrêsa	Phạm Tường Vy	2017-07-15 00:00:00	\N	0937771503	\N	155/8 Phú Thọ Hoà, Tân Phú	14	t	2025-09-10 16:24:00.685	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
708	VN152341	\N	Giuse	Vũ Nhật Nam	2015-08-22 00:00:00	\N	\N	\N	\N	24	t	2025-09-10 16:23:50.298	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
723	TN142168	\N	Têrêsa	Trịnh Kim Ngân	\N	\N	\N	\N	\N	28	t	2025-09-10 16:23:50.529	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
677	NM122273	\N	Maria	Nguyễn Đào Nhã My	2012-12-22 00:00:00	\N	0932721655	\N	207A Trần Thủ Độ, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:49.738	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
223	LD102348	\N	Micae	Lê Trang Bảo Duy	2010-08-16 00:00:00	\N	0918089110	0946309915	98 Lê Cao Lãng, Phú Thạnh, Tân Phú	29	t	2025-09-10 16:23:40.534	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
781	NN122168	\N	Maria	Nguyễn Ngọc Lam Nguyên	2012-11-08 00:00:00	\N	0934514405	\N	122/21 Miếu Gò Xoài, BHHA, Bình Tân	35	t	2025-09-10 16:23:52.004	2025-09-19 13:40:22.841	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
782	NN122177	\N	Maria	Nguyễn Ngọc Thảo Nguyên	2012-11-08 00:00:00	\N	0934514405	0773625165	122/21 Miếu Gò Xoài, BHHA, Bình Tân	35	t	2025-09-10 16:23:52.041	2025-09-19 13:40:23.631	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1102	TT112176	\N	Inhaxio	Trịnh Hiếu Thiên	2011-09-11 00:00:00	\N	0909486484	0907505962	CC Rubyland, 4 Lê Quát, Tân Thới Hoà, Tân Phú	42	t	2025-09-10 16:23:57.914	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
830	TN112111	\N	Maria	Trịnh Hoài Thảo Nhi	2011-05-21 00:00:00	\N	0908871775	0909529152	44/30 Trương Phước Phan, Btđ, B, Tân	42	t	2025-09-10 16:23:53.409	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
636	NM112117	\N	Maria	Nguyễn Thị Mến	2011-08-29 00:00:00	\N	0792070170	\N	299 Nguyễn Sơn, Tân Phú	42	t	2025-09-10 16:23:49.076	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
561	TL142263	\N	Têrêsa Maria	Trần Vũ Thiên Lam	2014-06-20 00:00:00	\N	0977113800	0988532995	53 Nguyễn Sơn, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:47.797	2025-09-19 15:36:24.8	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
822	PN172311	\N	Têrêsa	Phạm Quỳnh Phương Nhi	2017-05-16 00:00:00	\N	0978624048	0938054753	251 Hiền Vương, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:53.275	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
820	NN152113	\N	Maria	Nguyễn Yến Nhi	2015-09-12 00:00:00	\N	0975023165	\N	Tổ 11, ấp 1B, xã Vình Lộc B, Bình Chánh	24	t	2025-09-10 16:23:53.253	2025-09-19 15:36:24.879	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
845	NN102191	\N	Têrêsa	Nguyễn Tuyết Nhung	2010-08-24 00:00:00	\N	\N	\N	\N	37	t	2025-09-10 16:23:53.662	2025-09-19 13:40:22.891	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
865	LP162347	\N	Anrê	Lê Hoàng Gia Phát	2016-02-17 00:00:00	\N	0909677867	\N	2/2/16A Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	15	t	2025-09-10 16:23:53.973	2025-09-19 13:40:23.594	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
811	LN162253	\N	Têrêsa	Lê Hoàng Thu Nhi	2016-04-16 00:00:00	\N	0984472710	\N	121 Lê Lâm, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:53.129	2025-09-19 15:36:24.805	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
857	PN192563	\N	Phêrô	Phạm Minh Nhựt	2019-06-04 00:00:00	\N	0978624048	0938054753	251 Hiền Vương, Phú Thạnh	5	t	2025-09-10 16:23:53.864	2025-09-19 15:36:24.879	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
861	HP112163	\N	Giuse	Hoàng Gia Phát	2011-02-04 00:00:00	\N	0932321579	0913821230	24S, Lạc Long Quân, 5, 11	37	t	2025-09-10 16:23:53.922	2025-09-19 13:40:23.403	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
862	HP112346	\N	Louis	Huỳnh Tấn Phát	2011-02-04 00:00:00	\N	0944708015	\N	192/66 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	38	t	2025-09-10 16:23:53.936	2025-09-19 13:40:23.512	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
905	NP142111	\N	Gioan Baotixita	Nguyễn Gia Phú	2014-01-01 00:00:00	\N	\N	\N	\N	28	t	2025-09-10 16:23:54.639	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
104	TA142111	\N	Phêrô	Trần Tuấn Anh	2014-03-08 00:00:00	\N	0986607308	0397530482	12 Lê Văn Quới, BHHA, Bình Tân	28	t	2025-09-10 16:23:38.885	2025-09-19 15:36:24.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
898	BP122193	\N	Giuse	Bùi Đặng Gia Phú	\N	\N	\N	\N	\N	32	t	2025-09-10 16:23:54.529	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1057	BT182421	\N	Anna	Bùi Ngọc Cát Tường	2018-11-21 00:00:00	\N	0931144992	\N	129/8/13 Lê Lư, Phú Thọ Hoà, Tân Phú	2	t	2025-09-10 16:23:57.275	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
946	DP182483	\N	Têrêsa	Đậu Nguyên Tuyết Phương	2018-09-10 00:00:00	\N	\N	\N	53/18/3 Đường số 8B	2	t	2025-09-10 16:23:55.405	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
944	HP122187	\N	Matthêu	Hoàng Quý Phước	2012-09-19 00:00:00	\N	0933757379	\N	\N	36	t	2025-09-10 16:23:55.364	2025-09-19 13:40:22.839	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1041	BT162273	\N	Giuse	Bùi Trung Tín	2016-02-02 00:00:00	\N	0865139913	\N	212 Lê Cao Lãng, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:57.068	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
984	NQ122351	\N	Maria	Nguyễn Lệ Quý	2012-09-27 00:00:00	\N	0949483297	\N	544/16 Hương Lộ 2, BTĐ, Bình Tân	38	t	2025-09-10 16:23:56.164	2025-09-19 13:40:23.308	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	1
323	HH162379	\N	Maria	Huỳnh Nguyễn Bảo Hân	2016-12-01 00:00:00	\N	0906480482	\N	46 Đường số 13, BHHA, Bình Tân	17	t	2025-09-10 16:23:42.376	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
975	NQ122127	\N	Giuse	Nguyễn Trần Minh Quân	2012-12-28 00:00:00	\N	0785607686	0902570064	482/5/5 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú.	35	t	2025-09-10 16:23:55.995	2025-09-19 13:40:22.95	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
976	PQ092197	\N	Giuse	Phạm Đắc Đăng Quân	2009-04-17 00:00:00	\N	0908150788	\N	98 Đường 24, BHHA, Bình Tân	36	t	2025-09-10 16:23:56.015	2025-09-19 13:40:23.039	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
977	PQ122198	\N	Giacôbê	Phạm Lưu Minh Quân	2012-12-07 00:00:00	\N	0908749785	0938861129	58 Trần Thủ Độ, Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:56.035	2025-09-19 13:40:23.151	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
253	HD142116	\N	Phêrô	Hà Quang Đạt	2014-08-05 00:00:00	\N	0378888648	\N	85 Thạch Lam, Hiệp Tân, Tân Phú	28	t	2025-09-10 16:23:40.977	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1038	PT132155	\N	Vinh Sơn	Phạm Đình Tiến	\N	\N	\N	\N	\N	16	t	2025-09-10 16:23:57.015	2025-09-19 15:36:24.88	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1016	NT102148	\N	Đa Minh	Nguyễn Lê Chí Tài	2010-03-02 00:00:00	\N	0917183775	\N	191 ĐS 8,  BHHA, Bình Tân	42	t	2025-09-10 16:23:56.692	2025-09-21 02:38:58.851	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1017	NT092169	\N	Phaolo	Nguyễn Phương Tài	2009-12-15 00:00:00	\N	0774990076	\N	\N	38	t	2025-09-10 16:23:56.706	2025-09-19 13:40:22.911	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1054	LT172568	\N	Giuse	Lâm Đức Tùng	2017-09-03 00:00:00	\N	0772474889	0989450724	65/8A đường số 6, BHHA	14	t	2025-09-10 16:23:57.239	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
394	NH092146	\N	Gioakim	Nguyễn Minh Huy	2009-10-08 00:00:00	\N	0978276420	0388942531	127/71/26 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	50	t	2025-09-10 16:23:44.543	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1052	NT152214	\N	Maria	Nguyễn Đăng Gia Tuệ	2015-12-08 00:00:00	\N	0907831951	\N	Cc 118 Tân Hương, Tân Quý, Tân Phú	22	t	2025-09-10 16:23:57.214	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1136	NT132337	\N	Ysave	Nguyễn Ngọc Bảo Thơ	2013-09-03 00:00:00	\N	0903015660	0785511786	346 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	29	t	2025-09-10 16:23:58.384	2025-09-19 15:36:24.802	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1092	HT112121	\N	Đa Minh	Hoàng Phúc Thiên	2011-07-05 00:00:00	\N	0918347779	0902704879	463 BTĐ, BTĐA, Bình Tân	42	t	2025-09-10 16:23:57.762	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1091	ĐT112118	\N	Phanxico	Đỗ Phạm Gia Thiên	2011-03-17 00:00:00	\N	0987100910	\N	132/13 Đường số 8, BHHA, Bình Tân	36	t	2025-09-10 16:23:57.75	2025-09-19 13:40:22.918	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1034	TT152550	\N	Maria	Trần Vũ Bảo Tiên	2015-07-11 00:00:00	\N	0943554362	0937688464	247/17/5B Thạch Lam, Phú Thạnh	24	t	2025-09-10 16:23:56.957	2025-09-19 15:36:24.8	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
505	VK132127	\N	Vinh Sơn	Vương Phúc Khánh	2013-04-12 00:00:00	\N	0789580582	0937663730	187/2 Đường 5A, BHHA, Bình Tân	30	t	2025-09-10 16:23:46.775	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1131	PT152111	\N	Phaolô	Phạm Trường Thịnh	2015-03-05 00:00:00	\N	0978207042	\N	210A Lê Niệm, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:58.319	2025-09-19 13:40:23.056	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1133	PT212132	\N	Giuse	Phan Quốc Thịnh	2012-09-22 00:00:00	\N	0932769788	0909833442	307/2 Thạch Lam, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:58.347	2025-09-19 13:40:23.313	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1135	DT082195	\N	Maria	Dương Trần Ái Thơ	2008-12-08 00:00:00	\N	0982966799	\N	610/7/8A Tân Kỳ Tân QúY, BHHA, Bình Tân	51	t	2025-09-10 16:23:58.37	2025-09-19 13:40:23.479	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
98	TA172384	\N	Giuse	Trần Minh Anh	2017-05-03 00:00:00	\N	0975271097	\N	33/2 Đường số 1, BHHA, Bình Tân	10	t	2025-09-10 16:23:38.804	2025-09-19 15:36:24.804	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1168	PT092155	\N	Maria	Phạm Minh Thư	2009-12-29 00:00:00	\N	0988354079	0985460300	148 Lê Niệm, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:58.824	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1167	PT172362	\N	Maria	Phạm Anh Thư	2017-09-15 00:00:00	\N	0961863500	\N	419/6/6 Hương Lộ 2, BTĐ, Bình Tân	2	t	2025-09-10 16:23:58.81	2025-09-19 13:40:22.95	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1173	TT082249	\N	Maria	Trần Ngọc Anh Thư	2008-03-30 00:00:00	\N	0922821277	0934250602	84/20 Đường số 14, BHHA, Bình Tân	50	t	2025-09-10 16:23:58.899	2025-09-19 13:40:23.346	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
193	NC132258	\N	Goreti	Ngô Phương Chi	2013-06-21 00:00:00	\N	0982362840	\N	76/12 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	34	t	2025-09-10 16:23:40.113	2025-09-19 15:36:24.804	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1210	NT172421	\N	Gioan	Nguyễn Minh Trí	2017-09-21 00:00:00	\N	0909309829	0944405987	299 Trần Thủ Độ, Phú Thạnh, Tân Phú	2	t	2025-09-10 16:23:59.378	2025-09-19 13:40:22.901	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1231	NT122127	\N	Phanxico	Nguyễn Trung Trực	2012-06-15 00:00:00	\N	\N	0902847969	\N	35	t	2025-09-10 16:23:59.662	2025-09-19 13:40:22.956	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
265	ĐD132166	\N	Vinh Sơn	Đào Hải Đăng	2013-04-07 00:00:00	\N	0981394087	0976102966	250 Lê Niệm, Phú Thạnh, Tân Phú	34	t	2025-09-10 16:23:41.246	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1244	NU092183	\N	Maria	Nguyễn Thái Phương Uyên	2009-07-29 00:00:00	\N	0762619063	0772267294	54 ĐS 16A, BHHA, Bình Tân	50	t	2025-09-10 16:23:59.853	2025-09-19 13:40:23.003	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1251	ĐV142117	\N	Phaolo	Đào Đức Văn	2014-09-21 00:00:00	\N	\N	\N	\N	25	t	2025-09-10 16:23:59.94	2025-09-19 13:40:23.033	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
487	TK132170	\N	Giuse	Trần Nam Khang	2013-05-24 00:00:00	\N	0908803839	0938803839	342/19 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:23:46.454	2025-09-19 15:36:24.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1287	LV132276	\N	Maria	Lê Hoàng Khả Vy	2013-10-01 00:00:00	\N	0909767770	\N	25 Lê Lâm, Phú Thạnh, Tân Phú	24	t	2025-09-10 16:24:00.471	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1285	HV162353	\N	\N	Hoàng Nguyễn Nhật Vy	2016-01-10 00:00:00	\N	0945522338	\N	\N	15	t	2025-09-10 16:24:00.442	2025-09-19 13:40:23.15	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1286	LV162410	\N	Maria	Lâm Tường Vy	2016-03-10 00:00:00	\N	0984497209	\N	49A/13 Đường số 13, BHHA, Bình Tân	18	t	2025-09-10 16:24:00.46	2025-09-19 13:40:23.161	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1324	NY172393	\N	Maria	Nguyễn Hoàng Như Ý	2017-11-24 00:00:00	\N	0963388182	0906841417	54 Đường số 16A, BHHA, Bình Tân	10	t	2025-09-10 16:24:01.297	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1321	ĐY122158	\N	Maria	Đoàn Ngọc Như Ý	2012-01-25 00:00:00	\N	0986156067	\N	46/36/13 Nguyễn Ngọc Nhựt, Tân Quý, Tân Phú	32	t	2025-09-10 16:24:01.205	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
983	LQ142414	\N	Phanxico	Lâm Ngọc Quý	2014-05-28 00:00:00	\N	0906804208	\N	125/1/1 Đường số 8, BHHA, Bình Tân	24	t	2025-09-10 16:23:56.146	2025-09-19 15:36:24.8	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1291	NV132111	\N	Maria	Nguyễn Hữu Tường Vy	2013-04-10 00:00:00	\N	0937362234	0937592234	113/20 Phú Thọ Hòa,  Phú Thọ Hòa, Tân Phú	34	t	2025-09-10 16:24:00.537	2025-09-19 13:40:23.402	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
375	NH152246	\N	Đaminh	Nguyễn Minh Hoàng	2015-11-23 00:00:00	\N	0987573169	\N	282/3 Lê Văn Quới, BHHA, Bình Tân	16	t	2025-09-10 16:23:43.254	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
342	PH152577	\N	Têrêsa	Phạm Ngọc Hân	2015-11-21 00:00:00	\N	0937837094	0931449091	7/4 Hương Lộ 2, BTĐ	18	t	2025-09-10 16:23:42.705	2025-09-19 13:40:23.458	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
387	CH162375	\N	Giuse	Cao Nhật Huy	2016-09-20 00:00:00	\N	0987479910	0967684818	4/5/16 Đường số 3B, BHHA, Bình Tân	19	t	2025-09-10 16:23:44.422	2025-09-19 13:40:24.991	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
355	VH182405	\N	Maria	Vũ Gia Hân	\N	\N	0966379423	\N	252 Miếu Bình Đông, BHHA, BT	1	t	2025-09-10 16:23:42.925	2025-09-19 13:40:23.483	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1138	PT162284	\N	Maria	Phạm Nguyễn Anh Thơ	2016-11-10 00:00:00	\N	0907970716	\N	7 Đỗ Đức Dục, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:58.414	2025-09-19 13:40:23.578	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1	HA172336	\N	Têrêsa Avila	Hoàng Nguyễn Khả Ái	2017-03-04 00:00:00	\N	0906417493	0906417492	102/52 Bình Long, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:37.453	2025-09-19 15:36:24.799	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
688	TM152445	\N	Anna	Trần Ngọc Hà My	2015-08-16 00:00:00	\N	0906106201	0772778236	681/6/10 Âu Cơ, Tân Thành, Tân Phú	18	t	2025-09-10 16:23:49.941	2025-09-19 13:40:24.901	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1055	TT122141	\N	Matheu	Trần Thanh Tùng	2012-12-19 00:00:00	\N	0934023412	0979430803	98A Miếu Bình Đông , BHHA, Bình Tân	37	t	2025-09-10 16:23:57.252	2025-09-19 13:40:23.512	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1053	ĐT132374	\N	Giuse	Đoàn Quốc Tùng	2013-06-24 00:00:00	\N	0987896069	0974309937	248 Lê Niệm, Phú Thạnh, Tân Phú	29	t	2025-09-10 16:23:57.227	2025-09-19 15:36:24.805	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
149	NB122159	\N	Gioan	Ngô Gia Bảo	2012-10-17 00:00:00	\N	0918297379	0908292368	307/6 Đường Thạch Lam, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:39.505	2025-09-19 13:40:24.903	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1029	HT142338	\N	Maria	Hà Phan Cát Tiên	2014-06-09 00:00:00	\N	0886131074	0772115276	137/58 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	23	t	2025-09-10 16:23:56.866	2025-09-19 13:40:24.849	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
496	DK142142	\N	Phaolo	Dương Phúc An Khánh	2014-12-20 00:00:00	\N	0902686891	0772666975	239C Quách Đình Bảo, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:46.625	2025-09-19 13:40:23.499	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1160	NT182431	\N	Maria	Nguyễn Ngọc Anh Thư	2018-07-14 00:00:00	\N	0383118098	0397660690	26/19 Đường số 1, Kp14, BHHA, Bình Tân	3	t	2025-09-10 16:23:58.724	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
471	NK162241	\N	Phêrô	Nguyễn Phạm Gia Khang	2016-03-22 00:00:00	\N	0933393825	\N	150 Quách Đình Bảo, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:46.022	2025-09-19 15:36:24.805	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1334	NY112185	\N	Têrêsa	Nguyễn Thị Hải Yến	2011-03-30 00:00:00	\N	0977440933	\N	362 BTĐ, BTĐ, Bình Tân	41	t	2025-09-10 16:24:01.514	2025-09-19 13:40:23.543	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
144	LB132117	\N	Gioan Baotixita	Lê Hoàng Gia Bảo	2013-06-06 00:00:00	\N	0933766875	\N	62/8/22A Đường số 5A, BHHA, Bình Tân	33	t	2025-09-10 16:23:39.447	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
875	NP142116	\N	Vinh Sơn	Nguyễn Tuấn Phát	2014-07-30 00:00:00	\N	0907460717	\N	87 Lê Thiệt, Phú Thọ Hòa, Tân Phú	27	t	2025-09-10 16:23:54.156	2025-09-19 13:40:25.001	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
74	NA142338	\N	Maria	Nguyễn Ngọc Trâm Anh	2014-08-18 00:00:00	\N	0902900891	\N	\N	20	t	2025-09-10 16:23:38.468	2025-09-19 13:40:25.067	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
56	HA182411	\N	Maria	Hoàng Nguyễn Tú Anh	\N	\N	0972338340	0972857759	299 Nguyễn Sơn, Phú Thạnh, TP	2	t	2025-09-10 16:23:38.233	2025-09-19 13:40:24.953	1	0.32	0.0	0.0	0.13	0.0	0.0	0.00	2	0
59	LA152133	\N	Maria	Lại Phương Anh	2015-10-23 00:00:00	\N	0908484538	\N	69/16 Đường 16, BHHA, Bình Tân	20	t	2025-09-10 16:23:38.266	2025-09-19 13:40:25.205	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
48	DA172412	\N	Maria	Đàm Trần Trâm Anh	\N	\N	0978119507	\N	25/61 Văn Cao, Phú Thạnh, TP	12	t	2025-09-10 16:23:38.121	2025-09-21 03:31:18.085	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1010	TS162311	\N	Madalêna	Trần Ngọc Linh San	2016-05-18 00:00:00	\N	\N	\N	\N	17	t	2025-09-10 16:23:56.593	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
228	PD152419	\N	Đaminh	Phạm Trần Khánh Duy	\N	\N	0908455056	0932939564	73/37 Đường số 12, KP29, BHHA, BT	18	t	2025-09-10 16:23:40.603	2025-09-19 13:40:24.846	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
844	VN172455	\N	Têrêsa	Vũ Ngọc An Nhiên	2017-11-17 00:00:00	\N	0816115999	0968189990	40/28 A Miếu Gò Xoài, BHH A, Bình Tân	13	t	2025-09-10 16:23:53.644	2025-09-19 13:40:25.389	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1206	PT112257	\N	Maria	Phạm Ngọc Bảo Trân	2011-08-24 00:00:00	\N	0386672235	\N	29/8/18 đường số 10, BHHA, quận Bình Tân 	34	t	2025-09-10 16:23:59.334	2025-09-19 15:36:24.805	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
11	DA172401	\N	Giuse	Đinh Phan Quốc An	2017-12-13 00:00:00	\N	0937165774	0909770238	364/63/9 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	14	t	2025-09-10 16:23:37.605	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
7	DA192574	\N	Giuse	Đặng Phúc An	2019-10-13 00:00:00	\N	0985287664	0973403820	7 đường 5A, BHHA, Bình Tân	5	t	2025-09-10 16:23:37.544	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
24	NA212133	\N	Đa Minh	Nguyễn Minh An	2012-09-06 00:00:00	\N	\N	\N	111/47 Đường số 1 	37	t	2025-09-10 16:23:37.796	2025-09-20 16:46:36.563	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	1
234	DD132167	\N	Đa Minh	Dòng Minh Dương	2013-08-17 00:00:00	\N	0344870082	0372219105	191 ĐS 8, BHHA, Bình Tân	30	t	2025-09-10 16:23:40.695	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1196	VT132274	\N	Maria	Vũ Yến Trang	2013-02-22 00:00:00	\N	0931433251	0907743318	81/6A Đường số 14, BHHA, Bình Tân	26	t	2025-09-10 16:23:59.209	2025-09-19 13:40:25.443	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
15	LA172361	\N	Maria	Lê Triều Thiên An	2016-09-15 00:00:00	\N	0911318738	0907853655	129/17 Lê Thiệt, Phú Thọ Hòa, Tân Phú	17	t	2025-09-10 16:23:37.656	2025-09-21 08:23:12.469	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
28	NA112190	\N	Maria	Nguyễn Ngọc Thái An	2011-01-07 00:00:00	\N	0909291883	0906163200	35 Phan Anh, BTĐ, Bình Tân	40	t	2025-09-10 16:23:37.846	2025-09-19 13:40:25.012	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
17	NA122119	\N	Têrêsa	Ngô Thụy Thanh An	2012-09-19 00:00:00	\N	0906880999	0993880999	48/3 Phạm Văn Xảo, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:23:37.686	2025-09-19 13:40:25.042	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
5	CA132113	\N	Anna	Chu Hoài An	2013-07-01 00:00:00	\N	0907546708	0328136687	155/8 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	33	t	2025-09-10 16:23:37.516	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1058	NT162339	\N	Têrêsa	Nguyễn Cát Tường	2016-07-28 00:00:00	\N	0908977010	\N	479/9/7 Hương Lộ 2, BTĐ, Bình Tân	16	t	2025-09-10 16:23:57.297	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
31	NA152468	\N	Têrêsa	Nguyễn Quỳnh An	2015-04-10 00:00:00	\N	0909617927	0915453037	427/19A Lê Văn Quới, BTĐ B, Bình Tân	17	t	2025-09-10 16:23:37.883	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1158	NT132131	\N	Maria	Nguyễn Lê Thiên Thư	2013-05-13 00:00:00	\N	0907590770	0989882767	28C Phạm Vấn, PTH, TP	30	t	2025-09-10 16:23:58.686	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
12	LA172359	\N	Têrêsa	Lê Dương Cát An	2017-10-02 00:00:00	\N	0703474118	\N	136 Lê Niệm, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:37.62	2025-09-19 15:36:24.805	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
3	BA112162	\N	Đa Minh	Bùi Phúc An	2011-01-19 00:00:00	\N	0903736940	0944564233	29E Đường 5F, BHHA, Bình Tân	37	t	2025-09-10 16:23:37.483	2025-09-19 13:40:25.649	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
29	NA172354	\N	Maria	Nguyễn Phương Thúy An	2017-10-27 00:00:00	\N	0763666153	\N	100 Lê Cao Lãng, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:37.858	2025-09-19 15:36:24.806	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
249	TD172415	\N	\N	Trần Thị Linh Đan	2017-11-16 00:00:00	\N	0703474118	0909595867	Sơ Mân Côi	13	t	2025-09-10 16:23:40.932	2025-09-19 13:40:25.99	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
10	DA172458	\N	Têrêsa	Đinh Phạm Nhã An	2017-05-21 00:00:00	\N	0919308696	0972790029	111A Phan Văn Năm, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:37.581	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
40	VA142264	\N	Têrêsa	Võ Hoàng Thảo An	2014-04-13 00:00:00	\N	0986055988	0938771389	\N	27	t	2025-09-10 16:23:38.022	2025-09-19 13:40:25.161	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
848	NN142169	\N	Maria	Nguyễn Nhật Quỳnh Như	2015-01-06 00:00:00	0378885442	0378885442	0903930388	16D đường số 1A, phường Bình Hưng Hòa A, quận Bình Tân, HCM 	27	t	2025-09-10 16:23:53.707	2025-09-19 13:40:25.434	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
14	LA122147	\N	Maria	Lê Thị Diễm An	2012-01-01 00:00:00	\N	\N	0973705285	144/3B Bình Trị Đông, BTĐ, Bình Tân	38	t	2025-09-10 16:23:37.644	2025-09-19 13:40:24.848	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
16	LA152237	\N	Têrêsa	Lưu Hòa An	2015-09-09 00:00:00	\N	0906441521	\N	329/5/8 Tân Hương, Tân Quý, Tân Phú	10	t	2025-09-10 16:23:37.672	2025-09-21 05:13:02.421	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
36	TA192566	\N	Louis	Trần Nguyễn Gia An	2019-02-04 00:00:00	\N	0903084937	0902986945	50/3 đường số 14, BHHA	5	t	2025-09-10 16:23:37.958	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
258	ND132174	\N	Antôn	Nguyễn Thành Đạt	\N	\N	\N	\N	\N	33	t	2025-09-10 16:23:41.082	2025-09-19 15:36:24.807	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
413	HH132134	\N	Giuse	Huỳnh Bá Minh Hưng	2013-03-19 00:00:00	\N	0906387379	\N	224/139/37 đường số 8, BHH, Bình Tân	33	t	2025-09-10 16:23:44.888	2025-09-19 15:36:24.801	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
18	NA092141	\N	Giuse	Nguyễn An	2009-10-21 00:00:00	\N	0918303602	\N	8 đường số 5, Bình Hưng Hòa A, Bình Tân	50	t	2025-09-10 16:23:37.702	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
21	NA152158	\N	Têrêsa	Nguyễn Kim Thiên An	2015-09-04 00:00:00	\N	0984472710	\N	121 Lê Lâm, Phú Thạnh, Tân Phú	24	t	2025-09-10 16:23:37.751	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
64	LA182499	\N	Têrêsa	Lương Ngọc Bảo Anh	2018-05-09 00:00:00	\N	0909194457	0969817229	1 Văn Cao, Phú Thạnh, Tân Phú	3	t	2025-09-10 16:23:38.341	2025-09-19 15:36:24.879	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
27	NA132197	\N	Annê	Nguyễn Ngọc Tường An	2013-01-01 00:00:00	\N	0903176812	0909776212	133A Lê Lư, Phú Thọ Hòa	34	t	2025-09-10 16:23:37.834	2025-09-20 07:10:56.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
67	NA112121	\N	Maria	Nguyễn Hoàng Trâm Anh	2011-02-23 00:00:00	\N	0979997677	0933175253	105 ĐS 14, Bình Hưng Hoa A, Bình Tân	36	t	2025-09-10 16:23:38.374	2025-09-19 13:40:26.658	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
42	VA182409	\N	Maria	Vũ Ngọc Bảo An	2018-05-07 00:00:00	\N	0918222136	0981163868	61/12B Nguyễn Sơn, Phú Thạnh, Tân Phú	1	t	2025-09-10 16:23:38.044	2025-09-20 10:00:36.859	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
68	NA162374	\N	Đa Minh	Nguyễn Nam Anh	2016-10-03 00:00:00	\N	0978256749	0978679884	38 Đình Nghi Xuân, BTĐ, Bình Tân	17	t	2025-09-10 16:23:38.391	2025-09-21 08:23:12.469	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
25	NA142236	\N	Cecilia	Nguyễn Ngọc Bảo An	2014-11-24 00:00:00	\N	\N	\N	\N	27	t	2025-09-10 16:23:37.809	2025-09-19 13:40:27.366	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
69	NA152141	\N	Maria	Nguyễn Ngọc Lan Anh	2015-03-04 00:00:00	\N	0919567502	\N	343/60 Trần Thủ Độ, Phú Thọ Hoà, Tân Phú	21	t	2025-09-10 16:23:38.406	2025-09-19 13:40:27.038	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
46	CA182414	\N	Maria	Chu Bảo Anh	2018-11-19 00:00:00	\N	0988453880	\N	38/35 Hoàng Ngọc Phách, Phú Thọ Hoà, Tân Phú	1	t	2025-09-10 16:23:38.094	2025-09-19 13:40:26.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
45	CA172561	\N	Anna	Công Võ Phương Anh	2017-09-28 00:00:00	\N	0906303387	0902449519	48/52 Phạm Văn Xảo, Phú Thọ Hoà	4	t	2025-09-10 16:23:38.079	2025-09-19 13:40:26.701	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
58	HA142420	\N	Maria	Hồ Ngọc Quỳnh Anh	2014-12-20 00:00:00	\N	0796446355	\N	38/5 Kp31,BHH A, Bình Tân	15	t	2025-09-10 16:23:38.255	2025-09-19 13:40:26.658	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
73	NA172542	\N	Têrêsa	Nguyễn Ngọc Tú Anh	2017-09-20 00:00:00	\N	0902609479	0368018582	352/37/39 Thoại Ngọc Hầu, Phú Thạnh	14	t	2025-09-10 16:23:38.457	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
70	NA152371	\N	Têrêsa	Nguyễn Ngọc Phương Anh	2015-05-17 00:00:00	\N	0908356993	0906356993	17/16 Đường 14B, BHHA, Bình Tân	23	t	2025-09-10 16:23:38.422	2025-09-19 13:40:26.771	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
393	NH162316	\N	Giuse	Nguyễn Hoàng Anh Huy	2016-08-11 00:00:00	\N	0903735125	9039148484	269 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	17	t	2025-09-10 16:23:44.526	2025-09-21 08:23:12.469	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
22	NA142112	\N	Gioan Baotixita	Nguyễn Lê Khải An	2014-10-30 00:00:00	\N	0989882767	\N	28C Phạm Vấn, Phú Thọ Hoà, Tân Phú	25	t	2025-09-10 16:23:37.764	2025-09-19 13:40:26.812	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
34	PA172358	\N	Maria	Phạm Linh An	2017-03-04 00:00:00	\N	\N	\N	\N	13	t	2025-09-10 16:23:37.931	2025-09-19 13:40:25.479	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
47	DA192543	\N	Maria	Dương Lê Bảo Anh	2019-08-14 00:00:00	\N	0918661671	0909656474	364/49 Thoại Ngọc Hầu, Phú Thạnh	5	t	2025-09-10 16:23:38.108	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
54	HA152181	\N	Têrêsa	Hoàng Lê Quỳnh Anh	2015-01-16 00:00:00	\N	0914189143	\N	129/12 Lê Lư, Phú Thọ Hòa, Tân Phú	22	t	2025-09-10 16:23:38.208	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
53	ĐA162285	\N	Têrêsa	Đỗ Hà Bảo Anh	2016-02-15 00:00:00	\N	0908710036	\N	74/3 Đường số 1A, BHHA, Bình Tân	15	t	2025-09-10 16:23:38.192	2025-09-19 13:40:26.797	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
49	ĐA122148	\N	Rosa	Đào Thị Kim Anh	2012-09-11 00:00:00	\N	0362434734	0343880450	181 ĐS 1, Bình Hưng Hoà, Bình Tân	36	t	2025-09-10 16:23:38.132	2025-09-19 13:40:27.126	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
76	NA122281	\N	Phêrô	Nguyễn Nhật Anh	2012-01-01 00:00:00	\N	0938256918	0919654888	260B Đường số 8, BHHA, Bình Tân	21	t	2025-09-10 16:23:38.497	2025-09-19 13:40:27.16	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
51	ĐA112132	\N	Đa Minh	Đinh Nguyên Thế Anh	2011-08-09 00:00:00	\N	0907121812	0909884347	412 Lạc Long Quân, P5, 11	40	t	2025-09-10 16:23:38.165	2025-09-19 13:40:27.227	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
75	NA152556	\N	Giuse	Nguyễn Nhật Anh	2015-10-22 00:00:00	\N	0909548986	0988090885	162 Lê Sao, Phú Thạnh, Tân Phú	18	t	2025-09-10 16:23:38.48	2025-09-19 13:40:27.285	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
57	HA162431	\N	Giuse	Hoàng Trí Anh	2016-03-08 00:00:00	\N	0903627771	0938702089	109 Lê Quốc Trinh, Phú Thọ Hoà, Tân Phú	15	t	2025-09-10 16:23:38.244	2025-09-19 13:40:27.072	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
60	LA162584	\N	Phanxico Xavie	Lê Huy Anh	2016-01-07 00:00:00	\N	0909752586	\N	327E Lê Văn Quới, BTĐ	14	t	2025-09-10 16:23:38.278	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
65	NA092169	\N	Têrêsa	Ngô Thùy Minh Anh	2009-09-04 00:00:00	\N	0979222229	\N	1 Văn Cao, Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:38.351	2025-09-19 13:40:27.421	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
77	NA152356	\N	Giacobe	Nguyễn Nhật Anh	2015-07-13 00:00:00	\N	0907233285	0934824988	60B Văn Cao, Phú Thọ Hòa, Tân Phú	23	t	2025-09-10 16:23:38.517	2025-09-19 13:40:27.476	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
72	NA122151	\N	Maria	Nguyễn Ngọc Quỳnh Anh	2012-09-23 00:00:00	\N	0908131809	\N	127 Quách Đình Bảo, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:38.446	2025-09-19 13:40:27.699	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
26	NA112248	\N	Maria	Nguyễn Ngọc Bảo An	2011-09-14 00:00:00	\N	\N	\N	\N	32	t	2025-09-10 16:23:37.823	2025-09-19 15:36:24.88	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
117	NA082113	\N	Giuse	Nguyễn Hoàng Vũ Ân	2008-09-08 00:00:00	\N	0329791853	0908586549	133D ĐS 1, BHHA, Bình Tân	51	t	2025-09-10 16:23:39.05	2025-09-19 13:40:27.312	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
102	TA152219	\N	Têrêsa	Trần Nguyễn Quỳnh Anh	2015-07-14 00:00:00	\N	0907831951	\N	84 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	22	t	2025-09-10 16:23:38.855	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
101	TA132138	\N	Maria	Trần Nguyễn Bảo Anh	2013-05-01 00:00:00	\N	0913995435	0919428333	126/2 ĐS 4, BHHA, Bình Tân 	32	t	2025-09-10 16:23:38.845	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
88	PA142122	\N	Têrêsa	Phạm Nguyễn Hải Anh	2014-03-03 00:00:00	\N	0903602250	\N	245A Trần Thủ Độ, Phú Thạnh, Tân Phú	25	t	2025-09-10 16:23:38.662	2025-09-19 13:40:28.674	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
96	TA112176	\N	Giuse	Trần Khắc Tinh Anh	2011-01-23 00:00:00	\N	0773639634	\N	21/1 Đường 14, BHHA, Bình Tân	37	t	2025-09-10 16:23:38.775	2025-09-19 13:40:28.725	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
115	MA152263	\N	Giuse	Mai Minh Ân	2015-02-04 00:00:00	\N	0988545566	\N	6 Quách Đình Bảo, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:39.029	2025-09-19 13:40:29.389	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
92	PA132263	\N	Maria	Phan Ngọc Bảo Anh	2013-04-15 00:00:00	\N	0905750240	0905750240	45 Trần Thủ Độ, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:38.721	2025-09-19 13:40:28.925	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
957	VP132195	\N	Cecilia	Võ Hoàng Phương	2013-08-13 00:00:00	\N	\N	0775055930	135/27A Gò Xoài, BHHA, Bình Tân	30	t	2025-09-10 16:23:55.601	2025-09-19 15:36:24.806	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
114	LA132198	\N	Gioan Baotixita	Lý Đức Thiên Ân	2013-09-25 00:00:00				118 Lê Niệm, Phú Thạnh, Tân Phú	31	t	2025-09-10 16:23:39.017	2025-09-21 10:26:30.921	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
83	NA182566	\N	Maria	Nguyễn Xuân Anh	2018-04-17 00:00:00	\N	0938872122	0908941015	367/10 Vườn Lài, Phú Thọ Hoà	4	t	2025-09-10 16:23:38.592	2025-09-19 13:40:28.741	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
95	TA112155	\N	Giuse	Trần Đức Anh	2011-02-25 00:00:00	\N	0902346575	\N	4 Lê Đại, Phú Thọ Hòa, Tân Phú	40	t	2025-09-10 16:23:38.762	2025-09-19 13:40:27.194	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
107	TA182458	\N	Anton	Trịnh Vũ Nhật Anh	2018-10-15 00:00:00	\N	0979811659	0917666112	730/01/02/109 Hương Lộ 2, BTĐ A, Bình Tân	3	t	2025-09-10 16:23:38.932	2025-09-19 13:40:27.279	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
89	PA122263	\N	Têrêsa	Phạm Nguyễn Thúy Anh	2012-03-08 00:00:00	\N	0982808861	0933658972	76/10/6B Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	30	t	2025-09-10 16:23:38.673	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
106	TA082181	\N	Têrêsa	Trần Vũ Minh Anh	2008-11-14 00:00:00	\N	0914446733	0902330414	118/34/45 Liên Khu 5-6, Bình Hưng Hoà B, Bình Tân	51	t	2025-09-10 16:23:38.918	2025-09-19 13:40:27.366	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
121	NA122143	\N	Anna	Nguyễn Hồng Ân	2012-07-03 00:00:00	\N	0933115434	0773375734	180/23 Lý Thánh Tông, Hiệp Tân, Tân Phú	38	t	2025-09-10 16:23:39.112	2025-09-19 13:40:28.673	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
116	NA172439	\N	Phaolô	Nguyễn Đức Thiên Ân	2017-05-21 00:00:00	\N	0933364679	0704801788	278 Hiền Vương, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:23:39.039	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
109	NA112181	\N	Maria	Ngô Ngọc Ánh	2011-11-22 00:00:00	\N	\N	0943573923	172/15 Lê Thúc Hoạch, Tân Phú 	37	t	2025-09-10 16:23:38.952	2025-09-19 13:40:28.679	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
97	TA122151	\N	Maria	Trần Mai Quỳnh Anh	2012-12-12 00:00:00	\N	0978311466	0976650796	126/9 Lê Thiệt, Phú Thọ Hòa, Tân Phú	35	t	2025-09-10 16:23:38.79	2025-09-19 13:40:28.684	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
87	PA122110	\N	Madalêna	Phạm Huỳnh Quỳnh Anh	2012-07-18 00:00:00	\N	0909150170	\N	308 Lê Sao, Phú Thạnh	36	t	2025-09-10 16:23:38.65	2025-09-19 13:40:28.722	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
127	PA182414	\N	Têrêsa	Phạm Hồng Ân	2018-01-14 00:00:00	\N	0908409735	0932117993	151 Lê Cao Lãng, Phú Thạnh, Tân Phú	2	t	2025-09-10 16:23:39.208	2025-09-19 13:40:28.734	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
105	TA122142	\N	Têrêsa	Trần Vũ Đông Anh	2012-12-25 00:00:00	\N	0988604386	0902330414	80/25B Gò Dầu, Tân Sơn Nhì	36	t	2025-09-10 16:23:38.903	2025-09-19 13:40:28.741	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
99	TA172441	\N	Maria	Trần Ngọc Bảo Anh	2017-10-08 00:00:00	\N	\N	0394448308	100 Đường số 4, KP27	1	t	2025-09-10 16:23:38.819	2025-09-19 13:40:28.772	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
128	PA122132	\N	Maria	Phạm Nguyễn Hồng Ân	2012-02-08 00:00:00	\N	0989906806	\N	37/8/2C Số 6, BHHA, Bình Tân	36	t	2025-09-10 16:23:39.226	2025-09-19 13:40:28.797	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
85	PA192549	\N	Têrêsa	Phạm Đỗ Quỳnh Anh	2019-09-13 00:00:00	\N	0906840640	0908297254	363/38/33/29A Đất Mới, BTĐ	5	t	2025-09-10 16:23:38.619	2025-09-19 13:40:29.078	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
110	VA152285	\N	Maria	Vũ Trương Hồng Ánh	2015-05-08 00:00:00	\N	0906882072	\N	46 Trần Thủ Độ, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:38.963	2025-09-19 13:40:29.44	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
185	VC082175	\N	Phêrô	Vũ Mạnh Cường	2008-11-16 00:00:00	\N	0903342942	0908342942	89/23 Đường 14, BHHA, Bình Tân	51	t	2025-09-10 16:23:40.017	2025-09-19 13:40:30.671	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
818	NN142125	\N	Maria	Nguyễn Ngọc Thảo Nhi	2014-08-12 00:00:00	\N	0972532456	\N	326/5 Thạch Lam, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:53.226	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
172	NB092444	\N	Têrêsa	Ngô Khánh Băng	2009-04-04 00:00:00	\N	\N	0973495775	17 Lê Đại, PTH, Tân Phú	45	t	2025-09-10 16:23:39.845	2025-09-19 13:40:30.778	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
126	NA132199	\N	Maria	Nguyễn Vũ Hoài Ân	2013-02-20 00:00:00	\N	0987173143	0385858894	1 Văn Cao, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:23:39.19	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
173	TB182468	\N	Maria 	Trần Ngọc Bích	2018-09-19 00:00:00	\N	0986607308	0397530482	12 Lê Văn Qưới, BHHA, Bình Tân	3	t	2025-09-10 16:23:39.857	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
132	ĐB172361	\N	Antôn	Đỗ Quang Bách	2017-08-22 00:00:00	\N	0936385454	0798475441	294/7 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	11	t	2025-09-10 16:23:39.275	2025-09-19 13:40:29.326	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
142	HB132124	\N	Antôn	Hà Gia Bảo	2013-10-02 00:00:00	\N	0973804417	\N	54 Đường số 12, BHHA, Bình Tân	33	t	2025-09-10 16:23:39.424	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
183	NC152124	\N	Martino	Nguyễn Minh Cường	2015-07-20 00:00:00	\N	0903383924	\N	133 Đỗ Bí, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:39.987	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
162	TB132116	\N	Giuse	Trần Gia Bảo	2013-02-07 00:00:00	\N	0968781149	0933372671	19 Bình Long, BHHA, Bình Tân	32	t	2025-09-10 16:23:39.679	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
166	TB152274	\N	Giuse	Trần Nguyễn Gia Bảo	2015-11-03 00:00:00	\N	0397054039	\N	6 Đường 8B, BHHA, Bình Tân	22	t	2025-09-10 16:23:39.746	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
138	DB092169	\N	Phêrô	Doãn Trần Quốc Bảo	2009-04-05 00:00:00	\N	0918662859	0909122859	413/56/8/8 Lê Văn Quới, Bình Trị Đông A Bình Tân	50	t	2025-09-10 16:23:39.37	2025-09-19 15:36:24.88	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
148	LB172385	\N	Giuse	Lý Gia Bảo	2017-02-07 00:00:00	\N	0342620329	\N	2/7 Đường số 5, BHHA, Bình Tân	10	t	2025-09-10 16:23:39.493	2025-09-19 13:40:29.338	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
147	LB162245	\N	Đaminh	Lưu Gia Bảo	2016-12-16 00:00:00	\N	0903222645	\N	490/15A Hương Lộ 2, BTĐ, Bình Tân	19	t	2025-09-10 16:23:39.48	2025-09-21 09:18:20.194	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
137	BB122118	\N	Phêrô	Bùi Thế Bảo	2012-05-09 00:00:00	\N	0764663758	0764663758	482/5/19 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	37	t	2025-09-10 16:23:39.352	2025-09-19 13:40:29.438	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
141	ĐB112127	\N	Giuse	Đỗ Gia Bảo	2011-03-19 00:00:00	\N	0983114254	0386659830	31 Văn Cao, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:39.411	2025-09-19 13:40:29.492	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
140	ĐB132274	\N	Phêrô	Đinh Gia Bảo	2013-09-24 00:00:00	\N	0935468787	\N	125A Lê Lâm, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:39.398	2025-09-19 13:40:29.498	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
163	TB122268	\N	Giuse	Trần Hoàng Thiên Bảo	2012-08-26 00:00:00	\N	0902331600	\N	122 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	23	t	2025-09-10 16:23:39.694	2025-09-19 13:40:30.521	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
164	TB102145	\N	Micae	Trần Nguyễn Gia Bảo	2010-01-26 00:00:00	\N	\N	0903164315	381/30 Lê Văn Quới, BTĐA, Bình Tân	41	t	2025-09-10 16:23:39.709	2025-09-19 13:40:30.524	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
174	TB102140	\N	Maria	Trần Nguyễn Ngọc Bích	2010-04-16 00:00:00	\N	0776723228	\N	490/19/12 Hương Lộ 2, BTĐQ, Bình Tân	45	t	2025-09-10 16:23:39.869	2025-09-19 13:40:30.573	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
207	ND192561	\N	Maria	Nguyễn Đào Thuý Diễm	2019-01-01 00:00:00	\N	0987920066	0986633224	137/12 Bình Long, BHHA	5	t	2025-09-10 16:23:40.306	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
168	TB142137	\N	Inhaxio	Trịnh Hiếu Bảo	2014-09-11 00:00:00	\N	0907505962	\N	CCRubyland, Số 4 Lê Quát, Tân Thới Hòa, Tân Phú	25	t	2025-09-10 16:23:39.772	2025-09-19 13:40:30.889	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
191	LC152218	\N	Maria	Lê Khánh Chi	2015-03-08 00:00:00	\N	0903377289	\N	87 Miếu Gò Xoài, BHHA, Bình Tân	24	t	2025-09-10 16:23:40.087	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
181	NC162257	\N	Giuse	Nguyễn Thành Công	2016-12-20 00:00:00	\N	0989350235	\N	53 Lê Niệm, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:39.961	2025-09-19 13:40:30.853	1	0.38	0.0	0.0	0.15	0.0	0.0	0.00	2	2
189	NC142264	\N	Maria	Nguyễn Ngọc Bảo Châu	2014-11-19 00:00:00	\N	\N	\N	\N	22	t	2025-09-10 16:23:40.062	2025-09-19 13:40:31.365	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
220	TD152496	\N	Giuse	Trịnh Hùng Dũng	\N	\N	0376758981	0822408525	334 Tân Hòa Đông, BTĐ, BT	24	t	2025-09-10 16:23:40.479	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
469	NK112214	\N	Phaolô	Nguyễn Nam Khang	2011-10-15 00:00:00	\N	0919045026	\N	24/15/2A Miếu Gò Xoài, BHHA, Bình Tân	32	t	2025-09-10 16:23:45.975	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
66	NA132534	\N	Maria	Nguyễn Bùi Nhật Anh	2013-03-23 00:00:00	\N	0908862176	\N	87/22/5B Trần Quang Cơ, Phú Thạnh	32	t	2025-09-10 16:23:38.362	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
170	VB092182	\N	Raphael	Vũ Thiên Bảo	2009-03-14 00:00:00	\N	0775789175	0936731060	292 ĐS 5, BHH, Bình Tân	50	t	2025-09-10 16:23:39.811	2025-09-19 15:36:24.88	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
157	NB172319	\N	Phêrô	Nguyễn Trần Gia Bảo	2017-12-04 00:00:00	\N	0961177530	\N	5 Đường số 5A, BHHA, Bình Tân	12	t	2025-09-10 16:23:39.62	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
212	ĐD132176	\N	Giuse	Đinh Doanh Doanh	\N	\N	\N	\N	\N	32	t	2025-09-10 16:23:40.369	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
216	ĐD142311	\N	Tadeo	Đặng Quang Dũng	2014-10-29 00:00:00	\N	0907735588	\N	\N	24	t	2025-09-10 16:23:40.426	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
213	VD132176	\N	Maria	Vũ Hoàng Phương Dung	\N	\N	\N	\N	\N	33	t	2025-09-10 16:23:40.382	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
182	ĐC122183	\N	Đa Minh	Đào Việt Cường	2012-11-15 00:00:00	\N	0983884551	\N	364/14B Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:39.973	2025-09-19 13:40:30.728	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
194	NC142484	\N	\N	Nguyễn Bảo Chi	\N	\N	0901809447	0906992533	38/7 Đường 5A, BHH A, BT	18	t	2025-09-10 16:23:40.125	2025-09-19 13:40:31.045	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
171	VB122247	\N	Giêrađô	Vũ Thiên Bảo	2012-05-25 00:00:00	\N	0703036121	0906316914	206/1D Lê Văn Quới, BHHA, Bình Tân	36	t	2025-09-10 16:23:39.829	2025-09-19 13:40:31.046	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
178	VB102127	\N	Maria	Vũ Thu Bình	2010-02-08 00:00:00	\N	0908558944	0932959071	21A Đướng 13A, BHHA, Bình Tân	37	t	2025-09-10 16:23:39.927	2025-09-19 13:40:31.102	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
184	TC102151	\N	Phaolo	Trương Quốc Cường	2010-01-20 00:00:00	\N	0933955445	0933790766	53 Nguyễn Sơn, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:40.004	2025-09-19 13:40:31.186	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
211	ND092562	\N	Anna	Nguyễn Huyền Diệu	2009-04-02 00:00:00	\N	0396225982	0865935145	31/78 đường số 3, BHHA	50	t	2025-09-10 16:23:40.358	2025-09-19 13:40:31.041	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
175	PB112141	\N	Đa Minh	Phạm Thanh Bình	2011-05-12 00:00:00	\N	0896677448	0906549149	99 ĐS 14, BHHA, Bình Tân	40	t	2025-09-10 16:23:39.88	2025-09-19 13:40:31.196	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
217	ĐD092195	\N	Đa Minh	Đinh Lê Đức Dũng	2009-08-10 00:00:00	\N	0934229369	98544177	119 BHHA, Bình Tân	45	t	2025-09-10 16:23:40.438	2025-09-19 13:40:31.216	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
219	TD192571	\N	Giuse	Trần Nguyễn Quang Dũng	2019-12-28 00:00:00	\N	0932714113	0764682353	249 Tân Hương, Phú Thọ Hoà	5	t	2025-09-10 16:23:40.466	2025-09-19 13:40:31.225	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
202	ND132116	\N	Antôn	Nguyễn Vinh Danh	2013-06-25 00:00:00	\N	0903597246	0778845203	15/28/2 Lô Tư, BHHA, BT	30	t	2025-09-10 16:23:40.236	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
208	DD152564	\N	Anna	Đinh Ngọc Diệp	2015-10-12 00:00:00	\N	0906954980	0985659590	152/17/1B Lý Thánh Tông, Hiệp Tân	19	t	2025-09-10 16:23:40.321	2025-09-19 13:40:32.679	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
230	VD122175	\N	Đa Minh	Vũ Hoàng Khánh Duy	\N	\N	\N	\N	\N	30	t	2025-09-10 16:23:40.631	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
262	TĐ162213	\N	Giuse	Trần Thế Đạt	2016-09-08 00:00:00	\N	0909545994	\N	1/2/11 khu phố 21, BHHA, Bình Tân	16	t	2025-09-10 16:23:41.16	2025-09-19 13:40:32.475	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	1
259	TĐ162388	\N	Giuse	Trần Quốc Đạt	2016-09-18 00:00:00	\N	0902399877	0909324687	68/17/4 Đường số 3, BHHA, Bình Tân	17	t	2025-09-10 16:23:41.108	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
267	NĐ162386	\N	Phêrô	Nguyễn Phạm Hải Đăng	2016-03-27 00:00:00	\N	0934064979	0919153666	35 Đường số 1A, BHHA, Bình Tân	17	t	2025-09-10 16:23:41.307	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
557	NL132164	\N	Maria	Nguyễn Thảo Lam	2013-02-22 00:00:00	\N	0901506727	\N	10/9 Đường 5F, BHHA, Bình Tân	33	t	2025-09-10 16:23:47.729	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
245	ND182512	\N	Anna	Nguyễn Ngọc Linh Đan	2018-03-08 00:00:00	\N	0937111297	0909155036	186 Lê Văn Quới, BTĐ	4	t	2025-09-10 16:23:40.875	2025-09-19 13:40:33.194	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
236	ND182416	\N	Anna	Nguyễn Huỳnh Ánh Dương	2018-10-13 00:00:00	\N	0906737364	0908929249	61/2/3 Nguyễn Sơn, Phú Thạnh, Tân Phú	2	t	2025-09-10 16:23:40.729	2025-09-19 15:36:24.807	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
240	TD122176	\N	Maria	Trần Lê Ánh Dương	2012-10-23 00:00:00	\N	\N	0792472994	213 Lê Lâm, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:40.808	2025-09-19 15:36:24.807	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
266	ND182456	\N	Gioan	Nguyễn Ngô Hải Đăng	2018-02-06 00:00:00	\N	\N	0764455806	326 Thạch Lam, PT, Tân Phú	2	t	2025-09-10 16:23:41.269	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
229	TD162348	\N	Vinh Sơn	Trần Khánh Duy	2016-02-10 00:00:00	\N	0919604683	0944397281	28 Đường số 8B, BHHA, Bình Tân	19	t	2025-09-10 16:23:40.616	2025-09-21 09:18:26.855	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
197	NC162253	\N	Maria	Nguyễn Ngọc Linh Chi	2016-02-03 00:00:00	\N	0933132990	\N	87/13 Đường số 3, BHHA, Bình Tân	15	t	2025-09-10 16:23:40.166	2025-09-19 13:40:32.322	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
200	ND132448	\N	Anton	Nguyễn Thành Danh	2013-10-29 00:00:00	\N	0902875175	0907484098	81/18 Đường số 14, BHH A, Bình Tân	18	t	2025-09-10 16:23:40.207	2025-09-19 13:40:32.321	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
255	ND092164	\N	Giacôbê	Nguyễn Quốc Đạt	2009-11-26 00:00:00	\N	0908594910	0903188875	217 Lê Sao, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:41.006	2025-09-19 13:40:32.32	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
250	TD112180	\N	Anna	Trần Thùy Linh Đan	2011-06-25 00:00:00	\N	0904444300	\N	329/10 Tân Hương, Tân Quý, Tân Phú	41	t	2025-09-10 16:23:40.942	2025-09-19 13:40:32.918	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
263	VD122181	\N	Đa Minh	Vũ Tiến Đạt	\N	\N	\N	\N	\N	35	t	2025-09-10 16:23:41.183	2025-09-19 13:40:32.687	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
146	LB132364	\N	Đa Minh	Lương Gia Bảo	2013-12-07 00:00:00	\N	0909171351	\N	127/2/64 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	29	t	2025-09-10 16:23:39.469	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
257	ND122179	\N	Gioakim	Nguyễn Thành Đạt	2012-09-21 00:00:00	\N	0985431308	0933627422	137/104 Phan Anh, Bình Trị Đông, Bình Tân	38	t	2025-09-10 16:23:41.06	2025-09-19 13:40:32.636	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
508	ĐK102164	\N	Giuse	Đỗ Tân Khoa	2010-04-29 00:00:00	\N	\N	\N	\N	45	t	2025-09-10 16:23:46.823	2025-09-19 13:40:32.559	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
247	PD082110	\N	Giuse	Phạm Ngọc Huy Đan	2008-09-19 00:00:00	\N	0908312635	0908312635	31 Trương Phước Phan, BTĐ, Bình Tân	45	t	2025-09-10 16:23:40.904	2025-09-19 13:40:32.529	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
303	TH132117	\N	Maria	Tăng Thanh Hà	2013-05-16 00:00:00	\N	0914514599	\N	8/4 Đường 5C, BHHA, , Bình Tân	32	t	2025-09-10 16:23:42.047	2025-09-19 13:40:34.403	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
361	HH092130	\N	Gioan Baotixita	Huỳnh Đình Nhật Hiệp	2009-07-05 00:00:00	\N	0987081006	\N	128/4/43 Nguyễn Sơn, Phú Thọ Hoà, Tân Phú	50	t	2025-09-10 16:23:43.025	2025-09-19 15:36:24.802	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1094	PT152110	\N	Giuse	Phạm Nhật Thiên	2015-11-26 00:00:00	\N	0944470930	\N	35, ĐS 8, BHHA, Bình Tân	21	t	2025-09-10 16:23:57.796	2025-09-19 13:40:34.533	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
309	NH142197	\N	Maria	Nguyễn Minh Hằng	2014-08-10 00:00:00	\N	0919191958	\N	69B Kênh nước đen, BHH A, Bình Tân	25	t	2025-09-10 16:23:42.154	2025-09-19 13:40:34.899	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
301	PH132115	\N	Agnes	Phạm Khánh Hà	2013-07-21 00:00:00	\N	0978374779	\N	210A Lê Niệm, Phú Thạnh, Tân Phú	25	t	2025-09-10 16:23:42.019	2025-09-19 13:40:34.384	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
308	NH132131	\N	Phêrô	Nguyễn Sơn Nhật Hào	2013-07-03 00:00:00	\N	0909394386	0945961714	26/11 ĐS 5, BHHA, Bình Tân	31	t	2025-09-10 16:23:42.129	2025-09-19 13:40:34.337	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
304	TH112419	\N	Maria	Trần Ngọc Khánh Hà	2011-09-30 00:00:00	\N	0908106619	\N	119 Bình Long, BHHA, BT	37	t	2025-09-10 16:23:42.061	2025-09-19 13:40:34.647	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
290	VD102141	\N	Đa Minh	Vũ Việt Đức	2010-04-22 00:00:00	\N	0987076902	\N	90 ĐS 1A, Bình Tân	45	t	2025-09-10 16:23:41.834	2025-09-19 13:40:34.34	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
299	NH112541	\N	Lucia	Nguyễn Trần Thu Hà	2011-12-12 00:00:00	\N	0392747500	\N	20/29D đường số 1, BHHA	41	t	2025-09-10 16:23:41.987	2025-09-19 13:40:35.126	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
282	HĐ162254	\N	Đaminh	Hoàng Thiên Đức	2016-06-30 00:00:00	\N	0902704879	\N	463 Bình Trị Đông, BTĐA, Bình Tân	15	t	2025-09-10 16:23:41.655	2025-09-19 13:40:34.403	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
286	TD172468	\N	Phêrô	Trần Minh Đức	2017-01-18 00:00:00	\N	0922213939	0922733339	192/3 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú	12	t	2025-09-10 16:23:41.738	2025-09-21 03:31:18.084	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
281	HD172461	\N	Giuse	Hà Minh Đức	2017-05-04 00:00:00	\N	0865636363	0967757283	108 Đường số 4, BHH A, Bình Tân	13	t	2025-09-10 16:23:41.641	2025-09-19 13:40:34.286	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
302	PH182436	\N	Maria	Phạm Minh Hà	2018-09-11 00:00:00	\N	0359553773	0977881036	6/1A Miếu Gò Xoài, BHHA, Bình Tân	1	t	2025-09-10 16:23:42.034	2025-09-19 13:40:34.293	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
284	PD112133	\N	Batôlômêô	Phạm Trí Đức	2011-04-11 00:00:00	\N	\N	0978207042	210A Lê Niệm, Phú Thạnh	36	t	2025-09-10 16:23:41.706	2025-09-19 13:40:34.295	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
296	TG122190	\N	Maria	Trương Vũ Quỳnh Giang	2012-11-05 00:00:00	\N	0934148499	0932148499	46/15 Đường 3,  BHHA, Bình Tân	35	t	2025-09-10 16:23:41.941	2025-09-19 13:40:34.338	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
285	TD112199	\N	Đa Minh	Trần Hoàng Minh Đức	2011-07-31 00:00:00	\N	\N	0908827383	206 Thạch Lam, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:23:41.725	2025-09-19 13:40:34.352	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
287	TD152441	\N	Giuse	Trần Minh Đức	2015-01-08 00:00:00	\N	0903992679	\N	233 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú	24	t	2025-09-10 16:23:41.773	2025-09-19 13:40:34.39	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
307	NH142367	\N	Anna	Nguyễn Ngọc Hồng Hạnh	2014-11-27 00:00:00	\N	0377671733	\N	263 Bình Long, BHHA, Bình Tân	23	t	2025-09-10 16:23:42.114	2025-09-19 13:40:34.39	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
291	NG082126	\N	Giuse	Nguyễn Hoàng Gia	2008-11-03 00:00:00	\N	0937629462	\N	18/9 Hoàng Ngọc Phách, Phú Thọ Hòa, Tân Phú	40	t	2025-09-10 16:23:41.856	2025-09-19 13:40:34.441	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
305	NH122128	\N	Maria	Nguyễn Khang Phúc Hạ	2012-06-28 00:00:00	\N	0968400088	0888882200	301/33 Bình Long, BHHA, Bình Tân	36	t	2025-09-10 16:23:42.074	2025-09-19 13:40:34.849	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
312	CH122169	\N	Cecilia	Cao Gia Hân	2012-02-08 00:00:00	\N	0908526177	0908346908	285/106 Lê Văn Quới, BTĐ, Bình Tân	37	t	2025-09-10 16:23:42.21	2025-09-19 13:40:35.026	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
310	NH112117	\N	Maria	Nguyễn Thị Diễm Hằng	2011-06-24 00:00:00	\N	0907972257	\N	20/71 ĐS 1, BHHA, Bình Tân	41	t	2025-09-10 16:23:42.174	2025-09-19 13:40:35.152	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
278	ND122146	\N	Giuse	Nguyễn Minh Đông	2012-01-06 00:00:00	\N	0901506727	0384114977	10/9 Đường 5F, BHHA, Bình Tân	38	t	2025-09-10 16:23:41.564	2025-09-19 13:40:35.166	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
297	DG112180	\N	Maria	Dương Quỳnh Giao	2011-05-12 00:00:00	\N	0836973999	0933399050	1/27 Đường 5A, BHHA, Bình Tân	40	t	2025-09-10 16:23:41.958	2025-09-19 13:40:35.167	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
326	LH082162	\N	Rosa	Lê Hoàng Ngọc Hân	2008-07-08 00:00:00	\N	0903684479	0908540930	146 Lê Lâm, Phú Thạnh, Tân Phú	51	t	2025-09-10 16:23:42.445	2025-09-19 13:40:34.999	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
344	PH142245	\N	Maria	Phạm Nguyễn Gia Hân	2014-05-05 00:00:00	\N	0373737547	\N	63/1 Đường số 13A, BHHA, Bình Tân	27	t	2025-09-10 16:23:42.742	2025-09-19 13:40:37.306	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
276	PD142117	\N	Maria Rosa	Phạm Ý Đoan	2014-06-03 00:00:00	\N	0936680353	0903352339	245A Trần Thủ Độ, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:41.519	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
233	VD172436	\N	Maria	Vương Mỹ Duyên	2017-08-02 00:00:00	\N	0913902830	0326816151	260A Đường số 8, BHH A, Bình Tân	14	t	2025-09-10 16:23:40.675	2025-09-19 15:36:24.805	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
335	NH182427	\N	Maria	Nguyễn Ngọc Gia Hân	2018-11-26 00:00:00	\N	0972532456	0768189928	326/5 Thạch Lam, Phú Thạnh, Tân Phú	3	t	2025-09-10 16:23:42.589	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
346	PH092131	\N	Têrêsa	Phan Đặng Gia Hân	2009-01-13 00:00:00	\N	0918933261	0975996138	66/8 Lê Cảnh Tuân, Phú Thọ Hòa, Tân Phú	50	t	2025-09-10 16:23:42.769	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
325	KH152284	\N	Giuse	Kiều Việt Gia Hân	2015-01-28 00:00:00	\N	0901555574	\N	364/50 Trình Đình Trọng, Hòa Thạnh, Tân Phú	21	t	2025-09-10 16:23:42.431	2025-09-19 13:40:36.5	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
350	TH122156	\N	Maria	Trần Hoàng Gia Hân	2012-03-27 00:00:00	\N	0903328128	0989973449	20/27B ĐS 1, BHHA, Bình Tân	37	t	2025-09-10 16:23:42.83	2025-09-19 13:40:35.023	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
337	NH112570	\N	Maria	Nguyễn Ngô Vạn Gia Ngân	2011-07-01 00:00:00		0909686509		1/4 đường số 1C, BHHA	19	t	2025-09-10 16:23:42.629	2025-09-21 09:14:43.079	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
318	ĐH162317	\N	Maria	Đoàn Ngọc Hân	2016-04-15 00:00:00	\N	0903690812	\N	5 Trần Thủ Độ, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:42.294	2025-09-19 13:40:36.616	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
322	HH102160	\N	Annê	Hồ Ngọc Hân	2010-10-28 00:00:00	\N	0918898207	\N	89 ĐS 3, BHHA, Bình Tân	45	t	2025-09-10 16:23:42.357	2025-09-19 13:40:35.007	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
306	NH112146	\N	Maria	Nguyễn Hồng Hạnh	2011-02-16 00:00:00	\N	0935857971	0906629760	194/3 ĐS 8,  BHHA, Bình Tân	42	t	2025-09-10 16:23:42.091	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
338	NH142134	\N	Maria	Nguyễn Thanh Ngọc Hân	2014-02-12 00:00:00	\N	0349533598	0398635020	\N	26	t	2025-09-10 16:23:42.641	2025-09-19 13:40:36.633	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
334	NH132140	\N	Maria	Nguyễn Ngọc Hân	2013-08-20 00:00:00	\N	0903787916	\N	9C Đường 1A, BHHA, Bình Tân	30	t	2025-09-10 16:23:42.573	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
349	TH182487	\N	Maria	Trần Bảo Gia Hân	2018-03-08 00:00:00	\N	0978562926	0862030605	73A Liên Khu 10-11, BTĐ, BT	2	t	2025-09-10 16:23:42.816	2025-09-19 13:40:34.851	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
336	NH192531	\N	Matta	Nguyễn Ngọc Khánh Hân	2019-09-02 00:00:00	\N	0979339711	0973288707	66/2 Lê Cảnh Tuân, Phú Thọ Hoà	6	t	2025-09-10 16:23:42.61	2025-09-19 13:40:36.706	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
329	NH192535	\N	Têrêsa	Nguyễn Hoàng Khả Hân	2019-10-16 00:00:00	\N	0903735125	0939148484	269 Phú Thọ Hoà, Phú Thọ Hoà	6	t	2025-09-10 16:23:42.49	2025-09-19 13:40:36.451	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
340	NH132128	\N	Maria	Nguyễn Thị Ngọc Hân	2013-11-15 00:00:00	\N	0918501468	0941041468	17/11 ĐS 3,  BHHA,  Bình Tân	34	t	2025-09-10 16:23:42.671	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
341	PH152243	\N	Maria	Phạm Gia Hân	2015-12-12 00:00:00	\N	0906677023	\N	125 Đường số 14, BHHA, Bình Tân	20	t	2025-09-10 16:23:42.69	2025-09-19 13:40:36.449	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
315	DH182491	\N	Anna	Đặng Gia Bảo Hân	\N	\N	0931212184	0325688187	42/2 Liên Khu 8-9	4	t	2025-09-10 16:23:42.252	2025-09-19 13:40:36.452	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
313	DH172417	\N	Anna	Dương Đỗ Gia Hân	2017-09-30 00:00:00	\N	0902979562	0343750932	42/49/10 Đường số 5, BHHA, Bình Tân	12	t	2025-09-10 16:23:42.225	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
339	NH132402	\N	Maria	Nguyễn Thị Ngọc Hân	2013-12-03 00:00:00	\N	0908059717	\N	125 Bình Trị Đông, BT	18	t	2025-09-10 16:23:42.653	2025-09-19 13:40:36.703	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
381	VH142219	\N	Đaminh	Vũ Duy Hoàng	2014-10-14 00:00:00	\N	\N	\N	206/1D Lê Văn Quới, BHHA, Bình Tân	22	t	2025-09-10 16:23:44.315	2025-09-19 15:36:24.806	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
401	PH122179	\N	Faxicode Sale	Phạm Nguyễn Tường Huy	2012-03-12 00:00:00	\N	0903884663	0903602250	245A Trần Thủ Độ, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:44.673	2025-09-19 13:40:38.559	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
402	PH092181	\N	Giuse	Phan Nguyễn Hải Huy	2009-06-24 00:00:00	\N	0928234789	0905750240	45 Trần Thủ Độ, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:44.691	2025-09-19 13:40:38.555	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
448	WK122132	\N	Maria	WongThiên Kim	\N	\N	0706910287	\N	48/37 Đường 14A, BHH A, Bình Tân	38	t	2025-09-10 16:23:45.526	2025-09-19 13:40:39.127	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	1
427	PH152114	\N	Phanxico Assisi	Phạm Lê Bá Hương	2015-03-03 00:00:00	\N	0908531859	\N	21C Phạm Vấn, Phú Thọ Hoà, Tân Phú	22	t	2025-09-10 16:23:45.129	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
465	NK182443	\N	Tôma	Nguyễn Đào Tuấn Khang	2018-01-28 00:00:00	\N	\N	\N	21/3 Đường 14, BHH A, Bình Tân	3	t	2025-09-10 16:23:45.873	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
451	TK082164	\N	Antôn	Trần Phúc Kỳ	2008-10-17 00:00:00	\N	0909194256	0345441717	52 ĐS 14A, BHHA, Bình Tân	51	t	2025-09-10 16:23:45.572	2025-09-19 13:40:39.081	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
435	PK122120	\N	Antôn	Phạm Hà Anh Kiệt	\N	\N	\N	0908161889	\N	35	t	2025-09-10 16:23:45.286	2025-09-19 13:40:39.226	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
398	PH122198	\N	Phaolo	Phạm Đoàn Gia Huy	2012-03-26 00:00:00	\N	\N	0938545399	27 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	38	t	2025-09-10 16:23:44.627	2025-09-19 13:40:39.11	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
464	NK182463	\N	Martino	Nguyễn Duy Khang	2018-09-18 00:00:00	\N	0919977447	\N	378/95 Thoại Ngọc Hầu, PT, Tân Phú	2	t	2025-09-10 16:23:45.858	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
408	VH182416	\N	Giuse Maria	Võ Quang Huy	2018-11-10 00:00:00	\N	0903948161	0925406363	12/8A Đường số 13A, BHHA, BT	1	t	2025-09-10 16:23:44.794	2025-09-19 13:40:39.654	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
422	ĐH162312	\N	Têrêsa	Đào Ngọc Hương	2016-06-22 00:00:00	\N	0933111186	0909372237	75 Tô Hiệu, Phú Thạnh, Tân Phú	19	t	2025-09-10 16:23:45.032	2025-09-19 13:40:38.655	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
395	NH142560	\N	Giuse	Nguyễn Ngô Gia Huy	2014-06-30 00:00:00	\N	\N	\N	\N	19	t	2025-09-10 16:23:44.558	2025-09-21 09:18:37.873	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
669	VM122196	\N	Martino	Vy Gia Minh	2012-09-10 00:00:00	\N	\N	0934334334	131A Lê Lâm, Phú Thạnh, Tân Phú	34	t	2025-09-10 16:23:49.614	2025-09-19 15:36:24.803	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
406	TH142177	\N	Giuse	Trần Minh Huy	2014-02-27 00:00:00	\N	0375056528	\N	15 Lê Lăng, Phú Thọ Hoà, Tân Phú	25	t	2025-09-10 16:23:44.756	2025-09-19 13:40:38.678	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
409	VH112178	\N	Giuse	Vũ Hoàng Huy	2011-06-26 00:00:00	\N	0966379423	0327335743	307/25 Thạch Lam, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:44.824	2025-09-19 13:40:38.717	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
411	ĐH142119	\N	Giuse	Đinh Quốc Hoàng Hưng	2014-04-27 00:00:00	\N	0903085220	\N	480/13/5/13 Mã Lò, BHHA, Bình Tân	25	t	2025-09-10 16:23:44.859	2025-09-19 13:40:38.731	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
446	PK132149	\N	Têrêsa	Phạm Hoàng Thiên Kim	2013-12-21 00:00:00	\N	0918088285	\N	103 ĐS 12, BHHA, Bình Tân	33	t	2025-09-10 16:23:45.489	2025-09-19 13:40:39.1	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
458	HK112186	\N	Giuse	Hoàng Minh Khang	2011-05-05 00:00:00	\N	0909750730	0868049151	264/7 Nguyễn Sơn	41	t	2025-09-10 16:23:45.691	2025-09-19 13:40:39.112	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
417	PH092425	\N	Đa Minh	Phạm Chấn Hưng	2009-09-08 00:00:00	\N	\N	\N	\N	37	t	2025-09-10 16:23:44.946	2025-09-19 13:40:39.331	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
488	TK152129	\N	Phaolo	Trần Phạm Ân Khang	2015-11-07 00:00:00	\N	0937076242	\N	422 Phú Thọ Hoà , Phú Thọ Hoà, Tân Phú	22	t	2025-09-10 16:23:46.468	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
455	BK152118	\N	Giuse	Bùi Gia Khang	2015-10-06 00:00:00	\N	0925436507	\N	43 Đường 5F, BHHA, Bình Tân	19	t	2025-09-10 16:23:45.642	2025-09-19 13:40:41.128	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
499	ĐK142114	\N	Maria	Đoàn Nguyễn Gia Khánh	2014-03-10 00:00:00	0983390018	0983390018	0983390018	4 Trần Thủ Độ, quận Tân Phú, HCM 	27	t	2025-09-10 16:23:46.679	2025-09-19 13:40:40.451	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
450	TK142116	\N	Phaolô	Trần Hồng Kỳ	2014-10-05 00:00:00	\N	0908897637	\N	6/19 đường 14A, BHHA, Bình Tân	25	t	2025-09-10 16:23:45.556	2025-09-19 13:40:40.356	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
476	PK132161	\N	Gioan Baotixita	Phạm Dương Minh Khang	\N	\N	\N	\N	\N	31	t	2025-09-10 16:23:46.138	2025-09-19 13:40:40.522	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
507	ĐK142128	\N	Giuse	Đinh Minh Khoa	2014-04-27 00:00:00	\N	0987123414	\N	92 Bình Long, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:46.806	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
437	TK142131	\N	Phaolo	Trần Anh Kiệt	2014-06-09 00:00:00	\N	0932050767	\N	18 ĐS 4, BHHA, Bình Tân	28	t	2025-09-10 16:23:45.334	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
429	BK172432	\N	Giuse	Bùi Nguyễn Trung Kiên	2017-01-23 00:00:00	\N	0356622219	0394658876	\N	12	t	2025-09-10 16:23:45.173	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
462	LK132185	\N	Giuse	Linh Kim Minh Khang	2013-07-29 00:00:00	\N	0962601051	0329131051	293 Nguyễn Sơn, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:23:45.811	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
575	TL172327	\N	Đa Minh	Trần Hoàng Lâm	2017-10-27 00:00:00	\N	0969393958	0931966269	8/12/2 Lê Văn Quới, BHHA, Bình Tân	11	t	2025-09-10 16:23:48.045	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
456	DK172451	\N	Giuse	Đinh Bảo Khang	2017-07-25 00:00:00	\N	0903385473	\N	107/5 Phan Văn Năm, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:45.658	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
504	TK172345	\N	Giuse Maria	Trần Bảo Khánh	2017-03-13 00:00:00	\N	0909880406	0907037569	243 Bình Long, BHHA, Bình Tân	10	t	2025-09-10 16:23:46.764	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
443	NK152447	\N	Têrêsa	Nguyễn Thiên Kim	2015-05-11 00:00:00	\N	0902875175	0907484098	81/18 Đường số 14, BHH A, Bình Tân	18	t	2025-09-10 16:23:45.439	2025-09-19 13:40:40.54	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
461	LK162339	\N	Phaolô	Lê Trần Hạo Khang	2016-08-20 00:00:00	\N	0703474118	\N	136 Lê Niệm, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:45.79	2025-09-19 13:40:40.353	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
495	VK092179	\N	Maria	Vũ Lê Mai Khanh	2009-03-13 00:00:00	\N	0938285389	0777800058	76 Đường 22, BHHA, Bình Tân	45	t	2025-09-10 16:23:46.605	2025-09-19 13:40:40.364	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
482	TK172316	\N	Phêrô	Trần Bảo Khang	2017-10-19 00:00:00	\N	0902563500	\N	184 Thành Công, Tân Thành, Tân Phú	11	t	2025-09-10 16:23:46.289	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
431	TK152365	\N	Giuse	Trần Đức Kiên	2015-12-29 00:00:00	\N	0938954686	0819935718	10/1A Đường số 10, BHHA, Bình Tân	23	t	2025-09-10 16:23:45.21	2025-09-19 13:40:40.408	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
480	TK132140	\N	Giuse	Trần An Khang	2013-11-01 00:00:00	\N	0909490140	0932617895	84 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	33	t	2025-09-10 16:23:46.244	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
497	ĐK122150	\N	Giuse	Đặng Duy Khánh	\N	\N	\N	\N	\N	31	t	2025-09-10 16:23:46.637	2025-09-19 13:40:40.506	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
492	VK172575	\N	Giuse	Vũ Trọng Khang	2017-07-27 00:00:00	\N	0909183004	0798874317	24A đường số 8, BHHA	14	t	2025-09-10 16:23:46.545	2025-09-19 13:40:40.517	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
479	TK162535	\N	Gioan Baotixita	Tống Minh Khang	2016-06-07 00:00:00	\N	0906836205	\N	206/28/6 Lê Văn Quới, BHHA	14	t	2025-09-10 16:23:46.22	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
445	PK172329	\N	Maria	Phạm Hoàng Thiên Kim	2017-02-04 00:00:00	\N	\N	\N	\N	10	t	2025-09-10 16:23:45.475	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
475	PK132114	\N	Ignazio	Phạm Anh Khang	2013-04-18 00:00:00	\N	0976071310	\N	53 Nguyễn Sơn CC Phú Thạnh, Phú Thạnh, Tân Phú	32	t	2025-09-10 16:23:46.112	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
439	VK152237	\N	Phêrô	Võ Trần Anh Kiệt	2015-04-15 00:00:00	\N	\N	\N	\N	20	t	2025-09-10 16:23:45.368	2025-09-19 13:40:41.063	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
490	TK182534	\N	Antôn	Trịnh Gia Khang	2018-11-25 00:00:00	\N	0907078609	0769666244	6B Văn Cao, Phú Thạnh	4	t	2025-09-10 16:23:46.501	2025-09-19 13:40:41.076	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
434	ĐK102151	\N	Giuse	Đàm Huỳnh Tuấn Kiệt	2010-07-21 00:00:00	\N	0907667477	0933052013	127/14 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	40	t	2025-09-10 16:23:45.268	2025-09-19 13:40:41.113	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
493	NK122174	\N	Agatha	Nguyễn Hải Lam Khanh	2012-08-03 00:00:00	\N	0934143869	0908999804	3/11A Văn Cao, Phú Thạnh, Tân Phú 	35	t	2025-09-10 16:23:46.566	2025-09-19 13:40:41.117	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
442	NK182425	\N	Têrêsa	Nguyễn Hồ Thiên Kim	2018-02-03 00:00:00	\N	0934087256	0934087956	77B Đường số 14, BHH A, Bình Tân	2	t	2025-09-10 16:23:45.418	2025-09-19 13:40:41.164	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
519	NK182403	\N	Giuse	Nguyễn Nguyên Khoa	2018-08-26 00:00:00	\N	0362115353	94830595	29/9 Đình Tân Khai, BTĐ, Bình Tân	2	t	2025-09-10 16:23:47.037	2025-09-19 13:40:42.794	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
542	NK122143	\N	Gioan Baotixita	Nguyễn Trần Anh Khôi	\N	\N	\N	\N	\N	35	t	2025-09-10 16:23:47.439	2025-09-19 13:40:43.074	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	1
536	NK182519	\N	Phêrô	Nguyễn Hoàng Minh Khôi	2018-10-18 00:00:00	\N	0903145299	0902019035	37/8/33 đường số 6, BHHA, Bình Tân	4	t	2025-09-10 16:23:47.332	2025-09-19 13:40:42.348	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
524	SK142183	\N	Giuse	Song Anh Khoa	\N	\N	\N	\N	\N	28	t	2025-09-10 16:23:47.12	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
540	NK132145	\N	Phaolo	Nguyễn Tấn Minh Khôi	\N	\N	\N	\N	\N	32	t	2025-09-10 16:23:47.406	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
534	NK172315	\N	Giuse	Nguyễn Đăng Minh Khôi	2017-07-08 00:00:00	\N	0901046071	0939384308	294/10 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	11	t	2025-09-10 16:23:47.294	2025-09-19 13:40:42.201	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
541	NK192517	\N	Laurenso	Nguyễn Thái Đăng Khôi	2019-02-27 00:00:00	\N	0386561562	0906796035	23B đường số 1B, BHHA	5	t	2025-09-10 16:23:47.423	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
226	ND172316	\N	Anrê	Nguyễn Quang Duy	2017-05-11 00:00:00	\N	0935479843	0797774247	372 Bình Long, Phú Thọ Hòa, Tân Phú	10	t	2025-09-10 16:23:40.575	2025-09-19 15:36:24.807	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
514	NK122345	\N	Emmanuel	Nguyễn Đăng Khoa	2012-12-18 00:00:00	\N	0335935359	0963965675	9/3 Miếu Bình Đông, BHHA, Bình Tân	29	t	2025-09-10 16:23:46.923	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
521	PK122186	\N	Gioan	Phạm Duy Khoa	2012-04-05 00:00:00	\N	\N	\N	\N	37	t	2025-09-10 16:23:47.067	2025-09-19 13:40:42.369	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
545	PK112162	\N	Gioan Baotixita	Phạm Nguyễn Minh Khôi	2011-06-06 00:00:00	\N	0383309393	\N	245 Trần Thủ Độ, Phú Thạnh, Tân Phú	41	t	2025-09-10 16:23:47.489	2025-09-19 13:40:42.314	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
486	TK182411	\N	\N	Trần Khương Gia Khang	2018-02-03 00:00:00	\N	0703474118	0909595867	Sơ Mân Côi	4	t	2025-09-10 16:23:46.428	2025-09-19 13:40:41.028	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
538	NK112166	\N	Giuse	Nguyễn Minh Khôi	2009-09-13 00:00:00	\N	0908831362	\N	\N	36	t	2025-09-10 16:23:47.366	2025-09-19 13:40:42.199	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
531	LK182559	\N	Gioan Baotixita	Lê Nguyễn Minh Khôi	2018-04-12 00:00:00	\N	0936777717	0907400477	6 Nguyễn Văn Vịnh, Phú Thạnh	4	t	2025-09-10 16:23:47.23	2025-09-19 13:40:42.207	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
520	NK182552	\N	Giuse	Nguyễn Nguyên Khoa	2018-08-26 00:00:00	\N	0948305959	\N	29/9 Đình Tân Khai, BTĐ	4	t	2025-09-10 16:23:47.052	2025-09-19 13:40:42.251	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
533	NK102174	\N	Giuse	Nguyễn Chí Khôi	2010-07-12 00:00:00	\N	0905990898	0935190898	10 ĐS 4, BHHA, Bình Tân	41	t	2025-09-10 16:23:47.271	2025-09-19 13:40:42.251	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
535	NK092182	\N	Đa Minh	Nguyễn Đình Khôi	2009-04-16 00:00:00	\N	0968683611	\N	96 Lê Niệm, Phú Thạnh, Tân Phú	36	t	2025-09-10 16:23:47.314	2025-09-19 13:40:42.26	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
527	TK112194	\N	Emmanuel	Trần Phạm Đăng Khoa	2011-03-11 00:00:00	\N	0986132834	0938659271	375 Trần Thủ Độ, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:23:47.167	2025-09-19 13:40:42.317	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
537	NK122119	\N	Vinh Sơn	Nguyễn Huỳnh Đăng Khôi	2012-04-08 00:00:00	\N	0913775070	0902567809	127/2/20 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	35	t	2025-09-10 16:23:47.349	2025-09-19 13:40:42.371	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
526	TK182439	\N	Tôma	Trần Đăng Khoa	2018-03-14 00:00:00	\N	0937542098	0364061971	242/64 Thoại Ngọc Hầu, PT, Tân Phú	1	t	2025-09-10 16:23:47.154	2025-09-19 13:40:42.56	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
525	TK132334	\N	Gioan	Thái Minh Khoa	2013-07-17 00:00:00	\N	\N	\N	\N	23	t	2025-09-10 16:23:47.137	2025-09-19 13:40:42.74	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
528	HK162462	\N	Giuse	Hà Minh Khôi	2016-02-28 00:00:00	\N	0865636363	0967757283	108 Đường số 4, BHH A, Bình Tân	13	t	2025-09-10 16:23:47.181	2025-09-19 13:40:43.04	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
543	NK092127	\N	Giuse	Nguyễn Trần Minh Khôi	2009-03-21 00:00:00	\N	0983937343	\N	71/44/10 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	50	t	2025-09-10 16:23:47.454	2025-09-19 13:40:43.074	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
546	PK112119	\N	Luy	Phan Anh Khôi	2011-05-23 00:00:00	\N	0918336700	0937585533	165/11 Trần Quang Cơ, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:47.506	2025-09-19 13:40:43.081	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
572	NL112152	\N	Giuse	Nguyễn Hoàng Lâm	2011-11-01 00:00:00	\N	0988938593	0904676269	7C Đường 5B , BHHA, Bình Tân	40	t	2025-09-10 16:23:47.99	2025-09-19 13:40:44.027	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
544	PK142247	\N	Micae	Phạm Minh Khôi	2014-09-02 00:00:00	\N	0973864297	\N	20A Hiền Vương, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:47.472	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
578	VL132345	\N	Giuse	Vũ Đình Lâm	2013-05-21 00:00:00	\N	0972825997	0972825997	44/6 Đường số 4, BHHA, Bình Tân	29	t	2025-09-10 16:23:48.087	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
565	NL142152	\N	Anna	Nguyễn Thị Phương Lan	2014-09-12 00:00:00	\N	0906863568	0987652046	95C ĐS 1, BHHA, Bình Tân	26	t	2025-09-10 16:23:47.873	2025-09-19 13:40:42.849	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
523	PK142151	\N	Giuse	Phạm Nguyễn Nguyên Khoa	2014-01-13 00:00:00	\N	0932786764	0383309393	245 Trần Thủ Độ, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:47.098	2025-09-19 13:40:42.532	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
579	PL092161	\N	Phanxico Assisi	Phạm Nguyễn Gia Liêm	2009-04-10 00:00:00	\N	0907180481	0908180481	34/7 Đường 22, BHHA, Bình Tân	45	t	2025-09-10 16:23:48.11	2025-09-19 13:40:44.026	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
581	DL132188	\N	Maria	Diệp Nhã Linh	\N	\N	\N	\N	\N	32	t	2025-09-10 16:23:48.142	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
577	VL122249	\N	Micae	Võ Hoàng Lâm	2012-07-29 00:00:00	\N	0986055988	0938771389	\N	33	t	2025-09-10 16:23:48.069	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
571	LN172422	\N	Phêrô	Nguyễn Bùi Bảo Lâm	2017-05-22 00:00:00	\N	0977012229	0986531320	76/58 Nguyễn Sơn, Phú Thọ Hoà, Tân Phú	14	t	2025-09-10 16:23:47.97	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1255	NV182425	\N	Maria	Nguyễn Lưu Thanh Vân	2018-01-25 00:00:00	\N	0988134600	\N	24 Đường số 14B, BHHA, Bình Tân	3	t	2025-09-10 16:24:00	2025-09-19 15:36:24.808	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
558	NL182438	\N	Maria	Nguyễn Vũ Quỳnh Lam	2018-02-06 00:00:00	\N	0385395151	0908717130	359/5 Vườn Lài, PTH, Tân Phú	3	t	2025-09-10 16:23:47.745	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
548	TK122159	\N	Phêrô	Trần Bảo Khôi	\N	\N	0913625805	\N	416/4 Thạch Lam, Phú Thạnh	34	t	2025-09-10 16:23:47.546	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
568	BL192523	\N	Vinh Sơn	Bùi Hoàng Phúc Lâm	2019-03-09 00:00:00	\N	0948466606	0909600889	\N	6	t	2025-09-10 16:23:47.925	2025-09-19 13:40:44.032	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
576	TL192551	\N	Anê Thành	Trần Hoàng Khánh Lâm	2019-01-13 00:00:00	\N	0777714499	0387256589	123 Quách Đình Bảo, Phú Thạnh	6	t	2025-09-10 16:23:48.058	2025-09-19 13:40:44.867	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
35	PA122159	\N	Maria	Phạm Thị Thiên An	2012-01-01 00:00:00	\N	\N	\N	\N	21	t	2025-09-10 16:23:37.943	2025-09-19 13:40:25.216	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
532	NK162373	\N	Giuse	Nguyễn Anh Khôi	2016-01-09 00:00:00	\N	0989789742	\N	85 Đường số 5, BHHA, Bình Tân	16	t	2025-09-10 16:23:47.253	2025-09-19 13:40:42.526	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
569	DL172495	\N	Philipphe	Đỗ Phúc Lâm	2017-01-05 00:00:00	\N	0902451484	\N	142/06 Thoại Ngọc Hầu, PT, TP	12	t	2025-09-10 16:23:47.937	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
515	NK172434	\N	Đaminh	Nguyễn Hoàng Anh Khoa	2017-10-30 00:00:00	\N	0937783975	0949087589	127/4 Đường số 8, BHH A, Bình Tân	10	t	2025-09-10 16:23:46.94	2025-09-19 13:40:42.772	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
554	ĐL122151	\N	Maria Têrêsa	Đinh Ngọc Tường Lam	2012-09-01 00:00:00	\N	0903085220	\N	480/13/5/13 Mã Lò, BHHA, Bình Tân	36	t	2025-09-10 16:23:47.673	2025-09-19 13:40:42.843	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
583	NL122154	\N	Maria	Nguyễn Đoàn Khánh Linh	2012-10-15 00:00:00	\N	0902823603	\N	19/7 Đường 14B, BHHA, Bình Tân	37	t	2025-09-10 16:23:48.175	2025-09-19 13:40:42.885	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
553	NK142135	\N	Phêrô	Nguyễn Điền Khương	2014-04-16 00:00:00	0908999804	0908999804	0908999804	3/11A Văn Cao, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:47.639	2025-09-19 13:40:42.896	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
582	LL192537	\N	Maria	Lê Nguyễn Thái Linh	2019-06-28 00:00:00	\N	0974256885	0934934892	225/15/1/15 Lê Văn Quới, BTĐ	6	t	2025-09-10 16:23:48.161	2025-09-19 13:40:44.032	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
555	NL182497	\N	Maria	Nguyễn Cát Phương Lam	\N	\N	0946727177	0944727177	61 Hoàng Ngọc Phách, Phú Thọ Hoà, Tân Phú	1	t	2025-09-10 16:23:47.694	2025-09-19 13:40:44.884	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
586	NL172566	\N	Maria	Nguyễn Trương Khánh Linh	2017-09-24 00:00:00		0768111132			14	t	2025-09-10 16:23:48.231	2025-09-19 13:40:44.919	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
619	VL152278	\N	Đaminh	Vũ Tấn Lộc	2015-03-03 00:00:00	\N	0778762421	\N	34A Lê Cảnh Tuân, Phú Thọ Hòa, Tân Phú	21	t	2025-09-10 16:23:48.792	2025-09-19 13:40:44.657	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
624	NL192548	\N	Anna	Nguyễn Phương Ly	2019-12-30 00:00:00	\N	0344177991	0336950760	81 Kênh Nước Đen, BHHA	6	t	2025-09-10 16:23:48.868	2025-09-19 13:40:44.599	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
607	NL192517	\N	Tôma	Nguyễn Hữu Long	2019-04-14 00:00:00	\N	0976186145	0979236203	206A Lê Lâm, Phú Thạnh	6	t	2025-09-10 16:23:48.591	2025-09-19 13:40:44.659	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
597	BL122155	\N	Giuse	Bùi Gia Long	2012-01-04 00:00:00	\N	0903737451	0902377059	444A Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	37	t	2025-09-10 16:23:48.421	2025-09-19 13:40:44.604	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
618	PL122346	\N	Đa Minh	Phạm Phát Lộc	2012-12-21 00:00:00	\N	0937525608	\N	264 Lê Sao, Phú Thạnh, Tân Phú	29	t	2025-09-10 16:23:48.768	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
609	PL182445	\N	Giuse	Phạm Nguyên Long	2018-02-26 00:00:00	\N	0974511398	0988084068	84/1/8A Tây Lân, BTĐ A, Bình Tân	3	t	2025-09-10 16:23:48.624	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
622	NL162218	\N	Philipphe	Nguyễn Hữu Lương	2016-03-26 00:00:00	\N	0976186145	\N	822/14 Hương Lộ 2, BTĐA, Bình Tân	15	t	2025-09-10 16:23:48.845	2025-09-19 13:40:44.593	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
606	NL162211	\N	Đaminh	Nguyễn Đình Long	2016-09-28 00:00:00	\N	0912233947	\N	77 Đường số 14, BHHA, Bình Tân	15	t	2025-09-10 16:23:48.571	2025-09-19 13:40:44.701	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
817	NN182449	\N	Têrêsa	Nguyễn Lâm Yến Nhi	2018-07-07 00:00:00	\N	0906344366	0937344366	375 Vườn Lài, Phú Thọ Hoà, Tân Phú	2	t	2025-09-10 16:23:53.213	2025-09-19 15:36:24.808	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
562	VL132120	\N	Maria	Vũ Lê Hoàng Lam	2013-09-11 00:00:00	\N	0938285489	0907797873	76 ĐS 22, BHHA, Bình Tân	30	t	2025-09-10 16:23:47.815	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
589	PL132178	\N	Maria	Phan Nguyễn Khánh Linh	2013-06-12 00:00:00	\N	0906033338	91317003	447 Vườn Lài, Phú Thọ Hòa, Tân Phú	34	t	2025-09-10 16:23:48.278	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
596	PL112359	\N	Maria	Phạm Thị Bích Loan	2011-12-02 00:00:00	\N	0961863500	\N	479/6/6 Hương Lộ 2, BTĐ, Bình Tân	35	t	2025-09-10 16:23:48.403	2025-09-19 13:40:44.231	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
550	NK112190	\N	Giuse	Nguyễn Văn Khởi	2011-09-18 00:00:00	\N	0987750965	0384116878	/38/3 Hoàng Ngọc Phách, Phú Thọ Hòa, Tân Phú	42	t	2025-09-10 16:23:47.579	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
617	NL122195	\N	Antôn	Nguyễn Văn Lộc	2012-06-01 00:00:00	\N	0346643980	0392090392	257/3 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú 	42	t	2025-09-10 16:23:48.749	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
556	NL142131	\N	Maria	Nguyễn Hoàng Quỳnh Lam	2014-05-21 00:00:00	\N	0905395599	\N	128/3/14 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	26	t	2025-09-10 16:23:47.71	2025-09-19 13:40:44.346	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
587	NL142154	\N	Têrêsa	Nguyễn Vũ Thảo Linh	2014-05-27 00:00:00	\N	0902908448	0909077187	76/57/3 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	26	t	2025-09-10 16:23:48.246	2025-09-19 13:40:44.576	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
603	LL102124	\N	Giuse	Lý Hoàng Long	2010-12-21 00:00:00	\N	0902302356	0907731339	427 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú	41	t	2025-09-10 16:23:48.526	2025-09-19 13:40:44.385	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
604	NL122187	\N	Giuse	Ngô Bảo Long	2012-11-15 00:00:00	\N	0974953189	0866104689	303 Lê Văn Quới, Bình Tân	38	t	2025-09-10 16:23:48.539	2025-09-19 13:40:44.388	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
620	HL152245	\N	Giuse	Huỳnh Minh Luân	2015-11-13 00:00:00	\N	\N	\N	\N	16	t	2025-09-10 16:23:48.812	2025-09-19 13:40:44.551	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
592	TL162293	\N	Têrêsa	Trịnh Trúc Linh	2016-05-26 00:00:00	\N	0918882364	\N	24/9/8/1D Bến Lội, BTĐA, Bình Tân	15	t	2025-09-10 16:23:48.342	2025-09-19 13:40:44.655	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
629	LM982555	\N	Maria	Lâm Ngọc Mai	1998-09-27 00:00:00	\N	\N	\N	125/1 Đường số 8, BHHA	51	t	2025-09-10 16:23:48.96	2025-09-19 13:40:46.199	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
633	VM082122	\N	Têrêsa	Vũ Nguyễn Ngọc Mai	2008-03-29 00:00:00	\N	0919928448	0985230088	468 Hương Lộ 2, BTĐ, Bình Tân	51	t	2025-09-10 16:23:49.03	2025-09-19 13:40:46.469	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
631	NM142191	\N	Maria	Nguyễn Trúc Mai	2014-12-16 00:00:00	\N	0903144654	\N	110/2/3 ĐS 4, BHHA, Bình Tân	27	t	2025-09-10 16:23:48.993	2025-09-19 13:40:46.394	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
593	VL132216	\N	Têrêsa	Vũ Khánh Linh	2013-02-10 00:00:00	\N	0908500171	\N	16 Đường số 1B, BHHA, Bình Tân	25	t	2025-09-10 16:23:48.355	2025-09-19 13:40:45.863	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
640	HM142154	\N	Giuse	Hoàng Nhật Minh	\N	\N	\N	\N	\N	28	t	2025-09-10 16:23:49.142	2025-09-19 15:36:24.81	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
874	NP192572	\N	Phêrô	Nguyễn Tấn Phát	2019-05-01 00:00:00	\N	0789821821	0909909056	242/64 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	5	t	2025-09-10 16:23:54.141	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
656	PM082248	\N	Tôma	Phạm Hoàng Quang Minh	2008-09-18 00:00:00	\N	0938797008	0937362767	276 Bình Long, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:49.408	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
643	LM142187	\N	Gioan Baotixita	Lê Hoàng Minh	2014-04-27 00:00:00	\N	0908255909	0988293719	150 Đỗ Bí, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:49.187	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
649	NM152558	\N	Gioakim	Nguyễn Thái Gia Minh	2015-08-09 00:00:00	\N	0908447109	0918105013	205/36 Bình Trị Đông	19	t	2025-09-10 16:23:49.281	2025-09-19 13:40:46.237	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
659	PM152111	\N	Vinh Sơn Phaolo	Phạm Tuấn Minh	2015-09-29 00:00:00	\N	0976071310	\N	53 Nguyễn Sơn CC Phú Thạnh, Phú Thạnh, Tân Phú	24	t	2025-09-10 16:23:49.461	2025-09-19 15:36:24.81	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
625	PL092576	\N	Maria	Phạm Thảo Ly	2009-08-14 00:00:00	\N	0982922338	0348689819	303 Vườn Lài, Phú Thọ Hoà	34	t	2025-09-10 16:23:48.882	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
9	ĐA142351	\N	Maria	Đinh Ngọc An	2014-10-27 00:00:00	\N	\N	\N	\N	20	t	2025-09-10 16:23:37.568	2025-09-19 13:40:25.553	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
634	VM182375	\N	Phaolô	Vũ Duy Mạnh	2018-11-24 00:00:00	\N	0903716023	0908210701	16/5 Nguyễn Nhữ Lãm, Phú Thọ Hòa, Tân Phú	2	t	2025-09-10 16:23:49.046	2025-09-19 13:40:46.218	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
642	LM112247	\N	Giuse	Lê Hoàng Minh	2011-08-10 00:00:00	\N	0908722502	\N	77 Đường số 8, BHHA, Bình Tân	24	t	2025-09-10 16:23:49.172	2025-09-19 13:40:45.863	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1179	VT112161	\N	Maria	Vũ Ngọc Anh Thư	2011-04-11 00:00:00	\N	0943500700	0856500700	904/5B Hương Lộ 2, BTĐA, Bình Tân	42	t	2025-09-10 16:23:58.979	2025-09-19 15:36:24.81	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
630	NM112132	\N	Rosa	Nguyễn Thái Xuân Mai	2011-11-28 00:00:00	\N	0386561562	0906796035	23B Đường 1B, BHHA, Bình Tân	41	t	2025-09-10 16:23:48.974	2025-09-19 13:40:46.716	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
648	NM152482	\N	GioaKim	Nguyễn Thái Gia Minh	\N	\N	0902007339	\N	205/36 BTĐ A, BT	13	t	2025-09-10 16:23:49.267	2025-09-19 13:40:46.016	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
657	PM172547	\N	Martino	Phạm Khải Minh	2017-12-08 00:00:00	\N	0937714045	\N	31/39A Trương Phước Phan, BTĐ	14	t	2025-09-10 16:23:49.427	2025-09-19 13:40:46.027	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
663	TM172315	\N	Phêrô	Trần Gia Bảo Minh	2017-06-28 00:00:00	\N	0981236633	\N	\N	11	t	2025-09-10 16:23:49.517	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
660	PM102147	\N	Antôn	Phan Đặng Chính Minh	2010-06-26 00:00:00	\N	0384759592	\N	11 ĐS 3, BHHA, Bình Tân	40	t	2025-09-10 16:23:49.474	2025-09-19 13:40:46.234	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
654	NM162428	\N	Têrêsa	Nguyễn Ý Minh	2016-03-14 00:00:00	\N	0908673914	\N	12/4/7 Nguyễn Sơn, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:23:49.368	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
646	NM152493	\N	Giuse	Nguyễn Hữu Nhật Minh	\N	\N	0932725248	0933909802	44 Đường số 1,  BHHA, BT	18	t	2025-09-10 16:23:49.235	2025-09-19 13:40:46.026	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
637	CM092137	\N	Gioan	Cao Chấn Minh	2009-07-21 00:00:00	\N	0914254808	0909595247	130/14 A Ni Sư Huỳnh Liên	45	t	2025-09-10 16:23:49.096	2025-09-19 13:40:46.576	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
641	HM122149	\N	Gioan Baotixita	Hồ Hiểu Minh	2012-06-18 00:00:00	\N	0365563796	\N	201 Thạch Lam, Phú Thạnh,Tân Phú	35	t	2025-09-10 16:23:49.155	2025-09-19 13:40:46.627	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
651	NM122123	\N	Giuse	Nguyễn Trương Quốc Minh	2012-12-22 00:00:00	\N	0707706537	\N	558/10 Bình Long	36	t	2025-09-10 16:23:49.324	2025-09-19 13:40:46.635	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
627	PL182419	\N	Anna	Phan Vũ Khánh Ly	2018-02-01 00:00:00	\N	0778648805	\N	358/5 Bình Long, Phú Thọ Hoà, Tân Phú	1	t	2025-09-10 16:23:48.932	2025-09-19 13:40:46.69	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
628	DM182425	\N	Maria	Đặng Ánh Mai	\N	\N	0896474313	\N	48/47 Phạm Văn Xảo, PTH, TP	1	t	2025-09-10 16:23:48.947	2025-09-19 13:40:46.77	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
689	TM172536	\N	Rosa	Trần Phạm Trà My	2017-07-11 00:00:00	\N	0967526403	0986225253	263/3 Thạch Lam,Phú Thạnh	13	t	2025-09-10 16:23:49.956	2025-09-19 13:40:48.415	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
672	HM122118	\N	Maria	Hồ Ngọc Trà My	2012-01-24 00:00:00	\N	0987685967	0903942763	132/12 ĐS 8, BHHA, Bình Tân 	38	t	2025-09-10 16:23:49.656	2025-09-19 13:40:48.453	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	1
694	NM112431	\N	Maria	Nguyễn Thị Xuân Mỹ	2011-10-04 00:00:00	\N	0915164144	0918095314	74/8 Đường số 14, BHHA, Bình Tân	19	t	2025-09-10 16:23:50.045	2025-09-21 09:18:41.024	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
666	VM132131	\N	Đa Minh	Vũ Đình Gia Minh	2013-01-04 00:00:00	\N	0988866035	0946679090	19 Gò Xoài, BHHA, Bình Tân	32	t	2025-09-10 16:23:49.566	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
665	TM172460	\N	Phaolo	Trần Phan Quang Minh	2017-02-27 00:00:00	\N	\N	0917737730	234A Đường số 8, BHH A, Bình Tân	14	t	2025-09-10 16:23:49.552	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
706	VN192547	\N	Giuse	Võ Hiếu Nam	2019-01-03 00:00:00	\N	0903170287	0968772349	363/11/16 Bình Trị Đông, BTĐ	5	t	2025-09-10 16:23:50.259	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
693	NM142343	\N	Maria	Nguyễn Thanh Du Mỹ	2014-12-25 00:00:00	\N	\N	\N	\N	22	t	2025-09-10 16:23:50.025	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
679	NM132130	\N	Maria	Nguyễn Khánh My	2013-05-06 00:00:00	\N	0909545952	0908545952	175 Lê Lâm, Phú Thạnh, Tân Phú	30	t	2025-09-10 16:23:49.767	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
682	NM122113	\N	Maria	Nguyễn Ngọc Trà My	2012-11-10 00:00:00	\N	0937774350	0907433589	19/2 Đường số 13A, BHHA, Bình Tân	33	t	2025-09-10 16:23:49.821	2025-09-19 15:36:24.879	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
695	ĐN142113	\N	Gioakim	Đỗ Bảo Nam	2014-09-13 00:00:00	\N	0906141478	\N	55/13/2M đường số 18B, BHHA, Bình Tân	25	t	2025-09-10 16:23:50.061	2025-09-19 13:40:48.468	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
670	DM192529	\N	Têrêsa	Đoàn Nguyễn Thảo My	2019-04-04 00:00:00	\N	0353128478	0394600442	266/9 Phú Thọ Hoà, Phú Thọ Hoà	6	t	2025-09-10 16:23:49.631	2025-09-19 13:40:48.222	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
690	TM152128	\N	Maria	Trần Thị Hà My	2015-09-05 00:00:00	\N	0981684151	\N	323 Nguyễn Sơn, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:49.973	2025-09-19 13:40:48.583	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
700	NN142338	\N	Phaolô	Nguyễn Phước An Nam	2014-10-29 00:00:00	\N	0786612242	0933254303	138 Trần Thủ Độ, Phú Thạnh, Tân Phú	13	t	2025-09-10 16:23:50.16	2025-09-19 13:40:47.728	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
275	ND182414	\N	Têrêsa	Nguyễn Ngọc Tâm Đoan	2018-07-30 00:00:00	\N	0908286883	\N	88 Lê Lư, Phú Thọ Hoà, Tân Phú	3	t	2025-09-10 16:23:41.49	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
703	PN112519	\N	Giuse	Phạm Bảo Nam	2011-08-08 00:00:00	\N	0796446355	\N	38/5 đường số 1A, BHHA	33	t	2025-09-10 16:23:50.213	2025-09-19 13:40:47.731	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
707	VN122163	\N	Giuse	Vũ Hoàng Nam	2012-03-05 00:00:00	\N	0937737318	\N	54C Phạm Vấn, Phú Thọ Hòa	36	t	2025-09-10 16:23:50.283	2025-09-19 13:40:47.845	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
680	NM112188	\N	Têrêsa	Nguyễn Lâm Yến My	2011-05-04 00:00:00	\N	0909510452	0937344366	375 Vườn Lài, Phú Thọ Hòa, Tân Phú	41	t	2025-09-10 16:23:49.782	2025-09-19 13:40:47.874	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
678	NM162277	\N	Maria	Nguyễn Giáng My	2016-07-17 00:00:00	\N	0792167167	\N	25L Miếu Bình Đông, BHHA, Bình Tân	15	t	2025-09-10 16:23:49.75	2025-09-19 13:40:48.073	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
692	VM172478	\N	Maria	Vũ Thị Khởi My	2017-11-27 00:00:00	\N	0903374296	0988664442	38 Đường 5F, BHH A, BT	12	t	2025-09-10 16:23:50.007	2025-09-21 03:31:18.085	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
698	NN152118	\N	Giuse	Nguyễn Hoàng Nam	2015-10-26 00:00:00	\N	0784388987	\N	135/8 Trần Quang Cơ, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:50.121	2025-09-19 13:40:47.848	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
702	PN132485	\N	Giuse	Phạm Bảo Nam	2013-12-03 00:00:00	\N	0909872905	0976610717	33 Thoại Ngọc Hầu, Hoà Thạnh, Tân Phú	18	t	2025-09-10 16:23:50.197	2025-09-19 13:40:47.781	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
701	NN092197	\N	Giuse	Nguyễn Vũ Nhật Nam	2009-12-05 00:00:00	\N	0385395151	0908717130	70 Đàm Thận Huy, Tân Quý, Tân Phú	50	t	2025-09-10 16:23:50.178	2025-09-19 13:40:48.504	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
681	NM122163	\N	Maria	Nguyễn Ngọc Trà My	2012-11-08 00:00:00	\N	0909922064	0906922064	257 Phú Thọ Hoà, Phú Thọ Hoà, Tân Phú	37	t	2025-09-10 16:23:49.803	2025-09-19 13:40:48.557	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
687	PM072191	\N	Maria	Phạm Ngọc Diễm My	2007-10-04 00:00:00	\N	0902489979	0961216534	33 Đường 16A, BHHA, Bình Tân	50	t	2025-09-10 16:23:49.916	2025-09-19 13:40:48.605	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
727	CN152518	\N	Cecilia	Công Võ Phương Nghi	2015-05-09 00:00:00	\N	0906303387	0902449519	48/52 Phạm Văn Xảo, Phú Thọ Hoà	13	t	2025-09-10 16:23:50.595	2025-09-19 13:40:48.315	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
735	NN132173	\N	Giuse	Nguyễn Trung Nghĩa	\N	\N	\N	\N	\N	30	t	2025-09-10 16:23:50.726	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
711	DN192512	\N	Maria	Đinh Bảo Ngân	2019-01-02 00:00:00	\N	0909993202	0907797263	60/69 Trương Phước Phan, BTĐ, Bình Tân 	6	t	2025-09-10 16:23:50.346	2025-09-19 13:40:48.297	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
1044	BT132258	\N	Têrêsa	Bùi Tinh Tú	2013-08-19 00:00:00	\N	0865139913	\N	212 Lê Cao Lãng, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:57.108	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
754	NN102466	\N	Maria	Nguyễn Triệu Bảo Ngọc	2010-11-20 00:00:00	\N	\N	\N	45 Đường số 8, BHHA, Bình Tân	24	t	2025-09-10 16:23:51.121	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
752	NN132181	\N	Maria	Nguyễn Lê Mỹ Ngọc	2013-11-17 00:00:00	\N	0912581375	\N	191 ĐS 8, BHHA, Bình Tân	33	t	2025-09-10 16:23:51.072	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
720	NN192521	\N	Têrêsa	Nguyễn Vũ Khánh Ngân	2019-02-18 00:00:00	\N	0909077187	0902908448	76/57/3 Nguyễn Sơn, Phú Thọ Hoà	6	t	2025-09-10 16:23:50.484	2025-09-19 13:40:50.01	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
758	TN092140	\N	Anna	Trần Kim Ngọc	2009-01-03 00:00:00	\N	0909317657	0898493301	24/9/3 MiếU Gò XoàI, BHHA, BìNh Tân	51	t	2025-09-10 16:23:51.229	2025-09-19 13:40:49.763	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
736	NN132245	\N	Giuse	Nguyễn Vũ Hoàng Nghĩa	2013-12-20 00:00:00	\N	0978966898	\N	36 Đường số 1A, BHHA, Bình Tân	27	t	2025-09-10 16:23:50.742	2025-09-19 13:40:49.698	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
719	NN132282	\N	Matta	Nguyễn Thị Kim Ngân	2013-12-23 00:00:00	\N	0909928977	\N	62/2 Đường số 13A, BHHA, Bình Tân	25	t	2025-09-10 16:23:50.467	2025-09-19 13:40:48.553	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
716	NN162212	\N	Maria	Nguyễn Gia Ngân	2016-12-08 00:00:00	\N	0937838244	0938688446	26 Đường số 1B, BHHA, Bình Tân	19	t	2025-09-10 16:23:50.421	2025-09-19 13:40:48.401	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
722	TN102128	\N	Rosa	Trịnh Hoàng Thùy Ngân	2010-12-22 00:00:00	\N	0908385327	0909155935	E0811 CC Phú Thạnh, Tân Phú	45	t	2025-09-10 16:23:50.516	2025-09-19 13:40:48.244	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
738	LN162364	\N	Têrêsa	Lê Bảo Ngọc	2016-05-20 00:00:00	\N	0933903519	0938324303	372 Bình Long, Phú Thọ Hòa, Tân Phú	19	t	2025-09-10 16:23:50.778	2025-09-19 13:40:48.4	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
718	NN152117	\N	Têrêsa	Nguyễn Ngọc Kim Ngân	2015-02-17 00:00:00	\N	0908131809	\N	127 Quách Đình Bảo, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:23:50.455	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
741	LN152344	\N	Maria	Lê Nguyễn Lan Ngọc	2015-06-20 00:00:00	\N	0903677717	0907400477	6/3 Nguyễn Văn Vịnh, Hiệp Tân, Tân Phú	23	t	2025-09-10 16:23:50.837	2025-09-19 13:40:48.31	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
726	VN162366	\N	Maria	Vũ Ngọc Thùy Ngân	2016-07-09 00:00:00	\N	0938104189	0938370348	141/18 Đường số 8, BHHA, Bình Tân	17	t	2025-09-10 16:23:50.582	2025-09-21 08:23:12.47	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
759	TN112186	\N	Maria	Trần Lê Bảo Ngọc	2011-01-11 00:00:00	\N	\N	\N	25/52 Văn Cao, Phú Thạnh, Tân Phú	42	t	2025-09-10 16:23:51.256	2025-09-19 13:40:49.951	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	2	0
744	MN092181	\N	Maria	Mai Thị Thảo Ngọc	2009-12-18 00:00:00	\N	0908752574	0974490305	165B Lê Văn Quới, BTĐ, Bình Tân	45	t	2025-09-10 16:23:50.892	2025-09-19 13:40:49.597	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
712	ĐN142164	\N	Têrêsa	Đỗ Khánh Ngân	2014-01-01 00:00:00	\N	0908422019	0909354653	264/4 Lê Văn Quới, BHHA	28	t	2025-09-10 16:23:50.357	2025-09-19 13:40:49.644	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
757	TN082188	\N	Têrêsa	Trần Đức Bảo Ngọc	2008-09-24 00:00:00	\N	0914114266	\N	127/2/53 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	50	t	2025-09-10 16:23:51.19	2025-09-19 13:40:49.654	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
747	NN102231	\N	Phêrô	Nguyễn Đức Ngọc	2010-07-02 00:00:00	\N	\N	\N	\N	37	t	2025-09-10 16:23:50.954	2025-09-19 13:40:49.707	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
749	NN082169	\N	Maria	Nguyễn Khánh Ngọc	2008-02-09 00:00:00	\N	0933144399	0908958962	37/20 ĐS 8B, BHHA, Bình Tân	45	t	2025-09-10 16:23:51.014	2025-09-19 13:40:49.749	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
760	TN122192	\N	Maria	Trần Nguyễn Kim Ngọc	2012-11-18 00:00:00	\N	0917427317	0776723228	65 ĐS 13, BHHA, Bình Tân	35	t	2025-09-10 16:23:51.286	2025-09-19 13:40:50.161	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
769	BN132169	\N	Giuse	Bùi Võ Khôi Nguyên	2013-12-02 00:00:00	\N	0977440933	0967440933	362 BTĐ, BTĐ, Bình Tân	33	t	2025-09-10 16:23:51.475	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
697	LN162271	\N	Đaminh	Lê Hoàng Nam	2016-04-25 00:00:00	\N	0938925736	0383908499	230/28/6 Mã Lò, BTĐA, Bình Tân	16	t	2025-09-10 16:23:50.092	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
783	NN162214	\N	Têrêsa	Nguyễn Nhật Thảo Nguyên	2016-09-20 00:00:00	\N	0378885142	\N	132/10/5 Đường số 8, BHHA, Bình Tân	16	t	2025-09-10 16:23:52.087	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
805	NN142149	\N	Antôn	Nguyễn Tuấn Nhật	\N	\N	\N	\N	\N	24	t	2025-09-10 16:23:53.029	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
766	VN082126	\N	Anna	Vũ Nguyễn Bảo Ngọc	2008-10-14 00:00:00	\N	0938034907	0902964665	100/19 Đường 18B,  BHHA, Bình Tân	51	t	2025-09-10 16:23:51.43	2025-09-19 13:40:49.963	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
742	LN132276	\N	Maria	Lê Thị Bảo Ngọc	2013-12-23 00:00:00	0346264789	0346264789	0346264789	21/28 Vườn Lài, Phú Thọ Hòa, Tân Phú	27	t	2025-09-10 16:23:50.859	2025-09-19 13:40:49.713	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
748	NN122273	\N	Maria	Nguyễn Gia Bích Ngọc	2012-09-22 00:00:00	\N	0979895474	0965831127	107/23 Đường số 14, BHHA, Bình Tân	26	t	2025-09-10 16:23:50.996	2025-09-19 13:40:50.29	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
794	NN132147	\N	Antôn	Nguyễn Đoàn Trọng Nhân	\N	\N	\N	\N	\N	32	t	2025-09-10 16:23:52.845	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
745	NN182408	\N	Teresa	Ngô Bảo Ngọc	\N	\N	0939211830	\N	58/12/74 đường số 8B, BHHA, BT	3	t	2025-09-10 16:23:50.915	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
750	NN162452	\N	Giuse	Nguyễn Khương Ngọc	2016-02-24 00:00:00	\N	0937147443	0933654240	334 Thạch Lam, PT, Tân Phú	17	t	2025-09-10 16:23:51.038	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
775	NN172316	\N	Têrêsa	Nguyễn Diệp Thảo Nguyên	2017-05-16 00:00:00	\N	\N	\N	5 Đường số 5A, BHHA, Bình Tân	13	t	2025-09-10 16:23:51.592	2025-09-19 13:40:50.375	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1184	NT162285	\N	Têrêsa	Nguyễn An Thy	2016-10-02 00:00:00	\N	0909549601	\N	69/13A Kênh Nước Đen, BHHA, Bình Tân	16	t	2025-09-10 16:23:59.053	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
802	NN182547	\N	Giuse	Nguyễn Minh Nhật	2018-10-30 00:00:00	\N	0986839460	0384827967	413/56/19/39 Lê Văn Quới, BTĐA	4	t	2025-09-10 16:23:52.975	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
753	NN162295	\N	Anna	Nguyễn Như Bảo Ngọc	2016-01-22 00:00:00	\N	0903198664	\N	37/8/2C Đường số 6, BHHA, Bình Tân	15	t	2025-09-10 16:23:51.087	2025-09-19 13:40:50.261	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
763	VN152238	\N	Maria	Vũ Bảo Ngọc	2015-08-16 00:00:00	\N	0908500171	\N	16 Đường số 1B, BHHA, Bình Tân	20	t	2025-09-10 16:23:51.371	2025-09-19 13:40:49.748	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
765	VN122129	\N	Maria	Vũ Kim Ngọc	2012-10-27 00:00:00	\N	0903148260	0906967412	117/10 Lê Lư, Phú Thọ Hòa, Tân Phú	37	t	2025-09-10 16:23:51.403	2025-09-19 13:40:49.767	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
751	NN112249	\N	Maria	Nguyễn Lê Bảo Ngọc	2011-10-09 00:00:00	\N	0907254757	\N	149 Lê Cao Lãng, Phú Thạnh, Tân Phú	40	t	2025-09-10 16:23:51.054	2025-09-19 13:40:49.927	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
746	NN152375	\N	Maria	Nguyễn Bảo Ngọc	2015-11-21 00:00:00	\N	0961024413	0898470326	74/2 Liên Khu 2-5, BTĐ, Bình Tân	18	t	2025-09-10 16:23:50.934	2025-09-19 13:40:50.139	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
770	HN172414	\N	Giuse	Huỳnh Khôi Nguyên	\N	\N	0938147184	\N	186/24 Nguyễn Sơn, Phú Thọ Hòa, TP	12	t	2025-09-10 16:23:51.49	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
788	VN102149	\N	Phêrô	Vũ Hoàng Nguyên	2010-10-22 00:00:00	\N	0937737318	\N	54C Phạm Vấn, Phú Thọ Hoà, Tân Phú	36	t	2025-09-10 16:23:52.458	2025-09-19 13:40:50.203	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
803	NN172368	\N	Giuse	Nguyễn Minh Nhật	2017-08-04 00:00:00	\N	0906752430	0973024713	59/29 Nguyễn Sơn, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:52.994	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
773	LN122177	\N	Giuse	Linh Ngọc Khôi Nguyên	2011-05-19 00:00:00	\N	\N	\N	\N	36	t	2025-09-10 16:23:51.56	2025-09-19 13:40:50.27	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
776	NN102156	\N	Gioan Maria Vianney	Nguyễn Đức Khôi Nguyên	2010-06-07 00:00:00	\N	\N	\N	\N	41	t	2025-09-10 16:23:51.671	2025-09-19 13:40:50.672	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
792	KN142253	\N	Maria	Ký Trương Thy Nhã	2014-08-12 00:00:00	\N	0908654329	\N	33/10/19 Trần Quang Cơ, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:52.803	2025-09-19 13:40:51.851	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
784	NN122374	\N	Giuse	Nguyễn Phúc Nguyên	2012-11-18 00:00:00	\N	0899320232	0902307893	25/23 Văn Cao, Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:52.103	2025-09-19 13:40:52.406	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
837	LN172348	\N	Maria	Lý Nguyễn An Nhiên	2017-05-29 00:00:00	\N	0938720783		213B Hiền Vương, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:53.535	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
812	LN122159	\N	Maria	Lương Ngọc Uyên Nhi	2012-06-07 00:00:00	\N	0909194457	0969817229	1 Văn Cao, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:53.144	2025-09-19 13:40:52.431	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
855	TN092110	\N	Maria	Trương Ngọc Quỳnh Như	2009-12-22 00:00:00	\N	0904740799	0905235215	2/2/104 Lê Thúc Hoạch, Phú Thọ Hoà, Tân Phú	42	t	2025-09-10 16:23:53.831	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
808	ĐN122114	\N	Maria	Đinh Thảo Nhi	2012-02-24 00:00:00	\N	0935468187	\N	125 Lê Lâm, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:53.068	2025-09-19 13:40:52.059	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
824	TN162341	\N	Maria	Thái Ngọc Tâm Nhi	2016-08-18 00:00:00	\N	0906294054	0911124670	201 Đường số 1, BHHA, Bình Tân	17	t	2025-09-10 16:23:53.316	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
815	NN142328	\N	Maria	Nguyễn Hoàng Yến Nhi	2014-05-10 00:00:00	\N	0908977010	\N	479/9/7 Hương Lộ 2, BTĐ, Bình Tân	22	t	2025-09-10 16:23:53.182	2025-09-19 13:40:51.785	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
814	MN122128	\N	Maria	Mai Quỳnh Nhi	2012-06-26 00:00:00	\N	0934184988	\N	62 Lê Lâm, Phú Thạnh, Tân Phú	36	t	2025-09-10 16:23:53.169	2025-09-19 13:40:51.791	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
823	PN092119	\N	Anna	Phạm Thị Yến Nhi	2009-05-01 00:00:00	\N	0902852263	\N	31/3 Đường 3B, BHHA, Bình Tân	50	t	2025-09-10 16:23:53.291	2025-09-19 13:40:51.867	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
807	DN142174	\N	Maria	Dương Quỳnh Bảo Nhi	2014-04-01 00:00:00	\N	0933399050	\N	1/27 Đường 5A, BHHA, Bình Tân	25	t	2025-09-10 16:23:53.055	2025-09-19 13:40:51.947	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
829	TN092275	\N	Maria	Trần Thị Yến Nhi	2009-06-24 00:00:00	\N	0972972780	\N	386A Lê Văn Quới, BHHA, Tân Phú	35	t	2025-09-10 16:23:53.391	2025-09-19 13:40:51.999	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
849	NN132275	\N	\N	Nguyễn Quỳnh Như	2013-11-01 00:00:00	\N	0934666203	\N	172A Thạch Lam, Phú Thạnh, Tân Phú	25	t	2025-09-10 16:23:53.729	2025-09-19 13:40:52.126	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
846	DN132133	\N	Têrêsa	Dương Hoàng An Như	2013-03-31 00:00:00	\N	0772666975	0902686891	239C Quách Đình Bảo, Phú Thạnh, Tân Phú	32	t	2025-09-10 16:23:53.678	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
877	TP162395	\N	Giuse	Trần Đức Phát	2016-05-04 00:00:00	\N	0933999639	0338822833	225 Hiền Vương, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:23:54.19	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
887	HP192534	\N	Phanxico Xavie	Hoàng Nam Phong	2019-06-01 00:00:00	\N	0915246733	0986833856	95A Trần Thủ Độ, Phú Thạnh	6	t	2025-09-10 16:23:54.359	2025-09-19 13:40:53.437	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
892	NP142351	\N	Gioan Baotixita	Nguyễn Tuấn Phong	2014-08-15 00:00:00	\N	0367180909	0933001277	111/77 Đường số 1, BHHA, Bình Tân	29	t	2025-09-10 16:23:54.44	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
872	NP142125	\N	Giuse	Nguyễn Khắc Tiến Phát	2014-04-24 00:00:00	\N	0909183246	\N	218/12A Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	26	t	2025-09-10 16:23:54.107	2025-09-19 13:40:53.39	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
243	LĐ152217	\N	Monica	Lê Trần Thảo Đan	2015-07-07 00:00:00	\N	\N	\N	Sơ Mân Côi	24	t	2025-09-10 16:23:40.848	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
893	NP182467	\N	Vincente	Nguyễn Thanh Phong	2018-02-03 00:00:00	\N	0938312876	0384870110	45 Văn Cao, Phú Thạnh, Tân Phú	3	t	2025-09-10 16:23:54.452	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
867	LP132190	\N	Giuse	Lê Võ Tấn Phát	2013-10-30 00:00:00	\N	0903131812	0935287499	438/30 Tân Kỳ Tân Quý, Sơn Kỳ, Tân Phú	32	t	2025-09-10 16:23:54.012	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
880	VP182416	\N	Phêrô	Vũ Quốc Phát	2018-10-10 00:00:00	\N	0918232468	0961759069	6F Lê Quốc Trinh, Phú Thọ Hoà, Tân Phú	2	t	2025-09-10 16:23:54.246	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
827	TN142159	\N	Maria	Trần Lê Gia Nhi	2014-04-21 00:00:00	\N	0988887025	0985983377	25/52 Văn Cao, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:53.357	2025-09-19 13:40:53.485	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
840	NN152284	\N	Têrêsa	Nguyễn Ngọc An Nhiên	2015-05-24 00:00:00	\N	0918699559	\N	16/1 Trần Quang Cơ, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:23:53.575	2025-09-21 03:31:18.083	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
838	NN172473	\N	Maria	Nguyễn An Nhiên	2017-12-18 00:00:00	\N	0914330567	0966006186	343 Trần Thủ Độ, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:53.548	2025-09-19 13:40:53.379	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
833	AN152214	\N	Gioan Phaolo II	An Diệp Hạo Nhiên	2015-11-27 00:00:00	\N	0988868204	\N	15 Lê Lâm, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:53.463	2025-09-19 13:40:53.381	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
888	HP152537	\N	Giuse	Huỳnh Thanh Phong	2015-08-25 00:00:00	\N	0902157167	0908558623	42/24/7/16 Đường số 5, BHHA	23	t	2025-09-10 16:23:54.373	2025-09-19 13:40:53.384	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
866	LP142386	\N	Giuse	Lê Sỹ Gia Phát	2014-08-24 00:00:00	\N	0909732838	0978233878	222 Bình Long, Phú Thạnh, Tân Phú	23	t	2025-09-10 16:23:53.992	2025-09-19 13:40:53.794	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
870	NP082161	\N	Giuse 	Nguyễn Đức Phát	2008-06-19 00:00:00	\N	\N	0908650796	280 ĐS 8, BHH, Bình Tân	50	t	2025-09-10 16:23:54.077	2025-09-19 13:40:53.811	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
871	NP152355	\N	Giuse	Nguyễn Hưng Phát	2015-10-31 00:00:00	\N	0933345112	0934454928	38B Đường số 13A, BHHA, Bình Tân	23	t	2025-09-10 16:23:54.092	2025-09-19 13:40:53.86	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
881	VP062415	\N	Giuse	Vũ Tiến Phát	2006-05-09 00:00:00	\N	\N	\N	\N	51	t	2025-09-10 16:23:54.262	2025-09-19 13:40:54.264	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
883	DP152577	\N	Phaolô	Đặng Nguyễn Tiến Phong	2015-12-05 00:00:00	\N	0909839392	0909839594	113/11A đường 14, BHHA	18	t	2025-09-10 16:23:54.294	2025-09-19 13:40:54.268	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
882	DP192537	\N	Vinh Sơn	Đào Đình Phong	2019-11-19 00:00:00	\N	0976102966	0981394087	250 Lê Niệm, Phú Thạnh	5	t	2025-09-10 16:23:54.275	2025-09-19 13:40:54.279	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
919	HP152284	\N	Gioan	Huỳnh Vĩnh Phúc	2015-04-04 00:00:00	\N	0902936903	\N	5 Đường số 5A, BHHA, Bình Tân	12	t	2025-09-10 16:23:54.866	2025-09-21 03:31:18.084	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
931	NP102264	\N	Phêrô	Nguyễn Trọng Phúc	2010-10-23 00:00:00	\N	0935087639	0936773135	520 Hương Lộ 2, BTĐ, Bình Tân	34	t	2025-09-10 16:23:55.051	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
914	HP192537	\N	Micae	Hoàng Hồng Phúc	2019-01-14 00:00:00	\N	0933864032	0936665840	102/52 Bình Long, Phú Thạnh	6	t	2025-09-10 16:23:54.782	2025-09-19 13:40:56.048	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
864	LP132372	\N	Giuse	Lê Gia Phát	2013-07-14 00:00:00	\N	0908606086	\N	15A Lê Lư, Phú Thọ Hòa, Tân Phú	29	t	2025-09-10 16:23:53.961	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
910	VP122156	\N	Đa Minh	Vũ Nguyễn Gia Phú	2012-07-19 00:00:00	\N	0345126162	0985632623	223 Lê Sao, Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:54.729	2025-09-19 13:40:55.518	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
510	LK112145	\N	Giuse	Lương Đăng Khoa	2011-09-28 00:00:00	\N	0989674930	0909361776	107/8A ĐS 14, BHHA, Bình Tân 	42	t	2025-09-10 16:23:46.851	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
927	NP152237	\N	Giuse	Nguyễn Hoài Phúc	2015-12-16 00:00:00	\N	0908575282	\N	40A Lê Cao Lãng, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:54.986	2025-09-19 13:40:55.993	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
916	HP182433	\N	Giuse	Hồ Nguyễn Gia Phúc	2018-05-11 00:00:00	\N	0907281980	0906039380	101 Đường số 22, BHHA, Bình Tân	2	t	2025-09-10 16:23:54.822	2025-09-19 13:40:54.067	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
924	LP182447	\N	Giuse	Lương Hoàng Phúc	2018-04-06 00:00:00	\N	\N	\N	60/75 Trương Phước Phan, BTĐ, Bình Tân	1	t	2025-09-10 16:23:54.941	2025-09-19 13:40:56.103	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
923	LP182437	\N	Vincente	Lê Nguyễn Thiên Phúc	2018-10-19 00:00:00	\N	0985431308	0933627422	23/42 Đình Nghi Xuân, BTĐ, Bình Tân	3	t	2025-09-10 16:23:54.928	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
929	NP162242	\N	Đaminh	Nguyễn Nguyên Thiên Phúc	2016-09-03 00:00:00	\N	0932425206	\N	40/6A Miếu Gò Xoài, BHHA, Bình Tân	16	t	2025-09-10 16:23:55.02	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
932	PP162243	\N	Giuse	Phạm Nguyễn Hồng Phúc	2016-07-15 00:00:00	\N	0989906806	\N	82/36 Lê Văn Quới, BHHA, Bình Tân	16	t	2025-09-10 16:23:55.069	2025-09-19 15:36:24.879	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
934	PP182464	\N	Têrêsa	Phan Ngọc Hồng Phúc	2018-07-07 00:00:00	\N	0909076637	0909621712	84/36A Đường Số 14, BHH A, Bình Tân	3	t	2025-09-10 16:23:55.133	2025-09-19 15:36:24.88	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
909	VP112194	\N	Phêrô	Vũ Minh Phú	2011-12-03 00:00:00	\N	0902455106	\N	138/21 Phú Thọ Hòa	41	t	2025-09-10 16:23:54.712	2025-09-19 13:40:55.34	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
930	NP102316	\N	Giuse	Nguyễn Thiên Phúc	2010-12-09 00:00:00	\N	\N	\N	\N	29	t	2025-09-10 16:23:55.035	2025-09-19 15:36:24.832	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
907	NP122114	\N	Gioan Baotixita	Nguyễn Khánh Minh Phú	2012-08-12 00:00:00	\N	0938225737	\N	266/14/7 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	31	t	2025-09-10 16:23:54.677	2025-09-19 13:40:54.013	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
922	LP162267	\N	Giuse	Lê Hữu Phúc	2016-11-13 00:00:00	\N	0933064927	\N	92 Đỗ Bí, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:54.916	2025-09-19 13:40:56.108	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
928	NP162233	\N	Augustino	Nguyễn Hoàng Phúc	2016-04-01 00:00:00	\N	0904676269	\N	7C Đường 5B, BHHA, Bình Tân	15	t	2025-09-10 16:23:55.004	2025-09-19 13:40:55.984	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1165	NT172528	\N	Maria	Nguyễn Vũ Anh Thư	2017-05-08 00:00:00		0909705689		1H1 Lê Niệm, Phú Thạnh	11	t	2025-09-10 16:23:58.784	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
912	DP172463	\N	Giuse	Đinh Đức Phúc	2017-01-02 00:00:00	\N	\N	\N	\N	14	t	2025-09-10 16:23:54.759	2025-09-19 13:40:55.239	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
925	NP162253	\N	Đaminh	Nguyễn Công Phúc	2016-04-14 00:00:00	\N	0907972257	\N	20/71 Đường số 1, BHHA, Bình Tân	11	t	2025-09-10 16:23:54.953	2025-09-19 13:40:55.573	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
918	HP172345	\N	Vincente	Huỳnh Hữu Phúc	2017-01-13 00:00:00	\N	0903332322	\N	544/16 Hương Lộ 2, BTĐ, Bình Tân	11	t	2025-09-10 16:23:54.851	2025-09-19 13:40:55.644	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
935	TP122167	\N	Anna	Thái Nguyễn Hồng Phúc	2012-05-24 00:00:00	\N	\N	0858700708	\N	36	t	2025-09-10 16:23:55.151	2025-09-19 13:40:55.288	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
933	PP152249	\N	Vinh Sơn	Phạm Thiên Phúc	2015-03-02 00:00:00	\N	0918088285	\N	103 Đường số 14, BHHA, Bình Tân	22	t	2025-09-10 16:23:55.103	2025-09-19 13:40:56.041	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
876	PP112248	\N	Antôn	Phan Tiến Phát	2011-11-01 00:00:00	\N	0909621712	0909076637	84/36A Đường số 14, BHHA, Bình Tân	34	t	2025-09-10 16:23:54.172	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
936	TP142315	\N	Giuse	Trần Lâm Thiên Phúc	2014-04-01 00:00:00	\N	0903690812	\N	5 Trần Thủ Độ, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:55.171	2025-09-19 13:40:57.142	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
941	VP092194	\N	Giuse	Vũ Hồng Phúc	2009-05-18 00:00:00	\N	0907972621	0778762421	34A Lê Cảnh Tuân, Phú Thọ Hoà, Tân Phú	50	t	2025-09-10 16:23:55.316	2025-09-19 13:40:55.796	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
958	ĐP082177	\N	Maria	Đỗ Ngọc Phượng	2008-03-22 00:00:00	\N	0909102229	\N	189 Lê Sao, Phú Thạnh, Tân Phú	51	t	2025-09-10 16:23:55.63	2025-09-19 13:40:55.754	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
896	PP132138	\N	Đa Minh	Phạm Nguyễn Duy Phong	2013-10-27 00:00:00	\N	0938382600	0907007842	42/24/8 ĐS 5, BHHA, Bình Tân	31	t	2025-09-10 16:23:54.494	2025-09-19 13:40:55.761	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
960	VP122184	\N	Maria	Vũ Thị Ngọc Phượng	2012-10-21 00:00:00	\N	0909570884	0373348926	704/23/7 Hương Lộ 2, Btđa, Bình Tân	38	t	2025-09-10 16:23:55.664	2025-09-19 13:40:57.252	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	1
939	TP102170	\N	Gioan Baotixita	Trương Thiên Phúc	2010-10-07 00:00:00	\N	0918256627	0983256627	20/29 D, ĐS 1, BHHA, Bình Tân	45	t	2025-09-10 16:23:55.284	2025-09-19 13:40:55.869	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
962	NQ102115	\N	Phêrô	Nguyễn Vinh Quang	2010-09-11 00:00:00	\N	\N	\N	\N	45	t	2025-09-10 16:23:55.693	2025-09-19 13:40:55.865	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
950	NP112149	\N	Maria Têrêsa	Nguyễn Quỳnh Mai Phương	2011-05-27 00:00:00	\N	0377554139	0377552439	294/2/2 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	42	t	2025-09-10 16:23:55.478	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
938	TP172553	\N	Maria	Trần Vũ Phương Thiên Phúc	2017-01-11 00:00:00	\N	0988532995	0977113800	53 Nguyễn Son, Phú Thạnh	11	t	2025-09-10 16:23:55.256	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
971	NQ172434	\N	Vincente	Nguyễn Minh Quân	2017-06-10 00:00:00	\N	0909617927	0915453037	427/19A Lê Văn Quới, BTĐ B, Bình Tân	10	t	2025-09-10 16:23:55.922	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
940	VP172315	\N	Maria Têrêsa	Vũ Hồng Phúc	2017-06-24 00:00:00	\N	0938573546	0934010947	111/47 Đường số 1, BHHA, Bình Tân	10	t	2025-09-10 16:23:55.302	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
953	TP152417	\N	Annê	Trần Bảo Phương	2015-10-28 00:00:00	\N	\N	\N	15A Lê Lư, Phú Thọ Hòa, Tân Phú	16	t	2025-09-10 16:23:55.527	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
901	HP132170	\N	Antôn	Hoàng Nguyễn Thiên Phú	2013-06-25 00:00:00	\N	0972338340	\N	Xã Vĩnh Lộc B, Bình Chánh 	32	t	2025-09-10 16:23:54.573	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
964	ĐQ132169	\N	Giuse	Đặng Hoàng Quân	2013-01-24 00:00:00	\N	0903086513	0388322790	244/25 Thoại Ngọc Hầu, Phú Thạnh	34	t	2025-09-10 16:23:55.731	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
949	NP132169	\N	Têrêsa	Nguyễn Lê Hà Phương	\N	\N	\N	\N	\N	33	t	2025-09-10 16:23:55.463	2025-09-19 15:36:24.809	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
967	HQ102119	\N	Phanxico	Hứa Minh Quân	2010-04-08 00:00:00	\N	0933034520	\N	25/27 Văn Cao, Phú Thạnh, Tân Phú	35	t	2025-09-10 16:23:55.807	2025-09-19 13:40:55.463	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
973	NQ112127	\N	Đa Minh	Nguyễn Minh Quân	2011-10-11 00:00:00	\N	\N	\N	\N	34	t	2025-09-10 16:23:55.954	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
972	NQ122160	\N	Phaolo	Nguyễn Minh Quân	2012-09-27 00:00:00	\N	0708164967	0834000533	127/2/75 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	36	t	2025-09-10 16:23:55.937	2025-09-19 13:40:55.599	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
951	NP142251	\N	Maria	Nguyễn Võ Đông Phương	2014-10-20 00:00:00	\N	0937787901	\N	53 Nguyễn Sơn, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:23:55.492	2025-09-19 13:40:55.805	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
948	NP182464	\N	Têrêsa	Nguyễn Hà Phương	2018-04-16 00:00:00	\N	0983434624	0909549601	69/13 Kênh Nước Đen, BHHA, Bình Tân	1	t	2025-09-10 16:23:55.447	2025-09-19 13:40:55.911	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
961	LQ152178	\N	Augustino	Lê Nhật Quang	2015-04-05 00:00:00	\N	0383908499	\N	92 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	20	t	2025-09-10 16:23:55.677	2025-09-19 13:40:57.141	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
943	VP162257	\N	Đaminh	Vũ Thiên Phúc	2016-03-24 00:00:00	\N	0987076902	\N	9D Đường số 1A, BHHA, Bình Tân	16	t	2025-09-10 16:23:55.347	2025-09-19 13:40:57.195	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1003	TQ122152	\N	Maria	Trần Ngọc Phương Quỳnh	2012-07-10 00:00:00	\N	\N	0934974966	129 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	37	t	2025-09-10 16:23:56.486	2025-09-19 13:40:57.617	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
997	ĐQ082126	\N	Têrêsa	Đoàn Lại Như Quỳnh	2008-07-07 00:00:00	\N	0903950321	0938773123	208B Lê Lâm, Phú Thạnh, Tân Phú	51	t	2025-09-10 16:23:56.385	2025-09-19 13:40:57.875	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
989	NQ132249	\N	Anna	Nguyễn Ngọc Duy Quyên	2013-10-13 00:00:00	\N	0933848645	\N	56/1/16 Đường 8B, BHHA, Bình Tân	27	t	2025-09-10 16:23:56.246	2025-09-19 13:40:57.461	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1028	ĐT132326	\N	Maria	Điểu Hoàng Lan Tiên	2013-08-27 00:00:00	\N	0703474118	\N	136 Lê Niệm, Phú Thạnh, Tân Phú	29	t	2025-09-10 16:23:56.853	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1032	NT152264	\N	Catarina	Nguyễn Mai Thủy Tiên	2015-11-19 00:00:00	\N	0936842919	\N	294/11 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	21	t	2025-09-10 16:23:56.93	2025-09-19 13:40:57.747	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1007	LS102143	\N	Têrêsa	Linh Ngọc Đan Sa	2010-09-24 00:00:00	\N	0918495377	0919142093	188/15/1B Lê Đình Cẩn, Tân Tạo, Bình Tân  	45	t	2025-09-10 16:23:56.544	2025-09-19 13:40:57.409	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1012	NS122190	\N	Maria	Nguyễn Vũ Hoàng Sang	2012-07-01 00:00:00	\N	0906658352	\N	53/5 Tân Thành, Hòa Thạnh, Tân Phú	32	t	2025-09-10 16:23:56.631	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1027	VT192548	\N	Vincente	Vương Chí Tâm	2019-09-12 00:00:00	\N	0901668067	0933235000	16/2A Bùi Thế Mỹ, Tân Bình	5	t	2025-09-10 16:23:56.841	2025-09-19 15:36:24.809	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
991	NQ172567	\N	Maria	Nguyễn Thị Mỹ Quyên	2017-07-27 00:00:00	\N	0931055354	0363963641	352/37/39 Thoại Ngọc Hầu, Phú Thạnh	14	t	2025-09-10 16:23:56.278	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
995	TQ132419	\N	Maria	Trần Thục Quyên	2013-11-12 00:00:00	\N	0986426059	\N	83 Lê Thiệt, Phú Thọ Hoà, Tân Phú	24	t	2025-09-10 16:23:56.359	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
996	ĐQ152314	\N	Maria	Đặng Nguyễn Như Quỳnh	2015-12-01 00:00:00	\N	0907735588	\N	\N	24	t	2025-09-10 16:23:56.37	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
209	ĐD132147	\N	Maria	Đinh Thị Ngọc Diệp	2013-05-09 00:00:00	\N	0354065378	0359144744	35/14 Ao Đôi, BTĐ A, Bình Tân	32	t	2025-09-10 16:23:40.333	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1008	NS142121	\N	Maria	Nguyễn Ngọc Bảo Sam	2014-09-22 00:00:00	\N	0909909056	0789821821	242/64 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:56.561	2025-09-19 13:40:57.307	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
981	VQ162498	\N	Augustino	Võ Hoàng Quân	2016-10-06 00:00:00	\N	0368567983	\N	106 Hiền Vương, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:23:56.111	2025-09-21 03:31:18.084	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
979	PQ122562	\N	Đaminh	Phạm Trần Minh Quân	2012-06-02 00:00:00	\N	0946759379	0907227349	36 Văn Cao, Phú Thọ Hoà	18	t	2025-09-10 16:23:56.067	2025-09-19 13:40:57.252	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
990	NQ172549	\N	Maria	Nguyễn Ngọc Thanh Quyên	2017-07-25 00:00:00	\N	0777911588	0382447264	1B Trương Phước Phan, BTĐA	13	t	2025-09-10 16:23:56.263	2025-09-19 13:40:57.306	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1011	NS122374	\N	\N	Nguyễn Trần Thanh Sang	2012-05-10 00:00:00	\N	0933610621	0933034520	25/27 Văn Cao, Phú Thạnh, Tân Phú	23	t	2025-09-10 16:23:56.61	2025-09-19 13:40:57.321	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1006	VQ122154	\N	Têrêsa	Vũ Phạm Như Quỳnh	2012-11-25 00:00:00	\N	0908350472	\N	108 Lê Thiệt, Phú Thọ Hòa, Tân Phú	35	t	2025-09-10 16:23:56.532	2025-09-19 13:40:57.307	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1018	VT092175	\N	Giuse 	Vũ Minh Tài	2009-01-09 00:00:00	\N	0908129138	0918456455	48/7 Lê Cảnh Tuân, Phú Thọ Hòa, Tân Phú	45	t	2025-09-10 16:23:56.719	2025-09-19 13:40:57.663	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1009	NS152248	\N	Têrêsa	Nguyễn Ngọc Linh San	2015-05-25 00:00:00	\N	0339606077	\N	168 Lê Niệm, Phú Thạnh, Tân Phú	22	t	2025-09-10 16:23:56.578	2025-09-19 13:40:57.67	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1030	HT122131	\N	Maria	Hoàng Gia Cát Tiên	2012-10-15 00:00:00	\N	0932321579	\N	\N	36	t	2025-09-10 16:23:56.888	2025-09-19 13:40:57.779	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1031	MT162479	\N	Maria	Mai Cát Tiên	\N	\N	0963967879	0903022980	106/14/1 Đình Nghi Xuân, BTĐ, BT	13	t	2025-09-10 16:23:56.914	2025-09-19 13:40:57.804	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1014	NS142215	\N	Giuse	Nguyễn Trung Sơn	2014-04-22 00:00:00	\N	0918257303	\N	94 Đất Mới, BTĐ, Bình Tân	25	t	2025-09-10 16:23:56.667	2025-09-19 13:40:58.938	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1020	HT132116	\N	Têrêsa Calcutta	Hoàng Nữ Việt Tâm	2013-04-01 00:00:00	\N	0937393380	\N	536B Bình Long, Tân Quý, Tân Phú	31	t	2025-09-10 16:23:56.742	2025-09-19 13:40:59.048	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1045	NT132158	\N	Giuse	Nguyễn Như Thanh Tú	2013-10-12 00:00:00	\N	0339606077	0969578349	416/6/8 Lạc Long Quân, P5, Q11	31	t	2025-09-10 16:23:57.122	2025-09-19 13:40:59.058	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1022	NT142137	\N	Anna	Nguyễn Phạm Thanh Tâm	2014-06-26 00:00:00	\N	0982499233	0909334635	361 Thạch Lam, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:56.768	2025-09-19 13:40:59.297	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1037	NT112146	\N	Bênadô	Nguyễn Minh Tiến	2011-04-15 00:00:00	\N	0973003055	\N	302/76A Lê Đình Cẩn, Tân Tạo, Bình Tân	34	t	2025-09-10 16:23:57.001	2025-09-19 15:36:24.81	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1049	NT122117	\N	Giuse	Nguyễn Lê Đức Tuấn	2012-04-09 00:00:00	\N	\N	0918124978	326/7 Thạch Lam, Phú Thạnh, Tân Phú	37	t	2025-09-10 16:23:57.169	2025-09-19 13:40:59.045	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1040	TT122131	\N	Giacôbê	Trần Minh Tiến	2012-03-22 00:00:00	\N	0938893659	\N	6B Văn Cao, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:57.053	2025-09-19 13:40:58.887	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1059	NT112192	\N	Giuse	Nguyễn Khánh Tường	2011-09-15 00:00:00	\N	0933829595	0909391559	246/2/4 Lê Văn Quới, BHHA, Bình Tân	42	t	2025-09-10 16:23:57.314	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1241	NU102147	\N	Têrêsa	Nguyễn Ngọc Duy Uyên	2010-10-04 00:00:00	\N	0909225938	0794887173	56/1/16 ĐS 8B, BHHA, Bình Tân	42	t	2025-09-10 16:23:59.806	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1082	TT152435	\N	Anna	Trần Phương Thảo	2015-10-19 00:00:00	\N	0986426059	\N	83 Lê Thiệt, Phú Thọ Hoà, Tân Phú	24	t	2025-09-10 16:23:57.628	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1070	BT092138	\N	Giuse 	Bùi Hiệp Thành	2009-02-05 00:00:00	\N	0938098137	\N	42/35A ĐS 5, Bhha, Bình Tân	50	t	2025-09-10 16:23:57.462	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1064	ĐT082183	\N	Maria	Điểu Ngọc Lan Thanh	2008-01-22 00:00:00	\N	0909595867	\N	138 Lê Niệm, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:57.381	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1060	NT092173	\N	Đa Minh	Nguyễn Lê Minh Thái	2009-10-10 00:00:00	\N	0972858430	\N	21B Đường 14A BHHA, Bình Tân	50	t	2025-09-10 16:23:57.33	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1077	MT162218	\N	Rosa	Mai Bùi Xuân Thảo	2016-11-23 00:00:00	\N	0989311362	\N	216 Lê Cao Lãng, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:57.555	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1025	TT152172	\N	Têrêsa	Trần Ngọc An Tâm	2015-01-01 00:00:00	\N	\N	\N	\N	20	t	2025-09-10 16:23:56.811	2025-09-19 13:40:58.901	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1039	TT182415	\N	Batôlômêô	Trần Minh Tiến	2018-08-07 00:00:00	\N	0981684151	0932188525	325B Nguyễn Sơn, Phú Thạnh, Tân Phú	3	t	2025-09-10 16:23:57.03	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1075	VT072118	\N	Giuse	Võ Minh Thành	2007-11-27 00:00:00	\N	0905407588	\N	81/1 ĐS 14, BHHA, Bình Tân	50	t	2025-09-10 16:23:57.527	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1042	LT172409	\N	Giuse	Lê Trung Tín	2017-11-09 00:00:00	\N	0938477151	\N	31/63/17 Đường số 3, BHH A, BìnhTân	12	t	2025-09-10 16:23:57.079	2025-09-21 03:31:18.084	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1024	NT142538	\N	Maria	Nguyễn Quỳnh Kim Tâm	2014-09-26 00:00:00	\N	0938228610	0765023770	78/2 đường số 4, BHHA	18	t	2025-09-10 16:23:56.798	2025-09-19 13:40:59.546	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1013	NS082537	\N	Đaminh	Nguyễn Khánh Sơn	2008-01-08 00:00:00	\N	0906363536	0705721115	97/5N Nguyễn Ảnh Thủ, quận 12	34	t	2025-09-10 16:23:56.644	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1068	TT112156	\N	Maria	Từ Lưu Yến Thanh	2011-02-08 00:00:00	\N	0966667559	0933081993	168 Trần Thủ Độ, Phú Thạnh, Tân Phú 	42	t	2025-09-10 16:23:57.438	2025-09-19 13:40:59.244	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1071	NT112144	\N	Giuse	Nguyễn Tiến Thành	\N	\N	\N	\N	\N	36	t	2025-09-10 16:23:57.474	2025-09-19 13:40:59.456	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1033	TT142118	\N	Maria	Trần Ngọc Thủy Tiên	\N	\N	\N	\N	31/1 đường số 3, BHH A, Bình Tân	25	t	2025-09-10 16:23:56.943	2025-09-19 13:40:59.616	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1015	LT152319	\N	Giuse	Lê Phạm Văn Tài	2015-09-19 00:00:00	\N	0969156750	\N	\N	15	t	2025-09-10 16:23:56.679	2025-09-19 13:40:59.656	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1035	BT142335	\N	Micae	Bùi Lê Minh Tiến	2014-07-26 00:00:00	\N	0933238754	0909245170	147 Đường số 1, BHHA, Bình Tân	23	t	2025-09-10 16:23:56.969	2025-09-19 13:40:59.656	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1126	NT192526	\N	Giuse	Nguyễn Phúc Thịnh	2019-05-29 00:00:00	\N	0933345112	0934454920	38B đường số 13A, BHHA	5	t	2025-09-10 16:23:58.252	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
1072	NT132170	\N	Phêrô	Nguyễn Tiến Thành	\N	\N	\N	\N	\N	28	t	2025-09-10 16:23:57.487	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1087	NT102181	\N	Vinh Sơn	Nguyễn Tạ Mạnh Thắng	2011-11-27 00:00:00	\N	0913120443	\N	40/6D Miếu Gò Xoài, BHHA, Bình Tân	41	t	2025-09-10 16:23:57.692	2025-09-19 13:41:01.095	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1079	NT122162	\N	Maria	Nguyễn Ngọc Thanh Thảo	2012-01-17 00:00:00	\N	0908693090	0918794879	266/8/25 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	35	t	2025-09-10 16:23:57.583	2025-09-19 13:41:00.741	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1056	NT142122	\N	Anna	Nguyễn Minh Kim Tuyến	2014-01-01 00:00:00	\N	\N	\N	\N	21	t	2025-09-10 16:23:57.263	2025-09-19 13:40:59.509	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1101	TT112159	\N	Giuse	Trần Trung Thiên	2011-05-06 00:00:00	\N	0906209305	0783556694	62/17/16 Đường 5A, BHHA, Bình Tân	42	t	2025-09-10 16:23:57.897	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1097	TT142166	\N	Phaolo	Trần Bảo Thiên	2014-05-17 00:00:00	\N	0906097909	0972215774	142A Lê Lâm, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:57.841	2025-09-19 13:41:01.559	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1106	ĐT142267	\N	Giuse	Đỗ Hoàng Chí Thiện	2014-06-07 00:00:00	\N	0966035785	0362501468	264/13 Lê Văn Quới, BHHA, Bình Tân	28	t	2025-09-10 16:23:57.971	2025-09-21 02:16:56.335	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1105	DT132418	\N	Đaminh	Đào Đức Thiện	2013-03-04 00:00:00	\N	\N	\N	\N	24	t	2025-09-10 16:23:57.957	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1083	TT092143	\N	Maria	Trần Thanh Thảo	2009-07-18 00:00:00	\N	0906209305	0783556694	62/17/16 Đường 5A, BHHA	45	t	2025-09-10 16:23:57.64	2025-09-19 13:40:59.71	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1110	NT162328	\N	Phêrô	Nguyễn Chí Thiện	2016-12-11 00:00:00	\N	0933995258	\N	58/9 Đường số 14A, BHHA, Bình Tân	17	t	2025-09-10 16:23:58.028	2025-09-21 08:23:12.47	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1069	TT142179	\N	Cecilia	Trần Thái Thiên Thanh	2014-09-07 00:00:00	\N	0988080383	0919838482	3/10 Hiền Vương, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:57.45	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
1063	VT132169	\N	Giuse	Vũ Đình Thái	2013-09-15 00:00:00	\N	0943500700	0856500700	904/5B Hương Lộ 2, BTĐ, Bình Tân	30	t	2025-09-10 16:23:57.369	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1080	TT122410	\N	Têrêsa	Trần Hương Thảo	2012-08-10 00:00:00	\N	0932010812	0909842702	128/4/7 Nguyễn Sơn, Phú Thọ Hoà, Tân Phú	24	t	2025-09-10 16:23:57.597	2025-09-19 15:36:24.81	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1200	ĐT162335	\N	Anna	Đỗ Huỳnh Bảo Trân	2016-08-17 00:00:00	\N	0707870529	0797443610	87 Đường số 8, BHHA, Bình Tân	17	t	2025-09-10 16:23:59.259	2025-09-21 08:19:32.587	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1124	NT182490	\N	Giuse	Nguyễn Hữu Trường Thịnh	2018-02-04 00:00:00	\N	0932725248	0933909802	44 Đường số 1,  BHHA, BT	2	t	2025-09-10 16:23:58.222	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1089	VT182319	\N	Phêrô	Vũ Duy Thắng	2018-11-24 00:00:00	\N	0903716023	0908210701	16/5 Nguyễn Nhữ Lãm, Phú Thọ Hòa, Tân Phú	2	t	2025-09-10 16:23:57.723	2025-09-19 13:41:00.793	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1107	LT142163	\N	Giuse	Lê Ngọc Thiện	2014-08-14 00:00:00	\N	0798516579	\N	18/13 Đường số 4, BHHA, Bình Tân	22	t	2025-09-10 16:23:57.983	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1128	NT172363	\N	Vincente	Nguyễn Trường Thịnh	2017-05-27 00:00:00	\N	0902158555	0907394598	167 Lê Niệm, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:58.278	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
1111	NT152285	\N	Phêrô	Nguyễn Chí Thiện	2015-01-01 00:00:00	\N	0935087639	\N	520 Hương Lộ 2, BTĐ, Bình Tân	20	t	2025-09-10 16:23:58.039	2025-09-19 13:41:00.848	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1103	VT172316	\N	Giuse	Vi Hạo Thiên	2017-04-05 00:00:00	\N	0933593305	\N	251 Hiền Vương, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:23:57.933	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1114	NT172536	\N	Tôma	Nguyễn Thành Thiện	2017-07-05 00:00:00	\N	0933633472	\N	17/2/5 đường số 3A, BHHA	14	t	2025-09-10 16:23:58.081	2025-09-19 15:36:24.81	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1119	HT192565	\N	Giuse	Hoàng Đức Thịnh	2019-03-27 00:00:00	\N	0782273273	0946643653	115E Lê Lư, Phú Thọ Hòa, Tân Phú	6	t	2025-09-10 16:23:58.151	2025-09-19 13:41:01.283	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1093	NT122123	\N	Antôn	Nguyễn Cảnh Thiên	2012-06-04 00:00:00	\N	0913946663	0902977565	24/10 Đường 13A, BHHA, Bình Tân	30	t	2025-09-10 16:23:57.775	2025-09-19 13:41:01.577	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1154	HT152166	\N	Maria	Hoàng Anh Thư	2015-06-03 00:00:00	\N	0937760408	\N	280A ĐS 8, BHHA, Bình Tân	20	t	2025-09-10 16:23:58.638	2025-09-19 13:41:02.719	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
1162	NT142139	\N	Lucia	Nguyễn Ngọc Anh Thư	2014-06-29 00:00:00	0907413888	0907413888	0907413888	378/91 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:58.748	2025-09-19 13:41:02.606	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1149	CT142166	\N	Maria	Cao Song Thư	2014-04-08 00:00:00	\N	0918738876	\N	285/110 Lê Văn Quới, BTĐ, Bình Tân	25	t	2025-09-10 16:23:58.566	2025-09-19 13:41:02.607	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1164	NT122118	\N	Maria	Nguyễn Thanh Thư	2012-01-04 00:00:00	\N	0903172157	\N	325/27C Lê Văn Quới, BTĐ, Bình Tân	33	t	2025-09-10 16:23:58.773	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1116	PT132318	\N	Phêrô	Phạm Chí Thiện	2013-06-19 00:00:00	\N	0909881178	\N	\N	33	t	2025-09-10 16:23:58.114	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1152	DT112436	\N	Matta	Đoàn Ngọc Anh Thư	2011-05-06 00:00:00	\N	0977777796	0909377765	132B Lê Lâm, Phú Thạnh, Tân Phú	24	t	2025-09-10 16:23:58.609	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1143	NT162571	\N	Maria	Nguyễn Thị Thanh Thuý	2016-04-16 00:00:00	\N	0933633472	\N	17/2/5 đường số 3A, BHHA	14	t	2025-09-10 16:23:58.477	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
136	BB152112	\N	Vinh Sơn	Bùi Hoàng Gia Bảo	2015-04-13 00:00:00	\N	0909600889	\N	34 Đường số 5F, BHHA, Bình Tân	22	t	2025-09-10 16:23:39.335	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1123	LT132253	\N	Phaolô	Lưu Khánh Hưng Thịnh	2013-06-22 00:00:00	\N	0906373702	\N	342/25 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	25	t	2025-09-10 16:23:58.204	2025-09-19 13:41:01.101	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1140	BT132115	\N	Gioan Baotixita	Bùi Minh Thuận	2013-12-12 00:00:00	\N	0909119094	0938098137	42/35A ĐS 5, BHHA, Bình Tân	31	t	2025-09-10 16:23:58.44	2025-09-19 13:41:02.656	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1155	NT122371	\N	Anna	Nguyễn Anh Thư	2012-11-01 00:00:00	\N	0989789742	\N	85 Đường số 5, BHHA, Bình Tân	29	t	2025-09-10 16:23:58.649	2025-09-19 13:41:02.701	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	2	1
1161	NT102134	\N	Maria	Nguyễn Ngọc Anh Thư	2010-02-13 00:00:00	\N	0966082116	\N	76/10/7/7 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	45	t	2025-09-10 16:23:58.736	2025-09-19 13:41:02.604	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1166	NT122157	\N	Maria	Nguyễn Vũ Kim Thư	2012-06-30 00:00:00	\N	0911133332	\N	A5/35S14 Đường 1A, Vĩnh Lộc B, Bình Chánh	35	t	2025-09-10 16:23:58.798	2025-09-19 13:41:01.449	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1146	TT162357	\N	Maria	Trần Thị Thu Thủy	2016-10-17 00:00:00	\N	0978562926	0862030605	73A Liên Khu 10-11, BTĐ, Bình Tân	19	t	2025-09-10 16:23:58.529	2025-09-19 13:41:02.975	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1144	HT162241	\N	Anna	Hoàng Thị Diệu Thùy	2016-02-26 00:00:00	\N	0909874920	\N	23/1 Đường số 14B, BHHA, Bình Tân	15	t	2025-09-10 16:23:58.494	2025-09-19 13:41:01.424	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1125	NT162342	\N	Giuse	Nguyễn Phúc Thịnh	2016-05-17 00:00:00	\N	\N	\N	\N	16	t	2025-09-10 16:23:58.236	2025-09-19 13:41:01.12	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1141	TT112148	\N	Tôma	Trần Gia Thuận	2011-07-06 00:00:00	\N	0909459928	0932080079	58B Văn Cao, Phú Thọ Hoà, Tân Phú	37	t	2025-09-10 16:23:58.453	2025-09-19 13:41:01.309	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1151	DT172467	\N	Maria	Dương Huỳnh Anh Thư	2017-09-19 00:00:00	\N	0906034440	0934157131	16/14 Nguyễn Nhữ Lãm, PTH, Tân Phú	12	t	2025-09-10 16:23:58.592	2025-09-21 03:31:18.084	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1157	NT122169	\N	Maria	Nguyễn Kim Thư	2012-12-11 00:00:00	\N	\N	\N	\N	29	t	2025-09-10 16:23:58.673	2025-09-19 13:41:01.407	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1132	PT182407	\N	Giuse	Phan Hưng Thịnh	2018-02-18 00:00:00	\N	0911168488	\N	364/53/2 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	3	t	2025-09-10 16:23:58.334	2025-09-19 13:41:03.027	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1134	DT152481	\N	Vincente	Đặng Văn Thọ	\N	\N	0909804425	94434059	225/27/16 Lê Văn Quới, BTĐ, BT	18	t	2025-09-10 16:23:58.358	2025-09-19 13:41:02.761	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1142	PT182577	\N	Maria	Phan Trần Kim Thuỷ	2018-03-22 00:00:00	\N	0909981598	0939981598	44A Miếu Bình Đông, BTĐ	4	t	2025-09-10 16:23:58.466	2025-09-19 13:41:02.653	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1129	NT122256	\N	Gioan Baotixita	Nguyễn Văn Công Thịnh	2012-09-26 00:00:00	\N	0912436115	\N	44/62/38A Trương Phước Phan, BTĐ, Bình Tân	25	t	2025-09-10 16:23:58.29	2025-09-19 13:41:03.292	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1139	BT182511	\N	Đa Minh	Bùi Đức Thuận	2018-05-19 00:00:00	\N	0903736940	0944564233	29E Đường 5F, BHHA, Bình Tân	4	t	2025-09-10 16:23:58.428	2025-09-19 13:41:03.482	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1159	NT092552	\N	Anna	Nguyễn Minh Thư	2009-01-16 00:00:00	\N	0336885135	0335972194	A18/46 ấp 1A, Vĩnh Lộc B	51	t	2025-09-10 16:23:58.704	2025-09-19 13:41:03.382	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1178	VT182545	\N	Maria	Võ Ngân Thư	2018-11-28 00:00:00	\N	0938874572	0832384828	134 Trần Quang Cơ, Phú Thạnh, Tân Phú	4	t	2025-09-10 16:23:58.966	2025-09-19 13:41:03.285	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1199	NT132185	\N	Maria	Nguyễn Thị Bảo Trâm	2013-02-16 00:00:00	\N	0335163986	\N	114/3 ĐS 6, BHHA, Bình Tân	31	t	2025-09-10 16:23:59.247	2025-09-19 13:41:03.239	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1130	PT172357	\N	Antôn	Phạm Phúc Thịnh	2017-08-18 00:00:00	\N	0948956695	0909448807	A10-11 CC Phú Thạnh, 53 Nguyễn Sơn, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:58.303	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1191	TT102117	\N	Maria	Trương Phạm Minh Thy	2010-11-24 00:00:00	\N	0938595561	70759820	33 Đường 16A, BHHA, Bình Tân	45	t	2025-09-10 16:23:59.137	2025-09-19 13:41:03.165	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1183	ĐT132256	\N	Têrêsa	Đinh Khánh Thy	2013-06-05 00:00:00	\N	0935468187	\N	125A Lê Lâm, Phú Thạnh, Tân Phú	21	t	2025-09-10 16:23:59.042	2025-09-19 13:41:03.186	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1171	TT092199	\N	Maria	Trần Minh Thư	2009-07-17 00:00:00	\N	0903870866	0386582723	172/15 Lê Thúc Hoạch, Tân Quý, Tân Phú	50	t	2025-09-10 16:23:58.864	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1189	PT132146	\N	Têrêsa	Phạm Nguyễn Minh Thy	\N	\N	\N	\N	\N	32	t	2025-09-10 16:23:59.112	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1163	NT122283	\N	Madalêna	Nguyễn Ngọc Anh Thư	2012-10-17 00:00:00	\N	0938777949	\N	37A Đường số 12, BHHA, Bình Tân	32	t	2025-09-10 16:23:58.761	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1174	TT152556	\N	Maria	Trần Thị Anh Thư	2015-06-08 00:00:00	\N	0367451992	0329479889	242 Lê Văn Quới, BHHA	19	t	2025-09-10 16:23:58.916	2025-09-19 13:41:03.449	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
832	VN172440	\N	Maria	Vũ Yến Nhi	2017-06-21 00:00:00	\N	0989426644	0981620061	135/38 Gò Xoài, BHH A, Bình Tân	14	t	2025-09-10 16:23:53.446	2025-09-19 15:36:24.88	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1193	NT142147	\N	Maria	Nguyễn Ngọc Vân Trang	2014-06-12 00:00:00	\N	0935539786	0935074073	266/36/2 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	26	t	2025-09-10 16:23:59.16	2025-09-19 13:41:03.158	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1195	VT112130	\N	Maria	Vũ Thu Trang	2011-10-03 00:00:00	\N	0988866035	\N	19 Gò Xoài, BHHA, Bình Tân	41	t	2025-09-10 16:23:59.192	2025-09-19 13:41:03.158	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1137	PT172373	\N	Maria	Phạm Anh Thơ	2017-11-25 00:00:00	\N	0987717398	0973991364	33/13A Đường 16A, BHHA, Bình Tân	10	t	2025-09-10 16:23:58.399	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1147	NT132196	\N	Cecilia	Nguyễn Lam Vĩnh Thụy	2013-04-13 00:00:00	\N	0902977565	9090606343	34/07 Đường 22, BHHA, Bình Tân	30	t	2025-09-10 16:23:58.543	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1176	TT112141	\N	Anna	Trần Thị Minh Thư	2011-11-13 00:00:00	\N	0909545994	0963638487	1/2/11 Đường 5C, BHHA, Bình Tân 	40	t	2025-09-10 16:23:58.94	2025-09-19 13:41:03.164	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1153	ĐT132142	\N	Maria	Đỗ Ngọc Anh Thư	2013-10-07 00:00:00	\N	0938910635	\N	73/13 ĐS 12, BHHA, Bình Tân	30	t	2025-09-10 16:23:58.628	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1170	TT182553	\N	Maria	Thạch Đoàn Anh Thư	2018-01-22 00:00:00	\N	0901938196	0906514526	5 Trần Thủ Độ, Phú Thạnh, Tân Phú	4	t	2025-09-10 16:23:58.851	2025-09-19 13:41:03.278	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1204	NT122115	\N	Maria	Nguyễn Ngọc Quỳnh Trân	2012-08-01 00:00:00	\N	0938733188	\N	0272/06/05 Gò Xoài, BHHA, Bình Tân	37	t	2025-09-10 16:23:59.308	2025-09-19 13:41:03.173	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1202	NT182426	\N	Maria	Nguyễn Lê Quỳnh Trân	\N	\N	0938264209	0905365255	113/20 Phú Thọ Hòa, TP	3	t	2025-09-10 16:23:59.283	2025-09-19 13:41:03.211	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1198	NT162248	\N	Lucia	Nguyễn Ngọc Bảo Trâm	2016-07-10 00:00:00	\N	0907413888	\N	364/53 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	16	t	2025-09-10 16:23:59.237	2025-09-19 13:41:03.225	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1185	NT112186	\N	Maria	Nguyễn Đình Khánh Thy	2011-09-09 00:00:00	\N	0918336540	0784524554	368 Bình Long, Phú Thọ Hòa, Tân Phú	40	t	2025-09-10 16:23:59.065	2025-09-19 13:41:03.229	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1205	PT082166	\N	Maria	Phạm Ngọc Bảo Trân	2008-05-06 00:00:00	\N	0346498897	0355896030	18/19 ĐS 8B, BHHA, Bình Tân	51	t	2025-09-10 16:23:59.322	2025-09-19 13:41:05.013	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1223	DT132112	\N	Maria	Dương Thanh Trúc	2013-03-29 00:00:00	\N	0932048787	\N	34/27 Hoàng Ngọc Phách, Phú Thọ Hoà, Tân Phú	27	t	2025-09-10 16:23:59.551	2025-09-19 13:41:05.03	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1213	PT132118	\N	Gioan Baotixita	Phạm Đắc Minh Trí	2013-04-18 00:00:00	\N	\N	0938225737	266/14/7 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	31	t	2025-09-10 16:23:59.419	2025-09-19 13:41:05.092	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1229	ĐT142253	\N	Vinh Sơn	Đoàn Quang Trung	2014-01-22 00:00:00	\N	0966648730	\N	305/13/56 Lê Văn Quới, BTĐA, Bình Tân	28	t	2025-09-10 16:23:59.637	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1232	NT142166	\N	Giuse	Ngô Xuân Trường	2014-03-13 00:00:00	\N	0974953189	\N	330 Lê Văn Quới, BHHA, Bình Tân	28	t	2025-09-10 16:23:59.672	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1235	BU122115	\N	Maria	Bùi Phương Uyên	2012-08-25 00:00:00	\N	0909171809	0903185225	52A Lê Lư, Phú Thọ Hòa, Tân Phú	29	t	2025-09-10 16:23:59.714	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1225	NT132152	\N	Maria	Nguyễn Hoàng Thanh Trúc	2013-11-21 00:00:00	\N	0903145299	\N	37/8/33 Đường số 6, BHHA, Bình Tân	29	t	2025-09-10 16:23:59.577	2025-09-19 15:36:24.879	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1216	TT122178	\N	Giuse	Trần Nguyễn Quang Trí	2012-06-02 00:00:00	\N	0778941678	7064682353	249 Tân Hương, Tân Quý, Tân Phú	41	t	2025-09-10 16:23:59.46	2025-09-19 13:41:04.668	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1226	NT162238	\N	Catarina	Nguyễn Như Trúc	2016-04-21 00:00:00	\N	0938528139	\N	26/11 Đường số 5, BHHA, Bình Tân	16	t	2025-09-10 16:23:59.594	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1172	TT142198	\N	Maria	Trần Minh Thư	2014-10-17 00:00:00	\N	0989223170	\N	32 đường 3B, BHHA, Bình Tân	28	t	2025-09-10 16:23:58.88	2025-09-19 15:36:24.832	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1234	HU152349	\N	Phêrô	Hoàng Thanh Anh Uy	2015-11-15 00:00:00	\N	0782273273	0946643653	115E Lê Lư, Phú Thọ Hòa, Tân Phú	23	t	2025-09-10 16:23:59.699	2025-09-19 13:41:04.613	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1238	ĐU112112	\N	Maria	Đỗ Thị Nhã Uyên	2011-12-09 00:00:00	\N	\N	\N	\N	42	t	2025-09-10 16:23:59.755	2025-09-21 02:38:37.065	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1211	NT132156	\N	Giuse	Nguyễn Minh Trí	2013-04-01 00:00:00	\N	0898486348	0902961145	64 Lê Cảnh Tuân, Phú Thọ Hòa, Tân Phú	30	t	2025-09-10 16:23:59.393	2025-09-20 13:27:29.581	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1242	NU092135	\N	Maria	Nguyễn Ngọc Phương Uyên	2009-12-16 00:00:00	\N	0909277477	0903881727	299 Trần Thủ Độ, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:59.824	2025-09-19 15:36:24.832	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1218	TT152310	\N	Giuse	Trần Phạm Minh Triết	2015-12-15 00:00:00	\N	\N	\N	\N	23	t	2025-09-10 16:23:59.488	2025-09-19 13:41:04.655	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1236	DU192571	\N	Maria	Diệp Nhã Uyên	2019-01-07 00:00:00	\N	0703294296	\N	204/6 Đường số 8, BHHA, Bình Tân	6	t	2025-09-10 16:23:59.729	2025-09-19 13:41:04.724	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1175	TT092117	\N	Maria	Trần Thị Minh Thư	2009-01-07 00:00:00	\N	\N	\N	98 ĐS 4, BHHA, Bình Tân	50	t	2025-09-10 16:23:58.927	2025-09-19 15:36:24.879	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1220	PT132136	\N	Maria	Phạm Lê Phương Trinh	\N	\N	\N	\N	\N	31	t	2025-09-10 16:23:59.514	2025-09-19 13:41:04.923	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1207	TT172463	\N	Maria	Thái Phương Trân	2017-11-29 00:00:00	\N	0903042184	\N	305/54 Lê Văn Quới, BTĐ, Bình Tân	12	t	2025-09-10 16:23:59.345	2025-09-21 03:31:18.084	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1243	NU162472	\N	Maria 	Nguyễn Ngọc Thanh Uyên	2016-03-16 00:00:00	\N	0988289218	0908111746	56/17 Đường 14A, BHH A, Bình Tân	18	t	2025-09-10 16:23:59.84	2025-09-19 13:41:04.878	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1230	VT122118	\N	Phêrô	Võ Tấn Trung	2012-03-14 00:00:00	\N	0766081388	\N	42/24/47/5 Đường số 5, BHHA, Bình Tân	36	t	2025-09-10 16:23:59.652	2025-09-19 13:41:05.09	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1228	VT172406	\N	Maria	Vũ Nguyễn Thanh Trúc	2017-11-06 00:00:00	\N	0345126162	0985632623	223 Lê Sao, Phú Thạnh, Tân Phú	14	t	2025-09-10 16:23:59.624	2025-09-19 13:41:05.094	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1237	DU122130	\N	Madalêna	Dương Lê Thảo Uyên	2012-04-16 00:00:00	\N	0918661672	0909656474	364/49 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	36	t	2025-09-10 16:23:59.742	2025-09-19 13:41:05.221	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1215	TT162235	\N	Phanxico Savie	Trần Minh Trí	2016-10-11 00:00:00	\N	0908392790	\N	53 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	16	t	2025-09-10 16:23:59.443	2025-09-19 13:41:05.272	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1276	VV072192	\N	Michael	Vũ Anh Vũ	2007-01-05 00:00:00	\N	0775789175	0936731060	292 ĐS 5, BHH, Bình Tân	51	t	2025-09-10 16:24:00.328	2025-09-19 13:41:06.452	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1273	HV082196	\N	Tôma	Hoàng Anh Vũ	2008-04-12 00:00:00	\N	\N	0378963865	37/10 ĐS 14B, BHHA, Bình Tân	51	t	2025-09-10 16:24:00.278	2025-09-19 13:41:06.406	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1253	BV142193	\N	Têrêsa	Bùi Ngọc Thiên Vân	2014-06-18 00:00:00	0971098908	0971098908	0971098908	323 Lê Sao, quận Tân Phú, HCM \n	27	t	2025-09-10 16:23:59.97	2025-09-19 13:41:06.408	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1257	TV072518	\N	Maria	Trần Thanh Vân	2007-08-30 00:00:00		0932710065		18 đường 4, BHHA	51	t	2025-09-10 16:24:00.036	2025-09-21 10:25:35.539	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1245	NU162371	\N	Têrêsa	Nguyễn Trần Mỹ Uyên	2016-05-30 00:00:00	\N	0973311322	0975096029	48/6 Phạm Văn Xảo, Phú Thọ Hòa, Tân Phú	17	t	2025-09-10 16:23:59.865	2025-09-21 08:19:32.587	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1254	NV132261	\N	Maria	Nguyễn Lê Bảo Vân	2013-06-01 00:00:00	\N	0907254757	\N	149 Lê Cao Lãng, Phú Thạnh, Tân Phú	33	t	2025-09-10 16:23:59.985	2025-09-19 15:36:24.88	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1279	NV112136	\N	Giuse	Nguyễn Thanh Quốc Vương	2011-07-19 00:00:00	\N	0349533598	0398635020	17/2/1Phường Tân Tạo, Bình Tân	42	t	2025-09-10 16:24:00.363	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1250	VU142188	\N	Maria	Vũ Thu Uyên	\N	\N	\N	\N	\N	28	t	2025-09-10 16:23:59.926	2025-09-21 02:36:34.89	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1272	VV192567	\N	Giuse	Vũ Đức Vinh	2019-10-13 00:00:00	\N	0906860082	0908747803	111/47 đường số 1, BHHA, Bình Tân	6	t	2025-09-10 16:24:00.265	2025-09-19 13:41:07.006	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1277	VV162348	\N	Vinh Sơn	Vương Điền Vũ	2016-10-28 00:00:00	\N	0937663730	\N	240/15 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	17	t	2025-09-10 16:24:00.339	2025-09-21 08:23:12.47	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1248	TU182561	\N	Maria Goretti	Tống Minh Uyên	2018-05-04 00:00:00	\N	0906836205	\N	206/28/6 Lê Văn Quới, BHHA	1	t	2025-09-10 16:23:59.898	2025-09-19 13:41:06.511	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1259	ĐV092166	\N	Maria	Đặng Ngọc Phương Vi	2009-10-15 00:00:00	\N	0778901813	\N	17 Phan Thị Hành, Phú Thọ Hoà, Tân Phú	40	t	2025-09-10 16:24:00.066	2025-09-19 13:41:05.167	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1262	KV162238	\N	Giuse	Kiều Tuấn Việt	2016-05-04 00:00:00	\N	0901555574	\N	364/50 Trình Đình Trọng, Hòa Thạnh, Tân Phú	16	t	2025-09-10 16:24:00.108	2025-09-19 13:41:06.353	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1270	NV142147	\N	Giuse	Nguyễn Vũ Quang Vinh	\N	\N	\N	\N	\N	25	t	2025-09-10 16:24:00.239	2025-09-19 13:41:06.354	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1288	NV172336	\N	Maria	Nguyễn Cát Tường Vy	2017-08-02 00:00:00	\N	0868746226	0977378429	165/4 Trần Quang Cơ, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:24:00.489	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1260	NV112130	\N	Maria 	Nguyễn Tường Vi	2011-06-16 00:00:00	\N	0938190269	\N	114/18/30 Bùi Quang Là, P12, Gò Vấp	40	t	2025-09-10 16:24:00.079	2025-09-19 13:41:06.409	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1289	NV172489	\N	Teresa Calcutta	Nguyễn Cát Tường Vy	2017-07-03 00:00:00	\N	0932522078	0907684548	38/12 Nguyễn Sơn, PTH, TP	12	t	2025-09-10 16:24:00.507	2025-09-21 03:31:18.085	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1274	NV152185	\N	Emmanuel	Nguyễn Đăng Huy Vũ	2015-07-03 00:00:00	\N	0939384308	\N	294/10 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	20	t	2025-09-10 16:24:00.296	2025-09-19 13:41:06.458	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1271	TV172321	\N	Giuse	Trần Long Vinh	2017-10-19 00:00:00	\N	0903857234	0989765276	8 Đinh Liệt, Phú Thạnh, Tân Phú	10	t	2025-09-10 16:24:00.253	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
1261	ĐV122177	\N	Gioakim	Đỗ Quốc Việt	2012-11-14 00:00:00	\N	0906141478	\N	55/13/2M ĐS 18B, BHHA, Bình Tân	36	t	2025-09-10 16:24:00.094	2025-09-19 13:41:07.274	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
1275	PV082315	\N	Giuse	Phạm Anh Vũ	2008-09-19 00:00:00	\N	\N	\N	Hẻm 23 Đường 5A, BHHA, Bình Tân	38	t	2025-09-10 16:24:00.312	2025-09-19 13:41:07.388	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1316	VV152175	\N	Maria	Võ Phạm Khánh Vy	2015-03-14 00:00:00	\N	0944176190	\N	34/2 Đường số 8B, BHHA, Bình Tân	24	t	2025-09-10 16:24:01.07	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	1
509	DK192562	\N	Giuse	Đỗ Trần Đăng Khoa	2019-06-30 00:00:00	\N	0973500911	0974350807	337/10 Thạch Lam, Phú Thạnh	5	t	2025-09-10 16:23:46.836	2025-09-19 13:41:08.57	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	1
836	HN142174	\N	Têrêsa	Hồ An Nhiên	2014-08-24 00:00:00	\N	0938107580	\N	201 Thạch Lam, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:53.518	2025-09-19 13:41:08.271	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1312	TV142273	\N	Maria	Trần Ngọc Thảo Vy	2014-02-03 00:00:00	\N	0922821277	\N	84/20 Đường số 14, BHHA, Bình Tân	25	t	2025-09-10 16:24:00.955	2025-09-19 13:41:07.21	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
38	TA142176	\N	M. Goretti	Trần Thị Hoài An	2014-07-03 00:00:00	\N	0916464819	0918370695	113 Đỗ Bí, Phú Thạnh, Tân Phú	28	t	2025-09-10 16:23:37.996	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1298	NV122169	\N	Anna	Nguyễn Trần Khánh Vy	2012-07-01 00:00:00	\N	0937761114	0987254099	1/19 Lê Thúc Hoạch ,Phú Thọ Hòa,Tân Phú	38	t	2025-09-10 16:24:00.638	2025-09-19 13:41:08.53	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1295	NV122121	\N	Maria	Nguyễn Ngọc Tường Vy	2012-01-19 00:00:00	\N	0919567502	0337292989	343/60 Trần Thủ Độ, Phú Thọ Hoà, Tân Phú	38	t	2025-09-10 16:24:00.591	2025-09-19 13:41:08.273	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1330	PY182453	\N	Giuse	Phạm An Yên	2018-05-30 00:00:00	\N	0903352339	0936680353	245A Trần Thủ Độ, Phú Thạnh, Tân Phú	3	t	2025-09-10 16:24:01.438	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1333	NY172347	\N	Maria	Nguyễn Hải Yến	2017-12-04 00:00:00	\N	0843191688	0966253515	47 Đường số 4, BHHA, Bình Tân	11	t	2025-09-10 16:24:01.49	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1297	NV162364	\N	Maria	Nguyễn Thảo Vy	2016-02-27 00:00:00	\N	0988964846	0379762499	39 Miếu Bình Đông, BHHA, Bình Tân	19	t	2025-09-10 16:24:00.624	2025-09-19 13:41:08.269	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1306	PV172459	\N	Anna	Phan Thị Tường Vy	2017-02-09 00:00:00	\N	\N	0917737730	234A Đường số 08, BHH A, Bình Tân	14	t	2025-09-10 16:24:00.795	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1314	TV082119	\N	Maria	Trịnh Nguyễn Tường Vy	2008-12-21 00:00:00	\N	0909860950	0939891180	53 Nguyễn Sơn, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:24:01.019	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1313	TV092146	\N	Maria	Trần Thanh Vy	2009-09-20 00:00:00	\N	0909762051	0903850623	242/16 Thoại Ngọc Hầu, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:24:00.992	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1320	BY162421	\N	Anna	Bùi Ngọc Như Ý	2016-01-21 00:00:00	\N	0931144992	\N	129/8/13 Lê Lư, Phú Thọ Hoà, Tân Phú	13	t	2025-09-10 16:24:01.176	2025-09-19 13:41:07.011	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
761	TN182446	\N	Maria 	Trần Thị Thanh Ngọc	2018-08-01 00:00:00	\N	0934023412	0979430803	98A Miếu Bình Đông, BHH A, Bình Tân	2	t	2025-09-10 16:23:51.302	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1309	TV132341	\N	Maria	Trần Ai Vy	2013-08-23 00:00:00	\N	\N	\N	\N	23	t	2025-09-10 16:24:00.88	2025-09-19 13:41:07.185	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1294	NV162264	\N	Anna	Nguyễn Ngọc Tường Vy	2016-02-04 00:00:00	\N	0904422181	\N	132C Lê Lâm, Phú Thạnh, Tân Phú	15	t	2025-09-10 16:24:00.574	2025-09-19 13:41:07.186	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1299	PV122145	\N	Têrêsa	Phạm Hoàng Yến Vy	2012-12-14 00:00:00	\N	0589700831	\N	\N	36	t	2025-09-10 16:24:00.658	2025-09-19 13:41:07.19	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	0	1
1317	VV142153	\N	Maria	Vũ Thị Tường Vy	2014-03-06 00:00:00	\N	0903374296	0988664442	38 Đường 5F, BHHA, Bình Tân	31	t	2025-09-10 16:24:01.09	2025-09-19 13:41:07.273	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1292	NV092143	\N	Têrêsa	Nguyễn Lâm Yến Vy	2009-05-04 00:00:00	\N	0906344366	0937344366	375 Vườn Lài, Phú Thọ Hòa, Tân Phú	50	t	2025-09-10 16:24:00.549	2025-09-19 15:36:24.811	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
1308	TV172449	\N	Lucia	Từ Lưu Yến Vy	2017-08-23 00:00:00	\N	0966667559	0933081993	168 Trần Thủ Độ, Phú Thạnh, Tân Phú	12	t	2025-09-10 16:24:00.845	2025-09-21 03:31:18.085	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1325	NY192537	\N	Têrêsa	Nguyễn Kim Thiên Ý	2019-01-24 00:00:00	\N	\N	\N	121 Lê lâm, Phú Thạnh	5	t	2025-09-10 16:24:01.346	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1332	NY142116	\N	Maria Giuse	Nguyễn Giang Hải Yến	2014-12-11 00:00:00	\N	0903863033	\N	61 Đường số 1C, BHHA, Bình Tân	22	t	2025-09-10 16:24:01.469	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1329	VY112139	\N	Maria	Vũ Phạm Như Ý	2011-08-05 00:00:00	\N	0908350472	\N	108 Lê Thiệt, Phú Thọ Hòa, Tân Phú	35	t	2025-09-10 16:24:01.424	2025-09-19 13:41:09.104	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
430	NK162247	\N	Giuse	Nguyễn Hoàng Kiên	2016-10-22 00:00:00	\N	0934395587	\N	128/3/14 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	15	t	2025-09-10 16:23:45.19	2025-09-19 13:41:09.029	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
567	VL082167	\N	Maria	Vũ Hoàng Phương Lan	2008-11-22 00:00:00	\N	0774973690	\N	298/11 Vườn Lài, Phú Thọ Hòa, Tân Phú	51	t	2025-09-10 16:23:47.904	2025-09-19 13:41:10.374	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
84	NA142113	\N	Maria	Nguyễn Xuân Anh	2014-12-31 00:00:00	\N	0366488454	\N	14/21 Đường số 14A, BHHA, Bình Tân	27	t	2025-09-10 16:23:38.605	2025-09-19 13:41:09.048	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
453	NK132178	\N	Giuse	Nguyễn Trường Khải	2013-11-07 00:00:00	0905990898	0905990898	0905990898	135/15 Thoại Ngọc Hầu, quận Tân Phú, HCM 	27	t	2025-09-10 16:23:45.609	2025-09-19 13:41:10.486	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1002	TQ092110	\N	Maria	Trần Mai Như Quỳnh	2009-03-10 00:00:00	\N	0931152797	0908443070	186 Thạch Lam, Phú Thạnh, Tân Phú	50	t	2025-09-10 16:23:56.469	2025-09-19 15:36:24.811	1	0.38	0.0	0.0	0.15	0.0	0.0	0.00	1	2
954	TP192542	\N	Têrêsa	Trần Nhã Phương	2019-09-12 00:00:00	\N	0909606365	0936624959	15A Lê Lư, Phú Thọ Hoà	5	t	2025-09-10 16:23:55.547	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1323	LY142164	\N	Maria	Lý Như Ý	2014-01-01 00:00:00	0342620329	0342620329	0342620329	2/7 đường số 5, phường Bình Hưng Hòa A, quận Bình Tân, HCM 	27	t	2025-09-10 16:24:01.275	2025-09-19 13:41:08.709	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
55	HA132178	\N	Maria	Hoàng Ngọc Trâm Anh	2013-12-05 00:00:00	\N	0903755507	0938355885	331 Trần Thủ Độ, Phú Thạnh, Tân Phú	31	t	2025-09-10 16:23:38.221	2025-09-19 13:41:09.053	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
63	LA142257	\N	Maria	Lê Phạm Phương Anh	2014-10-09 00:00:00	\N	0902858598	0933375680	1/17 Lê Thúc Hoạch, Phú Thọ Hòa, Tân Phú	28	t	2025-09-10 16:23:38.329	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
947	LP172349	\N	Maria	Lê Nhã Phương	2017-02-14 00:00:00	\N	0792414929	0777723988	71/3/5 Phú Thọ Hòa, Phú Thọ Hòa, Tân Phú	10	t	2025-09-10 16:23:55.426	2025-09-19 15:36:24.811	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1327	TY142112	\N	Catarina	Trần Ngọc Như Ý	2014-07-06 00:00:00	\N	0981835454	0909121820	319A Nguyễn Sơn, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:24:01.383	2025-09-19 13:41:08.721	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
1326	NY152257	\N	Maria	Nguyễn Vũ Như Ý	2015-09-29 00:00:00	\N	0978966898	\N	36 Đường số 1A, BHHA, Bình Tân	20	t	2025-09-10 16:24:01.367	2025-09-19 13:41:08.671	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1113	NT122136	\N	Martino	Nguyễn Minh Thiện	2012-06-06 00:00:00	\N	0972666058	\N	53 Lê Niệm, Phú Thạnh, Tân Phú	32	t	2025-09-10 16:23:58.068	2025-09-19 13:41:08.772	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
343	PH152521	\N	Têrêsa	Phạm Ngọc Hân	2015-07-04 00:00:00	\N	0906699787	0937134799	14/23 đường số 14A, BHHA	19	t	2025-09-10 16:23:42.729	2025-09-19 13:41:11.193	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1342	TN192562	\N	Maria	Tăng Yến Ngọc	2019-05-08 00:00:00	\N	0765200480	0989765911	59 Phan Văn Năm, Phú Thạnh	5	t	2025-09-17 15:05:16.117	2025-09-19 13:41:10.733	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	1
563	BL162581	\N	Maria	Bùi Mỹ Lan	2016-11-03 00:00:00	\N	0974322995	0336911840	93/21 đường số 14, BHHA	19	t	2025-09-10 16:23:47.835	2025-09-19 13:41:10.8	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
621	NL132547	\N	Gioan Baotixita	Nguyễn Vũ Thành Luân	2013-06-22 00:00:00	\N	0916940805	0908255088	12 Lê Khôi, Phú Thạnh	34	t	2025-09-10 16:23:48.829	2025-09-19 13:41:11.145	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
30	NA142133	\N	Giuse	Nguyễn Quốc An	2014-03-29 00:00:00	\N	0907818079	\N	3 Võ Văn Dũng, Phú Thạnh, Tân Phú	27	t	2025-09-10 16:23:37.872	2025-09-19 13:41:10.908	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
328	NH142267	\N	Maria	Nguyễn Gia Hân	2014-02-05 00:00:00	0908988293	0908988293	0908988293	Chờ phụ huynh xác nhận 	27	t	2025-09-10 16:23:42.475	2025-09-19 13:41:10.961	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
289	TD132172	\N	Phanxico Xavie	Trương Hoàng Minh Đức	2013-09-18 00:00:00	\N	0933955445	0933790766	C103 Cc Phú Thạnh, 53 Nguyễn Sơn, Phú Thạnh, Tân Phú	31	t	2025-09-10 16:23:41.812	2025-09-19 13:41:10.539	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1098	TT132141	\N	Phêrô	Trần Gia Thiên	2013-04-22 00:00:00	\N	0932151357	0909094037	192 Trần Thủ Độ, Phú Thạnh, Tân Phú	31	t	2025-09-10 16:23:57.854	2025-09-19 13:41:11.094	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
884	ĐP162251	\N	Giuse	Đinh Hải Phong	2016-06-15 00:00:00	\N	0972068779	0985383070	24/25/18 Miếu Gò Xoài, BHHA, Bình Tân	15	t	2025-09-10 16:23:54.313	2025-09-19 13:41:10.956	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
506	ĐK122171	\N	Phêrô	Đặng Lâm Gia Khiêm	2012-06-14 00:00:00	\N	0932929242	\N	31/39/20 Đường số 3 BHHA, Bình Tân	37	t	2025-09-10 16:23:46.788	2025-09-19 13:41:10.966	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	2	1
1201	LT142165	\N	Catarina	Lê Bảo Trân	\N	\N	0932610400	\N	A710 CC Phú Thạnh 53 Nguyễn Sơn, Phú Thạnh, Tân Phú	26	t	2025-09-10 16:23:59.27	2025-09-19 13:41:10.929	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
992	NQ152462	\N	Têrêsa	Nguyễn Trần Hoàng Quyên	2015-05-21 00:00:00	\N	0907205549	0903054969	76/43/5 Nguyễn Sơn, Phú Thọ Hoà, Tân Phú	18	t	2025-09-10 16:23:56.298	2025-09-19 13:41:10.493	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
37	TA172338	\N	Maria	Trần Phạm Thiên An	2017-04-26 00:00:00	\N	0938686854	0937076242	422 Phú Thọ Hoà , Phú Thọ Hoà, Tân Phú	13	t	2025-09-10 16:23:37.971	2025-09-19 13:41:10.576	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	1
139	ĐB172367	\N	Gioan Baotixita	Đinh Gia Bảo	2017-01-30 00:00:00	\N	0936330206	0903029558	31B Đường số 14A, BHHA, Bình Tân	13	t	2025-09-10 16:23:39.382	2025-09-19 13:41:10.526	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1340	LD182533	\N	Martin Vincente	Lê Minh Đức	\N	\N	\N	\N	\N	1	t	2025-09-17 15:05:16.087	2025-09-19 13:41:10.532	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1341	NA192547	\N	Maria	Nguyễn Bảo Minh Anh	2019-11-11 00:00:00	\N	0902461854	0932725212	31/16 đường số 13, BHHA	5	t	2025-09-17 15:05:16.105	2025-09-19 13:41:10.631	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
661	PM112133	\N	Giuse	Phan Đặng Đức Minh	2011-12-19 00:00:00	\N	0918933261	0975996138	66/8 Lê Cảnh Tuân, Phú Thọ Hòa, Tân Phú	40	t	2025-09-10 16:23:49.486	2025-09-19 13:41:10.686	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
177	VB152112	\N	Maria	Vũ Phúc An Bình	2015-11-02 00:00:00	\N	0938047599	\N	152/21B Bình Long, Phú Thạnh, Tân Phú	20	t	2025-09-10 16:23:39.907	2025-09-19 13:41:10.94	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1344	VT192582	\N	Anna	Võ Phương Trinh	2019-05-13 00:00:00	\N	0936104672	\N	129/8/13 Lê Lư, Phú Thọ Hoà	6	t	2025-09-17 15:05:16.14	2025-09-19 13:41:10.953	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
673	HM192533	\N	Maria	Huỳnh Hà My	2019-07-03 00:00:00	\N	0903332322	\N	544/16 Hương Lộ 2, BTĐ	6	t	2025-09-10 16:23:49.672	2025-09-19 13:41:11.021	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1343	NH192555	\N	Maria	Nguyễn Minh Huyền	2019-06-23 00:00:00	\N	0919191958	\N	69B Kênh Nước Đen, BHHA	5	t	2025-09-17 15:05:16.128	2025-09-19 13:41:11.146	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1338	PN172533	\N	Maria	Phang Mẫn Nghi	2017-02-01 00:00:00	\N	0798133286	\N	305/13/07 Lê Văn Quới, BTĐ	13	t	2025-09-17 15:05:16.055	2025-09-19 13:41:11.009	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1352	LN112530	\N	Agatha	Lê Quỳnh Như	2011-08-08 00:00:00	\N	0767061812	\N	186/62 Vườn Lài, Tân Thành	19	t	2025-09-17 15:05:16.25	2025-09-19 13:41:12.202	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	2	0
894	NP112133	\N	Phêrô	Nguyễn Trần Duy Phong	2011-09-13 00:00:00	\N	0903007020	0764213606	341/44D Lạc Long Quân F.05, 11.	42	t	2025-09-10 16:23:54.465	2025-09-21 02:38:15.758	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
33	PA162316	\N	Têrêsa	Phạm Hoàng Thục An	2016-02-19 00:00:00	\N	0908673381	0908688929	70/9 Đình Nghi Xuân, BTĐ, Bình Tân	19	t	2025-09-10 16:23:37.918	2025-09-21 09:16:54.286	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1353	HS092577	\N	Tômasô	Hoàng Thái Sang	2009-04-26 00:00:00	\N	0909874920	0909192441	23/1 Đường số 14B, BHHA, Bình Tân	50	t	2025-09-17 15:05:16.262	2025-09-19 13:41:12.199	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
113	LA132150	\N	Maria	Lê Đoàn Hồng Ân	2013-03-16 00:00:00	\N	0909483149	\N	326/6 Thạch Lam, Phú Thọ Hoà, Tân Phú	30	t	2025-09-10 16:23:39.003	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1354	NT072544	\N	Antôn	Nguyễn Bảo Thiên	2007-10-05 00:00:00	\N	0913943113	0364646056	184 Hiền Vương, Phú Thạnh	51	t	2025-09-17 15:05:16.276	2025-09-19 13:41:12.213	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
1350	NY132566	\N	Maria	Nguyễn Phạm Như Ý	2013-09-10 00:00:00	\N	0901333374	0931333374	61A Lê Sao, Phú Thạnh	19	t	2025-09-17 15:05:16.219	2025-09-21 09:18:50.285	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
1339	VT072177	\N	Maria	Vũ Ngọc Phương Trinh	2007-06-12 00:00:00	\N	0903886493	\N	40 Trần Thủ Độ, Phú Thạnh, Tân Phú 	51	t	2025-09-17 15:05:16.073	2025-09-19 13:41:10.993	1	0.11	0.0	0.0	0.04	0.0	0.0	0.00	1	1
1345	HD182546	\N	Anna	Huỳnh Kim Ánh Dương	2018-07-29 00:00:00	\N	0906635112	0932350377	133/17 Đường số 1, BTĐ	4	t	2025-09-17 15:05:16.152	2025-09-19 13:41:11.014	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
23	NA112145	\N	Maria	Nguyễn Lê Triều An	2011-02-08 00:00:00	\N	0902986991	0902402712	337/6 Trần Thủ Độ, Phú Thạnh, Tân Phú	38	t	2025-09-10 16:23:37.776	2025-09-19 13:40:25.402	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1351	TA132583	\N	Maria	Trương Thị Kim Anh	2013-11-22 00:00:00	\N	0973434678	0907889179	138/2 Phú Thọ Hoà, Phú Thọ Hoà	19	t	2025-09-17 15:05:16.237	2025-09-21 09:19:01.526	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
6	DA192524	\N	Maria	Dương Hoàng Vân An	2019-03-25 00:00:00	\N	0772666975	0902686891	247 Quách Đình Bảo, Phú Thạnh	5	t	2025-09-10 16:23:37.532	2025-09-19 15:36:24.812	1	0.27	0.0	0.0	0.11	0.0	0.0	0.00	1	1
19	NA162343	\N	Têrêsa	Nguyễn Hoài An	2016-03-15 00:00:00	\N	0906506889	\N	162 Nguyễn Sơn, Phú Thọ Hòa, Tân Phú	15	t	2025-09-10 16:23:37.72	2025-09-19 13:40:25.448	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
108	VA122283	\N	Têrêsa	Võ Trần Ngọc Anh	2012-02-22 00:00:00	\N	9095042012	0909044911	278 Hòa Bình, Hiệp Tân, quận Tân Phú	30	t	2025-09-10 16:23:38.942	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
4	CA172317	\N	Giuse	Cao Kiện An	2017-06-21 00:00:00	\N	0918738876	0902632661	285/110 Lê Văn Quới, BTĐ, Bình Tân	10	t	2025-09-10 16:23:37.499	2025-09-19 15:36:24.812	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
1347	NH172532	\N	\N	Nguyễn Bảo Gia Hưng	2017-08-07 00:00:00	\N	0901333374	0931333374	61A Lê Sao, Phú Thạnh	13	t	2025-09-17 15:05:16.178	2025-09-19 13:41:11.039	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1349	PT172574	\N	Maria	Phạm Anh Thư	2017-09-15 00:00:00	\N	0974384554	0961863500	479/6/6 Hương Lộ 2, BTĐ	13	t	2025-09-17 15:05:16.207	2025-09-19 13:41:11.143	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1346	PQ172534	\N	Anna	Phạm Hồng Quyên	2017-04-17 00:00:00	\N	0906704430	0708197137	40/20 Miếu Gò Xoài, BHHA	13	t	2025-09-17 15:05:16.166	2025-09-19 13:41:11.091	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
1348	NN162565	\N	Phêrô	Nguyễn Anh Nhật	2016-07-18 00:00:00	\N	0866071189	0917392428	86 Phú Thọ Hoà, Phú Thọ Hoà	13	t	2025-09-17 15:05:16.194	2025-09-19 13:41:11.093	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	1	0
13	LA162239	\N	Maria	Lê Mỹ An	2016-09-29 00:00:00	\N	0987140909	\N	76/4 Miếu Bình Đông, BHHA, Bình Tân	16	t	2025-09-10 16:23:37.633	2025-09-19 13:40:25.593	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	1	0
39	VA162337	\N	Giuse	Võ Hoàng Bình An	2016-09-01 00:00:00	\N	0703474118	\N	136 Lê Niệm, Phú Thạnh, Tân Phú	11	t	2025-09-10 16:23:38.01	2025-09-19 13:40:25.609	1	0.16	0.0	0.0	0.06	0.0	0.0	0.00	2	0
8	ĐA132146	\N	Têrêsa	Đinh Lê Hoài An	2013-11-23 00:00:00		0934129369	0985447177	119 BHHA, Bình Tân, TPHCM	30	f	2025-09-10 16:23:37.556	2025-09-21 14:14:55.679	1	0.00	0.0	0.0	0.00	0.0	0.0	0.00	0	0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password_hash, role, saint_name, full_name, birth_date, phone_number, address, department_id, is_active, created_at, updated_at) FROM stdin;
1	admin	$2b$12$YRHd9vZQhJx73xP04cRqSuStIsyyp.x1.RQgg9YUYhXupyUQlbQ4C	ban_dieu_hanh	Giuse	Administrator	\N	\N	\N	\N	t	2025-09-10 16:14:24.002	2025-09-10 16:14:24.002
4	0902568643	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Martino	Trần Công Hải	1995-08-07 00:00:00	0902568643	119 Lê Thiệt, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:38.776	2025-09-10 16:15:38.776
5	0348487779	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Lucia	Phạm Hoàng Lan Chi	1997-10-14 00:00:00	0348487779	230C Lê Lâm, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:38.796	2025-09-10 16:15:38.796
6	0932681906	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Teresa	Nguyễn Lê Quỳnh Thảo Ái	2005-03-09 00:00:00	0932681906	127/2/40 Lê Thúc Hoạch, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:38.813	2025-09-10 16:15:38.813
7	0933050019	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Teresa	Nguyễn Lê Quỳnh Ngọc Ái	2005-03-09 00:00:00	0933050019	127/2/40 Lê Thúc Hoạch, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:38.83	2025-09-10 16:15:38.83
9	0938317475	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	G.B	Ngô Thái An	2003-09-09 00:00:00	0938317475	6 Nguyễn Nhữ Lãm, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:38.857	2025-09-10 16:15:38.857
10	0784450665	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Micae	Bàng Thành Anh	2000-05-28 00:00:00	0784450665	437/36 Hương Lộ 2, P.Bình Trị Đông, Q.Bình Tân	1	t	2025-09-10 16:15:38.872	2025-09-10 16:15:38.872
11	0939025981	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Thị Phương Anh	1996-02-07 00:00:00	0939025981	30/9 đường số 5D, P. BHHA, Q. Bình Tân	1	t	2025-09-10 16:15:38.887	2025-09-10 16:15:38.887
12	0334864681	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Matta	Phạm Hoàng Lan Anh	2002-09-25 00:00:00	0334864681	230C Lê Lâm, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:38.902	2025-09-10 16:15:38.902
14	0373618547	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Phạm Quỳnh Anh	2005-08-28 00:00:00	0373618547	84/1/18A Tây Lân, P.Bình Trị Đông A, Q.Bình Tân	1	t	2025-09-10 16:15:38.934	2025-09-10 16:15:38.934
15	0779158158	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Phaolo	Nguyễn Tuấn Anh	1998-09-26 00:00:00	0779158158	115 Tân Quý, P.Tân Quý, Q.Tân Phú	1	t	2025-09-10 16:15:38.947	2025-09-10 16:15:38.947
16	0937830433	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Loan Anh	1999-10-16 00:00:00	0937830433	8 đường số 3, P.11, Q.6	1	t	2025-09-10 16:15:38.959	2025-09-10 16:15:38.959
18	0933376708	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria Rosa	Phạm Gia Bảo	2005-08-21 00:00:00	0933376708	81 Vườn Lài, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:38.994	2025-09-10 16:15:38.994
19	0865745284	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Đaminh	Nguyễn Quốc Cường	1995-08-07 00:00:00	0865745284	33 Lê Quốc Trinh, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.02	2025-09-10 16:15:39.02
20	0773185483	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Nguyễn Hoàng Duy	2000-09-16 00:00:00	0773185483	63/16 đường 13A, P.Bình Hưng Hoà, Q.Bình Tân	1	t	2025-09-10 16:15:39.036	2025-09-10 16:15:39.036
21	0969624359	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Thị Minh Duyên	2005-07-22 00:00:00	0969624359	222 đường số 8, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.062	2025-09-10 16:15:39.062
22	0908496662	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Nguyễn Ngọc Tiến Đạt	2001-08-26 00:00:00	0908496662	58K Văn Cao, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.08	2025-09-10 16:15:39.08
23	0932173500	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Trần Thị Kiều Giang	1999-11-05 00:00:00	0932173500	119 Lê Thiệt, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.097	2025-09-10 16:15:39.097
24	0964453859	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Anna Maria	Đinh Lê Phương Hạnh	1999-06-24 00:00:00	0964453859	C6-28, 36 Tân Thắng, CC Ruby, P.Tân Sơn Nhì	1	t	2025-09-10 16:15:39.113	2025-09-10 16:15:39.113
25	0908025919	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Cecilia	Trần Hồng Hạnh	2001-10-29 00:00:00	0908025919	208 đường số 8, P.BHHA	1	t	2025-09-10 16:15:39.14	2025-09-10 16:15:39.14
26	0901487327	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Teresa	Bùi Thanh Hằng	2003-02-02 00:00:00	0901487327	482 Xô Viết Nghệ Tĩnh, P.Thạnh Mỹ Tây, Q.Bình Thạnh	1	t	2025-09-10 16:15:39.156	2025-09-10 16:15:39.156
28	0904539115	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria Teresa	Phạm Gia Khiêm	2004-07-29 00:00:00	0904539115	81 Vườn Lài, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.193	2025-09-10 16:15:39.193
29	0333914986	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Cecilia	Vũ Nguyễn An Lành	2002-03-29 00:00:00	0333914986	337/16/2 Trần Thủ Độ, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:39.207	2025-09-10 16:15:39.207
31	0398852909	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Lê Nguyễn Ngọc Linh	2005-03-15 00:00:00	0398852909	35A đường 5B, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.237	2025-09-10 16:15:39.237
32	0903616705	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Trịnh Bảo Long	2005-07-06 00:00:00	0903616705	17/27A đường số 3, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.252	2025-09-10 16:15:39.252
33	0793511532	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Đaminh	Nguyễn Ngọc Minh	1996-10-09 00:00:00	0793511532	18/6 Trung Lang, P.Bảy Hiền	1	t	2025-09-10 16:15:39.265	2025-09-10 16:15:39.265
34	0866429646	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Trịnh Nhật Minh	2005-01-10 00:00:00	0866429646	730/1/2/109 Hương Lộ 2, P.Bình Trị Đông A, Q.Bình Tân	1	t	2025-09-10 16:15:39.28	2025-09-10 16:15:39.28
3	0792396156	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Giuse	Vũ Đào Nhật Minh	1995-04-02 00:00:00	0792396156	186 Lê Lư, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:38.76	2025-09-10 16:26:07.207
17	0903842290	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Giuse	Vũ Nguyên Bá	1997-05-28 00:00:00	0903842290	151/73/22 Liên khu 4-5, P.Bình Tân	1	t	2025-09-10 16:15:38.973	2025-09-10 16:26:13.388
27	0936740450	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Maria	Châu Ngọc Hân	1999-12-16 00:00:00	0936740450	26/10 đường số 5, P.Bình Hưng Hoà A, Q.Tân Phú	1	t	2025-09-10 16:15:39.173	2025-09-10 16:26:50.387
8	0908907011	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Anna	Trần Ngọc Hoài An	2002-04-26 00:00:00	0908907011	92/1/9 đường số 6, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:38.843	2025-09-10 16:27:13.31
13	0378003742	$2b$12$od3X8xbm6WpCQvUOmWAjHuh8omf8dnWWtgCvZ6pc3TyJn/LZSMXxG	giao_ly_vien	Maria	Phạm Thị Kim Anh	2002-05-11 00:00:00	0378003742	221/28D Vườn Lài, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:38.916	2025-09-16 07:37:29.008
30	0774973690	$2b$12$CP08SGDyEDiEbaXJ4HhBw.FxxICyczTiZR1XiVYt983B3aQZ/3eNa	giao_ly_vien	Maria	Vũ Hoàng Phương Linh	1997-10-15 00:00:00	0774973690	298/11 Vườn Lài, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.22	2025-09-19 02:16:53.62
35	0901993907	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Teresa	Nguyễn Trần Kim Ngân	1999-03-03 00:00:00	0901993907	240 Hà Duy Phiên, Bình Mỹ, Củ Chi	1	t	2025-09-10 16:15:39.295	2025-09-10 16:15:39.295
36	0703442793	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria Teresa	Vũ Ngọc Ngân	2004-08-14 00:00:00	0703442793	40 Trần Thủ Độ, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:39.313	2025-09-10 16:15:39.313
37	0708107910	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Lucia	Trần Nguyễn Kim Ngọc	1996-05-29 00:00:00	0708107910	43 Nguyễn Nhữ Lãm, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.324	2025-09-10 16:15:39.324
38	0969440256	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Vương Thị Bích Ngọc	2004-12-22 00:00:00	0969440256	260A đường số 8, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.339	2025-09-10 16:15:39.339
39	0972746724	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	G.B	Phạm Công Nguyên	2001-11-03 00:00:00	0972746724	135/11 Lê Văn Quới, P.Bình Trị Đông, Q.Bình Tân	1	t	2025-09-10 16:15:39.353	2025-09-10 16:15:39.353
40	0352473489	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Lương Thị Thuý Nhài	2004-08-07 00:00:00	0352473489	69 Nguyễn Đỗ Cung, P.Tây Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:39.365	2025-09-10 16:15:39.365
42	0934110390	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Thuỳ Nhung	2002-10-11 00:00:00	0934110390	14B đường số 9, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.396	2025-09-10 16:15:39.396
43	0932792062	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Nguyễn Ngọc Thành Phát	2005-07-27 00:00:00	0932792062	58K Văn Cao, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.406	2025-09-10 16:15:39.406
44	0962394976	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Nguyễn Hoàng Thanh Phong	2004-11-02 00:00:00	0962394976	13 đường số 19A, P.Bình Hưng Hoà A, Q.Tân Phú	1	t	2025-09-10 16:15:39.421	2025-09-10 16:15:39.421
45	0981981614	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Vincente	Vũ Đức Phương	2004-03-16 00:00:00	0981981614	468 Hương Lộ 2, P.Bình Trị Đông, Q.Bình Tân	1	t	2025-09-10 16:15:39.434	2025-09-10 16:15:39.434
46	0978808738	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Ngô Thị Phương	2003-07-07 00:00:00	0978808738	92 đường số 8, P. Bình Hưng Hòa A, Q. Bình Tân	1	t	2025-09-10 16:15:39.448	2025-09-10 16:15:39.448
47	0704750663	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Toma	Nguyễn Thành Quang	1996-05-22 00:00:00	0704750663	17/2/5 đường số 3A, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.462	2025-09-10 16:15:39.462
48	0965585950	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Teresa	Phạm Như Quỳnh	1999-01-25 00:00:00	0965585950	33/6A đường 16A, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.476	2025-09-10 16:15:39.476
49	0934193753	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Thuỵ Song Quỳnh	1997-07-30 00:00:00	0934193753	33 Lê Quốc Trinh, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.493	2025-09-10 16:15:39.493
50	0839784156	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Anna	Huỳnh Mai Thuý Quỳnh	2003-01-09 00:00:00	0839784156	34 Dương Thiệu Tước, P.Tân Sơn Nhì, Q.Tân Phú	1	t	2025-09-10 16:15:39.512	2025-09-10 16:15:39.512
51	0852389872	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Trần Nhật Sơn	1999-05-22 00:00:00	0852389872	21 Đình Tân Khai, P.Bình Trị Đông	1	t	2025-09-10 16:15:39.528	2025-09-10 16:15:39.528
52	0797401044	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Ngọc Tiền	2001-10-12 00:00:00	0797401044	387 Vườn Lài, P.Phú Thọ Hoà, Q.tân Phú	1	t	2025-09-10 16:15:39.544	2025-09-10 16:15:39.544
53	0702107998	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Phanxico Xavie	Trang Sĩ Tín	1999-07-21 00:00:00	0702107998	20/16/5 đường số 3, P.Bình Hưng Hoà A, Q.BìnhTân	1	t	2025-09-10 16:15:39.56	2025-09-10 16:15:39.56
54	0773605769	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	GioaKim	Phạm Huy Toàn	2003-08-20 00:00:00	0773605769	81 Đỗ Bí, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:39.574	2025-09-10 16:15:39.574
55	0814499991	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Nguyễn Ngọc Tuân	2003-04-10 00:00:00	0814499991	280 đường số 8, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.592	2025-09-10 16:15:39.592
56	0985287664	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Đặng Anh Tuấn	1989-10-29 00:00:00	0985287664	201/29 Mã Lò, P.Bình Trị Đông A, Q.Bình Tân	1	t	2025-09-10 16:15:39.608	2025-09-10 16:15:39.608
59	0938190269	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Thị Thanh Thanh	2002-07-29 00:00:00	0938190269	26/35 đường số 1, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.654	2025-09-10 16:15:39.654
61	0981414157	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	G.B	Nguyễn Minh Thành	2002-11-12 00:00:00	0981414157	38/10 đường số 1, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.69	2025-09-10 16:15:39.69
62	0707311434	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Matta	Nguyễn Thanh Thảo	1995-12-16 00:00:00	0707311434	387 Vườn Lài, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.706	2025-09-10 16:15:39.706
63	0364161319	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Đỗ Minh Thuỳ	2000-04-18 00:00:00	0364161319	18/10 đường 1B, P. Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.729	2025-09-10 16:15:39.729
65	0768729632	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Anna	Lại Thị Thu Trang	1997-11-26 00:00:00	0768729632	135/39 Lê Văn Quới, P.Bình Trị Đông, Q.Bình Tân	1	t	2025-09-10 16:15:39.759	2025-09-10 16:15:39.759
66	0912433665	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Đinh Trần Quỳnh Trâm	2002-12-17 00:00:00	0912433665	698 Luỹ Bán Bích, P.Tân Thành, Q.Tân Phú	1	t	2025-09-10 16:15:39.774	2025-09-10 16:15:39.774
67	0858803041	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Trần Huỳnh Yến Vy	2001-09-16 00:00:00	0858803041	21 Đình Tân Khai, P.Bình Trị Đông	1	t	2025-09-10 16:15:39.79	2025-09-10 16:15:39.79
60	0708211458	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Maria	Vũ Ngọc Đan Thanh	2001-04-20 00:00:00	0708211458	88 Bùi Thị Xuân, P.Tân Sơn Hoà, Q.Tân Bình	1	t	2025-09-10 16:15:39.67	2025-09-10 16:26:23.812
64	0343648760	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Maria	Nguyễn Thị Ngọc Thuý	1998-12-22 00:00:00	0343648760	490/49/12 Hương Lộ 2, P.Bình Trị Đông, Q.Bình Tân	1	t	2025-09-10 16:15:39.745	2025-09-10 16:26:31.356
58	0339371828	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Cecilia	Nguyễn Ngọc Thiên Thanh	2004-07-06 00:00:00	0339371828	127/71/1 Lê Thúc Hoạch, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.641	2025-09-10 16:27:02.183
41	0792193204	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Teresa	Trịnh Xuân Nhi	2002-11-22 00:00:00	0792193204	5/9 Lê Cảnh Tuân, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.381	2025-09-10 16:27:07.42
68	0703637119	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Đặng Nguyên Tường Vy	2002-08-04 00:00:00	0703637119	6C Phạm Vấn, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.806	2025-09-10 16:15:39.806
69	0393442257	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Ngọc Thanh Xuân	2004-12-15 00:00:00	0393442257	248 Lê Niệm, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:39.82	2025-09-10 16:15:39.82
70	0931342706	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Thị Như Ý	2005-06-27 00:00:00	0931342706	20/71 đường số 1, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.836	2025-09-10 16:15:39.836
71	0931440982	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Hoàng Quế Anh	2007-02-07 00:00:00	0931440982	266/13/14 Phú Thọ Hoà, P.Phú Thọ Hoà	1	t	2025-09-10 16:15:39.85	2025-09-10 16:15:39.85
72	0333855450	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Bùi Thị Ngọc Bích	2004-10-02 00:00:00	0333855450	18/3 Hoàng Ngọc Phách, P.Phú Thọ Hoà	1	t	2025-09-10 16:15:39.862	2025-09-10 16:15:39.862
73	0936889585	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Phaolo	Nguyễn Cường	2008-04-17 00:00:00	0936889585	8 đường số 5, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.878	2025-09-10 16:15:39.878
74	0936514170	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Đoàn Thị Ngọc Dung	2007-11-29 00:00:00	0936514170	a5/20a6 tổ 11, ấp 1B, xã Vĩnh Lộc B	1	t	2025-09-10 16:15:39.892	2025-09-10 16:15:39.892
75	0937186802	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Anne	Hồ Nguyễn Hà Giang	2007-10-24 00:00:00	0937186802	101 đường số 22, P.BHH, Q.Bình Tân	1	t	2025-09-10 16:15:39.907	2025-09-10 16:15:39.907
76	0904810447	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giacobe	Trần Xuân Hà	2007-04-24 00:00:00	0904810447	104/11 đường số 18, P.BHH	1	t	2025-09-10 16:15:39.921	2025-09-10 16:15:39.921
77	0703780482	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Ngọc Bảo Hân	2008-07-30 00:00:00	0703780482	26/35 đường số 1, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.934	2025-09-10 16:15:39.934
78	0769791806	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Trần Huy Hoàng	2005-06-18 00:00:00	0769791806	40/28A đường số 16, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.945	2025-09-10 16:15:39.945
79	0903655161	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Vincente	Nguyễn Vũ Quốc Hùng	2007-05-05 00:00:00	0903655161	270 Thoại Ngọc Hầu	1	t	2025-09-10 16:15:39.957	2025-09-10 16:15:39.957
80	0346175070	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	G.B	Vũ Nguyễn Thịnh Khang	2003-10-28 00:00:00	0346175070	337/16/2 Trần Thủ Độ, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:39.971	2025-09-10 16:15:39.971
81	0779632997	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Vincente	Chu Hoàng Khoa	1999-10-19 00:00:00	0779632997	344 Phú Thọ Hoà, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:39.986	2025-09-10 16:15:39.986
82	0908597924	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Thị Thảo Liên	2003-10-17 00:00:00	0908597924	124 Lê Lâm, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:40.002	2025-09-10 16:15:40.002
83	0921453614	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Nguyễn Xuân  Lộc	2001-11-08 00:00:00	0921453614	58 Lê Sao phường Phú Thạnh quận Tân Phú	1	t	2025-09-10 16:15:40.018	2025-09-10 16:15:40.018
84	0903189036	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Phạm Thị Kim Ngân	2002-07-18 00:00:00	0903189036	33/13A, đường 16A, P.BHHA, Q.Bình Tân	1	t	2025-09-10 16:15:40.031	2025-09-10 16:15:40.031
85	0902645657	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Châu Tuấn Nghĩa	2005-10-24 00:00:00	0902645657	55 Văn Cao, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:40.044	2025-09-10 16:15:40.044
86	0902799112	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Phạm Ngọc  Phương	1994-06-26 00:00:00	0902799112	188 Lê Trọng Tấn, P.Tây Thạnh	1	t	2025-09-10 16:15:40.06	2025-09-10 16:15:40.06
87	0912781826	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	G.B	Nguyễn Anh Tài	2005-09-06 00:00:00	0912781826	387 Vườn Lài, P.Phú Thọ Hoà, Q.tân Phú	1	t	2025-09-10 16:15:40.072	2025-09-10 16:15:40.072
88	0764327422	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Giuse	Đỗ Trọng Tấn	2006-04-22 00:00:00	0764327422	145 Lê Quốc Trinh, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:40.084	2025-09-10 16:15:40.084
89	0339931628	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Micae	Nguyễn Minh Toàn	2007-01-03 00:00:00	0339931628	127/71/1 Lê Thúc Hoạch, P.Phú Thọ Hoà, Q.Tân Phú	1	t	2025-09-10 16:15:40.098	2025-09-10 16:15:40.098
90	0908854296	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Gioan	Bàng Anh Tuấn	2007-08-22 00:00:00	0908854296	437/36 Hương Lộ 2, P.Bình Trị Đông, Q.Bình Tân	1	t	2025-09-10 16:15:40.113	2025-09-10 16:15:40.113
91	0938548076	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Antôn	Hà Thúc Long Thành	2007-04-12 00:00:00	0938548076	B10/10 Võ Văn Vân, Ấp 2, xã Vĩnh Lộc B	1	t	2025-09-10 16:15:40.124	2025-09-10 16:15:40.124
92	0976400133	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Teresa	Nguyễn Thị Thanh Thảo	2004-03-07 00:00:00	0976400133	362 Bình Trị Đông, P.Bình Trị Đông	1	t	2025-09-10 16:15:40.135	2025-09-10 16:15:40.135
93	0772401510	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria Goretti	Phạm Võ Thiên Thơ	2007-10-15 00:00:00	0772401510	99 đường số 14, P.BHHA, Q.Bình Tân	1	t	2025-09-10 16:15:40.15	2025-09-10 16:15:40.15
94	0385288099	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Rosa	Vũ Huyền Trang	2000-09-28 00:00:00	0385288099	30/21/5 Tứ Hải, P.6, Q.Tân Bình	1	t	2025-09-10 16:15:40.162	2025-09-10 16:15:40.162
95	0984753543	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Teresa	Phạm Quỳnh Trang	2006-11-20 00:00:00	0984753543	84/1/18A Tây Lân, P.Bình Trị Đông A, Q.Bình Tân	1	t	2025-09-10 16:15:40.176	2025-09-10 16:15:40.176
96	0357377064	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Ngọc Trân	2002-01-29 00:00:00	0357377064	490/49/12 Hương Lộ 2, P.Bình Trị Đông, Q.Bình Tân	1	t	2025-09-10 16:15:40.196	2025-09-10 16:15:40.196
97	0865179400	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Phero	Trần Thành Trung	2000-08-28 00:00:00	0865179400	127/70 Lê Thúc Hoạch, P.Phú Thọ Hoà	1	t	2025-09-10 16:15:40.209	2025-09-10 16:15:40.209
98	0931401827	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Maria	Nguyễn Ngọc Thuỵ Vy	2007-11-20 00:00:00	0931401827	36/1A đường số 14, P.BHHA, Q.Bình Tân	1	t	2025-09-10 16:15:40.223	2025-09-10 16:15:40.223
99	0909579612	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	giao_ly_vien	Cecilia	Nguyễn Cát Tường Vy	2001-12-25 00:00:00	0909579612	Lô C, T4.C7, CC Phú Thạnh, 53 Nguyễn Sơn, P.Phú Thạnh	1	t	2025-09-10 16:15:40.237	2025-09-10 16:15:40.237
2	0938258946	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Phaolo	Hoàng Minh Tuấn	1989-08-25 00:00:00	0938258946	56 Lê Niệm, P.Phú Thạnh, Q.Tân Phú	1	t	2025-09-10 16:15:38.741	2025-09-10 16:15:59.223
57	0707030378	$2b$10$MJvpaIuq1OYUv4PQKsH.P.xskb.ejAHKi7wQ8JdZpvz49JO8rFp2y	ban_dieu_hanh	Phero	Nguyễn Tuấn	1997-12-01 00:00:00	0707030378	8 đường số 5, P.Bình Hưng Hoà A, Q.Bình Tân	1	t	2025-09-10 16:15:39.626	2025-09-10 16:16:16.366
104	0988358081	$2b$10$X2J9R86IFUlY8dGRTTP0ou1q5Jls0FRQoWLvoLhu/YKvgUpcLkwDm	ban_dieu_hanh	Sr	Ánh  Hoa	2000-01-01 00:00:00	0988358081	159 Lê Niệm, Phú Thạnh	1	t	2025-09-14 14:03:59.578	2025-09-14 14:04:11.632
103	0364070464	$2b$10$X2J9R86IFUlY8dGRTTP0ou1q5Jls0FRQoWLvoLhu/YKvgUpcLkwDm	ban_dieu_hanh	Sr	Bích Thu	2000-01-01 00:00:00	0364070464	159 Lê Niệm, Phú Thạnh	1	t	2025-09-14 14:03:59.561	2025-09-14 14:04:14.632
102	0379500738	$2b$10$X2J9R86IFUlY8dGRTTP0ou1q5Jls0FRQoWLvoLhu/YKvgUpcLkwDm	ban_dieu_hanh	Sr	Hoài	2000-01-01 00:00:00	0379500738	159 Lê Niệm, Phú Thạnh	1	t	2025-09-14 14:03:59.547	2025-09-14 14:04:20.123
105	0703474118	$2b$10$X2J9R86IFUlY8dGRTTP0ou1q5Jls0FRQoWLvoLhu/YKvgUpcLkwDm	ban_dieu_hanh	Sr	Kiều  Trinh	2000-01-01 00:00:00	0703474118	159 Lê Niệm, Phú Thạnh	1	t	2025-09-14 14:03:59.598	2025-09-14 14:04:23.933
101	0903583894	$2b$10$X2J9R86IFUlY8dGRTTP0ou1q5Jls0FRQoWLvoLhu/YKvgUpcLkwDm	ban_dieu_hanh	Sr	Kim  Huệ	2000-01-01 00:00:00	0903583894	159 Lê Niệm, Phú Thạnh	1	t	2025-09-14 14:03:59.532	2025-09-14 14:04:27.192
100	0399962577	$2b$10$X2J9R86IFUlY8dGRTTP0ou1q5Jls0FRQoWLvoLhu/YKvgUpcLkwDm	ban_dieu_hanh	Sr	Nguyệt  Hằng	2000-01-01 00:00:00	0399962577	159 Lê Niệm, Phú Thạnh	1	t	2025-09-14 14:03:59.509	2025-09-14 14:04:31.217
\.


--
-- Data for Name: weekly_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weekly_stats (id, week_start_date, week_end_date, department_id, class_id, total_students, thursday_attendance, sunday_attendance, created_at) FROM stdin;
\.


--
-- Name: academic_years_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.academic_years_id_seq', 1, true);


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_id_seq', 2845, true);


--
-- Name: class_teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.class_teachers_id_seq', 105, true);


--
-- Name: classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.classes_id_seq', 51, true);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departments_id_seq', 4, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_id_seq', 1354, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 105, true);


--
-- Name: weekly_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.weekly_stats_id_seq', 1, false);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: academic_years academic_years_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_years
    ADD CONSTRAINT academic_years_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: class_teachers class_teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_teachers
    ADD CONSTRAINT class_teachers_pkey PRIMARY KEY (id);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weekly_stats weekly_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_stats
    ADD CONSTRAINT weekly_stats_pkey PRIMARY KEY (id);


--
-- Name: academic_years_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX academic_years_name_key ON public.academic_years USING btree (name);


--
-- Name: attendance_student_id_attendance_date_attendance_type_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX attendance_student_id_attendance_date_attendance_type_key ON public.attendance USING btree (student_id, attendance_date, attendance_type);


--
-- Name: class_teachers_class_id_user_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX class_teachers_class_id_user_id_key ON public.class_teachers USING btree (class_id, user_id);


--
-- Name: departments_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX departments_name_key ON public.departments USING btree (name);


--
-- Name: students_student_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX students_student_code_key ON public.students USING btree (student_code);


--
-- Name: users_username_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);


--
-- Name: attendance attendance_marked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_marked_by_fkey FOREIGN KEY (marked_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: class_teachers class_teachers_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_teachers
    ADD CONSTRAINT class_teachers_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: class_teachers class_teachers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_teachers
    ADD CONSTRAINT class_teachers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: classes classes_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: students students_academic_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_academic_year_id_fkey FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: students students_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: users users_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: weekly_stats weekly_stats_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_stats
    ADD CONSTRAINT weekly_stats_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: weekly_stats weekly_stats_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_stats
    ADD CONSTRAINT weekly_stats_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict KVr9oJKxPlh87P38OPaEUbkQ5Gq8fWP808edZfhJu7bDAxMSTBPUqpjAigBkfkw

