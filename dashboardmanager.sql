--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.9

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO postgres;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO postgres;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_user_group_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_group_roles (
    auth_user_id bigint NOT NULL,
    group_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.auth_user_group_roles OWNER TO postgres;

--
-- Name: auth_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_users (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    password character varying,
    idno character varying,
    uuid character varying,
    tp_account character varying,
    member_type character varying,
    verify_level character varying,
    is_admin boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_whitelist boolean DEFAULT false,
    is_blacked boolean DEFAULT false,
    expired_at timestamp with time zone,
    created_at timestamp with time zone,
    login_at timestamp with time zone,
    CONSTRAINT chk_auth_users_email CHECK (((email)::text ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text))
);


ALTER TABLE public.auth_users OWNER TO postgres;

--
-- Name: auth_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auth_users_id_seq OWNER TO postgres;

--
-- Name: auth_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_users_id_seq OWNED BY public.auth_users.id;


--
-- Name: component_charts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.component_charts (
    index character varying NOT NULL,
    color character varying[],
    types character varying[],
    unit character varying
);


ALTER TABLE public.component_charts OWNER TO postgres;

--
-- Name: component_maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.component_maps (
    id bigint NOT NULL,
    index character varying NOT NULL,
    title character varying NOT NULL,
    type character varying NOT NULL,
    source character varying NOT NULL,
    size character varying,
    icon character varying,
    paint json,
    property json
);


ALTER TABLE public.component_maps OWNER TO postgres;

--
-- Name: component_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.component_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.component_maps_id_seq OWNER TO postgres;

--
-- Name: component_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.component_maps_id_seq OWNED BY public.component_maps.id;


--
-- Name: components; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.components (
    id bigint NOT NULL,
    index character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.components OWNER TO postgres;

--
-- Name: components_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.components_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.components_id_seq OWNER TO postgres;

--
-- Name: components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.components_id_seq OWNED BY public.components.id;


--
-- Name: contributors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contributors (
    id bigint NOT NULL,
    user_id character varying NOT NULL,
    user_name character varying NOT NULL,
    image text,
    link text NOT NULL,
    identity character varying,
    description text,
    include boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.contributors OWNER TO postgres;

--
-- Name: contributors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contributors_id_seq OWNER TO postgres;

--
-- Name: contributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contributors_id_seq OWNED BY public.contributors.id;


--
-- Name: dashboard_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dashboard_groups (
    dashboard_id bigint NOT NULL,
    group_id bigint NOT NULL
);


ALTER TABLE public.dashboard_groups OWNER TO postgres;

--
-- Name: dashboards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dashboards (
    id bigint NOT NULL,
    index character varying NOT NULL,
    name character varying NOT NULL,
    components integer[],
    icon text,
    updated_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dashboards OWNER TO postgres;

--
-- Name: dashboards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dashboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dashboards_id_seq OWNER TO postgres;

--
-- Name: dashboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dashboards_id_seq OWNED BY public.dashboards.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying,
    is_personal boolean DEFAULT false,
    create_by bigint
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_id_seq OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidents (
    id bigint NOT NULL,
    type text,
    description text,
    distance numeric,
    latitude numeric,
    longitude numeric,
    place text,
    "time" timestamp with time zone,
    status text
);


ALTER TABLE public.incidents OWNER TO postgres;

--
-- Name: incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incidents_id_seq OWNER TO postgres;

--
-- Name: incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incidents_id_seq OWNED BY public.incidents.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.issues (
    id bigint NOT NULL,
    title character varying NOT NULL,
    user_name character varying NOT NULL,
    user_id character varying NOT NULL,
    context text,
    description text NOT NULL,
    decision_desc text,
    status character varying NOT NULL,
    updated_by character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.issues OWNER TO postgres;

--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.issues_id_seq OWNER TO postgres;

--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.issues_id_seq OWNED BY public.issues.id;


--
-- Name: query_charts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.query_charts (
    index character varying NOT NULL,
    history_config json,
    map_config_ids integer[],
    map_filter json,
    time_from character varying,
    time_to character varying,
    update_freq integer,
    update_freq_unit character varying,
    source character varying,
    short_desc text,
    long_desc text,
    use_case text,
    links text[],
    contributors text[],
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    query_type character varying,
    query_chart text,
    query_history text,
    city text NOT NULL
);


ALTER TABLE public.query_charts OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying,
    access_control boolean DEFAULT false,
    modify boolean DEFAULT false,
    read boolean DEFAULT false
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: view_points; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.view_points (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    center_x numeric,
    center_y numeric,
    zoom numeric,
    pitch numeric,
    bearing numeric,
    name text,
    point_type text
);


ALTER TABLE public.view_points OWNER TO postgres;

--
-- Name: view_points_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.view_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.view_points_id_seq OWNER TO postgres;

--
-- Name: view_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.view_points_id_seq OWNED BY public.view_points.id;


--
-- Name: auth_users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users ALTER COLUMN id SET DEFAULT nextval('public.auth_users_id_seq'::regclass);


--
-- Name: component_maps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_maps ALTER COLUMN id SET DEFAULT nextval('public.component_maps_id_seq'::regclass);


--
-- Name: components id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.components ALTER COLUMN id SET DEFAULT nextval('public.components_id_seq'::regclass);


--
-- Name: contributors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contributors ALTER COLUMN id SET DEFAULT nextval('public.contributors_id_seq'::regclass);


--
-- Name: dashboards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboards ALTER COLUMN id SET DEFAULT nextval('public.dashboards_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: incidents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents ALTER COLUMN id SET DEFAULT nextval('public.incidents_id_seq'::regclass);


--
-- Name: issues id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issues ALTER COLUMN id SET DEFAULT nextval('public.issues_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: view_points id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.view_points ALTER COLUMN id SET DEFAULT nextval('public.view_points_id_seq'::regclass);


--
-- Data for Name: auth_user_group_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_group_roles (auth_user_id, group_id, role_id) FROM stdin;
1	4	1
1	1	1
1	2	1
1	3	1
\.


--
-- Data for Name: auth_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_users (id, name, email, password, idno, uuid, tp_account, member_type, verify_level, is_admin, is_active, is_whitelist, is_blacked, expired_at, created_at, login_at) FROM stdin;
1	skychen901009	skychen901009@gmail.com	921891feb2e8b86f84a941483f119c42118dae1c136a7f051cb1dd06e6bc01e3	\N	\N	\N	\N	\N	t	t	t	f	\N	2025-05-22 18:32:05.571389+00	2025-05-31 22:18:02.466595+00
\.


--
-- Data for Name: component_charts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.component_charts (index, color, types, unit) FROM stdin;
youbike_availability	{#9DC56E,#356340,#9DC56E}	{GuageChart,BarPercentChart}	輛
aging_workforce_trend	{#24B0DD,#56B96D,#F8CF58,#F5AD4A,#E170A6,#ED6A45,#AF4137,#10294A}	{BarPercentChart,RadarChart,ColumnChart}	%
bike_map	{#a0b8e8,#b7ff98}	{MapLegend}	條
vaccine2D	{#ccd5ae,#5edfff}	{DistrictChart,ColumnChart,BarChart}	間
bike_network	{#a0b8e8,#b7ff98}	{DonutChart,BarChart}	公里
cancer102_111	{#24B0DD,#56B96D,#F8CF58,#F5AD4A,#E170A6}	{TimelineSeparateChart,TimelineStackedChart}	人
aging_kpi	{#F65658,#F49F36,#F5C860,#9AC17C,#4CB495,#569C9A,#60819C,#2F8AB1}	{TextUnitChart}	\N
city_age_distribution	{#24B0DD,#56B96D,#F8CF58,#F5AD4A,#E170A6,#ED6A45,#AF4137,#10294A}	{DistrictChart,ColumnChart}	仟人
dependency_aging	{#67baca,#fbf3ac}	{ColumnLineChart,TimelineSeparateChart}	%
ebus_percent	{#9DC56E,#356340,#9DC56E}	{IconPercentChart,BarPercentChart}	輛
disaster_prevention_park	{#56B96D}	{ColumnChart}	人
vaccine3D	{#fdebd3,#f9b4ab,#bbd4ce}	{HeatmapChart}	間
disable_ppl	{#b2fcff}	{DistrictChart,ColumnChart,DonutChart}	人
disabled	{#ccd5ae,#dda15e,#5edfff,#b2fcff}	{DistrictChart,ColumnChart}	間
\.


--
-- Data for Name: component_maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.component_maps (id, index, title, type, source, size, icon, paint, property) FROM stdin;
70	youbike_realtime	youbike站點	symbol	geojson	\N	youbike	{}	[{"key":"sna","name":"場站名稱"},{"key":"sno","name":"場站ID"},{"key":"available_return_bikes","name":"可還車位"},{"key":"available_rent_general_bikes","name":"剩餘車輛"}]
99	youbike_realtime_metrotaipei	youbike站點	symbol	geojson	\N	youbike	{}	[{"key":"sna","name":"場站名稱"},{"key":"sno","name":"場站ID"},{"key":"available_return_bikes","name":"可還車位"},{"key":"available_rent_general_bikes","name":"剩餘車輛"}]
1	disaster_prevention_park	防災公園地點	circle	geojson	\N	\N	{"circle-color":"#56B96D"}	[{"key":"公園名稱","name":"公園名稱"},{"key":"容納人數","name":"容納人數"},{"key":"空間面積","name":"空間面積"},{"key":"週邊醫院資源","name":"週邊醫院資源"},{"key":"週邊消防資源","name":"週邊消防資源"},{"key":"週邊警政資源","name":"週邊警政資源"}]
101	bike_network_metrotaipei	自行車路網	line	geojson	\N	\N	{"line-color":["match",["get","direction"],"雙向","#097138","單向","#007BFF","#808080"]}	[{"key":"data_time","name":"數據時間"},{"key":"route_name","name":"路線名稱"},{"key":"city_code","name":"城市代碼"},{"key":"city","name":"城市"},{"key":"road_section_start","name":"起點路段"},{"key":"road_section_end","name":"終點路段"},{"key":"direction","name":"方向"},{"key":"cycling_length","name":"自行車道長度"},{"key":"finished_time","name":"完工時間"},{"key":"update_time","name":"更新時間"}]
89	disabled_ntp	身心障礙機構	circle	geojson	\N	\N	{"circle-color":"#FFB703"}	[{"key":"district","name":"district"},{"key":"機構名稱","name":"機構名稱"}]
15	vaccine_tp_adult	疫苗接踵處分布	circle	geojson	\N	\N	{"circle-color":"#219EBC"}	\N
25	vaccine_tp_below3	疫苗接踵處分布	circle	geojson	\N	\N	{"circle-color":"#219EBC"}	\N
35	hpv_vaccine	疫苗接踵處分布	circle	geojson	\N	\N	{"circle-color":"#219EBC"}	\N
45	vaccine_tp_3	疫苗接踵處分布	circle	geojson	\N	\N	{"circle-color":"#219EBC"}	\N
50	vaccine_ntp_type	疫苗接踵處分布	circle	geojson	\N	\N	{"circle-color":"#219EBC"}	\N
100	bike_network_tpe	自行車路網	line	geojson	\N	\N	{"line-color":["match",["get","direction"],"雙向","#097138","單向","#007BFF","#808080"]}	[{"key":"data_time","name":"數據時間"},{"key":"route_name","name":"路線名稱"},{"key":"city_code","name":"城市代碼"},{"key":"city","name":"城市"},{"key":"road_section_start","name":"起點路段"},{"key":"road_section_end","name":"終點路段"},{"key":"direction","name":"方向"},{"key":"cycling_length","name":"自行車道長度"},{"key":"finished_time","name":"完工時間"},{"key":"update_time","name":"更新時間"}]
88	disabled_tp	身心障礙機構	circle	geojson	\N	\N	{"circle-color":"#FFB703"}	[{"key":"district","name":"district"},{"key":"機構名稱","name":"機構名稱"}]
\.


--
-- Data for Name: components; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.components (id, index, name) FROM stdin;
60	youbike_availability	YouBike使用情況
215	aging_workforce_trend	高齡就業人口之年增結構
7	cancer102_111	近十年罹癌人數
6	vaccine3D	疫苗熱力圖
9	disable_ppl	身心障礙人數
8	disabled	身心障礙社福機構
217	bike_map	自行車道路網圖資
5	vaccine2D	疫苗接踵處分布圖
213	bike_network	自行車道路統計資料
218	aging_kpi	長照指標
216	city_age_distribution	全市年齡分區
214	dependency_aging	扶養比及老化指數
212	ebus_percent	電動巴士比例
3	disaster_prevention_park	防災公園量能
\.


--
-- Data for Name: contributors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contributors (id, user_id, user_name, image, link, identity, description, include, created_at, updated_at) FROM stdin;
1	doit	臺北市政府資訊局	doit.png	https://doit.gov.taipei/	\N	\N	f	2024-05-09 01:58:47.164185+00	2024-05-09 01:58:47.164185+00
2	ntpc	新北市政府資訊中心	ntpc.png	https://www.imc.ntpc.gov.tw/	\N	\N	f	2024-05-09 01:58:47.164185+00	2024-05-09 01:58:47.164185+00
\.


--
-- Data for Name: dashboard_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dashboard_groups (dashboard_id, group_id) FROM stdin;
106	2
356	2
355	3
359	3
358	3
360	4
368	2
369	4
369	2
369	3
\.


--
-- Data for Name: dashboards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dashboards (id, index, name, components, icon, updated_at, created_at) FROM stdin;
106	map-layers-taipei	圖資資訊	{217}	public	2025-03-12 01:59:00.512775+00	2024-03-21 10:04:24.928533+00
356	ltc_care_tpe	長照關懷	{214,215,216,218}	elderly	2025-02-26 08:43:42.86017+00	2024-03-21 09:38:37.66+00
355	ltc_care_newtpe	長照關懷	{214,215,216,218}	elderly	2025-02-27 06:42:21.705931+00	2024-03-21 09:38:37.66+00
359	map-layers-metrotaipei	圖資資訊	{217}	public	2024-05-16 03:56:12.76016+00	2024-03-21 10:04:24.928533+00
358	practical_transportation_newtpe	務實交通	{60,212,213}	directions_car	2025-03-12 08:00:38.75842+00	2024-03-21 09:38:37.66+00
1	09a25cd9cb7d	收藏組件	\N	favorite	2025-03-14 07:34:22.247753+00	2025-03-14 07:34:22.247753+00
2	3245d9eace5f	我的新儀表板	{215,218,216,213,212,214,60,146}	star	2025-03-14 14:55:11.732116+00	2025-03-14 14:55:11.732116+00
360	b24279ec78a7	收藏組件	{}	favorite	2025-05-30 08:25:34.843977+00	2025-05-22 18:32:05.575031+00
368	disaster_prevention_park	台北市防災公園	{218,215,3}	star	2025-05-31 22:02:59.420706+00	2025-05-30 10:30:12.549531+00
369	7c4415ca913c	健康守護	{5,7,8,9}	health_and_safety	2025-06-01 00:30:00.133564+00	2025-05-31 14:10:10.870325+00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name, is_personal, create_by) FROM stdin;
1	public	f	\N
2	taipei	f	\N
3	metrotaipei	f	\N
4	user: 1's personal group	t	1
\.


--
-- Data for Name: incidents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incidents (id, type, description, distance, latitude, longitude, place, "time", status) FROM stdin;
\.


--
-- Data for Name: issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.issues (id, title, user_name, user_id, context, description, decision_desc, status, updated_by, created_at, updated_at) FROM stdin;
4	test	Drew	1	test	test	測試	不處理	doit	2024-03-15 07:33:39.695288+00	2024-07-26 06:37:55.038985+00
\.


--
-- Data for Name: query_charts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.query_charts (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city) FROM stdin;
aging_kpi	\N	{}	{}	static	\N	0	\N	主計處	此圖顯示臺北長照關懷各項指標。	此圖表呈現臺北長照關懷相關指標，包括 扶老比、扶幼比、扶養比 及 老化指數。扶老比代表每百名勞動人口需扶養的老年人口數，扶幼比則是需扶養的兒童人口數，而扶養比則合計這兩者，反映整體社會負擔程度。老化指數則比較老年人口與兒童人口比例，顯示人口結構的高齡化趨勢。這些數據可用於評估長照需求，並規劃資源分配與政策方向，以因應人口老化帶來的挑戰。	在制定長照政策時，政府可運用 扶老比、扶幼比、扶養比 及 老化指數 來評估未來照護需求。例如，某城市發現扶老比上升且老化指數超過 100，代表老年人口已多於兒童，預示長照需求將持續增加。政府可據此增設長照機構、強化居家照護服務，並鼓勵社區共融計畫，以減輕勞動人口的扶養壓力，確保高齡者獲得適切照顧。	{https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1}	{doit}	2023-12-20 05:56:00+00	2024-06-12 06:02:41.642+00	three_d	select y_axis,icon ,round(avg(data))data  \r\nfrom(\r\nselect '扶老比' as y_axis, percent30 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶幼比' as y_axis, percent31 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶養比' as y_axis, percent32 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '老化指數' as y_axis, percent33 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\n)d\r\ngroup by y_axis,icon	\N	taipei
aging_workforce_trend	\N	\N	\N	static	\N	\N	\N	主計處	顯示雙北就業人口之年齡結構時間數列統計資料	雙北地區人口年齡分配按月別時間數列統計資料，記錄臺北市與新北市各年齡層人口數的月度變化，涵蓋從0歲至65歲以上等多個年齡區間。該資料反映雙北地區人口在不同年齡層之分布情形，具備連續性與時間性，可作為分析區域人口結構、行政規劃及社會資源配置的重要參考。透過長期追蹤，亦能協助了解人口構成在不同時間點的變化狀況與組成比例，有助於支持各項人口相關研究與實務應用。	適用於跨域分析或探討都市群體共通趨勢，涵蓋臺北市與新北市兩地，常見於區域整體發展、通勤流動、就業市場整合、住宅與交通規劃等議題。亦可用於比較兩市人口結構差異、公共資源分布或整合性施政評估。例如：雙北地區勞動參與率變化、雙北通勤族群結構分析、雙北教育資源均衡程度探討等。	{https://data.taipei/dataset/detail?id=df320c78-f66b-4504-92b4-cf2a2eb46f1b,https://data.ntpc.gov.tw/datasets/c285509a-7fb2-434f-8542-0b4986c337a8}	{doit,ntpc}	2024-11-28 05:56:00+00	2024-12-10 02:59:39.341+00	three_d	select x_axis,y_axis,round(avg(percentage)) as data\r\nfrom (select year as x_axis,'1.非高齡就業人口' as y_axis,sum(percentage) as percentage  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure not in ('就業人口','就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲','就業人口按年齡別/65歲以上')\r\ngroup by year \r\nunion all \r\nselect year as x_axis,'2.中高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲')\r\nunion all \r\nselect year as x_axis,'3.高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/65歲以上')\r\nunion all \r\nselect year as x_axis,'1.非高齡就業人口' as y_axis,sum(percentage) as data  from employment_age_structure_new_tpe\r\nwhere  gender ='總計' and age_structure not in ('就業人口','就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲','就業人口按年齡別/65歲以上')\r\ngroup by year \r\nunion all \r\nselect year as x_axis,'2.中高齡就業人口' as y_axis,percentage as data  from employment_age_structure_new_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲')\r\nunion all \r\nselect year as x_axis,'3.高齡就業人口' as y_axis,percentage as data  from employment_age_structure_new_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/65歲以上'))d\r\nwhere x_axis >'2016'\r\ngroup by x_axis,y_axis \r\norder by 1,2	\N	metrotaipei
aging_workforce_trend	\N	\N	\N	static	\N	\N	\N	主計處	顯示臺北就業人口之年齡結構時間數列統計資料	臺北市人口年齡分配按月別時間數列統計資料，提供各年齡層人口數的定期統計結果，依月別呈現，涵蓋從幼年、青壯年至高齡等不同年齡區間。此資料可作為觀察人口結構組成的重要依據，反映各年齡層在人口總數中的分布情形。透過持續的月別紀錄，可供相關單位進行人口結構分析、資源分配規劃及政策評估等多元應用。資料內容具體、連續，適合用於進行長期與跨時比較之研究分析。	適用於聚焦單一行政區之人口、就業、教育、社會福利、都市規劃等議題。多用於市政層級的政策分析、市內人口結構觀察、社會服務配置研究，以及針對臺北市特定區域（如中正區、大安區等）的細部分析。例如：臺北市高齡人口比例變化、臺北市各區幼兒園分布狀況等。	{https://data.taipei/dataset/detail?id=df320c78-f66b-4504-92b4-cf2a2eb46f1b}	{doit}	2024-11-28 05:56:00+00	2025-03-19 10:25:55.340887+00	three_d	select x_axis,y_axis,round(avg(percentage)) as data\r\nfrom (select year as x_axis,'1.非高齡就業人口' as y_axis,sum(percentage) as percentage  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure not in ('就業人口','就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲','就業人口按年齡別/65歲以上')\r\ngroup by year \r\nunion all \r\nselect year as x_axis,'2.中高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲')\r\nunion all \r\nselect year as x_axis,'3.高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/65歲以上')\r\n)d\r\nwhere x_axis >'2016'\r\ngroup by x_axis,y_axis \r\norder by 1,2	\N	taipei
bike_map	\N	{100}	{}	static	\N	\N	\N	交通局交工處	顯示臺北當前自行車路網分布。	顯示臺北市當前自行車路網分布。臺北市擁有完善的自行車路網，主要由河濱自行車道與市區自行車道組成。河濱自行車道沿淡水河、基隆河、新店溪與景美溪等河岸規劃，提供連續、寬敞且景觀良好的騎行空間，深受市民與遊客喜愛。市區自行車道則分布於市內多條主要幹道，包括敦化南北路、承德路、松隆路、松德路、和平西路、民生東路、八德路、光復南路、永吉路等，串聯重要商圈、學區與轉運點，提升日常通勤與短程移動的便利性。臺北市政府持續推動「自行車道願景計畫」，整合市區與河濱車道系統、銜接捷運與轉乘據點，並優化既有路線與設施，致力打造友善、安全的騎乘環境。	使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON}	{doit}	2023-12-20 05:56:00+00	2024-01-11 06:26:02.069+00	map_legend	SELECT unnest(array['自行車路網']) as name, 'line' as type	\N	taipei
bike_network	\N	{100}	{"mode":"byParam","byParam":{"xParam":"direction"}}	static	\N	\N	\N	交通局交工處	顯示臺北市當前自行車路網分布。	顯示臺北市當前自行車路網分布。臺北市擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，臺北市政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。	使用於地圖分析、交通規劃與旅遊建議，臺北市的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON}	{doit}	2023-12-20 05:56:00+00	2024-01-11 06:26:02.069+00	two_d	select  direction as x_axis ,round(sum(cycling_length)/1000) as data\r\nfrom public.bike_network_tpe  \r\nwhere direction !=''\r\ngroup by direction	\N	taipei
bike_map	null	{100,101}	{}	static	\N	\N	\N	交通局交工處	顯示雙北當前自行車路網分布。	顯示雙北當前自行車路網分布。雙北擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，雙北政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。	使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2023-12-20 05:56:00+00	2025-06-01 00:41:38.108198+00	map_legend	SELECT unnest(array['自行車路網']) as name, 'line' as type	\N	metrotaipei
dependency_aging	\N	\N	\N	static	\N	\N	\N	主計處	顯示雙北扶養比及老化指數時間數列統計資料	顯示雙北扶養比及老化指數時間數列統計資料。雙北政府主計處提供了扶養比和老化指數資料，詳細記錄了各年齡段人口比例的變化情況。這些資料有助於分析雙北人口結構的演變，評估青壯年人口對幼年和老年人口的扶養負擔，以及社會老化程度。透過這些統計資料，政策制定者和研究人員可以深入了解人口趨勢，為未來的社會福利和經濟發展規劃提供參考。	使用於人口結構分析、社會福利規劃與經濟發展評估，雙北的扶養比與老化指數數據提供決策參考。政府機構可透過這些統計資料評估勞動力供給與社會扶養負擔，進而調整退休政策與醫療資源配置。企業可運用數據研判市場趨勢，規劃銀髮族產品與服務。學術研究則可透過時間序列分析，探討人口老化對經濟與社會的影響，為未來城市發展與人口政策提供科學依據。\r\n	{https://data.taipei/dataset/detail?id=aafb15dc-5508-4091-bd48-a708e60f6698,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}	{doit,ntpc}	2024-11-28 05:56:00+00	2024-12-10 02:59:39.341+00	time	select \r\nx_axis,y_axis,round(avg(data)) data\r\nfrom (\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'扶養比' as y_axis,total_dependency_ratio as data  \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'老化指數' as y_axis ,aging_index \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'扶養比' as y_axis,total_dependency_ratio  \r\nfrom \r\ndependency_ratio_and_aging_index_new_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'老化指數' as y_axis ,aging_index \r\nfrom \r\ndependency_ratio_and_aging_index_new_tpe\r\n)d\r\nwhere x_axis >'2013-01-01 00:00:00.000'\r\ngroup by x_axis,y_axis\r\norder by 1\r\n	\N	metrotaipei
city_age_distribution	null	\N	null	static	\N	\N	\N	主計處	顯示臺北市年齡分區	顯示臺北市年齡分區，將市民人口依年齡群體劃分至不同行政區域。此分區有助於掌握各區人口結構分布，包括幼年人口、青壯年人口與高齡人口比例，為政策制定者、城市規劃單位及研究人員提供重要的分析依據。透過此資料，可進行公共資源配置、社區照護設計及設施規劃，確保臺北市在教育、醫療、交通與長照等方面的發展，能更貼近各年齡層居民的實際需求，促進人口結構與城市功能的平衡發展。	使用於城市規劃、社會政策制定及人口統計分析，臺北市年齡分區數據可協助市府機關與研究單位掌握市內人口結構的變化。此指標適用於評估各年齡層在不同行政區的分布情形，有助於規劃教育資源、醫療設施及長照服務的佈局與優化。此外，企業亦可依據此資料進行在地市場分析，針對不同年齡族群設計產品與服務，提升區域經營策略的精準度與實效性，強化對臺北市多元人口需求的回應。\n\n\n\n\n\n\n\n\n	{https://data.taipei/dataset/detail?id=1e0c58e9-6aa5-4acb-a5a1-f60bacad60f3}	{doit}	2024-11-28 05:56:00+00	2025-05-31 21:03:35.94307+00	three_d	select x_axis,y_axis,round(sum(data)/1000) data\r\nfrom(select 區域別 as x_axis,'0_14歲人口數' as y_axis,percent24 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'15_64歲人口數' as y_axis,percent26 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'65歲以上人口數' as y_axis,percent28 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\n)d\r\ngroup by x_axis,y_axis\r\n	\N	taipei
cancer102_111	null	\N	null	static	\N	0	\N	衛福部	本儀表板彙整近十年雙北死亡率前五名癌症的罹患人數	透過折線圖方式呈現各癌症類型的年度變化趨勢，幫助使用者掌握高致死癌症在台灣的發生規模與變動狀況。\n\n圖表著重於長期趨勢觀察與類型比較，可作為公衛政策、癌症防治計畫與醫療資源配置的重要參考依據。	中央健康署的癌症防治規劃人員透過本圖表發現，肺癌與肝癌的罹患人數在近年穩定居高，顯示仍需強化早期診斷與預防宣導策略。	{https://data.gov.tw/dataset/6399}	\N	2025-05-31 18:01:25.819482+00	2025-05-31 22:50:36.260887+00	time	SELECT \n  TO_TIMESTAMP(癌症診斷年::TEXT || '-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\n  癌症別 AS y_axis,\n  SUM( (REPLACE(癌症發生數, ',', ''))::INT ) AS data\nFROM cancer102_111\nWHERE 縣市別 IN ('台北市')\n  AND 癌症診斷年 BETWEEN 2013 AND 2022\n  AND 癌症別 IN ('肺、支氣管及氣管', '結直腸', '女性乳房', '肝及肝內膽管', '甲狀腺')\nGROUP BY 癌症診斷年, 癌症別\nORDER BY 癌症診斷年, 癌症別;	\N	taipei
youbike_availability	\N	{99}	\N	current	\N	10	minute	交通局	顯示當前雙北共享單車YouBike的使用情況。	顯示雙北地區（臺北市與新北市）當前共享單車 YouBike 的使用情況，格式為可借車輛數／全區車位數。資料來源為兩市交通局公開資料，每5分鐘更新一次，提供即時的車輛可用資訊與站點使用狀況，有助於掌握整體運行效率與民眾使用情形，亦可作為交通管理與營運調度的參考依據。	藉由顯示雙北地區 YouBike 的使用情況，以及觀察可借車輛數約為車柱總數的一半，可大致掌握目前停放於站點與使用中車輛的整體分布情形。使用者亦可透過地圖模式查詢雙北各站點的即時資訊，包括可借車輛數、可還空位數及站點位置，方便規劃路線與掌握使用狀況，提升共享單車的便利性與使用效率。	{https://tdx.transportdata.tw/api-service/swagger/basic/2cc9b888-a592-496f-99de-9ab35b7fb70d#/Bike/BikeApi_Availability_2181,https://tdx.transportdata.tw/api/basic/v2/Bike/Availability/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2023-12-20 05:56:00+00	2024-03-19 06:08:17.99+00	percent	select x_axis,y_axis,sum(data)data\r\nfrom (select '在站車輛' as x_axis, \r\nunnest(ARRAY['可借車輛', '空位']) as y_axis, \r\nunnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data\r\nfrom tran_ubike_realtime_new_tpe\r\nunion all \r\nselect '在站車輛' as x_axis, \r\nunnest(ARRAY['可借車輛', '空位']) as y_axis, \r\nunnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data\r\nfrom tran_ubike_realtime)d\r\ngroup by x_axis,y_axis	\N	metrotaipei
youbike_availability	\N	{70}	\N	current	\N	10	minute	交通局	顯示當前臺北市共享單車YouBike的使用情況。	顯示臺北市當前共享單車 YouBike 的使用情況，格式為可借車輛數／全市車位數。資料來源為臺北市政府交通局公開資料，每5分鐘更新一次，反映即時的使用狀況與車輛調度情形，可作為交通監測與市民使用參考依據。	藉由臺北市 YouBike 使用情況的顯示，以及全市可借車輛數約為車柱總數的一半，可大致掌握目前停放於站點與正在使用中的車輛數量。使用者可透過地圖模式查詢臺北市各站點的即時資訊，包括可借車輛數、可還空位數及站點位置，方便即時掌握使用狀況，提升共享單車的使用效率與便利性。	{https://tdx.transportdata.tw/api-service/swagger/basic/2cc9b888-a592-496f-99de-9ab35b7fb70d#/Bike/BikeApi_Availability_2181}	{doit}	2023-12-20 05:56:00+00	2024-03-19 06:08:17.99+00	percent	select '在站車輛' as x_axis, \r\nunnest(ARRAY['可借車輛', '空位']) as y_axis, \r\nunnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data\r\nfrom tran_ubike_realtime	\N	taipei
ebus_percent	\N	{88,89}	\N	static	\N	\N	\N	交通局	顯示臺北電動公車比例	此圖顯示臺北市電動公車的比例，呈現全市公車車隊中電動車所占比重，以及近年來電動公車數量的成長情形。圖表比較傳統燃油公車與電動公車的比例變化，並標示臺北市政府推動電動化政策、補助措施及其帶來的環保效益。透過這些數據，可評估臺北市電動公車的普及程度，及其在減碳與空氣品質改善上的貢獻，有助於進一步規劃更完善的公共運輸電動化策略，推動城市交通朝向低碳永續目標邁進。	可用於評估臺北市公共運輸電動化的進程，透過此圖顯示電動公車在市區公車總數中的占比及其成長趨勢。圖表呈現傳統燃油公車與電動公車的比例變化，並標示臺北市政府推動的政策措施、補助方案及相關環保效益等影響因素。透過這些數據，可分析臺北市電動公車的普及程度及其在減碳排放與空氣品質改善方面的貢獻，有助於進一步規劃更完善的公共運輸電動化策略，推動臺北朝向低碳與永續發展的城市目標邁進。	{https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/Taipei?%24top=30&%24format=JSON}	{doit}	2025-02-15 05:56:00+00	2025-02-20 09:11:21.620625+00	percent	select '電動公車數量' as x_axis,y_axis,sum(data) data from \r\n(\r\nselect '電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe\r\nwhere plate_numb like 'E%'\r\nunion all\r\nselect '非電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe)d\r\ngroup by \r\ny_axis	\N	taipei
disabled	null	{88,89}	{"mode":"byParam","byParam":{"xParam":"district"}}	static	\N	0	\N	衛福部	本儀表板呈現台北市與新北市各行政區內，身心障礙相關社會福利機構的設置數量	透過行政區地圖與長條圖的視覺化方式，讓使用者快速掌握雙北地區社福資源的空間分布狀況。\n本系統可協助使用者觀察不同行政區在身心障礙人口上的相對規模，有助於了解人口密度分布與服務需求潛勢區域。	新北市社會局承辦人欲了解機構分布情形，並發現社福機構數量差異明顯，作為資源補強與政策協調的依據。	{https://www.sfaa.gov.tw/SFAA/Welfare/Institution.aspx?nodeid=460,https://www.sfaa.gov.tw/SFAA/Welfare/Institution.aspx?nodeid=460}	\N	2025-05-31 18:35:17.04758+00	2025-06-01 00:23:04.02105+00	two_d	WITH all_agencies AS (\n  SELECT district FROM disabled_agency_tp\n  UNION ALL\n  SELECT district FROM disabled_agency_ntp\n),\ndistrict_order AS (\n  SELECT * FROM (VALUES\n    ('北投區', 1), ('士林區', 2), ('內湖區', 3), ('南港區', 4), ('松山區', 5),\n    ('信義區', 6), ('中山區', 7), ('大同區', 8), ('中正區', 9), ('萬華區', 10),\n    ('大安區', 11), ('文山區', 12), ('新莊區', 13), ('淡水區', 14), ('汐止區', 15),\n    ('板橋區', 16), ('三重區', 17), ('樹林區', 18), ('土城區', 19), ('蘆洲區', 20),\n    ('中和區', 21), ('永和區', 22), ('新店區', 23), ('鶯歌區', 24), ('三峽區', 25),\n    ('瑞芳區', 26), ('五股區', 27), ('泰山區', 28), ('林口區', 29), ('深坑區', 30),\n    ('石碇區', 31), ('坪林區', 32), ('三芝區', 33), ('石門區', 34), ('八里區', 35),\n    ('平溪區', 36), ('雙溪區', 37), ('貢寮區', 38), ('金山區', 39), ('萬里區', 40),\n    ('烏來區', 41)\n  ) AS t(district, ordering)\n)\nSELECT\n  d.district AS x_axis,\n  COALESCE(COUNT(a.district), 0)::FLOAT AS data\nFROM district_order d\nLEFT JOIN all_agencies a ON a.district = d.district\nGROUP BY d.district, d.ordering\nORDER BY d.ordering;\n	\N	metrotaipei
vaccine2D	null	{15,25,35,45}	{"mode":"byParam","byParam":{"xParam":"district"}}	static	\N	0	\N	衛生局	本儀表板以行政區圖方式呈現台北市與新北市各行政區內，可提供疫苗接種服務的醫療院所數量。	每個行政區皆以清楚邊界與對應數值顯示，使用者可點選或比較不同區域之疫苗接種資源狀況。\n\n行政區圖強調地理分區與數值精確呈現，適合用於個別區域比較與具體決策分析，亦可搭配表格、折線圖等資訊進行多	公衛規劃小組比對區與區之間的疫苗接種院所數據後，發現某區服務據點數量相對集中，而另一區則因幅員較大造成部分地段服務可及性不足，進而規劃區內資源補強方案。	{https://data.taipei/dataset/detail?id=f2a66aec-9b15-4580-9d04-9e991d45e908,https://data.taipei/dataset/detail?id=6f830d1c-b595-4c08-8b05-4430d247a0db,https://data.taipei/dataset/detail?id=0db13d34-51e3-497a-a023-286d5ef692ea,https://data.taipei/dataset/detail?id=96f143fe-4c95-4d88-9985-77f28e2d2c3d}	\N	2025-05-31 16:47:06.583275+00	2025-06-01 00:43:16.904158+00	two_d	WITH combined_data AS (\n    -- 3歲以下流感疫苗資料，新增 vaccine_type 欄位\n    SELECT district, '嬰兒流感疫苗' AS vaccine_type\n    FROM vaccine_tp_below3\n    WHERE district IS NOT NULL\n    UNION ALL\n    -- HPV 疫苗資料，新增 vaccine_type 欄位\n    SELECT district, 'HPV疫苗' AS vaccine_type\n    FROM hpv_vaccine\n    WHERE district IS NOT NULL\n    UNION ALL\n    -- 3歲以上幼童流感疫苗資料，新增 vaccine_type 欄位\n    SELECT district, '幼童流感疫苗' AS vaccine_type\n    FROM vaccine_tp_3\n    WHERE district IS NOT NULL\n    UNION ALL\n    -- 成人流感疫苗資料，新增 vaccine_type 欄位\n    SELECT district, '成人流感疫苗' AS vaccine_type\n    FROM vaccine_tp_adult\n    WHERE district IS NOT NULL\n),\ncounts AS (\n    -- 按行政區和疫苗種類分組，計算醫療院所數量\n    SELECT \n        district,\n        vaccine_type,\n        COUNT(*) AS count\n    FROM combined_data\n    GROUP BY district, vaccine_type\n),\nsorted_districts AS (\n    -- 定義行政區排序\n    SELECT \n        district,\n        vaccine_type,\n        count,\n        CASE district\n            WHEN '北投區' THEN 1\n            WHEN '士林區' THEN 2\n            WHEN '內湖區' THEN 3\n            WHEN '南港區' THEN 4\n            WHEN '松山區' THEN 5\n            WHEN '信義區' THEN 6\n            WHEN '中山區' THEN 7\n            WHEN '大同區' THEN 8\n            WHEN '中正區' THEN 9\n            WHEN '萬華區' THEN 10\n            WHEN '大安區' THEN 11\n            WHEN '文山區' THEN 12\n            ELSE 13\n        END AS district_order\n    FROM counts\n)\n-- 最終結果，按行政區順序排序，調整欄位名稱以符合熱力圖格式\nSELECT \n    district AS x_axis,\n    vaccine_type AS y_axis,\n    count AS data\nFROM sorted_districts\nORDER BY district_order, vaccine_type;	\N	taipei
disabled	null	{88,89}	{"mode":"byParam","byParam":{"xParam":"district"}}	static	\N	0	\N	衛福部	本儀表板呈現台北市與新北市各行政區內，身心障礙相關社會福利機構的設置數量	透過行政區地圖與長條圖的視覺化方式，讓使用者快速掌握雙北地區社福資源的空間分布狀況。\n\n本系統可協助政策推動者評估不同區域的服務密度，並作為未來設點、擴點或資源調整的重要參考。	新北市社會局承辦人欲了解構分布情形，發現雖然兩地人口規模相當，但社福機構數量差異明顯，作為資源補強與政策協調的依據。	{https://www.sfaa.gov.tw/SFAA/Welfare/Institution.aspx?nodeid=460}	\N	2025-05-31 18:35:17.04758+00	2025-05-31 22:44:44.743705+00	two_d	SELECT\n  CASE district\n    WHEN '北投區' THEN 1\n    WHEN '士林區' THEN 2\n    WHEN '內湖區' THEN 3\n    WHEN '南港區' THEN 4\n    WHEN '松山區' THEN 5\n    WHEN '信義區' THEN 6\n    WHEN '中山區' THEN 7\n    WHEN '大同區' THEN 8\n    WHEN '中正區' THEN 9\n    WHEN '萬華區' THEN 10\n    WHEN '大安區' THEN 11\n    WHEN '文山區' THEN 12\n  END AS ordering,\n  district AS x_axis,\n  COUNT(*)::FLOAT AS data\nFROM disabled_agency_tp\nWHERE district IN ('北投區', '士林區', '內湖區', '南港區', '松山區', '信義區', '中山區', '大同區', '中正區', '萬華區', '大安區', '文山區')\nGROUP BY district\nORDER BY ordering;\n	\N	taipei
disable_ppl	null	\N	null	static	\N	0	\N	衛福部	本儀表板整合台北市與新北市各行政區的身心障礙人口統計資料	透過行政區地圖與長條圖，清楚呈現各區的障礙人口分布情形，提供民眾與政策制定者一目了然的視覺化數據。\n\n使用者可觀察不同行政區在身心障礙人口上的相對規模，有助於了解人口密度分布與服務需求潛勢區域。	社會局的規劃人員希望了解雙北地區障礙人口較多的區域，作為後續政策討論與資源投入的參考依據。	{https://dep.mohw.gov.tw/dos/cp-5224-62359-113.html}	\N	2025-05-31 19:08:50.388717+00	2025-06-01 00:19:24.844949+00	two_d	WITH double_cities_districts AS (\n    -- 從資料中過濾雙北行政區\n    SELECT \n        地址 AS district,\n        COALESCE(CAST("2024Q4Total" AS INTEGER), 0) AS total\n    FROM disable_population\n    WHERE 地址 IN (\n        '北投區', '士林區', '內湖區', '南港區', '松山區', '信義區',\n        '中山區', '大同區', '中正區', '萬華區', '大安區', '文山區',\n        '新莊區', '淡水區', '汐止區', '板橋區', '三重區', '樹林區',\n        '土城區', '蘆洲區', '中和區', '永和區', '新店區', '鶯歌區',\n        '三峽區', '瑞芳區', '五股區', '泰山區', '林口區', '深坑區',\n        '石碇區', '坪林區', '三芝區', '石門區', '八里區', '平溪區',\n        '雙溪區', '貢寮區', '金山區', '萬里區', '烏來區'\n    )\n),\nsorted_districts AS (\n    -- 定義行政區排序\n    SELECT \n        district,\n        total,\n        CASE district\n            WHEN '北投區' THEN 1\n            WHEN '士林區' THEN 2\n            WHEN '內湖區' THEN 3\n            WHEN '南港區' THEN 4\n            WHEN '松山區' THEN 5\n            WHEN '信義區' THEN 6\n            WHEN '中山區' THEN 7\n            WHEN '大同區' THEN 8\n            WHEN '中正區' THEN 9\n            WHEN '萬華區' THEN 10\n            WHEN '大安區' THEN 11\n            WHEN '文山區' THEN 12\n            WHEN '新莊區' THEN 13\n            WHEN '淡水區' THEN 14\n            WHEN '汐止區' THEN 15\n            WHEN '板橋區' THEN 16\n            WHEN '三重區' THEN 17\n            WHEN '樹林區' THEN 18\n            WHEN '土城區' THEN 19\n            WHEN '蘆洲區' THEN 20\n            WHEN '中和區' THEN 21\n            WHEN '永和區' THEN 22\n            WHEN '新店區' THEN 23\n            WHEN '鶯歌區' THEN 24\n            WHEN '三峽區' THEN 25\n            WHEN '瑞芳區' THEN 26\n            WHEN '五股區' THEN 27\n            WHEN '泰山區' THEN 28\n            WHEN '林口區' THEN 29\n            WHEN '深坑區' THEN 30\n            WHEN '石碇區' THEN 31\n            WHEN '坪林區' THEN 32\n            WHEN '三芝區' THEN 33\n            WHEN '石門區' THEN 34\n            WHEN '八里區' THEN 35\n            WHEN '平溪區' THEN 36\n            WHEN '雙溪區' THEN 37\n            WHEN '貢寮區' THEN 38\n            WHEN '金山區' THEN 39\n            WHEN '萬里區' THEN 40\n            WHEN '烏來區' THEN 41\n            ELSE 42\n        END AS district_order\n    FROM double_cities_districts\n)\n-- 最終結果，按行政區順序排序，格式化為 Mapbox ColumnChart 所需欄位\nSELECT \n    district AS x_axis,\n    total AS data\nFROM sorted_districts\nORDER BY district_order;	\N	metrotaipei
ebus_percent	null	\N	null	static	\N	\N	\N	交通局	顯示雙北電動公車比例	此圖顯示雙北地區電動公車的比例，呈現臺北市與新北市公車車隊中電動車所占比重，以及近年來電動公車數量的成長情形。圖表比較傳統燃油公車與電動公車的比例變化，並標示雙北兩市政府推動電動化政策、補助措施及其帶來的環保效益。透過這些數據，可評估雙北地區電動公車的普及程度，及其對減碳、空氣品質改善的實質貢獻，進一步作為規劃大臺北地區公共運輸電動化策略的重要依據，推動都會區交通體系朝向低碳永續發展。	可用於評估雙北地區公共運輸電動化進程，透過此圖顯示臺北市與新北市公車系統中電動公車的占比及成長趨勢。圖表比較傳統燃油公車與電動公車的比例變化，並標示雙北兩市推動相關政策、補助措施及其所帶來的環保效益。透過這些數據，可評估雙北地區電動公車的普及率，以及其在減碳排放與空氣品質改善上的具體貢獻，進而作為制定更完善的都會區公共運輸電動化策略的重要依據，推動雙北朝向低碳永續城市目標發展。	{https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2025-02-15 05:56:00+00	2025-05-31 21:03:43.926425+00	percent	select '電動公車數量' as x_axis,y_axis,sum(data) data from \r\n(select '電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_new_tpe\r\nwhere plate_numb like 'E%'\r\nunion all\r\nselect '非電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_new_tpe\r\nwhere plate_numb not like 'E%'\r\nunion all\r\nselect '電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe\r\nwhere plate_numb like 'E%'\r\nunion all\r\nselect '非電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe)d\r\ngroup by \r\ny_axis\r\n	\N	metrotaipei
disaster_prevention_park	null	{1}	{"mode":"byParam","byParam":{"xParam":"公園名稱"}}	static	\N	0	\N	工務局公園處	臺北市公園裡各項設施說明	pm_name(公園名稱)、pm_Longitude(經度)、pm_Latitude(緯度)、di_area(空間面積)、di_capacity(容納人數)、di_Amount1(安置登記站個數)、di_Amount2(醫護站個數)、di_Amount3(播音站個數)、di_Amount4(物資管理站個數)、di_Amount5(器材倉庫個數)、di_Amount6(指揮中心個數)、di_Amount7(伙食區個數)、di_Amount8(帳篷區個數)、di_Amount9(沐浴區個數)、di_Amount10(曬衣場個數)、di_Amount11(公共廁所個數)、di_Amount12(垃圾場個數)、di_Amount13(公共電話個數)、di_Amount14(消防蓄水設施個數)、di_Amount15(消防栓個數)、di_Amount16(自來水取水站個數)、di_Amount17(維生貯水槽個數)、di_Amount18(臨時廁所設置區個數)、di_hospital(週邊醫院資源)、di_fire(週邊消防資源)、di_police(週邊警政資源)	test	{https://parks.gov.taipei/parks/json/}	{doit}	2016-11-01 12:00:00+00	2025-05-31 21:07:55.576243+00	three_d	SELECT\n    公園名稱 AS x_axis,\n    '容納人數' AS y_axis,\n    CAST(容納人數 AS INTEGER) AS data\nFROM disaster_prevention_park\nORDER BY\n    ARRAY_POSITION(ARRAY['復興公園', '士林官邸公園', '榮星花園公園', '大湖公園', '玉泉公園', '民權公園', '二二八和平公園', '大安森林公園', '松德公園', '南港公園', '景華公園'], 公園名稱);	\N	taipei
dependency_aging	null	\N	null	static	\N	\N	\N	主計處	顯示臺北市扶養比及老化指數時間數列統計資料	顯示臺北市扶養比及老化指數時間數列統計資料。臺北市政府主計處提供了扶養比和老化指數資料，詳細記錄了各年齡段人口比例的變化情況。這些資料有助於分析臺北市人口結構的演變，評估青壯年人口對幼年和老年人口的扶養負擔，以及社會老化程度。透過這些統計資料，政策制定者和研究人員可以深入了解人口趨勢，為未來的社會福利和經濟發展規劃提供參考。	使用於人口結構分析、社會福利規劃與經濟發展評估，臺北市的扶養比與老化指數數據提供決策參考。政府機構可透過這些統計資料評估勞動力供給與社會扶養負擔，進而調整退休政策與醫療資源配置。企業可運用數據研判市場趨勢，規劃銀髮族產品與服務。學術研究則可透過時間序列分析，探討人口老化對經濟與社會的影響，為未來城市發展與人口政策提供科學依據。\r\n	{https://data.taipei/dataset/detail?id=aafb15dc-5508-4091-bd48-a708e60f6698}	{doit}	2024-11-28 05:56:00+00	2025-05-31 21:03:40.267545+00	time	select \r\nx_axis,y_axis,round(avg(data)) data\r\nfrom (\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'扶養比' as y_axis,total_dependency_ratio as data  \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'老化指數' as y_axis ,aging_index \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\n)d\r\nwhere x_axis >'2013-01-01 00:00:00.000'\r\ngroup by x_axis,y_axis\r\norder by 1\r\n	\N	taipei
vaccine3D	null	\N	null	static	\N	0	\N	新北市政府衛生局,衛生局	本儀表板以熱點圖形式呈現台北市與新北市各行政區內，可提供疫苗接種服務之醫療院所數量。	圖面透過色彩強度標示資源密集度，讓使用者直觀辨識疫苗服務熱區與資源相對稀少區域。\n\n此熱點圖著重於視覺強度反映服務密度，可快速掌握整體分布趨勢，並作為疫苗接種政策與醫療資源調度的重要依據。	新北市衛生局公衛專員觀察熱點圖，發現某些區屬於高密度接種資源熱區，但某些區色彩偏淡，顯示接種院所相對稀少，可作為後續增設合作院所與流動接種站的策略依據。	{}	\N	2025-05-31 17:07:36.916897+00	2025-05-31 20:32:18.629888+00	three_d	WITH ntp_child_vaccines AS (\n    -- 拆分新北市幼兒疫苗資料的疫苗欄位，將逗號分隔的疫苗種類展開為多行\n    SELECT \n        district,\n        hosp_name,\n        TRIM(vaccine_type) AS vaccine_type\n    FROM vaccine_ntp_type,\n    LATERAL unnest(string_to_array(vaccine, '、')) AS vaccine_type\n    WHERE district IS NOT NULL \n        AND vaccine IS NOT NULL \n        AND vaccine != ''\n        AND hosp_name IS NOT NULL\n),\nntp_general_vaccines AS (\n    -- 處理新北市一般疫苗資料，假設疫苗種類為「流感疫苗」\n    SELECT \n        district,\n        name AS hosp_name,\n        '流感疫苗' AS vaccine_type\n    FROM vaccine_ntp\n    WHERE district IS NOT NULL\n        AND name IS NOT NULL\n),\nntp_combined_vaccines AS (\n    -- 聯集新北市幼兒疫苗和一般疫苗資料\n    SELECT district, hosp_name, vaccine_type\n    FROM ntp_child_vaccines\n    UNION\n    SELECT district, hosp_name, vaccine_type\n    FROM ntp_general_vaccines\n),\nntp_distinct_counts AS (\n    -- 新北市：去重複，按行政區和疫苗種類分組，計算醫療院所數量\n    SELECT \n        district,\n        vaccine_type,\n        COUNT(DISTINCT hosp_name) AS count\n    FROM ntp_combined_vaccines\n    GROUP BY district, vaccine_type\n    HAVING COUNT(DISTINCT hosp_name) IS NOT NULL\n),\ntp_combined_data AS (\n    -- 台北市：聯集各類疫苗資料\n    SELECT district, '嬰兒流感疫苗' AS vaccine_type\n    FROM vaccine_tp_below3\n    WHERE district IS NOT NULL\n    UNION ALL\n    SELECT district, 'HPV 疫苗' AS vaccine_type\n    FROM hpv_vaccine\n    WHERE district IS NOT NULL\n    UNION ALL\n    SELECT district, '幼童流感疫苗' AS vaccine_type\n    FROM vaccine_tp_3\n    WHERE district IS NOT NULL\n    UNION ALL\n    SELECT district, '成人流感疫苗' AS vaccine_type\n    FROM vaccine_tp_adult\n    WHERE district IS NOT NULL\n),\ntp_counts AS (\n    -- 台北市：按行政區和疫苗種類分組，計算醫療院所數量\n    SELECT \n        district,\n        vaccine_type,\n        COUNT(*) AS count\n    FROM tp_combined_data\n    GROUP BY district, vaccine_type\n    HAVING COUNT(*) IS NOT NULL\n),\ncombined_counts AS (\n    -- 聯集新北市和台北市的統計結果\n    SELECT district, vaccine_type, count\n    FROM ntp_distinct_counts\n    UNION\n    SELECT district, vaccine_type, count\n    FROM tp_counts\n),\nsorted_districts AS (\n    -- 定義行政區排序\n    SELECT \n        district,\n        vaccine_type,\n        COALESCE(count, 0) AS count,\n        CASE district\n            WHEN '北投區' THEN 1\n            WHEN '士林區' THEN 2\n            WHEN '內湖區' THEN 3\n            WHEN '南港區' THEN 4\n            WHEN '松山區' THEN 5\n            WHEN '信義區' THEN 6\n            WHEN '中山區' THEN 7\n            WHEN '大同區' THEN 8\n            WHEN '中正區' THEN 9\n            WHEN '萬華區' THEN 10\n            WHEN '大安區' THEN 11\n            WHEN '文山區' THEN 12\n            WHEN '新莊區' THEN 13\n            WHEN '淡水區' THEN 14\n            WHEN '汐止區' THEN 15\n            WHEN '板橋區' THEN 16\n            WHEN '三重區' THEN 17\n            WHEN '樹林區' THEN 18\n            WHEN '土城區' THEN 19\n            WHEN '蘆洲區' THEN 20\n            WHEN '中和區' THEN 21\n            WHEN '永和區' THEN 22\n            WHEN '新店區' THEN 23\n            WHEN '鶯歌區' THEN 24\n            WHEN '三峽區' THEN 25\n            WHEN '瑞芳區' THEN 26\n            WHEN '五股區' THEN 27\n            WHEN '泰山區' THEN 28\n            WHEN '林口區' THEN 29\n            WHEN '深坑區' THEN 30\n            WHEN '石碇區' THEN 31\n            WHEN '坪林區' THEN 32\n            WHEN '三芝區' THEN 33\n            WHEN '石門區' THEN 34\n            WHEN '八里區' THEN 35\n            WHEN '平溪區' THEN 36\n            WHEN '雙溪區' THEN 37\n            WHEN '貢寮區' THEN 38\n            WHEN '金山區' THEN 39\n            WHEN '萬里區' THEN 40\n            WHEN '烏來區' THEN 41\n            ELSE 42\n        END AS district_order\n    FROM combined_counts\n)\n-- 最終結果，按行政區順序和疫苗種類排序，格式化為 3D 圖所需欄位\nSELECT \n    district AS x_axis,\n    vaccine_type AS y_axis,\n    count AS data\nFROM sorted_districts\nORDER BY district_order, vaccine_type;	\N	metrotaipei
cancer102_111	null	\N	null	static	\N	0	\N	衛福部	本儀表板彙整近十年雙北死亡率前五名癌症的罹患人數，透過折線圖方式呈現各癌症類型的年度變化趨勢	幫助使用者掌握高致死癌症在台灣的發生規模與變動狀況。\n\n圖表著重於長期趨勢觀察與類型比較，可作為公衛政策、癌症防治計畫與醫療資源配置的重要參考依據。	中央健康署的癌症防治規劃人員透過本圖表發現，肺癌與肝癌的罹患人數在近年穩定居高，顯示仍需強化早期診斷與預防宣導策略。	{https://data.gov.tw/dataset/6399}	\N	2025-05-31 18:01:25.819482+00	2025-05-31 22:50:55.708984+00	time	SELECT \n  TO_TIMESTAMP(癌症診斷年::TEXT || '-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\n  癌症別 AS y_axis,\n  SUM( (REPLACE(癌症發生數, ',', ''))::INT ) AS data\nFROM cancer102_111\nWHERE 縣市別 IN ('台北市', '新北市')\n  AND 癌症診斷年 BETWEEN 2013 AND 2022\n  AND 癌症別 IN ('肺、支氣管及氣管', '結直腸', '女性乳房', '肝及肝內膽管', '甲狀腺')\nGROUP BY 癌症診斷年, 癌症別\nORDER BY 癌症診斷年, 癌症別;	\N	metrotaipei
vaccine3D	null	\N	null	static	\N	0	\N	衛生局	本儀表板以熱力圖形式呈現台北市與新北市各行政區內，可提供疫苗接種服務之醫療院所數量。	圖面透過色彩強度標示資源密集度，讓使用者直觀辨識疫苗服務熱區與資源相對稀少區域。\n此熱力圖著重於<視覺程度反映服務密度>，可快速掌握整體分布趨勢，並作為疫苗接種政策與醫療資源調度的重要依據。	新北市衛生局公衛專員觀察熱點圖，發現某些區屬於高密度接種資源熱區，但某些區色彩偏淡，顯示接種院所相對稀少，可作為後續增設合作院所與流動接種站的策略依據。	{}	\N	2025-05-31 17:07:36.916897+00	2025-05-31 20:32:27.922376+00	three_d	WITH combined_data AS (\n    -- 3歲以下流感疫苗資料，新增 vaccine_type 欄位\n    SELECT district, '嬰兒流感疫苗' AS vaccine_type\n    FROM vaccine_tp_below3\n    WHERE district IS NOT NULL\n    UNION ALL\n    -- HPV 疫苗資料，新增 vaccine_type 欄位\n    SELECT district, 'HPV 疫苗' AS vaccine_type\n    FROM hpv_vaccine\n    WHERE district IS NOT NULL\n    UNION ALL\n    -- 3歲以上幼童流感疫苗資料，新增 vaccine_type 欄位\n    SELECT district, '幼童流感疫苗' AS vaccine_type\n    FROM vaccine_tp_3\n    WHERE district IS NOT NULL\n    UNION ALL\n    -- 成人流感疫苗資料，新增 vaccine_type 欄位\n    SELECT district, '成人流感疫苗' AS vaccine_type\n    FROM vaccine_tp_adult\n    WHERE district IS NOT NULL\n),\ncounts AS (\n    -- 按行政區和疫苗種類分組，計算醫療院所數量\n    SELECT \n        district,\n        vaccine_type,\n        COUNT(*) AS count\n    FROM combined_data\n    GROUP BY district, vaccine_type\n),\nsorted_districts AS (\n    -- 定義行政區排序\n    SELECT \n        district,\n        vaccine_type,\n        count,\n        CASE district\n            WHEN '北投區' THEN 1\n            WHEN '士林區' THEN 2\n            WHEN '內湖區' THEN 3\n            WHEN '南港區' THEN 4\n            WHEN '松山區' THEN 5\n            WHEN '信義區' THEN 6\n            WHEN '中山區' THEN 7\n            WHEN '大同區' THEN 8\n            WHEN '中正區' THEN 9\n            WHEN '萬華區' THEN 10\n            WHEN '大安區' THEN 11\n            WHEN '文山區' THEN 12\n            ELSE 13\n        END AS district_order\n    FROM counts\n)\n-- 最終結果，按行政區順序排序，調整欄位名稱以符合熱力圖格式\nSELECT \n    district AS x_axis,\n    vaccine_type AS y_axis,\n    count AS data\nFROM sorted_districts\nORDER BY district_order, vaccine_type;	\N	taipei
disable_ppl	null	\N	null	static	\N	0	\N	衛福部	本儀表板整合台北市與新北市各行政區的身心障礙人口統計資料。	透過行政區地圖與長條圖，清楚呈現各區的障礙人口分布情形，提供民眾與政策制定者一目了然的視覺化數據。使用者可觀察不同行政區在身心障礙人口上的相對規模，有助於了解人口密度分布與服務需求潛勢區域。	社會局的規劃人員希望了解雙北地區障礙人口較多的區域，作為後續政策討論與資源投入的參考依據。	{https://dep.mohw.gov.tw/dos/cp-5224-62359-113.html}	\N	2025-05-31 19:08:50.388717+00	2025-05-31 22:45:20.281786+00	two_d	WITH taipei_districts AS (\n    -- 從資料中過濾台北市行政區\n    SELECT \n        地址 AS district,\n        COALESCE(CAST("2024Q4Total" AS INTEGER), 0) AS total\n    FROM disable_population\n    WHERE 地址 IN (\n        '北投區', '士林區', '內湖區', '南港區', '松山區', '信義區',\n        '中山區', '大同區', '中正區', '萬華區', '大安區', '文山區'\n    )\n),\nsorted_districts AS (\n    -- 定義行政區排序\n    SELECT \n        district,\n        total,\n        CASE district\n            WHEN '北投區' THEN 1\n            WHEN '士林區' THEN 2\n            WHEN '內湖區' THEN 3\n            WHEN '南港區' THEN 4\n            WHEN '松山區' THEN 5\n            WHEN '信義區' THEN 6\n            WHEN '中山區' THEN 7\n            WHEN '大同區' THEN 8\n            WHEN '中正區' THEN 9\n            WHEN '萬華區' THEN 10\n            WHEN '大安區' THEN 11\n            WHEN '文山區' THEN 12\n            ELSE 13\n        END AS district_order\n    FROM taipei_districts\n)\n-- 最終結果，按行政區順序排序，格式化為 Mapbox ColumnChart 所需欄位\nSELECT \n    district AS x_axis,\n    total AS data\nFROM sorted_districts\nORDER BY district_order;	\N	taipei
vaccine2D	null	{15,25,35,45,50}	{"mode":"byParam","byParam":{"xParam":"district"}}	static	\N	0	\N	新北市政府衛生局 衛生局	本儀表板以行政區圖方式呈現台北市與新北市各行政區內，可提供疫苗接種服務的醫療院所數量。	每個行政區皆以清楚邊界與對應數值顯示，使用者可點選或比較不同區域之疫苗接種資源狀況。\n\n行政區圖強調地理分區與數值精確呈現，適合用於個別區域比較與具體決策分析，亦可搭配表格、折線圖等資訊進行多	公衛規劃小組比對區與區之間的疫苗接種院所數據後，發現某區服務據點數量相對集中，而另一區則因幅員較大造成部分地段服務可及性不足，進而規劃區內資源補強方案。	{https://data.taipei/dataset/detail?id=f2a66aec-9b15-4580-9d04-9e991d45e908,https://data.taipei/dataset/detail?id=6f830d1c-b595-4c08-8b05-4430d247a0db,https://data.taipei/dataset/detail?id=0db13d34-51e3-497a-a023-286d5ef692ea,https://data.taipei/dataset/detail?id=96f143fe-4c95-4d88-9985-77f28e2d2c3d,https://data.gov.tw/dataset/123304}	\N	2025-05-31 16:47:06.583275+00	2025-06-01 00:43:52.157436+00	two_d	WITH ntp_child_vaccines AS (\n    -- 拆分新北市幼兒疫苗資料的疫苗欄位，將逗號分隔的疫苗種類展開為多行\n    SELECT \n        district,\n        hosp_name\n    FROM vaccine_ntp_type,\n    LATERAL unnest(string_to_array(vaccine, '、')) AS vaccine_type\n    WHERE district IS NOT NULL \n        AND vaccine IS NOT NULL \n        AND vaccine != ''\n),\nntp_general_vaccines AS (\n    -- 處理新北市一般疫苗資料\n    SELECT \n        district,\n        name AS hosp_name\n    FROM vaccine_ntp\n    WHERE district IS NOT NULL\n),\nntp_combined_vaccines AS (\n    -- 聯集新北市幼兒疫苗和一般疫苗資料\n    SELECT district, hosp_name\n    FROM ntp_child_vaccines\n    UNION\n    SELECT district, hosp_name\n    FROM ntp_general_vaccines\n),\nntp_distinct_counts AS (\n    -- 新北市：去重複，按行政區分組，計算醫療院所總數\n    SELECT \n        district,\n        CAST(COUNT(DISTINCT hosp_name) AS FLOAT) AS count\n    FROM ntp_combined_vaccines\n    GROUP BY district\n),\ntp_combined_data AS (\n    -- 台北市：聯集各類疫苗資料\n    SELECT district\n    FROM vaccine_tp_below3\n    WHERE district IS NOT NULL\n    UNION ALL\n    SELECT district\n    FROM hpv_vaccine\n    WHERE district IS NOT NULL\n    UNION ALL\n    SELECT district\n    FROM vaccine_tp_3\n    WHERE district IS NOT NULL\n    UNION ALL\n    SELECT district\n    FROM vaccine_tp_adult\n    WHERE district IS NOT NULL\n),\ntp_counts AS (\n    -- 台北市：按行政區分組，計算醫療院所總數\n    SELECT \n        district,\n        CAST(COUNT(*) AS FLOAT) AS count\n    FROM tp_combined_data\n    GROUP BY district\n),\ncombined_counts AS (\n    -- 聯集新北市和台北市的統計結果，並按行政區加總\n    SELECT \n        district,\n        SUM(count) AS count\n    FROM (\n        SELECT district, count FROM ntp_distinct_counts\n        UNION ALL\n        SELECT district, count FROM tp_counts\n    ) AS subquery\n    GROUP BY district\n),\nsorted_districts AS (\n    -- 定義行政區排序\n    SELECT \n        district,\n        count,\n        CASE district\n            WHEN '北投區' THEN 1\n            WHEN '士林區' THEN 2\n            WHEN '內湖區' THEN 3\n            WHEN '南港區' THEN 4\n            WHEN '松山區' THEN 5\n            WHEN '信義區' THEN 6\n            WHEN '中山區' THEN 7\n            WHEN '大同區' THEN 8\n            WHEN '中正區' THEN 9\n            WHEN '萬華區' THEN 10\n            WHEN '大安區' THEN 11\n            WHEN '文山區' THEN 12\n            WHEN '新莊區' THEN 13\n            WHEN '淡水區' THEN 14\n            WHEN '汐止區' THEN 15\n            WHEN '板橋區' THEN 16\n            WHEN '三重區' THEN 17\n            WHEN '樹林區' THEN 18\n            WHEN '土城區' THEN 19\n            WHEN '蘆洲區' THEN 20\n            WHEN '中和區' THEN 21\n            WHEN '永和區' THEN 22\n            WHEN '新店區' THEN 23\n            WHEN '鶯歌區' THEN 24\n            WHEN '三峽區' THEN 25\n            WHEN '瑞芳區' THEN 26\n            WHEN '五股區' THEN 27\n            WHEN '泰山區' THEN 28\n            WHEN '林口區' THEN 29\n            WHEN '深坑區' THEN 30\n            WHEN '石碇區' THEN 31\n            WHEN '坪林區' THEN 32\n            WHEN '三芝區' THEN 33\n            WHEN '石門區' THEN 34\n            WHEN '八里區' THEN 35\n            WHEN '平溪區' THEN 36\n            WHEN '雙溪區' THEN 37\n            WHEN '貢寮區' THEN 38\n            WHEN '金山區' THEN 39\n            WHEN '萬里區' THEN 40\n            WHEN '烏來區' THEN 41\n            ELSE 42\n        END AS district_order\n    FROM combined_counts\n)\n-- 最終結果，按行政區順序排序，格式化為 2D 地圖所需欄位\nSELECT \n    district AS x_axis,\n    count AS data\nFROM sorted_districts\nORDER BY district_order;	\N	metrotaipei
city_age_distribution	null	\N	null	static	\N	\N	\N	主計處	顯示雙北年齡分區	顯示雙北地區年齡分區，將人口依年齡群體劃分至不同城市區域。此分區有助於了解臺北市與新北市在人口結構上的差異與分布情形，包括各行政區的老化程度、青壯年與幼年人口比例，為政策制定者、城市規劃者及研究人員提供精確的分析依據。透過此資料，可進行跨區域的公共資源配置、社區規劃與長期照護服務設計，確保雙北地區在教育、交通、醫療與社福等層面能因應不同年齡層需求，促進整體都市發展的均衡與永續。	使用於城市規劃、社會政策制定及人口統計分析，雙北地區年齡分區數據可協助政府與研究機構掌握人口結構的變化情形。此指標適用於評估各年齡層在臺北市與新北市的區域分布，有助於規劃教育資源配置、醫療設施布建及長照服務佈點。除此之外，企業亦可依據此數據進行市場分析，針對不同年齡族群設計產品與服務，強化區域經營策略的精準度與效益。此資料為雙北區域在政策與產業發展上的重要基礎依據。	{https://data.taipei/dataset/detail?id=1e0c58e9-6aa5-4acb-a5a1-f60bacad60f3,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}	{doit,ntpc}	2024-11-28 05:56:00+00	2025-05-31 21:03:16.980167+00	three_d	select x_axis,y_axis,round(sum(data)/1000) data\r\nfrom(select 區域別 as x_axis,'0_14歲人口數' as y_axis,percent24 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'15_64歲人口數' as y_axis,percent26 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'65歲以上人口數' as y_axis,percent28 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'0_14歲人口數' as y_axis,percent24 as data\r\nfrom \r\npublic.city_age_distribution_newtaipei \r\nwhere 區域別 not in ('總計','新北市') and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_newtaipei)\r\nunion all\r\nselect 區域別 as x_axis,'15_64歲人口數' as y_axis,percent26 as data\r\nfrom \r\npublic.city_age_distribution_newtaipei \r\nwhere 區域別 not in ('總計','新北市') and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_newtaipei)  \r\nunion all\r\nselect 區域別 as x_axis,'65歲以上人口數' as y_axis,percent28 as data\r\nfrom \r\npublic.city_age_distribution_newtaipei \r\nwhere 區域別 not in ('總計','新北市') and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_newtaipei)\r\n)d\r\ngroup by x_axis,y_axis\r\n	\N	metrotaipei
bike_network	null	{100,101}	{"mode":"byParam","byParam":{"xParam":"direction"}}	static	\N	\N	\N	交通局交工處	顯示雙北當前自行車路網分布。	顯示雙北當前自行車路網分布。雙北擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，雙北政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。	使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2023-12-20 05:56:00+00	2025-06-01 00:44:15.024762+00	two_d	select x_axis,sum(data)data from (select  direction as x_axis ,round(sum(cycling_length)/1000) as data\r\nfrom public.bike_network_tpe  \r\ngroup by direction\r\nunion all\r\nselect  direction as x_axis ,round(sum(cycling_length)/1000) as data\r\nfrom public.bike_network_new_tpe  \r\ngroup by direction\r\n)d\r\nwhere x_axis !=''\r\ngroup by x_axis	\N	metrotaipei
aging_kpi	null	{}	{}	static	\N	0	\N	主計處	此圖顯示雙北長照關懷各項指標。	此圖表呈現雙北長照關懷相關指標，包括 扶老比、扶幼比、扶養比 及 老化指數。扶老比代表每百名勞動人口需扶養的老年人口數，扶幼比則是需扶養的兒童人口數，而扶養比則合計這兩者，反映整體社會負擔程度。老化指數則比較老年人口與兒童人口比例，顯示人口結構的高齡化趨勢。這些數據可用於評估長照需求，並規劃資源分配與政策方向，以因應人口老化帶來的挑戰。	在制定長照政策時，政府可運用 扶老比、扶幼比、扶養比 及 老化指數 來評估未來照護需求。例如，某城市發現扶老比上升且老化指數超過 100，代表老年人口已多於兒童，預示長照需求將持續增加。政府可據此增設長照機構、強化居家照護服務，並鼓勵社區共融計畫，以減輕勞動人口的扶養壓力，確保高齡者獲得適切照顧。	{https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}	{doit,ntpc}	2023-12-20 05:56:00+00	2025-05-31 21:03:26.245019+00	three_d	select y_axis,icon ,round(avg(data))data  \r\nfrom(\r\nselect '扶老比' as y_axis, percent30 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶幼比' as y_axis, percent31 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶養比' as y_axis, percent32 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '老化指數' as y_axis, percent33 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶老比' as y_axis, avg(percent30) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型='計'\r\nunion all\r\nselect '扶幼比' as y_axis, avg(percent31) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei ) and 統計類型='計'\r\nunion all\r\nselect '扶養比' as y_axis, avg(percent32) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型='計'\r\nunion all\r\nselect '老化指數' as y_axis, avg(percent33) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型='計'\r\n)d\r\ngroup by y_axis,icon	\N	metrotaipei
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, access_control, modify, read) FROM stdin;
1	admin	t	t	t
2	editor	f	t	t
3	viewer	f	f	t
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: view_points; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.view_points (id, user_id, center_x, center_y, zoom, pitch, bearing, name, point_type) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: auth_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_users_id_seq', 1, true);


--
-- Name: component_maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.component_maps_id_seq', 2, true);


--
-- Name: components_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.components_id_seq', 9, true);


--
-- Name: contributors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contributors_id_seq', 1, false);


--
-- Name: dashboards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dashboards_id_seq', 369, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 4, true);


--
-- Name: incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incidents_id_seq', 1, false);


--
-- Name: issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.issues_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- Name: view_points_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.view_points_id_seq', 1, true);


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: postgres
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: auth_user_group_roles auth_user_group_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT auth_user_group_roles_pkey PRIMARY KEY (auth_user_id, group_id, role_id);


--
-- Name: auth_users auth_users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_email_key UNIQUE (email);


--
-- Name: auth_users auth_users_idno_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_idno_key UNIQUE (idno);


--
-- Name: auth_users auth_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_pkey PRIMARY KEY (id);


--
-- Name: auth_users auth_users_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_uuid_key UNIQUE (uuid);


--
-- Name: component_charts component_charts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_charts
    ADD CONSTRAINT component_charts_pkey PRIMARY KEY (index);


--
-- Name: component_maps component_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_maps
    ADD CONSTRAINT component_maps_pkey PRIMARY KEY (id);


--
-- Name: components components_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.components
    ADD CONSTRAINT components_index_key UNIQUE (index);


--
-- Name: components components_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.components
    ADD CONSTRAINT components_pkey PRIMARY KEY (id);


--
-- Name: contributors contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT contributors_pkey PRIMARY KEY (id);


--
-- Name: dashboard_groups dashboard_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_groups
    ADD CONSTRAINT dashboard_groups_pkey PRIMARY KEY (dashboard_id, group_id);


--
-- Name: dashboards dashboards_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboards
    ADD CONSTRAINT dashboards_index_key UNIQUE (index);


--
-- Name: dashboards dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboards
    ADD CONSTRAINT dashboards_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: query_charts query_charts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.query_charts
    ADD CONSTRAINT query_charts_pkey PRIMARY KEY (index, city);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: view_points view_points_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.view_points
    ADD CONSTRAINT view_points_pkey PRIMARY KEY (id);


--
-- Name: auth_user_group_roles fk_auth_user_group_roles_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT fk_auth_user_group_roles_auth_user FOREIGN KEY (auth_user_id) REFERENCES public.auth_users(id);


--
-- Name: auth_user_group_roles fk_auth_user_group_roles_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT fk_auth_user_group_roles_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: auth_user_group_roles fk_auth_user_group_roles_role; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT fk_auth_user_group_roles_role FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: dashboard_groups fk_dashboard_groups_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_groups
    ADD CONSTRAINT fk_dashboard_groups_dashboard FOREIGN KEY (dashboard_id) REFERENCES public.dashboards(id);


--
-- Name: dashboard_groups fk_dashboard_groups_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_groups
    ADD CONSTRAINT fk_dashboard_groups_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: groups fk_groups_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_auth_user FOREIGN KEY (create_by) REFERENCES public.auth_users(id);


--
-- Name: view_points fk_view_points_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.view_points
    ADD CONSTRAINT fk_view_points_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_users(id);


--
-- PostgreSQL database dump complete
--

