--
-- PostgreSQL database dump
--

\restrict ikGexjEfnbAEuB3i0nlvH7KjYspW3Au0sxefKDhNZAlxkVjd2wOhl4Ldr25St1y

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg12+1)
-- Dumped by pg_dump version 18.3 (Debian 18.3-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: polla
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO polla;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.app_settings (
    key text NOT NULL,
    value text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.app_settings OWNER TO polla;

--
-- Name: bonus_predictions; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.bonus_predictions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    champion_team_id bigint,
    top_scorer text,
    best_defense_team_id bigint,
    best_player text,
    runner_up_team_id bigint,
    third_place_team_id bigint,
    top_assister text,
    semifinalist_team_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    finalist_team_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    top_scorer_correct boolean,
    top_assister_correct boolean
);


ALTER TABLE public.bonus_predictions OWNER TO polla;

--
-- Name: bonus_predictions_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.bonus_predictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bonus_predictions_id_seq OWNER TO polla;

--
-- Name: bonus_predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.bonus_predictions_id_seq OWNED BY public.bonus_predictions.id;


--
-- Name: group_predictions; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.group_predictions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_id bigint NOT NULL,
    first_team_id bigint NOT NULL,
    second_team_id bigint NOT NULL,
    exact_order boolean DEFAULT false NOT NULL
);


ALTER TABLE public.group_predictions OWNER TO polla;

--
-- Name: group_predictions_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.group_predictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.group_predictions_id_seq OWNER TO polla;

--
-- Name: group_predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.group_predictions_id_seq OWNED BY public.group_predictions.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    tournament_id bigint,
    name text NOT NULL,
    external_id text
);


ALTER TABLE public.groups OWNER TO polla;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_id_seq OWNER TO polla;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.matches (
    id bigint NOT NULL,
    external_id text,
    tournament_id bigint,
    group_id bigint,
    stage text DEFAULT 'GROUP'::text NOT NULL,
    status text DEFAULT 'NOT_STARTED'::text NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    home_team_id bigint NOT NULL,
    away_team_id bigint NOT NULL,
    home_score integer,
    away_score integer,
    winner_team_id bigint,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    round_label text,
    matchday integer,
    prediction_lock_at timestamp with time zone,
    round_key text,
    calendar_date date,
    kickoff_time_local character varying(5),
    score_multiplier numeric(5,2) DEFAULT 1 NOT NULL
);


ALTER TABLE public.matches OWNER TO polla;

--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.matches_id_seq OWNER TO polla;

--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: prediction_scores; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.prediction_scores (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    source_type text NOT NULL,
    source_id bigint NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    breakdown jsonb DEFAULT '{}'::jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.prediction_scores OWNER TO polla;

--
-- Name: prediction_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.prediction_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prediction_scores_id_seq OWNER TO polla;

--
-- Name: prediction_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.prediction_scores_id_seq OWNED BY public.prediction_scores.id;


--
-- Name: predictions; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.predictions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    match_id bigint NOT NULL,
    predicted_home_score integer NOT NULL,
    predicted_away_score integer NOT NULL,
    predicted_advancing_team_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    bracket_home_team_id bigint,
    bracket_away_team_id bigint
);


ALTER TABLE public.predictions OWNER TO polla;

--
-- Name: predictions_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.predictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.predictions_id_seq OWNER TO polla;

--
-- Name: predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.predictions_id_seq OWNED BY public.predictions.id;


--
-- Name: qualifier_predictions; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.qualifier_predictions (
    user_id bigint NOT NULL,
    team_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.qualifier_predictions OWNER TO polla;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.schema_migrations (
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO polla;

--
-- Name: scoring_rules; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.scoring_rules (
    id bigint NOT NULL,
    exact_score_points integer DEFAULT 3 NOT NULL,
    outcome_points integer DEFAULT 1 NOT NULL,
    advancing_team_points integer DEFAULT 2 NOT NULL,
    qualified_team_points integer DEFAULT 2 NOT NULL,
    exact_group_order_points integer DEFAULT 3 NOT NULL,
    champion_points integer DEFAULT 5 NOT NULL,
    top_scorer_points integer DEFAULT 4 NOT NULL,
    best_defense_points integer DEFAULT 4 NOT NULL,
    best_player_points integer DEFAULT 4 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    goal_diff_points integer DEFAULT 2 NOT NULL,
    draw_points integer DEFAULT 3 NOT NULL,
    r8_advance_points integer DEFAULT 8 NOT NULL,
    r8_exact_points integer DEFAULT 5 NOT NULL,
    r4_advance_points integer DEFAULT 12 NOT NULL,
    r4_exact_points integer DEFAULT 7 NOT NULL,
    sf_advance_points integer DEFAULT 18 NOT NULL,
    sf_exact_points integer DEFAULT 10 NOT NULL,
    final_advance_points integer DEFAULT 40 NOT NULL,
    final_exact_points integer DEFAULT 15 NOT NULL,
    semifinalist_points integer DEFAULT 10 NOT NULL,
    semifinalist_max_points integer DEFAULT 40 NOT NULL,
    finalist_points integer DEFAULT 20 NOT NULL,
    finalist_max_points integer DEFAULT 40 NOT NULL,
    runner_up_points integer DEFAULT 20 NOT NULL,
    third_place_points integer DEFAULT 15 NOT NULL,
    top_assister_points integer DEFAULT 20 NOT NULL,
    group_master_bonus integer DEFAULT 5 NOT NULL,
    expert_day_bonus integer DEFAULT 10 NOT NULL,
    invicto_bonus integer DEFAULT 15 NOT NULL
);


ALTER TABLE public.scoring_rules OWNER TO polla;

--
-- Name: scoring_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.scoring_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scoring_rules_id_seq OWNER TO polla;

--
-- Name: scoring_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.scoring_rules_id_seq OWNED BY public.scoring_rules.id;


--
-- Name: standings; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.standings (
    id bigint NOT NULL,
    tournament_id bigint,
    group_id bigint,
    team_id bigint,
    rank integer NOT NULL,
    points integer NOT NULL,
    played integer NOT NULL,
    won integer NOT NULL,
    draw integer NOT NULL,
    lost integer NOT NULL,
    goals_for integer NOT NULL,
    goals_against integer NOT NULL,
    goal_diff integer NOT NULL
);


ALTER TABLE public.standings OWNER TO polla;

--
-- Name: standings_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.standings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.standings_id_seq OWNER TO polla;

--
-- Name: standings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.standings_id_seq OWNED BY public.standings.id;


--
-- Name: sync_runs; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.sync_runs (
    id bigint NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    status text NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.sync_runs OWNER TO polla;

--
-- Name: sync_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.sync_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sync_runs_id_seq OWNER TO polla;

--
-- Name: sync_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.sync_runs_id_seq OWNED BY public.sync_runs.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    external_id text NOT NULL,
    name text NOT NULL,
    short_name text,
    logo_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.teams OWNER TO polla;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO polla;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: tournaments; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.tournaments (
    id bigint NOT NULL,
    name text NOT NULL,
    external_id text,
    season text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tournaments OWNER TO polla;

--
-- Name: tournaments_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.tournaments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournaments_id_seq OWNER TO polla;

--
-- Name: tournaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.tournaments_id_seq OWNED BY public.tournaments.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: polla
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    role text DEFAULT 'USER'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    display_name text,
    amount_paid numeric(12,2) DEFAULT 0 NOT NULL,
    payment_notes text,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.users OWNER TO polla;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: polla
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO polla;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: polla
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: bonus_predictions id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions ALTER COLUMN id SET DEFAULT nextval('public.bonus_predictions_id_seq'::regclass);


--
-- Name: group_predictions id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.group_predictions ALTER COLUMN id SET DEFAULT nextval('public.group_predictions_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: prediction_scores id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.prediction_scores ALTER COLUMN id SET DEFAULT nextval('public.prediction_scores_id_seq'::regclass);


--
-- Name: predictions id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions ALTER COLUMN id SET DEFAULT nextval('public.predictions_id_seq'::regclass);


--
-- Name: scoring_rules id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.scoring_rules ALTER COLUMN id SET DEFAULT nextval('public.scoring_rules_id_seq'::regclass);


--
-- Name: standings id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.standings ALTER COLUMN id SET DEFAULT nextval('public.standings_id_seq'::regclass);


--
-- Name: sync_runs id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.sync_runs ALTER COLUMN id SET DEFAULT nextval('public.sync_runs_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: tournaments id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN id SET DEFAULT nextval('public.tournaments_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.app_settings (key, value, updated_at) FROM stdin;
tournament_season	2026	2026-06-03 00:43:14.278538+00
data_source	manual	2026-06-03 00:43:14.282316+00
tournament_name	Mundial FIFA 2026	2026-06-29 17:02:19.506634+00
prediction_lock_hours_before	0	2026-06-29 17:02:19.50921+00
knockout_predictions_open_date	2026-06-27	2026-06-29 17:02:19.511425+00
knockout_predictions_close_date	2026-06-28	2026-06-29 17:02:19.513632+00
extras_open_date	2026-06-01	2026-06-29 17:02:19.517752+00
extras_close_date	2026-06-17	2026-06-29 17:02:19.520597+00
official_bonus_results	{"championTeamId":null,"runnerUpTeamId":null,"thirdPlaceTeamId":null,"semifinalistTeamIds":[49],"finalistTeamIds":[49]}	2026-07-03 10:11:45.053316+00
official_qualified_team_ids	["1","2","6","5","9","10","13","15","17","19","21","22","25","26","29","30","33","35","37","39","44","41","45","46"]	2026-06-28 03:59:30.897843+00
\.


--
-- Data for Name: bonus_predictions; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.bonus_predictions (id, user_id, champion_team_id, top_scorer, best_defense_team_id, best_player, runner_up_team_id, third_place_team_id, top_assister, semifinalist_team_ids, finalist_team_ids, top_scorer_correct, top_assister_correct) FROM stdin;
124	54	44	Leonel Messi	\N	\N	33	41	Leonel Messi	{33,44,41,9}	{33,44}	\N	\N
78	13	33	Kylian Mbappe	\N	\N	44	29	Olise	{44,33,29,9}	{44,33}	\N	\N
52	38	44	Messi	\N	\N	29	9	Messi	{29,44,33,9}	{29,44}	\N	\N
193	25	44	Mbape	\N	\N	29	33	Messi	{29,44,33,9}	{29,44}	\N	\N
15	1	\N	\N	\N	\N	\N	\N	\N	{}	{}	\N	\N
48	37	37	messi	\N	\N	33	9	messi	{33,37,25,9}	{33,37}	\N	\N
89	10	44	Mbappe	\N	\N	33	41	James Rodríguez	{33,44,41,9}	{33,44}	\N	\N
13	41	33	mbappe	\N	\N	45	41	Olise	{33,45,41,37}	{33,45}	\N	\N
99	14	33	Kylian Mbappe	\N	\N	44	29	Lamine yamal	{33,44,29,9}	{33,44}	\N	\N
197	50	29	Mbappe	\N	\N	37	33	James Rodríguez	{29,37,33,45}	{29,37}	\N	\N
44	59	44	Kylian mbappe	\N	\N	33	9	James Rodríguez	{33,44,13,9}	{33,44}	\N	\N
223	68	44	Messi	\N	\N	33	9	Olise	{33,44,41,9}	{33,44}	\N	\N
5969	17	\N	\N	\N	\N	\N	\N	\N	{}	{}	\N	\N
266	35	33	Messi	\N	\N	37	29	Gustavo puerta	{33,37,29,45}	{33,37}	\N	\N
5987	39	\N	\N	\N	\N	\N	\N	\N	{}	{}	\N	\N
49	36	44	Leonel Messi	\N	\N	17	\N	Joshua kimmich	{17,44,41,9}	{17,44}	\N	\N
183	46	33	Mbappe	\N	\N	45	41	Kimmich	{33,45,41,37}	{33,45}	\N	\N
411	47	33	Lucho	\N	\N	37	9	Messi	{33,37,29,9}	{33,37}	\N	\N
159	16	\N	Kilyan mbappe	\N	\N	\N	\N	Michael Olise	{}	{}	\N	\N
84	12	44	Mbappe	\N	\N	33	9	James Rodríguez	{33,44,41,9}	{33,44}	\N	\N
253	66	44	Messi	\N	\N	33	9	Depoul	{33,44,41,9}	{33,44}	\N	\N
166	30	33	Mbappe	\N	\N	35	37	Leonel Messi	{33,35,41,37}	{33,35}	\N	\N
31	51	33	Mbappe	\N	\N	37	29	Olise	{33,37,29,9}	{33,37}	\N	\N
7	24	33	Kylian Mbappe	\N	\N	44	29	Joshua Kimmich	{33,44,29,45}	{33,44}	\N	\N
10	15	37	Messi	\N	\N	33	9	Olisse	{33,37,29,9}	{33,37}	\N	\N
261	44	44	Leonel Messi	\N	\N	41	21	De Paul	{41,44,21,9}	{41,44}	\N	\N
11	27	44	Mbape	\N	\N	33	29	Lionel messi	{33,44,29,45}	{33,44}	\N	\N
120	33	33	Messi	\N	\N	37	9	Messi	{33,37,29,9}	{33,37}	\N	\N
202	26	29	Leonel Messi	\N	\N	9	44	Leonel Messi	{29,9,17,44}	{29,9}	\N	\N
178	31	33	Leonel messi	\N	\N	37	29	Michael olise	{33,37,29,45}	{33,37}	\N	\N
269	23	33	Kylian Mbappe	\N	\N	37	9	Joshua Kimmich	{33,37,41,9}	{33,37}	\N	\N
809	28	33	\N	\N	\N	37	41	\N	{33,37,41,45}	{33,37}	\N	\N
6	11	33	Kylian Mbappe	\N	\N	44	41	Michael Olise	{33,44,41,45}	{33,44}	\N	\N
26	42	44	Leonel messi	\N	\N	29	33	Olisse	{29,44,33,45}	{29,44}	\N	\N
63	9	44	Mbappe	\N	\N	33	45	Luis Díaz	{33,44,41,45}	{33,44}	\N	\N
64	32	33	Haaland	\N	\N	37	9	Lionel Messi	{33,37,29,9}	{33,37}	\N	\N
51	45	44	Kylian Mbapee	\N	\N	29	33	Lionel Messi	{29,44,33,45}	{29,44}	\N	\N
72	29	44	Messi	\N	\N	41	45	James	{41,44,17,45}	{41,44}	\N	\N
128	43	33	Mbappe	\N	\N	45	29	Olise	{33,45,29,37}	{33,45}	\N	\N
127	56	37	Kylian Mbappé	\N	\N	33	41	Jude Bellingham	{33,37,41,9}	{33,37}	\N	\N
299	58	41	Kylian Mbappé	\N	\N	37	33	Jude Bellingham	{41,37,33,9}	{41,37}	\N	\N
14	18	\N	Haaland	\N	\N	\N	\N	Messi	{}	{}	\N	\N
257	55	33	Messi	\N	\N	37	29	Olise	{33,37,29,45}	{33,37}	\N	\N
28	48	44	Kylian Mbappé	\N	\N	33	41	Lionel messi	{44,33,41,9}	{44,33}	\N	\N
147	34	33	Kylian Mbappe	\N	\N	9	44	Lionel Messi	{33,9,34,44}	{33,9}	\N	\N
50	40	44	Lionel Messi	\N	\N	21	34	Lionel Messi	{21,44,34,20}	{21,44}	\N	\N
\.


--
-- Data for Name: group_predictions; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.group_predictions (id, user_id, group_id, first_team_id, second_team_id, exact_order) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.groups (id, tournament_id, name, external_id) FROM stdin;
1	1	Grupo A	GROUP_A
2	1	Grupo B	GROUP_B
3	1	Grupo C	GROUP_C
4	1	Grupo D	GROUP_D
5	1	Grupo E	GROUP_E
6	1	Grupo F	GROUP_F
7	1	Grupo G	GROUP_G
8	1	Grupo H	GROUP_H
9	1	Grupo I	GROUP_I
10	1	Grupo J	GROUP_J
11	1	Grupo K	GROUP_K
12	1	Grupo L	GROUP_L
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.matches (id, external_id, tournament_id, group_id, stage, status, starts_at, home_team_id, away_team_id, home_score, away_score, winner_team_id, updated_at, round_label, matchday, prediction_lock_at, round_key, calendar_date, kickoff_time_local, score_multiplier) FROM stdin;
79	wc2026-ko-79	1	\N	KNOCKOUT	FINISHED	2026-07-01 01:00:00+00	1	20	2	0	1	2026-07-01 04:01:26.335143+00	Dieciseisavos · Partido 79 · 1º Grupo A vs 3º Grupo C/E/F/H/I	\N	2026-06-30 01:00:00+00	R16	2026-06-30	20:00	1.00
80	wc2026-ko-80	1	\N	KNOCKOUT	FINISHED	2026-07-01 18:00:00+00	45	42	2	1	45	2026-07-01 18:01:37.841998+00	Dieciseisavos · Partido 80 · 1º Grupo L vs 3º Grupo E/H/I/J/K	\N	2026-06-30 18:00:00+00	R16	2026-07-01	13:00	1.00
82	wc2026-ko-82	1	\N	KNOCKOUT	FINISHED	2026-07-02 00:00:00+00	25	34	3	2	25	2026-07-01 22:49:45.252679+00	Dieciseisavos · Partido 82 · 1º Grupo G vs 3º Grupo A/E/H/I/J	\N	2026-07-01 00:00:00+00	R16	2026-07-01	19:00	1.00
81	wc2026-ko-81	1	\N	KNOCKOUT	FINISHED	2026-07-01 21:00:00+00	13	8	2	0	13	2026-07-02 02:09:29.162918+00	Dieciseisavos · Partido 81 · 1º Grupo D vs 3º Grupo B/E/F/I/J	\N	2026-06-30 21:00:00+00	R16	2026-07-01	16:00	1.00
84	wc2026-ko-84	1	\N	KNOCKOUT	FINISHED	2026-07-02 22:00:00+00	29	39	3	0	29	2026-07-02 21:00:17.325801+00	Dieciseisavos · Partido 84 · 1º Grupo H vs 2º Grupo J	\N	2026-07-01 22:00:00+00	R16	2026-07-02	17:00	1.00
83	wc2026-ko-83	1	\N	KNOCKOUT	FINISHED	2026-07-02 18:00:00+00	41	46	2	1	41	2026-07-03 01:09:56.621687+00	Dieciseisavos · Partido 83 · 2º Grupo K vs 2º Grupo L	\N	2026-07-01 18:00:00+00	R16	2026-07-02	13:00	1.00
85	wc2026-ko-85	1	\N	KNOCKOUT	FINISHED	2026-07-03 01:00:00+00	6	38	2	0	6	2026-07-03 10:11:31.715113+00	Dieciseisavos · Partido 85 · 1º Grupo B vs 3º Grupo E/F/G/I/J	\N	2026-07-02 01:00:00+00	R16	2026-07-02	20:00	1.00
2	wc2026-match-002	1	1	GROUP	FINISHED	2026-06-12 02:00:00+00	3	4	2	1	3	2026-06-12 03:55:42.948018+00	Fase de grupos · J1 · Estadio Akron	1	\N	GROUP	2026-06-11	20:00	1.00
6	wc2026-match-006	1	4	GROUP	FINISHED	2026-06-15 04:00:00+00	15	16	2	0	15	2026-06-14 22:31:23.846667+00	Fase de grupos · J1 · BC Place	1	\N	GROUP	2026-06-13	21:00	1.00
37	wc2026-match-037	1	8	GROUP	FINISHED	2026-06-21 22:00:00+00	32	30	2	2	\N	2026-06-22 00:05:12.771369+00	Fase de grupos · J2 · Hard Rock Stadium	2	\N	GROUP	2026-06-21	18:00	1.00
86	wc2026-ko-86	1	\N	KNOCKOUT	NOT_STARTED	2026-07-03 19:00:00+00	37	30	\N	\N	\N	2026-06-28 04:50:12.326656+00	Dieciseisavos · Partido 86 · 1º Grupo J vs 2º Grupo H	\N	2026-07-02 19:00:00+00	R16	2026-07-03	14:00	1.00
91	wc2026-ko-91	1	\N	KNOCKOUT	NOT_STARTED	2026-07-05 21:00:00+00	9	35	\N	\N	\N	2026-06-30 18:59:16.672784+00	Octavos de final · Partido 91 · Ganador partido 76 vs Ganador partido 78	\N	2026-07-04 21:00:00+00	R8	2026-07-05	16:00	1.00
90	wc2026-ko-90	1	\N	KNOCKOUT	NOT_STARTED	2026-07-05 01:30:00+00	5	10	\N	\N	\N	2026-06-30 03:54:24.438012+00	Octavos de final · Partido 90 · Ganador partido 73 vs Ganador partido 75	\N	2026-07-04 01:30:00+00	R8	2026-07-04	20:30	1.00
94	wc2026-ko-94	1	\N	KNOCKOUT	NOT_STARTED	2026-07-07 00:00:00+00	13	25	\N	\N	\N	2026-07-02 02:09:45.629046+00	Octavos de final · Partido 94 · Ganador partido 81 vs Ganador partido 82	\N	2026-07-06 00:00:00+00	R8	2026-07-06	19:00	1.00
87	wc2026-ko-87	1	\N	KNOCKOUT	NOT_STARTED	2026-07-03 22:30:00+00	44	47	\N	\N	\N	2026-06-28 04:50:12.328685+00	Dieciseisavos · Partido 87 · 1º Grupo K vs 3º Grupo D/E/I/J/L	\N	2026-07-02 22:30:00+00	R16	2026-07-03	17:30	1.00
88	wc2026-ko-88	1	\N	KNOCKOUT	NOT_STARTED	2026-07-04 01:00:00+00	15	26	\N	\N	\N	2026-06-28 04:50:12.332673+00	Dieciseisavos · Partido 88 · 2º Grupo D vs 2º Grupo G	\N	2026-07-03 01:00:00+00	R16	2026-07-03	20:00	1.00
95	wc2026-ko-95	1	\N	KNOCKOUT	NOT_STARTED	2026-07-07 21:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.428051+00	Octavos de final · Partido 95 · Ganador partido 86 vs Ganador partido 88	\N	2026-07-06 21:00:00+00	R8	2026-07-07	16:00	1.00
96	wc2026-ko-96	1	\N	KNOCKOUT	NOT_STARTED	2026-07-08 00:00:00+00	6	49	\N	\N	\N	2026-07-03 12:30:22.430095+00	Octavos de final · Partido 96 · Ganador partido 85 vs Ganador partido 87	\N	2026-07-07 00:00:00+00	R8	2026-07-07	19:00	1.00
97	wc2026-ko-97	1	\N	KNOCKOUT	NOT_STARTED	2026-07-10 01:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.431772+00	Cuartos de final · Partido 97 · Ganador octavos 89 vs Ganador octavos 90	\N	2026-07-09 01:00:00+00	R4	2026-07-09	20:00	1.00
89	wc2026-ko-89	1	\N	KNOCKOUT	NOT_STARTED	2026-07-04 22:00:00+00	14	33	\N	\N	\N	2026-06-30 22:54:24.056992+00	Octavos de final · Partido 89 · Ganador partido 74 vs Ganador partido 77	\N	2026-07-03 22:00:00+00	R8	2026-07-04	17:00	1.00
98	wc2026-ko-98	1	\N	KNOCKOUT	NOT_STARTED	2026-07-10 01:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.433487+00	Cuartos de final · Partido 98 · Ganador octavos 93 vs Ganador octavos 94	\N	2026-07-09 01:00:00+00	R4	2026-07-09	20:00	1.00
8	wc2026-match-008	1	2	GROUP	FINISHED	2026-06-13 19:00:00+00	7	6	1	1	\N	2026-06-13 21:04:37.128305+00	Fase de grupos · J1 · Levi's Stadium	1	\N	GROUP	2026-06-13	12:00	1.00
7	wc2026-match-007	1	3	GROUP	FINISHED	2026-06-13 22:00:00+00	9	10	1	1	\N	2026-06-14 00:05:38.517507+00	Fase de grupos · J1 · MetLife Stadium	1	\N	GROUP	2026-06-13	18:00	1.00
9	wc2026-match-009	1	5	GROUP	FINISHED	2026-06-14 23:00:00+00	19	20	1	0	19	2026-06-15 01:04:22.452934+00	Fase de grupos · J1 · Lincoln Financial Field	1	\N	GROUP	2026-06-14	19:00	1.00
28	wc2026-match-028	1	1	GROUP	FINISHED	2026-06-19 01:00:00+00	1	3	1	0	1	2026-06-19 02:56:40.647747+00	Fase de grupos · J2 · Estadio Akron	2	\N	GROUP	2026-06-18	19:00	1.00
99	wc2026-ko-99	1	\N	KNOCKOUT	NOT_STARTED	2026-07-11 01:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.435167+00	Cuartos de final · Partido 99 · Ganador octavos 91 vs Ganador octavos 92	\N	2026-07-10 01:00:00+00	R4	2026-07-10	20:00	1.00
100	wc2026-ko-100	1	\N	KNOCKOUT	NOT_STARTED	2026-07-11 01:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.436744+00	Cuartos de final · Partido 100 · Ganador octavos 95 vs Ganador octavos 96	\N	2026-07-10 01:00:00+00	R4	2026-07-10	20:00	1.00
93	wc2026-ko-93	1	\N	KNOCKOUT	NOT_STARTED	2026-07-06 21:00:00+00	41	29	\N	\N	\N	2026-07-03 01:10:04.639369+00	Octavos de final · Partido 93 · Ganador partido 83 vs Ganador partido 84	\N	2026-07-05 21:00:00+00	R8	2026-07-06	16:00	1.00
92	wc2026-ko-92	1	\N	KNOCKOUT	NOT_STARTED	2026-07-06 00:00:00+00	1	45	\N	\N	\N	2026-07-01 18:01:21.134104+00	Octavos de final · Partido 92 · Ganador partido 79 vs Ganador partido 80	\N	2026-07-05 00:00:00+00	R8	2026-07-05	19:00	1.00
14	wc2026-match-014	1	8	GROUP	FINISHED	2026-06-15 16:00:00+00	29	30	0	0	\N	2026-06-15 17:56:26.139302+00	Fase de grupos · J1 · Mercedes-Benz Stadium	1	\N	GROUP	2026-06-15	12:00	1.00
12	wc2026-match-012	1	6	GROUP	FINISHED	2026-06-15 02:00:00+00	23	24	5	1	23	2026-06-15 03:59:17.347765+00	Fase de grupos · J1 · Estadio BBVA	1	\N	GROUP	2026-06-14	20:00	1.00
17	wc2026-match-017	1	9	GROUP	FINISHED	2026-06-16 19:00:00+00	33	34	3	1	33	2026-06-16 21:05:51.415229+00	Fase de grupos · J1 · MetLife Stadium	1	\N	GROUP	2026-06-16	15:00	1.00
16	wc2026-match-016	1	7	GROUP	FINISHED	2026-06-15 19:00:00+00	25	26	1	1	\N	2026-06-15 20:58:37.898391+00	Fase de grupos · J1 · Lumen Field	1	\N	GROUP	2026-06-15	12:00	1.00
15	wc2026-match-015	1	7	GROUP	FINISHED	2026-06-16 01:00:00+00	27	28	2	2	\N	2026-06-16 03:04:04.917723+00	Fase de grupos · J1 · SoFi Stadium	1	\N	GROUP	2026-06-15	18:00	1.00
13	wc2026-match-013	1	8	GROUP	FINISHED	2026-06-15 22:00:00+00	31	32	1	1	\N	2026-06-16 00:04:29.245972+00	Fase de grupos · J1 · Hard Rock Stadium	1	\N	GROUP	2026-06-15	18:00	1.00
18	wc2026-match-018	1	9	GROUP	FINISHED	2026-06-16 22:00:00+00	36	35	1	4	35	2026-06-17 00:01:00.945712+00	Fase de grupos · J1 · Gillette Stadium	1	\N	GROUP	2026-06-16	18:00	1.00
19	wc2026-match-019	1	10	GROUP	FINISHED	2026-06-17 01:00:00+00	37	38	3	0	37	2026-06-17 02:59:41.354563+00	Fase de grupos · J1 · Arrowhead Stadium	1	\N	GROUP	2026-06-16	20:00	1.00
23	wc2026-match-023	1	11	GROUP	FINISHED	2026-06-17 17:00:00+00	41	42	1	1	\N	2026-06-17 18:59:57.478759+00	Fase de grupos · J1 · NRG Stadium	1	\N	GROUP	2026-06-17	12:00	1.00
21	wc2026-match-021	1	12	GROUP	FINISHED	2026-06-17 23:00:00+00	47	48	1	0	47	2026-06-18 01:04:09.036101+00	Fase de grupos · J1 · BMO Field	1	\N	GROUP	2026-06-17	19:00	1.00
22	wc2026-match-022	1	12	GROUP	FINISHED	2026-06-17 20:00:00+00	45	46	4	2	45	2026-06-17 22:02:01.420939+00	Fase de grupos · J1 · AT&T Stadium	1	\N	GROUP	2026-06-17	15:00	1.00
24	wc2026-match-024	1	11	GROUP	FINISHED	2026-06-18 02:00:00+00	43	44	1	3	44	2026-06-18 04:01:39.53559+00	Fase de grupos · J1 · Estadio Azteca	1	\N	GROUP	2026-06-17	20:00	3.00
26	wc2026-match-026	1	2	GROUP	FINISHED	2026-06-18 19:00:00+00	6	8	4	1	6	2026-06-18 20:58:45.134162+00	Fase de grupos · J2 · SoFi Stadium	2	\N	GROUP	2026-06-18	12:00	1.00
27	wc2026-match-027	1	2	GROUP	FINISHED	2026-06-18 22:00:00+00	5	7	6	0	5	2026-06-18 23:59:27.394402+00	Fase de grupos · J2 · BC Place	2	\N	GROUP	2026-06-18	15:00	1.00
32	wc2026-match-032	1	4	GROUP	FINISHED	2026-06-19 19:00:00+00	13	15	2	0	13	2026-06-19 21:04:40.395533+00	Fase de grupos · J2 · Lumen Field	2	\N	GROUP	2026-06-19	12:00	1.00
30	wc2026-match-030	1	3	GROUP	FINISHED	2026-06-19 22:00:00+00	12	10	0	1	10	2026-06-19 23:59:15.932549+00	Fase de grupos · J2 · Gillette Stadium	2	\N	GROUP	2026-06-19	18:00	1.00
31	wc2026-match-031	1	4	GROUP	FINISHED	2026-06-20 03:00:00+00	16	14	0	1	14	2026-06-20 05:05:41.039859+00	Fase de grupos · J2 · Levi's Stadium	2	\N	GROUP	2026-06-19	20:00	1.00
35	wc2026-match-035	1	6	GROUP	FINISHED	2026-06-20 17:00:00+00	21	23	5	1	21	2026-06-20 18:56:55.062537+00	Fase de grupos · J2 · NRG Stadium	2	\N	GROUP	2026-06-20	12:00	1.00
33	wc2026-match-033	1	5	GROUP	FINISHED	2026-06-20 20:00:00+00	17	19	2	1	17	2026-06-20 22:00:22.201637+00	Fase de grupos · J2 · BMO Field	2	\N	GROUP	2026-06-20	16:00	1.00
34	wc2026-match-034	1	5	GROUP	FINISHED	2026-06-21 00:00:00+00	20	18	0	0	\N	2026-06-21 01:55:38.187748+00	Fase de grupos · J2 · Arrowhead Stadium	2	\N	GROUP	2026-06-20	19:00	1.00
36	wc2026-match-036	1	6	GROUP	FINISHED	2026-06-21 04:00:00+00	24	22	0	4	22	2026-06-21 05:56:37.429015+00	Fase de grupos · J2 · Estadio BBVA	2	\N	GROUP	2026-06-20	22:00	1.00
38	wc2026-match-038	1	8	GROUP	FINISHED	2026-06-21 16:00:00+00	29	31	4	0	29	2026-06-21 18:01:27.860803+00	Fase de grupos · J2 · Mercedes-Benz Stadium	2	\N	GROUP	2026-06-21	12:00	1.00
4	wc2026-match-004	1	4	GROUP	FINISHED	2026-06-13 01:00:00+00	13	14	4	1	13	2026-06-13 03:03:24.006735+00	Fase de grupos · J1 · SoFi Stadium	1	\N	GROUP	2026-06-12	18:00	1.00
44	wc2026-match-044	1	10	GROUP	FINISHED	2026-06-23 03:00:00+00	40	38	1	2	38	2026-06-23 05:02:56.40016+00	Fase de grupos · J2 · Levi's Stadium	2	\N	GROUP	2026-06-22	20:00	1.00
47	wc2026-match-047	1	11	GROUP	FINISHED	2026-06-23 17:00:00+00	41	43	5	0	41	2026-06-23 19:00:05.935824+00	Fase de grupos · J2 · NRG Stadium	2	\N	GROUP	2026-06-23	12:00	1.00
46	wc2026-match-046	1	12	GROUP	FINISHED	2026-06-23 23:00:00+00	48	46	0	1	46	2026-06-24 00:55:04.638523+00	Fase de grupos · J2 · BMO Field	2	\N	GROUP	2026-06-23	19:00	1.00
48	wc2026-match-048	1	11	GROUP	FINISHED	2026-06-24 02:00:00+00	44	42	1	0	44	2026-06-24 03:57:55.204066+00	Fase de grupos · J2 · Estadio Akron	2	\N	GROUP	2026-06-23	20:00	1.00
45	wc2026-match-045	1	12	GROUP	FINISHED	2026-06-23 20:00:00+00	45	47	0	0	\N	2026-06-23 22:01:20.230457+00	Fase de grupos · J2 · Gillette Stadium	2	\N	GROUP	2026-06-23	16:00	1.00
49	wc2026-match-049	1	3	GROUP	FINISHED	2026-06-24 22:00:00+00	12	9	0	3	9	2026-06-25 00:02:15.624079+00	Fase de grupos · J3 · Hard Rock Stadium	3	\N	GROUP	2026-06-24	18:00	1.00
5	wc2026-match-005	1	3	GROUP	FINISHED	2026-06-14 01:00:00+00	11	12	0	1	12	2026-06-14 03:03:07.531219+00	Fase de grupos · J1 · Gillette Stadium	1	\N	GROUP	2026-06-13	21:00	1.00
10	wc2026-match-010	1	5	GROUP	FINISHED	2026-06-14 17:00:00+00	17	18	7	1	17	2026-06-14 19:00:40.882251+00	Fase de grupos · J1 · NRG Stadium	1	\N	GROUP	2026-06-14	12:00	1.00
25	wc2026-match-025	1	1	GROUP	FINISHED	2026-06-18 16:00:00+00	4	2	1	1	\N	2026-06-18 17:59:12.276965+00	Fase de grupos · J2 · Mercedes-Benz Stadium	2	\N	GROUP	2026-06-18	12:00	1.00
39	wc2026-match-039	1	7	GROUP	FINISHED	2026-06-21 19:00:00+00	25	27	0	0	\N	2026-06-21 21:01:06.22925+00	Fase de grupos · J2 · SoFi Stadium	2	\N	GROUP	2026-06-21	12:00	1.00
3	wc2026-match-003	1	2	GROUP	FINISHED	2026-06-12 19:00:00+00	5	8	1	1	\N	2026-06-12 20:58:56.506653+00	Fase de grupos · J1 · BMO Field	1	\N	GROUP	2026-06-12	15:00	1.00
11	wc2026-match-011	1	6	GROUP	FINISHED	2026-06-14 20:00:00+00	21	22	2	2	\N	2026-06-14 21:55:28.322823+00	Fase de grupos · J1 · AT&T Stadium	1	\N	GROUP	2026-06-14	15:00	1.00
20	wc2026-match-020	1	10	GROUP	FINISHED	2026-06-17 04:00:00+00	39	40	3	1	39	2026-06-17 06:09:05.31513+00	Fase de grupos · J1 · Levi's Stadium	1	\N	GROUP	2026-06-16	21:00	1.00
59	wc2026-match-059	1	4	GROUP	FINISHED	2026-06-26 02:00:00+00	16	13	3	2	16	2026-06-26 04:02:25.512009+00	Fase de grupos · J3 · SoFi Stadium	3	\N	GROUP	2026-06-25	19:00	1.00
72	wc2026-match-072	1	11	GROUP	FINISHED	2026-06-27 23:30:00+00	42	43	3	1	42	2026-06-28 01:28:52.900994+00	Fase de grupos · J3 · Mercedes-Benz Stadium	3	\N	GROUP	2026-06-27	19:30	1.00
64	wc2026-match-064	1	7	GROUP	FINISHED	2026-06-27 03:00:00+00	28	25	1	5	25	2026-06-27 04:59:29.011167+00	Fase de grupos · J3 · BC Place	3	\N	GROUP	2026-06-26	20:00	1.00
63	wc2026-match-063	1	7	GROUP	FINISHED	2026-06-27 03:00:00+00	26	27	1	1	\N	2026-06-27 05:04:44.158542+00	Fase de grupos · J3 · Lumen Field	3	\N	GROUP	2026-06-26	20:00	1.00
69	wc2026-match-069	1	10	GROUP	FINISHED	2026-06-28 02:00:00+00	38	39	3	3	\N	2026-06-28 03:59:30.581472+00	Fase de grupos · J3 · Arrowhead Stadium	3	\N	GROUP	2026-06-27	21:00	1.00
76	wc2026-ko-76	1	\N	KNOCKOUT	FINISHED	2026-06-30 02:30:00+00	9	22	2	1	9	2026-06-29 19:03:00.134348+00	Dieciseisavos · Partido 76 · 1º Grupo C vs 2º Grupo F	\N	2026-06-29 02:30:00+00	R16	2026-06-29	21:30	1.00
29	wc2026-match-029	1	3	GROUP	FINISHED	2026-06-20 01:00:00+00	9	11	3	0	9	2026-06-20 02:31:47.198341+00	Fase de grupos · J2 · Lincoln Financial Field	2	\N	GROUP	2026-06-19	21:00	1.00
42	wc2026-match-042	1	9	GROUP	FINISHED	2026-06-22 21:00:00+00	33	36	3	0	33	2026-06-23 00:49:11.717473+00	Fase de grupos · J2 · Lincoln Financial Field	2	\N	GROUP	2026-06-22	17:00	1.00
41	wc2026-match-041	1	9	GROUP	FINISHED	2026-06-23 00:00:00+00	35	34	3	2	35	2026-06-23 01:59:36.950236+00	Fase de grupos · J2 · MetLife Stadium	2	\N	GROUP	2026-06-22	20:00	1.00
52	wc2026-match-052	1	2	GROUP	FINISHED	2026-06-24 19:00:00+00	8	7	3	1	8	2026-06-24 20:59:30.632539+00	Fase de grupos · J3 · Lumen Field	3	\N	GROUP	2026-06-24	12:00	1.00
1	wc2026-match-001	1	1	GROUP	FINISHED	2026-06-11 19:00:00+00	1	2	2	0	1	2026-06-11 21:05:28.059749+00	Fase de grupos · J1 · Estadio Azteca	1	\N	GROUP	2026-06-11	13:00	1.00
51	wc2026-match-051	1	2	GROUP	FINISHED	2026-06-24 19:00:00+00	6	5	2	1	6	2026-06-24 20:59:46.63834+00	Fase de grupos · J3 · BC Place	3	\N	GROUP	2026-06-24	12:00	1.00
54	wc2026-match-054	1	1	GROUP	FINISHED	2026-06-25 01:00:00+00	2	3	1	0	2	2026-06-25 02:58:49.406375+00	Fase de grupos · J3 · Estadio BBVA	3	\N	GROUP	2026-06-24	19:00	1.00
56	wc2026-match-056	1	5	GROUP	FINISHED	2026-06-25 20:00:00+00	20	17	2	1	20	2026-06-25 21:58:38.708732+00	Fase de grupos · J3 · MetLife Stadium	3	\N	GROUP	2026-06-25	16:00	1.00
50	wc2026-match-050	1	3	GROUP	FINISHED	2026-06-24 22:00:00+00	10	11	4	2	10	2026-06-25 00:02:46.263282+00	Fase de grupos · J3 · Mercedes-Benz Stadium	3	\N	GROUP	2026-06-24	18:00	1.00
55	wc2026-match-055	1	5	GROUP	FINISHED	2026-06-25 20:00:00+00	18	19	0	2	19	2026-06-25 22:00:01.120434+00	Fase de grupos · J3 · Lincoln Financial Field	3	\N	GROUP	2026-06-25	16:00	1.00
58	wc2026-match-058	1	6	GROUP	FINISHED	2026-06-25 23:00:00+00	24	21	1	3	21	2026-06-26 00:56:49.991003+00	Fase de grupos · J3 · Arrowhead Stadium	3	\N	GROUP	2026-06-25	18:00	1.00
57	wc2026-match-057	1	6	GROUP	FINISHED	2026-06-25 23:00:00+00	22	23	1	1	\N	2026-06-26 00:58:54.643966+00	Fase de grupos · J3 · AT&T Stadium	3	\N	GROUP	2026-06-25	18:00	1.00
60	wc2026-match-060	1	4	GROUP	FINISHED	2026-06-26 02:00:00+00	14	15	0	0	\N	2026-06-26 03:59:47.979263+00	Fase de grupos · J3 · Levi's Stadium	3	\N	GROUP	2026-06-25	19:00	1.00
61	wc2026-match-061	1	9	GROUP	FINISHED	2026-06-26 19:00:00+00	35	33	1	4	33	2026-06-26 21:01:47.601382+00	Fase de grupos · J3 · Gillette Stadium	3	\N	GROUP	2026-06-26	15:00	1.00
62	wc2026-match-062	1	9	GROUP	FINISHED	2026-06-26 19:00:00+00	34	36	5	0	34	2026-06-26 21:02:03.067725+00	Fase de grupos · J3 · BMO Field	3	\N	GROUP	2026-06-26	15:00	1.00
65	wc2026-match-065	1	8	GROUP	FINISHED	2026-06-27 00:00:00+00	30	31	0	0	\N	2026-06-27 02:02:37.792733+00	Fase de grupos · J3 · NRG Stadium	3	\N	GROUP	2026-06-26	19:00	1.00
66	wc2026-match-066	1	8	GROUP	FINISHED	2026-06-27 00:00:00+00	32	29	0	1	29	2026-06-27 02:02:56.65997+00	Fase de grupos · J3 · Estadio Akron	3	\N	GROUP	2026-06-26	18:00	1.00
67	wc2026-match-067	1	12	GROUP	FINISHED	2026-06-27 21:00:00+00	48	45	0	2	45	2026-06-27 23:00:13.094978+00	Fase de grupos · J3 · MetLife Stadium	3	\N	GROUP	2026-06-27	17:00	1.00
68	wc2026-match-068	1	12	GROUP	FINISHED	2026-06-27 21:00:00+00	46	47	2	1	46	2026-06-27 23:00:23.738747+00	Fase de grupos · J3 · Lincoln Financial Field	3	\N	GROUP	2026-06-27	17:00	1.00
71	wc2026-match-071	1	11	GROUP	FINISHED	2026-06-27 23:30:00+00	44	41	0	0	\N	2026-06-28 01:28:38.105382+00	Fase de grupos · J3 · Hard Rock Stadium	3	\N	GROUP	2026-06-27	19:30	1.00
74	wc2026-ko-74	1	\N	KNOCKOUT	FINISHED	2026-06-29 17:30:00+00	17	14	1	1	14	2026-06-29 23:29:55.199401+00	Dieciseisavos · Partido 74 · 1º Grupo E vs 3º Grupo A/B/C/D/F	\N	2026-06-28 17:30:00+00	R16	2026-06-29	12:30	1.00
40	wc2026-match-040	1	7	GROUP	FINISHED	2026-06-22 01:00:00+00	28	26	1	3	26	2026-06-22 03:01:11.424041+00	Fase de grupos · J2 · BC Place	2	\N	GROUP	2026-06-21	18:00	1.00
43	wc2026-match-043	1	10	GROUP	FINISHED	2026-06-22 17:00:00+00	37	39	2	0	37	2026-06-22 19:02:52.469461+00	Fase de grupos · J2 · AT&T Stadium	2	\N	GROUP	2026-06-22	12:00	1.00
53	wc2026-match-053	1	1	GROUP	FINISHED	2026-06-25 01:00:00+00	4	1	0	3	1	2026-06-25 02:58:31.314969+00	Fase de grupos · J3 · Estadio Azteca	3	\N	GROUP	2026-06-24	19:00	1.00
78	wc2026-ko-78	1	\N	KNOCKOUT	FINISHED	2026-06-30 22:00:00+00	19	35	1	2	35	2026-06-30 18:59:16.242986+00	Dieciseisavos · Partido 78 · 2º Grupo E vs 2º Grupo I	\N	2026-06-29 22:00:00+00	R16	2026-06-30	17:00	1.00
75	wc2026-ko-75	1	\N	KNOCKOUT	FINISHED	2026-06-29 23:00:00+00	21	10	1	1	10	2026-06-30 03:54:11.825989+00	Dieciseisavos · Partido 75 · 1º Grupo F vs 2º Grupo C	\N	2026-06-28 23:00:00+00	R16	2026-06-29	18:00	1.00
77	wc2026-ko-77	1	\N	KNOCKOUT	FINISHED	2026-06-30 18:00:00+00	33	23	3	0	33	2026-06-30 22:54:09.678975+00	Dieciseisavos · Partido 77 · 1º Grupo I vs 3º Grupo C/D/F/G/H	\N	2026-06-29 18:00:00+00	R16	2026-06-30	13:00	1.00
70	wc2026-match-070	1	10	GROUP	FINISHED	2026-06-28 02:00:00+00	40	37	1	3	37	2026-06-28 03:57:46.699765+00	Fase de grupos · J3 · AT&T Stadium	3	\N	GROUP	2026-06-27	21:00	1.00
73	wc2026-ko-73	1	\N	KNOCKOUT	FINISHED	2026-06-28 20:00:00+00	2	5	0	1	5	2026-06-28 20:58:06.277321+00	Dieciseisavos · Partido 73 · 2º Grupo A vs 2º Grupo B	\N	2026-06-26 20:00:00+00	R16	2026-06-28	15:00	1.00
101	wc2026-ko-101	1	\N	KNOCKOUT	NOT_STARTED	2026-07-15 01:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.438951+00	Semifinal · Partido 101 · Ganador cuartos 97 vs Ganador cuartos 98	\N	2026-07-14 01:00:00+00	SF	2026-07-14	20:00	1.00
102	wc2026-ko-102	1	\N	KNOCKOUT	NOT_STARTED	2026-07-15 01:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.440622+00	Semifinal · Partido 102 · Ganador cuartos 99 vs Ganador cuartos 100	\N	2026-07-14 01:00:00+00	SF	2026-07-14	20:00	1.00
103	wc2026-ko-103	1	\N	KNOCKOUT	NOT_STARTED	2026-07-18 22:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.442225+00	Tercer puesto · Perdedor semifinal 1 vs Perdedor semifinal 2	\N	2026-07-17 22:00:00+00	TP3	2026-07-18	17:00	1.00
104	wc2026-ko-104	1	\N	KNOCKOUT	NOT_STARTED	2026-07-20 01:00:00+00	49	49	\N	\N	\N	2026-07-03 12:30:22.443888+00	Final · Ganador semifinal 1 vs Ganador semifinal 2	\N	2026-07-19 01:00:00+00	F	2026-07-19	20:00	1.00
\.


--
-- Data for Name: prediction_scores; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.prediction_scores (id, user_id, source_type, source_id, points, breakdown, updated_at) FROM stdin;
304	34	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.02072+00
305	38	MATCH	4	0	{}	2026-06-13 03:03:24.027844+00
64	15	MATCH	3	0	{}	2026-06-12 20:58:56.512618+00
65	37	MATCH	3	0	{}	2026-06-12 20:58:56.514911+00
5	15	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.071969+00
6	27	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.074864+00
7	11	MATCH	1	0	{}	2026-06-11 21:05:28.078508+00
8	24	MATCH	1	0	{}	2026-06-11 21:05:28.08077+00
9	10	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.082911+00
10	14	MATCH	1	0	{}	2026-06-11 21:05:28.085082+00
11	9	MATCH	1	0	{}	2026-06-11 21:05:28.128565+00
12	13	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.131289+00
13	12	MATCH	1	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-11 21:05:28.133879+00
14	23	MATCH	1	0	{}	2026-06-11 21:05:28.136265+00
15	29	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.138504+00
16	18	MATCH	1	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-11 21:05:28.147729+00
17	28	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.151722+00
18	33	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.156092+00
19	32	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.158213+00
20	31	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.161013+00
21	30	MATCH	1	3	{"winner": 3}	2026-06-11 21:05:28.163172+00
22	40	MATCH	2	3	{"winner": 3}	2026-06-12 03:55:42.960245+00
23	15	MATCH	2	0	{}	2026-06-12 03:55:42.96306+00
24	27	MATCH	2	5	{"winner": 3, "goalDiff": 2}	2026-06-12 03:55:42.965306+00
25	13	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:42.967441+00
26	14	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:42.969626+00
27	10	MATCH	2	3	{"winner": 3}	2026-06-12 03:55:42.971812+00
28	11	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:42.973992+00
29	24	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:42.976196+00
30	18	MATCH	2	3	{"winner": 3}	2026-06-12 03:55:42.978364+00
31	28	MATCH	2	5	{"winner": 3, "goalDiff": 2}	2026-06-12 03:55:42.981505+00
32	16	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.029932+00
33	37	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.032399+00
34	44	MATCH	2	5	{"winner": 3, "goalDiff": 2}	2026-06-12 03:55:43.034645+00
35	36	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.03694+00
36	34	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.039376+00
37	35	MATCH	2	0	{}	2026-06-12 03:55:43.041561+00
38	43	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.04372+00
39	9	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.045799+00
40	33	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.04816+00
41	32	MATCH	2	3	{"winner": 3}	2026-06-12 03:55:43.050342+00
42	30	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.05247+00
43	46	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.054657+00
44	45	MATCH	2	3	{"winner": 3}	2026-06-12 03:55:43.0568+00
45	41	MATCH	2	0	{}	2026-06-12 03:55:43.059811+00
46	31	MATCH	2	0	{}	2026-06-12 03:55:43.061922+00
47	47	MATCH	2	0	{}	2026-06-12 03:55:43.06406+00
48	23	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.066337+00
49	42	MATCH	2	2	{"goalDiff": 2}	2026-06-12 03:55:43.068502+00
50	12	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.070653+00
51	29	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.073558+00
52	48	MATCH	2	0	{}	2026-06-12 03:55:43.07772+00
53	38	MATCH	2	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 03:55:43.080052+00
306	40	MATCH	4	0	{}	2026-06-13 03:03:24.029766+00
307	37	MATCH	4	0	{}	2026-06-13 03:03:24.0334+00
308	15	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.035252+00
309	23	MATCH	4	0	{}	2026-06-13 03:03:24.037147+00
310	26	MATCH	4	0	{}	2026-06-13 03:03:24.039008+00
311	33	MATCH	4	0	{}	2026-06-13 03:03:24.040771+00
312	30	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.04285+00
313	9	MATCH	4	0	{}	2026-06-13 03:03:24.045722+00
314	45	MATCH	4	0	{}	2026-06-13 03:03:24.047522+00
315	28	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.049354+00
66	34	MATCH	3	0	{}	2026-06-12 20:58:56.516684+00
67	40	MATCH	3	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 20:58:56.518579+00
68	38	MATCH	3	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 20:58:56.52055+00
69	23	MATCH	3	0	{}	2026-06-12 20:58:56.522374+00
70	26	MATCH	3	0	{}	2026-06-12 20:58:56.524274+00
316	16	MATCH	4	0	{}	2026-06-13 03:03:24.051409+00
317	10	MATCH	4	0	{}	2026-06-13 03:03:24.053632+00
318	31	MATCH	4	0	{}	2026-06-13 03:03:24.055534+00
71	33	MATCH	3	0	{}	2026-06-12 20:58:56.526084+00
72	30	MATCH	3	0	{}	2026-06-12 20:58:56.528896+00
73	47	MATCH	3	0	{}	2026-06-12 20:58:56.530787+00
74	9	MATCH	3	0	{}	2026-06-12 20:58:56.532624+00
75	28	MATCH	3	0	{}	2026-06-12 20:58:56.534542+00
76	45	MATCH	3	0	{}	2026-06-12 20:58:56.536348+00
77	54	MATCH	3	0	{}	2026-06-12 20:58:56.538138+00
78	10	MATCH	3	0	{}	2026-06-12 20:58:56.539934+00
79	31	MATCH	3	0	{}	2026-06-12 20:58:56.541693+00
80	14	MATCH	3	0	{}	2026-06-12 20:58:56.543571+00
81	24	MATCH	3	0	{}	2026-06-12 20:58:56.545524+00
82	13	MATCH	3	0	{}	2026-06-12 20:58:56.547402+00
83	11	MATCH	3	0	{}	2026-06-12 20:58:56.549171+00
84	32	MATCH	3	0	{}	2026-06-12 20:58:56.551718+00
85	43	MATCH	3	0	{}	2026-06-12 20:58:56.554273+00
86	18	MATCH	3	0	{}	2026-06-12 20:58:56.556152+00
87	44	MATCH	3	0	{}	2026-06-12 20:58:56.557933+00
88	46	MATCH	3	5	{"draw": 3, "goalDiff": 2}	2026-06-12 20:58:56.559667+00
89	42	MATCH	3	0	{}	2026-06-12 20:58:56.561508+00
90	48	MATCH	3	0	{}	2026-06-12 20:58:56.563332+00
91	50	MATCH	3	0	{}	2026-06-12 20:58:56.565105+00
92	25	MATCH	3	0	{}	2026-06-12 20:58:56.566863+00
93	41	MATCH	3	0	{}	2026-06-12 20:58:56.568579+00
94	51	MATCH	3	0	{}	2026-06-12 20:58:56.570447+00
95	35	MATCH	3	0	{}	2026-06-12 20:58:56.572273+00
96	36	MATCH	3	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 20:58:56.574399+00
97	29	MATCH	3	0	{}	2026-06-12 20:58:56.576646+00
98	12	MATCH	3	0	{}	2026-06-12 20:58:56.578458+00
99	16	MATCH	3	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-12 20:58:56.580228+00
100	55	MATCH	3	0	{}	2026-06-12 20:58:56.58205+00
319	14	MATCH	4	0	{}	2026-06-13 03:03:24.057413+00
320	24	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.059385+00
321	11	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.061961+00
322	32	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.063765+00
323	43	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.065624+00
324	18	MATCH	4	0	{}	2026-06-13 03:03:24.067483+00
325	42	MATCH	4	0	{}	2026-06-13 03:03:24.0694+00
326	48	MATCH	4	0	{}	2026-06-13 03:03:24.071237+00
327	54	MATCH	4	0	{}	2026-06-13 03:03:24.073116+00
328	25	MATCH	4	0	{}	2026-06-13 03:03:24.074902+00
329	35	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.076927+00
330	50	MATCH	4	0	{}	2026-06-13 03:03:24.078732+00
331	47	MATCH	4	0	{}	2026-06-13 03:03:24.080536+00
332	51	MATCH	4	0	{}	2026-06-13 03:03:24.082371+00
333	36	MATCH	4	0	{}	2026-06-13 03:03:24.084164+00
334	55	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.085932+00
335	41	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.087718+00
336	27	MATCH	4	0	{}	2026-06-13 03:03:24.089518+00
337	56	MATCH	4	0	{}	2026-06-13 03:03:24.091356+00
338	13	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.093139+00
339	29	MATCH	4	0	{}	2026-06-13 03:03:24.094906+00
340	44	MATCH	4	0	{}	2026-06-13 03:03:24.096674+00
341	46	MATCH	4	3	{"winner": 3}	2026-06-13 03:03:24.098466+00
342	12	MATCH	4	0	{}	2026-06-13 03:03:24.10058+00
1573	68	LATE_START	0	10	{}	2026-06-17 17:39:07.596998+00
405	34	MATCH	7	0	{}	2026-06-14 00:05:38.523477+00
406	15	MATCH	7	0	{}	2026-06-14 00:05:38.526352+00
407	54	MATCH	7	0	{}	2026-06-14 00:05:38.528177+00
408	25	MATCH	7	0	{}	2026-06-14 00:05:38.53008+00
409	45	MATCH	7	0	{}	2026-06-14 00:05:38.531896+00
410	9	MATCH	7	0	{}	2026-06-14 00:05:38.533791+00
411	40	MATCH	7	5	{"draw": 3, "goalDiff": 2}	2026-06-14 00:05:38.535808+00
412	47	MATCH	7	0	{}	2026-06-14 00:05:38.53782+00
413	30	MATCH	7	0	{}	2026-06-14 00:05:38.539789+00
414	13	MATCH	7	0	{}	2026-06-14 00:05:38.541648+00
415	33	MATCH	7	0	{}	2026-06-14 00:05:38.543626+00
416	48	MATCH	7	0	{}	2026-06-14 00:05:38.545776+00
417	35	MATCH	7	0	{}	2026-06-14 00:05:38.547577+00
418	31	MATCH	7	0	{}	2026-06-14 00:05:38.549452+00
419	27	MATCH	7	0	{}	2026-06-14 00:05:38.551481+00
420	38	MATCH	7	0	{}	2026-06-14 00:05:38.553349+00
421	10	MATCH	7	0	{}	2026-06-14 00:05:38.555171+00
422	36	MATCH	7	0	{}	2026-06-14 00:05:38.556975+00
423	28	MATCH	7	0	{}	2026-06-14 00:05:38.558812+00
623	15	MATCH	10	5	{"winner": 3, "goalDiff": 2}	2026-06-14 19:00:40.921205+00
624	54	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.92896+00
625	25	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.942247+00
626	9	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.947727+00
627	27	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.953731+00
628	45	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.96433+00
629	37	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.968246+00
630	38	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.971375+00
631	11	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.973924+00
632	31	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.980752+00
633	30	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.98373+00
634	56	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.985923+00
635	13	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.989794+00
354	15	MATCH	8	0	{}	2026-06-13 21:04:37.134994+00
355	34	MATCH	8	0	{}	2026-06-13 21:04:37.13774+00
356	37	MATCH	8	0	{}	2026-06-13 21:04:37.139847+00
1364	15	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.370728+00
357	54	MATCH	8	0	{}	2026-06-13 21:04:37.142143+00
358	25	MATCH	8	0	{}	2026-06-13 21:04:37.144263+00
359	9	MATCH	8	0	{}	2026-06-13 21:04:37.146349+00
360	47	MATCH	8	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-13 21:04:37.148681+00
361	45	MATCH	8	0	{}	2026-06-13 21:04:37.152931+00
362	36	MATCH	8	0	{}	2026-06-13 21:04:37.155147+00
363	40	MATCH	8	0	{}	2026-06-13 21:04:37.157068+00
364	13	MATCH	8	0	{}	2026-06-13 21:04:37.160639+00
365	33	MATCH	8	0	{}	2026-06-13 21:04:37.16259+00
366	10	MATCH	8	0	{}	2026-06-13 21:04:37.164584+00
367	56	MATCH	8	0	{}	2026-06-13 21:04:37.167118+00
368	48	MATCH	8	0	{}	2026-06-13 21:04:37.16959+00
369	35	MATCH	8	0	{}	2026-06-13 21:04:37.17332+00
370	27	MATCH	8	0	{}	2026-06-13 21:04:37.179304+00
371	55	MATCH	8	0	{}	2026-06-13 21:04:37.183197+00
372	38	MATCH	8	0	{}	2026-06-13 21:04:37.185758+00
373	28	MATCH	8	0	{}	2026-06-13 21:04:37.188729+00
374	30	MATCH	8	0	{}	2026-06-13 21:04:37.192117+00
375	31	MATCH	8	0	{}	2026-06-13 21:04:37.197048+00
376	42	MATCH	8	0	{}	2026-06-13 21:04:37.198938+00
377	24	MATCH	8	0	{}	2026-06-13 21:04:37.202909+00
378	11	MATCH	8	0	{}	2026-06-13 21:04:37.204814+00
379	12	MATCH	8	0	{}	2026-06-13 21:04:37.206756+00
380	58	MATCH	8	0	{}	2026-06-13 21:04:37.208672+00
381	14	MATCH	8	0	{}	2026-06-13 21:04:37.210833+00
382	32	MATCH	8	0	{}	2026-06-13 21:04:37.212684+00
383	44	MATCH	8	0	{}	2026-06-13 21:04:37.214591+00
384	41	MATCH	8	0	{}	2026-06-13 21:04:37.217053+00
385	23	MATCH	8	0	{}	2026-06-13 21:04:37.229685+00
386	16	MATCH	8	0	{}	2026-06-13 21:04:37.23203+00
387	18	MATCH	8	0	{}	2026-06-13 21:04:37.235009+00
388	29	MATCH	8	0	{}	2026-06-13 21:04:37.237304+00
389	50	MATCH	8	0	{}	2026-06-13 21:04:37.240173+00
390	43	MATCH	8	0	{}	2026-06-13 21:04:37.243012+00
391	46	MATCH	8	0	{}	2026-06-13 21:04:37.246071+00
392	59	MATCH	8	0	{}	2026-06-13 21:04:37.24993+00
393	51	MATCH	8	0	{}	2026-06-13 21:04:37.257876+00
1365	54	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.378388+00
424	56	MATCH	7	0	{}	2026-06-14 00:05:38.562497+00
425	51	MATCH	7	0	{}	2026-06-14 00:05:38.56463+00
426	42	MATCH	7	0	{}	2026-06-14 00:05:38.566618+00
427	24	MATCH	7	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 00:05:38.568722+00
428	55	MATCH	7	0	{}	2026-06-14 00:05:38.570522+00
429	11	MATCH	7	0	{}	2026-06-14 00:05:38.572252+00
430	12	MATCH	7	0	{}	2026-06-14 00:05:38.574281+00
431	37	MATCH	7	0	{}	2026-06-14 00:05:38.576417+00
432	32	MATCH	7	0	{}	2026-06-14 00:05:38.579355+00
433	16	MATCH	7	0	{}	2026-06-14 00:05:38.581238+00
434	18	MATCH	7	0	{}	2026-06-14 00:05:38.583113+00
435	29	MATCH	7	0	{}	2026-06-14 00:05:38.585091+00
436	43	MATCH	7	0	{}	2026-06-14 00:05:38.586993+00
437	50	MATCH	7	0	{}	2026-06-14 00:05:38.588876+00
438	59	MATCH	7	0	{}	2026-06-14 00:05:38.590748+00
439	44	MATCH	7	0	{}	2026-06-14 00:05:38.592555+00
440	26	MATCH	7	0	{}	2026-06-14 00:05:38.594477+00
441	14	MATCH	7	0	{}	2026-06-14 00:05:38.596293+00
442	46	MATCH	7	0	{}	2026-06-14 00:05:38.598142+00
443	23	MATCH	7	0	{}	2026-06-14 00:05:38.600021+00
637	47	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.995133+00
638	10	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.99734+00
639	40	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.001807+00
640	28	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.004004+00
641	14	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.006177+00
642	32	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.010835+00
643	26	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.013106+00
644	35	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.01681+00
645	18	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.019087+00
647	36	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.030988+00
648	24	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.037321+00
649	58	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.042102+00
650	59	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.044315+00
651	55	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.046441+00
652	44	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.048548+00
653	46	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.0529+00
654	51	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.055109+00
655	42	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.057745+00
656	23	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.05993+00
657	48	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.064845+00
658	12	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.067001+00
659	41	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.070819+00
660	43	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.072973+00
661	16	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.075125+00
444	58	MATCH	7	0	{}	2026-06-14 00:05:38.601963+00
1366	25	MATCH	19	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 02:59:41.384723+00
1367	9	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.387358+00
1368	36	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.390791+00
1369	38	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.394722+00
1370	24	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.397025+00
1371	40	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.400154+00
1372	27	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.404858+00
1373	30	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.407062+00
1374	47	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.410817+00
1375	33	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.413123+00
724	15	MATCH	11	0	{}	2026-06-14 21:55:28.329634+00
456	15	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.539004+00
457	37	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.569592+00
458	34	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.571572+00
459	54	MATCH	5	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 03:03:07.573474+00
460	25	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.575341+00
461	31	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.577172+00
462	45	MATCH	5	0	{}	2026-06-14 03:03:07.578975+00
463	9	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.580973+00
464	40	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.582771+00
465	47	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.58454+00
466	13	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.586438+00
467	30	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.588376+00
468	33	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.590195+00
469	28	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.592041+00
470	48	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.594017+00
471	35	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.59627+00
472	27	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.598092+00
473	55	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.599925+00
474	38	MATCH	5	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 03:03:07.629484+00
475	10	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.631568+00
476	56	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.633628+00
477	42	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.635508+00
478	12	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.637286+00
479	14	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.639186+00
480	32	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.640981+00
481	36	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.642716+00
482	16	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.644682+00
483	18	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.646512+00
484	43	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.648356+00
485	50	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.650203+00
486	26	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.652052+00
487	51	MATCH	5	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 03:03:07.65385+00
488	46	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.6558+00
489	29	MATCH	5	5	{"winner": 3, "goalDiff": 2}	2026-06-14 03:03:07.657589+00
490	41	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.659418+00
491	59	MATCH	5	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 03:03:07.661224+00
492	44	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.663071+00
493	58	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.664925+00
494	24	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.667052+00
495	23	MATCH	5	3	{"winner": 3}	2026-06-14 03:03:07.668911+00
725	34	MATCH	11	0	{}	2026-06-14 21:55:28.332203+00
726	25	MATCH	11	0	{}	2026-06-14 21:55:28.334031+00
727	54	MATCH	11	0	{}	2026-06-14 21:55:28.336103+00
728	27	MATCH	11	0	{}	2026-06-14 21:55:28.338157+00
729	9	MATCH	11	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 21:55:28.340058+00
730	45	MATCH	11	0	{}	2026-06-14 21:55:28.342081+00
731	11	MATCH	11	0	{}	2026-06-14 21:55:28.344017+00
732	30	MATCH	11	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 21:55:28.345966+00
733	38	MATCH	11	0	{}	2026-06-14 21:55:28.347888+00
734	33	MATCH	11	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 21:55:28.350505+00
735	47	MATCH	11	0	{}	2026-06-14 21:55:28.352412+00
736	56	MATCH	11	0	{}	2026-06-14 21:55:28.354393+00
737	10	MATCH	11	0	{}	2026-06-14 21:55:28.356275+00
738	40	MATCH	11	0	{}	2026-06-14 21:55:28.358215+00
739	28	MATCH	11	0	{}	2026-06-14 21:55:28.361554+00
740	32	MATCH	11	0	{}	2026-06-14 21:55:28.363565+00
741	26	MATCH	11	0	{}	2026-06-14 21:55:28.365539+00
742	35	MATCH	11	0	{}	2026-06-14 21:55:28.367483+00
743	18	MATCH	11	0	{}	2026-06-14 21:55:28.369341+00
744	36	MATCH	11	0	{}	2026-06-14 21:55:28.371306+00
1376	29	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.416805+00
1377	32	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.41903+00
622	34	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.902886+00
636	33	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:40.991966+00
646	50	MATCH	10	3	{"winner": 3}	2026-06-14 19:00:41.02336+00
1378	14	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.422803+00
1379	45	MATCH	19	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 02:59:41.425742+00
1380	44	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.429823+00
1381	11	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.432819+00
1382	35	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.435625+00
1383	13	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.438726+00
1384	48	MATCH	19	5	{"winner": 3, "goalDiff": 2}	2026-06-17 02:59:41.440884+00
1385	58	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.44573+00
1386	43	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.448165+00
1387	51	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.450354+00
1388	26	MATCH	19	5	{"winner": 3, "goalDiff": 2}	2026-06-17 02:59:41.453827+00
745	37	MATCH	11	5	{"draw": 3, "goalDiff": 2}	2026-06-14 21:55:28.373338+00
746	24	MATCH	11	0	{}	2026-06-14 21:55:28.376722+00
747	58	MATCH	11	0	{}	2026-06-14 21:55:28.378776+00
748	55	MATCH	11	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 21:55:28.380762+00
749	42	MATCH	11	0	{}	2026-06-14 21:55:28.383416+00
750	13	MATCH	11	0	{}	2026-06-14 21:55:28.38527+00
751	23	MATCH	11	0	{}	2026-06-14 21:55:28.387104+00
752	48	MATCH	11	0	{}	2026-06-14 21:55:28.388979+00
753	43	MATCH	11	0	{}	2026-06-14 21:55:28.390971+00
754	16	MATCH	11	0	{}	2026-06-14 21:55:28.392918+00
755	59	MATCH	11	0	{}	2026-06-14 21:55:28.394893+00
756	51	MATCH	11	0	{}	2026-06-14 21:55:28.398539+00
570	34	MATCH	6	0	{}	2026-06-14 22:31:23.853411+00
571	38	MATCH	6	0	{}	2026-06-14 22:31:23.855494+00
572	40	MATCH	6	0	{}	2026-06-14 22:31:23.85731+00
573	15	MATCH	6	0	{}	2026-06-14 22:31:23.859093+00
574	37	MATCH	6	0	{}	2026-06-14 22:31:23.860887+00
575	28	MATCH	6	0	{}	2026-06-14 22:31:23.862746+00
576	10	MATCH	6	0	{}	2026-06-14 22:31:23.86462+00
577	9	MATCH	6	0	{}	2026-06-14 22:31:23.86648+00
578	45	MATCH	6	0	{}	2026-06-14 22:31:23.868247+00
579	54	MATCH	6	0	{}	2026-06-14 22:31:23.869902+00
580	25	MATCH	6	0	{}	2026-06-14 22:31:23.871672+00
581	33	MATCH	6	0	{}	2026-06-14 22:31:23.873441+00
582	36	MATCH	6	0	{}	2026-06-14 22:31:23.875848+00
583	30	MATCH	6	0	{}	2026-06-14 22:31:23.87838+00
584	31	MATCH	6	0	{}	2026-06-14 22:31:23.881029+00
585	47	MATCH	6	0	{}	2026-06-14 22:31:23.8842+00
586	48	MATCH	6	0	{}	2026-06-14 22:31:23.885984+00
587	35	MATCH	6	0	{}	2026-06-14 22:31:23.88783+00
588	27	MATCH	6	0	{}	2026-06-14 22:31:23.889656+00
589	55	MATCH	6	0	{}	2026-06-14 22:31:23.891549+00
1389	34	MATCH	19	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 02:59:41.458545+00
1390	66	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.461329+00
1391	16	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.464808+00
1392	41	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.467801+00
1393	37	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.470842+00
1394	55	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.474895+00
1395	56	MATCH	19	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 02:59:41.477109+00
1396	31	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.479251+00
1397	10	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.482378+00
1398	50	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.487732+00
1399	18	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.490051+00
590	13	MATCH	6	0	{}	2026-06-14 22:31:23.893459+00
591	42	MATCH	6	0	{}	2026-06-14 22:31:23.895235+00
592	24	MATCH	6	0	{}	2026-06-14 22:31:23.896952+00
593	12	MATCH	6	0	{}	2026-06-14 22:31:23.898744+00
594	14	MATCH	6	0	{}	2026-06-14 22:31:23.900522+00
595	32	MATCH	6	0	{}	2026-06-14 22:31:23.902236+00
596	16	MATCH	6	0	{}	2026-06-14 22:31:23.904007+00
597	18	MATCH	6	0	{}	2026-06-14 22:31:23.905833+00
598	43	MATCH	6	0	{}	2026-06-14 22:31:23.907528+00
599	50	MATCH	6	0	{}	2026-06-14 22:31:23.909314+00
600	59	MATCH	6	3	{"winner": 3}	2026-06-14 22:31:23.9111+00
601	26	MATCH	6	0	{}	2026-06-14 22:31:23.913608+00
602	41	MATCH	6	0	{}	2026-06-14 22:31:23.915713+00
603	58	MATCH	6	0	{}	2026-06-14 22:31:23.917474+00
604	56	MATCH	6	0	{}	2026-06-14 22:31:23.929935+00
605	11	MATCH	6	0	{}	2026-06-14 22:31:23.932041+00
606	46	MATCH	6	0	{}	2026-06-14 22:31:23.933859+00
607	23	MATCH	6	0	{}	2026-06-14 22:31:23.935897+00
608	44	MATCH	6	0	{}	2026-06-14 22:31:23.938249+00
609	29	MATCH	6	0	{}	2026-06-14 22:31:23.940538+00
610	51	MATCH	6	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 22:31:23.943713+00
1400	59	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.492211+00
1401	46	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.494482+00
1402	42	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.498801+00
1403	28	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.500942+00
757	31	MATCH	11	0	{}	2026-06-14 21:55:28.403467+00
758	44	MATCH	11	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 21:55:28.431108+00
759	14	MATCH	11	0	{}	2026-06-14 21:55:28.433108+00
760	41	MATCH	11	0	{}	2026-06-14 21:55:28.435159+00
761	12	MATCH	11	5	{"draw": 3, "goalDiff": 2}	2026-06-14 21:55:28.437211+00
762	46	MATCH	11	0	{}	2026-06-14 21:55:28.439149+00
763	50	MATCH	11	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-14 21:55:28.442622+00
1404	23	MATCH	19	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 02:59:41.504732+00
1405	12	MATCH	19	3	{"winner": 3}	2026-06-17 02:59:41.507036+00
2025	54	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.233808+00
2026	29	MATCH	26	0	{}	2026-06-18 20:58:45.240733+00
2027	9	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.329666+00
2028	15	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.33247+00
2029	38	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.334501+00
2030	40	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.336255+00
2031	10	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.339063+00
2032	34	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.430625+00
2033	55	MATCH	26	0	{}	2026-06-18 20:58:45.432832+00
2034	47	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.528527+00
2035	35	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.530656+00
2036	24	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.532263+00
827	15	MATCH	9	0	{}	2026-06-15 01:04:22.46314+00
828	34	MATCH	9	0	{}	2026-06-15 01:04:22.466524+00
829	54	MATCH	9	0	{}	2026-06-15 01:04:22.469054+00
830	25	MATCH	9	0	{}	2026-06-15 01:04:22.471425+00
831	27	MATCH	9	0	{}	2026-06-15 01:04:22.473947+00
832	9	MATCH	9	0	{}	2026-06-15 01:04:22.476234+00
833	45	MATCH	9	0	{}	2026-06-15 01:04:22.530885+00
834	37	MATCH	9	5	{"winner": 3, "goalDiff": 2}	2026-06-15 01:04:22.534355+00
835	30	MATCH	9	0	{}	2026-06-15 01:04:22.537671+00
836	38	MATCH	9	0	{}	2026-06-15 01:04:22.539989+00
837	40	MATCH	9	0	{}	2026-06-15 01:04:22.542276+00
838	28	MATCH	9	0	{}	2026-06-15 01:04:22.54453+00
839	32	MATCH	9	0	{}	2026-06-15 01:04:22.546829+00
840	26	MATCH	9	0	{}	2026-06-15 01:04:22.549607+00
841	35	MATCH	9	0	{}	2026-06-15 01:04:22.552018+00
842	18	MATCH	9	0	{}	2026-06-15 01:04:22.554415+00
843	36	MATCH	9	0	{}	2026-06-15 01:04:22.556731+00
844	50	MATCH	9	0	{}	2026-06-15 01:04:22.560018+00
845	10	MATCH	9	0	{}	2026-06-15 01:04:22.562956+00
846	24	MATCH	9	0	{}	2026-06-15 01:04:22.565792+00
847	55	MATCH	9	0	{}	2026-06-15 01:04:22.568865+00
848	47	MATCH	9	5	{"winner": 3, "goalDiff": 2}	2026-06-15 01:04:22.572114+00
849	48	MATCH	9	0	{}	2026-06-15 01:04:22.574845+00
850	43	MATCH	9	0	{}	2026-06-15 01:04:22.57797+00
851	16	MATCH	9	0	{}	2026-06-15 01:04:22.580741+00
852	56	MATCH	9	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-15 01:04:22.583641+00
853	11	MATCH	9	0	{}	2026-06-15 01:04:22.586812+00
854	33	MATCH	9	5	{"winner": 3, "goalDiff": 2}	2026-06-15 01:04:22.590012+00
855	13	MATCH	9	0	{}	2026-06-15 01:04:22.592861+00
856	42	MATCH	9	3	{"winner": 3}	2026-06-15 01:04:22.595146+00
857	14	MATCH	9	0	{}	2026-06-15 01:04:22.597404+00
858	12	MATCH	9	0	{}	2026-06-15 01:04:22.628602+00
859	58	MATCH	9	0	{}	2026-06-15 01:04:22.632506+00
860	29	MATCH	9	0	{}	2026-06-15 01:04:22.635558+00
861	41	MATCH	9	0	{}	2026-06-15 01:04:22.637926+00
862	23	MATCH	9	0	{}	2026-06-15 01:04:22.640295+00
863	31	MATCH	9	0	{}	2026-06-15 01:04:22.642565+00
864	51	MATCH	9	0	{}	2026-06-15 01:04:22.645398+00
865	46	MATCH	9	0	{}	2026-06-15 01:04:22.647624+00
866	59	MATCH	9	0	{}	2026-06-15 01:04:22.649853+00
867	66	MATCH	9	0	{}	2026-06-15 01:04:22.652139+00
879	15	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.354686+00
880	34	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.35713+00
881	25	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.361039+00
882	54	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.363196+00
883	27	MATCH	12	0	{}	2026-06-15 03:59:17.365323+00
884	9	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.367398+00
885	30	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.369494+00
886	45	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.371592+00
887	38	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.37375+00
888	37	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.37587+00
889	33	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.378147+00
890	47	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.380349+00
891	40	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.38257+00
892	14	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.38477+00
893	32	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.386879+00
894	26	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.389337+00
895	18	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.391542+00
896	36	MATCH	12	0	{}	2026-06-15 03:59:17.394666+00
897	24	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.397874+00
2037	13	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.533809+00
2038	48	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.535307+00
2039	37	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.536589+00
2040	51	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.538413+00
1424	36	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.336092+00
1436	45	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.365759+00
1453	23	MATCH	20	0	{}	2026-06-17 06:09:05.405601+00
1457	48	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.415454+00
2041	68	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.540186+00
2042	45	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.542039+00
2043	44	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.543432+00
2044	16	MATCH	26	0	{}	2026-06-18 20:58:45.544787+00
2045	32	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.546322+00
898	55	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.400869+00
899	13	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.40314+00
900	48	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.405289+00
901	43	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.407519+00
902	16	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.409672+00
903	42	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.412151+00
904	28	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.415484+00
905	11	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.417718+00
906	56	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.419886+00
907	10	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.422123+00
908	35	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.424439+00
909	50	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.426669+00
910	12	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.428874+00
911	58	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.431114+00
912	29	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.433259+00
913	31	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.435431+00
914	51	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.437578+00
915	44	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.439795+00
916	41	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.442031+00
917	59	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.444252+00
918	66	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.447764+00
919	23	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.450019+00
920	46	MATCH	12	3	{"winner": 3}	2026-06-15 03:59:17.453409+00
2046	14	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.547848+00
2047	41	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.551607+00
2048	30	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.553188+00
2049	33	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.554668+00
989	15	MATCH	14	0	{}	2026-06-15 17:56:26.149804+00
990	34	MATCH	14	0	{}	2026-06-15 17:56:26.154887+00
991	25	MATCH	14	0	{}	2026-06-15 17:56:26.157506+00
992	54	MATCH	14	0	{}	2026-06-15 17:56:26.159973+00
993	9	MATCH	14	0	{}	2026-06-15 17:56:26.162175+00
994	27	MATCH	14	0	{}	2026-06-15 17:56:26.165026+00
995	45	MATCH	14	0	{}	2026-06-15 17:56:26.230597+00
996	38	MATCH	14	0	{}	2026-06-15 17:56:26.233355+00
997	40	MATCH	14	0	{}	2026-06-15 17:56:26.328529+00
998	30	MATCH	14	0	{}	2026-06-15 17:56:26.331443+00
999	51	MATCH	14	0	{}	2026-06-15 17:56:26.334881+00
1000	55	MATCH	14	0	{}	2026-06-15 17:56:26.435625+00
1001	10	MATCH	14	0	{}	2026-06-15 17:56:26.438664+00
1002	48	MATCH	14	0	{}	2026-06-15 17:56:26.442231+00
1003	42	MATCH	14	0	{}	2026-06-15 17:56:26.532303+00
1004	13	MATCH	14	0	{}	2026-06-15 17:56:26.628731+00
1005	29	MATCH	14	0	{}	2026-06-15 17:56:26.631783+00
1006	28	MATCH	14	0	{}	2026-06-15 17:56:26.72977+00
1007	35	MATCH	14	0	{}	2026-06-15 17:56:26.735489+00
1008	16	MATCH	14	0	{}	2026-06-15 17:56:26.830145+00
1009	26	MATCH	14	0	{}	2026-06-15 17:56:26.833027+00
1010	36	MATCH	14	0	{}	2026-06-15 17:56:26.837943+00
1011	32	MATCH	14	0	{}	2026-06-15 17:56:26.929497+00
1012	37	MATCH	14	0	{}	2026-06-15 17:56:26.932621+00
1013	50	MATCH	14	0	{}	2026-06-15 17:56:26.936448+00
1014	58	MATCH	14	0	{}	2026-06-15 17:56:26.939068+00
1015	56	MATCH	14	0	{}	2026-06-15 17:56:26.943022+00
1016	66	MATCH	14	0	{}	2026-06-15 17:56:27.032285+00
1017	33	MATCH	14	0	{}	2026-06-15 17:56:27.034668+00
1018	41	MATCH	14	0	{}	2026-06-15 17:56:27.037653+00
1019	59	MATCH	14	0	{}	2026-06-15 17:56:27.040725+00
1020	11	MATCH	14	0	{}	2026-06-15 17:56:27.129535+00
1021	44	MATCH	14	0	{}	2026-06-15 17:56:27.133617+00
1022	14	MATCH	14	0	{}	2026-06-15 17:56:27.137722+00
1023	47	MATCH	14	0	{}	2026-06-15 17:56:27.140487+00
1024	23	MATCH	14	0	{}	2026-06-15 17:56:27.142795+00
1025	46	MATCH	14	0	{}	2026-06-15 17:56:27.147694+00
1026	31	MATCH	14	0	{}	2026-06-15 17:56:27.151212+00
1040	15	MATCH	16	0	{}	2026-06-15 20:58:37.905371+00
1041	34	MATCH	16	0	{}	2026-06-15 20:58:37.908092+00
1042	54	MATCH	16	0	{}	2026-06-15 20:58:37.911726+00
1043	25	MATCH	16	0	{}	2026-06-15 20:58:37.913932+00
1044	9	MATCH	16	0	{}	2026-06-15 20:58:37.91617+00
1045	27	MATCH	16	0	{}	2026-06-15 20:58:37.918383+00
1046	38	MATCH	16	0	{}	2026-06-15 20:58:37.920766+00
1047	51	MATCH	16	0	{}	2026-06-15 20:58:37.923063+00
1048	45	MATCH	16	0	{}	2026-06-15 20:58:37.92527+00
1049	30	MATCH	16	0	{}	2026-06-15 20:58:37.927477+00
1050	40	MATCH	16	5	{"draw": 3, "goalDiff": 2}	2026-06-15 20:58:37.929781+00
1051	55	MATCH	16	5	{"draw": 3, "goalDiff": 2}	2026-06-15 20:58:37.93195+00
1052	10	MATCH	16	0	{}	2026-06-15 20:58:37.934453+00
1053	37	MATCH	16	0	{}	2026-06-15 20:58:37.93667+00
1054	29	MATCH	16	0	{}	2026-06-15 20:58:37.939097+00
1055	28	MATCH	16	0	{}	2026-06-15 20:58:37.942907+00
1056	35	MATCH	16	0	{}	2026-06-15 20:58:37.945145+00
1057	16	MATCH	16	0	{}	2026-06-15 20:58:37.948677+00
1058	26	MATCH	16	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-15 20:58:37.951116+00
1059	36	MATCH	16	0	{}	2026-06-15 20:58:37.953946+00
1060	50	MATCH	16	0	{}	2026-06-15 20:58:37.956234+00
1061	13	MATCH	16	0	{}	2026-06-15 20:58:37.958449+00
1062	32	MATCH	16	0	{}	2026-06-15 20:58:37.960744+00
1063	58	MATCH	16	0	{}	2026-06-15 20:58:37.963145+00
1064	33	MATCH	16	0	{}	2026-06-15 20:58:37.965495+00
1065	56	MATCH	16	0	{}	2026-06-15 20:58:37.968964+00
1066	14	MATCH	16	0	{}	2026-06-15 20:58:37.971102+00
1067	31	MATCH	16	0	{}	2026-06-15 20:58:37.9736+00
1068	44	MATCH	16	0	{}	2026-06-15 20:58:37.975841+00
1069	47	MATCH	16	0	{}	2026-06-15 20:58:37.977981+00
1070	24	MATCH	16	0	{}	2026-06-15 20:58:37.980242+00
1071	43	MATCH	16	0	{}	2026-06-15 20:58:37.982384+00
1072	41	MATCH	16	0	{}	2026-06-15 20:58:37.984497+00
1073	18	MATCH	16	0	{}	2026-06-15 20:58:37.986689+00
1074	59	MATCH	16	0	{}	2026-06-15 20:58:37.988896+00
1075	48	MATCH	16	0	{}	2026-06-15 20:58:37.991+00
1076	66	MATCH	16	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-15 20:58:37.993172+00
1077	46	MATCH	16	0	{}	2026-06-15 20:58:37.995322+00
1078	12	MATCH	16	0	{}	2026-06-15 20:58:37.997475+00
1092	15	MATCH	13	0	{}	2026-06-16 00:04:29.264126+00
1093	34	MATCH	13	0	{}	2026-06-16 00:04:29.267146+00
1094	54	MATCH	13	0	{}	2026-06-16 00:04:29.271364+00
1095	25	MATCH	13	0	{}	2026-06-16 00:04:29.277392+00
1096	9	MATCH	13	0	{}	2026-06-16 00:04:29.281139+00
1097	27	MATCH	13	0	{}	2026-06-16 00:04:29.283379+00
1098	38	MATCH	13	0	{}	2026-06-16 00:04:29.2872+00
1099	45	MATCH	13	0	{}	2026-06-16 00:04:29.290737+00
1100	40	MATCH	13	0	{}	2026-06-16 00:04:29.294072+00
1101	55	MATCH	13	0	{}	2026-06-16 00:04:29.296295+00
1102	10	MATCH	13	0	{}	2026-06-16 00:04:29.298908+00
1103	13	MATCH	13	0	{}	2026-06-16 00:04:29.301571+00
1104	29	MATCH	13	0	{}	2026-06-16 00:04:29.303918+00
1105	28	MATCH	13	0	{}	2026-06-16 00:04:29.306435+00
1106	35	MATCH	13	0	{}	2026-06-16 00:04:29.308784+00
1107	16	MATCH	13	0	{}	2026-06-16 00:04:29.310965+00
1108	26	MATCH	13	0	{}	2026-06-16 00:04:29.313542+00
1109	36	MATCH	13	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 00:04:29.315769+00
1110	50	MATCH	13	0	{}	2026-06-16 00:04:29.317913+00
1111	37	MATCH	13	0	{}	2026-06-16 00:04:29.320106+00
1112	51	MATCH	13	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 00:04:29.322289+00
1113	30	MATCH	13	0	{}	2026-06-16 00:04:29.32455+00
1114	32	MATCH	13	0	{}	2026-06-16 00:04:29.32732+00
1115	56	MATCH	13	0	{}	2026-06-16 00:04:29.329414+00
1116	58	MATCH	13	0	{}	2026-06-16 00:04:29.331561+00
1117	11	MATCH	13	0	{}	2026-06-16 00:04:29.333855+00
1118	14	MATCH	13	0	{}	2026-06-16 00:04:29.336056+00
1119	44	MATCH	13	0	{}	2026-06-16 00:04:29.33823+00
1120	31	MATCH	13	0	{}	2026-06-16 00:04:29.340389+00
1121	24	MATCH	13	0	{}	2026-06-16 00:04:29.342938+00
1122	43	MATCH	13	0	{}	2026-06-16 00:04:29.345325+00
1123	33	MATCH	13	0	{}	2026-06-16 00:04:29.349751+00
1124	41	MATCH	13	0	{}	2026-06-16 00:04:29.353312+00
1125	18	MATCH	13	0	{}	2026-06-16 00:04:29.355621+00
1126	48	MATCH	13	0	{}	2026-06-16 00:04:29.361153+00
1127	66	MATCH	13	0	{}	2026-06-16 00:04:29.363422+00
1128	42	MATCH	13	0	{}	2026-06-16 00:04:29.36558+00
1419	34	MATCH	20	0	{}	2026-06-17 06:09:05.324087+00
1420	15	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.326396+00
1421	54	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.328796+00
1422	25	MATCH	20	0	{}	2026-06-17 06:09:05.331088+00
1423	9	MATCH	20	0	{}	2026-06-17 06:09:05.333899+00
1425	38	MATCH	20	0	{}	2026-06-17 06:09:05.339781+00
1426	24	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.341984+00
1427	40	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.345734+00
1428	27	MATCH	20	0	{}	2026-06-17 06:09:05.347855+00
1429	30	MATCH	20	0	{}	2026-06-17 06:09:05.35002+00
1430	47	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.352184+00
1431	33	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.354916+00
1432	55	MATCH	20	0	{}	2026-06-17 06:09:05.357055+00
1433	16	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.359228+00
1434	32	MATCH	20	0	{}	2026-06-17 06:09:05.361366+00
1435	14	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.36352+00
1574	15	MATCH	23	0	{}	2026-06-17 18:59:57.489762+00
1129	47	MATCH	13	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 00:04:29.367885+00
1130	23	MATCH	13	0	{}	2026-06-16 00:04:29.370859+00
1131	46	MATCH	13	5	{"draw": 3, "goalDiff": 2}	2026-06-16 00:04:29.373183+00
1132	59	MATCH	13	0	{}	2026-06-16 00:04:29.375554+00
1133	12	MATCH	13	0	{}	2026-06-16 00:04:29.377781+00
2050	58	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.556569+00
1437	11	MATCH	20	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 06:09:05.367912+00
1438	29	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.369998+00
1439	58	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.372142+00
1440	44	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.374359+00
1441	26	MATCH	20	0	{}	2026-06-17 06:09:05.376601+00
1442	43	MATCH	20	0	{}	2026-06-17 06:09:05.378805+00
1443	66	MATCH	20	0	{}	2026-06-17 06:09:05.380923+00
1444	51	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.383849+00
1445	41	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.385933+00
1147	15	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.928073+00
1148	34	MATCH	15	0	{}	2026-06-16 03:04:04.930987+00
1149	54	MATCH	15	0	{}	2026-06-16 03:04:04.933796+00
1150	25	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.935948+00
1151	9	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.9381+00
1152	27	MATCH	15	0	{}	2026-06-16 03:04:04.940177+00
1153	38	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.942382+00
1154	45	MATCH	15	0	{}	2026-06-16 03:04:04.944573+00
1155	30	MATCH	15	0	{}	2026-06-16 03:04:04.948375+00
1156	40	MATCH	15	0	{}	2026-06-16 03:04:04.950549+00
1157	55	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.953874+00
1158	50	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.95708+00
1159	28	MATCH	15	0	{}	2026-06-16 03:04:04.959216+00
1160	16	MATCH	15	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 03:04:04.96182+00
1161	36	MATCH	15	0	{}	2026-06-16 03:04:04.964008+00
1162	26	MATCH	15	0	{}	2026-06-16 03:04:04.966187+00
1163	35	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.97072+00
1164	37	MATCH	15	0	{}	2026-06-16 03:04:04.972862+00
1165	10	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.975149+00
1166	66	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.977443+00
1167	24	MATCH	15	0	{}	2026-06-16 03:04:04.979594+00
1168	56	MATCH	15	0	{}	2026-06-16 03:04:04.981773+00
1169	58	MATCH	15	0	{}	2026-06-16 03:04:04.983976+00
1170	11	MATCH	15	0	{}	2026-06-16 03:04:04.986145+00
1171	14	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:04.988395+00
1172	31	MATCH	15	0	{}	2026-06-16 03:04:04.990876+00
1173	47	MATCH	15	0	{}	2026-06-16 03:04:04.993726+00
1174	33	MATCH	15	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 03:04:04.996008+00
1175	43	MATCH	15	0	{}	2026-06-16 03:04:04.998132+00
1176	41	MATCH	15	0	{}	2026-06-16 03:04:05.000384+00
1177	13	MATCH	15	0	{}	2026-06-16 03:04:05.002596+00
1178	18	MATCH	15	0	{}	2026-06-16 03:04:05.004853+00
1179	48	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:05.007291+00
1180	29	MATCH	15	0	{}	2026-06-16 03:04:05.00945+00
1181	32	MATCH	15	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 03:04:05.011671+00
1182	42	MATCH	15	0	{}	2026-06-16 03:04:05.01415+00
1183	51	MATCH	15	0	{}	2026-06-16 03:04:05.016414+00
1184	44	MATCH	15	0	{}	2026-06-16 03:04:05.018613+00
1185	12	MATCH	15	5	{"draw": 3, "goalDiff": 2}	2026-06-16 03:04:05.020796+00
1186	46	MATCH	15	0	{}	2026-06-16 03:04:05.023025+00
1187	23	MATCH	15	0	{}	2026-06-16 03:04:05.025575+00
1446	35	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.388123+00
1447	56	MATCH	20	0	{}	2026-06-17 06:09:05.390348+00
1448	37	MATCH	20	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 06:09:05.392425+00
1449	31	MATCH	20	0	{}	2026-06-17 06:09:05.394678+00
1450	18	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.397378+00
1451	59	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.400735+00
1452	28	MATCH	20	0	{}	2026-06-17 06:09:05.402969+00
1255	15	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.424726+00
1256	54	MATCH	17	5	{"winner": 3, "goalDiff": 2}	2026-06-16 21:05:51.427915+00
1257	25	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.430851+00
1258	9	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.435737+00
1259	36	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.439441+00
1260	38	MATCH	17	5	{"winner": 3, "goalDiff": 2}	2026-06-16 21:05:51.441809+00
1261	27	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.444493+00
1262	24	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.446947+00
1263	30	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.44915+00
1264	47	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.451545+00
1265	33	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.45388+00
1266	55	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.456301+00
1267	16	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.459008+00
1268	32	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.463089+00
1269	14	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.465345+00
1270	45	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.467732+00
1271	59	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.470016+00
1272	41	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.472285+00
1273	11	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.475649+00
1274	40	MATCH	17	0	{}	2026-06-16 21:05:51.478627+00
1275	46	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.481676+00
1276	37	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.484723+00
1277	42	MATCH	17	5	{"winner": 3, "goalDiff": 2}	2026-06-16 21:05:51.487564+00
1278	48	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.490139+00
1279	29	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.492574+00
1280	13	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.495041+00
1281	28	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.498519+00
1282	58	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.501405+00
1283	56	MATCH	17	0	{}	2026-06-16 21:05:51.529995+00
1284	26	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.537076+00
1285	44	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.53937+00
1286	43	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.542723+00
1287	35	MATCH	17	5	{"winner": 3, "goalDiff": 2}	2026-06-16 21:05:51.545723+00
1288	51	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.549717+00
1289	34	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.552892+00
1290	66	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.555642+00
1291	31	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.558725+00
1292	23	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.562863+00
1293	10	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.566847+00
1294	50	MATCH	17	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-16 21:05:51.57082+00
1295	12	MATCH	17	3	{"winner": 3}	2026-06-16 21:05:51.574729+00
2051	11	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.558133+00
2052	28	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.560871+00
2053	27	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.562311+00
2054	36	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.563754+00
2055	31	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.565217+00
2056	23	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.566639+00
2057	26	MATCH	26	0	{}	2026-06-18 20:58:45.568132+00
1309	15	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.959967+00
1310	54	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.962888+00
1311	25	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.965114+00
1312	9	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.967476+00
1313	36	MATCH	18	0	{}	2026-06-17 00:01:00.969708+00
1314	38	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.97245+00
1315	24	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.974748+00
1316	27	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.976872+00
1317	40	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.978972+00
1318	47	MATCH	18	0	{}	2026-06-17 00:01:00.981105+00
1319	30	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.98351+00
1320	33	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.985834+00
1321	44	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.988794+00
1322	55	MATCH	18	0	{}	2026-06-17 00:01:00.991043+00
1323	32	MATCH	18	0	{}	2026-06-17 00:01:00.99331+00
1324	14	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.995456+00
1325	45	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:00.997642+00
1326	59	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.030186+00
1327	41	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.032649+00
1328	11	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.035082+00
1329	35	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.03769+00
1330	48	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.03999+00
2058	42	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.569616+00
2059	50	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.5711+00
1454	12	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.408335+00
1455	13	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.411101+00
1456	10	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.413283+00
1458	46	MATCH	20	5	{"winner": 3, "goalDiff": 2}	2026-06-17 06:09:05.41932+00
1459	42	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.421815+00
1460	50	MATCH	20	3	{"winner": 3}	2026-06-17 06:09:05.424018+00
2060	56	MATCH	26	0	{}	2026-06-18 20:58:45.572571+00
2061	46	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.574113+00
1331	13	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.042744+00
1332	58	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.045569+00
1333	26	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.047669+00
1334	56	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.050003+00
1335	43	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.052184+00
1336	51	MATCH	18	0	{}	2026-06-17 00:01:01.054393+00
1337	34	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.056562+00
1338	66	MATCH	18	0	{}	2026-06-17 00:01:01.058839+00
1339	29	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.061008+00
1340	16	MATCH	18	5	{"winner": 3, "goalDiff": 2}	2026-06-17 00:01:01.0632+00
1341	31	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.065383+00
1342	28	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.067508+00
1343	10	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.069588+00
1344	18	MATCH	18	0	{}	2026-06-17 00:01:01.071766+00
1345	23	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.073945+00
1346	46	MATCH	18	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 00:01:01.076347+00
1347	37	MATCH	18	5	{"winner": 3, "goalDiff": 2}	2026-06-17 00:01:01.078879+00
1348	12	MATCH	18	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-17 00:01:01.081625+00
1349	42	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.083869+00
1350	50	MATCH	18	3	{"winner": 3}	2026-06-17 00:01:01.086504+00
2062	59	MATCH	26	3	{"winner": 3}	2026-06-18 20:58:45.575582+00
2063	43	MATCH	26	0	{}	2026-06-18 20:58:45.577167+00
2676	15	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.213724+00
2677	25	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.224041+00
2678	54	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.225657+00
2679	38	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.228083+00
2680	9	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.232341+00
2681	27	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.239855+00
2682	55	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.241636+00
2683	14	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.246729+00
2684	28	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.248209+00
2685	40	MATCH	33	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 22:00:22.250177+00
2686	13	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.251671+00
2687	34	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.258109+00
2688	37	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.261064+00
2689	31	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.269094+00
2690	59	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.270601+00
2691	48	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.272036+00
2692	43	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.273478+00
2693	33	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.275772+00
2694	51	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.277406+00
2695	44	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.282926+00
2696	68	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.285135+00
2697	50	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.286605+00
2698	23	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.28806+00
2699	11	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.29392+00
2700	58	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.295457+00
2701	56	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.301745+00
2702	36	MATCH	33	0	{}	2026-06-20 22:00:22.303219+00
2703	24	MATCH	33	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 22:00:22.305244+00
2704	16	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.306667+00
2705	32	MATCH	33	5	{"winner": 3, "goalDiff": 2}	2026-06-20 22:00:22.309086+00
2706	35	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.310527+00
2707	47	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.315726+00
2708	45	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.318346+00
2709	66	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.319838+00
2710	10	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.321318+00
1575	9	MATCH	23	0	{}	2026-06-17 18:59:57.49483+00
1576	14	MATCH	23	0	{}	2026-06-17 18:59:57.50082+00
1577	54	MATCH	23	0	{}	2026-06-17 18:59:57.503337+00
1578	11	MATCH	23	0	{}	2026-06-17 18:59:57.507361+00
1579	30	MATCH	23	0	{}	2026-06-17 18:59:57.508886+00
1580	35	MATCH	23	0	{}	2026-06-17 18:59:57.511172+00
1581	47	MATCH	23	0	{}	2026-06-17 18:59:57.513328+00
1582	38	MATCH	23	0	{}	2026-06-17 18:59:57.530314+00
1583	23	MATCH	23	0	{}	2026-06-17 18:59:57.536365+00
1584	55	MATCH	23	0	{}	2026-06-17 18:59:57.545759+00
1585	40	MATCH	23	0	{}	2026-06-17 18:59:57.547409+00
1586	24	MATCH	23	0	{}	2026-06-17 18:59:57.548937+00
1587	10	MATCH	23	0	{}	2026-06-17 18:59:57.551081+00
1588	16	MATCH	23	0	{}	2026-06-17 18:59:57.553076+00
1589	27	MATCH	23	0	{}	2026-06-17 18:59:57.555433+00
1590	34	MATCH	23	0	{}	2026-06-17 18:59:57.558068+00
1591	56	MATCH	23	0	{}	2026-06-17 18:59:57.559443+00
1592	32	MATCH	23	0	{}	2026-06-17 18:59:57.562163+00
1593	44	MATCH	23	0	{}	2026-06-17 18:59:57.563684+00
1594	45	MATCH	23	0	{}	2026-06-17 18:59:57.569734+00
1595	37	MATCH	23	0	{}	2026-06-17 18:59:57.572539+00
1596	59	MATCH	23	0	{}	2026-06-17 18:59:57.574457+00
1597	28	MATCH	23	0	{}	2026-06-17 18:59:57.576062+00
1598	48	MATCH	23	0	{}	2026-06-17 18:59:57.581241+00
1599	51	MATCH	23	0	{}	2026-06-17 18:59:57.583037+00
1600	33	MATCH	23	0	{}	2026-06-17 18:59:57.585123+00
1601	13	MATCH	23	0	{}	2026-06-17 18:59:57.587118+00
1602	58	MATCH	23	0	{}	2026-06-17 18:59:57.593182+00
1603	36	MATCH	23	0	{}	2026-06-17 18:59:57.594813+00
1604	31	MATCH	23	0	{}	2026-06-17 18:59:57.596416+00
1605	41	MATCH	23	0	{}	2026-06-17 18:59:57.60174+00
1606	46	MATCH	23	0	{}	2026-06-17 18:59:57.603261+00
1607	50	MATCH	23	0	{}	2026-06-17 18:59:57.60487+00
1608	12	MATCH	23	0	{}	2026-06-17 18:59:57.606286+00
1609	29	MATCH	23	0	{}	2026-06-17 18:59:57.607754+00
1610	42	MATCH	23	0	{}	2026-06-17 18:59:57.609208+00
1611	25	MATCH	23	0	{}	2026-06-17 18:59:57.615323+00
1612	43	MATCH	23	0	{}	2026-06-17 18:59:57.617029+00
1613	68	MATCH	23	0	{}	2026-06-17 18:59:57.620149+00
2711	26	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.323724+00
2712	41	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.32875+00
2713	30	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.334731+00
2714	42	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.336224+00
2715	46	MATCH	33	3	{"winner": 3}	2026-06-20 22:00:22.337672+00
3429	15	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.729733+00
3430	54	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.732068+00
3431	47	MATCH	42	5	{"winner": 3, "goalDiff": 2}	2026-06-23 00:49:11.735066+00
3432	38	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.736679+00
3433	40	MATCH	42	5	{"winner": 3, "goalDiff": 2}	2026-06-23 00:49:11.73915+00
3434	46	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.741563+00
3435	55	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.746096+00
3436	43	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.751732+00
3437	34	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.753435+00
3438	68	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.75506+00
3439	10	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.763473+00
3440	29	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.770872+00
3441	32	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.77773+00
3442	41	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.784204+00
3443	28	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.790561+00
3444	14	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.795776+00
2273	16	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.432232+00
2274	43	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.433837+00
2275	32	MATCH	32	0	{}	2026-06-19 21:04:40.43548+00
2276	45	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.43692+00
2277	11	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.438366+00
2278	14	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.439771+00
2279	33	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.441191+00
2280	44	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.442689+00
2281	24	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.444061+00
2282	36	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.445771+00
2283	35	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.448673+00
2284	28	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.450159+00
2285	41	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.451666+00
2286	56	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.45307+00
1649	15	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.438801+00
1650	9	MATCH	22	5	{"winner": 3, "goalDiff": 2}	2026-06-17 22:02:01.445768+00
1651	14	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.447839+00
1652	54	MATCH	22	0	{}	2026-06-17 22:02:01.450817+00
1653	16	MATCH	22	0	{}	2026-06-17 22:02:01.455779+00
1654	30	MATCH	22	0	{}	2026-06-17 22:02:01.457886+00
1655	47	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.460889+00
1656	23	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.463688+00
1657	55	MATCH	22	0	{}	2026-06-17 22:02:01.467731+00
1658	40	MATCH	22	0	{}	2026-06-17 22:02:01.469858+00
1659	37	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.472729+00
1660	35	MATCH	22	5	{"winner": 3, "goalDiff": 2}	2026-06-17 22:02:01.478087+00
1661	10	MATCH	22	0	{}	2026-06-17 22:02:01.480179+00
1662	24	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.483511+00
1663	27	MATCH	22	0	{}	2026-06-17 22:02:01.485574+00
1664	34	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.487758+00
2287	13	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.454504+00
2288	37	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.455978+00
2289	29	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.458058+00
3445	27	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.802816+00
3446	51	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.808277+00
3447	48	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.811581+00
3448	59	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.81763+00
1665	38	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.491598+00
1666	11	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.494885+00
1667	56	MATCH	22	0	{}	2026-06-17 22:02:01.497736+00
1668	32	MATCH	22	5	{"winner": 3, "goalDiff": 2}	2026-06-17 22:02:01.501671+00
1669	45	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.504456+00
1670	28	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.507741+00
1671	48	MATCH	22	0	{}	2026-06-17 22:02:01.512008+00
1672	33	MATCH	22	0	{}	2026-06-17 22:02:01.515996+00
1673	51	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.51872+00
1674	59	MATCH	22	0	{}	2026-06-17 22:02:01.521752+00
1675	13	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.523824+00
1676	58	MATCH	22	0	{}	2026-06-17 22:02:01.526713+00
1677	41	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.53072+00
1678	36	MATCH	22	0	{}	2026-06-17 22:02:01.532761+00
1679	31	MATCH	22	0	{}	2026-06-17 22:02:01.535741+00
1680	50	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.537786+00
1681	25	MATCH	22	0	{}	2026-06-17 22:02:01.540745+00
1682	43	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.543721+00
1683	26	MATCH	22	0	{}	2026-06-17 22:02:01.547738+00
1684	66	MATCH	22	0	{}	2026-06-17 22:02:01.550729+00
1685	68	MATCH	22	5	{"winner": 3, "goalDiff": 2}	2026-06-17 22:02:01.553725+00
1686	18	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.556063+00
1687	46	MATCH	22	0	{}	2026-06-17 22:02:01.558685+00
1688	29	MATCH	22	3	{"winner": 3}	2026-06-17 22:02:01.561957+00
1689	12	MATCH	22	5	{"winner": 3, "goalDiff": 2}	2026-06-17 22:02:01.564395+00
2099	56	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.402084+00
2100	54	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.404487+00
2101	9	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.406114+00
2102	38	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.431052+00
2103	15	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.433064+00
2104	40	MATCH	27	0	{}	2026-06-18 23:59:27.434681+00
2105	10	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.436353+00
2106	34	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.438359+00
2107	55	MATCH	27	0	{}	2026-06-18 23:59:27.439926+00
2108	47	MATCH	27	0	{}	2026-06-18 23:59:27.441385+00
2109	35	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.442801+00
2110	24	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.444323+00
2111	13	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.445869+00
2112	48	MATCH	27	0	{}	2026-06-18 23:59:27.447298+00
2113	51	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.448565+00
2114	45	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.449983+00
2115	29	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.451378+00
2116	68	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.468034+00
2117	37	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.469669+00
2118	16	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.471319+00
2119	44	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.472756+00
2120	32	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.474194+00
2121	11	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.475713+00
2122	14	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.477197+00
2123	41	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.478684+00
2124	33	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.480174+00
2125	58	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.481592+00
2126	28	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.483051+00
2127	27	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.484545+00
2128	36	MATCH	27	0	{}	2026-06-18 23:59:27.486659+00
2129	31	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.488154+00
2130	23	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.489668+00
2131	26	MATCH	27	0	{}	2026-06-18 23:59:27.491175+00
2132	42	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.492668+00
2133	43	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.49469+00
1725	15	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.043034+00
1726	9	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.045844+00
1727	14	MATCH	21	0	{}	2026-06-18 01:04:09.047765+00
1728	54	MATCH	21	0	{}	2026-06-18 01:04:09.049793+00
1729	11	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.051928+00
1730	16	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.053952+00
2134	66	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.496955+00
2135	59	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.499439+00
2136	46	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.500867+00
2137	30	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.502432+00
2138	50	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.530504+00
2139	12	MATCH	27	3	{"winner": 3}	2026-06-18 23:59:27.532439+00
3449	45	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.820726+00
3450	25	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.826721+00
3451	50	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.832148+00
3452	42	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.845305+00
3453	44	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.85278+00
3454	9	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.854346+00
1731	38	MATCH	21	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 01:04:09.056148+00
1732	23	MATCH	21	0	{}	2026-06-18 01:04:09.058456+00
1733	55	MATCH	21	0	{}	2026-06-18 01:04:09.060491+00
1734	40	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.062737+00
1735	30	MATCH	21	0	{}	2026-06-18 01:04:09.064786+00
1736	35	MATCH	21	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 01:04:09.066886+00
1737	10	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.068999+00
1738	24	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.07101+00
1739	27	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.073544+00
1740	56	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.075635+00
1741	47	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.077822+00
1742	37	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.079842+00
1743	34	MATCH	21	0	{}	2026-06-18 01:04:09.081846+00
1744	44	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.083914+00
1745	45	MATCH	21	0	{}	2026-06-18 01:04:09.086084+00
1746	28	MATCH	21	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 01:04:09.088142+00
1747	48	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.090188+00
1748	51	MATCH	21	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 01:04:09.092174+00
1749	33	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.094223+00
1750	59	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.096323+00
1751	13	MATCH	21	0	{}	2026-06-18 01:04:09.098351+00
1752	58	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.10046+00
1753	36	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.128756+00
1754	68	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.131252+00
1755	31	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.13347+00
1756	25	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.135629+00
1757	43	MATCH	21	0	{}	2026-06-18 01:04:09.137711+00
1758	26	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.139818+00
1759	32	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.141998+00
1760	41	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.144043+00
1761	18	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.146225+00
1762	42	MATCH	21	3	{"winner": 3}	2026-06-18 01:04:09.14832+00
1763	66	MATCH	21	0	{}	2026-06-18 01:04:09.150354+00
1764	46	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.152395+00
1765	29	MATCH	21	0	{}	2026-06-18 01:04:09.155374+00
1766	50	MATCH	21	0	{}	2026-06-18 01:04:09.15747+00
1767	12	MATCH	21	5	{"winner": 3, "goalDiff": 2}	2026-06-18 01:04:09.159538+00
3455	36	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.865263+00
3456	24	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.876775+00
3457	26	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.901364+00
3458	11	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.908733+00
3459	37	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.917879+00
3460	31	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.919615+00
3461	35	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.922726+00
3462	33	MATCH	42	5	{"winner": 3, "goalDiff": 2}	2026-06-23 00:49:11.930729+00
3463	30	MATCH	42	5	{"winner": 3, "goalDiff": 2}	2026-06-23 00:49:11.936132+00
3464	13	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.94317+00
3465	12	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.954728+00
3466	58	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.956463+00
3467	56	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.963034+00
3468	23	MATCH	42	5	{"winner": 3, "goalDiff": 2}	2026-06-23 00:49:11.969608+00
3469	16	MATCH	42	3	{"winner": 3}	2026-06-23 00:49:11.979746+00
3470	66	MATCH	42	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 00:49:11.998805+00
4281	25	MATCH	51	0	{}	2026-06-24 20:59:46.647785+00
4282	10	MATCH	51	0	{}	2026-06-24 20:59:46.652829+00
4283	37	MATCH	51	0	{}	2026-06-24 20:59:46.656927+00
4284	27	MATCH	51	3	{"winner": 3}	2026-06-24 20:59:46.662814+00
4285	55	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.665039+00
4286	32	MATCH	51	0	{}	2026-06-24 20:59:46.6671+00
4287	33	MATCH	51	0	{}	2026-06-24 20:59:46.672651+00
4288	29	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.676735+00
4289	47	MATCH	51	0	{}	2026-06-24 20:59:46.68121+00
4290	15	MATCH	51	0	{}	2026-06-24 20:59:46.687024+00
4291	38	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.690728+00
4292	45	MATCH	51	0	{}	2026-06-24 20:59:46.695457+00
4293	36	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.697517+00
4294	24	MATCH	51	0	{}	2026-06-24 20:59:46.699528+00
4295	46	MATCH	51	0	{}	2026-06-24 20:59:46.703862+00
4296	40	MATCH	51	0	{}	2026-06-24 20:59:46.706076+00
4297	54	MATCH	51	0	{}	2026-06-24 20:59:46.719571+00
2254	51	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.401739+00
2255	46	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.40367+00
2256	50	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.407098+00
2257	58	MATCH	32	0	{}	2026-06-19 21:04:40.408622+00
2258	15	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.410556+00
2259	47	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.412201+00
2260	55	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.413644+00
2261	9	MATCH	32	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 21:04:40.41509+00
2262	38	MATCH	32	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 21:04:40.416468+00
2263	54	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.417834+00
2264	68	MATCH	32	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 21:04:40.41922+00
2265	10	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.420735+00
2266	40	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.422119+00
2267	31	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.423496+00
2268	30	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.424899+00
2269	59	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.426402+00
2270	27	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.427767+00
2271	12	MATCH	32	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 21:04:40.42931+00
1803	15	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.542056+00
1804	9	MATCH	24	30	{"winner": 9, "goalDiff": 6, "exactScore": 15}	2026-06-18 04:01:39.544407+00
1805	14	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.54644+00
1806	54	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.548459+00
1807	16	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.550555+00
1808	37	MATCH	24	30	{"winner": 9, "goalDiff": 6, "exactScore": 15}	2026-06-18 04:01:39.552661+00
1809	38	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.55559+00
1810	23	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.558428+00
1811	55	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.560468+00
1812	40	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.562721+00
1813	30	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.564786+00
1814	35	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.566882+00
1815	24	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.568898+00
1816	27	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.571322+00
1817	34	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.573355+00
1818	56	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.575381+00
1819	10	MATCH	24	30	{"winner": 9, "goalDiff": 6, "exactScore": 15}	2026-06-18 04:01:39.577409+00
1820	47	MATCH	24	30	{"winner": 9, "goalDiff": 6, "exactScore": 15}	2026-06-18 04:01:39.579508+00
1821	32	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.581515+00
1822	45	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.583525+00
1823	48	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.585564+00
1824	51	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.587644+00
1825	33	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.590768+00
1826	13	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.592783+00
1827	58	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.595156+00
1828	36	MATCH	24	30	{"winner": 9, "goalDiff": 6, "exactScore": 15}	2026-06-18 04:01:39.59719+00
1829	31	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.599283+00
1830	25	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.601373+00
1831	43	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.628541+00
1832	26	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.630954+00
1833	68	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.634095+00
1834	66	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.63633+00
1835	41	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.638442+00
1836	18	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.640554+00
1837	42	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.643662+00
1838	44	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.645911+00
1839	59	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.648074+00
1840	28	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.650112+00
1841	50	MATCH	24	9	{"winner": 9}	2026-06-18 04:01:39.652604+00
1842	29	MATCH	24	15	{"winner": 9, "goalDiff": 6}	2026-06-18 04:01:39.654772+00
1843	46	MATCH	24	30	{"winner": 9, "goalDiff": 6, "exactScore": 15}	2026-06-18 04:01:39.656851+00
1844	11	MATCH	24	30	{"winner": 9, "goalDiff": 6, "exactScore": 15}	2026-06-18 04:01:39.659398+00
2272	34	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.43076+00
2492	35	MATCH	31	0	{}	2026-06-20 05:05:41.045432+00
2493	15	MATCH	31	3	{"winner": 3}	2026-06-20 05:05:41.047861+00
2494	50	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.049397+00
4298	68	MATCH	51	0	{}	2026-06-24 20:59:46.726554+00
3051	15	MATCH	39	0	{}	2026-06-21 21:01:06.233379+00
3052	25	MATCH	39	0	{}	2026-06-21 21:01:06.235425+00
3053	54	MATCH	39	0	{}	2026-06-21 21:01:06.237003+00
3054	14	MATCH	39	0	{}	2026-06-21 21:01:06.238732+00
3055	36	MATCH	39	0	{}	2026-06-21 21:01:06.240323+00
3056	23	MATCH	39	0	{}	2026-06-21 21:01:06.242044+00
3057	34	MATCH	39	0	{}	2026-06-21 21:01:06.243854+00
3058	10	MATCH	39	0	{}	2026-06-21 21:01:06.245399+00
3059	55	MATCH	39	5	{"draw": 3, "goalDiff": 2}	2026-06-21 21:01:06.24785+00
3060	38	MATCH	39	0	{}	2026-06-21 21:01:06.249446+00
3061	45	MATCH	39	0	{}	2026-06-21 21:01:06.251767+00
3062	33	MATCH	39	0	{}	2026-06-21 21:01:06.253608+00
3063	30	MATCH	39	0	{}	2026-06-21 21:01:06.255732+00
3064	24	MATCH	39	0	{}	2026-06-21 21:01:06.257715+00
3065	27	MATCH	39	0	{}	2026-06-21 21:01:06.259094+00
3066	11	MATCH	39	0	{}	2026-06-21 21:01:06.260477+00
3067	9	MATCH	39	0	{}	2026-06-21 21:01:06.261883+00
3068	43	MATCH	39	0	{}	2026-06-21 21:01:06.263311+00
3069	40	MATCH	39	0	{}	2026-06-21 21:01:06.264832+00
3070	68	MATCH	39	0	{}	2026-06-21 21:01:06.266226+00
3071	37	MATCH	39	0	{}	2026-06-21 21:01:06.267574+00
3072	26	MATCH	39	0	{}	2026-06-21 21:01:06.26906+00
3073	32	MATCH	39	5	{"draw": 3, "goalDiff": 2}	2026-06-21 21:01:06.270599+00
3074	28	MATCH	39	0	{}	2026-06-21 21:01:06.272073+00
3075	16	MATCH	39	0	{}	2026-06-21 21:01:06.273578+00
3076	31	MATCH	39	0	{}	2026-06-21 21:01:06.275009+00
3077	48	MATCH	39	5	{"draw": 3, "goalDiff": 2}	2026-06-21 21:01:06.276385+00
3078	66	MATCH	39	0	{}	2026-06-21 21:01:06.277896+00
3079	51	MATCH	39	0	{}	2026-06-21 21:01:06.280099+00
3080	59	MATCH	39	0	{}	2026-06-21 21:01:06.329498+00
3081	44	MATCH	39	0	{}	2026-06-21 21:01:06.331364+00
3082	13	MATCH	39	0	{}	2026-06-21 21:01:06.333461+00
3083	29	MATCH	39	0	{}	2026-06-21 21:01:06.334974+00
3084	47	MATCH	39	0	{}	2026-06-21 21:01:06.336995+00
3085	35	MATCH	39	0	{}	2026-06-21 21:01:06.338391+00
3086	46	MATCH	39	0	{}	2026-06-21 21:01:06.340211+00
3087	50	MATCH	39	0	{}	2026-06-21 21:01:06.341969+00
3088	56	MATCH	39	0	{}	2026-06-21 21:01:06.343565+00
3089	58	MATCH	39	0	{}	2026-06-21 21:01:06.345203+00
3090	42	MATCH	39	0	{}	2026-06-21 21:01:06.346843+00
3091	12	MATCH	39	0	{}	2026-06-21 21:01:06.348448+00
4299	28	MATCH	51	0	{}	2026-06-24 20:59:46.731816+00
4300	43	MATCH	51	0	{}	2026-06-24 20:59:46.742733+00
4301	14	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.745102+00
4302	26	MATCH	51	0	{}	2026-06-24 20:59:46.747235+00
4303	51	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.751786+00
4304	41	MATCH	51	0	{}	2026-06-24 20:59:46.756089+00
4305	9	MATCH	51	0	{}	2026-06-24 20:59:46.763743+00
4306	44	MATCH	51	3	{"winner": 3}	2026-06-24 20:59:46.766032+00
4307	13	MATCH	51	0	{}	2026-06-24 20:59:46.769643+00
4308	35	MATCH	51	0	{}	2026-06-24 20:59:46.771764+00
4309	56	MATCH	51	0	{}	2026-06-24 20:59:46.776662+00
4310	30	MATCH	51	0	{}	2026-06-24 20:59:46.778765+00
4311	58	MATCH	51	0	{}	2026-06-24 20:59:46.78209+00
1957	56	MATCH	25	0	{}	2026-06-18 17:59:12.283307+00
1958	54	MATCH	25	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 17:59:12.285758+00
1959	29	MATCH	25	0	{}	2026-06-18 17:59:12.287319+00
1960	9	MATCH	25	0	{}	2026-06-18 17:59:12.288994+00
1961	15	MATCH	25	0	{}	2026-06-18 17:59:12.331598+00
1962	40	MATCH	25	0	{}	2026-06-18 17:59:12.333482+00
1963	10	MATCH	25	0	{}	2026-06-18 17:59:12.335249+00
1964	34	MATCH	25	0	{}	2026-06-18 17:59:12.336805+00
1965	55	MATCH	25	0	{}	2026-06-18 17:59:12.338426+00
1966	59	MATCH	25	0	{}	2026-06-18 17:59:12.339976+00
1967	47	MATCH	25	5	{"draw": 3, "goalDiff": 2}	2026-06-18 17:59:12.341425+00
1968	50	MATCH	25	0	{}	2026-06-18 17:59:12.342983+00
1969	46	MATCH	25	0	{}	2026-06-18 17:59:12.344534+00
1970	68	MATCH	25	0	{}	2026-06-18 17:59:12.346209+00
1971	35	MATCH	25	0	{}	2026-06-18 17:59:12.347675+00
1972	24	MATCH	25	0	{}	2026-06-18 17:59:12.349162+00
1973	48	MATCH	25	0	{}	2026-06-18 17:59:12.350777+00
1974	45	MATCH	25	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 17:59:12.352241+00
1975	51	MATCH	25	0	{}	2026-06-18 17:59:12.353737+00
1976	13	MATCH	25	0	{}	2026-06-18 17:59:12.355506+00
1977	37	MATCH	25	0	{}	2026-06-18 17:59:12.358187+00
1978	38	MATCH	25	0	{}	2026-06-18 17:59:12.360081+00
1979	44	MATCH	25	0	{}	2026-06-18 17:59:12.36157+00
1980	16	MATCH	25	0	{}	2026-06-18 17:59:12.363783+00
1981	58	MATCH	25	0	{}	2026-06-18 17:59:12.365248+00
1982	32	MATCH	25	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 17:59:12.367192+00
1983	11	MATCH	25	0	{}	2026-06-18 17:59:12.369095+00
1984	14	MATCH	25	0	{}	2026-06-18 17:59:12.370549+00
1985	41	MATCH	25	0	{}	2026-06-18 17:59:12.372072+00
1986	36	MATCH	25	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 17:59:12.373511+00
1987	42	MATCH	25	0	{}	2026-06-18 17:59:12.374936+00
1988	30	MATCH	25	0	{}	2026-06-18 17:59:12.376346+00
1989	33	MATCH	25	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-18 17:59:12.377779+00
2175	56	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.657441+00
2176	54	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.660097+00
2177	29	MATCH	28	0	{}	2026-06-19 02:56:40.662093+00
2178	9	MATCH	28	0	{}	2026-06-19 02:56:40.664997+00
2179	15	MATCH	28	0	{}	2026-06-19 02:56:40.668204+00
2180	10	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.670546+00
2181	34	MATCH	28	0	{}	2026-06-19 02:56:40.67343+00
2182	35	MATCH	28	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 02:56:40.676905+00
2183	48	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.678251+00
2184	37	MATCH	28	0	{}	2026-06-19 02:56:40.68109+00
2185	24	MATCH	28	0	{}	2026-06-19 02:56:40.682425+00
2186	40	MATCH	28	0	{}	2026-06-19 02:56:40.684613+00
2187	45	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.68677+00
2188	47	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.68892+00
2189	51	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.691651+00
2190	55	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.693226+00
2191	38	MATCH	28	0	{}	2026-06-19 02:56:40.695721+00
2192	68	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.697121+00
2193	16	MATCH	28	0	{}	2026-06-19 02:56:40.700173+00
2194	44	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.701672+00
2195	58	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.705126+00
2196	32	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.70641+00
2197	11	MATCH	28	0	{}	2026-06-19 02:56:40.710414+00
2198	14	MATCH	28	0	{}	2026-06-19 02:56:40.713032+00
2199	30	MATCH	28	0	{}	2026-06-19 02:56:40.714406+00
2200	33	MATCH	28	0	{}	2026-06-19 02:56:40.717037+00
2201	50	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.718371+00
2202	41	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.730682+00
2203	28	MATCH	28	0	{}	2026-06-19 02:56:40.732213+00
2204	27	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.735301+00
2205	13	MATCH	28	0	{}	2026-06-19 02:56:40.739006+00
2206	36	MATCH	28	0	{}	2026-06-19 02:56:40.740658+00
2207	31	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.745397+00
2208	26	MATCH	28	0	{}	2026-06-19 02:56:40.747235+00
2209	43	MATCH	28	0	{}	2026-06-19 02:56:40.751233+00
2210	66	MATCH	28	0	{}	2026-06-19 02:56:40.752605+00
2211	12	MATCH	28	0	{}	2026-06-19 02:56:40.754689+00
2212	59	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.756399+00
2213	42	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.758488+00
2214	46	MATCH	28	5	{"winner": 3, "goalDiff": 2}	2026-06-19 02:56:40.760095+00
2215	23	MATCH	28	0	{}	2026-06-19 02:56:40.762787+00
2585	15	MATCH	35	0	{}	2026-06-20 18:56:55.069839+00
2586	25	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.073407+00
2587	54	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.128575+00
2588	9	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.130623+00
2589	38	MATCH	35	0	{}	2026-06-20 18:56:55.133061+00
2590	27	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.135042+00
2591	55	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.13872+00
2592	14	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.140144+00
2593	50	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.141576+00
2594	46	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.143131+00
2595	28	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.148741+00
2596	51	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.150209+00
2597	40	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.151626+00
2598	32	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.153026+00
2599	11	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.154667+00
2600	13	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.15689+00
2601	34	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.158561+00
2602	31	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.162178+00
2603	36	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.165775+00
2604	59	MATCH	35	0	{}	2026-06-20 18:56:55.1675+00
2605	58	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.169732+00
2606	48	MATCH	35	0	{}	2026-06-20 18:56:55.171399+00
2607	35	MATCH	35	0	{}	2026-06-20 18:56:55.17291+00
2608	43	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.175722+00
2609	33	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.177295+00
2610	44	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.179071+00
2611	68	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.18123+00
2612	41	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.183241+00
2613	16	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.184849+00
2614	37	MATCH	35	0	{}	2026-06-20 18:56:55.186584+00
2615	23	MATCH	35	0	{}	2026-06-20 18:56:55.188418+00
2616	30	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.18998+00
2617	47	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.19149+00
2618	56	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.230185+00
2619	24	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.232808+00
2290	66	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.459496+00
2291	23	MATCH	32	5	{"winner": 3, "goalDiff": 2}	2026-06-19 21:04:40.461229+00
2292	48	MATCH	32	3	{"winner": 3}	2026-06-19 21:04:40.462629+00
2293	26	MATCH	32	0	{}	2026-06-19 21:04:40.46406+00
2294	25	MATCH	32	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 21:04:40.46545+00
2769	15	MATCH	34	0	{}	2026-06-21 01:55:38.197516+00
2770	25	MATCH	34	0	{}	2026-06-21 01:55:38.201641+00
2771	54	MATCH	34	0	{}	2026-06-21 01:55:38.20536+00
2772	38	MATCH	34	0	{}	2026-06-21 01:55:38.20783+00
2773	55	MATCH	34	5	{"draw": 3, "goalDiff": 2}	2026-06-21 01:55:38.210525+00
2774	9	MATCH	34	0	{}	2026-06-21 01:55:38.213537+00
2775	14	MATCH	34	0	{}	2026-06-21 01:55:38.216491+00
2776	28	MATCH	34	0	{}	2026-06-21 01:55:38.218343+00
2777	47	MATCH	34	0	{}	2026-06-21 01:55:38.219801+00
2778	27	MATCH	34	0	{}	2026-06-21 01:55:38.222947+00
2779	40	MATCH	34	0	{}	2026-06-21 01:55:38.225909+00
2780	32	MATCH	34	5	{"draw": 3, "goalDiff": 2}	2026-06-21 01:55:38.228+00
2781	13	MATCH	34	0	{}	2026-06-21 01:55:38.231749+00
2782	34	MATCH	34	0	{}	2026-06-21 01:55:38.233274+00
2783	31	MATCH	34	0	{}	2026-06-21 01:55:38.235983+00
2784	59	MATCH	34	0	{}	2026-06-21 01:55:38.23909+00
2785	48	MATCH	34	5	{"draw": 3, "goalDiff": 2}	2026-06-21 01:55:38.241452+00
2786	43	MATCH	34	0	{}	2026-06-21 01:55:38.243222+00
2787	41	MATCH	34	0	{}	2026-06-21 01:55:38.245186+00
2788	33	MATCH	34	0	{}	2026-06-21 01:55:38.246784+00
2789	51	MATCH	34	0	{}	2026-06-21 01:55:38.248175+00
2790	44	MATCH	34	0	{}	2026-06-21 01:55:38.249717+00
2791	68	MATCH	34	0	{}	2026-06-21 01:55:38.251064+00
2792	16	MATCH	34	0	{}	2026-06-21 01:55:38.252763+00
2793	50	MATCH	34	0	{}	2026-06-21 01:55:38.254248+00
2794	56	MATCH	34	0	{}	2026-06-21 01:55:38.255773+00
2795	58	MATCH	34	0	{}	2026-06-21 01:55:38.258215+00
2796	24	MATCH	34	0	{}	2026-06-21 01:55:38.260057+00
2797	11	MATCH	34	0	{}	2026-06-21 01:55:38.261375+00
2798	37	MATCH	34	0	{}	2026-06-21 01:55:38.263722+00
2799	35	MATCH	34	0	{}	2026-06-21 01:55:38.265226+00
2800	36	MATCH	34	0	{}	2026-06-21 01:55:38.268497+00
2801	45	MATCH	34	0	{}	2026-06-21 01:55:38.269913+00
2802	66	MATCH	34	0	{}	2026-06-21 01:55:38.27129+00
2803	10	MATCH	34	0	{}	2026-06-21 01:55:38.272693+00
2804	26	MATCH	34	0	{}	2026-06-21 01:55:38.274081+00
2805	30	MATCH	34	0	{}	2026-06-21 01:55:38.275506+00
2806	29	MATCH	34	0	{}	2026-06-21 01:55:38.276864+00
2333	35	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.030406+00
2334	50	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.033426+00
2335	15	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.036326+00
2336	54	MATCH	30	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 23:59:16.037942+00
2337	47	MATCH	30	0	{}	2026-06-19 23:59:16.03942+00
2338	55	MATCH	30	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 23:59:16.04128+00
2339	9	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.043666+00
2340	38	MATCH	30	0	{}	2026-06-19 23:59:16.130403+00
2341	10	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.132251+00
2342	40	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.133867+00
2343	37	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.135281+00
2344	59	MATCH	30	0	{}	2026-06-19 23:59:16.136765+00
2345	27	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.138378+00
2346	12	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.139991+00
2347	34	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.141498+00
2348	16	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.142919+00
2349	43	MATCH	30	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 23:59:16.144391+00
2350	32	MATCH	30	0	{}	2026-06-19 23:59:16.146055+00
2351	45	MATCH	30	0	{}	2026-06-19 23:59:16.230434+00
2807	23	MATCH	34	0	{}	2026-06-21 01:55:38.279786+00
2808	42	MATCH	34	0	{}	2026-06-21 01:55:38.28121+00
2809	46	MATCH	34	0	{}	2026-06-21 01:55:38.283796+00
4312	11	MATCH	51	0	{}	2026-06-24 20:59:46.784808+00
4313	59	MATCH	51	0	{}	2026-06-24 20:59:46.787874+00
4314	31	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.790733+00
4315	34	MATCH	51	0	{}	2026-06-24 20:59:46.793509+00
4316	12	MATCH	51	3	{"winner": 3}	2026-06-24 20:59:46.796834+00
4317	48	MATCH	51	0	{}	2026-06-24 20:59:46.799632+00
4318	23	MATCH	51	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 20:59:46.801681+00
4319	50	MATCH	51	0	{}	2026-06-24 20:59:46.805742+00
4320	66	MATCH	51	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:46.807728+00
5160	9	MATCH	57	0	{}	2026-06-26 00:58:54.650504+00
5161	10	MATCH	57	0	{}	2026-06-26 00:58:54.653168+00
5162	11	MATCH	57	0	{}	2026-06-26 00:58:54.655275+00
5163	13	MATCH	57	0	{}	2026-06-26 00:58:54.657374+00
5164	14	MATCH	57	0	{}	2026-06-26 00:58:54.659538+00
5165	15	MATCH	57	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:58:54.661737+00
5166	23	MATCH	57	0	{}	2026-06-26 00:58:54.664151+00
5167	24	MATCH	57	5	{"draw": 3, "goalDiff": 2}	2026-06-26 00:58:54.666356+00
5168	25	MATCH	57	0	{}	2026-06-26 00:58:54.668609+00
2352	11	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.232982+00
2353	31	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.23505+00
2354	14	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.236501+00
2355	41	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.23857+00
2356	44	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.240068+00
2357	30	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.241553+00
2358	36	MATCH	30	0	{}	2026-06-19 23:59:16.243044+00
2359	28	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.244487+00
2360	56	MATCH	30	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 23:59:16.24707+00
2361	58	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.248512+00
2362	13	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.249954+00
2363	33	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.251423+00
2364	68	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.330419+00
2365	29	MATCH	30	0	{}	2026-06-19 23:59:16.332439+00
2366	66	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.33391+00
2367	24	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.335346+00
2368	26	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.336789+00
2369	25	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.338229+00
2370	51	MATCH	30	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 23:59:16.339683+00
2371	23	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.341268+00
2372	48	MATCH	30	3	{"winner": 3}	2026-06-19 23:59:16.342873+00
2373	46	MATCH	30	5	{"winner": 3, "goalDiff": 2}	2026-06-19 23:59:16.344433+00
2374	42	MATCH	30	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-19 23:59:16.346732+00
5169	26	MATCH	57	5	{"draw": 3, "goalDiff": 2}	2026-06-26 00:58:54.671029+00
5170	27	MATCH	57	0	{}	2026-06-26 00:58:54.67312+00
5171	28	MATCH	57	0	{}	2026-06-26 00:58:54.67518+00
5172	29	MATCH	57	0	{}	2026-06-26 00:58:54.677219+00
5173	30	MATCH	57	0	{}	2026-06-26 00:58:54.679389+00
5174	31	MATCH	57	0	{}	2026-06-26 00:58:54.682397+00
5175	32	MATCH	57	0	{}	2026-06-26 00:58:54.685126+00
5176	33	MATCH	57	0	{}	2026-06-26 00:58:54.687274+00
5177	34	MATCH	57	0	{}	2026-06-26 00:58:54.689333+00
5178	35	MATCH	57	0	{}	2026-06-26 00:58:54.691347+00
5179	36	MATCH	57	0	{}	2026-06-26 00:58:54.693499+00
5180	37	MATCH	57	0	{}	2026-06-26 00:58:54.695579+00
5181	38	MATCH	57	5	{"draw": 3, "goalDiff": 2}	2026-06-26 00:58:54.697677+00
5182	40	MATCH	57	0	{}	2026-06-26 00:58:54.699875+00
5183	41	MATCH	57	0	{}	2026-06-26 00:58:54.703079+00
5184	42	MATCH	57	0	{}	2026-06-26 00:58:54.729895+00
3749	66	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.35719+00
3750	11	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.360208+00
3751	48	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.364727+00
3752	14	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.366814+00
3753	41	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.368871+00
3754	25	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.370953+00
3755	58	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.377761+00
3756	12	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.384236+00
3757	59	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.38898+00
3758	31	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.432279+00
3759	50	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.439247+00
3760	42	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.443638+00
3761	27	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.446296+00
3762	33	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.449836+00
3763	30	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.453193+00
3764	51	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.456786+00
3765	56	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.470743+00
3766	24	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.474639+00
3767	26	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.478876+00
5185	43	MATCH	57	0	{}	2026-06-26 00:58:54.732661+00
5186	44	MATCH	57	0	{}	2026-06-26 00:58:54.735133+00
5187	45	MATCH	57	0	{}	2026-06-26 00:58:54.73731+00
5188	46	MATCH	57	0	{}	2026-06-26 00:58:54.739317+00
5189	47	MATCH	57	0	{}	2026-06-26 00:58:54.742122+00
5190	48	MATCH	57	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:58:54.744545+00
5191	50	MATCH	57	0	{}	2026-06-26 00:58:54.746986+00
5192	51	MATCH	57	0	{}	2026-06-26 00:58:54.749285+00
5193	54	MATCH	57	0	{}	2026-06-26 00:58:54.751617+00
5194	55	MATCH	57	0	{}	2026-06-26 00:58:54.75368+00
5195	56	MATCH	57	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:58:54.756343+00
5196	58	MATCH	57	0	{}	2026-06-26 00:58:54.758396+00
5197	59	MATCH	57	0	{}	2026-06-26 00:58:54.760509+00
5198	66	MATCH	57	5	{"draw": 3, "goalDiff": 2}	2026-06-26 00:58:54.76264+00
5199	68	MATCH	57	0	{}	2026-06-26 00:58:54.765372+00
6151	9	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.103744+00
6152	10	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.106455+00
6153	11	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.108434+00
8061	34	MATCH	74	0	{}	2026-06-29 23:29:55.708239+00
2413	35	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.203143+00
2414	15	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.20505+00
2415	54	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.206627+00
2416	47	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.208105+00
2417	38	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.209689+00
2418	55	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.211264+00
2419	9	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.212744+00
2420	33	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.214212+00
2421	30	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.215669+00
2422	68	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.21724+00
2423	10	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.219167+00
2424	40	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.220577+00
2425	31	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.222056+00
2426	37	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.223594+00
2427	27	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.225046+00
2428	12	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.226524+00
2429	34	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.227854+00
2430	16	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.229146+00
2431	32	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.230513+00
2432	45	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.231917+00
2433	11	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.233327+00
2434	14	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.234664+00
2435	56	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.236035+00
2436	44	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.237345+00
2437	36	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.238865+00
2438	28	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.24032+00
2439	41	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.241726+00
2440	58	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.243052+00
2441	29	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.244448+00
2442	66	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.245748+00
2443	24	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.247141+00
2444	25	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.248579+00
2445	13	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.249996+00
2446	26	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.251351+00
2447	42	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.252688+00
2448	51	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.254002+00
2449	23	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.255354+00
2450	50	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.256876+00
2451	46	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.25825+00
2452	59	MATCH	29	3	{"winner": 3}	2026-06-20 02:31:47.259636+00
2453	43	MATCH	29	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 02:31:47.261086+00
2863	15	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.434236+00
2864	25	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.4363+00
2865	54	MATCH	36	0	{}	2026-06-21 05:56:37.437799+00
2866	38	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.439204+00
2867	27	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.44076+00
2868	55	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.442154+00
2869	9	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.443691+00
2870	14	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.44517+00
2871	28	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.446525+00
2872	40	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.447987+00
2873	32	MATCH	36	0	{}	2026-06-21 05:56:37.449409+00
2874	11	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.451124+00
2875	34	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.452722+00
2876	37	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.454362+00
2877	31	MATCH	36	0	{}	2026-06-21 05:56:37.456106+00
2878	35	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.457512+00
2879	43	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.459024+00
2880	48	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.46037+00
2881	44	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.461799+00
2882	68	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.463212+00
2883	16	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.464943+00
2884	47	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.466223+00
2885	58	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.467632+00
2886	56	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.468943+00
2887	24	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.470392+00
2888	36	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.47186+00
2889	33	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.473164+00
2890	50	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.528529+00
2891	51	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.530602+00
2892	13	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.532113+00
2893	45	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.534043+00
2894	66	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.535403+00
2895	10	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.536926+00
2896	26	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.538297+00
2897	30	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.539801+00
2898	42	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.541227+00
2899	29	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.542626+00
2900	12	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.544051+00
2901	23	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.545441+00
2902	46	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.546798+00
2903	59	MATCH	36	3	{"winner": 3}	2026-06-21 05:56:37.548243+00
3525	15	MATCH	41	0	{}	2026-06-23 01:59:37.029763+00
3526	54	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.032505+00
3527	47	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.034106+00
3528	38	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.035752+00
3529	40	MATCH	41	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 01:59:37.037652+00
3530	46	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.039075+00
3531	55	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.040526+00
3532	43	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.042041+00
3533	34	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.043458+00
3534	68	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.044931+00
3535	10	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.046487+00
3536	29	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.048281+00
3537	32	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.050098+00
3538	37	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.051622+00
3539	28	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.053418+00
3540	14	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.055004+00
3541	27	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.056425+00
3542	41	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.057829+00
3543	59	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.059905+00
3544	45	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.061431+00
3545	25	MATCH	41	0	{}	2026-06-23 01:59:37.062919+00
3546	48	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.065864+00
3547	9	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.067295+00
3548	44	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.068806+00
3549	36	MATCH	41	0	{}	2026-06-23 01:59:37.070339+00
3550	24	MATCH	41	0	{}	2026-06-23 01:59:37.073019+00
3551	26	MATCH	41	0	{}	2026-06-23 01:59:37.074571+00
3552	50	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.076081+00
3553	11	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.077609+00
3554	31	MATCH	41	0	{}	2026-06-23 01:59:37.079027+00
3555	51	MATCH	41	0	{}	2026-06-23 01:59:37.081127+00
3556	35	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.082642+00
3557	33	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.129421+00
3558	30	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.131196+00
3559	58	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.132827+00
3560	56	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.134443+00
3561	66	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.135794+00
3562	42	MATCH	41	3	{"winner": 3}	2026-06-23 01:59:37.137151+00
3563	23	MATCH	41	5	{"winner": 3, "goalDiff": 2}	2026-06-23 01:59:37.138587+00
6154	13	MATCH	67	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:13.110738+00
6155	14	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.113326+00
6156	15	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.115654+00
6157	23	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.117741+00
6158	24	MATCH	67	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:13.120196+00
6159	25	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.122303+00
6160	27	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.124327+00
6161	28	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.127333+00
6162	29	MATCH	67	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:13.12937+00
6163	30	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.131462+00
6164	31	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.133948+00
6165	32	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.136291+00
6166	33	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.138505+00
6167	34	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.141076+00
6168	35	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.143106+00
6169	36	MATCH	67	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:13.145422+00
6170	37	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.150055+00
6171	38	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.152182+00
8062	13	MATCH	74	0	{}	2026-06-29 23:29:56.528569+00
2495	38	MATCH	31	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 05:05:41.132177+00
2496	55	MATCH	31	0	{}	2026-06-20 05:05:41.135084+00
2497	9	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.137616+00
2498	10	MATCH	31	0	{}	2026-06-20 05:05:41.139859+00
2499	40	MATCH	31	0	{}	2026-06-20 05:05:41.14175+00
2500	31	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.143436+00
2501	27	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.145909+00
2502	34	MATCH	31	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 05:05:41.147593+00
2503	16	MATCH	31	0	{}	2026-06-20 05:05:41.149225+00
2504	43	MATCH	31	0	{}	2026-06-20 05:05:41.15091+00
2505	33	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.152588+00
2506	45	MATCH	31	0	{}	2026-06-20 05:05:41.15479+00
2507	68	MATCH	31	3	{"winner": 3}	2026-06-20 05:05:41.156332+00
2508	11	MATCH	31	0	{}	2026-06-20 05:05:41.157804+00
2509	14	MATCH	31	0	{}	2026-06-20 05:05:41.159405+00
2510	44	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.162644+00
2511	30	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.164133+00
2512	36	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.167138+00
2513	28	MATCH	31	0	{}	2026-06-20 05:05:41.175222+00
2514	13	MATCH	31	0	{}	2026-06-20 05:05:41.179536+00
2515	54	MATCH	31	0	{}	2026-06-20 05:05:41.182989+00
2516	37	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.186147+00
2517	32	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.188478+00
2518	56	MATCH	31	0	{}	2026-06-20 05:05:41.190106+00
2519	58	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.192777+00
2520	29	MATCH	31	3	{"winner": 3}	2026-06-20 05:05:41.19609+00
2521	66	MATCH	31	0	{}	2026-06-20 05:05:41.199653+00
2522	24	MATCH	31	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-20 05:05:41.201066+00
2523	25	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.202483+00
2524	26	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.203783+00
2525	23	MATCH	31	0	{}	2026-06-20 05:05:41.230471+00
2526	47	MATCH	31	3	{"winner": 3}	2026-06-20 05:05:41.232409+00
2527	48	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.234362+00
2528	41	MATCH	31	0	{}	2026-06-20 05:05:41.236876+00
2529	59	MATCH	31	0	{}	2026-06-20 05:05:41.240508+00
2530	42	MATCH	31	5	{"winner": 3, "goalDiff": 2}	2026-06-20 05:05:41.244431+00
2531	51	MATCH	31	0	{}	2026-06-20 05:05:41.246372+00
2532	12	MATCH	31	0	{}	2026-06-20 05:05:41.248411+00
2533	46	MATCH	31	0	{}	2026-06-20 05:05:41.251634+00
3838	15	MATCH	45	0	{}	2026-06-23 22:01:20.23749+00
3839	46	MATCH	45	0	{}	2026-06-23 22:01:20.240305+00
3840	54	MATCH	45	0	{}	2026-06-23 22:01:20.242394+00
3841	29	MATCH	45	0	{}	2026-06-23 22:01:20.244644+00
3175	59	MATCH	37	0	{}	2026-06-22 00:05:12.829127+00
3176	44	MATCH	37	0	{}	2026-06-22 00:05:12.830801+00
3177	13	MATCH	37	0	{}	2026-06-22 00:05:12.832116+00
3178	29	MATCH	37	0	{}	2026-06-22 00:05:12.833732+00
3179	35	MATCH	37	0	{}	2026-06-22 00:05:12.835059+00
3180	41	MATCH	37	0	{}	2026-06-22 00:05:12.836423+00
3181	50	MATCH	37	0	{}	2026-06-22 00:05:12.837892+00
3182	58	MATCH	37	5	{"draw": 3, "goalDiff": 2}	2026-06-22 00:05:12.839395+00
3183	56	MATCH	37	5	{"draw": 3, "goalDiff": 2}	2026-06-22 00:05:12.841046+00
3184	42	MATCH	37	0	{}	2026-06-22 00:05:12.842433+00
3185	48	MATCH	37	0	{}	2026-06-22 00:05:12.844108+00
3186	12	MATCH	37	0	{}	2026-06-22 00:05:12.845584+00
3187	46	MATCH	37	0	{}	2026-06-22 00:05:12.847141+00
3842	23	MATCH	45	0	{}	2026-06-23 22:01:20.246828+00
3843	9	MATCH	45	0	{}	2026-06-23 22:01:20.249278+00
3844	38	MATCH	45	0	{}	2026-06-23 22:01:20.251454+00
3845	40	MATCH	45	0	{}	2026-06-23 22:01:20.26817+00
3846	68	MATCH	45	0	{}	2026-06-23 22:01:20.332087+00
3847	47	MATCH	45	0	{}	2026-06-23 22:01:20.334658+00
3848	55	MATCH	45	0	{}	2026-06-23 22:01:20.33837+00
3849	28	MATCH	45	0	{}	2026-06-23 22:01:20.431781+00
3242	15	MATCH	40	0	{}	2026-06-22 03:01:11.429202+00
3243	25	MATCH	40	0	{}	2026-06-22 03:01:11.43135+00
3244	54	MATCH	40	0	{}	2026-06-22 03:01:11.433056+00
3245	14	MATCH	40	0	{}	2026-06-22 03:01:11.434646+00
3246	36	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.436157+00
3247	34	MATCH	40	5	{"winner": 3, "goalDiff": 2}	2026-06-22 03:01:11.43777+00
3248	10	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.439251+00
3249	55	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.440815+00
3250	38	MATCH	40	0	{}	2026-06-22 03:01:11.442199+00
3251	45	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.443562+00
3252	30	MATCH	40	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 03:01:11.445051+00
3253	33	MATCH	40	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 03:01:11.446651+00
3254	24	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.448848+00
3255	27	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.450533+00
3256	11	MATCH	40	0	{}	2026-06-22 03:01:11.452059+00
3850	37	MATCH	45	0	{}	2026-06-23 22:01:20.438088+00
2958	15	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.866232+00
2959	25	MATCH	38	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-21 18:01:27.930728+00
2960	54	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.932655+00
2961	14	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.93445+00
2962	36	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.93695+00
2963	46	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.938814+00
2964	34	MATCH	38	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-21 18:01:27.940655+00
2965	10	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.942202+00
2966	55	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.943773+00
2967	38	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.945398+00
2968	45	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.947058+00
2969	50	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.948632+00
2970	33	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.950144+00
2971	30	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.951733+00
2972	24	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.953628+00
2973	27	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.955068+00
2974	47	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.95838+00
2975	11	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.959998+00
2976	9	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.961641+00
2977	68	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.963135+00
2978	23	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.965213+00
2979	43	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.970825+00
2980	40	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.974587+00
2981	37	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.979331+00
2982	26	MATCH	38	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-21 18:01:27.98351+00
2983	32	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.985024+00
2984	28	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.986439+00
2985	16	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.988877+00
2986	42	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:27.990944+00
2987	31	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.029239+00
2988	41	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.031259+00
2989	12	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.032818+00
2990	48	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.034736+00
2991	66	MATCH	38	0	{}	2026-06-21 18:01:28.036223+00
2992	51	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.039076+00
2993	59	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.040527+00
2994	44	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.042044+00
2995	58	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.043471+00
2996	56	MATCH	38	3	{"winner": 3}	2026-06-21 18:01:28.045395+00
6172	40	MATCH	67	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:13.154787+00
6173	41	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.157758+00
6174	42	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.160232+00
4833	9	MATCH	56	5	{"winner": 3, "goalDiff": 2}	2026-06-25 21:58:38.716504+00
4834	10	MATCH	56	0	{}	2026-06-25 21:58:38.719496+00
4835	11	MATCH	56	0	{}	2026-06-25 21:58:38.721555+00
4836	12	MATCH	56	0	{}	2026-06-25 21:58:38.723638+00
4837	13	MATCH	56	0	{}	2026-06-25 21:58:38.726088+00
4838	14	MATCH	56	0	{}	2026-06-25 21:58:38.728369+00
4839	15	MATCH	56	0	{}	2026-06-25 21:58:38.730653+00
4840	23	MATCH	56	0	{}	2026-06-25 21:58:38.733062+00
4841	24	MATCH	56	0	{}	2026-06-25 21:58:38.735555+00
4842	25	MATCH	56	0	{}	2026-06-25 21:58:38.73767+00
4843	26	MATCH	56	0	{}	2026-06-25 21:58:38.739929+00
4844	27	MATCH	56	0	{}	2026-06-25 21:58:38.742424+00
4845	28	MATCH	56	0	{}	2026-06-25 21:58:38.744516+00
4846	29	MATCH	56	0	{}	2026-06-25 21:58:38.746887+00
4847	30	MATCH	56	0	{}	2026-06-25 21:58:38.749014+00
4848	31	MATCH	56	0	{}	2026-06-25 21:58:38.751727+00
4849	32	MATCH	56	0	{}	2026-06-25 21:58:38.754089+00
4850	33	MATCH	56	0	{}	2026-06-25 21:58:38.75615+00
4851	34	MATCH	56	0	{}	2026-06-25 21:58:38.758358+00
4852	35	MATCH	56	0	{}	2026-06-25 21:58:38.760335+00
4853	36	MATCH	56	0	{}	2026-06-25 21:58:38.762674+00
4854	37	MATCH	56	0	{}	2026-06-25 21:58:38.765088+00
4855	38	MATCH	56	0	{}	2026-06-25 21:58:38.767117+00
4856	40	MATCH	56	0	{}	2026-06-25 21:58:38.769529+00
4857	41	MATCH	56	0	{}	2026-06-25 21:58:38.771674+00
4858	42	MATCH	56	0	{}	2026-06-25 21:58:38.77412+00
4859	43	MATCH	56	0	{}	2026-06-25 21:58:38.776323+00
4860	44	MATCH	56	0	{}	2026-06-25 21:58:38.778517+00
4861	45	MATCH	56	0	{}	2026-06-25 21:58:38.780761+00
4862	46	MATCH	56	0	{}	2026-06-25 21:58:38.782827+00
4863	48	MATCH	56	0	{}	2026-06-25 21:58:38.784966+00
4864	50	MATCH	56	5	{"winner": 3, "goalDiff": 2}	2026-06-25 21:58:38.787185+00
4865	51	MATCH	56	0	{}	2026-06-25 21:58:38.78928+00
4866	54	MATCH	56	0	{}	2026-06-25 21:58:38.79132+00
4867	55	MATCH	56	0	{}	2026-06-25 21:58:38.793592+00
4868	56	MATCH	56	0	{}	2026-06-25 21:58:38.796036+00
4869	58	MATCH	56	0	{}	2026-06-25 21:58:38.798101+00
4870	66	MATCH	56	0	{}	2026-06-25 21:58:38.800342+00
4871	68	MATCH	56	0	{}	2026-06-25 21:58:38.802642+00
2620	42	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.236385+00
2621	12	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.238205+00
2622	45	MATCH	35	3	{"winner": 3}	2026-06-20 18:56:55.239735+00
4942	9	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.127485+00
6175	43	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.162446+00
4391	25	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.630794+00
4392	10	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.633335+00
4393	37	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.635424+00
4394	24	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.637571+00
4395	27	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.639587+00
4396	55	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.641773+00
4397	33	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.643772+00
4398	32	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.645856+00
4399	29	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.647962+00
4400	47	MATCH	49	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:15.649916+00
4401	15	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.65194+00
4402	38	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.653928+00
4403	45	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.655951+00
4404	46	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.657904+00
4405	54	MATCH	49	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 00:02:15.659972+00
4406	40	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.663574+00
4407	28	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.666492+00
4408	43	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.66848+00
4409	68	MATCH	49	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 00:02:15.670664+00
4410	14	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.672843+00
4411	26	MATCH	49	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 00:02:15.674887+00
4412	51	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.677136+00
4413	9	MATCH	49	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 00:02:15.67918+00
4414	44	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.681249+00
4415	13	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.683216+00
4416	36	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.685791+00
4417	35	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.688101+00
4418	56	MATCH	49	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:15.690745+00
4419	30	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.692919+00
4420	58	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.695186+00
4421	11	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.700147+00
4422	59	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.702129+00
4423	41	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.704436+00
6176	44	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.167472+00
4943	10	MATCH	55	5	{"winner": 3, "goalDiff": 2}	2026-06-25 22:00:01.129982+00
4424	34	MATCH	49	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 00:02:15.729734+00
4425	48	MATCH	49	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:15.732219+00
4426	23	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.734304+00
4427	50	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.736394+00
4428	66	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.738501+00
4429	31	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.740467+00
4944	11	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.132198+00
8063	11	MATCH	74	0	{}	2026-06-29 23:29:57.244938+00
3146	15	MATCH	37	0	{}	2026-06-22 00:05:12.780739+00
3147	25	MATCH	37	0	{}	2026-06-22 00:05:12.782778+00
3148	54	MATCH	37	0	{}	2026-06-22 00:05:12.784728+00
3149	14	MATCH	37	0	{}	2026-06-22 00:05:12.786367+00
3150	36	MATCH	37	0	{}	2026-06-22 00:05:12.787829+00
3151	34	MATCH	37	0	{}	2026-06-22 00:05:12.790905+00
3152	55	MATCH	37	0	{}	2026-06-22 00:05:12.792316+00
3153	10	MATCH	37	0	{}	2026-06-22 00:05:12.793805+00
3154	45	MATCH	37	0	{}	2026-06-22 00:05:12.795299+00
3155	33	MATCH	37	0	{}	2026-06-22 00:05:12.797476+00
3156	30	MATCH	37	0	{}	2026-06-22 00:05:12.798905+00
3157	24	MATCH	37	0	{}	2026-06-22 00:05:12.800428+00
3158	47	MATCH	37	0	{}	2026-06-22 00:05:12.801851+00
3159	27	MATCH	37	0	{}	2026-06-22 00:05:12.803277+00
3160	11	MATCH	37	0	{}	2026-06-22 00:05:12.804714+00
3161	68	MATCH	37	0	{}	2026-06-22 00:05:12.806123+00
3162	23	MATCH	37	0	{}	2026-06-22 00:05:12.807739+00
3163	9	MATCH	37	0	{}	2026-06-22 00:05:12.809134+00
3164	43	MATCH	37	5	{"draw": 3, "goalDiff": 2}	2026-06-22 00:05:12.810492+00
3165	38	MATCH	37	0	{}	2026-06-22 00:05:12.812306+00
3166	40	MATCH	37	0	{}	2026-06-22 00:05:12.813683+00
3167	37	MATCH	37	0	{}	2026-06-22 00:05:12.815104+00
3168	26	MATCH	37	0	{}	2026-06-22 00:05:12.816455+00
3169	32	MATCH	37	0	{}	2026-06-22 00:05:12.817864+00
3170	28	MATCH	37	0	{}	2026-06-22 00:05:12.81922+00
3171	16	MATCH	37	0	{}	2026-06-22 00:05:12.820738+00
3172	31	MATCH	37	0	{}	2026-06-22 00:05:12.823986+00
3173	66	MATCH	37	0	{}	2026-06-22 00:05:12.825816+00
3174	51	MATCH	37	0	{}	2026-06-22 00:05:12.827662+00
3618	15	MATCH	44	3	{"winner": 3}	2026-06-23 05:02:56.413073+00
3619	54	MATCH	44	0	{}	2026-06-23 05:02:56.419454+00
3620	38	MATCH	44	0	{}	2026-06-23 05:02:56.425777+00
3621	47	MATCH	44	0	{}	2026-06-23 05:02:56.427427+00
3622	40	MATCH	44	0	{}	2026-06-23 05:02:56.431047+00
3623	46	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.433459+00
3624	55	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.436731+00
3625	43	MATCH	44	0	{}	2026-06-23 05:02:56.438117+00
3626	10	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.440927+00
3627	32	MATCH	44	0	{}	2026-06-23 05:02:56.442909+00
3628	28	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.446438+00
3629	14	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.448052+00
3630	27	MATCH	44	0	{}	2026-06-23 05:02:56.452392+00
3631	51	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.453923+00
3632	45	MATCH	44	0	{}	2026-06-23 05:02:56.457184+00
3633	25	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.45864+00
3634	50	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.463615+00
3635	9	MATCH	44	0	{}	2026-06-23 05:02:56.466046+00
3636	36	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.470092+00
3637	26	MATCH	44	5	{"winner": 3, "goalDiff": 2}	2026-06-23 05:02:56.471679+00
3638	24	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.473846+00
3639	34	MATCH	44	5	{"winner": 3, "goalDiff": 2}	2026-06-23 05:02:56.47668+00
3640	11	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.47987+00
3641	37	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.48429+00
3642	48	MATCH	44	0	{}	2026-06-23 05:02:56.485861+00
3643	44	MATCH	44	0	{}	2026-06-23 05:02:56.490311+00
3644	31	MATCH	44	3	{"winner": 3}	2026-06-23 05:02:56.495724+00
3645	35	MATCH	44	5	{"winner": 3, "goalDiff": 2}	2026-06-23 05:02:56.49729+00
3646	33	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.498779+00
3647	30	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.500193+00
3648	58	MATCH	44	0	{}	2026-06-23 05:02:56.502265+00
3649	56	MATCH	44	5	{"winner": 3, "goalDiff": 2}	2026-06-23 05:02:56.509097+00
3650	66	MATCH	44	0	{}	2026-06-23 05:02:56.510724+00
3651	23	MATCH	44	5	{"winner": 3, "goalDiff": 2}	2026-06-23 05:02:56.512589+00
3652	16	MATCH	44	0	{}	2026-06-23 05:02:56.515794+00
3653	41	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.520412+00
3654	12	MATCH	44	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-23 05:02:56.523215+00
3655	13	MATCH	44	3	{"winner": 3}	2026-06-23 05:02:56.525629+00
3656	68	MATCH	44	0	{}	2026-06-23 05:02:56.528466+00
3657	42	MATCH	44	3	{"winner": 3}	2026-06-23 05:02:56.532569+00
4430	12	MATCH	49	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 00:02:15.742527+00
4431	42	MATCH	49	3	{"winner": 3}	2026-06-25 00:02:15.744788+00
6177	45	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.169498+00
6178	46	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.171952+00
6179	47	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.174502+00
6180	48	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.177517+00
6181	50	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.180043+00
8064	54	MATCH	74	0	{}	2026-06-29 23:29:57.967788+00
3851	10	MATCH	45	0	{}	2026-06-23 22:01:20.44134+00
3852	13	MATCH	45	0	{}	2026-06-23 22:01:20.444358+00
3853	34	MATCH	45	0	{}	2026-06-23 22:01:20.447741+00
3854	45	MATCH	45	0	{}	2026-06-23 22:01:20.450373+00
3855	36	MATCH	45	0	{}	2026-06-23 22:01:20.452979+00
3856	41	MATCH	45	0	{}	2026-06-23 22:01:20.45528+00
3857	44	MATCH	45	0	{}	2026-06-23 22:01:20.459731+00
3858	14	MATCH	45	0	{}	2026-06-23 22:01:20.461877+00
3859	43	MATCH	45	0	{}	2026-06-23 22:01:20.46431+00
3860	35	MATCH	45	0	{}	2026-06-23 22:01:20.467722+00
3861	66	MATCH	45	0	{}	2026-06-23 22:01:20.529872+00
3862	48	MATCH	45	0	{}	2026-06-23 22:01:20.533868+00
3863	25	MATCH	45	0	{}	2026-06-23 22:01:20.537241+00
3864	58	MATCH	45	0	{}	2026-06-23 22:01:20.632888+00
3865	12	MATCH	45	0	{}	2026-06-23 22:01:20.635291+00
3866	59	MATCH	45	0	{}	2026-06-23 22:01:20.638813+00
3867	51	MATCH	45	0	{}	2026-06-23 22:01:20.64249+00
3868	31	MATCH	45	0	{}	2026-06-23 22:01:20.646401+00
3869	42	MATCH	45	0	{}	2026-06-23 22:01:20.649461+00
3870	50	MATCH	45	0	{}	2026-06-23 22:01:20.65175+00
3871	27	MATCH	45	0	{}	2026-06-23 22:01:20.65499+00
3872	33	MATCH	45	0	{}	2026-06-23 22:01:20.657329+00
3873	30	MATCH	45	0	{}	2026-06-23 22:01:20.660502+00
3874	56	MATCH	45	0	{}	2026-06-23 22:01:20.663049+00
3875	11	MATCH	45	0	{}	2026-06-23 22:01:20.665465+00
3876	24	MATCH	45	0	{}	2026-06-23 22:01:20.66886+00
3877	26	MATCH	45	0	{}	2026-06-23 22:01:20.67167+00
3878	32	MATCH	45	0	{}	2026-06-23 22:01:20.673806+00
3257	68	MATCH	40	0	{}	2026-06-22 03:01:11.453715+00
3258	9	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.45728+00
3259	43	MATCH	40	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 03:01:11.459336+00
3260	47	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.463361+00
3261	23	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.46488+00
3262	40	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.466419+00
3263	26	MATCH	40	0	{}	2026-06-22 03:01:11.46788+00
3264	28	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.469437+00
3265	16	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.47092+00
3266	31	MATCH	40	0	{}	2026-06-22 03:01:11.472458+00
3267	66	MATCH	40	0	{}	2026-06-22 03:01:11.473898+00
3268	51	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.475413+00
3269	13	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.476998+00
3270	29	MATCH	40	0	{}	2026-06-22 03:01:11.479555+00
3271	35	MATCH	40	0	{}	2026-06-22 03:01:11.481118+00
3272	41	MATCH	40	5	{"winner": 3, "goalDiff": 2}	2026-06-22 03:01:11.483035+00
3273	37	MATCH	40	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 03:01:11.487061+00
3274	58	MATCH	40	0	{}	2026-06-22 03:01:11.488458+00
3275	56	MATCH	40	0	{}	2026-06-22 03:01:11.528765+00
3276	42	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.530692+00
3277	50	MATCH	40	0	{}	2026-06-22 03:01:11.532253+00
3278	48	MATCH	40	5	{"winner": 3, "goalDiff": 2}	2026-06-22 03:01:11.53394+00
3279	32	MATCH	40	0	{}	2026-06-22 03:01:11.535586+00
3280	12	MATCH	40	3	{"winner": 3}	2026-06-22 03:01:11.537122+00
6182	51	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.181956+00
6183	54	MATCH	67	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:13.18438+00
6184	55	MATCH	67	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:13.186488+00
6185	56	MATCH	67	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:13.188721+00
6186	58	MATCH	67	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:13.191115+00
6187	59	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.193212+00
6188	68	MATCH	67	3	{"winner": 3}	2026-06-27 23:00:13.195264+00
8972	34	MATCH	78	5	{"winner": 3, "goalDiff": 2}	2026-06-30 18:59:17.443101+00
8973	13	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:18.645816+00
8974	54	MATCH	78	5	{"winner": 3, "goalDiff": 2}	2026-06-30 18:59:19.682191+00
8975	37	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:20.434185+00
8977	38	MATCH	78	0	{}	2026-06-30 18:59:21.015848+00
8980	11	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:21.644383+00
8981	10	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:22.308899+00
8984	14	MATCH	78	0	{}	2026-06-30 18:59:22.931248+00
8986	27	MATCH	78	0	{}	2026-06-30 18:59:23.494629+00
7194	35	BONUSES	0	0	{}	2026-07-03 10:11:45.40044+00
8065	10	MATCH	74	0	{}	2026-06-29 23:29:58.492169+00
8066	38	MATCH	74	0	{}	2026-06-29 23:29:58.77673+00
8067	1	MATCH	74	0	{}	2026-06-29 23:29:59.057739+00
8068	27	MATCH	74	0	{}	2026-06-29 23:29:59.318878+00
8069	14	MATCH	74	0	{}	2026-06-29 23:29:59.602729+00
8070	12	MATCH	74	0	{}	2026-06-29 23:29:59.902916+00
8071	15	MATCH	74	0	{}	2026-06-29 23:30:00.248722+00
8072	9	MATCH	74	0	{}	2026-06-29 23:30:00.580385+00
8073	56	MATCH	74	0	{}	2026-06-29 23:30:00.829868+00
8074	29	MATCH	74	0	{}	2026-06-29 23:30:01.096722+00
8075	41	MATCH	74	0	{}	2026-06-29 23:30:01.420179+00
8076	35	MATCH	74	0	{}	2026-06-29 23:30:01.691841+00
8077	30	MATCH	74	0	{}	2026-06-29 23:30:01.956722+00
8078	48	MATCH	74	0	{}	2026-06-29 23:30:02.226722+00
8079	31	MATCH	74	0	{}	2026-06-29 23:30:02.505787+00
8080	24	MATCH	74	0	{}	2026-06-29 23:30:02.785728+00
8081	25	MATCH	74	0	{}	2026-06-29 23:30:03.077347+00
8082	40	MATCH	74	0	{}	2026-06-29 23:30:03.336723+00
8083	42	MATCH	74	0	{}	2026-06-29 23:30:03.590721+00
8084	26	MATCH	74	0	{}	2026-06-29 23:30:03.84972+00
8085	44	MATCH	74	0	{}	2026-06-29 23:30:04.086922+00
8086	51	MATCH	74	0	{}	2026-06-29 23:30:04.378325+00
8087	58	MATCH	74	0	{}	2026-06-29 23:30:04.777816+00
8088	23	MATCH	74	0	{}	2026-06-29 23:30:05.079468+00
8089	37	MATCH	74	0	{}	2026-06-29 23:30:05.436632+00
8090	50	MATCH	74	0	{}	2026-06-29 23:30:05.759114+00
8091	59	MATCH	74	0	{}	2026-06-29 23:30:06.52585+00
8092	33	MATCH	74	0	{}	2026-06-29 23:30:06.93596+00
8093	46	MATCH	74	0	{}	2026-06-29 23:30:07.259023+00
8094	32	MATCH	74	0	{}	2026-06-29 23:30:07.555908+00
8095	55	MATCH	74	0	{}	2026-06-29 23:30:07.873831+00
8096	36	MATCH	74	0	{}	2026-06-29 23:30:08.232807+00
8097	45	MATCH	74	0	{}	2026-06-29 23:30:08.549009+00
8098	28	MATCH	74	0	{}	2026-06-29 23:30:08.850319+00
8099	47	MATCH	74	0	{}	2026-06-29 23:30:09.23426+00
8100	66	MATCH	74	0	{}	2026-06-29 23:30:09.532809+00
8101	43	MATCH	74	0	{}	2026-06-29 23:30:09.890471+00
8102	68	MATCH	74	0	{}	2026-06-29 23:30:10.229787+00
8517	34	MATCH	75	5	{"draw": 3, "goalDiff": 2}	2026-06-30 03:54:12.147549+00
8988	15	MATCH	78	0	{}	2026-06-30 18:59:24.170493+00
8992	9	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:25.391326+00
5637	23	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.19678+00
5638	59	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.199582+00
5639	29	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.204712+00
5640	42	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.206768+00
3949	15	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.647876+00
3335	15	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.486925+00
3336	54	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.492202+00
3337	38	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.49774+00
3338	47	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.502344+00
3339	40	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.504137+00
3340	46	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.510136+00
3341	37	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.511684+00
3342	55	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.513261+00
3343	43	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.521576+00
3344	34	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.523213+00
3345	68	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.524624+00
3346	51	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.527048+00
3347	29	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.534727+00
3348	32	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.550661+00
3349	28	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.552631+00
3350	14	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.56172+00
3351	27	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.563756+00
3352	11	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.565218+00
3353	48	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.567739+00
3354	59	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.572473+00
3355	45	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.574621+00
3356	25	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.579726+00
3357	41	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.582104+00
3358	50	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.583533+00
3359	42	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.584987+00
3360	58	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.58705+00
3361	36	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.591065+00
3362	44	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.596729+00
3363	9	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.600208+00
3364	24	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.60156+00
3365	26	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.606052+00
3366	10	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.607461+00
3367	31	MATCH	43	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-22 19:02:52.608853+00
3368	35	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.612894+00
3369	56	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.61427+00
3370	33	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.615904+00
3371	30	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.620987+00
3372	13	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.62243+00
3373	23	MATCH	43	5	{"winner": 3, "goalDiff": 2}	2026-06-22 19:02:52.623792+00
3374	12	MATCH	43	3	{"winner": 3}	2026-06-22 19:02:52.625139+00
3950	46	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.650721+00
3951	37	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.652931+00
3952	54	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.655101+00
3953	29	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.657328+00
3954	23	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.65946+00
3955	68	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.661705+00
3956	40	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.663752+00
3957	10	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.666013+00
3958	55	MATCH	46	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 00:55:04.668169+00
3959	28	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.670239+00
3960	47	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.67233+00
3961	9	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.674436+00
3962	13	MATCH	46	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 00:55:04.676457+00
3963	34	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.679477+00
3964	45	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.681494+00
3965	36	MATCH	46	0	{}	2026-06-24 00:55:04.683633+00
3966	41	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.685724+00
5270	15	MATCH	60	0	{}	2026-06-26 03:59:47.988984+00
5271	54	MATCH	60	0	{}	2026-06-26 03:59:48.02985+00
5272	34	MATCH	60	0	{}	2026-06-26 03:59:48.03292+00
5273	56	MATCH	60	5	{"draw": 3, "goalDiff": 2}	2026-06-26 03:59:48.036396+00
5274	40	MATCH	60	0	{}	2026-06-26 03:59:48.038495+00
5275	38	MATCH	60	0	{}	2026-06-26 03:59:48.04059+00
5276	23	MATCH	60	0	{}	2026-06-26 03:59:48.04267+00
5277	13	MATCH	60	0	{}	2026-06-26 03:59:48.044856+00
5278	45	MATCH	60	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 03:59:48.046883+00
5279	10	MATCH	60	0	{}	2026-06-26 03:59:48.048941+00
5280	9	MATCH	60	0	{}	2026-06-26 03:59:48.051117+00
5281	55	MATCH	60	5	{"draw": 3, "goalDiff": 2}	2026-06-26 03:59:48.053088+00
5282	58	MATCH	60	0	{}	2026-06-26 03:59:48.055045+00
5283	11	MATCH	60	0	{}	2026-06-26 03:59:48.056972+00
5284	14	MATCH	60	0	{}	2026-06-26 03:59:48.058874+00
5285	32	MATCH	60	0	{}	2026-06-26 03:59:48.060856+00
5286	41	MATCH	60	5	{"draw": 3, "goalDiff": 2}	2026-06-26 03:59:48.064033+00
5287	37	MATCH	60	0	{}	2026-06-26 03:59:48.06664+00
5288	43	MATCH	60	5	{"draw": 3, "goalDiff": 2}	2026-06-26 03:59:48.068672+00
5289	48	MATCH	60	0	{}	2026-06-26 03:59:48.070633+00
5290	24	MATCH	60	0	{}	2026-06-26 03:59:48.072638+00
5291	46	MATCH	60	0	{}	2026-06-26 03:59:48.074534+00
5292	44	MATCH	60	0	{}	2026-06-26 03:59:48.076595+00
5293	35	MATCH	60	0	{}	2026-06-26 03:59:48.078862+00
5294	33	MATCH	60	0	{}	2026-06-26 03:59:48.081507+00
5295	36	MATCH	60	0	{}	2026-06-26 03:59:48.083548+00
5296	30	MATCH	60	0	{}	2026-06-26 03:59:48.086741+00
5297	66	MATCH	60	0	{}	2026-06-26 03:59:48.088928+00
5298	27	MATCH	60	0	{}	2026-06-26 03:59:48.090956+00
5299	28	MATCH	60	0	{}	2026-06-26 03:59:48.093143+00
5300	26	MATCH	60	5	{"draw": 3, "goalDiff": 2}	2026-06-26 03:59:48.095212+00
5301	31	MATCH	60	5	{"draw": 3, "goalDiff": 2}	2026-06-26 03:59:48.097724+00
5302	47	MATCH	60	0	{}	2026-06-26 03:59:48.099749+00
5303	59	MATCH	60	5	{"draw": 3, "goalDiff": 2}	2026-06-26 03:59:48.102623+00
5304	29	MATCH	60	0	{}	2026-06-26 03:59:48.10469+00
5305	68	MATCH	60	0	{}	2026-06-26 03:59:48.107041+00
5306	42	MATCH	60	0	{}	2026-06-26 03:59:48.109723+00
5307	51	MATCH	60	0	{}	2026-06-26 03:59:48.112587+00
5308	12	MATCH	60	0	{}	2026-06-26 03:59:48.132399+00
5309	50	MATCH	60	0	{}	2026-06-26 03:59:48.134677+00
3728	54	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.044068+00
3729	37	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.069003+00
3730	23	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.077714+00
3731	15	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.129751+00
3732	9	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.153809+00
3733	38	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.160736+00
3734	40	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.22977+00
3735	68	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.238727+00
3736	47	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.24334+00
3737	55	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.252724+00
3738	46	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.258608+00
3739	10	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.273111+00
3740	28	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.275611+00
3741	13	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.283046+00
3742	29	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.33478+00
3743	34	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.337295+00
3744	45	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.340759+00
3745	36	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.343737+00
3746	44	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.347726+00
3747	43	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.351775+00
3748	35	MATCH	47	3	{"winner": 3}	2026-06-23 19:00:06.353882+00
8994	29	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:26.441347+00
8996	35	MATCH	78	5	{"winner": 3, "goalDiff": 2}	2026-06-30 18:59:27.453132+00
8998	12	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:28.549056+00
9000	48	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:29.336986+00
9002	30	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:29.956305+00
9004	24	MATCH	78	0	{}	2026-06-30 18:59:30.563029+00
9006	25	MATCH	78	0	{}	2026-06-30 18:59:31.958205+00
9008	40	MATCH	78	0	{}	2026-06-30 18:59:32.634064+00
9010	42	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:33.22933+00
11702	34	MATCH	82	0	{}	2026-07-01 22:49:45.561454+00
11703	13	MATCH	82	0	{}	2026-07-01 22:49:45.805758+00
11704	54	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:46.450502+00
11705	38	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:46.700545+00
11706	11	MATCH	82	3	{"winner": 3}	2026-07-01 22:49:47.037021+00
11707	10	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:47.350116+00
11708	27	MATCH	82	0	{}	2026-07-01 22:49:47.628515+00
11709	14	MATCH	82	0	{}	2026-07-01 22:49:47.89791+00
11710	15	MATCH	82	0	{}	2026-07-01 22:49:48.18598+00
11711	56	MATCH	82	0	{}	2026-07-01 22:49:48.476263+00
11712	9	MATCH	82	0	{}	2026-07-01 22:49:48.765545+00
4502	25	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.277656+00
4503	15	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.284973+00
4504	10	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.287841+00
4505	37	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.292722+00
4506	24	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.295047+00
4507	27	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.297942+00
4508	55	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.301296+00
4509	33	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.309171+00
4510	32	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.311323+00
4511	29	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.313425+00
4512	47	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.320224+00
4513	38	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.325753+00
4514	45	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.331735+00
4515	36	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.333775+00
4516	46	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.336327+00
4517	54	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.338385+00
4518	40	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.340416+00
4519	28	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.342427+00
4520	43	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.344563+00
4521	14	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.350722+00
4522	26	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.352895+00
4523	51	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.358049+00
4524	68	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.360109+00
4525	9	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.362008+00
4526	44	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.363962+00
4527	13	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.36596+00
4528	35	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.367902+00
4529	30	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.374725+00
4530	58	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.382248+00
4531	11	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.388119+00
4532	59	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.391898+00
4533	34	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.397676+00
4534	48	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.399877+00
4535	23	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.402527+00
4536	50	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.407803+00
4537	66	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.418148+00
4538	31	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.420507+00
4539	41	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.425006+00
4540	56	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.428684+00
4541	12	MATCH	50	5	{"winner": 3, "goalDiff": 2}	2026-06-25 00:02:46.431258+00
4542	42	MATCH	50	3	{"winner": 3}	2026-06-25 00:02:46.437928+00
8518	13	MATCH	75	0	{}	2026-06-30 03:54:12.388799+00
8519	11	MATCH	75	0	{}	2026-06-30 03:54:12.681436+00
8520	54	MATCH	75	0	{}	2026-06-30 03:54:12.989445+00
8521	10	MATCH	75	0	{}	2026-06-30 03:54:13.284215+00
8522	37	MATCH	75	0	{}	2026-06-30 03:54:13.58719+00
8523	38	MATCH	75	0	{}	2026-06-30 03:54:13.884526+00
8524	14	MATCH	75	0	{}	2026-06-30 03:54:14.233106+00
8525	27	MATCH	75	5	{"draw": 3, "goalDiff": 2}	2026-06-30 03:54:14.475844+00
8526	15	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:14.742662+00
8527	9	MATCH	75	0	{}	2026-06-30 03:54:14.994293+00
8528	56	MATCH	75	0	{}	2026-06-30 03:54:15.276407+00
8529	29	MATCH	75	0	{}	2026-06-30 03:54:15.560178+00
8530	35	MATCH	75	0	{}	2026-06-30 03:54:15.805838+00
8531	12	MATCH	75	5	{"draw": 3, "goalDiff": 2}	2026-06-30 03:54:16.446836+00
8532	30	MATCH	75	0	{}	2026-06-30 03:54:16.737765+00
8533	48	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:17.034343+00
8534	24	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:17.273463+00
8535	25	MATCH	75	0	{}	2026-06-30 03:54:17.54378+00
8536	31	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:17.776674+00
8537	40	MATCH	75	0	{}	2026-06-30 03:54:18.04643+00
8538	42	MATCH	75	0	{}	2026-06-30 03:54:18.453743+00
8539	26	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:18.79058+00
8540	44	MATCH	75	0	{}	2026-06-30 03:54:19.129326+00
8541	36	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:19.40763+00
8542	51	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:19.732317+00
8543	58	MATCH	75	5	{"draw": 3, "goalDiff": 2}	2026-06-30 03:54:20.00713+00
8544	41	MATCH	75	0	{}	2026-06-30 03:54:20.332846+00
8545	50	MATCH	75	0	{}	2026-06-30 03:54:20.643081+00
8546	59	MATCH	75	0	{}	2026-06-30 03:54:20.974979+00
6260	9	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.747508+00
6261	10	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.75306+00
6262	11	MATCH	68	3	{"winner": 3}	2026-06-27 23:00:23.755174+00
6263	13	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.757251+00
6264	14	MATCH	68	3	{"winner": 3}	2026-06-27 23:00:23.760147+00
6265	15	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.762131+00
6266	23	MATCH	68	0	{}	2026-06-27 23:00:23.764576+00
6267	24	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.767666+00
6268	25	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.769869+00
6269	27	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.771836+00
6270	28	MATCH	68	0	{}	2026-06-27 23:00:23.774274+00
6271	29	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.776899+00
6272	30	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.778936+00
6273	31	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.781544+00
6274	32	MATCH	68	3	{"winner": 3}	2026-06-27 23:00:23.78374+00
6275	33	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.786576+00
6276	34	MATCH	68	3	{"winner": 3}	2026-06-27 23:00:23.788977+00
6277	35	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.791061+00
6278	36	MATCH	68	0	{}	2026-06-27 23:00:23.793094+00
6279	37	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.795265+00
6280	38	MATCH	68	3	{"winner": 3}	2026-06-27 23:00:23.797622+00
6281	40	MATCH	68	0	{}	2026-06-27 23:00:23.800729+00
6282	41	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.802967+00
6283	43	MATCH	68	0	{}	2026-06-27 23:00:23.804936+00
6284	44	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.807017+00
6285	45	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.810064+00
6286	46	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.830957+00
6287	47	MATCH	68	0	{}	2026-06-27 23:00:23.834736+00
6288	48	MATCH	68	0	{}	2026-06-27 23:00:23.837977+00
6289	50	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.842659+00
6290	51	MATCH	68	0	{}	2026-06-27 23:00:23.846591+00
6291	54	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.848998+00
6292	55	MATCH	68	5	{"winner": 3, "goalDiff": 2}	2026-06-27 23:00:23.853734+00
6293	56	MATCH	68	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 23:00:23.857447+00
6294	58	MATCH	68	0	{}	2026-06-27 23:00:23.861737+00
6295	68	MATCH	68	0	{}	2026-06-27 23:00:23.866403+00
8990	56	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:24.755362+00
4613	25	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.323488+00
4614	15	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.327353+00
4615	10	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.329395+00
4616	24	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.331466+00
4617	27	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.333685+00
4618	55	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.335822+00
4619	33	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.33826+00
4620	32	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.341176+00
4621	47	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.343693+00
4622	38	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.345948+00
4623	45	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.348519+00
4624	37	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.351087+00
4625	46	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.353293+00
4626	54	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.355802+00
4627	36	MATCH	53	0	{}	2026-06-25 02:58:31.358735+00
4628	40	MATCH	53	0	{}	2026-06-25 02:58:31.360796+00
4629	28	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.363253+00
4630	43	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.36675+00
4631	14	MATCH	53	0	{}	2026-06-25 02:58:31.36943+00
4632	26	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.371613+00
4633	51	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.373676+00
4634	9	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.375745+00
4635	44	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.37835+00
4636	68	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.380318+00
4637	35	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.382679+00
4638	56	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.385049+00
4639	30	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.387154+00
4640	58	MATCH	53	0	{}	2026-06-25 02:58:31.389166+00
4641	34	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.391182+00
4642	48	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.393231+00
4643	11	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.39526+00
4644	50	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.39736+00
4645	66	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.399466+00
4646	59	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.401589+00
4647	31	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.403735+00
4648	23	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.40584+00
4649	12	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.407951+00
4650	42	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.429524+00
4651	13	MATCH	53	3	{"winner": 3}	2026-06-25 02:58:31.433097+00
4652	41	MATCH	53	0	{}	2026-06-25 02:58:31.435183+00
5380	15	MATCH	59	0	{}	2026-06-26 04:02:25.530722+00
5381	54	MATCH	59	0	{}	2026-06-26 04:02:25.536568+00
5382	25	MATCH	59	0	{}	2026-06-26 04:02:25.539739+00
5383	34	MATCH	59	0	{}	2026-06-26 04:02:25.542684+00
5384	56	MATCH	59	0	{}	2026-06-26 04:02:25.545654+00
5385	40	MATCH	59	0	{}	2026-06-26 04:02:25.550327+00
5386	38	MATCH	59	0	{}	2026-06-26 04:02:25.552445+00
5387	23	MATCH	59	0	{}	2026-06-26 04:02:25.555805+00
5388	13	MATCH	59	0	{}	2026-06-26 04:02:25.559829+00
5389	45	MATCH	59	0	{}	2026-06-26 04:02:25.561785+00
5390	10	MATCH	59	0	{}	2026-06-26 04:02:25.564334+00
5391	9	MATCH	59	0	{}	2026-06-26 04:02:25.567281+00
5392	55	MATCH	59	0	{}	2026-06-26 04:02:25.570662+00
5393	11	MATCH	59	0	{}	2026-06-26 04:02:25.573025+00
5394	14	MATCH	59	0	{}	2026-06-26 04:02:25.575005+00
5395	32	MATCH	59	0	{}	2026-06-26 04:02:25.577853+00
5396	29	MATCH	59	0	{}	2026-06-26 04:02:25.579836+00
5397	41	MATCH	59	0	{}	2026-06-26 04:02:25.583644+00
5398	43	MATCH	59	0	{}	2026-06-26 04:02:25.585633+00
5399	27	MATCH	59	0	{}	2026-06-26 04:02:25.587721+00
5400	24	MATCH	59	0	{}	2026-06-26 04:02:25.589772+00
5401	46	MATCH	59	0	{}	2026-06-26 04:02:25.592883+00
5402	44	MATCH	59	0	{}	2026-06-26 04:02:25.59482+00
5403	35	MATCH	59	0	{}	2026-06-26 04:02:25.596802+00
5404	33	MATCH	59	0	{}	2026-06-26 04:02:25.598771+00
5405	36	MATCH	59	0	{}	2026-06-26 04:02:25.602138+00
5406	30	MATCH	59	0	{}	2026-06-26 04:02:25.605138+00
5407	58	MATCH	59	5	{"winner": 3, "goalDiff": 2}	2026-06-26 04:02:25.607269+00
5408	48	MATCH	59	0	{}	2026-06-26 04:02:25.609288+00
5409	37	MATCH	59	0	{}	2026-06-26 04:02:25.611328+00
5410	68	MATCH	59	0	{}	2026-06-26 04:02:25.613382+00
5411	66	MATCH	59	0	{}	2026-06-26 04:02:25.615443+00
5412	28	MATCH	59	0	{}	2026-06-26 04:02:25.617437+00
5413	26	MATCH	59	0	{}	2026-06-26 04:02:25.619371+00
5414	31	MATCH	59	0	{}	2026-06-26 04:02:25.621356+00
5415	50	MATCH	59	0	{}	2026-06-26 04:02:25.624751+00
5416	51	MATCH	59	0	{}	2026-06-26 04:02:25.62855+00
5417	59	MATCH	59	0	{}	2026-06-26 04:02:25.630629+00
5418	42	MATCH	59	0	{}	2026-06-26 04:02:25.632783+00
5419	47	MATCH	59	0	{}	2026-06-26 04:02:25.634828+00
5420	12	MATCH	59	5	{"winner": 3, "goalDiff": 2}	2026-06-26 04:02:25.636865+00
9012	26	MATCH	78	0	{}	2026-06-30 18:59:33.756535+00
9014	36	MATCH	78	0	{}	2026-06-30 18:59:34.344586+00
3967	44	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.687679+00
3968	14	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.690154+00
3969	43	MATCH	46	0	{}	2026-06-24 00:55:04.693354+00
3970	35	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.695504+00
3971	66	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.729743+00
3972	48	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.73195+00
3973	25	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.734095+00
3974	58	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.736202+00
3975	59	MATCH	46	0	{}	2026-06-24 00:55:04.738282+00
3976	51	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.740251+00
3977	31	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.742389+00
3978	27	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.744618+00
3979	33	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.746774+00
3980	30	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.7489+00
3981	56	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.751234+00
3982	11	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.753329+00
3983	50	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.75547+00
3984	26	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.757495+00
3985	24	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.759619+00
3986	32	MATCH	46	5	{"winner": 3, "goalDiff": 2}	2026-06-24 00:55:04.761961+00
3987	38	MATCH	46	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-24 00:55:04.76434+00
3988	12	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.766788+00
3989	42	MATCH	46	3	{"winner": 3}	2026-06-24 00:55:04.770741+00
7606	34	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:00.450451+00
7607	13	MATCH	76	5	{"winner": 3, "goalDiff": 2}	2026-06-29 19:03:00.747442+00
7608	11	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:01.131652+00
7609	54	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:01.450217+00
7610	10	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:01.748635+00
7611	37	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:02.150238+00
7612	38	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:02.451768+00
7613	14	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:02.764947+00
7614	27	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:03.059026+00
7615	36	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:03.372445+00
7616	15	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:03.74937+00
7617	9	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:04.075299+00
8547	46	MATCH	75	0	{}	2026-06-30 03:54:21.293143+00
5711	54	MATCH	65	0	{}	2026-06-27 02:02:37.806722+00
5712	25	MATCH	65	0	{}	2026-06-27 02:02:37.810785+00
5713	15	MATCH	65	0	{}	2026-06-27 02:02:37.81577+00
5714	9	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.819743+00
5715	38	MATCH	65	0	{}	2026-06-27 02:02:37.821882+00
5716	47	MATCH	65	0	{}	2026-06-27 02:02:37.82468+00
5717	46	MATCH	65	0	{}	2026-06-27 02:02:37.827743+00
5718	27	MATCH	65	0	{}	2026-06-27 02:02:37.830687+00
5719	58	MATCH	65	0	{}	2026-06-27 02:02:37.833633+00
5720	56	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.836688+00
5721	10	MATCH	65	0	{}	2026-06-27 02:02:37.840042+00
5722	33	MATCH	65	0	{}	2026-06-27 02:02:37.842039+00
5723	55	MATCH	65	0	{}	2026-06-27 02:02:37.845649+00
5724	48	MATCH	65	0	{}	2026-06-27 02:02:37.848429+00
5725	40	MATCH	65	0	{}	2026-06-27 02:02:37.851732+00
5726	28	MATCH	65	0	{}	2026-06-27 02:02:37.853716+00
5727	29	MATCH	65	0	{}	2026-06-27 02:02:37.856492+00
5728	66	MATCH	65	0	{}	2026-06-27 02:02:37.858601+00
5729	37	MATCH	65	0	{}	2026-06-27 02:02:37.861663+00
5730	32	MATCH	65	0	{}	2026-06-27 02:02:37.864644+00
5731	45	MATCH	65	0	{}	2026-06-27 02:02:37.867733+00
5732	11	MATCH	65	0	{}	2026-06-27 02:02:37.869969+00
5733	36	MATCH	65	0	{}	2026-06-27 02:02:37.872668+00
5734	14	MATCH	65	0	{}	2026-06-27 02:02:37.875885+00
5735	43	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.87867+00
5736	51	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.881748+00
5737	35	MATCH	65	0	{}	2026-06-27 02:02:37.883815+00
5738	50	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.886723+00
5739	34	MATCH	65	0	{}	2026-06-27 02:02:37.89773+00
5740	31	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.902744+00
5741	12	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.909736+00
5742	26	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.915814+00
5743	13	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.917971+00
5744	30	MATCH	65	0	{}	2026-06-27 02:02:37.922008+00
5745	23	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.926833+00
5746	59	MATCH	65	5	{"draw": 3, "goalDiff": 2}	2026-06-27 02:02:37.930547+00
5747	42	MATCH	65	0	{}	2026-06-27 02:02:37.937735+00
5748	24	MATCH	65	0	{}	2026-06-27 02:02:37.940023+00
5749	41	MATCH	65	0	{}	2026-06-27 02:02:37.946755+00
5750	68	MATCH	65	0	{}	2026-06-27 02:02:37.949766+00
9018	58	MATCH	78	0	{}	2026-06-30 18:59:35.551523+00
9020	41	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:37.239523+00
9022	23	MATCH	78	0	{}	2026-06-30 18:59:38.55504+00
9024	50	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:39.449021+00
9026	59	MATCH	78	0	{}	2026-06-30 18:59:40.142222+00
9028	46	MATCH	78	5	{"winner": 3, "goalDiff": 2}	2026-06-30 18:59:40.65769+00
9030	33	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:41.337804+00
9032	32	MATCH	78	0	{}	2026-06-30 18:59:42.160816+00
9034	55	MATCH	78	0	{}	2026-06-30 18:59:42.889209+00
4060	15	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.213059+00
4061	46	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.215691+00
4062	68	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.218382+00
4063	54	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.221187+00
4064	29	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.223898+00
4065	40	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.228882+00
4066	23	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.230979+00
4067	9	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.234539+00
4068	38	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.236739+00
4069	55	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.238934+00
4070	28	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.241125+00
4071	37	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.243322+00
4072	47	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.245444+00
4073	10	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.247522+00
4074	13	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.24962+00
4075	34	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.251755+00
4076	45	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.253913+00
4077	36	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.256502+00
4078	41	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.258487+00
4079	44	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.260486+00
4080	14	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.262676+00
4081	35	MATCH	48	0	{}	2026-06-24 03:57:55.264782+00
4082	66	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.26688+00
4083	11	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.268928+00
4084	25	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.271142+00
4085	59	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.273199+00
4086	51	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.275328+00
4087	31	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.277407+00
4088	50	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.280653+00
4089	27	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.282766+00
4090	33	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.284843+00
4091	30	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.286817+00
4092	43	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.288843+00
4093	58	MATCH	48	0	{}	2026-06-24 03:57:55.290887+00
6764	24	QUALIFIERS	0	84	{"correctCount": 21, "qualifiedTeams": 84}	2026-06-28 03:59:30.989683+00
6765	38	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:30.99175+00
6766	41	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.993759+00
6767	13	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:30.995817+00
6768	1	QUALIFIERS	0	68	{"correctCount": 17, "qualifiedTeams": 68}	2026-06-28 03:59:31.029847+00
6769	30	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:31.032114+00
6770	59	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:31.034128+00
6771	58	QUALIFIERS	0	68	{"correctCount": 17, "qualifiedTeams": 68}	2026-06-28 03:59:31.036154+00
6772	43	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:31.038323+00
6773	9	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:31.041681+00
6774	48	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:31.043769+00
6775	31	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:31.045759+00
6776	36	QUALIFIERS	0	64	{"correctCount": 16, "qualifiedTeams": 64}	2026-06-28 03:59:31.047893+00
6777	16	QUALIFIERS	0	64	{"correctCount": 16, "qualifiedTeams": 64}	2026-06-28 03:59:31.049799+00
6778	47	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:31.051779+00
6779	34	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:31.053763+00
6780	28	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:31.055764+00
6781	66	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:31.05778+00
6782	25	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:31.059795+00
4094	48	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.292911+00
4095	24	MATCH	48	5	{"winner": 3, "goalDiff": 2}	2026-06-24 03:57:55.294979+00
4096	32	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.297033+00
4097	12	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.29924+00
4098	42	MATCH	48	3	{"winner": 3}	2026-06-24 03:57:55.301233+00
4099	56	MATCH	48	0	{}	2026-06-24 03:57:55.303228+00
4723	25	MATCH	54	0	{}	2026-06-25 02:58:49.428741+00
4724	15	MATCH	54	0	{}	2026-06-25 02:58:49.431659+00
4725	10	MATCH	54	0	{}	2026-06-25 02:58:49.433966+00
4726	37	MATCH	54	0	{}	2026-06-25 02:58:49.437725+00
4727	24	MATCH	54	0	{}	2026-06-25 02:58:49.439971+00
4728	27	MATCH	54	0	{}	2026-06-25 02:58:49.442117+00
4729	55	MATCH	54	0	{}	2026-06-25 02:58:49.444624+00
4730	33	MATCH	54	0	{}	2026-06-25 02:58:49.446818+00
4731	32	MATCH	54	0	{}	2026-06-25 02:58:49.449082+00
4732	47	MATCH	54	0	{}	2026-06-25 02:58:49.451117+00
4733	38	MATCH	54	0	{}	2026-06-25 02:58:49.453238+00
4734	45	MATCH	54	0	{}	2026-06-25 02:58:49.455269+00
4735	46	MATCH	54	0	{}	2026-06-25 02:58:49.457206+00
4736	54	MATCH	54	0	{}	2026-06-25 02:58:49.459252+00
4737	36	MATCH	54	0	{}	2026-06-25 02:58:49.461253+00
4738	40	MATCH	54	0	{}	2026-06-25 02:58:49.463266+00
4739	28	MATCH	54	0	{}	2026-06-25 02:58:49.465306+00
4740	43	MATCH	54	0	{}	2026-06-25 02:58:49.467349+00
4741	14	MATCH	54	0	{}	2026-06-25 02:58:49.469367+00
4742	26	MATCH	54	0	{}	2026-06-25 02:58:49.471371+00
4743	51	MATCH	54	0	{}	2026-06-25 02:58:49.474321+00
4744	9	MATCH	54	0	{}	2026-06-25 02:58:49.476305+00
4745	44	MATCH	54	0	{}	2026-06-25 02:58:49.478288+00
4746	68	MATCH	54	0	{}	2026-06-25 02:58:49.480238+00
4747	56	MATCH	54	0	{}	2026-06-25 02:58:49.482233+00
4748	30	MATCH	54	0	{}	2026-06-25 02:58:49.484208+00
4749	58	MATCH	54	5	{"winner": 3, "goalDiff": 2}	2026-06-25 02:58:49.486219+00
4750	11	MATCH	54	0	{}	2026-06-25 02:58:49.489268+00
4751	59	MATCH	54	0	{}	2026-06-25 02:58:49.491361+00
4752	34	MATCH	54	0	{}	2026-06-25 02:58:49.493417+00
4753	48	MATCH	54	0	{}	2026-06-25 02:58:49.495444+00
4754	50	MATCH	54	0	{}	2026-06-25 02:58:49.497567+00
4755	66	MATCH	54	0	{}	2026-06-25 02:58:49.499618+00
4756	35	MATCH	54	0	{}	2026-06-25 02:58:49.501661+00
4757	31	MATCH	54	0	{}	2026-06-25 02:58:49.529631+00
4758	23	MATCH	54	0	{}	2026-06-25 02:58:49.531959+00
4759	12	MATCH	54	0	{}	2026-06-25 02:58:49.534021+00
4760	42	MATCH	54	0	{}	2026-06-25 02:58:49.536085+00
4761	13	MATCH	54	0	{}	2026-06-25 02:58:49.53811+00
4762	41	MATCH	54	0	{}	2026-06-25 02:58:49.540086+00
5491	54	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.641789+00
5492	25	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.646021+00
5493	15	MATCH	61	0	{}	2026-06-26 21:01:47.648255+00
5494	9	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.651336+00
5495	38	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.653587+00
5496	47	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.655802+00
5497	46	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.658046+00
5498	58	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.660149+00
5499	27	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.662304+00
5500	56	MATCH	61	0	{}	2026-06-26 21:01:47.664396+00
5501	33	MATCH	61	0	{}	2026-06-26 21:01:47.666399+00
5502	55	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.67065+00
5503	40	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.673901+00
5504	48	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.676019+00
5505	28	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.678222+00
5506	37	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.680285+00
5507	32	MATCH	61	0	{}	2026-06-26 21:01:47.682424+00
5508	13	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.684586+00
5509	45	MATCH	61	0	{}	2026-06-26 21:01:47.686682+00
5510	11	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.688837+00
5511	66	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.690936+00
5512	14	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.693104+00
5513	43	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.695358+00
5514	36	MATCH	61	0	{}	2026-06-26 21:01:47.697479+00
5515	10	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.699517+00
5516	24	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.701524+00
5517	51	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.703615+00
5518	35	MATCH	61	0	{}	2026-06-26 21:01:47.706637+00
5519	50	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.708759+00
5520	34	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.71077+00
5521	31	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.712746+00
5522	68	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.71475+00
5523	12	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.716717+00
5524	41	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.72979+00
5525	26	MATCH	61	0	{}	2026-06-26 21:01:47.73186+00
5526	30	MATCH	61	0	{}	2026-06-26 21:01:47.734741+00
5527	23	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.737+00
5528	59	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.739131+00
5529	29	MATCH	61	3	{"winner": 3}	2026-06-26 21:01:47.741288+00
5530	42	MATCH	61	0	{}	2026-06-26 21:01:47.743352+00
6367	9	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.111842+00
6368	10	MATCH	71	0	{}	2026-06-28 01:28:38.114423+00
6369	11	MATCH	71	0	{}	2026-06-28 01:28:38.116692+00
6370	12	MATCH	71	0	{}	2026-06-28 01:28:38.118933+00
6371	13	MATCH	71	0	{}	2026-06-28 01:28:38.122436+00
6372	14	MATCH	71	0	{}	2026-06-28 01:28:38.125802+00
6373	15	MATCH	71	0	{}	2026-06-28 01:28:38.128436+00
6374	23	MATCH	71	0	{}	2026-06-28 01:28:38.130655+00
6375	24	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.133246+00
6376	25	MATCH	71	0	{}	2026-06-28 01:28:38.135323+00
6377	26	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.137583+00
6378	27	MATCH	71	0	{}	2026-06-28 01:28:38.140722+00
6379	28	MATCH	71	0	{}	2026-06-28 01:28:38.142839+00
6380	29	MATCH	71	0	{}	2026-06-28 01:28:38.145647+00
6381	30	MATCH	71	0	{}	2026-06-28 01:28:38.147922+00
4170	25	MATCH	52	0	{}	2026-06-24 20:59:30.64078+00
4171	10	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.643482+00
4172	37	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.648018+00
4173	27	MATCH	52	0	{}	2026-06-24 20:59:30.652131+00
4174	55	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.655898+00
4175	32	MATCH	52	0	{}	2026-06-24 20:59:30.658584+00
4176	47	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.660781+00
4177	33	MATCH	52	0	{}	2026-06-24 20:59:30.662735+00
4178	29	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.664925+00
4179	15	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.666979+00
4180	38	MATCH	52	0	{}	2026-06-24 20:59:30.66919+00
4181	45	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.671299+00
4182	36	MATCH	52	0	{}	2026-06-24 20:59:30.673376+00
4183	24	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.675452+00
4184	51	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.677596+00
4185	40	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.679759+00
4186	54	MATCH	52	0	{}	2026-06-24 20:59:30.683535+00
4187	28	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.685581+00
4188	43	MATCH	52	0	{}	2026-06-24 20:59:30.687716+00
4189	14	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.689692+00
4190	26	MATCH	52	0	{}	2026-06-24 20:59:30.693563+00
4191	41	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.695926+00
4192	68	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.698483+00
4193	9	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.700848+00
4194	44	MATCH	52	0	{}	2026-06-24 20:59:30.729047+00
4195	13	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.732306+00
4196	35	MATCH	52	0	{}	2026-06-24 20:59:30.735722+00
4197	56	MATCH	52	0	{}	2026-06-24 20:59:30.739309+00
4198	48	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.741487+00
4199	46	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.743656+00
4200	30	MATCH	52	0	{}	2026-06-24 20:59:30.745777+00
4201	58	MATCH	52	0	{}	2026-06-24 20:59:30.747865+00
4202	11	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.749996+00
4203	59	MATCH	52	5	{"winner": 3, "goalDiff": 2}	2026-06-24 20:59:30.752299+00
4204	31	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.754324+00
4205	34	MATCH	52	0	{}	2026-06-24 20:59:30.756354+00
4206	12	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.758369+00
4207	42	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.760443+00
4208	23	MATCH	52	0	{}	2026-06-24 20:59:30.762472+00
4209	50	MATCH	52	3	{"winner": 3}	2026-06-24 20:59:30.764583+00
4210	66	MATCH	52	0	{}	2026-06-24 20:59:30.766652+00
6382	31	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.150666+00
6383	32	MATCH	71	0	{}	2026-06-28 01:28:38.152849+00
6384	33	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.155767+00
6385	34	MATCH	71	0	{}	2026-06-28 01:28:38.15794+00
6386	35	MATCH	71	0	{}	2026-06-28 01:28:38.160365+00
6387	36	MATCH	71	0	{}	2026-06-28 01:28:38.162662+00
6388	37	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.165806+00
6389	38	MATCH	71	0	{}	2026-06-28 01:28:38.168121+00
6390	40	MATCH	71	0	{}	2026-06-28 01:28:38.170454+00
6391	41	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.172736+00
6392	42	MATCH	71	0	{}	2026-06-28 01:28:38.175079+00
6393	43	MATCH	71	0	{}	2026-06-28 01:28:38.177479+00
6394	44	MATCH	71	0	{}	2026-06-28 01:28:38.179879+00
6395	45	MATCH	71	0	{}	2026-06-28 01:28:38.182278+00
6396	46	MATCH	71	0	{}	2026-06-28 01:28:38.184664+00
6397	47	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.187059+00
6398	48	MATCH	71	0	{}	2026-06-28 01:28:38.189868+00
6399	50	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.192211+00
6400	51	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.19485+00
6401	54	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.19769+00
6402	55	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.20009+00
6403	56	MATCH	71	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 01:28:38.20291+00
6404	58	MATCH	71	0	{}	2026-06-28 01:28:38.230324+00
6405	59	MATCH	71	0	{}	2026-06-28 01:28:38.233751+00
6406	66	MATCH	71	0	{}	2026-06-28 01:28:38.236946+00
6407	68	MATCH	71	5	{"draw": 3, "goalDiff": 2}	2026-06-28 01:28:38.239376+00
9016	51	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:34.963126+00
9036	47	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:43.452143+00
4945	12	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.134389+00
4946	13	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.136681+00
4947	14	MATCH	55	5	{"winner": 3, "goalDiff": 2}	2026-06-25 22:00:01.138839+00
4948	15	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.141088+00
4949	23	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.143085+00
4950	24	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.14528+00
4951	25	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.147503+00
4952	26	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.149911+00
4953	27	MATCH	55	5	{"winner": 3, "goalDiff": 2}	2026-06-25 22:00:01.152108+00
4954	28	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.154195+00
4955	29	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.156248+00
4956	30	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.158738+00
4957	31	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.162052+00
4958	32	MATCH	55	0	{}	2026-06-25 22:00:01.164296+00
4959	33	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.16631+00
4960	34	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.168556+00
4961	35	MATCH	55	0	{}	2026-06-25 22:00:01.171601+00
4962	36	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.17411+00
4963	37	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.176672+00
4964	38	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.179861+00
4965	40	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.18216+00
4966	41	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.184427+00
4967	42	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.187294+00
4968	43	MATCH	55	0	{}	2026-06-25 22:00:01.193903+00
4969	44	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.196069+00
4970	45	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.198512+00
4971	46	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.20125+00
4972	48	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.203307+00
4973	50	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.209724+00
4974	51	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.212093+00
4975	54	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.215159+00
4976	55	MATCH	55	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-25 22:00:01.218114+00
4977	56	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.220577+00
4978	58	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.222914+00
4979	66	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.225171+00
4980	68	MATCH	55	3	{"winner": 3}	2026-06-25 22:00:01.23051+00
2674	27	INVICTO	0	15	{"invicto": 15, "maxStreak": 11}	2026-07-03 10:11:49.696454+00
5821	54	MATCH	66	0	{}	2026-06-27 02:02:56.667477+00
2675	31	INVICTO	0	15	{"invicto": 15, "maxStreak": 11}	2026-07-03 10:11:49.70745+00
9038	45	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:44.033192+00
9040	44	MATCH	78	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 18:59:44.655457+00
9042	28	MATCH	78	5	{"winner": 3, "goalDiff": 2}	2026-06-30 18:59:46.455728+00
9044	31	MATCH	78	5	{"winner": 3, "goalDiff": 2}	2026-06-30 18:59:47.135832+00
9046	66	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:47.728644+00
9048	43	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:48.536869+00
9050	68	MATCH	78	3	{"winner": 3}	2026-06-30 18:59:49.231388+00
5822	25	MATCH	66	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 02:02:56.669949+00
5051	9	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.001239+00
5052	10	MATCH	58	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:56:50.004747+00
5053	11	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.007964+00
5054	13	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.012728+00
5055	14	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.014979+00
5056	15	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.01695+00
5057	23	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.01978+00
5058	24	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.022206+00
5059	25	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.025683+00
5060	26	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.02778+00
5061	27	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.030472+00
5062	28	MATCH	58	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:56:50.037078+00
5063	29	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.039214+00
5064	30	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.041367+00
5823	15	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.672363+00
5824	9	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.674449+00
5825	38	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.67676+00
5826	47	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.683751+00
5827	46	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.686733+00
5828	56	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.688778+00
5829	58	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.690861+00
5830	27	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.692914+00
5831	10	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.695304+00
5832	33	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.699999+00
5833	55	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.702083+00
5834	40	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.704333+00
5835	48	MATCH	66	0	{}	2026-06-27 02:02:56.706626+00
5836	31	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.709737+00
5837	28	MATCH	66	0	{}	2026-06-27 02:02:56.711895+00
5838	29	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.713991+00
5839	66	MATCH	66	0	{}	2026-06-27 02:02:56.717739+00
5840	37	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.720243+00
5841	32	MATCH	66	0	{}	2026-06-27 02:02:56.723089+00
5842	45	MATCH	66	0	{}	2026-06-27 02:02:56.725112+00
5843	11	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.727153+00
5844	36	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.729954+00
5845	14	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.732258+00
5846	43	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.735341+00
5847	24	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.740553+00
5848	35	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.743177+00
5849	34	MATCH	66	0	{}	2026-06-27 02:02:56.745173+00
5850	50	MATCH	66	0	{}	2026-06-27 02:02:56.749961+00
5851	51	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.752289+00
5852	12	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.754635+00
5853	26	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.756959+00
5854	41	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.759228+00
5065	31	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.044777+00
5066	32	MATCH	58	0	{}	2026-06-26 00:56:50.048768+00
5067	33	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.051556+00
5068	34	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.057726+00
5069	35	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.062379+00
5070	36	MATCH	58	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:56:50.068002+00
5071	37	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.071722+00
5072	38	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.081794+00
5073	40	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.09106+00
5074	41	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.103724+00
5075	42	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.107721+00
5076	43	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.120067+00
5077	44	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.127725+00
5078	45	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.136969+00
5079	46	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.146731+00
5080	47	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.153838+00
5081	48	MATCH	58	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:56:50.15648+00
5082	50	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.15987+00
5083	51	MATCH	58	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-26 00:56:50.16361+00
5084	54	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.174735+00
5085	55	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.176841+00
5086	56	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.183943+00
5087	58	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.190292+00
5088	59	MATCH	58	3	{"winner": 3}	2026-06-26 00:56:50.203726+00
5089	68	MATCH	58	5	{"winner": 3, "goalDiff": 2}	2026-06-26 00:56:50.208246+00
6702	9	MATCH	69	0	{}	2026-06-28 03:59:30.58812+00
6703	10	MATCH	69	0	{}	2026-06-28 03:59:30.590675+00
6704	11	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.592779+00
6705	12	MATCH	69	0	{}	2026-06-28 03:59:30.594794+00
6706	13	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.596777+00
6707	14	MATCH	69	0	{}	2026-06-28 03:59:30.598767+00
6708	15	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.601177+00
6709	23	MATCH	69	0	{}	2026-06-28 03:59:30.603144+00
6710	24	MATCH	69	0	{}	2026-06-28 03:59:30.605106+00
6711	25	MATCH	69	0	{}	2026-06-28 03:59:30.60711+00
6712	26	MATCH	69	0	{}	2026-06-28 03:59:30.609062+00
6713	27	MATCH	69	0	{}	2026-06-28 03:59:30.611148+00
6714	28	MATCH	69	0	{}	2026-06-28 03:59:30.613142+00
6715	29	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.615119+00
6716	30	MATCH	69	0	{}	2026-06-28 03:59:30.618233+00
6717	31	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.620219+00
6718	32	MATCH	69	0	{}	2026-06-28 03:59:30.649828+00
6719	33	MATCH	69	0	{}	2026-06-28 03:59:30.65216+00
6720	34	MATCH	69	0	{}	2026-06-28 03:59:30.654363+00
6721	35	MATCH	69	0	{}	2026-06-28 03:59:30.656461+00
6722	36	MATCH	69	0	{}	2026-06-28 03:59:30.658516+00
6723	37	MATCH	69	0	{}	2026-06-28 03:59:30.660515+00
6724	38	MATCH	69	0	{}	2026-06-28 03:59:30.66255+00
6725	40	MATCH	69	0	{}	2026-06-28 03:59:30.664596+00
6726	43	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.666716+00
6727	44	MATCH	69	0	{}	2026-06-28 03:59:30.668751+00
6728	45	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.670777+00
6729	46	MATCH	69	0	{}	2026-06-28 03:59:30.672832+00
6730	47	MATCH	69	0	{}	2026-06-28 03:59:30.675337+00
6731	48	MATCH	69	0	{}	2026-06-28 03:59:30.677402+00
6732	50	MATCH	69	0	{}	2026-06-28 03:59:30.679425+00
6733	51	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.681481+00
6734	54	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.683498+00
6735	55	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.68551+00
6736	56	MATCH	69	0	{}	2026-06-28 03:59:30.687663+00
6737	58	MATCH	69	0	{}	2026-06-28 03:59:30.68976+00
6738	59	MATCH	69	0	{}	2026-06-28 03:59:30.691815+00
6739	66	MATCH	69	5	{"draw": 3, "goalDiff": 2}	2026-06-28 03:59:30.693807+00
6740	68	MATCH	69	0	{}	2026-06-28 03:59:30.695906+00
6741	55	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.930875+00
6742	68	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.933961+00
6743	15	QUALIFIERS	0	64	{"correctCount": 16, "qualifiedTeams": 64}	2026-06-28 03:59:30.938031+00
6744	27	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:30.941047+00
6745	10	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.943449+00
6746	18	QUALIFIERS	0	56	{"correctCount": 14, "qualifiedTeams": 56}	2026-06-28 03:59:30.946043+00
6747	32	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:30.94985+00
6748	44	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.952051+00
6749	14	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.954239+00
6479	9	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:52.958127+00
6480	10	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:52.963907+00
6481	11	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:52.971813+00
6482	12	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:52.97415+00
6483	13	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:52.982929+00
6484	14	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:52.98656+00
6485	15	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:52.993818+00
6486	23	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.012734+00
6487	24	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.020941+00
6488	25	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.023748+00
6489	26	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.039143+00
6490	27	MATCH	72	0	{}	2026-06-28 01:28:53.048741+00
6491	28	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.052723+00
6492	29	MATCH	72	0	{}	2026-06-28 01:28:53.058014+00
6493	30	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.067505+00
6494	31	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.08578+00
6495	32	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.088741+00
6496	33	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.093743+00
6497	34	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.100736+00
6498	35	MATCH	72	0	{}	2026-06-28 01:28:53.103122+00
6499	36	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.110144+00
6500	37	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.120816+00
6501	38	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.123309+00
6502	40	MATCH	72	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 01:28:53.128942+00
6503	41	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.131838+00
6504	42	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.134405+00
6505	43	MATCH	72	0	{}	2026-06-28 01:28:53.138202+00
6506	44	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.140445+00
6507	45	MATCH	72	0	{}	2026-06-28 01:28:53.14272+00
6508	46	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.144799+00
6509	47	MATCH	72	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 01:28:53.146971+00
5601	54	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.082693+00
5602	25	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.089727+00
5603	15	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.093742+00
5604	9	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.097735+00
5605	38	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.100737+00
5606	56	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.102812+00
5607	58	MATCH	62	0	{}	2026-06-26 21:02:03.10565+00
5608	46	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.108411+00
5609	27	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.112131+00
5610	47	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.117687+00
5611	10	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.120144+00
5612	33	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.123911+00
5613	55	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.128723+00
5614	40	MATCH	62	0	{}	2026-06-26 21:02:03.130862+00
5615	48	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.133071+00
5616	28	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.135765+00
5617	66	MATCH	62	0	{}	2026-06-26 21:02:03.138038+00
5618	37	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.144786+00
5619	32	MATCH	62	0	{}	2026-06-26 21:02:03.146761+00
5620	45	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.148845+00
5621	11	MATCH	62	0	{}	2026-06-26 21:02:03.150843+00
5622	13	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.152913+00
5623	14	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.154933+00
5624	43	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.156984+00
5625	36	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.160037+00
5626	24	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.16471+00
5627	51	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.168914+00
5628	35	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.173791+00
5629	34	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.175831+00
5630	50	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.177834+00
5631	31	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.179854+00
5632	68	MATCH	62	0	{}	2026-06-26 21:02:03.183664+00
5633	12	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.185678+00
5634	26	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.188734+00
5635	41	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.190681+00
5636	30	MATCH	62	3	{"winner": 3}	2026-06-26 21:02:03.192667+00
6510	48	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.14922+00
6511	50	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.151687+00
6512	51	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.155621+00
6513	54	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.157756+00
6514	55	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.160089+00
6515	56	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.162968+00
6516	58	MATCH	72	5	{"winner": 3, "goalDiff": 2}	2026-06-28 01:28:53.165084+00
6517	66	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.167392+00
6518	68	MATCH	72	3	{"winner": 3}	2026-06-28 01:28:53.170746+00
7204	17	BONUSES	0	0	{}	2026-07-03 10:11:45.421212+00
7205	29	BONUSES	0	0	{}	2026-07-03 10:11:45.423386+00
7206	58	BONUSES	0	0	{}	2026-07-03 10:11:45.42546+00
7207	45	BONUSES	0	0	{}	2026-07-03 10:11:45.42765+00
7209	50	BONUSES	0	0	{}	2026-07-03 10:11:45.432008+00
7210	44	BONUSES	0	0	{}	2026-07-03 10:11:45.434256+00
7211	9	BONUSES	0	0	{}	2026-07-03 10:11:45.436363+00
7212	26	BONUSES	0	0	{}	2026-07-03 10:11:45.438445+00
7213	28	BONUSES	0	0	{}	2026-07-03 10:11:45.440403+00
7214	39	BONUSES	0	0	{}	2026-07-03 10:11:45.442419+00
7215	14	BONUSES	0	0	{}	2026-07-03 10:11:45.444442+00
7216	34	BONUSES	0	0	{}	2026-07-03 10:11:45.44654+00
7217	15	BONUSES	0	0	{}	2026-07-03 10:11:45.448556+00
7218	37	BONUSES	0	0	{}	2026-07-03 10:11:45.450594+00
7219	13	BONUSES	0	0	{}	2026-07-03 10:11:45.452664+00
7220	47	BONUSES	0	0	{}	2026-07-03 10:11:45.454638+00
7221	56	BONUSES	0	0	{}	2026-07-03 10:11:45.456608+00
7222	12	BONUSES	0	0	{}	2026-07-03 10:11:45.458694+00
7223	40	BONUSES	0	0	{}	2026-07-03 10:11:45.460731+00
7224	41	BONUSES	0	0	{}	2026-07-03 10:11:45.462747+00
7225	42	BONUSES	0	0	{}	2026-07-03 10:11:45.464754+00
7226	36	BONUSES	0	0	{}	2026-07-03 10:11:45.466742+00
7227	24	BONUSES	0	0	{}	2026-07-03 10:11:45.468788+00
7193	54	BONUSES	0	0	{}	2026-07-03 10:11:45.398177+00
7195	10	BONUSES	0	0	{}	2026-07-03 10:11:45.402618+00
7196	27	BONUSES	0	0	{}	2026-07-03 10:11:45.404707+00
7197	55	BONUSES	0	0	{}	2026-07-03 10:11:45.40677+00
7198	16	BONUSES	0	0	{}	2026-07-03 10:11:45.408716+00
7199	43	BONUSES	0	0	{}	2026-07-03 10:11:45.41076+00
7200	25	BONUSES	0	0	{}	2026-07-03 10:11:45.41276+00
7201	11	BONUSES	0	0	{}	2026-07-03 10:11:45.414738+00
7202	59	BONUSES	0	0	{}	2026-07-03 10:11:45.416753+00
7203	68	BONUSES	0	0	{}	2026-07-03 10:11:45.41909+00
7153	28	MATCH	73	0	{}	2026-06-28 20:58:07.046113+00
7154	54	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:07.862941+00
7155	11	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:08.372031+00
7156	10	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:08.692621+00
7157	46	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:09.047471+00
7158	37	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:09.331044+00
7159	38	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:09.621734+00
7160	1	MATCH	73	0	{}	2026-06-28 20:58:09.931655+00
7161	27	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:10.364457+00
7162	56	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:10.631729+00
7163	44	MATCH	73	0	{}	2026-06-28 20:58:10.905868+00
7164	34	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:11.1999+00
7165	14	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:11.568724+00
7166	36	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:11.891947+00
7167	12	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:12.22273+00
7168	15	MATCH	73	0	{}	2026-06-28 20:58:12.539724+00
7169	9	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:12.950618+00
7170	55	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:13.257871+00
7171	41	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:13.55842+00
7172	29	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:13.920728+00
7173	13	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:14.208781+00
7174	35	MATCH	73	0	{}	2026-06-28 20:58:14.496731+00
7175	58	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:14.77072+00
7176	68	MATCH	73	0	{}	2026-06-28 20:58:15.071506+00
7177	48	MATCH	73	0	{}	2026-06-28 20:58:15.393387+00
7178	30	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:15.686505+00
7179	31	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:16.26667+00
7180	24	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:16.646048+00
7181	25	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:16.998724+00
7182	40	MATCH	73	0	{}	2026-06-28 20:58:17.357229+00
7183	42	MATCH	73	3	{"winner": 3}	2026-06-28 20:58:17.964812+00
7184	26	MATCH	73	0	{}	2026-06-28 20:58:18.490719+00
7185	47	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:18.815692+00
7186	50	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:19.126418+00
7187	23	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:19.440298+00
7188	66	MATCH	73	5	{"winner": 3, "goalDiff": 2}	2026-06-28 20:58:19.753771+00
7189	51	MATCH	73	0	{}	2026-06-28 20:58:20.069771+00
7190	32	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:20.547889+00
7191	33	MATCH	73	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 20:58:21.938324+00
5855	30	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.761658+00
5856	13	MATCH	66	0	{}	2026-06-27 02:02:56.764101+00
5857	59	MATCH	66	0	{}	2026-06-27 02:02:56.766103+00
5858	42	MATCH	66	3	{"winner": 3}	2026-06-27 02:02:56.768142+00
5859	68	MATCH	66	0	{}	2026-06-27 02:02:56.770526+00
5860	23	MATCH	66	5	{"winner": 3, "goalDiff": 2}	2026-06-27 02:02:56.772565+00
6041	54	MATCH	63	0	{}	2026-06-27 05:04:44.165828+00
6042	25	MATCH	63	0	{}	2026-06-27 05:04:44.168335+00
6043	15	MATCH	63	0	{}	2026-06-27 05:04:44.17052+00
6044	9	MATCH	63	0	{}	2026-06-27 05:04:44.17268+00
6045	38	MATCH	63	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 05:04:44.174876+00
6046	47	MATCH	63	0	{}	2026-06-27 05:04:44.177023+00
6047	46	MATCH	63	0	{}	2026-06-27 05:04:44.179184+00
6048	56	MATCH	63	0	{}	2026-06-27 05:04:44.181196+00
6049	58	MATCH	63	0	{}	2026-06-27 05:04:44.183366+00
6050	27	MATCH	63	0	{}	2026-06-27 05:04:44.185371+00
6051	10	MATCH	63	0	{}	2026-06-27 05:04:44.187462+00
6052	55	MATCH	63	0	{}	2026-06-27 05:04:44.189438+00
6053	40	MATCH	63	0	{}	2026-06-27 05:04:44.191507+00
6054	48	MATCH	63	0	{}	2026-06-27 05:04:44.193553+00
6055	28	MATCH	63	0	{}	2026-06-27 05:04:44.195749+00
6056	37	MATCH	63	5	{"draw": 3, "goalDiff": 2}	2026-06-27 05:04:44.198559+00
6057	45	MATCH	63	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 05:04:44.201346+00
6058	11	MATCH	63	0	{}	2026-06-27 05:04:44.204044+00
6059	66	MATCH	63	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 05:04:44.231725+00
6060	14	MATCH	63	0	{}	2026-06-27 05:04:44.234158+00
6061	43	MATCH	63	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 05:04:44.23751+00
6062	36	MATCH	63	0	{}	2026-06-27 05:04:44.239597+00
6063	32	MATCH	63	0	{}	2026-06-27 05:04:44.330738+00
6064	33	MATCH	63	0	{}	2026-06-27 05:04:44.336885+00
6065	24	MATCH	63	0	{}	2026-06-27 05:04:44.338957+00
6066	51	MATCH	63	0	{}	2026-06-27 05:04:44.341155+00
6067	34	MATCH	63	0	{}	2026-06-27 05:04:44.343176+00
6068	50	MATCH	63	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 05:04:44.345295+00
6069	35	MATCH	63	0	{}	2026-06-27 05:04:44.348724+00
6070	31	MATCH	63	0	{}	2026-06-27 05:04:44.350776+00
6071	26	MATCH	63	0	{}	2026-06-27 05:04:44.352789+00
6072	30	MATCH	63	0	{}	2026-06-27 05:04:44.354787+00
6073	13	MATCH	63	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-27 05:04:44.356951+00
6074	42	MATCH	63	0	{}	2026-06-27 05:04:44.360798+00
6075	68	MATCH	63	0	{}	2026-06-27 05:04:44.364113+00
6076	41	MATCH	63	0	{}	2026-06-27 05:04:44.367602+00
6077	29	MATCH	63	0	{}	2026-06-27 05:04:44.371064+00
6078	23	MATCH	63	0	{}	2026-06-27 05:04:44.374304+00
6079	44	MATCH	63	0	{}	2026-06-27 05:04:44.37783+00
7230	38	BONUSES	0	0	{}	2026-07-03 10:11:45.475107+00
7231	32	BONUSES	0	0	{}	2026-07-03 10:11:45.477579+00
7234	51	BONUSES	0	0	{}	2026-07-03 10:11:45.495472+00
7235	33	BONUSES	0	0	{}	2026-07-03 10:11:45.497463+00
7236	30	BONUSES	0	0	{}	2026-07-03 10:11:45.499504+00
7232	66	BONUSES	0	0	{}	2026-07-03 10:11:45.491025+00
6750	26	QUALIFIERS	0	68	{"correctCount": 17, "qualifiedTeams": 68}	2026-06-28 03:59:30.95646+00
6751	37	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.958656+00
5931	54	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.018615+00
5932	25	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.021223+00
5933	15	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.023232+00
5934	9	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.025475+00
5935	38	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.027533+00
5936	47	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.029766+00
5937	46	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.032387+00
5938	56	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.035351+00
5939	58	MATCH	64	0	{}	2026-06-27 04:59:29.037868+00
5940	27	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.040201+00
5941	10	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.042846+00
5942	33	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.045492+00
5943	55	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.047919+00
5944	40	MATCH	64	0	{}	2026-06-27 04:59:29.050387+00
5945	48	MATCH	64	0	{}	2026-06-27 04:59:29.052862+00
5946	28	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.054937+00
5947	37	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.058018+00
5948	66	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.060023+00
5949	45	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.062899+00
5950	11	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.065464+00
5951	14	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.067496+00
5952	43	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.06971+00
5953	36	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.0723+00
5954	24	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.074653+00
5955	51	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.076753+00
5956	34	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.079144+00
5957	35	MATCH	64	0	{}	2026-06-27 04:59:29.081259+00
5958	31	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.083269+00
5959	26	MATCH	64	0	{}	2026-06-27 04:59:29.085389+00
5960	50	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.087435+00
5961	30	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.089609+00
5962	13	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.092884+00
5963	42	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.132134+00
5964	68	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.135635+00
5965	41	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.137878+00
5966	29	MATCH	64	0	{}	2026-06-27 04:59:29.229736+00
5967	23	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.233875+00
5968	32	MATCH	64	0	{}	2026-06-27 04:59:29.236035+00
5969	59	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.238037+00
5970	44	MATCH	64	3	{"winner": 3}	2026-06-27 04:59:29.240039+00
6752	29	QUALIFIERS	0	64	{"correctCount": 16, "qualifiedTeams": 64}	2026-06-28 03:59:30.960864+00
6753	54	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.963026+00
6754	50	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:30.965221+00
6755	51	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:30.967392+00
6756	46	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:30.969458+00
6757	12	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:30.97165+00
6758	23	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:30.973817+00
6759	33	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.976038+00
6760	42	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:30.9782+00
6761	11	QUALIFIERS	0	76	{"correctCount": 19, "qualifiedTeams": 76}	2026-06-28 03:59:30.980453+00
6762	45	QUALIFIERS	0	80	{"correctCount": 20, "qualifiedTeams": 80}	2026-06-28 03:59:30.983501+00
6763	56	QUALIFIERS	0	68	{"correctCount": 17, "qualifiedTeams": 68}	2026-06-28 03:59:30.98578+00
7229	46	BONUSES	0	0	{}	2026-07-03 10:11:45.472846+00
7233	18	BONUSES	0	0	{}	2026-07-03 10:11:45.493407+00
7237	31	BONUSES	0	0	{}	2026-07-03 10:11:45.501641+00
6590	9	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.716337+00
6591	10	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.722042+00
6592	11	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.727742+00
6593	12	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.730135+00
6594	13	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.734723+00
6595	14	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.73764+00
6596	15	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.740784+00
6597	23	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.744953+00
6598	24	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.748529+00
6599	25	MATCH	70	0	{}	2026-06-28 03:57:46.750849+00
6600	26	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.755961+00
6601	27	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.760303+00
6602	28	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.765723+00
6603	29	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.767947+00
6604	30	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.770904+00
6605	31	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.780043+00
6606	32	MATCH	70	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 03:57:46.783956+00
6607	33	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.789723+00
6608	34	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.792594+00
6609	35	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.796323+00
6610	36	MATCH	70	0	{}	2026-06-28 03:57:46.800111+00
6611	37	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.803723+00
6612	38	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.821809+00
6613	40	MATCH	70	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 03:57:46.830719+00
6614	41	MATCH	70	5	{"winner": 3, "goalDiff": 2}	2026-06-28 03:57:46.835529+00
6615	42	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.841732+00
6616	43	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.847093+00
6617	44	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.849401+00
6618	45	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.852821+00
6619	46	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.857448+00
6620	47	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.862723+00
6621	48	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.865288+00
6622	50	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.868731+00
6623	51	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.874732+00
6624	54	MATCH	70	5	{"winner": 3, "goalDiff": 2}	2026-06-28 03:57:46.880725+00
6625	55	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.883415+00
6626	56	MATCH	70	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-28 03:57:46.886339+00
6627	58	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.890732+00
6628	59	MATCH	70	5	{"winner": 3, "goalDiff": 2}	2026-06-28 03:57:46.894431+00
6629	66	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.897198+00
6630	68	MATCH	70	3	{"winner": 3}	2026-06-28 03:57:46.899916+00
11713	29	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:49.117116+00
11714	35	MATCH	82	0	{}	2026-07-01 22:49:49.390184+00
11715	12	MATCH	82	0	{}	2026-07-01 22:49:49.685133+00
11716	37	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:50.635085+00
11717	48	MATCH	82	0	{}	2026-07-01 22:49:50.966149+00
11718	30	MATCH	82	3	{"winner": 3}	2026-07-01 22:49:51.237259+00
11719	24	MATCH	82	0	{}	2026-07-01 22:49:51.503328+00
11720	25	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:51.76831+00
11721	40	MATCH	82	0	{}	2026-07-01 22:49:52.052376+00
11722	42	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:52.365276+00
11723	26	MATCH	82	0	{}	2026-07-01 22:49:52.635299+00
11724	36	MATCH	82	0	{}	2026-07-01 22:49:52.914857+00
11725	51	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:53.173733+00
11726	58	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:53.433761+00
11727	41	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:53.678262+00
11728	23	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:53.959159+00
11729	50	MATCH	82	0	{}	2026-07-01 22:49:54.258948+00
11730	59	MATCH	82	0	{}	2026-07-01 22:49:54.53602+00
11731	46	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:54.799962+00
11732	33	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:55.101574+00
11733	32	MATCH	82	0	{}	2026-07-01 22:49:55.411727+00
11734	55	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:55.675725+00
11735	45	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:56.348158+00
11736	47	MATCH	82	0	{}	2026-07-01 22:49:56.64568+00
11737	28	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:56.940681+00
11738	31	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:57.199726+00
11739	44	MATCH	82	3	{"winner": 3}	2026-07-01 22:49:57.483059+00
11740	66	MATCH	82	0	{}	2026-07-01 22:49:57.777995+00
11741	43	MATCH	82	5	{"winner": 3, "goalDiff": 2}	2026-07-01 22:49:58.083001+00
11742	68	MATCH	82	3	{"winner": 3}	2026-07-01 22:49:58.379926+00
6783	35	QUALIFIERS	0	68	{"correctCount": 17, "qualifiedTeams": 68}	2026-06-28 03:59:31.061841+00
6784	40	QUALIFIERS	0	72	{"correctCount": 18, "qualifiedTeams": 72}	2026-06-28 03:59:31.064035+00
10792	34	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:38.66008+00
10793	13	MATCH	80	5	{"winner": 3, "goalDiff": 2}	2026-07-01 18:01:39.145055+00
10822	33	MATCH	80	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 18:01:49.997015+00
6879	30	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.127558+00
6883	66	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.140779+00
6884	28	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.144041+00
6891	42	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.223364+00
6892	54	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.227818+00
6895	41	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.239306+00
6896	51	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.242793+00
6899	43	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.294896+00
6900	9	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.300273+00
6859	68	GROUP_MASTER	1	5	{"groupName": "Grupo A", "groupMaster": 5}	2026-07-03 10:11:49.917494+00
6860	58	GROUP_MASTER	1	5	{"groupName": "Grupo A", "groupMaster": 5}	2026-07-03 10:11:50.013153+00
6863	41	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.033231+00
6864	51	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.036632+00
6867	32	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.047693+00
6868	9	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.050949+00
6871	45	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.098626+00
6872	38	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.102071+00
6875	12	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.111829+00
6876	24	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.11615+00
6877	25	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.120571+00
6880	50	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.130961+00
6881	47	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.134341+00
6882	14	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.137616+00
6885	37	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.149999+00
6886	13	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.155059+00
6887	27	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.205401+00
6888	23	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.209292+00
6861	42	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.021539+00
6869	10	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.091037+00
6870	35	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.095217+00
6873	15	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.105388+00
6889	11	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.215227+00
6890	44	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.218609+00
6893	68	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.232621+00
6894	34	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.235912+00
6897	40	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.249161+00
6898	46	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.291054+00
9882	34	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:10.276116+00
6862	34	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.029766+00
6865	46	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.041041+00
6866	43	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.044352+00
6874	48	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.108689+00
6878	31	GROUP_MASTER	2	5	{"groupName": "Grupo B", "groupMaster": 5}	2026-07-03 10:11:50.124156+00
9883	13	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:10.540916+00
9884	54	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:10.844263+00
9885	37	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:11.161055+00
9886	38	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:11.453363+00
9887	10	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:11.756486+00
6913	30	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.344465+00
6912	31	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.341166+00
6916	66	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.406818+00
6917	28	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.410687+00
6918	37	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.413987+00
6919	59	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.417215+00
6921	33	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.42346+00
6923	27	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.492651+00
6920	13	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.420351+00
6922	55	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.429765+00
6926	58	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.50287+00
6924	23	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.496198+00
6925	56	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.499586+00
6928	44	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.509413+00
6927	11	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.506114+00
6930	66	GROUP_MASTER	4	5	{"groupName": "Grupo D", "groupMaster": 5}	2026-07-03 10:11:50.548467+00
6931	59	GROUP_MASTER	4	5	{"groupName": "Grupo D", "groupMaster": 5}	2026-07-03 10:11:50.591032+00
6929	32	GROUP_MASTER	4	5	{"groupName": "Grupo D", "groupMaster": 5}	2026-07-03 10:11:50.526838+00
6932	1	GROUP_MASTER	4	5	{"groupName": "Grupo D", "groupMaster": 5}	2026-07-03 10:11:50.596958+00
6935	38	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.631547+00
6933	42	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.610839+00
6934	32	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.623919+00
6936	48	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.635909+00
6937	24	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.691926+00
6938	14	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.704959+00
6940	33	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.716136+00
6941	1	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.71947+00
6942	56	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.727916+00
6939	37	GROUP_MASTER	5	5	{"groupName": "Grupo E", "groupMaster": 5}	2026-07-03 10:11:50.710604+00
6943	42	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.735896+00
6944	29	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.739334+00
6945	54	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.793604+00
6946	68	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.797315+00
6947	34	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.800643+00
6949	51	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.807425+00
6951	43	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.814938+00
6950	40	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.810751+00
6954	12	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.831277+00
6953	45	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.824904+00
6955	24	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.835669+00
6956	25	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.839975+00
6957	31	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.842964+00
6958	30	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.846019+00
6903	45	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.311304+00
6904	38	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.314682+00
6905	15	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.317972+00
6906	48	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.321689+00
6907	12	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.324941+00
6908	26	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.328206+00
6909	24	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.331439+00
6911	36	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.334704+00
6910	25	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.337887+00
9888	27	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:12.081684+00
6915	14	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.40052+00
6974	68	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:50.939352+00
6975	34	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:50.942475+00
6976	41	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:50.993606+00
6977	51	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:50.996934+00
6978	43	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.00247+00
6979	9	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.006613+00
6980	10	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.00977+00
6982	38	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.017031+00
6981	45	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.013898+00
6985	24	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.028636+00
6983	48	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.021251+00
6984	12	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.024457+00
6986	25	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.034948+00
6987	36	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.031724+00
6988	31	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.03825+00
6989	30	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.041525+00
6990	50	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.04468+00
6991	47	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.047736+00
6992	14	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.050869+00
6993	28	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.054915+00
6994	37	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.058+00
6995	59	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.061012+00
6996	33	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.065204+00
6997	1	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.068412+00
6999	55	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.098057+00
6998	16	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.094597+00
7001	23	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.104799+00
7000	27	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.101488+00
7002	11	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:51.108964+00
7003	40	GROUP_MASTER	8	5	{"groupName": "Grupo H", "groupMaster": 5}	2026-07-03 10:11:51.121534+00
7004	47	GROUP_MASTER	8	5	{"groupName": "Grupo H", "groupMaster": 5}	2026-07-03 10:11:51.143488+00
7005	55	GROUP_MASTER	8	5	{"groupName": "Grupo H", "groupMaster": 5}	2026-07-03 10:11:51.195622+00
7006	42	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.206713+00
7008	54	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.213135+00
7013	46	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.229862+00
7014	43	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.233278+00
7015	32	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.236563+00
7016	9	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.239702+00
6964	1	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.901286+00
6965	16	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.907356+00
6966	55	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.91053+00
6967	27	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.913782+00
6968	23	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.9168+00
6969	56	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.919936+00
6970	58	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.922932+00
6971	44	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.927067+00
6973	54	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:50.936124+00
9889	56	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:12.371923+00
9890	15	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:12.682629+00
9891	14	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:13.174465+00
9892	9	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:13.4345+00
9893	29	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:13.740724+00
7027	47	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.317794+00
7031	37	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.329959+00
7029	66	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.323881+00
7032	59	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.332937+00
7034	33	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.339072+00
7035	16	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.344217+00
7036	55	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.347444+00
7037	27	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.35059+00
7041	11	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.396588+00
7042	44	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.399906+00
7043	29	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.405399+00
7044	54	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.408544+00
7045	68	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.411546+00
7046	34	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.4146+00
7047	41	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.417793+00
7048	40	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.421858+00
7049	46	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.424868+00
7050	9	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.429981+00
7051	10	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.433048+00
7052	45	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.437386+00
7053	38	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.440489+00
7054	48	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.444555+00
7055	12	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.447479+00
7056	26	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.450441+00
7057	24	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.4536+00
7058	36	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.456571+00
7059	50	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.494634+00
7060	47	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.497837+00
7061	14	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.500949+00
7062	28	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.505095+00
7063	37	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.508273+00
7064	59	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.511446+00
7066	16	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.520662+00
7067	27	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.524735+00
7070	11	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.535239+00
7071	44	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.538453+00
7072	42	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.542925+00
7073	29	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.546145+00
7074	54	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.549232+00
7019	45	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.249294+00
7022	12	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.298243+00
7023	26	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.301587+00
7024	24	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.304937+00
7025	30	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.311388+00
7026	50	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.314613+00
7028	14	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.320818+00
7038	23	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.353658+00
7040	58	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.393438+00
9894	35	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:14.072721+00
9895	12	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:14.37604+00
9896	48	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:14.652468+00
9897	30	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:15.334621+00
9898	24	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:15.754879+00
7087	38	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.606046+00
7086	45	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.602978+00
7090	12	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.615527+00
7092	24	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.621617+00
7094	36	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.624757+00
7093	25	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.627951+00
7091	26	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.618605+00
7096	30	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.634608+00
7098	47	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.640837+00
7097	50	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.637708+00
7095	31	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.631382+00
7099	14	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.643965+00
7100	66	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.647175+00
7101	28	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.650445+00
7103	59	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.656606+00
7104	13	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.659813+00
7102	37	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.65355+00
7105	33	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.662966+00
7107	18	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.693502+00
7106	1	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.666633+00
7110	27	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.70376+00
7108	16	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.696823+00
7109	55	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.700451+00
7112	58	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.71115+00
7111	23	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.706967+00
7114	44	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.717447+00
7115	42	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.721938+00
7113	11	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.714316+00
7117	54	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.728329+00
7119	41	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.735664+00
7116	29	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.725215+00
7118	34	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.73254+00
7122	46	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.744945+00
7120	51	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.738707+00
7121	40	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.741905+00
7126	10	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.796839+00
7124	32	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.751304+00
7127	35	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.799994+00
7128	45	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.803091+00
7129	38	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.806438+00
7125	9	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.793564+00
7131	48	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.813219+00
7130	15	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.809824+00
7132	12	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.816457+00
7078	51	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.561622+00
7079	40	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.564741+00
7077	41	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.558459+00
7081	43	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.571038+00
7083	9	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.593297+00
7080	46	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.567922+00
7082	32	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.574171+00
7084	10	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.596561+00
9899	25	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:16.480335+00
7085	35	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.599751+00
7089	48	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.612467+00
7144	13	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.894701+00
7145	33	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.898095+00
7135	25	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.826871+00
7136	31	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.829908+00
12188	32	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:41.539281+00
12189	55	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:43.047919+00
7137	30	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.832895+00
7138	50	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.835949+00
9900	31	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:16.764726+00
9901	40	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:17.042374+00
9902	42	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:17.268109+00
9903	26	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:17.549318+00
9904	51	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:17.828522+00
9905	58	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:18.064218+00
9906	41	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:18.347897+00
9907	23	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:18.655863+00
9908	50	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:18.96176+00
9909	59	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:19.331032+00
9910	46	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:19.577539+00
9911	33	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:19.898892+00
9912	11	MATCH	77	5	{"winner": 3, "goalDiff": 2}	2026-06-30 22:54:20.23341+00
9913	32	MATCH	77	5	{"winner": 3, "goalDiff": 2}	2026-06-30 22:54:20.529762+00
9914	55	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:20.772335+00
9915	36	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:21.137666+00
9916	45	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:21.433018+00
9917	28	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:21.732358+00
9918	47	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:22.835447+00
7139	47	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.839216+00
7140	14	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.842481+00
7146	55	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.904575+00
12176	40	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:37.282962+00
12177	42	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:37.5439+00
12178	26	MATCH	81	0	{}	2026-07-02 02:09:37.799993+00
12179	36	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:38.094937+00
12180	51	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:38.385962+00
12181	58	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:38.735449+00
12182	50	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:38.997833+00
12183	41	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:39.349885+00
12184	23	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:39.649486+00
7141	66	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.845507+00
7142	28	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.848742+00
7143	37	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.851896+00
7147	27	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.907722+00
7148	23	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.910882+00
7149	56	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.913986+00
7150	58	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.917432+00
7151	11	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.920607+00
9919	44	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:23.165749+00
9920	66	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:23.446305+00
9921	43	MATCH	77	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 22:54:23.739589+00
9922	68	MATCH	77	3	{"winner": 3}	2026-06-30 22:54:24.052329+00
7152	44	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.923701+00
7134	24	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.822666+00
12185	59	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:39.986428+00
12186	46	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:40.268281+00
12187	33	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:40.656416+00
12190	45	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:43.595381+00
12191	47	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:43.973709+00
12192	44	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:44.640944+00
12193	28	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:46.444012+00
12194	31	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:47.538995+00
6914	50	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.392921+00
6948	41	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.803891+00
6959	50	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.849296+00
6960	28	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.855689+00
6972	42	GROUP_MASTER	7	5	{"groupName": "Grupo G", "groupMaster": 5}	2026-07-03 10:11:50.931811+00
7007	29	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.20999+00
7017	10	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.242899+00
7018	35	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.246005+00
7030	28	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.32692+00
7065	18	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.517588+00
7068	23	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.528008+00
7069	58	GROUP_MASTER	10	5	{"groupName": "Grupo J", "groupMaster": 5}	2026-07-03 10:11:51.532136+00
7075	68	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.552445+00
7076	34	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.555413+00
7088	15	GROUP_MASTER	11	5	{"groupName": "Grupo K", "groupMaster": 5}	2026-07-03 10:11:51.609249+00
7123	43	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.748037+00
6901	10	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.304236+00
6902	35	GROUP_MASTER	3	5	{"groupName": "Grupo C", "groupMaster": 5}	2026-07-03 10:11:50.307761+00
7618	56	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:04.439517+00
7619	29	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:04.73249+00
7620	35	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:05.061729+00
7621	12	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:05.367961+00
7622	48	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:05.730864+00
7623	30	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:06.466596+00
7624	24	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:06.831887+00
7625	25	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:07.14444+00
7626	31	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:07.45489+00
7627	40	MATCH	76	0	{}	2026-06-29 19:03:07.749721+00
7628	42	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:08.441943+00
7629	26	MATCH	76	0	{}	2026-06-29 19:03:09.342823+00
7630	58	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:09.879426+00
7631	41	MATCH	76	0	{}	2026-06-29 19:03:10.250065+00
7632	23	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:10.533945+00
7633	50	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:10.79415+00
7634	59	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:11.365282+00
7635	46	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:11.630657+00
7636	33	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:11.887814+00
7637	32	MATCH	76	5	{"winner": 3, "goalDiff": 2}	2026-06-29 19:03:12.181689+00
7638	55	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:12.762744+00
7639	45	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:13.053734+00
7640	44	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:13.379453+00
7641	28	MATCH	76	0	{}	2026-06-29 19:03:13.671723+00
7642	47	MATCH	76	3	{"winner": 3}	2026-06-29 19:03:14.048914+00
7643	51	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:14.33972+00
7644	66	MATCH	76	5	{"winner": 3, "goalDiff": 2}	2026-06-29 19:03:14.581808+00
7645	43	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:14.871822+00
7646	68	MATCH	76	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-06-29 19:03:15.152148+00
7228	23	BONUSES	0	0	{}	2026-07-03 10:11:45.470715+00
7208	48	BONUSES	0	0	{}	2026-07-03 10:11:45.429835+00
10337	34	MATCH	79	0	{}	2026-07-01 04:01:26.645284+00
10338	13	MATCH	79	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 04:01:26.904344+00
10339	54	MATCH	79	0	{}	2026-07-01 04:01:27.190208+00
10340	37	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:27.469871+00
10341	11	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:27.735533+00
10342	38	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:28.054077+00
10343	10	MATCH	79	0	{}	2026-07-01 04:01:28.355395+00
10344	14	MATCH	79	0	{}	2026-07-01 04:01:28.647076+00
10345	27	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:28.947131+00
10346	15	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:29.25642+00
10347	56	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:29.55025+00
10348	9	MATCH	79	0	{}	2026-07-01 04:01:29.850131+00
10349	29	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:30.149831+00
10350	35	MATCH	79	0	{}	2026-07-01 04:01:30.451022+00
10351	12	MATCH	79	0	{}	2026-07-01 04:01:30.738513+00
10352	48	MATCH	79	0	{}	2026-07-01 04:01:31.034245+00
10353	30	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:31.331108+00
10354	24	MATCH	79	0	{}	2026-07-01 04:01:31.631347+00
10355	25	MATCH	79	0	{}	2026-07-01 04:01:31.930999+00
10356	40	MATCH	79	0	{}	2026-07-01 04:01:32.230659+00
10357	42	MATCH	79	0	{}	2026-07-01 04:01:32.470825+00
10358	26	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:32.767594+00
10359	36	MATCH	79	0	{}	2026-07-01 04:01:33.068953+00
10360	58	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:33.359085+00
10361	41	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:33.648224+00
10362	51	MATCH	79	0	{}	2026-07-01 04:01:33.929801+00
10363	23	MATCH	79	0	{}	2026-07-01 04:01:34.178406+00
10364	50	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:34.458407+00
10365	59	MATCH	79	0	{}	2026-07-01 04:01:34.74912+00
10366	46	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:35.04489+00
10367	33	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:35.34277+00
10368	32	MATCH	79	0	{}	2026-07-01 04:01:35.634291+00
10369	55	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:36.131768+00
10370	45	MATCH	79	0	{}	2026-07-01 04:01:36.553793+00
10371	47	MATCH	79	0	{}	2026-07-01 04:01:36.84347+00
10372	44	MATCH	79	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 04:01:37.139812+00
10373	28	MATCH	79	3	{"winner": 3}	2026-07-01 04:01:37.434985+00
10374	31	MATCH	79	0	{}	2026-07-01 04:01:37.669487+00
10375	66	MATCH	79	0	{}	2026-07-01 04:01:38.004292+00
10376	43	MATCH	79	0	{}	2026-07-01 04:01:38.275716+00
10377	68	MATCH	79	0	{}	2026-07-01 04:01:38.680614+00
12157	34	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:29.476721+00
12158	13	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:29.889731+00
12159	54	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:30.467724+00
12160	38	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:31.034211+00
12161	11	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:31.370636+00
12162	10	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:31.705721+00
12163	27	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:32.049987+00
12164	14	MATCH	81	0	{}	2026-07-02 02:09:32.339402+00
12165	15	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:32.676285+00
12166	56	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:33.027979+00
12167	9	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:33.344963+00
12168	29	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:33.618272+00
12169	35	MATCH	81	0	{}	2026-07-02 02:09:34.273734+00
12170	12	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:34.680752+00
12171	37	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:35.163825+00
12172	48	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:35.602587+00
12173	30	MATCH	81	5	{"winner": 3, "goalDiff": 2}	2026-07-02 02:09:36.184738+00
12174	24	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:36.726282+00
12175	25	MATCH	81	3	{"winner": 3}	2026-07-02 02:09:37.007964+00
7020	38	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.252483+00
7021	48	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.294638+00
10794	54	MATCH	80	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 18:01:39.396037+00
10795	38	MATCH	80	5	{"winner": 3, "goalDiff": 2}	2026-07-01 18:01:39.667551+00
10796	11	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:39.950472+00
10797	10	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:40.282762+00
10798	14	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:40.568012+00
10799	27	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:40.852889+00
10800	15	MATCH	80	5	{"winner": 3, "goalDiff": 2}	2026-07-01 18:01:41.136097+00
10801	56	MATCH	80	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 18:01:41.45069+00
10802	29	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:41.748351+00
10803	35	MATCH	80	5	{"winner": 3, "goalDiff": 2}	2026-07-01 18:01:42.064262+00
10804	12	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:42.360239+00
10805	37	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:42.688658+00
10806	48	MATCH	80	0	{}	2026-07-01 18:01:42.987163+00
10807	30	MATCH	80	5	{"winner": 3, "goalDiff": 2}	2026-07-01 18:01:43.282415+00
10808	24	MATCH	80	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 18:01:43.834735+00
10809	25	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:44.195382+00
10810	40	MATCH	80	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 18:01:44.477437+00
10811	9	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:44.936784+00
10812	42	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:45.773089+00
10813	26	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:46.477751+00
10814	36	MATCH	80	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-01 18:01:47.057637+00
10815	51	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:47.662315+00
10816	58	MATCH	80	0	{}	2026-07-01 18:01:48.157607+00
10817	41	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:48.533095+00
10818	23	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:48.806764+00
10819	50	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:49.121883+00
10820	59	MATCH	80	0	{}	2026-07-01 18:01:49.398517+00
10821	46	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:49.686608+00
10823	32	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:50.346419+00
10824	55	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:50.638043+00
10825	47	MATCH	80	5	{"winner": 3, "goalDiff": 2}	2026-07-01 18:01:51.064925+00
10826	44	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:51.459771+00
10827	45	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:51.790958+00
10828	28	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:52.094991+00
10829	31	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:52.379638+00
10830	66	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:52.776069+00
10831	43	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:53.137051+00
10832	68	MATCH	80	3	{"winner": 3}	2026-07-01 18:01:53.541245+00
8548	33	MATCH	75	5	{"draw": 3, "goalDiff": 2}	2026-06-30 03:54:21.646572+00
8549	32	MATCH	75	0	{}	2026-06-30 03:54:21.940628+00
8550	55	MATCH	75	0	{}	2026-06-30 03:54:22.258848+00
8551	45	MATCH	75	0	{}	2026-06-30 03:54:22.539335+00
8552	23	MATCH	75	5	{"draw": 3, "goalDiff": 2}	2026-06-30 03:54:22.850757+00
8553	28	MATCH	75	0	{}	2026-06-30 03:54:23.16792+00
8554	47	MATCH	75	0	{}	2026-06-30 03:54:23.550113+00
8555	43	MATCH	75	0	{}	2026-06-30 03:54:23.843862+00
8556	66	MATCH	75	10	{"draw": 3, "goalDiff": 2, "exactScore": 5}	2026-06-30 03:54:24.135003+00
8557	68	MATCH	75	0	{}	2026-06-30 03:54:24.403417+00
7192	1	BONUSES	0	0	{}	2026-07-03 10:11:45.395821+00
6961	59	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.859876+00
6962	13	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.893864+00
6963	33	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.897898+00
7033	13	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.33601+00
12195	66	MATCH	81	0	{}	2026-07-02 02:09:48.176615+00
12196	43	MATCH	81	0	{}	2026-07-02 02:09:48.546724+00
12197	68	MATCH	81	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 02:09:48.963581+00
12612	34	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:17.692054+00
12613	13	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:18.074857+00
12614	54	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:18.396534+00
12615	38	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:18.773181+00
12616	11	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:19.071239+00
12617	10	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:19.410262+00
12618	27	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:19.755248+00
12619	14	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:20.453874+00
12620	15	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:20.88274+00
12621	56	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:21.318985+00
12622	9	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:21.847151+00
12623	29	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:22.155569+00
12624	35	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:22.48756+00
12625	12	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:22.996733+00
12626	37	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:23.454507+00
12627	30	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:23.888846+00
12628	24	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:24.200565+00
12629	25	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:24.535892+00
12630	40	MATCH	84	0	{}	2026-07-02 21:00:24.894555+00
12631	42	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:25.333732+00
12632	26	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:25.630199+00
12633	36	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:26.434266+00
12634	51	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:26.743446+00
12635	58	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:27.05525+00
12636	41	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:27.3636+00
12637	23	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:27.660722+00
12638	50	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:28.028968+00
12639	59	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:28.377305+00
12640	46	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:28.743729+00
12641	33	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:29.643874+00
12642	32	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:30.053209+00
12643	55	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:30.378374+00
12644	45	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:30.784848+00
12645	48	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:31.206455+00
12646	47	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:31.545968+00
12647	28	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:31.881091+00
12648	31	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:32.635066+00
12649	44	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:33.763757+00
12650	66	MATCH	84	3	{"winner": 3}	2026-07-02 21:00:34.339737+00
12651	43	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:34.628734+00
12652	68	MATCH	84	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-02 21:00:34.928594+00
7133	26	GROUP_MASTER	12	5	{"groupName": "Grupo L", "groupMaster": 5}	2026-07-03 10:11:51.819601+00
13067	34	MATCH	83	0	{}	2026-07-03 01:09:56.861767+00
13068	13	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:09:57.15684+00
13069	54	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:09:57.478476+00
13070	38	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:09:57.742566+00
13071	11	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:09:58.033522+00
13072	10	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:09:58.303908+00
13073	27	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:09:58.588294+00
13074	14	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:09:58.848455+00
13075	15	MATCH	83	0	{}	2026-07-03 01:09:59.093199+00
13076	56	MATCH	83	0	{}	2026-07-03 01:09:59.361366+00
13077	9	MATCH	83	3	{"winner": 3}	2026-07-03 01:09:59.642198+00
13078	29	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:09:59.963383+00
13079	35	MATCH	83	0	{}	2026-07-03 01:10:00.336997+00
13080	12	MATCH	83	3	{"winner": 3}	2026-07-03 01:10:00.599914+00
13081	37	MATCH	83	0	{}	2026-07-03 01:10:00.934256+00
13082	48	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:01.23358+00
13083	30	MATCH	83	3	{"winner": 3}	2026-07-03 01:10:01.546728+00
13084	24	MATCH	83	3	{"winner": 3}	2026-07-03 01:10:01.868327+00
13085	25	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:02.242645+00
13086	40	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:02.538595+00
13087	42	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:03.429202+00
13088	26	MATCH	83	0	{}	2026-07-03 01:10:03.831139+00
13089	36	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:04.153518+00
13090	51	MATCH	83	0	{}	2026-07-03 01:10:04.447079+00
13091	58	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:10:04.941004+00
13092	41	MATCH	83	0	{}	2026-07-03 01:10:05.546558+00
13093	23	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:06.554677+00
13094	50	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:06.867953+00
13095	59	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:10:07.186946+00
13096	46	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:07.563338+00
13097	33	MATCH	83	0	{}	2026-07-03 01:10:07.862508+00
13098	32	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:08.209156+00
13099	55	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:08.4944+00
13100	45	MATCH	83	0	{}	2026-07-03 01:10:08.8709+00
13101	47	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:09.279728+00
13102	28	MATCH	83	3	{"winner": 3}	2026-07-03 01:10:09.591301+00
13103	31	MATCH	83	5	{"winner": 3, "goalDiff": 2}	2026-07-03 01:10:09.981731+00
13104	44	MATCH	83	0	{}	2026-07-03 01:10:10.290548+00
13105	66	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:10.649122+00
13106	43	MATCH	83	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 01:10:10.9463+00
13107	68	MATCH	83	0	{}	2026-07-03 01:10:11.293727+00
7011	41	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.222493+00
7012	40	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.226706+00
7009	68	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.216109+00
7010	34	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.219279+00
13522	34	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:32.215822+00
13523	13	MATCH	85	0	{}	2026-07-03 10:11:32.604405+00
13524	54	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:32.941916+00
13525	38	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:33.321054+00
13526	11	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:33.646889+00
13527	10	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:34.046606+00
13528	27	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:34.397306+00
13529	14	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:34.695423+00
13530	15	MATCH	85	0	{}	2026-07-03 10:11:35.017331+00
13531	56	MATCH	85	0	{}	2026-07-03 10:11:35.305006+00
13532	9	MATCH	85	0	{}	2026-07-03 10:11:35.60498+00
13533	29	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:35.894971+00
13534	35	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:36.491035+00
13535	12	MATCH	85	0	{}	2026-07-03 10:11:36.90358+00
13536	37	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:37.159348+00
13537	30	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:37.591036+00
13538	24	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:37.841995+00
13539	25	MATCH	85	0	{}	2026-07-03 10:11:38.136781+00
13540	40	MATCH	85	0	{}	2026-07-03 10:11:38.420815+00
13541	42	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:38.721075+00
13542	26	MATCH	85	0	{}	2026-07-03 10:11:39.034736+00
13543	36	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:39.31776+00
13544	51	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:39.595182+00
13545	58	MATCH	85	0	{}	2026-07-03 10:11:39.895054+00
13546	41	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:40.143989+00
13547	23	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:40.505792+00
13548	50	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:40.818636+00
13549	59	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:41.123604+00
13550	46	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:41.401704+00
13551	33	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:41.694606+00
13552	32	MATCH	85	5	{"winner": 3, "goalDiff": 2}	2026-07-03 10:11:41.995077+00
13553	55	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:42.327036+00
13554	45	MATCH	85	0	{}	2026-07-03 10:11:42.646682+00
13555	48	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:42.934509+00
13556	47	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:43.245666+00
13557	28	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:43.529914+00
13558	31	MATCH	85	10	{"winner": 3, "goalDiff": 2, "exactScore": 5}	2026-07-03 10:11:43.810498+00
13559	44	MATCH	85	0	{}	2026-07-03 10:11:44.140844+00
13560	43	MATCH	85	3	{"winner": 3}	2026-07-03 10:11:44.422455+00
13561	66	MATCH	85	5	{"winner": 3, "goalDiff": 2}	2026-07-03 10:11:44.700587+00
13562	68	MATCH	85	0	{}	2026-07-03 10:11:45.016112+00
13609	29	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.518831+00
13610	32	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.527889+00
13611	10	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.532545+00
13612	12	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.540708+00
13613	30	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.548817+00
13614	28	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.597743+00
13615	13	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.601273+00
13616	33	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.60486+00
13617	18	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.608287+00
13618	27	EXPERT_DAY	20260611	10	{"date": "2026-06-11", "expertDay": 10}	2026-07-03 10:11:45.613405+00
13619	46	EXPERT_DAY	20260612	10	{"date": "2026-06-12", "expertDay": 10}	2026-07-03 10:11:45.632621+00
13620	37	EXPERT_DAY	20260614	10	{"date": "2026-06-14", "expertDay": 10}	2026-07-03 10:11:46.012879+00
13621	33	EXPERT_DAY	20260614	10	{"date": "2026-06-14", "expertDay": 10}	2026-07-03 10:11:46.018798+00
13622	42	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:46.692412+00
13623	54	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:46.696598+00
13624	29	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:46.791035+00
13625	41	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:46.798538+00
13626	46	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:46.893984+00
13627	10	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.096047+00
6952	9	GROUP_MASTER	6	5	{"groupName": "Grupo F", "groupMaster": 5}	2026-07-03 10:11:50.819644+00
7039	56	GROUP_MASTER	9	5	{"groupName": "Grupo I", "groupMaster": 5}	2026-07-03 10:11:51.356818+00
13628	35	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.19671+00
13629	45	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.292655+00
13630	15	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.394907+00
13631	48	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.398556+00
13632	12	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.494565+00
13633	24	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.498021+00
13634	50	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.597723+00
13635	14	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.60225+00
13636	37	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.60688+00
13637	59	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.61118+00
13638	33	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.614546+00
13639	13	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.691033+00
13640	16	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.696388+00
13641	58	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.704357+00
13642	44	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.707631+00
13643	11	EXPERT_DAY	20260616	10	{"date": "2026-06-16", "expertDay": 10}	2026-07-03 10:11:47.710885+00
13644	54	EXPERT_DAY	20260618	10	{"date": "2026-06-18", "expertDay": 10}	2026-07-03 10:11:47.899882+00
13645	32	EXPERT_DAY	20260618	10	{"date": "2026-06-18", "expertDay": 10}	2026-07-03 10:11:47.913608+00
13646	45	EXPERT_DAY	20260618	10	{"date": "2026-06-18", "expertDay": 10}	2026-07-03 10:11:47.920932+00
13647	68	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.102267+00
13648	34	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.105971+00
13649	9	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.118572+00
13650	15	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.126196+00
13651	24	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.196248+00
13652	25	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.204616+00
13653	31	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.211218+00
13654	30	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.215989+00
13655	50	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.219517+00
13656	37	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.226964+00
13657	33	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.233422+00
13658	27	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.292804+00
13659	44	EXPERT_DAY	20260619	10	{"date": "2026-06-19", "expertDay": 10}	2026-07-03 10:11:48.300558+00
13660	55	EXPERT_DAY	20260620	10	{"date": "2026-06-20", "expertDay": 10}	2026-07-03 10:11:48.413672+00
13661	42	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.609701+00
13662	34	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.617289+00
13663	41	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.622342+00
13664	46	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.626012+00
13665	10	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.698917+00
13666	35	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.704061+00
13667	30	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.721659+00
13668	50	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.725209+00
13669	14	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.729972+00
13670	37	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.796204+00
13671	28	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.799946+00
13672	33	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.805052+00
13673	55	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.812396+00
13674	23	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.817219+00
13675	56	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.820797+00
13676	11	EXPERT_DAY	20260622	10	{"date": "2026-06-22", "expertDay": 10}	2026-07-03 10:11:48.826878+00
13677	43	EXPERT_DAY	20260626	10	{"date": "2026-06-26", "expertDay": 10}	2026-07-03 10:11:49.326802+00
13678	54	EXPERT_DAY	20260627	10	{"date": "2026-06-27", "expertDay": 10}	2026-07-03 10:11:49.492416+00
13679	31	EXPERT_DAY	20260627	10	{"date": "2026-06-27", "expertDay": 10}	2026-07-03 10:11:49.521685+00
13680	55	EXPERT_DAY	20260627	10	{"date": "2026-06-27", "expertDay": 10}	2026-07-03 10:11:49.594333+00
13683	11	INVICTO	0	15	{"invicto": 15, "maxStreak": 10}	2026-07-03 10:11:49.71476+00
13684	29	INVICTO	0	15	{"invicto": 15, "maxStreak": 10}	2026-07-03 10:11:49.718537+00
13685	46	INVICTO	0	15	{"invicto": 15, "maxStreak": 10}	2026-07-03 10:11:49.801361+00
13686	30	INVICTO	0	15	{"invicto": 15, "maxStreak": 10}	2026-07-03 10:11:49.811295+00
\.


--
-- Data for Name: predictions; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.predictions (id, user_id, match_id, predicted_home_score, predicted_away_score, predicted_advancing_team_id, created_at, updated_at, bracket_home_team_id, bracket_away_team_id) FROM stdin;
1807	35	30	0	2	\N	2026-06-19 16:23:41.341767+00	2026-06-19 16:23:41.341767+00	\N	\N
91	40	2	2	0	\N	2026-06-11 20:17:32.372322+00	2026-06-11 20:17:32.372322+00	\N	\N
92	34	10	4	0	\N	2026-06-11 20:50:52.284422+00	2026-06-11 20:50:52.284422+00	\N	\N
13	15	2	1	1	\N	2026-06-07 02:31:26.228512+00	2026-06-07 02:31:26.228512+00	\N	\N
14	15	1	2	1	\N	2026-06-07 02:31:35.068783+00	2026-06-07 02:31:35.068783+00	\N	\N
15	15	3	2	0	\N	2026-06-08 00:01:30.286632+00	2026-06-08 00:01:30.286632+00	\N	\N
18	15	8	0	2	\N	2026-06-08 00:03:23.473645+00	2026-06-08 00:03:23.473645+00	\N	\N
20	15	5	0	3	\N	2026-06-08 00:03:50.918946+00	2026-06-08 00:03:50.918946+00	\N	\N
21	15	10	6	0	\N	2026-06-08 00:04:23.121728+00	2026-06-08 00:04:23.121728+00	\N	\N
22	15	11	3	1	\N	2026-06-08 00:04:44.513438+00	2026-06-08 00:04:44.513438+00	\N	\N
23	15	9	1	2	\N	2026-06-08 00:05:12.787285+00	2026-06-08 00:05:12.787285+00	\N	\N
24	15	12	2	0	\N	2026-06-08 00:05:43.927057+00	2026-06-08 00:05:43.927057+00	\N	\N
25	15	14	4	0	\N	2026-06-08 00:07:26.565253+00	2026-06-08 00:07:26.565253+00	\N	\N
26	15	16	3	0	\N	2026-06-08 00:07:36.351103+00	2026-06-08 00:07:36.351103+00	\N	\N
27	15	13	0	2	\N	2026-06-08 00:07:51.246273+00	2026-06-08 00:07:51.246273+00	\N	\N
28	15	15	1	1	\N	2026-06-08 00:08:16.952375+00	2026-06-08 00:08:16.952375+00	\N	\N
30	15	17	3	1	\N	2026-06-08 14:37:19.171206+00	2026-06-08 14:37:19.171206+00	\N	\N
33	15	23	3	0	\N	2026-06-08 14:38:26.628531+00	2026-06-08 14:38:26.628531+00	\N	\N
36	15	24	0	2	\N	2026-06-08 14:39:04.103235+00	2026-06-08 14:39:04.103235+00	\N	\N
37	27	1	2	1	\N	2026-06-11 03:12:15.357924+00	2026-06-11 03:12:15.357924+00	\N	\N
38	27	2	3	2	\N	2026-06-11 03:12:24.424726+00	2026-06-11 03:12:24.424726+00	\N	\N
39	11	1	1	2	\N	2026-06-11 14:28:14.134016+00	2026-06-11 14:28:14.134016+00	\N	\N
93	34	11	2	1	\N	2026-06-11 20:51:32.936567+00	2026-06-11 20:51:32.936567+00	\N	\N
43	13	2	2	1	\N	2026-06-11 18:07:44.362796+00	2026-06-11 18:07:44.362796+00	\N	\N
41	14	2	2	1	\N	2026-06-11 18:07:11.788725+00	2026-06-11 18:07:48.062675+00	\N	\N
45	10	2	2	0	\N	2026-06-11 18:08:25.936155+00	2026-06-11 18:08:25.936155+00	\N	\N
40	11	2	2	1	\N	2026-06-11 14:28:50.848232+00	2026-06-11 18:19:36.925952+00	\N	\N
47	24	2	2	1	\N	2026-06-11 18:47:15.265424+00	2026-06-11 18:47:15.265424+00	\N	\N
48	24	1	1	1	\N	2026-06-11 18:47:29.392869+00	2026-06-11 18:47:29.392869+00	\N	\N
49	10	1	2	1	\N	2026-06-11 18:48:17.57599+00	2026-06-11 18:48:17.57599+00	\N	\N
94	34	9	1	1	\N	2026-06-11 20:52:04.43053+00	2026-06-11 20:52:04.43053+00	\N	\N
51	14	1	1	1	\N	2026-06-11 18:49:23.53342+00	2026-06-11 18:49:23.53342+00	\N	\N
10	9	1	1	1	\N	2026-06-04 20:52:03.591656+00	2026-06-11 18:49:41.314283+00	\N	\N
53	13	1	1	0	\N	2026-06-11 18:49:55.752376+00	2026-06-11 18:49:55.752376+00	\N	\N
95	34	12	2	0	\N	2026-06-11 20:52:53.964223+00	2026-06-11 20:52:53.964223+00	\N	\N
54	12	1	2	0	\N	2026-06-11 18:52:36.427777+00	2026-06-11 18:52:54.776768+00	\N	\N
57	23	1	1	1	\N	2026-06-11 18:52:55.432589+00	2026-06-11 18:54:13.371626+00	\N	\N
60	29	1	2	1	\N	2026-06-11 18:54:41.8581+00	2026-06-11 18:54:41.8581+00	\N	\N
61	18	2	3	1	\N	2026-06-11 18:58:08.872989+00	2026-06-11 18:58:08.872989+00	\N	\N
62	18	1	2	0	\N	2026-06-11 18:58:20.740892+00	2026-06-11 18:58:20.740892+00	\N	\N
63	28	1	1	0	\N	2026-06-11 18:58:37.026958+00	2026-06-11 18:58:37.026958+00	\N	\N
64	28	2	1	0	\N	2026-06-11 18:58:59.188971+00	2026-06-11 18:58:59.188971+00	\N	\N
65	16	2	2	1	\N	2026-06-11 19:19:29.414577+00	2026-06-11 19:19:29.414577+00	\N	\N
66	33	1	2	1	\N	2026-06-04 20:52:11.711383+00	2026-06-04 20:52:11.711383+00	\N	\N
67	32	1	2	1	\N	2026-06-04 20:52:11.711383+00	2026-06-04 20:52:11.711383+00	\N	\N
68	31	1	2	1	\N	2026-06-04 20:52:11.711383+00	2026-06-04 20:52:11.711383+00	\N	\N
69	30	1	2	1	\N	2026-06-04 20:52:11.711383+00	2026-06-04 20:52:11.711383+00	\N	\N
70	37	2	2	1	\N	2026-06-11 19:22:29.71212+00	2026-06-11 19:22:29.71212+00	\N	\N
96	34	14	4	0	\N	2026-06-11 20:53:55.043508+00	2026-06-11 20:53:55.043508+00	\N	\N
117	44	2	1	0	\N	2026-06-12 00:25:04.777211+00	2026-06-12 00:25:04.777211+00	\N	\N
77	36	2	2	1	\N	2026-06-11 19:46:10.834203+00	2026-06-11 19:46:10.834203+00	\N	\N
78	37	3	2	0	\N	2026-06-11 19:49:37.266264+00	2026-06-11 19:49:37.266264+00	\N	\N
83	37	5	1	2	\N	2026-06-11 19:54:29.857815+00	2026-06-11 19:54:29.857815+00	\N	\N
84	34	2	2	1	\N	2026-06-11 19:56:54.614151+00	2026-06-11 19:56:54.614151+00	\N	\N
85	34	4	2	0	\N	2026-06-11 19:58:09.42356+00	2026-06-11 19:58:09.42356+00	\N	\N
86	34	3	2	1	\N	2026-06-11 19:58:28.964213+00	2026-06-11 19:58:28.964213+00	\N	\N
87	34	6	1	2	\N	2026-06-11 20:01:56.278424+00	2026-06-11 20:01:56.278424+00	\N	\N
88	34	8	0	2	\N	2026-06-11 20:04:56.244265+00	2026-06-11 20:04:56.244265+00	\N	\N
89	34	7	2	1	\N	2026-06-11 20:05:54.150025+00	2026-06-11 20:05:54.150025+00	\N	\N
97	34	16	2	0	\N	2026-06-11 20:54:18.782803+00	2026-06-11 20:54:18.782803+00	\N	\N
99	34	15	2	0	\N	2026-06-11 20:55:26.734733+00	2026-06-11 20:55:26.734733+00	\N	\N
101	35	2	1	1	\N	2026-06-11 21:12:45.035351+00	2026-06-11 21:12:45.035351+00	\N	\N
102	43	2	2	1	\N	2026-06-11 21:31:40.075719+00	2026-06-11 21:31:40.075719+00	\N	\N
11	9	2	2	1	\N	2026-06-04 20:52:11.711383+00	2026-06-11 22:51:54.212063+00	\N	\N
104	33	2	2	1	\N	2026-06-11 23:13:38.803358+00	2026-06-11 23:13:38.803358+00	\N	\N
105	32	2	2	0	\N	2026-06-11 23:35:57.702006+00	2026-06-11 23:35:57.702006+00	\N	\N
106	30	2	2	1	\N	2026-06-11 23:37:07.033727+00	2026-06-11 23:37:07.033727+00	\N	\N
107	46	2	2	1	\N	2026-06-11 23:43:35.727221+00	2026-06-11 23:43:35.727221+00	\N	\N
108	45	2	2	0	\N	2026-06-11 23:54:06.978936+00	2026-06-11 23:54:06.978936+00	\N	\N
111	41	2	1	1	\N	2026-06-12 00:00:30.400062+00	2026-06-12 00:00:30.400062+00	\N	\N
75	38	4	0	1	\N	2026-06-11 19:28:06.520369+00	2026-06-13 00:41:24.123178+00	\N	\N
115	31	2	1	3	\N	2026-06-12 00:18:59.660189+00	2026-06-12 00:18:59.660189+00	\N	\N
76	38	6	2	2	\N	2026-06-11 19:28:36.064735+00	2026-06-14 03:39:21.729404+00	\N	\N
118	47	2	1	1	\N	2026-06-12 00:45:25.341736+00	2026-06-12 00:45:25.341736+00	\N	\N
121	23	2	2	1	\N	2026-06-12 00:56:46.380318+00	2026-06-12 00:56:58.445743+00	\N	\N
126	42	2	1	2	\N	2026-06-12 01:09:22.6425+00	2026-06-12 01:39:44.835733+00	\N	\N
129	40	4	1	2	\N	2026-06-12 01:14:20.018797+00	2026-06-12 01:14:20.018797+00	\N	\N
79	37	4	1	2	\N	2026-06-11 19:53:31.326247+00	2026-06-12 12:44:31.803928+00	\N	\N
58	12	2	2	1	\N	2026-06-11 18:53:03.553966+00	2026-06-12 01:09:47.7362+00	\N	\N
130	40	3	1	1	\N	2026-06-12 01:14:39.321994+00	2026-06-12 01:14:39.321994+00	\N	\N
131	40	6	1	2	\N	2026-06-12 01:15:15.421751+00	2026-06-14 00:00:22.90654+00	\N	\N
16	15	4	2	1	\N	2026-06-08 00:01:51.244729+00	2026-06-12 15:28:46.660897+00	\N	\N
74	38	3	1	1	\N	2026-06-11 19:27:34.417408+00	2026-06-12 18:48:53.318142+00	\N	\N
82	37	8	0	3	\N	2026-06-11 19:54:12.517769+00	2026-06-13 16:01:23.641903+00	\N	\N
90	34	5	0	2	\N	2026-06-11 20:06:44.183611+00	2026-06-13 13:54:06.318186+00	\N	\N
17	15	6	0	2	\N	2026-06-08 00:02:11.995138+00	2026-06-13 15:50:21.325732+00	\N	\N
98	34	13	0	1	\N	2026-06-11 20:54:46.640243+00	2026-06-15 13:23:00.28494+00	\N	\N
80	37	6	1	2	\N	2026-06-11 19:53:45.441451+00	2026-06-13 16:08:24.009902+00	\N	\N
19	15	7	3	1	\N	2026-06-08 00:03:36.648616+00	2026-06-13 18:18:14.531799+00	\N	\N
100	34	20	1	1	\N	2026-06-11 20:56:08.432399+00	2026-06-16 17:03:38.76551+00	\N	\N
31	15	18	0	2	\N	2026-06-08 14:37:41.925718+00	2026-06-16 21:24:47.795569+00	\N	\N
32	15	19	2	0	\N	2026-06-08 14:37:56.714732+00	2026-06-16 23:38:02.061799+00	\N	\N
29	15	20	2	1	\N	2026-06-08 00:08:33.046246+00	2026-06-16 23:38:41.074684+00	\N	\N
34	15	22	2	1	\N	2026-06-08 14:38:40.465536+00	2026-06-17 11:03:49.255289+00	\N	\N
35	15	21	2	1	\N	2026-06-08 14:38:55.838742+00	2026-06-17 22:08:15.583344+00	\N	\N
132	29	2	2	1	\N	2026-06-12 01:18:09.357737+00	2026-06-12 01:18:09.357737+00	\N	\N
133	23	3	2	0	\N	2026-06-12 01:26:04.867847+00	2026-06-12 01:26:04.867847+00	\N	\N
244	25	14	4	0	\N	2026-06-12 18:13:30.386965+00	2026-06-12 18:13:30.386965+00	\N	\N
134	23	4	1	1	\N	2026-06-12 01:27:01.440868+00	2026-06-12 01:27:24.946467+00	\N	\N
1808	35	29	3	1	\N	2026-06-19 16:24:24.447261+00	2026-06-19 16:24:24.447261+00	\N	\N
140	48	2	1	1	\N	2026-06-12 01:53:13.867794+00	2026-06-12 01:53:13.867794+00	\N	\N
71	38	2	2	1	\N	2026-06-11 19:25:24.013888+00	2026-06-12 01:54:23.624747+00	\N	\N
142	26	3	2	1	\N	2026-06-12 02:27:49.743782+00	2026-06-12 02:27:49.743782+00	\N	\N
143	26	4	1	1	\N	2026-06-12 02:28:10.25821+00	2026-06-12 02:28:10.25821+00	\N	\N
167	28	6	0	2	\N	2026-06-12 11:50:52.523924+00	2026-06-13 13:36:59.856006+00	\N	\N
145	33	4	1	1	\N	2026-06-12 03:17:54.329005+00	2026-06-12 03:23:54.461808+00	\N	\N
144	33	3	1	0	\N	2026-06-12 03:17:14.993084+00	2026-06-12 03:24:01.815742+00	\N	\N
150	30	3	1	0	\N	2026-06-12 04:01:15.451037+00	2026-06-12 18:02:57.503612+00	\N	\N
151	30	4	2	1	\N	2026-06-12 04:01:28.371198+00	2026-06-12 04:01:37.927537+00	\N	\N
155	47	3	2	1	\N	2026-06-12 04:05:56.034294+00	2026-06-12 04:05:56.034294+00	\N	\N
162	10	6	0	2	\N	2026-06-12 10:49:55.63272+00	2026-06-12 10:49:55.63272+00	\N	\N
163	9	3	1	0	\N	2026-06-12 11:27:11.528152+00	2026-06-12 11:27:11.528152+00	\N	\N
164	9	4	0	2	\N	2026-06-12 11:27:18.93662+00	2026-06-12 11:27:18.93662+00	\N	\N
165	9	6	1	3	\N	2026-06-12 11:27:29.496162+00	2026-06-12 11:27:29.496162+00	\N	\N
166	28	3	2	0	\N	2026-06-12 11:50:18.595727+00	2026-06-12 11:50:18.595727+00	\N	\N
169	45	3	2	0	\N	2026-06-12 11:58:29.631721+00	2026-06-12 11:58:29.631721+00	\N	\N
170	45	4	1	2	\N	2026-06-12 11:58:42.899291+00	2026-06-12 11:58:42.899291+00	\N	\N
171	45	6	2	2	\N	2026-06-12 12:02:27.703745+00	2026-06-12 12:02:27.703745+00	\N	\N
168	28	4	3	1	\N	2026-06-12 11:51:23.797824+00	2026-06-12 12:09:09.892777+00	\N	\N
173	16	4	2	2	\N	2026-06-12 12:21:03.904816+00	2026-06-12 12:21:03.904816+00	\N	\N
201	54	3	1	0	\N	2026-06-12 17:52:51.148257+00	2026-06-12 18:03:01.671721+00	\N	\N
160	10	3	2	1	\N	2026-06-12 10:49:20.525564+00	2026-06-12 13:08:20.846563+00	\N	\N
161	10	4	1	2	\N	2026-06-12 10:49:43.276058+00	2026-06-12 13:08:31.912834+00	\N	\N
179	31	3	2	0	\N	2026-06-12 13:21:20.134216+00	2026-06-12 13:21:20.134216+00	\N	\N
180	31	4	1	2	\N	2026-06-12 13:21:35.216736+00	2026-06-12 13:21:35.216736+00	\N	\N
181	14	3	2	1	\N	2026-06-12 13:26:43.802729+00	2026-06-12 13:26:43.802729+00	\N	\N
182	14	4	1	2	\N	2026-06-12 13:26:51.495815+00	2026-06-12 13:26:51.495815+00	\N	\N
183	24	3	2	1	\N	2026-06-12 13:54:29.044719+00	2026-06-12 13:54:29.044719+00	\N	\N
184	24	4	2	0	\N	2026-06-12 13:54:37.572723+00	2026-06-12 13:54:37.572723+00	\N	\N
185	13	3	1	0	\N	2026-06-12 14:00:13.811598+00	2026-06-12 14:00:13.811598+00	\N	\N
221	54	20	1	0	\N	2026-06-12 17:57:53.352692+00	2026-06-16 14:38:30.62218+00	\N	\N
189	11	3	2	0	\N	2026-06-12 15:36:57.761721+00	2026-06-12 15:36:57.761721+00	\N	\N
188	11	4	2	1	\N	2026-06-12 15:36:50.761189+00	2026-06-12 15:37:01.477372+00	\N	\N
191	32	3	1	0	\N	2026-06-12 15:48:08.419559+00	2026-06-12 15:48:08.419559+00	\N	\N
192	32	4	2	1	\N	2026-06-12 15:48:17.894717+00	2026-06-12 15:48:17.894717+00	\N	\N
193	43	3	1	0	\N	2026-06-12 16:37:47.32025+00	2026-06-12 16:37:47.32025+00	\N	\N
194	43	4	2	1	\N	2026-06-12 16:38:18.862039+00	2026-06-12 16:38:18.862039+00	\N	\N
195	18	3	2	1	\N	2026-06-12 16:41:11.167466+00	2026-06-12 16:41:11.167466+00	\N	\N
196	18	4	1	2	\N	2026-06-12 16:41:31.139535+00	2026-06-12 16:41:31.139535+00	\N	\N
197	44	3	2	0	\N	2026-06-12 17:36:09.630747+00	2026-06-12 17:36:09.630747+00	\N	\N
198	46	3	2	2	\N	2026-06-12 17:46:40.120145+00	2026-06-12 17:46:40.120145+00	\N	\N
199	42	3	2	0	\N	2026-06-12 17:47:06.268786+00	2026-06-12 17:47:06.268786+00	\N	\N
200	42	4	1	2	\N	2026-06-12 17:47:12.050302+00	2026-06-12 17:47:12.050302+00	\N	\N
239	25	11	3	1	\N	2026-06-12 18:12:45.425032+00	2026-06-12 18:12:56.03094+00	\N	\N
242	25	12	2	0	\N	2026-06-12 18:13:10.391788+00	2026-06-12 18:13:10.391788+00	\N	\N
205	54	8	1	0	\N	2026-06-12 17:55:08.138596+00	2026-06-12 17:55:08.138596+00	\N	\N
206	54	7	2	1	\N	2026-06-12 17:55:16.571185+00	2026-06-12 17:55:16.571185+00	\N	\N
207	54	5	0	1	\N	2026-06-12 17:55:21.983553+00	2026-06-12 17:55:21.983553+00	\N	\N
208	54	6	0	1	\N	2026-06-12 17:55:28.890612+00	2026-06-12 17:55:28.890612+00	\N	\N
209	54	10	2	0	\N	2026-06-12 17:55:37.902477+00	2026-06-12 17:55:37.902477+00	\N	\N
210	54	11	1	0	\N	2026-06-12 17:55:42.724492+00	2026-06-12 17:55:42.724492+00	\N	\N
211	54	9	0	1	\N	2026-06-12 17:55:57.43422+00	2026-06-12 17:55:57.43422+00	\N	\N
212	54	12	1	0	\N	2026-06-12 17:56:47.284114+00	2026-06-12 17:56:47.284114+00	\N	\N
213	54	14	2	0	\N	2026-06-12 17:56:58.843006+00	2026-06-12 17:57:02.467147+00	\N	\N
215	54	16	1	0	\N	2026-06-12 17:57:09.053154+00	2026-06-12 17:57:09.053154+00	\N	\N
216	54	13	0	1	\N	2026-06-12 17:57:12.392548+00	2026-06-12 17:57:12.392548+00	\N	\N
217	54	15	0	1	\N	2026-06-12 17:57:20.444159+00	2026-06-12 17:57:20.444159+00	\N	\N
218	54	17	2	0	\N	2026-06-12 17:57:34.362481+00	2026-06-12 17:57:34.362481+00	\N	\N
219	54	18	0	1	\N	2026-06-12 17:57:42.152713+00	2026-06-12 17:57:42.152713+00	\N	\N
220	54	19	2	0	\N	2026-06-12 17:57:46.604811+00	2026-06-12 17:57:46.604811+00	\N	\N
222	48	4	1	1	\N	2026-06-12 17:59:28.347113+00	2026-06-12 17:59:28.347113+00	\N	\N
223	48	3	2	1	\N	2026-06-12 17:59:42.991152+00	2026-06-12 17:59:42.991152+00	\N	\N
202	54	4	1	2	\N	2026-06-12 17:54:42.321303+00	2026-06-12 18:03:03.820722+00	\N	\N
228	50	3	2	1	\N	2026-06-12 18:05:45.332514+00	2026-06-12 18:05:45.332514+00	\N	\N
232	25	4	1	1	\N	2026-06-12 18:11:29.570533+00	2026-06-12 18:11:29.570533+00	\N	\N
233	25	3	1	0	\N	2026-06-12 18:11:35.098623+00	2026-06-12 18:11:35.098623+00	\N	\N
234	25	8	0	2	\N	2026-06-12 18:11:50.987371+00	2026-06-12 18:11:50.987371+00	\N	\N
235	25	7	1	2	\N	2026-06-12 18:12:01.44471+00	2026-06-12 18:12:01.44471+00	\N	\N
236	25	5	0	2	\N	2026-06-12 18:12:08.4072+00	2026-06-12 18:12:08.4072+00	\N	\N
237	25	6	1	1	\N	2026-06-12 18:12:25.47043+00	2026-06-12 18:12:25.47043+00	\N	\N
238	25	10	5	0	\N	2026-06-12 18:12:38.580692+00	2026-06-12 18:12:38.580692+00	\N	\N
243	25	9	0	2	\N	2026-06-12 18:13:15.321621+00	2026-06-12 18:13:15.321621+00	\N	\N
245	25	16	3	0	\N	2026-06-12 18:13:37.697761+00	2026-06-12 18:13:37.697761+00	\N	\N
246	25	13	0	2	\N	2026-06-12 18:13:43.207719+00	2026-06-12 18:13:43.207719+00	\N	\N
247	25	15	1	1	\N	2026-06-12 18:13:54.336749+00	2026-06-12 18:13:54.336749+00	\N	\N
249	25	17	3	0	\N	2026-06-12 18:14:26.265285+00	2026-06-12 18:14:26.265285+00	\N	\N
250	25	18	1	2	\N	2026-06-12 18:14:35.227221+00	2026-06-12 18:14:35.227221+00	\N	\N
248	25	19	3	0	\N	2026-06-12 18:14:19.759912+00	2026-06-12 18:14:38.963513+00	\N	\N
252	25	20	1	1	\N	2026-06-12 18:14:49.272729+00	2026-06-12 18:14:49.272729+00	\N	\N
255	41	3	1	0	\N	2026-06-12 18:24:02.351571+00	2026-06-12 18:24:02.351571+00	\N	\N
230	51	3	2	0	\N	2026-06-12 18:11:01.530297+00	2026-06-12 18:19:32.502187+00	\N	\N
256	35	3	2	0	\N	2026-06-12 18:30:37.388267+00	2026-06-12 18:30:37.388267+00	\N	\N
157	36	3	1	1	\N	2026-06-12 10:29:29.858109+00	2026-06-12 18:55:51.799397+00	\N	\N
257	35	4	2	1	\N	2026-06-12 18:30:45.958469+00	2026-06-12 22:27:40.051753+00	\N	\N
229	50	4	1	2	\N	2026-06-12 18:06:08.792739+00	2026-06-12 21:35:26.243347+00	\N	\N
156	47	4	1	2	\N	2026-06-12 04:08:19.351461+00	2026-06-13 00:44:51.046637+00	\N	\N
231	51	4	1	2	\N	2026-06-12 18:11:26.312982+00	2026-06-12 22:37:01.47472+00	\N	\N
146	33	6	1	1	\N	2026-06-12 03:17:57.796721+00	2026-06-14 04:31:36.13173+00	\N	\N
159	36	6	1	1	\N	2026-06-12 10:30:46.883298+00	2026-06-13 16:57:07.700133+00	\N	\N
154	30	6	1	1	\N	2026-06-12 04:01:51.514511+00	2026-06-13 18:13:48.829009+00	\N	\N
258	29	3	2	1	\N	2026-06-12 18:34:28.499722+00	2026-06-12 18:34:28.499722+00	\N	\N
260	12	3	1	0	\N	2026-06-12 18:48:13.221095+00	2026-06-12 18:48:13.221095+00	\N	\N
158	36	4	1	2	\N	2026-06-12 10:30:14.182425+00	2026-06-12 18:55:58.213032+00	\N	\N
265	16	3	1	1	\N	2026-06-12 18:58:01.233724+00	2026-06-12 18:59:00.193998+00	\N	\N
267	55	3	0	1	\N	2026-06-12 18:59:14.561026+00	2026-06-12 18:59:14.561026+00	\N	\N
268	55	4	2	1	\N	2026-06-12 19:09:49.327078+00	2026-06-12 19:09:54.834669+00	\N	\N
270	41	4	2	1	\N	2026-06-12 19:30:51.51922+00	2026-06-12 19:30:51.51922+00	\N	\N
271	27	4	2	2	\N	2026-06-12 19:31:06.391241+00	2026-06-12 19:31:06.391241+00	\N	\N
272	56	4	1	2	\N	2026-06-12 21:29:24.281534+00	2026-06-12 21:29:24.281534+00	\N	\N
279	13	4	2	1	\N	2026-06-12 21:55:04.017577+00	2026-06-12 21:55:04.017577+00	\N	\N
286	29	4	1	2	\N	2026-06-12 22:50:28.008076+00	2026-06-12 22:50:28.008076+00	\N	\N
287	9	8	0	3	\N	2026-06-12 23:36:06.352364+00	2026-06-12 23:36:06.352364+00	\N	\N
290	44	4	1	2	\N	2026-06-12 23:36:41.716933+00	2026-06-12 23:36:41.716933+00	\N	\N
369	31	6	1	2	\N	2026-06-13 14:42:45.532488+00	2026-06-13 14:42:45.532488+00	\N	\N
371	31	5	1	3	\N	2026-06-13 14:44:05.424775+00	2026-06-13 14:44:05.424775+00	\N	\N
298	47	8	1	1	\N	2026-06-13 00:46:27.522452+00	2026-06-13 00:46:41.01722+00	\N	\N
303	46	4	2	1	\N	2026-06-13 00:46:50.030748+00	2026-06-13 00:46:50.030748+00	\N	\N
304	12	4	1	1	\N	2026-06-13 00:57:38.619764+00	2026-06-13 00:57:38.619764+00	\N	\N
305	45	8	2	1	\N	2026-06-13 01:17:38.220731+00	2026-06-13 01:17:38.220731+00	\N	\N
306	45	7	3	1	\N	2026-06-13 01:17:50.140031+00	2026-06-13 01:17:50.140031+00	\N	\N
307	45	5	1	1	\N	2026-06-13 01:18:20.812589+00	2026-06-13 01:18:20.812589+00	\N	\N
308	36	8	1	2	\N	2026-06-13 01:47:07.557816+00	2026-06-13 01:47:07.557816+00	\N	\N
288	9	7	2	1	\N	2026-06-12 23:36:28.620655+00	2026-06-13 02:51:31.844269+00	\N	\N
289	9	5	0	4	\N	2026-06-12 23:36:35.933851+00	2026-06-13 02:51:42.167215+00	\N	\N
312	9	10	5	0	\N	2026-06-13 02:52:06.178828+00	2026-06-13 02:52:06.178828+00	\N	\N
316	9	14	6	0	\N	2026-06-13 02:52:55.746423+00	2026-06-13 02:52:55.746423+00	\N	\N
317	9	16	2	0	\N	2026-06-13 02:53:07.704717+00	2026-06-13 02:53:07.704717+00	\N	\N
318	9	13	0	2	\N	2026-06-13 02:53:19.124197+00	2026-06-13 02:53:19.124197+00	\N	\N
319	9	15	1	1	\N	2026-06-13 02:53:33.015941+00	2026-06-13 02:53:33.015941+00	\N	\N
324	9	23	3	0	\N	2026-06-13 02:54:45.133729+00	2026-06-13 02:54:45.133729+00	\N	\N
325	9	22	3	1	\N	2026-06-13 02:54:54.699243+00	2026-06-13 02:54:54.699243+00	\N	\N
326	9	21	2	0	\N	2026-06-13 02:55:08.016735+00	2026-06-13 02:55:08.016735+00	\N	\N
328	40	8	1	2	\N	2026-06-13 02:58:09.727486+00	2026-06-13 02:58:09.727486+00	\N	\N
329	40	5	0	3	\N	2026-06-13 02:59:31.069424+00	2026-06-13 02:59:31.069424+00	\N	\N
330	40	7	2	2	\N	2026-06-13 02:59:35.150933+00	2026-06-13 03:00:15.383947+00	\N	\N
333	47	7	2	0	\N	2026-06-13 03:07:52.298545+00	2026-06-13 03:07:52.298545+00	\N	\N
334	47	5	0	2	\N	2026-06-13 03:08:39.318322+00	2026-06-13 03:08:39.318322+00	\N	\N
335	30	7	3	0	\N	2026-06-13 03:08:52.852488+00	2026-06-13 03:08:52.852488+00	\N	\N
336	47	6	1	1	\N	2026-06-13 03:09:20.144038+00	2026-06-13 03:09:20.144038+00	\N	\N
338	13	8	0	2	\N	2026-06-13 03:12:40.894839+00	2026-06-13 03:12:40.894839+00	\N	\N
339	13	7	3	1	\N	2026-06-13 03:13:02.158122+00	2026-06-13 03:13:02.158122+00	\N	\N
340	13	5	1	2	\N	2026-06-13 03:13:37.183644+00	2026-06-13 03:13:37.183644+00	\N	\N
341	30	5	1	2	\N	2026-06-13 03:16:29.77289+00	2026-06-13 03:16:29.77289+00	\N	\N
343	33	5	1	2	\N	2026-06-13 03:18:06.816178+00	2026-06-13 03:18:06.816178+00	\N	\N
344	33	7	4	0	\N	2026-06-13 03:18:14.401571+00	2026-06-13 03:18:14.401571+00	\N	\N
345	33	8	2	1	\N	2026-06-13 03:18:20.306392+00	2026-06-13 03:18:20.306392+00	\N	\N
347	10	8	0	2	\N	2026-06-13 04:11:32.979109+00	2026-06-13 04:11:32.979109+00	\N	\N
354	28	5	0	2	\N	2026-06-13 13:43:57.314343+00	2026-06-13 16:07:36.735971+00	\N	\N
356	56	8	2	1	\N	2026-06-13 14:05:31.545054+00	2026-06-13 14:05:31.545054+00	\N	\N
1809	35	31	2	1	\N	2026-06-19 16:25:03.212132+00	2026-06-19 16:25:03.212132+00	\N	\N
360	48	8	0	2	\N	2026-06-13 14:19:43.695158+00	2026-06-13 14:19:51.25867+00	\N	\N
362	48	7	2	1	\N	2026-06-13 14:21:09.683757+00	2026-06-13 14:21:09.683757+00	\N	\N
363	48	5	0	2	\N	2026-06-13 14:21:35.360598+00	2026-06-13 14:21:35.360598+00	\N	\N
364	48	6	1	1	\N	2026-06-13 14:22:02.294667+00	2026-06-13 14:22:02.294667+00	\N	\N
365	35	8	0	1	\N	2026-06-13 14:39:59.325801+00	2026-06-13 14:39:59.325801+00	\N	\N
366	35	5	0	2	\N	2026-06-13 14:40:39.138768+00	2026-06-13 14:40:39.138768+00	\N	\N
367	35	6	0	2	\N	2026-06-13 14:40:52.922723+00	2026-06-13 14:40:52.922723+00	\N	\N
368	35	7	2	1	\N	2026-06-13 14:41:25.132856+00	2026-06-13 14:41:25.132856+00	\N	\N
372	31	7	2	1	\N	2026-06-13 14:44:28.872207+00	2026-06-13 14:44:28.872207+00	\N	\N
373	27	7	2	1	\N	2026-06-13 14:45:22.659909+00	2026-06-13 14:45:22.659909+00	\N	\N
374	27	8	0	3	\N	2026-06-13 14:45:33.356158+00	2026-06-13 14:45:33.356158+00	\N	\N
375	27	5	1	2	\N	2026-06-13 14:45:48.018726+00	2026-06-13 14:45:48.018726+00	\N	\N
376	27	6	2	3	\N	2026-06-13 14:45:52.365835+00	2026-06-13 14:45:58.258941+00	\N	\N
378	27	10	5	0	\N	2026-06-13 14:46:14.694692+00	2026-06-13 14:46:14.694692+00	\N	\N
379	27	11	1	2	\N	2026-06-13 14:46:24.899793+00	2026-06-13 14:46:24.899793+00	\N	\N
381	27	12	1	2	\N	2026-06-13 14:47:07.052417+00	2026-06-13 14:47:07.052417+00	\N	\N
382	27	14	4	0	\N	2026-06-13 14:47:25.090764+00	2026-06-13 14:47:25.090764+00	\N	\N
383	27	16	3	1	\N	2026-06-13 14:47:32.815391+00	2026-06-13 14:47:32.815391+00	\N	\N
384	27	13	0	2	\N	2026-06-13 14:47:39.131921+00	2026-06-13 14:47:39.131921+00	\N	\N
389	55	5	0	2	\N	2026-06-13 14:50:34.506168+00	2026-06-13 15:14:57.086109+00	\N	\N
386	55	8	0	1	\N	2026-06-13 14:48:18.399914+00	2026-06-13 15:16:54.940797+00	\N	\N
388	55	6	1	2	\N	2026-06-13 14:50:32.264449+00	2026-06-13 15:16:09.240174+00	\N	\N
291	38	8	0	2	\N	2026-06-13 00:05:54.998035+00	2026-06-13 15:51:54.584756+00	\N	\N
292	38	7	2	0	\N	2026-06-13 00:06:18.805685+00	2026-06-13 15:51:59.68617+00	\N	\N
293	38	5	0	1	\N	2026-06-13 00:06:36.135407+00	2026-06-13 15:52:00.56226+00	\N	\N
350	28	8	0	2	\N	2026-06-13 13:35:04.00172+00	2026-06-13 16:07:13.883322+00	\N	\N
349	10	5	1	2	\N	2026-06-13 04:11:54.693093+00	2026-06-13 16:17:00.848644+00	\N	\N
348	10	7	2	1	\N	2026-06-13 04:11:47.555354+00	2026-06-13 16:16:50.469967+00	\N	\N
309	36	7	3	2	\N	2026-06-13 01:47:18.729306+00	2026-06-13 16:41:19.883644+00	\N	\N
337	30	8	0	1	\N	2026-06-13 03:12:07.00388+00	2026-06-13 18:13:40.831566+00	\N	\N
352	28	7	2	3	\N	2026-06-13 13:37:22.449196+00	2026-06-13 20:42:29.31244+00	\N	\N
370	31	8	1	2	\N	2026-06-13 14:43:20.056778+00	2026-06-13 18:43:28.575174+00	\N	\N
357	56	7	2	1	\N	2026-06-13 14:07:29.452818+00	2026-06-13 21:42:35.012766+00	\N	\N
358	56	5	0	2	\N	2026-06-13 14:08:25.710841+00	2026-06-14 00:20:37.841317+00	\N	\N
313	9	11	2	2	\N	2026-06-13 02:52:18.972772+00	2026-06-14 18:54:49.698106+00	\N	\N
342	13	6	1	3	\N	2026-06-13 03:17:49.719217+00	2026-06-14 01:56:12.86406+00	\N	\N
315	9	12	1	0	\N	2026-06-13 02:52:40.843777+00	2026-06-14 18:55:08.693166+00	\N	\N
385	27	15	1	0	\N	2026-06-13 14:47:45.597728+00	2026-06-15 22:41:28.077207+00	\N	\N
380	27	9	1	2	\N	2026-06-13 14:46:53.83472+00	2026-06-14 21:33:46.389444+00	\N	\N
314	9	9	0	2	\N	2026-06-13 02:52:27.385+00	2026-06-14 22:01:26.320649+00	\N	\N
320	9	17	3	1	\N	2026-06-13 02:53:49.532844+00	2026-06-16 04:06:39.590938+00	\N	\N
321	9	18	1	3	\N	2026-06-13 02:53:58.981178+00	2026-06-16 04:06:52.763733+00	\N	\N
323	9	20	1	1	\N	2026-06-13 02:54:21.985085+00	2026-06-16 04:07:17.693535+00	\N	\N
322	9	19	2	0	\N	2026-06-13 02:54:11.34672+00	2026-06-16 04:08:28.699232+00	\N	\N
327	9	24	1	3	\N	2026-06-13 02:55:13.345614+00	2026-06-18 00:07:27.134989+00	\N	\N
390	51	7	2	1	\N	2026-06-13 15:00:26.401308+00	2026-06-13 15:00:26.401308+00	\N	\N
392	42	6	0	1	\N	2026-06-13 15:06:20.31569+00	2026-06-13 15:06:20.31569+00	\N	\N
393	42	5	0	2	\N	2026-06-13 15:06:31.978275+00	2026-06-13 15:06:31.978275+00	\N	\N
394	42	8	0	2	\N	2026-06-13 15:06:42.415472+00	2026-06-13 15:06:42.415472+00	\N	\N
395	42	7	2	1	\N	2026-06-13 15:06:51.970573+00	2026-06-13 15:06:51.970573+00	\N	\N
396	24	8	0	2	\N	2026-06-13 15:11:33.489188+00	2026-06-13 15:11:33.489188+00	\N	\N
399	24	6	0	1	\N	2026-06-13 15:12:41.482728+00	2026-06-13 15:12:41.482728+00	\N	\N
397	24	7	1	1	\N	2026-06-13 15:11:43.034861+00	2026-06-13 15:13:22.88142+00	\N	\N
387	55	7	2	1	\N	2026-06-13 14:49:30.452721+00	2026-06-13 15:14:09.323371+00	\N	\N
405	11	8	1	2	\N	2026-06-13 15:15:20.61013+00	2026-06-13 15:15:20.61013+00	\N	\N
407	11	7	3	2	\N	2026-06-13 15:16:29.104228+00	2026-06-13 15:16:29.104228+00	\N	\N
410	12	6	0	2	\N	2026-06-13 15:20:12.282115+00	2026-06-13 15:20:12.282115+00	\N	\N
411	12	8	0	3	\N	2026-06-13 15:20:19.439342+00	2026-06-13 15:20:19.439342+00	\N	\N
412	12	7	2	1	\N	2026-06-13 15:20:28.58862+00	2026-06-13 15:20:28.58862+00	\N	\N
413	12	5	0	3	\N	2026-06-13 15:20:37.423721+00	2026-06-13 15:20:37.423721+00	\N	\N
419	58	8	3	1	\N	2026-06-13 15:56:16.231576+00	2026-06-13 15:56:16.231576+00	\N	\N
420	14	8	0	2	\N	2026-06-13 15:58:56.033715+00	2026-06-13 15:58:56.033715+00	\N	\N
421	14	5	1	2	\N	2026-06-13 15:59:08.596491+00	2026-06-13 15:59:08.596491+00	\N	\N
423	14	6	0	2	\N	2026-06-13 15:59:30.069974+00	2026-06-13 15:59:30.069974+00	\N	\N
81	37	7	3	2	\N	2026-06-11 19:54:06.176449+00	2026-06-13 16:01:02.806254+00	\N	\N
429	32	7	2	0	\N	2026-06-13 16:12:37.105429+00	2026-06-13 16:12:37.105429+00	\N	\N
431	32	5	1	2	\N	2026-06-13 16:13:42.98444+00	2026-06-13 16:13:42.98444+00	\N	\N
432	32	6	2	2	\N	2026-06-13 16:14:11.31772+00	2026-06-13 16:14:11.31772+00	\N	\N
430	32	8	0	1	\N	2026-06-13 16:12:42.640395+00	2026-06-13 16:14:33.761489+00	\N	\N
437	44	8	0	2	\N	2026-06-13 16:27:24.303527+00	2026-06-13 16:27:40.157838+00	\N	\N
440	36	5	0	2	\N	2026-06-13 16:41:40.559266+00	2026-06-13 16:41:40.559266+00	\N	\N
442	41	8	0	2	\N	2026-06-13 17:11:44.190782+00	2026-06-13 17:11:44.190782+00	\N	\N
443	23	8	0	1	\N	2026-06-13 17:46:09.86816+00	2026-06-13 17:46:09.86816+00	\N	\N
444	16	8	0	2	\N	2026-06-13 18:00:22.386828+00	2026-06-13 18:01:41.119731+00	\N	\N
445	16	7	2	1	\N	2026-06-13 18:00:45.354138+00	2026-06-13 18:01:44.639586+00	\N	\N
446	16	5	0	3	\N	2026-06-13 18:01:07.656548+00	2026-06-13 18:01:49.357599+00	\N	\N
447	16	6	1	2	\N	2026-06-13 18:01:23.222802+00	2026-06-13 18:01:55.550474+00	\N	\N
456	18	8	1	0	\N	2026-06-13 18:36:22.781329+00	2026-06-13 18:36:22.781329+00	\N	\N
457	18	7	3	1	\N	2026-06-13 18:36:34.423849+00	2026-06-13 18:36:34.423849+00	\N	\N
458	18	5	0	2	\N	2026-06-13 18:36:51.279018+00	2026-06-13 18:36:51.279018+00	\N	\N
459	18	6	1	1	\N	2026-06-13 18:37:04.196031+00	2026-06-13 18:37:04.196031+00	\N	\N
460	29	8	2	1	\N	2026-06-13 18:37:36.395026+00	2026-06-13 18:37:36.395026+00	\N	\N
461	29	7	3	1	\N	2026-06-13 18:38:12.10226+00	2026-06-13 18:38:12.10226+00	\N	\N
508	45	9	1	1	\N	2026-06-14 00:29:55.929675+00	2026-06-14 00:31:00.689973+00	\N	\N
462	50	8	0	2	\N	2026-06-13 18:40:58.352282+00	2026-06-13 18:41:13.48421+00	\N	\N
466	43	8	0	1	\N	2026-06-13 18:43:24.121578+00	2026-06-13 18:43:24.121578+00	\N	\N
468	43	7	2	1	\N	2026-06-13 18:43:34.68196+00	2026-06-13 18:43:34.68196+00	\N	\N
469	43	5	0	2	\N	2026-06-13 18:43:41.689934+00	2026-06-13 18:43:41.689934+00	\N	\N
470	43	6	0	1	\N	2026-06-13 18:43:48.172094+00	2026-06-13 18:43:48.172094+00	\N	\N
471	46	8	0	3	\N	2026-06-13 18:45:00.821719+00	2026-06-13 18:45:00.821719+00	\N	\N
472	50	7	2	1	\N	2026-06-13 18:46:41.31372+00	2026-06-13 18:46:41.31372+00	\N	\N
473	50	5	0	2	\N	2026-06-13 18:47:01.644581+00	2026-06-13 18:47:01.644581+00	\N	\N
474	50	6	1	2	\N	2026-06-13 18:47:09.387824+00	2026-06-13 18:47:09.387824+00	\N	\N
475	59	8	2	1	\N	2026-06-13 18:52:43.950915+00	2026-06-13 18:52:43.950915+00	\N	\N
477	59	7	3	0	\N	2026-06-13 18:53:12.486741+00	2026-06-13 18:53:12.486741+00	\N	\N
478	59	6	2	1	\N	2026-06-13 18:53:47.031672+00	2026-06-13 18:53:47.031672+00	\N	\N
391	51	8	0	1	\N	2026-06-13 15:01:26.722234+00	2026-06-13 18:57:51.638547+00	\N	\N
480	44	7	3	1	\N	2026-06-13 19:20:31.148911+00	2026-06-13 19:20:31.148911+00	\N	\N
481	26	7	2	1	\N	2026-06-13 20:00:05.837318+00	2026-06-13 20:00:05.837318+00	\N	\N
482	26	5	1	3	\N	2026-06-13 20:00:23.288737+00	2026-06-13 20:00:23.288737+00	\N	\N
483	26	6	2	2	\N	2026-06-13 20:00:38.257521+00	2026-06-13 20:00:38.257521+00	\N	\N
422	14	7	2	1	\N	2026-06-13 15:59:17.812721+00	2026-06-13 21:02:16.335592+00	\N	\N
489	51	5	0	1	\N	2026-06-13 21:17:31.026172+00	2026-06-13 21:17:31.026172+00	\N	\N
490	46	7	2	1	\N	2026-06-13 21:25:21.295603+00	2026-06-13 21:25:21.295603+00	\N	\N
512	46	5	0	2	\N	2026-06-14 00:36:25.688296+00	2026-06-14 00:36:25.688296+00	\N	\N
491	23	7	3	1	\N	2026-06-13 21:40:44.33156+00	2026-06-13 21:41:01.17123+00	\N	\N
513	29	5	1	2	\N	2026-06-14 00:42:02.415375+00	2026-06-14 00:42:02.415375+00	\N	\N
495	58	7	2	0	\N	2026-06-13 21:49:23.856585+00	2026-06-13 21:56:57.390925+00	\N	\N
498	41	5	0	2	\N	2026-06-13 22:32:32.622722+00	2026-06-13 22:32:32.622722+00	\N	\N
499	41	6	1	1	\N	2026-06-13 22:32:58.621433+00	2026-06-13 22:32:58.621433+00	\N	\N
476	59	5	0	1	\N	2026-06-13 18:53:04.018722+00	2026-06-13 22:37:06.25935+00	\N	\N
501	44	5	0	2	\N	2026-06-13 23:58:50.04282+00	2026-06-13 23:58:50.04282+00	\N	\N
503	58	5	0	2	\N	2026-06-14 00:19:19.072026+00	2026-06-14 00:19:19.072026+00	\N	\N
398	24	5	0	2	\N	2026-06-13 15:11:54.513845+00	2026-06-14 00:23:51.894498+00	\N	\N
509	45	10	4	0	\N	2026-06-14 00:30:27.429416+00	2026-06-14 00:30:27.429416+00	\N	\N
510	45	11	1	2	\N	2026-06-14 00:30:50.412955+00	2026-06-14 00:30:50.412955+00	\N	\N
515	58	6	0	1	\N	2026-06-14 00:44:59.864832+00	2026-06-14 00:44:59.864832+00	\N	\N
516	23	5	0	2	\N	2026-06-14 00:56:40.187856+00	2026-06-14 00:56:40.187856+00	\N	\N
359	56	6	0	1	\N	2026-06-13 14:14:17.76468+00	2026-06-14 01:22:50.153247+00	\N	\N
519	37	10	3	0	\N	2026-06-14 01:45:10.638115+00	2026-06-14 01:45:10.638115+00	\N	\N
529	11	11	3	1	\N	2026-06-14 02:47:45.429717+00	2026-06-14 02:47:45.429717+00	\N	\N
530	38	10	2	0	\N	2026-06-14 02:59:38.440982+00	2026-06-14 02:59:38.440982+00	\N	\N
527	11	6	1	2	\N	2026-06-14 02:47:07.28205+00	2026-06-14 02:47:07.28205+00	\N	\N
528	11	10	3	1	\N	2026-06-14 02:47:32.042802+00	2026-06-14 02:47:32.042802+00	\N	\N
536	46	6	1	2	\N	2026-06-14 03:10:03.467851+00	2026-06-14 03:10:14.199783+00	\N	\N
137	23	6	0	2	\N	2026-06-12 01:27:55.153183+00	2026-06-14 03:17:16.535366+00	\N	\N
520	37	9	2	1	\N	2026-06-14 01:45:39.960431+00	2026-06-14 22:05:58.932837+00	\N	\N
535	31	10	5	0	\N	2026-06-14 03:09:21.319761+00	2026-06-14 03:14:58.198248+00	\N	\N
543	44	6	0	2	\N	2026-06-14 03:26:45.663027+00	2026-06-14 03:26:45.663027+00	\N	\N
514	29	6	1	2	\N	2026-06-14 00:42:14.048475+00	2026-06-14 04:01:34.123599+00	\N	\N
550	30	10	3	0	\N	2026-06-14 04:25:33.881439+00	2026-06-14 04:25:33.881439+00	\N	\N
551	30	11	2	2	\N	2026-06-14 04:27:21.077895+00	2026-06-14 04:27:21.077895+00	\N	\N
552	30	9	1	2	\N	2026-06-14 04:28:15.487131+00	2026-06-14 04:28:15.487131+00	\N	\N
555	30	12	2	0	\N	2026-06-14 04:32:04.230164+00	2026-06-14 04:32:04.230164+00	\N	\N
507	45	12	2	1	\N	2026-06-14 00:29:53.128126+00	2026-06-14 19:21:19.535901+00	\N	\N
518	56	10	3	0	\N	2026-06-14 01:31:47.041305+00	2026-06-14 15:36:54.892295+00	\N	\N
533	38	12	2	0	\N	2026-06-14 03:01:09.589442+00	2026-06-14 19:23:28.137726+00	\N	\N
531	38	11	2	1	\N	2026-06-14 02:59:47.761727+00	2026-06-14 19:22:44.201282+00	\N	\N
532	38	9	1	1	\N	2026-06-14 03:00:06.453196+00	2026-06-14 22:58:29.848011+00	\N	\N
521	37	12	4	1	\N	2026-06-14 01:45:57.962723+00	2026-06-15 01:18:23.109844+00	\N	\N
556	13	10	3	0	\N	2026-06-14 05:53:45.338343+00	2026-06-14 05:53:45.338343+00	\N	\N
488	51	6	2	0	\N	2026-06-13 21:17:15.33833+00	2026-06-14 05:56:41.654712+00	\N	\N
559	33	12	2	1	\N	2026-06-14 06:09:30.150563+00	2026-06-14 06:09:30.150563+00	\N	\N
560	33	10	2	1	\N	2026-06-14 06:09:40.791745+00	2026-06-14 06:09:40.791745+00	\N	\N
561	33	11	2	2	\N	2026-06-14 06:09:50.944186+00	2026-06-14 06:09:50.944186+00	\N	\N
563	47	10	3	0	\N	2026-06-14 06:15:10.382451+00	2026-06-14 06:15:10.382451+00	\N	\N
564	47	11	2	1	\N	2026-06-14 06:19:21.259399+00	2026-06-14 06:19:21.259399+00	\N	\N
566	47	12	2	0	\N	2026-06-14 06:22:21.243757+00	2026-06-14 06:22:21.243757+00	\N	\N
672	56	11	1	0	\N	2026-06-14 18:36:40.590723+00	2026-06-14 19:28:01.849958+00	\N	\N
568	10	10	3	0	\N	2026-06-14 08:06:36.431102+00	2026-06-14 08:06:36.431102+00	\N	\N
569	10	11	2	1	\N	2026-06-14 08:06:58.387682+00	2026-06-14 08:06:58.387682+00	\N	\N
572	40	10	3	0	\N	2026-06-14 12:12:01.663717+00	2026-06-14 12:16:24.265732+00	\N	\N
574	40	11	2	1	\N	2026-06-14 12:18:23.925577+00	2026-06-14 12:18:23.925577+00	\N	\N
575	40	9	0	1	\N	2026-06-14 12:21:45.434734+00	2026-06-14 12:21:52.553912+00	\N	\N
577	40	12	2	1	\N	2026-06-14 12:23:18.328567+00	2026-06-14 12:23:18.328567+00	\N	\N
578	28	9	0	1	\N	2026-06-14 13:25:01.900053+00	2026-06-14 13:25:01.900053+00	\N	\N
580	28	10	3	0	\N	2026-06-14 13:25:12.045723+00	2026-06-14 13:25:12.045723+00	\N	\N
581	28	11	1	2	\N	2026-06-14 13:25:23.877211+00	2026-06-14 13:25:23.877211+00	\N	\N
582	14	10	5	0	\N	2026-06-14 13:41:55.210306+00	2026-06-14 13:41:55.210306+00	\N	\N
1810	51	32	2	1	\N	2026-06-19 16:51:19.755048+00	2026-06-19 16:51:19.755048+00	\N	\N
585	14	12	2	0	\N	2026-06-14 13:42:39.70596+00	2026-06-14 13:42:39.70596+00	\N	\N
586	32	10	3	2	\N	2026-06-14 13:55:42.501305+00	2026-06-14 13:55:42.501305+00	\N	\N
587	32	11	2	1	\N	2026-06-14 13:56:22.626641+00	2026-06-14 13:56:22.626641+00	\N	\N
588	32	9	2	2	\N	2026-06-14 13:57:32.788643+00	2026-06-14 13:57:32.788643+00	\N	\N
589	32	12	2	1	\N	2026-06-14 13:57:56.46436+00	2026-06-14 13:57:56.46436+00	\N	\N
590	26	10	4	0	\N	2026-06-14 13:59:23.079722+00	2026-06-14 13:59:23.079722+00	\N	\N
591	26	11	1	2	\N	2026-06-14 13:59:57.507464+00	2026-06-14 13:59:57.507464+00	\N	\N
592	26	9	1	2	\N	2026-06-14 14:00:27.315724+00	2026-06-14 14:00:27.315724+00	\N	\N
593	26	12	2	0	\N	2026-06-14 14:00:42.805202+00	2026-06-14 14:00:42.805202+00	\N	\N
594	35	10	4	0	\N	2026-06-14 14:16:24.749221+00	2026-06-14 14:16:24.749221+00	\N	\N
595	35	11	0	2	\N	2026-06-14 14:16:33.045295+00	2026-06-14 14:16:33.045295+00	\N	\N
596	35	9	0	2	\N	2026-06-14 14:16:40.383563+00	2026-06-14 14:16:40.383563+00	\N	\N
598	18	10	3	0	\N	2026-06-14 14:34:53.088531+00	2026-06-14 14:34:53.088531+00	\N	\N
558	50	10	4	0	\N	2026-06-14 06:00:16.896804+00	2026-06-14 14:34:56.933019+00	\N	\N
600	18	11	2	1	\N	2026-06-14 14:35:54.567528+00	2026-06-14 14:35:54.567528+00	\N	\N
601	18	12	2	0	\N	2026-06-14 14:35:54.640786+00	2026-06-14 14:35:54.640786+00	\N	\N
602	18	9	0	1	\N	2026-06-14 14:35:54.847628+00	2026-06-14 14:35:54.847628+00	\N	\N
606	36	9	1	2	\N	2026-06-14 14:36:36.136302+00	2026-06-14 14:36:36.136302+00	\N	\N
607	36	12	2	2	\N	2026-06-14 14:37:01.121638+00	2026-06-14 14:37:01.121638+00	\N	\N
608	36	10	4	0	\N	2026-06-14 14:37:53.383978+00	2026-06-14 14:37:53.383978+00	\N	\N
609	36	11	2	1	\N	2026-06-14 14:38:59.162861+00	2026-06-14 14:38:59.162861+00	\N	\N
610	37	11	1	1	\N	2026-06-14 14:54:32.542468+00	2026-06-14 14:54:32.542468+00	\N	\N
603	50	9	1	2	\N	2026-06-14 14:36:05.883009+00	2026-06-14 14:57:09.826209+00	\N	\N
570	10	9	1	2	\N	2026-06-14 08:07:27.120431+00	2026-06-14 21:57:38.075357+00	\N	\N
615	24	10	4	0	\N	2026-06-14 15:04:56.973744+00	2026-06-14 15:04:56.973744+00	\N	\N
616	24	11	2	1	\N	2026-06-14 15:05:22.555192+00	2026-06-14 15:05:22.555192+00	\N	\N
617	24	9	1	1	\N	2026-06-14 15:05:34.598576+00	2026-06-14 15:05:34.598576+00	\N	\N
618	24	12	1	0	\N	2026-06-14 15:05:51.992234+00	2026-06-14 15:05:51.992234+00	\N	\N
619	58	10	4	0	\N	2026-06-14 15:05:55.01498+00	2026-06-14 15:09:14.100587+00	\N	\N
621	59	10	3	0	\N	2026-06-14 15:11:41.851524+00	2026-06-14 15:11:41.851524+00	\N	\N
622	58	11	2	1	\N	2026-06-14 15:11:49.032347+00	2026-06-14 15:11:49.032347+00	\N	\N
623	55	10	3	0	\N	2026-06-14 15:31:18.170428+00	2026-06-14 15:31:18.170428+00	\N	\N
626	55	12	2	1	\N	2026-06-14 15:32:38.583693+00	2026-06-14 15:34:05.769354+00	\N	\N
625	55	9	1	2	\N	2026-06-14 15:31:59.786628+00	2026-06-14 15:34:09.29975+00	\N	\N
624	55	11	2	2	\N	2026-06-14 15:31:35.50905+00	2026-06-14 15:34:12.333751+00	\N	\N
632	44	10	4	1	\N	2026-06-14 15:37:11.193749+00	2026-06-14 15:37:11.193749+00	\N	\N
634	46	10	4	0	\N	2026-06-14 16:17:40.675419+00	2026-06-14 16:17:40.675419+00	\N	\N
633	51	10	3	0	\N	2026-06-14 16:17:27.068204+00	2026-06-14 16:17:55.541415+00	\N	\N
637	42	10	2	0	\N	2026-06-14 16:21:24.233339+00	2026-06-14 16:21:24.233339+00	\N	\N
638	42	11	1	2	\N	2026-06-14 16:21:28.696927+00	2026-06-14 16:21:28.696927+00	\N	\N
642	13	12	2	0	\N	2026-06-14 16:32:23.75872+00	2026-06-14 16:32:23.75872+00	\N	\N
640	13	11	2	1	\N	2026-06-14 16:23:56.99334+00	2026-06-14 16:33:36.233044+00	\N	\N
565	47	9	2	1	\N	2026-06-14 06:22:01.999291+00	2026-06-14 22:34:47.982735+00	\N	\N
645	23	10	3	0	\N	2026-06-14 16:37:44.295901+00	2026-06-14 16:37:44.295901+00	\N	\N
646	23	11	2	0	\N	2026-06-14 16:37:49.030834+00	2026-06-14 16:38:00.153944+00	\N	\N
648	48	10	3	0	\N	2026-06-14 16:43:06.39577+00	2026-06-14 16:43:06.39577+00	\N	\N
649	48	11	2	1	\N	2026-06-14 16:43:33.105519+00	2026-06-14 16:43:33.105519+00	\N	\N
650	48	9	1	1	\N	2026-06-14 16:43:50.128951+00	2026-06-14 16:43:50.128951+00	\N	\N
651	48	12	2	1	\N	2026-06-14 16:44:18.595598+00	2026-06-14 16:44:18.595598+00	\N	\N
652	12	10	3	1	\N	2026-06-14 16:45:22.353417+00	2026-06-14 16:45:22.353417+00	\N	\N
653	41	10	3	0	\N	2026-06-14 16:45:38.643723+00	2026-06-14 16:45:38.643723+00	\N	\N
654	43	10	3	0	\N	2026-06-14 16:49:00.824997+00	2026-06-14 16:49:00.824997+00	\N	\N
655	43	11	0	2	\N	2026-06-14 16:49:08.177794+00	2026-06-14 16:49:08.177794+00	\N	\N
656	43	9	0	2	\N	2026-06-14 16:49:28.075296+00	2026-06-14 16:49:38.175961+00	\N	\N
659	43	12	1	0	\N	2026-06-14 16:49:53.14549+00	2026-06-14 16:49:53.14549+00	\N	\N
660	16	10	4	0	\N	2026-06-14 16:57:32.977053+00	2026-06-14 16:57:36.130484+00	\N	\N
662	16	11	2	1	\N	2026-06-14 16:57:48.54796+00	2026-06-14 16:58:43.74225+00	\N	\N
663	16	9	0	2	\N	2026-06-14 16:57:57.88736+00	2026-06-14 16:58:47.651107+00	\N	\N
664	16	12	2	1	\N	2026-06-14 16:58:28.999969+00	2026-06-14 16:58:51.110103+00	\N	\N
636	42	12	2	0	\N	2026-06-14 16:21:20.391989+00	2026-06-15 01:24:52.253563+00	\N	\N
669	59	11	2	1	\N	2026-06-14 17:44:43.815966+00	2026-06-14 17:44:43.815966+00	\N	\N
670	51	11	2	1	\N	2026-06-14 18:05:36.230709+00	2026-06-14 18:05:36.230709+00	\N	\N
579	28	12	2	0	\N	2026-06-14 13:25:02.035295+00	2026-06-14 18:06:48.209924+00	\N	\N
673	56	9	1	0	\N	2026-06-14 18:36:49.452726+00	2026-06-14 18:36:49.452726+00	\N	\N
675	11	9	1	2	\N	2026-06-14 18:43:08.653289+00	2026-06-14 18:43:08.653289+00	\N	\N
676	11	12	3	1	\N	2026-06-14 18:43:21.538119+00	2026-06-14 18:43:21.538119+00	\N	\N
562	33	9	2	1	\N	2026-06-14 06:09:56.989373+00	2026-06-14 22:34:53.970177+00	\N	\N
683	31	11	2	1	\N	2026-06-14 19:02:31.419188+00	2026-06-14 19:22:51.616219+00	\N	\N
674	56	12	2	1	\N	2026-06-14 18:37:02.146796+00	2026-06-14 19:28:14.180226+00	\N	\N
571	10	12	3	1	\N	2026-06-14 08:07:56.035723+00	2026-06-14 21:57:57.523567+00	\N	\N
641	13	9	1	3	\N	2026-06-14 16:24:08.444337+00	2026-06-14 22:01:59.907674+00	\N	\N
639	42	9	2	0	\N	2026-06-14 16:21:38.33422+00	2026-06-14 22:11:14.809931+00	\N	\N
584	14	9	1	1	\N	2026-06-14 13:42:32.08449+00	2026-06-14 22:13:49.23381+00	\N	\N
597	35	12	1	0	\N	2026-06-14 14:16:47.27311+00	2026-06-15 01:14:01.485915+00	\N	\N
604	50	12	3	1	\N	2026-06-14 14:36:14.45627+00	2026-06-15 01:47:36.050559+00	\N	\N
684	44	11	2	2	\N	2026-06-14 19:03:07.302734+00	2026-06-14 19:03:07.302734+00	\N	\N
583	14	11	2	1	\N	2026-06-14 13:42:22.76799+00	2026-06-14 19:13:42.338136+00	\N	\N
688	41	11	2	1	\N	2026-06-14 19:14:53.894298+00	2026-06-14 19:14:53.894298+00	\N	\N
691	12	9	0	2	\N	2026-06-14 19:20:59.126978+00	2026-06-14 19:20:59.126978+00	\N	\N
692	12	11	1	1	\N	2026-06-14 19:21:17.817863+00	2026-06-14 19:21:17.817863+00	\N	\N
694	12	12	2	0	\N	2026-06-14 19:21:31.263177+00	2026-06-14 19:21:31.263177+00	\N	\N
700	58	9	1	1	\N	2026-06-14 19:25:32.381721+00	2026-06-14 19:25:32.381721+00	\N	\N
701	58	12	1	0	\N	2026-06-14 19:27:05.248224+00	2026-06-14 19:27:05.248224+00	\N	\N
704	46	11	2	1	\N	2026-06-14 19:37:10.266186+00	2026-06-14 19:37:10.266186+00	\N	\N
605	50	11	2	2	\N	2026-06-14 14:36:20.491725+00	2026-06-14 19:53:38.255522+00	\N	\N
708	29	9	1	2	\N	2026-06-14 20:35:27.870519+00	2026-06-14 20:35:27.870519+00	\N	\N
709	29	12	2	1	\N	2026-06-14 20:36:00.860764+00	2026-06-14 20:36:00.860764+00	\N	\N
710	41	9	0	1	\N	2026-06-14 21:05:38.498339+00	2026-06-14 21:05:38.498339+00	\N	\N
713	23	9	1	2	\N	2026-06-14 21:38:38.363587+00	2026-06-14 21:38:38.363587+00	\N	\N
721	31	9	2	2	\N	2026-06-14 22:08:14.986914+00	2026-06-14 22:08:14.986914+00	\N	\N
722	31	12	2	1	\N	2026-06-14 22:10:59.105746+00	2026-06-14 22:10:59.105746+00	\N	\N
725	51	9	1	1	\N	2026-06-14 22:12:38.974838+00	2026-06-14 22:12:38.974838+00	\N	\N
732	46	9	1	3	\N	2026-06-14 22:36:30.161833+00	2026-06-14 22:36:30.161833+00	\N	\N
728	59	9	2	2	\N	2026-06-14 22:22:50.372305+00	2026-06-14 22:54:36.236903+00	\N	\N
738	66	9	1	2	\N	2026-06-08 00:05:12.787285+00	2026-06-08 00:05:12.787285+00	\N	\N
739	51	12	1	0	\N	2026-06-14 23:22:15.253727+00	2026-06-14 23:22:15.253727+00	\N	\N
740	44	12	3	1	\N	2026-06-14 23:30:36.568756+00	2026-06-14 23:30:36.568756+00	\N	\N
741	41	12	2	1	\N	2026-06-14 23:55:28.479894+00	2026-06-14 23:55:28.479894+00	\N	\N
742	45	14	3	0	\N	2026-06-15 00:26:24.984484+00	2026-06-15 00:29:36.821799+00	\N	\N
747	38	14	4	0	\N	2026-06-15 00:46:51.663026+00	2026-06-15 00:46:51.663026+00	\N	\N
748	38	13	0	2	\N	2026-06-15 00:47:56.6895+00	2026-06-15 00:47:56.6895+00	\N	\N
749	38	16	1	0	\N	2026-06-15 00:48:54.229464+00	2026-06-15 00:48:54.229464+00	\N	\N
750	38	15	1	1	\N	2026-06-15 00:49:16.235099+00	2026-06-15 00:49:16.235099+00	\N	\N
752	51	16	2	1	\N	2026-06-15 01:11:25.617842+00	2026-06-15 01:11:25.617842+00	\N	\N
756	59	12	1	0	\N	2026-06-15 01:17:12.513104+00	2026-06-15 01:17:12.513104+00	\N	\N
737	66	12	2	0	\N	2026-06-14 23:04:14.815325+00	2026-06-15 01:30:54.367932+00	\N	\N
744	45	16	3	1	\N	2026-06-15 00:29:58.815721+00	2026-06-15 13:12:43.415353+00	\N	\N
745	45	13	1	2	\N	2026-06-15 00:30:13.056796+00	2026-06-15 13:13:29.832129+00	\N	\N
746	45	15	2	1	\N	2026-06-15 00:30:31.914586+00	2026-06-15 13:14:52.064151+00	\N	\N
766	23	12	2	1	\N	2026-06-15 01:55:13.769087+00	2026-06-15 01:55:13.769087+00	\N	\N
705	46	12	2	0	\N	2026-06-14 19:37:46.189375+00	2026-06-15 01:57:21.213514+00	\N	\N
768	40	14	2	1	\N	2026-06-15 02:43:44.836977+00	2026-06-15 02:43:44.836977+00	\N	\N
769	30	14	3	1	\N	2026-06-15 02:43:53.879194+00	2026-06-15 02:43:53.879194+00	\N	\N
770	30	16	2	1	\N	2026-06-15 02:44:09.83372+00	2026-06-15 02:44:09.83372+00	\N	\N
772	30	15	1	2	\N	2026-06-15 02:44:26.938075+00	2026-06-15 02:44:26.938075+00	\N	\N
773	40	16	2	2	\N	2026-06-15 02:45:58.846179+00	2026-06-15 02:45:58.846179+00	\N	\N
774	40	13	1	3	\N	2026-06-15 02:46:02.256763+00	2026-06-15 02:46:11.272528+00	\N	\N
776	40	15	1	2	\N	2026-06-15 02:46:34.054679+00	2026-06-15 02:46:34.054679+00	\N	\N
751	51	14	4	0	\N	2026-06-15 01:09:46.606694+00	2026-06-15 03:08:43.432814+00	\N	\N
780	55	14	3	0	\N	2026-06-15 03:26:04.087248+00	2026-06-15 03:26:04.087248+00	\N	\N
781	55	16	2	2	\N	2026-06-15 03:27:36.228773+00	2026-06-15 03:27:36.228773+00	\N	\N
782	55	13	1	3	\N	2026-06-15 03:28:14.957379+00	2026-06-15 03:28:14.957379+00	\N	\N
783	55	15	1	1	\N	2026-06-15 03:28:51.414733+00	2026-06-15 03:28:51.414733+00	\N	\N
784	10	14	5	0	\N	2026-06-15 03:59:59.614574+00	2026-06-15 03:59:59.614574+00	\N	\N
785	10	16	3	1	\N	2026-06-15 04:00:12.721335+00	2026-06-15 04:00:12.721335+00	\N	\N
786	10	13	1	2	\N	2026-06-15 04:00:27.365965+00	2026-06-15 04:00:27.365965+00	\N	\N
834	50	15	1	1	\N	2026-06-15 14:54:57.916131+00	2026-06-15 14:54:57.916131+00	\N	\N
839	48	14	3	2	\N	2026-06-15 15:03:22.087767+00	2026-06-15 15:04:27.599171+00	\N	\N
794	42	14	5	0	\N	2026-06-15 04:18:59.844481+00	2026-06-15 04:18:59.844481+00	\N	\N
795	13	14	4	1	\N	2026-06-15 04:37:08.791246+00	2026-06-15 04:37:08.791246+00	\N	\N
791	37	16	3	1	\N	2026-06-15 04:18:20.323723+00	2026-06-15 18:20:15.091925+00	\N	\N
798	13	13	0	3	\N	2026-06-15 04:37:30.02038+00	2026-06-15 04:37:30.02038+00	\N	\N
799	29	14	3	0	\N	2026-06-15 09:02:15.549077+00	2026-06-15 09:02:15.549077+00	\N	\N
800	29	16	3	1	\N	2026-06-15 09:02:27.094081+00	2026-06-15 09:02:27.094081+00	\N	\N
801	29	13	0	3	\N	2026-06-15 09:02:35.787059+00	2026-06-15 09:02:35.787059+00	\N	\N
802	28	14	4	0	\N	2026-06-15 11:54:18.99049+00	2026-06-15 11:54:18.99049+00	\N	\N
803	28	16	1	2	\N	2026-06-15 11:54:29.014989+00	2026-06-15 11:54:29.014989+00	\N	\N
804	28	13	1	2	\N	2026-06-15 11:54:36.712937+00	2026-06-15 11:54:36.712937+00	\N	\N
805	28	15	2	0	\N	2026-06-15 11:54:47.652039+00	2026-06-15 11:54:47.652039+00	\N	\N
807	35	14	5	0	\N	2026-06-15 12:32:31.734867+00	2026-06-15 12:32:31.734867+00	\N	\N
808	35	16	3	0	\N	2026-06-15 12:32:38.366108+00	2026-06-15 12:32:38.366108+00	\N	\N
809	35	13	0	3	\N	2026-06-15 12:32:45.685529+00	2026-06-15 12:32:45.685529+00	\N	\N
816	16	14	4	0	\N	2026-06-15 13:33:53.611799+00	2026-06-15 13:33:53.611799+00	\N	\N
817	16	16	3	1	\N	2026-06-15 13:34:04.596146+00	2026-06-15 13:34:04.596146+00	\N	\N
818	16	13	1	2	\N	2026-06-15 13:34:15.401577+00	2026-06-15 13:34:15.401577+00	\N	\N
819	16	15	2	2	\N	2026-06-15 13:34:31.28412+00	2026-06-15 13:34:31.28412+00	\N	\N
820	26	14	5	0	\N	2026-06-15 14:25:48.086133+00	2026-06-15 14:25:48.086133+00	\N	\N
821	26	16	1	1	\N	2026-06-15 14:26:01.522205+00	2026-06-15 14:26:01.522205+00	\N	\N
822	26	13	1	2	\N	2026-06-15 14:26:20.341797+00	2026-06-15 14:26:20.341797+00	\N	\N
824	36	14	2	1	\N	2026-06-15 14:29:06.962839+00	2026-06-15 14:29:06.962839+00	\N	\N
825	36	16	3	0	\N	2026-06-15 14:29:12.647466+00	2026-06-15 14:29:12.647466+00	\N	\N
826	36	13	1	1	\N	2026-06-15 14:29:20.940775+00	2026-06-15 14:29:20.940775+00	\N	\N
827	36	15	0	2	\N	2026-06-15 14:29:35.603089+00	2026-06-15 14:29:35.603089+00	\N	\N
828	36	18	2	1	\N	2026-06-15 14:30:24.128063+00	2026-06-15 14:30:24.128063+00	\N	\N
829	36	19	2	0	\N	2026-06-15 14:30:33.811073+00	2026-06-15 14:30:33.811073+00	\N	\N
831	36	17	3	0	\N	2026-06-15 14:31:06.23846+00	2026-06-15 14:31:06.23846+00	\N	\N
823	26	15	0	3	\N	2026-06-15 14:26:35.167651+00	2026-06-16 00:09:15.374727+00	\N	\N
835	50	13	0	1	\N	2026-06-15 14:54:59.655924+00	2026-06-15 14:57:30.337087+00	\N	\N
836	50	16	2	1	\N	2026-06-15 14:55:01.952887+00	2026-06-15 14:57:39.149945+00	\N	\N
843	32	14	3	1	\N	2026-06-15 15:08:28.234425+00	2026-06-15 15:08:28.234425+00	\N	\N
788	37	14	5	1	\N	2026-06-15 04:17:04.423594+00	2026-06-15 15:40:39.625645+00	\N	\N
792	37	13	0	2	\N	2026-06-15 04:18:31.686905+00	2026-06-15 21:18:52.604233+00	\N	\N
779	50	14	6	0	\N	2026-06-15 03:24:02.158278+00	2026-06-15 15:55:00.836888+00	\N	\N
806	51	13	1	1	\N	2026-06-15 12:29:16.831926+00	2026-06-15 21:48:46.332678+00	\N	\N
771	30	13	1	2	\N	2026-06-15 02:44:15.688586+00	2026-06-15 17:59:40.109612+00	\N	\N
796	13	16	4	1	\N	2026-06-15 04:37:12.60766+00	2026-06-15 18:02:05.358857+00	\N	\N
810	35	15	1	1	\N	2026-06-15 12:32:55.094581+00	2026-06-15 23:22:31.0528+00	\N	\N
789	37	15	2	1	\N	2026-06-15 04:18:04.858067+00	2026-06-16 00:53:04.980067+00	\N	\N
787	10	15	1	1	\N	2026-06-15 04:00:35.247738+00	2026-06-16 00:42:53.058457+00	\N	\N
830	36	20	2	1	\N	2026-06-15 14:30:44.964727+00	2026-06-17 03:04:30.58287+00	\N	\N
844	32	16	1	2	\N	2026-06-15 15:09:16.479414+00	2026-06-15 15:09:16.479414+00	\N	\N
846	58	14	3	0	\N	2026-06-15 15:09:39.93444+00	2026-06-15 15:09:39.93444+00	\N	\N
847	32	13	2	3	\N	2026-06-15 15:09:47.69763+00	2026-06-15 15:09:47.69763+00	\N	\N
849	58	16	2	0	\N	2026-06-15 15:12:07.71917+00	2026-06-15 15:12:07.71917+00	\N	\N
850	56	14	2	0	\N	2026-06-15 15:12:53.9013+00	2026-06-15 15:12:53.9013+00	\N	\N
852	66	14	3	1	\N	2026-06-15 15:13:23.889718+00	2026-06-15 15:13:23.889718+00	\N	\N
853	33	14	4	1	\N	2026-06-15 15:13:28.358112+00	2026-06-15 15:13:28.358112+00	\N	\N
845	41	14	5	0	\N	2026-06-15 15:09:20.835187+00	2026-06-15 15:13:35.227106+00	\N	\N
855	33	16	2	1	\N	2026-06-15 15:13:59.97529+00	2026-06-15 15:13:59.97529+00	\N	\N
859	56	13	2	1	\N	2026-06-15 15:14:56.381004+00	2026-06-15 15:14:59.969743+00	\N	\N
861	66	15	1	1	\N	2026-06-15 15:15:09.202626+00	2026-06-15 15:15:09.202626+00	\N	\N
902	24	15	2	1	\N	2026-06-15 16:03:52.300201+00	2026-06-15 22:45:45.339254+00	\N	\N
851	56	16	2	1	\N	2026-06-15 15:13:00.227692+00	2026-06-15 15:16:26.244668+00	\N	\N
864	58	13	0	2	\N	2026-06-15 15:16:40.224413+00	2026-06-15 15:16:40.224413+00	\N	\N
865	59	14	4	1	\N	2026-06-15 15:17:28.869621+00	2026-06-15 15:17:28.869621+00	\N	\N
814	56	15	1	0	\N	2026-06-15 13:17:07.534164+00	2026-06-15 15:18:29.397177+00	\N	\N
868	58	15	2	0	\N	2026-06-15 15:19:58.618754+00	2026-06-15 15:19:58.618754+00	\N	\N
870	14	16	2	1	\N	2026-06-15 15:20:25.200723+00	2026-06-15 15:20:25.200723+00	\N	\N
871	31	16	2	1	\N	2026-06-15 15:21:07.113766+00	2026-06-15 15:21:07.113766+00	\N	\N
872	11	14	4	1	\N	2026-06-15 15:21:52.013342+00	2026-06-15 15:21:52.013342+00	\N	\N
873	11	13	0	2	\N	2026-06-15 15:22:12.31514+00	2026-06-15 15:22:12.31514+00	\N	\N
874	11	15	1	3	\N	2026-06-15 15:22:23.900476+00	2026-06-15 15:22:23.900476+00	\N	\N
875	44	14	4	0	\N	2026-06-15 15:23:17.203798+00	2026-06-15 15:23:17.203798+00	\N	\N
876	44	16	3	1	\N	2026-06-15 15:23:28.592081+00	2026-06-15 15:23:28.592081+00	\N	\N
877	14	13	1	2	\N	2026-06-15 15:23:30.154206+00	2026-06-15 15:23:30.154206+00	\N	\N
878	14	15	1	1	\N	2026-06-15 15:23:35.134829+00	2026-06-15 15:23:35.134829+00	\N	\N
879	44	13	0	2	\N	2026-06-15 15:23:37.881334+00	2026-06-15 15:23:37.881334+00	\N	\N
869	14	14	6	1	\N	2026-06-15 15:20:17.305325+00	2026-06-15 15:23:43.02272+00	\N	\N
883	47	14	3	1	\N	2026-06-15 15:40:55.086124+00	2026-06-15 15:40:55.086124+00	\N	\N
884	23	14	4	0	\N	2026-06-15 15:41:15.281004+00	2026-06-15 15:41:15.281004+00	\N	\N
885	31	13	1	3	\N	2026-06-15 15:41:49.588651+00	2026-06-15 15:41:49.588651+00	\N	\N
886	31	15	1	0	\N	2026-06-15 15:43:07.305953+00	2026-06-15 15:43:07.305953+00	\N	\N
887	47	16	1	2	\N	2026-06-15 15:43:09.332722+00	2026-06-15 15:43:09.332722+00	\N	\N
952	38	17	2	0	\N	2026-06-15 23:20:19.907137+00	2026-06-15 23:20:19.907137+00	\N	\N
889	46	14	5	1	\N	2026-06-15 15:44:38.814497+00	2026-06-15 15:45:47.289731+00	\N	\N
892	47	15	3	1	\N	2026-06-15 15:47:17.052196+00	2026-06-15 15:47:17.052196+00	\N	\N
953	38	18	0	1	\N	2026-06-15 23:20:30.844038+00	2026-06-15 23:20:30.844038+00	\N	\N
866	31	14	3	1	\N	2026-06-15 15:18:11.862011+00	2026-06-15 15:58:29.615774+00	\N	\N
858	33	15	2	2	\N	2026-06-15 15:14:55.315937+00	2026-06-15 16:00:03.269012+00	\N	\N
900	24	16	3	1	\N	2026-06-15 16:00:21.897047+00	2026-06-15 16:00:21.897047+00	\N	\N
901	24	13	1	2	\N	2026-06-15 16:01:19.993631+00	2026-06-15 16:01:19.993631+00	\N	\N
903	43	15	0	1	\N	2026-06-15 16:32:06.785212+00	2026-06-15 16:32:06.785212+00	\N	\N
904	43	13	0	3	\N	2026-06-15 16:32:14.45182+00	2026-06-15 16:32:19.672812+00	\N	\N
906	43	16	2	1	\N	2026-06-15 16:32:29.282791+00	2026-06-15 16:32:29.282791+00	\N	\N
856	33	13	1	2	\N	2026-06-15 15:14:11.776966+00	2026-06-15 17:43:46.584936+00	\N	\N
910	41	16	2	1	\N	2026-06-15 17:46:34.752115+00	2026-06-15 17:46:34.752115+00	\N	\N
911	41	13	0	1	\N	2026-06-15 17:47:00.844044+00	2026-06-15 17:47:00.844044+00	\N	\N
912	41	15	1	0	\N	2026-06-15 17:47:10.662566+00	2026-06-15 17:47:10.662566+00	\N	\N
915	13	15	2	1	\N	2026-06-15 18:03:29.631906+00	2026-06-15 18:03:29.631906+00	\N	\N
916	18	16	2	1	\N	2026-06-15 18:06:06.919461+00	2026-06-15 18:06:06.919461+00	\N	\N
917	18	13	0	2	\N	2026-06-15 18:06:17.40473+00	2026-06-15 18:06:17.40473+00	\N	\N
918	18	15	0	1	\N	2026-06-15 18:06:32.733341+00	2026-06-15 18:06:32.733341+00	\N	\N
919	59	16	2	1	\N	2026-06-15 18:14:18.368561+00	2026-06-15 18:14:18.368561+00	\N	\N
921	48	16	2	1	\N	2026-06-15 18:26:01.798684+00	2026-06-15 18:26:01.798684+00	\N	\N
922	48	13	0	2	\N	2026-06-15 18:26:20.977351+00	2026-06-15 18:26:20.977351+00	\N	\N
923	48	15	1	1	\N	2026-06-15 18:26:33.180428+00	2026-06-15 18:26:33.180428+00	\N	\N
924	66	16	1	1	\N	2026-06-15 18:26:57.441278+00	2026-06-15 18:26:57.441278+00	\N	\N
954	38	19	2	1	\N	2026-06-15 23:20:51.628978+00	2026-06-15 23:20:51.628978+00	\N	\N
955	38	20	1	1	\N	2026-06-15 23:21:20.225271+00	2026-06-15 23:21:20.225271+00	\N	\N
925	66	13	1	2	\N	2026-06-15 18:27:41.112675+00	2026-06-15 18:28:17.119598+00	\N	\N
929	46	16	3	1	\N	2026-06-15 18:30:37.360604+00	2026-06-15 18:30:37.360604+00	\N	\N
930	12	16	3	1	\N	2026-06-15 18:35:34.09509+00	2026-06-15 18:43:57.163722+00	\N	\N
932	29	15	0	2	\N	2026-06-15 19:00:37.642656+00	2026-06-15 19:00:37.642656+00	\N	\N
848	32	15	2	2	\N	2026-06-15 15:10:22.807024+00	2026-06-15 19:23:25.76173+00	\N	\N
934	42	15	1	2	\N	2026-06-15 19:36:16.038495+00	2026-06-15 19:36:16.038495+00	\N	\N
935	42	13	0	2	\N	2026-06-15 19:36:25.095973+00	2026-06-15 19:36:25.095973+00	\N	\N
888	47	13	1	1	\N	2026-06-15 15:43:57.052214+00	2026-06-15 20:14:16.044407+00	\N	\N
938	23	13	1	3	\N	2026-06-15 20:43:00.76724+00	2026-06-15 20:43:00.76724+00	\N	\N
941	46	13	2	2	\N	2026-06-15 21:40:49.128773+00	2026-06-15 21:40:49.128773+00	\N	\N
942	51	15	1	0	\N	2026-06-15 21:42:32.213282+00	2026-06-15 21:42:32.213282+00	\N	\N
946	59	13	1	2	\N	2026-06-15 21:48:34.7723+00	2026-06-15 21:48:34.7723+00	\N	\N
947	12	13	0	1	\N	2026-06-15 21:48:46.131396+00	2026-06-15 21:48:46.131396+00	\N	\N
980	27	17	3	1	\N	2026-06-16 02:00:36.620819+00	2026-06-16 02:00:36.620819+00	\N	\N
958	44	15	0	1	\N	2026-06-15 23:52:26.169735+00	2026-06-15 23:52:26.169735+00	\N	\N
964	12	15	1	1	\N	2026-06-16 00:10:43.474744+00	2026-06-16 00:10:43.474744+00	\N	\N
965	24	17	2	1	\N	2026-06-16 00:29:05.5621+00	2026-06-16 00:29:05.5621+00	\N	\N
966	24	18	0	2	\N	2026-06-16 00:29:16.173456+00	2026-06-16 00:29:16.173456+00	\N	\N
967	24	19	2	1	\N	2026-06-16 00:29:23.760388+00	2026-06-16 00:29:23.760388+00	\N	\N
968	24	20	1	0	\N	2026-06-16 00:29:33.55539+00	2026-06-16 00:29:33.55539+00	\N	\N
981	27	18	0	2	\N	2026-06-16 02:00:55.454223+00	2026-06-16 02:00:55.454223+00	\N	\N
1811	46	32	3	1	\N	2026-06-19 17:12:29.21131+00	2026-06-19 17:12:29.21131+00	\N	\N
973	40	18	1	2	\N	2026-06-16 00:43:22.482195+00	2026-06-16 00:43:22.482195+00	\N	\N
974	40	19	3	1	\N	2026-06-16 00:43:35.615341+00	2026-06-16 00:43:35.615341+00	\N	\N
975	40	20	2	0	\N	2026-06-16 00:43:52.704974+00	2026-06-16 00:43:52.704974+00	\N	\N
969	46	15	4	1	\N	2026-06-16 00:41:47.34465+00	2026-06-16 00:44:27.982417+00	\N	\N
979	23	15	1	2	\N	2026-06-16 00:53:43.718605+00	2026-06-16 00:53:43.718605+00	\N	\N
982	27	19	3	1	\N	2026-06-16 02:01:06.27473+00	2026-06-16 02:01:25.788847+00	\N	\N
984	27	20	0	0	\N	2026-06-16 02:01:34.612506+00	2026-06-16 02:01:34.612506+00	\N	\N
985	30	17	3	0	\N	2026-06-16 02:23:21.303253+00	2026-06-16 02:23:21.303253+00	\N	\N
987	30	20	1	1	\N	2026-06-16 02:23:52.960405+00	2026-06-16 02:23:52.960405+00	\N	\N
989	47	17	3	1	\N	2026-06-16 02:26:03.641989+00	2026-06-16 02:26:03.641989+00	\N	\N
990	47	18	1	1	\N	2026-06-16 02:31:20.245942+00	2026-06-16 02:31:20.245942+00	\N	\N
992	47	20	2	0	\N	2026-06-16 02:41:53.947249+00	2026-06-16 02:41:53.947249+00	\N	\N
986	30	19	3	1	\N	2026-06-16 02:23:41.083134+00	2026-06-16 21:53:57.829682+00	\N	\N
988	30	18	1	3	\N	2026-06-16 02:24:06.913075+00	2026-06-16 21:53:16.149752+00	\N	\N
991	47	19	3	1	\N	2026-06-16 02:39:07.58479+00	2026-06-17 00:24:19.615335+00	\N	\N
1812	50	32	2	1	\N	2026-06-19 17:26:57.269607+00	2026-06-19 17:26:57.269607+00	\N	\N
998	33	18	1	2	\N	2026-06-16 03:12:07.395788+00	2026-06-16 03:12:07.395788+00	\N	\N
999	33	19	2	1	\N	2026-06-16 03:12:43.958608+00	2026-06-16 03:12:43.958608+00	\N	\N
1000	33	20	2	1	\N	2026-06-16 03:13:26.74505+00	2026-06-16 03:13:26.74505+00	\N	\N
997	33	17	3	0	\N	2026-06-16 03:11:01.062169+00	2026-06-16 03:13:37.307895+00	\N	\N
1089	44	18	0	2	\N	2026-06-16 15:35:00.835096+00	2026-06-16 15:35:00.835096+00	\N	\N
1002	55	17	3	2	\N	2026-06-16 03:18:07.717615+00	2026-06-16 03:19:25.341462+00	\N	\N
1005	55	18	2	2	\N	2026-06-16 03:20:02.813984+00	2026-06-16 03:20:02.813984+00	\N	\N
1016	29	19	3	1	\N	2026-06-16 05:27:14.244256+00	2026-06-17 00:23:28.355399+00	\N	\N
1008	55	20	1	1	\N	2026-06-16 03:22:47.112622+00	2026-06-16 03:22:47.112622+00	\N	\N
1017	16	17	2	1	\N	2026-06-16 10:55:15.295848+00	2026-06-16 10:55:15.295848+00	\N	\N
1020	16	20	2	0	\N	2026-06-16 10:56:01.092294+00	2026-06-16 10:56:01.092294+00	\N	\N
1021	32	17	2	1	\N	2026-06-16 12:29:27.639197+00	2026-06-16 12:29:27.639197+00	\N	\N
1022	32	18	2	2	\N	2026-06-16 12:30:14.307124+00	2026-06-16 12:30:14.307124+00	\N	\N
1023	32	19	3	2	\N	2026-06-16 12:30:36.96506+00	2026-06-16 12:30:36.96506+00	\N	\N
1024	32	20	1	1	\N	2026-06-16 12:31:13.077726+00	2026-06-16 12:31:13.077726+00	\N	\N
1025	14	17	3	1	\N	2026-06-16 12:37:23.615835+00	2026-06-16 12:37:23.615835+00	\N	\N
1026	14	18	0	2	\N	2026-06-16 12:37:33.06737+00	2026-06-16 12:37:33.06737+00	\N	\N
1027	14	19	3	1	\N	2026-06-16 12:37:38.955103+00	2026-06-16 12:37:38.955103+00	\N	\N
1028	14	20	2	1	\N	2026-06-16 12:37:44.391664+00	2026-06-16 12:37:44.391664+00	\N	\N
1029	14	24	0	3	\N	2026-06-16 12:37:57.936516+00	2026-06-16 12:37:57.936516+00	\N	\N
1030	14	21	1	1	\N	2026-06-16 12:38:07.851484+00	2026-06-16 12:38:07.851484+00	\N	\N
1031	14	23	3	0	\N	2026-06-16 12:38:14.44493+00	2026-06-16 12:38:14.44493+00	\N	\N
1032	14	22	2	1	\N	2026-06-16 12:38:21.341968+00	2026-06-16 12:38:21.341968+00	\N	\N
1033	45	17	2	1	\N	2026-06-16 13:07:34.099501+00	2026-06-16 13:07:34.099501+00	\N	\N
1034	45	18	0	2	\N	2026-06-16 13:07:41.645752+00	2026-06-16 13:07:41.645752+00	\N	\N
1035	45	19	3	0	\N	2026-06-16 13:07:51.50792+00	2026-06-16 13:07:51.50792+00	\N	\N
1036	45	20	2	0	\N	2026-06-16 13:08:00.031+00	2026-06-16 13:08:00.031+00	\N	\N
1037	59	17	2	1	\N	2026-06-16 13:16:57.48474+00	2026-06-16 13:16:57.48474+00	\N	\N
1038	59	18	0	2	\N	2026-06-16 13:18:05.432798+00	2026-06-16 13:18:05.432798+00	\N	\N
1051	11	20	3	1	\N	2026-06-16 14:21:58.51029+00	2026-06-17 03:14:23.217326+00	\N	\N
1090	44	19	2	0	\N	2026-06-16 15:35:12.305656+00	2026-06-16 15:35:12.305656+00	\N	\N
1044	41	18	0	2	\N	2026-06-16 13:41:47.83608+00	2026-06-16 13:41:47.83608+00	\N	\N
1042	41	17	2	1	\N	2026-06-16 13:39:12.593752+00	2026-06-16 13:45:45.328553+00	\N	\N
1046	29	20	2	0	\N	2026-06-16 14:17:10.970226+00	2026-06-16 14:17:10.970226+00	\N	\N
1048	11	18	1	3	\N	2026-06-16 14:20:55.685836+00	2026-06-16 14:20:55.685836+00	\N	\N
1049	11	19	3	1	\N	2026-06-16 14:21:30.749487+00	2026-06-16 14:21:30.749487+00	\N	\N
1047	11	17	3	1	\N	2026-06-16 14:19:37.550726+00	2026-06-16 14:21:36.984459+00	\N	\N
1053	35	18	0	2	\N	2026-06-16 14:27:32.189961+00	2026-06-16 14:27:32.189961+00	\N	\N
1054	35	19	2	0	\N	2026-06-16 14:27:37.629896+00	2026-06-16 14:27:37.629896+00	\N	\N
971	40	17	2	2	\N	2026-06-16 00:42:51.667775+00	2026-06-16 14:34:10.338351+00	\N	\N
1057	46	17	3	1	\N	2026-06-16 14:36:14.253057+00	2026-06-16 14:36:14.253057+00	\N	\N
993	37	17	3	1	\N	2026-06-16 03:05:31.694011+00	2026-06-16 14:36:14.969146+00	\N	\N
1062	54	23	2	0	\N	2026-06-16 14:38:48.537471+00	2026-06-16 14:38:48.537471+00	\N	\N
1065	54	24	0	2	\N	2026-06-16 14:41:18.305724+00	2026-06-16 14:41:18.305724+00	\N	\N
1066	42	17	2	0	\N	2026-06-16 14:51:18.131726+00	2026-06-16 14:51:18.131726+00	\N	\N
1067	48	17	3	2	\N	2026-06-16 14:52:19.182951+00	2026-06-16 14:52:19.182951+00	\N	\N
1014	29	17	3	0	\N	2026-06-16 05:26:56.530732+00	2026-06-16 14:54:04.11875+00	\N	\N
1069	48	18	1	2	\N	2026-06-16 14:55:40.273843+00	2026-06-16 14:55:40.273843+00	\N	\N
1070	13	17	3	1	\N	2026-06-16 14:56:10.478536+00	2026-06-16 14:56:10.478536+00	\N	\N
1071	13	18	0	1	\N	2026-06-16 14:56:33.476865+00	2026-06-16 14:56:33.476865+00	\N	\N
1072	13	19	2	1	\N	2026-06-16 14:56:44.643855+00	2026-06-16 14:56:44.643855+00	\N	\N
1073	48	19	4	1	\N	2026-06-16 14:57:00.455732+00	2026-06-16 14:57:00.455732+00	\N	\N
1075	28	17	3	1	\N	2026-06-16 14:58:15.418735+00	2026-06-16 14:58:15.418735+00	\N	\N
1076	58	17	3	1	\N	2026-06-16 15:01:56.200095+00	2026-06-16 15:01:56.200095+00	\N	\N
1077	58	18	1	3	\N	2026-06-16 15:02:08.869478+00	2026-06-16 15:02:08.869478+00	\N	\N
1078	58	19	2	0	\N	2026-06-16 15:02:19.731413+00	2026-06-16 15:02:19.731413+00	\N	\N
1079	58	20	2	1	\N	2026-06-16 15:02:29.712547+00	2026-06-16 15:02:29.712547+00	\N	\N
1091	44	20	2	0	\N	2026-06-16 15:35:31.831687+00	2026-06-16 15:35:31.831687+00	\N	\N
1080	56	17	1	1	\N	2026-06-16 15:05:57.421526+00	2026-06-16 15:06:06.882986+00	\N	\N
1084	26	17	3	1	\N	2026-06-16 15:17:43.405156+00	2026-06-16 15:17:43.405156+00	\N	\N
1085	26	18	0	2	\N	2026-06-16 15:17:54.663725+00	2026-06-16 15:17:54.663725+00	\N	\N
1087	26	20	2	2	\N	2026-06-16 15:19:04.741905+00	2026-06-16 15:19:04.741905+00	\N	\N
1088	44	17	3	1	\N	2026-06-16 15:34:50.890383+00	2026-06-16 15:34:50.890383+00	\N	\N
1083	56	18	0	2	\N	2026-06-16 15:10:42.995978+00	2026-06-16 15:36:12.827907+00	\N	\N
1096	43	18	0	2	\N	2026-06-16 15:50:22.863917+00	2026-06-16 15:50:22.863917+00	\N	\N
1097	43	17	5	1	\N	2026-06-16 15:50:46.937502+00	2026-06-16 15:50:46.937502+00	\N	\N
1098	43	19	3	1	\N	2026-06-16 15:51:49.825186+00	2026-06-16 15:51:49.825186+00	\N	\N
1095	43	20	1	1	\N	2026-06-16 15:50:16.527815+00	2026-06-16 15:51:59.849967+00	\N	\N
1101	51	19	2	0	\N	2026-06-16 15:53:44.734848+00	2026-06-16 15:53:44.734848+00	\N	\N
1102	51	18	1	1	\N	2026-06-16 15:54:06.501179+00	2026-06-16 15:54:06.501179+00	\N	\N
1052	35	17	2	0	\N	2026-06-16 14:27:24.054201+00	2026-06-16 15:59:51.090494+00	\N	\N
1094	51	17	3	1	\N	2026-06-16 15:49:19.841469+00	2026-06-16 16:12:38.953766+00	\N	\N
1086	26	19	4	1	\N	2026-06-16 15:18:11.030584+00	2026-06-17 00:56:19.332114+00	\N	\N
1107	34	17	4	0	\N	2026-06-16 17:02:51.522581+00	2026-06-16 17:02:51.522581+00	\N	\N
1108	34	18	0	2	\N	2026-06-16 17:03:03.562773+00	2026-06-16 17:03:03.562773+00	\N	\N
1109	34	19	3	0	\N	2026-06-16 17:03:14.028045+00	2026-06-16 17:03:14.028045+00	\N	\N
1111	66	17	2	1	\N	2026-06-16 17:30:53.904363+00	2026-06-16 17:30:53.904363+00	\N	\N
1112	66	18	2	2	\N	2026-06-16 17:31:14.133444+00	2026-06-16 17:31:14.133444+00	\N	\N
1113	66	19	3	2	\N	2026-06-16 17:31:33.408917+00	2026-06-16 17:31:33.408917+00	\N	\N
1114	66	20	1	1	\N	2026-06-16 17:31:55.243077+00	2026-06-16 17:31:55.243077+00	\N	\N
1015	29	18	1	2	\N	2026-06-16 05:27:07.511726+00	2026-06-16 21:25:15.72687+00	\N	\N
1018	16	18	0	3	\N	2026-06-16 10:55:31.683367+00	2026-06-16 21:25:51.811378+00	\N	\N
1019	16	19	3	1	\N	2026-06-16 10:55:49.917742+00	2026-06-16 21:26:07.676137+00	\N	\N
1103	51	20	2	1	\N	2026-06-16 15:54:31.340564+00	2026-06-17 00:09:09.223961+00	\N	\N
1040	41	19	3	1	\N	2026-06-16 13:38:46.916604+00	2026-06-16 22:40:57.909107+00	\N	\N
994	37	19	3	1	\N	2026-06-16 03:05:51.338986+00	2026-06-16 21:37:11.303948+00	\N	\N
1006	55	19	3	1	\N	2026-06-16 03:20:19.224772+00	2026-06-17 00:10:50.808217+00	\N	\N
1039	41	20	2	0	\N	2026-06-16 13:38:43.754059+00	2026-06-17 00:43:08.403329+00	\N	\N
1093	56	19	3	0	\N	2026-06-16 15:46:19.552727+00	2026-06-17 00:47:23.105924+00	\N	\N
1055	35	20	2	1	\N	2026-06-16 14:27:46.675817+00	2026-06-17 01:59:59.877732+00	\N	\N
1063	54	22	1	1	\N	2026-06-16 14:40:33.332141+00	2026-06-17 19:29:49.27509+00	\N	\N
1100	56	20	1	1	\N	2026-06-16 15:52:04.856971+00	2026-06-17 02:37:50.66619+00	\N	\N
995	37	20	3	1	\N	2026-06-16 03:06:09.874022+00	2026-06-17 03:32:21.200861+00	\N	\N
1064	54	21	1	1	\N	2026-06-16 14:41:03.745442+00	2026-06-17 19:30:04.609727+00	\N	\N
1115	31	17	3	1	\N	2026-06-16 17:36:22.587725+00	2026-06-16 17:36:53.019061+00	\N	\N
1117	31	18	0	1	\N	2026-06-16 17:37:01.740793+00	2026-06-16 17:37:01.740793+00	\N	\N
1118	31	19	2	0	\N	2026-06-16 17:37:17.815741+00	2026-06-16 17:37:17.815741+00	\N	\N
1119	31	20	1	1	\N	2026-06-16 17:37:33.052325+00	2026-06-16 17:37:33.052325+00	\N	\N
1120	23	17	3	1	\N	2026-06-16 17:44:28.675899+00	2026-06-16 17:44:28.675899+00	\N	\N
1121	28	18	0	2	\N	2026-06-16 18:00:05.178493+00	2026-06-16 18:00:05.178493+00	\N	\N
1124	10	18	1	3	\N	2026-06-16 18:06:37.084498+00	2026-06-16 18:06:37.084498+00	\N	\N
1125	10	17	2	1	\N	2026-06-16 18:06:43.834026+00	2026-06-16 18:06:43.834026+00	\N	\N
1126	10	19	3	1	\N	2026-06-16 18:06:57.15577+00	2026-06-16 18:06:57.15577+00	\N	\N
1128	11	23	4	1	\N	2026-06-16 18:16:13.542476+00	2026-06-16 18:16:13.542476+00	\N	\N
1813	50	30	1	2	\N	2026-06-19 17:27:02.084399+00	2026-06-19 17:27:02.084399+00	\N	\N
1131	11	21	3	1	\N	2026-06-16 18:17:07.062207+00	2026-06-16 18:17:07.062207+00	\N	\N
1133	50	17	3	1	\N	2026-06-16 18:49:03.595733+00	2026-06-16 18:49:03.595733+00	\N	\N
1135	50	19	3	1	\N	2026-06-16 18:49:52.435842+00	2026-06-16 18:49:52.435842+00	\N	\N
1137	12	17	2	1	\N	2026-06-16 18:50:27.093681+00	2026-06-16 18:50:27.093681+00	\N	\N
1138	18	18	2	0	\N	2026-06-16 19:21:11.209081+00	2026-06-16 19:21:16.032224+00	\N	\N
1140	18	19	3	1	\N	2026-06-16 19:21:25.390345+00	2026-06-16 19:21:25.390345+00	\N	\N
1141	18	20	1	0	\N	2026-06-16 19:21:34.07302+00	2026-06-16 19:21:34.07302+00	\N	\N
1143	16	22	1	1	\N	2026-06-16 20:08:59.012003+00	2026-06-16 20:08:59.012003+00	\N	\N
1144	16	21	2	0	\N	2026-06-16 20:09:05.435121+00	2026-06-16 20:09:05.435121+00	\N	\N
1145	16	24	1	2	\N	2026-06-16 20:09:14.552893+00	2026-06-16 20:09:14.552893+00	\N	\N
1229	37	24	1	3	\N	2026-06-17 03:11:12.828759+00	2026-06-17 03:12:42.388279+00	\N	\N
1148	23	18	0	2	\N	2026-06-16 21:15:33.724983+00	2026-06-16 21:15:33.724983+00	\N	\N
1236	30	23	3	0	\N	2026-06-17 03:22:53.673853+00	2026-06-17 03:22:53.673853+00	\N	\N
1151	46	18	1	4	\N	2026-06-16 21:20:46.279982+00	2026-06-16 21:20:59.585999+00	\N	\N
996	37	18	0	3	\N	2026-06-16 03:06:23.915224+00	2026-06-16 21:27:53.323297+00	\N	\N
1162	12	18	1	4	\N	2026-06-16 21:38:56.816417+00	2026-06-16 21:38:56.816417+00	\N	\N
1251	35	23	3	0	\N	2026-06-17 10:52:04.524832+00	2026-06-17 10:52:04.524832+00	\N	\N
1237	30	22	2	2	\N	2026-06-17 03:23:01.875834+00	2026-06-17 03:23:01.875834+00	\N	\N
1165	42	18	1	3	\N	2026-06-16 21:51:59.832682+00	2026-06-16 21:51:59.832682+00	\N	\N
1134	50	18	1	3	\N	2026-06-16 18:49:46.141047+00	2026-06-16 21:58:39.671234+00	\N	\N
1169	59	20	1	0	\N	2026-06-16 22:26:51.63746+00	2026-06-16 22:26:51.63746+00	\N	\N
1170	59	19	2	1	\N	2026-06-16 22:26:52.029884+00	2026-06-16 22:27:01.319042+00	\N	\N
1176	46	19	2	1	\N	2026-06-17 00:01:24.974775+00	2026-06-17 00:01:24.974775+00	\N	\N
1177	42	19	2	1	\N	2026-06-17 00:03:29.351231+00	2026-06-17 00:03:29.351231+00	\N	\N
1122	28	19	2	0	\N	2026-06-16 18:00:15.093754+00	2026-06-17 00:27:19.627759+00	\N	\N
1123	28	20	1	1	\N	2026-06-16 18:00:29.999738+00	2026-06-17 00:27:33.100726+00	\N	\N
1186	47	22	2	1	\N	2026-06-17 00:27:50.266685+00	2026-06-17 00:27:50.266685+00	\N	\N
1187	47	23	3	1	\N	2026-06-17 00:30:54.522456+00	2026-06-17 00:30:54.522456+00	\N	\N
1188	38	23	2	0	\N	2026-06-17 00:36:50.727988+00	2026-06-17 00:36:50.727988+00	\N	\N
1190	38	21	1	0	\N	2026-06-17 00:37:28.036126+00	2026-06-17 00:37:28.036126+00	\N	\N
1191	38	24	0	2	\N	2026-06-17 00:37:46.098537+00	2026-06-17 00:37:46.098537+00	\N	\N
1194	23	19	3	0	\N	2026-06-17 00:51:15.640139+00	2026-06-17 00:51:15.640139+00	\N	\N
1195	23	20	1	1	\N	2026-06-17 00:51:30.897234+00	2026-06-17 00:51:30.897234+00	\N	\N
1196	12	19	2	1	\N	2026-06-17 00:54:28.922391+00	2026-06-17 00:54:28.922391+00	\N	\N
1200	23	24	0	3	\N	2026-06-17 01:27:20.26033+00	2026-06-17 01:27:20.26033+00	\N	\N
1201	23	23	4	0	\N	2026-06-17 01:27:51.087657+00	2026-06-17 01:27:51.087657+00	\N	\N
1202	23	22	2	1	\N	2026-06-17 01:28:02.039993+00	2026-06-17 01:28:02.039993+00	\N	\N
1203	23	21	0	1	\N	2026-06-17 01:28:17.477468+00	2026-06-17 01:28:17.477468+00	\N	\N
1205	55	23	4	1	\N	2026-06-17 02:08:28.340307+00	2026-06-17 02:08:28.340307+00	\N	\N
1206	55	22	2	2	\N	2026-06-17 02:08:47.377946+00	2026-06-17 02:08:47.377946+00	\N	\N
1207	55	21	2	2	\N	2026-06-17 02:08:56.68311+00	2026-06-17 02:08:56.68311+00	\N	\N
1208	55	24	0	2	\N	2026-06-17 02:09:02.40298+00	2026-06-17 02:09:02.40298+00	\N	\N
1210	12	20	3	0	\N	2026-06-17 02:42:27.640312+00	2026-06-17 02:42:27.640312+00	\N	\N
1132	13	20	2	1	\N	2026-06-16 18:32:06.336973+00	2026-06-17 02:59:03.42851+00	\N	\N
1212	40	23	3	0	\N	2026-06-17 03:00:01.184658+00	2026-06-17 03:00:01.184658+00	\N	\N
1213	40	24	0	3	\N	2026-06-17 03:00:44.48758+00	2026-06-17 03:00:44.48758+00	\N	\N
1214	40	21	2	1	\N	2026-06-17 03:00:55.264748+00	2026-06-17 03:00:55.264748+00	\N	\N
1215	40	22	2	2	\N	2026-06-17 03:01:04.809644+00	2026-06-17 03:01:04.809644+00	\N	\N
1127	10	20	2	1	\N	2026-06-16 18:07:13.655417+00	2026-06-17 03:03:11.637566+00	\N	\N
1074	48	20	2	0	\N	2026-06-16 14:57:14.465556+00	2026-06-17 03:03:53.83631+00	\N	\N
1227	37	22	2	1	\N	2026-06-17 03:10:22.519745+00	2026-06-17 03:10:22.519745+00	\N	\N
1238	30	21	0	1	\N	2026-06-17 03:23:13.576311+00	2026-06-17 03:23:13.576311+00	\N	\N
1252	35	21	1	0	\N	2026-06-17 10:52:16.921681+00	2026-06-17 10:52:16.921681+00	\N	\N
1232	46	20	2	0	\N	2026-06-17 03:12:20.695713+00	2026-06-17 03:12:20.695713+00	\N	\N
1239	30	24	1	2	\N	2026-06-17 03:23:25.223903+00	2026-06-17 03:23:25.223903+00	\N	\N
1253	35	22	3	1	\N	2026-06-17 10:52:40.710745+00	2026-06-17 10:52:40.710745+00	\N	\N
1256	24	23	2	0	\N	2026-06-17 11:09:30.088358+00	2026-06-17 11:09:30.088358+00	\N	\N
1242	42	20	3	0	\N	2026-06-17 03:44:36.928729+00	2026-06-17 03:54:58.008825+00	\N	\N
1136	50	20	2	1	\N	2026-06-16 18:50:00.533757+00	2026-06-17 03:58:46.832115+00	\N	\N
1246	10	23	3	0	\N	2026-06-17 04:40:56.431785+00	2026-06-17 04:40:56.431785+00	\N	\N
1247	10	22	2	2	\N	2026-06-17 04:41:07.540727+00	2026-06-17 04:41:07.540727+00	\N	\N
1248	10	21	2	0	\N	2026-06-17 04:41:13.341929+00	2026-06-17 04:41:13.341929+00	\N	\N
1250	35	24	0	1	\N	2026-06-17 10:51:50.023068+00	2026-06-17 10:51:50.023068+00	\N	\N
1257	24	22	2	1	\N	2026-06-17 11:09:46.74336+00	2026-06-17 11:09:46.74336+00	\N	\N
1258	24	21	3	1	\N	2026-06-17 11:10:13.257229+00	2026-06-17 11:10:13.257229+00	\N	\N
1259	24	24	1	2	\N	2026-06-17 11:10:29.668186+00	2026-06-17 11:10:29.668186+00	\N	\N
1142	16	23	3	0	\N	2026-06-16 20:08:45.242051+00	2026-06-17 11:18:43.690087+00	\N	\N
1261	27	23	3	0	\N	2026-06-17 11:43:14.596627+00	2026-06-17 11:43:14.596627+00	\N	\N
1262	27	22	2	2	\N	2026-06-17 11:43:25.11812+00	2026-06-17 11:43:25.11812+00	\N	\N
1263	27	21	2	1	\N	2026-06-17 11:43:38.38329+00	2026-06-17 11:43:38.38329+00	\N	\N
1264	27	24	0	3	\N	2026-06-17 11:43:50.367974+00	2026-06-17 11:43:50.367974+00	\N	\N
1265	34	23	3	0	\N	2026-06-17 11:54:58.63825+00	2026-06-17 11:54:58.63825+00	\N	\N
1266	34	22	2	1	\N	2026-06-17 11:55:20.203594+00	2026-06-17 11:55:20.203594+00	\N	\N
1267	34	24	0	2	\N	2026-06-17 11:55:45.440758+00	2026-06-17 11:55:45.440758+00	\N	\N
1189	38	22	2	1	\N	2026-06-17 00:37:11.922186+00	2026-06-17 13:35:09.139343+00	\N	\N
1218	56	21	2	1	\N	2026-06-17 03:02:19.791031+00	2026-06-17 13:59:34.700719+00	\N	\N
1130	11	22	3	2	\N	2026-06-16 18:16:49.497668+00	2026-06-17 17:23:58.316993+00	\N	\N
1219	56	24	0	2	\N	2026-06-17 03:02:26.851724+00	2026-06-17 19:27:49.041764+00	\N	\N
1217	56	23	2	0	\N	2026-06-17 03:02:12.72374+00	2026-06-17 14:07:07.236762+00	\N	\N
1249	10	24	1	3	\N	2026-06-17 04:41:24.32289+00	2026-06-17 22:05:40.511769+00	\N	\N
1184	47	21	2	1	\N	2026-06-17 00:27:20.78478+00	2026-06-17 17:51:12.221645+00	\N	\N
1182	47	24	1	3	\N	2026-06-17 00:26:57.535737+00	2026-06-17 17:52:24.469673+00	\N	\N
1216	56	22	1	1	\N	2026-06-17 03:02:05.250313+00	2026-06-17 19:27:42.871627+00	\N	\N
1228	37	21	3	1	\N	2026-06-17 03:11:01.942939+00	2026-06-17 22:16:14.454976+00	\N	\N
1268	34	21	1	1	\N	2026-06-17 11:57:12.386249+00	2026-06-17 11:57:12.386249+00	\N	\N
1269	32	23	2	0	\N	2026-06-17 12:07:48.197245+00	2026-06-17 12:07:48.197245+00	\N	\N
1270	32	22	3	1	\N	2026-06-17 12:08:38.34537+00	2026-06-17 12:08:38.34537+00	\N	\N
1272	32	24	1	2	\N	2026-06-17 12:09:20.285418+00	2026-06-17 12:09:20.285418+00	\N	\N
1273	44	23	3	0	\N	2026-06-17 12:24:31.508275+00	2026-06-17 12:24:31.508275+00	\N	\N
1274	44	21	2	0	\N	2026-06-17 12:24:51.686527+00	2026-06-17 12:24:51.686527+00	\N	\N
1275	45	23	2	0	\N	2026-06-17 12:27:16.294259+00	2026-06-17 12:27:16.294259+00	\N	\N
1276	45	22	2	1	\N	2026-06-17 12:27:34.159644+00	2026-06-17 12:27:34.159644+00	\N	\N
1277	45	21	1	1	\N	2026-06-17 12:27:47.571087+00	2026-06-17 12:27:47.571087+00	\N	\N
1278	45	24	1	2	\N	2026-06-17 12:27:58.122234+00	2026-06-17 19:21:17.356741+00	\N	\N
1226	37	23	3	1	\N	2026-06-17 03:09:24.558857+00	2026-06-17 12:52:39.227943+00	\N	\N
1284	59	23	3	1	\N	2026-06-17 13:38:06.480289+00	2026-06-17 13:38:06.480289+00	\N	\N
1286	28	23	2	0	\N	2026-06-17 13:53:33.638404+00	2026-06-17 13:53:58.604008+00	\N	\N
1288	28	22	2	1	\N	2026-06-17 13:54:26.295098+00	2026-06-17 13:54:26.295098+00	\N	\N
1289	28	21	1	0	\N	2026-06-17 13:54:34.744984+00	2026-06-17 13:54:34.744984+00	\N	\N
1291	48	23	3	0	\N	2026-06-17 13:58:57.768859+00	2026-06-17 13:58:57.768859+00	\N	\N
1292	48	22	2	2	\N	2026-06-17 13:59:29.932275+00	2026-06-17 13:59:29.932275+00	\N	\N
1295	48	21	2	1	\N	2026-06-17 13:59:53.16089+00	2026-06-17 13:59:53.16089+00	\N	\N
1296	48	24	0	2	\N	2026-06-17 13:59:59.650016+00	2026-06-17 13:59:59.650016+00	\N	\N
1297	51	24	0	2	\N	2026-06-17 14:00:06.155+00	2026-06-17 14:00:06.155+00	\N	\N
1298	51	21	1	0	\N	2026-06-17 14:01:10.444597+00	2026-06-17 14:01:10.444597+00	\N	\N
1299	51	23	3	1	\N	2026-06-17 14:01:38.904666+00	2026-06-17 14:01:38.904666+00	\N	\N
1301	33	23	2	1	\N	2026-06-17 14:05:48.307638+00	2026-06-17 14:05:48.307638+00	\N	\N
1302	33	22	2	2	\N	2026-06-17 14:05:58.837509+00	2026-06-17 14:06:20.180487+00	\N	\N
1304	33	21	2	1	\N	2026-06-17 14:06:35.006731+00	2026-06-17 14:06:35.006731+00	\N	\N
1307	33	24	0	2	\N	2026-06-17 14:07:07.650545+00	2026-06-17 14:07:07.650545+00	\N	\N
1309	13	23	3	0	\N	2026-06-17 14:10:28.487606+00	2026-06-17 14:10:28.487606+00	\N	\N
1300	51	22	2	1	\N	2026-06-17 14:02:06.475659+00	2026-06-17 14:16:02.125674+00	\N	\N
1285	59	22	2	2	\N	2026-06-17 13:40:30.505502+00	2026-06-17 14:23:53.704757+00	\N	\N
1312	59	21	3	1	\N	2026-06-17 14:24:09.552044+00	2026-06-17 14:24:09.552044+00	\N	\N
1314	13	22	2	1	\N	2026-06-17 15:04:52.654574+00	2026-06-17 15:04:52.654574+00	\N	\N
1315	13	21	0	1	\N	2026-06-17 15:05:01.796472+00	2026-06-17 15:05:01.796472+00	\N	\N
1316	13	24	0	3	\N	2026-06-17 15:05:07.491849+00	2026-06-17 15:05:07.491849+00	\N	\N
1317	58	23	2	0	\N	2026-06-17 15:50:48.902069+00	2026-06-17 15:50:48.902069+00	\N	\N
1318	58	22	2	2	\N	2026-06-17 15:51:00.740165+00	2026-06-17 15:51:00.740165+00	\N	\N
1319	58	21	2	1	\N	2026-06-17 15:51:11.881757+00	2026-06-17 15:51:11.881757+00	\N	\N
1321	58	24	0	2	\N	2026-06-17 15:51:22.28581+00	2026-06-17 15:51:22.28581+00	\N	\N
1322	41	22	2	1	\N	2026-06-17 15:51:26.045222+00	2026-06-17 15:51:45.436076+00	\N	\N
1326	36	23	2	0	\N	2026-06-17 16:07:22.284845+00	2026-06-17 16:07:22.284845+00	\N	\N
1328	36	21	2	0	\N	2026-06-17 16:07:54.743734+00	2026-06-17 16:07:54.743734+00	\N	\N
1327	36	22	2	2	\N	2026-06-17 16:07:36.583363+00	2026-06-17 16:08:36.586731+00	\N	\N
1329	36	24	1	3	\N	2026-06-17 16:08:10.229053+00	2026-06-17 16:09:02.381623+00	\N	\N
1359	68	21	2	1	\N	2026-06-17 17:20:53.164023+00	2026-06-17 17:26:53.134801+00	\N	\N
1333	31	23	3	1	\N	2026-06-17 16:14:54.364822+00	2026-06-17 16:14:54.364822+00	\N	\N
1334	31	21	2	0	\N	2026-06-17 16:15:26.822497+00	2026-06-17 16:15:26.822497+00	\N	\N
1335	31	22	1	1	\N	2026-06-17 16:15:49.668979+00	2026-06-17 16:15:49.668979+00	\N	\N
1336	31	24	1	2	\N	2026-06-17 16:16:02.673386+00	2026-06-17 16:16:02.673386+00	\N	\N
1320	41	23	3	1	\N	2026-06-17 15:51:22.178525+00	2026-06-17 16:20:33.651827+00	\N	\N
1338	46	23	3	0	\N	2026-06-17 16:20:54.874729+00	2026-06-17 16:20:54.874729+00	\N	\N
1339	50	23	3	1	\N	2026-06-17 16:48:30.541165+00	2026-06-17 16:48:30.541165+00	\N	\N
1340	50	22	2	1	\N	2026-06-17 16:48:35.242742+00	2026-06-17 16:48:35.242742+00	\N	\N
3874	43	67	0	1	\N	2026-06-27 15:19:02.447754+00	2026-06-27 15:19:02.447754+00	\N	\N
1343	12	23	3	0	\N	2026-06-17 16:51:12.725298+00	2026-06-17 16:51:12.725298+00	\N	\N
1344	29	23	3	1	\N	2026-06-17 16:51:44.640807+00	2026-06-17 16:51:44.640807+00	\N	\N
1345	42	23	3	0	\N	2026-06-17 16:51:45.435226+00	2026-06-17 16:51:45.435226+00	\N	\N
1346	25	23	2	0	\N	2026-06-17 16:52:09.348721+00	2026-06-17 16:52:09.348721+00	\N	\N
1347	25	22	1	1	\N	2026-06-17 16:52:19.75912+00	2026-06-17 16:52:19.75912+00	\N	\N
1348	25	21	2	0	\N	2026-06-17 16:52:25.450865+00	2026-06-17 16:52:25.450865+00	\N	\N
1349	25	24	0	2	\N	2026-06-17 16:52:30.30126+00	2026-06-17 16:52:30.30126+00	\N	\N
1350	43	23	3	0	\N	2026-06-17 16:53:33.56356+00	2026-06-17 16:53:33.56356+00	\N	\N
1351	43	22	2	1	\N	2026-06-17 16:53:43.140132+00	2026-06-17 16:53:43.140132+00	\N	\N
1352	43	21	1	1	\N	2026-06-17 16:53:53.046891+00	2026-06-17 16:53:53.046891+00	\N	\N
1353	43	24	1	2	\N	2026-06-17 16:53:59.675088+00	2026-06-17 16:53:59.675088+00	\N	\N
1354	26	24	0	2	\N	2026-06-17 17:01:39.615733+00	2026-06-17 17:01:39.615733+00	\N	\N
1355	26	22	2	2	\N	2026-06-17 17:01:48.429396+00	2026-06-17 17:01:48.429396+00	\N	\N
1356	26	21	2	0	\N	2026-06-17 17:02:00.764435+00	2026-06-17 17:02:00.764435+00	\N	\N
1367	68	23	3	0	\N	2026-06-17 17:38:35.388587+00	2026-06-17 17:38:35.388587+00	\N	\N
1360	68	24	0	3	\N	2026-06-17 17:21:16.23441+00	2026-06-17 17:21:16.23441+00	\N	\N
1370	66	22	2	2	\N	2026-06-17 17:59:53.731566+00	2026-06-17 17:59:53.731566+00	\N	\N
1357	68	22	3	1	\N	2026-06-17 17:20:30.608993+00	2026-06-17 17:26:35.664224+00	\N	\N
1372	66	24	0	2	\N	2026-06-17 18:00:53.35448+00	2026-06-17 18:00:53.35448+00	\N	\N
1325	41	24	0	2	\N	2026-06-17 15:52:04.511209+00	2026-06-17 18:09:47.440942+00	\N	\N
1271	32	21	2	1	\N	2026-06-17 12:08:57.387724+00	2026-06-17 18:28:45.626278+00	\N	\N
1324	41	21	2	0	\N	2026-06-17 15:51:56.036216+00	2026-06-17 19:06:19.956737+00	\N	\N
1377	18	22	2	1	\N	2026-06-17 19:12:53.854169+00	2026-06-17 19:12:53.854169+00	\N	\N
1378	18	21	2	0	\N	2026-06-17 19:13:11.052104+00	2026-06-17 19:13:11.052104+00	\N	\N
1379	18	24	0	2	\N	2026-06-17 19:13:32.045411+00	2026-06-17 19:13:32.045411+00	\N	\N
1387	54	26	1	0	\N	2026-06-17 19:31:31.317271+00	2026-06-17 19:31:31.317271+00	\N	\N
1820	58	32	1	1	\N	2026-06-19 17:38:23.791156+00	2026-06-19 17:38:23.791156+00	\N	\N
1381	46	22	2	2	\N	2026-06-17 19:23:12.675302+00	2026-06-17 19:46:07.789765+00	\N	\N
1392	29	22	2	1	\N	2026-06-17 19:51:38.029741+00	2026-06-17 19:51:38.029741+00	\N	\N
1393	12	22	2	0	\N	2026-06-17 19:53:47.194949+00	2026-06-17 19:53:47.194949+00	\N	\N
1394	42	21	3	0	\N	2026-06-17 20:07:23.874787+00	2026-06-17 20:07:33.192897+00	\N	\N
1396	42	24	0	2	\N	2026-06-17 20:07:55.148254+00	2026-06-17 20:07:55.148254+00	\N	\N
1397	44	24	0	3	\N	2026-06-17 21:14:38.431728+00	2026-06-17 21:14:38.431728+00	\N	\N
1313	59	24	0	2	\N	2026-06-17 14:28:50.456744+00	2026-06-18 01:07:44.308416+00	\N	\N
1371	66	21	1	3	\N	2026-06-17 18:00:33.574752+00	2026-06-17 21:53:48.820329+00	\N	\N
1400	56	25	2	1	\N	2026-06-17 21:58:24.268256+00	2026-06-17 21:58:24.268256+00	\N	\N
1402	56	27	2	1	\N	2026-06-17 21:58:39.038721+00	2026-06-17 21:58:39.038721+00	\N	\N
1386	54	25	1	1	\N	2026-06-17 19:31:25.619655+00	2026-06-18 15:47:33.332721+00	\N	\N
1290	28	24	0	1	\N	2026-06-17 13:54:43.064354+00	2026-06-17 23:06:46.306724+00	\N	\N
1342	50	24	0	3	\N	2026-06-17 16:48:50.553872+00	2026-06-17 23:24:05.448759+00	\N	\N
1403	56	28	2	1	\N	2026-06-17 21:58:46.96788+00	2026-06-18 14:54:08.881263+00	\N	\N
1389	54	28	2	1	\N	2026-06-17 19:31:46.03525+00	2026-06-18 21:25:18.103517+00	\N	\N
1388	54	27	2	0	\N	2026-06-17 19:31:38.135525+00	2026-06-18 18:04:21.111282+00	\N	\N
1407	46	21	2	1	\N	2026-06-17 22:04:55.951793+00	2026-06-17 22:04:55.951793+00	\N	\N
1412	29	21	1	2	\N	2026-06-17 22:49:35.785729+00	2026-06-17 22:49:35.785729+00	\N	\N
1413	29	24	0	2	\N	2026-06-17 22:53:25.933168+00	2026-06-17 22:53:25.933168+00	\N	\N
1341	50	21	2	2	\N	2026-06-17 16:48:44.044898+00	2026-06-17 22:54:18.500464+00	\N	\N
1415	29	25	2	0	\N	2026-06-17 22:54:44.935896+00	2026-06-17 22:54:44.935896+00	\N	\N
1416	29	28	1	2	\N	2026-06-17 22:55:06.681299+00	2026-06-17 22:55:06.681299+00	\N	\N
1417	12	21	2	1	\N	2026-06-17 22:55:10.536722+00	2026-06-17 22:55:10.536722+00	\N	\N
1418	29	26	1	1	\N	2026-06-17 22:56:24.660266+00	2026-06-17 22:56:24.660266+00	\N	\N
1424	9	26	2	0	\N	2026-06-18 00:12:05.257238+00	2026-06-18 00:12:05.257238+00	\N	\N
1425	9	27	3	1	\N	2026-06-18 00:12:50.177952+00	2026-06-18 00:12:50.177952+00	\N	\N
1423	9	25	2	1	\N	2026-06-18 00:11:10.428779+00	2026-06-18 00:17:06.519867+00	\N	\N
1426	9	28	1	1	\N	2026-06-18 00:13:40.070895+00	2026-06-18 00:17:13.140824+00	\N	\N
1429	38	27	1	0	\N	2026-06-18 00:27:18.15748+00	2026-06-18 00:27:18.15748+00	\N	\N
1431	15	25	3	0	\N	2026-06-18 00:36:14.564919+00	2026-06-18 00:36:14.564919+00	\N	\N
1432	15	28	1	2	\N	2026-06-18 00:36:43.914961+00	2026-06-18 00:36:43.914961+00	\N	\N
1433	15	27	2	0	\N	2026-06-18 00:36:55.328224+00	2026-06-18 00:36:55.328224+00	\N	\N
1434	15	26	2	0	\N	2026-06-18 00:37:11.636726+00	2026-06-18 00:37:11.636726+00	\N	\N
1435	15	30	0	2	\N	2026-06-18 00:37:57.700069+00	2026-06-18 00:37:57.700069+00	\N	\N
1436	15	32	2	1	\N	2026-06-18 00:38:02.639594+00	2026-06-18 00:38:15.155142+00	\N	\N
1438	15	29	4	0	\N	2026-06-18 00:38:26.242115+00	2026-06-18 00:38:26.242115+00	\N	\N
1439	15	31	0	2	\N	2026-06-18 00:38:34.981675+00	2026-06-18 00:38:34.981675+00	\N	\N
1440	15	35	1	2	\N	2026-06-18 00:39:06.6299+00	2026-06-18 00:39:06.6299+00	\N	\N
1444	15	36	0	3	\N	2026-06-18 00:40:03.500849+00	2026-06-20 18:52:26.661882+00	\N	\N
1445	15	38	2	0	\N	2026-06-18 00:40:30.717831+00	2026-06-18 00:40:30.717831+00	\N	\N
1446	15	37	4	0	\N	2026-06-18 00:40:49.058007+00	2026-06-18 00:40:49.058007+00	\N	\N
1447	15	40	2	1	\N	2026-06-18 00:41:35.054915+00	2026-06-18 00:41:35.054915+00	\N	\N
1449	15	43	2	0	\N	2026-06-18 00:42:47.181483+00	2026-06-18 00:42:47.181483+00	\N	\N
1450	15	42	3	0	\N	2026-06-18 00:43:00.825268+00	2026-06-18 00:43:00.825268+00	\N	\N
1452	15	44	0	2	\N	2026-06-18 00:44:00.795363+00	2026-06-18 00:44:00.795363+00	\N	\N
3875	43	68	1	1	\N	2026-06-27 15:19:09.703344+00	2026-06-27 15:19:09.703344+00	\N	\N
1443	15	34	4	0	\N	2026-06-18 00:39:39.49477+00	2026-06-20 14:16:17.502171+00	\N	\N
1458	38	26	1	0	\N	2026-06-18 00:53:57.503615+00	2026-06-18 00:53:57.503615+00	\N	\N
1459	46	24	1	3	\N	2026-06-18 01:06:00.558677+00	2026-06-18 01:06:00.558677+00	\N	\N
1129	11	24	1	3	\N	2026-06-16 18:16:23.186374+00	2026-06-18 01:51:55.120987+00	\N	\N
1463	40	25	2	1	\N	2026-06-18 03:31:46.037554+00	2026-06-18 03:31:46.037554+00	\N	\N
1464	40	26	2	1	\N	2026-06-18 03:35:26.252737+00	2026-06-18 03:35:40.510998+00	\N	\N
1466	40	27	1	1	\N	2026-06-18 03:36:02.679927+00	2026-06-18 03:36:02.679927+00	\N	\N
1468	10	25	1	2	\N	2026-06-18 04:03:58.637052+00	2026-06-18 04:03:58.637052+00	\N	\N
1469	10	26	2	1	\N	2026-06-18 04:04:13.903937+00	2026-06-18 04:04:13.903937+00	\N	\N
1470	10	27	2	1	\N	2026-06-18 04:04:35.933152+00	2026-06-18 04:04:35.933152+00	\N	\N
1471	10	28	2	1	\N	2026-06-18 04:04:50.566027+00	2026-06-18 04:04:50.566027+00	\N	\N
1472	34	25	2	1	\N	2026-06-18 04:10:18.129825+00	2026-06-18 04:10:25.72472+00	\N	\N
1475	34	26	2	0	\N	2026-06-18 04:11:34.536724+00	2026-06-18 04:11:34.536724+00	\N	\N
1476	34	27	3	0	\N	2026-06-18 04:11:49.174561+00	2026-06-18 04:11:49.174561+00	\N	\N
1477	34	28	1	1	\N	2026-06-18 04:11:59.51805+00	2026-06-18 04:11:59.51805+00	\N	\N
1478	55	25	2	1	\N	2026-06-18 04:15:37.834075+00	2026-06-18 04:15:37.834075+00	\N	\N
1479	55	26	2	2	\N	2026-06-18 04:16:59.418059+00	2026-06-18 04:16:59.418059+00	\N	\N
1480	55	27	2	3	\N	2026-06-18 04:17:19.155722+00	2026-06-18 04:17:19.155722+00	\N	\N
1482	59	25	2	0	\N	2026-06-18 04:34:00.904167+00	2026-06-18 04:34:00.904167+00	\N	\N
1483	47	25	2	2	\N	2026-06-18 04:55:05.141034+00	2026-06-18 04:55:05.141034+00	\N	\N
1484	47	26	2	0	\N	2026-06-18 04:55:23.326992+00	2026-06-18 04:55:23.326992+00	\N	\N
1485	47	27	1	2	\N	2026-06-18 04:55:40.767933+00	2026-06-18 04:55:40.767933+00	\N	\N
1487	50	25	2	0	\N	2026-06-18 05:39:08.941111+00	2026-06-18 05:39:08.941111+00	\N	\N
1488	46	25	2	0	\N	2026-06-18 06:25:26.951039+00	2026-06-18 06:25:26.951039+00	\N	\N
1489	68	25	0	2	\N	2026-06-18 10:47:16.290033+00	2026-06-18 10:47:16.290033+00	\N	\N
1494	35	26	2	1	\N	2026-06-18 10:51:31.826963+00	2026-06-18 10:51:31.826963+00	\N	\N
1493	35	25	2	0	\N	2026-06-18 10:51:00.356428+00	2026-06-18 10:51:40.829976+00	\N	\N
1497	35	28	1	0	\N	2026-06-18 10:52:21.790403+00	2026-06-18 10:52:21.790403+00	\N	\N
1496	35	27	2	0	\N	2026-06-18 10:51:55.297772+00	2026-06-18 10:52:43.099384+00	\N	\N
1499	24	25	2	0	\N	2026-06-18 11:20:16.686529+00	2026-06-18 11:20:16.686529+00	\N	\N
1500	24	26	2	1	\N	2026-06-18 11:20:35.406148+00	2026-06-18 11:20:35.406148+00	\N	\N
1501	24	27	1	0	\N	2026-06-18 11:20:47.253579+00	2026-06-18 11:20:47.253579+00	\N	\N
1504	13	26	3	1	\N	2026-06-18 11:26:33.349784+00	2026-06-18 11:26:33.349784+00	\N	\N
1505	13	27	2	0	\N	2026-06-18 11:27:06.724165+00	2026-06-18 11:27:06.724165+00	\N	\N
1506	48	25	2	0	\N	2026-06-18 11:37:16.232173+00	2026-06-18 11:37:16.232173+00	\N	\N
1507	48	26	2	1	\N	2026-06-18 11:37:29.945129+00	2026-06-18 11:37:29.945129+00	\N	\N
1508	48	27	1	1	\N	2026-06-18 11:38:14.145685+00	2026-06-18 11:38:14.145685+00	\N	\N
1509	48	28	2	1	\N	2026-06-18 11:38:30.716858+00	2026-06-18 11:38:30.716858+00	\N	\N
1511	37	28	1	2	\N	2026-06-18 11:53:00.169222+00	2026-06-18 11:53:00.169222+00	\N	\N
1512	37	26	2	1	\N	2026-06-18 11:53:09.897891+00	2026-06-18 11:53:09.897891+00	\N	\N
1515	51	26	3	1	\N	2026-06-18 12:02:46.529401+00	2026-06-18 12:02:46.529401+00	\N	\N
1516	51	27	1	0	\N	2026-06-18 12:03:00.949987+00	2026-06-18 12:03:00.949987+00	\N	\N
1502	24	28	2	2	\N	2026-06-18 11:20:59.733722+00	2026-06-18 12:23:38.361446+00	\N	\N
1467	40	28	1	2	\N	2026-06-18 03:37:54.892433+00	2026-06-18 23:54:02.372531+00	\N	\N
1521	45	28	2	1	\N	2026-06-18 12:32:47.341354+00	2026-06-18 12:32:47.341354+00	\N	\N
1522	45	27	3	1	\N	2026-06-18 12:33:14.839333+00	2026-06-18 12:33:14.839333+00	\N	\N
1523	45	25	1	1	\N	2026-06-18 12:34:22.970015+00	2026-06-18 12:34:22.970015+00	\N	\N
1419	29	27	2	1	\N	2026-06-17 22:58:00.438099+00	2026-06-18 20:53:30.053522+00	\N	\N
1514	51	25	2	1	\N	2026-06-18 12:02:38.337201+00	2026-06-18 15:46:19.561722+00	\N	\N
1503	13	25	2	1	\N	2026-06-18 11:24:36.683679+00	2026-06-18 14:03:51.50117+00	\N	\N
1510	37	25	3	1	\N	2026-06-18 11:51:43.501734+00	2026-06-18 15:59:33.838145+00	\N	\N
1490	68	26	2	1	\N	2026-06-18 10:48:58.999336+00	2026-06-18 18:08:26.259589+00	\N	\N
1491	68	27	3	1	\N	2026-06-18 10:50:02.526333+00	2026-06-18 21:58:36.651201+00	\N	\N
1486	47	28	3	2	\N	2026-06-18 04:56:09.077762+00	2026-06-19 00:34:46.537329+00	\N	\N
1448	15	39	2	0	\N	2026-06-18 00:42:02.91973+00	2026-06-21 18:49:18.371032+00	\N	\N
1513	37	27	2	1	\N	2026-06-18 11:53:19.332418+00	2026-06-18 21:01:46.548523+00	\N	\N
1517	51	28	2	1	\N	2026-06-18 12:03:04.56249+00	2026-06-19 00:38:21.346936+00	\N	\N
1481	55	28	2	1	\N	2026-06-18 04:17:32.240282+00	2026-06-18 23:56:01.66812+00	\N	\N
1430	38	28	2	2	\N	2026-06-18 00:27:18.245375+00	2026-06-19 00:05:18.669333+00	\N	\N
1492	68	28	3	2	\N	2026-06-18 10:50:14.039731+00	2026-06-19 00:09:57.559415+00	\N	\N
1441	15	33	2	0	\N	2026-06-18 00:39:18.826689+00	2026-06-20 14:16:43.492211+00	\N	\N
1451	15	41	1	2	\N	2026-06-18 00:43:20.395041+00	2026-06-22 21:11:17.285469+00	\N	\N
1455	15	46	0	2	\N	2026-06-18 00:44:59.513644+00	2026-06-23 19:12:24.896876+00	\N	\N
1456	15	48	3	0	\N	2026-06-18 00:45:11.037129+00	2026-06-23 00:55:09.650635+00	\N	\N
1454	15	45	3	0	\N	2026-06-18 00:44:50.072208+00	2026-06-23 19:12:10.613093+00	\N	\N
1524	45	26	2	1	\N	2026-06-18 12:34:41.284757+00	2026-06-18 12:34:41.284757+00	\N	\N
1457	38	25	2	1	\N	2026-06-18 00:53:46.243748+00	2026-06-18 12:38:52.300251+00	\N	\N
1526	16	28	2	2	\N	2026-06-18 12:43:12.554499+00	2026-06-18 12:43:12.554499+00	\N	\N
1528	44	25	1	2	\N	2026-06-18 12:43:57.418748+00	2026-06-18 12:43:57.418748+00	\N	\N
1527	16	27	3	1	\N	2026-06-18 12:43:31.416906+00	2026-06-18 12:44:06.623829+00	\N	\N
1530	44	26	2	0	\N	2026-06-18 12:44:10.531766+00	2026-06-18 12:44:10.531766+00	\N	\N
1531	44	27	2	0	\N	2026-06-18 12:44:27.326477+00	2026-06-18 12:44:27.326477+00	\N	\N
1532	44	28	2	1	\N	2026-06-18 12:44:39.241373+00	2026-06-18 12:44:39.241373+00	\N	\N
1533	16	26	1	2	\N	2026-06-18 12:44:43.303578+00	2026-06-18 12:44:43.303578+00	\N	\N
1534	16	25	2	0	\N	2026-06-18 12:45:01.717261+00	2026-06-18 12:45:01.717261+00	\N	\N
1535	58	25	1	2	\N	2026-06-18 13:19:24.650941+00	2026-06-18 13:19:24.650941+00	\N	\N
1538	58	28	2	1	\N	2026-06-18 13:20:07.052282+00	2026-06-18 13:20:07.052282+00	\N	\N
1540	32	25	1	1	\N	2026-06-18 13:48:50.786223+00	2026-06-18 13:48:50.786223+00	\N	\N
1541	32	27	2	0	\N	2026-06-18 13:49:48.531788+00	2026-06-18 13:49:48.531788+00	\N	\N
1542	32	28	3	2	\N	2026-06-18 13:50:16.901228+00	2026-06-18 13:50:16.901228+00	\N	\N
1543	32	26	2	1	\N	2026-06-18 13:51:16.169918+00	2026-06-18 13:51:16.169918+00	\N	\N
1544	11	25	3	1	\N	2026-06-18 14:00:53.586285+00	2026-06-18 14:00:53.586285+00	\N	\N
1547	11	27	2	1	\N	2026-06-18 14:01:40.539723+00	2026-06-18 14:01:40.539723+00	\N	\N
1546	14	25	3	1	\N	2026-06-18 14:01:28.884724+00	2026-06-18 14:01:43.676886+00	\N	\N
1550	11	28	1	2	\N	2026-06-18 14:01:52.625519+00	2026-06-18 14:01:52.625519+00	\N	\N
1551	14	26	2	0	\N	2026-06-18 14:01:57.74972+00	2026-06-18 14:01:57.74972+00	\N	\N
1552	14	27	2	1	\N	2026-06-18 14:03:07.609791+00	2026-06-18 14:03:07.609791+00	\N	\N
1553	14	28	2	2	\N	2026-06-18 14:03:36.236542+00	2026-06-18 14:03:36.236542+00	\N	\N
1556	41	26	2	0	\N	2026-06-18 14:43:26.314253+00	2026-06-18 14:43:26.314253+00	\N	\N
1558	41	27	1	0	\N	2026-06-18 14:45:12.153468+00	2026-06-18 14:45:12.153468+00	\N	\N
1555	41	25	2	1	\N	2026-06-18 14:18:05.216643+00	2026-06-18 15:15:58.099778+00	\N	\N
1562	36	25	1	1	\N	2026-06-18 15:16:14.301676+00	2026-06-18 15:16:14.301676+00	\N	\N
1577	30	26	2	1	\N	2026-06-18 15:32:27.48075+00	2026-06-18 18:39:14.154553+00	\N	\N
1572	33	26	2	1	\N	2026-06-18 15:30:16.544801+00	2026-06-18 18:43:23.051676+00	\N	\N
1573	33	27	2	1	\N	2026-06-18 15:30:56.542608+00	2026-06-18 15:30:56.542608+00	\N	\N
1574	30	28	2	2	\N	2026-06-18 15:31:21.253026+00	2026-06-18 15:31:21.253026+00	\N	\N
1575	33	28	2	2	\N	2026-06-18 15:31:25.542896+00	2026-06-18 15:31:25.542896+00	\N	\N
1578	42	25	2	1	\N	2026-06-18 15:37:52.703768+00	2026-06-18 15:37:52.703768+00	\N	\N
1536	58	26	3	1	\N	2026-06-18 13:19:39.831161+00	2026-06-18 15:44:29.716732+00	\N	\N
1537	58	27	2	1	\N	2026-06-18 13:19:55.718298+00	2026-06-18 15:45:09.485731+00	\N	\N
1570	30	25	2	0	\N	2026-06-18 15:29:00.320603+00	2026-06-18 15:53:58.639409+00	\N	\N
1587	50	28	2	1	\N	2026-06-18 15:54:29.122149+00	2026-06-18 15:54:29.122149+00	\N	\N
1557	41	28	2	1	\N	2026-06-18 14:44:58.832283+00	2026-06-18 15:54:41.186723+00	\N	\N
1545	11	26	3	1	\N	2026-06-18 14:01:20.137344+00	2026-06-18 16:14:45.767171+00	\N	\N
1593	28	26	2	0	\N	2026-06-18 16:18:16.474886+00	2026-06-18 16:18:16.474886+00	\N	\N
1594	28	27	1	0	\N	2026-06-18 16:18:25.291482+00	2026-06-18 16:18:25.291482+00	\N	\N
1595	28	28	0	2	\N	2026-06-18 16:18:31.597364+00	2026-06-18 16:18:31.597364+00	\N	\N
1596	27	26	2	1	\N	2026-06-18 16:27:47.294296+00	2026-06-18 16:27:47.294296+00	\N	\N
1597	27	27	2	1	\N	2026-06-18 16:28:02.553304+00	2026-06-18 16:28:02.553304+00	\N	\N
1598	27	28	2	1	\N	2026-06-18 16:28:18.141843+00	2026-06-18 16:28:18.141843+00	\N	\N
1565	36	27	1	1	\N	2026-06-18 15:17:05.317163+00	2026-06-18 16:30:09.744848+00	\N	\N
1641	13	28	2	2	\N	2026-06-18 20:34:29.612888+00	2026-06-18 20:34:29.612888+00	\N	\N
1566	36	28	2	2	\N	2026-06-18 15:17:25.130971+00	2026-06-18 16:30:52.363732+00	\N	\N
1564	36	26	2	1	\N	2026-06-18 15:16:55.078415+00	2026-06-18 16:32:17.374737+00	\N	\N
1603	31	26	2	0	\N	2026-06-18 16:32:25.582077+00	2026-06-18 16:32:25.582077+00	\N	\N
1604	31	27	2	1	\N	2026-06-18 16:32:43.89158+00	2026-06-18 16:32:43.89158+00	\N	\N
1605	31	28	2	1	\N	2026-06-18 16:34:01.291167+00	2026-06-18 16:34:01.291167+00	\N	\N
1613	23	26	2	1	\N	2026-06-18 17:03:21.305014+00	2026-06-18 17:03:21.305014+00	\N	\N
1614	23	27	2	0	\N	2026-06-18 17:03:36.383084+00	2026-06-18 17:03:36.383084+00	\N	\N
1569	33	25	1	1	\N	2026-06-18 15:27:18.249955+00	2026-06-18 17:56:43.563526+00	\N	\N
1622	26	26	1	2	\N	2026-06-18 18:04:22.397066+00	2026-06-18 18:04:22.397066+00	\N	\N
1623	42	26	1	0	\N	2026-06-18 18:04:31.596465+00	2026-06-18 18:04:31.596465+00	\N	\N
1624	26	27	1	1	\N	2026-06-18 18:04:33.444584+00	2026-06-18 18:04:33.444584+00	\N	\N
1625	26	28	1	2	\N	2026-06-18 18:04:49.794927+00	2026-06-18 18:04:49.794927+00	\N	\N
1585	50	26	2	1	\N	2026-06-18 15:54:14.194768+00	2026-06-18 18:05:28.549838+00	\N	\N
3876	43	71	1	3	\N	2026-06-27 15:19:17.181813+00	2026-06-27 15:19:17.181813+00	\N	\N
1643	42	27	2	0	\N	2026-06-18 20:53:37.878624+00	2026-06-18 20:53:37.878624+00	\N	\N
1401	56	26	1	1	\N	2026-06-17 21:58:32.993922+00	2026-06-18 18:11:24.53274+00	\N	\N
1632	46	26	3	1	\N	2026-06-18 18:17:35.017526+00	2026-06-18 18:17:35.017526+00	\N	\N
1633	43	27	2	1	\N	2026-06-18 18:22:49.609636+00	2026-06-18 18:22:49.609636+00	\N	\N
1635	59	26	2	1	\N	2026-06-18 18:22:55.362381+00	2026-06-18 18:22:55.362381+00	\N	\N
1634	43	26	1	1	\N	2026-06-18 18:22:54.069277+00	2026-06-18 18:23:01.162847+00	\N	\N
1637	43	28	1	2	\N	2026-06-18 18:23:15.194576+00	2026-06-18 18:23:22.748466+00	\N	\N
1645	66	27	2	1	\N	2026-06-18 20:54:21.140395+00	2026-06-18 20:54:21.140395+00	\N	\N
1646	66	28	1	3	\N	2026-06-18 20:54:33.086591+00	2026-06-18 20:54:33.086591+00	\N	\N
1647	59	27	2	0	\N	2026-06-18 20:58:57.385215+00	2026-06-18 20:58:57.385215+00	\N	\N
1650	46	27	3	1	\N	2026-06-18 21:02:41.492028+00	2026-06-18 21:02:41.492028+00	\N	\N
1576	30	27	2	0	\N	2026-06-18 15:31:32.4819+00	2026-06-18 21:10:03.576088+00	\N	\N
1586	50	27	3	1	\N	2026-06-18 15:54:24.834567+00	2026-06-18 21:11:20.173296+00	\N	\N
1655	54	30	0	1	\N	2026-06-18 21:25:02.578661+00	2026-06-18 21:25:02.578661+00	\N	\N
1656	54	29	2	0	\N	2026-06-18 21:25:06.594767+00	2026-06-18 21:25:06.594767+00	\N	\N
1815	50	31	1	2	\N	2026-06-19 17:27:10.505908+00	2026-06-19 17:27:10.505908+00	\N	\N
1659	12	27	2	1	\N	2026-06-18 21:26:58.976489+00	2026-06-18 21:26:58.976489+00	\N	\N
1660	12	28	1	2	\N	2026-06-18 21:27:24.252381+00	2026-06-18 21:27:24.252381+00	\N	\N
1667	47	32	3	1	\N	2026-06-18 23:54:08.602196+00	2026-06-18 23:54:08.602196+00	\N	\N
1668	47	30	2	1	\N	2026-06-18 23:55:27.706801+00	2026-06-18 23:55:27.706801+00	\N	\N
1669	47	29	4	0	\N	2026-06-18 23:55:52.602586+00	2026-06-20 00:14:14.486615+00	\N	\N
1676	59	28	2	1	\N	2026-06-19 00:07:01.462456+00	2026-06-19 00:07:01.462456+00	\N	\N
1677	38	31	0	1	\N	2026-06-19 00:07:12.624395+00	2026-06-19 00:07:12.624395+00	\N	\N
1644	42	28	2	1	\N	2026-06-18 20:54:02.264388+00	2026-06-19 00:42:18.291399+00	\N	\N
1683	46	28	3	2	\N	2026-06-19 00:47:04.2464+00	2026-06-19 00:47:04.2464+00	\N	\N
1684	23	28	2	2	\N	2026-06-19 00:54:22.789177+00	2026-06-19 00:54:22.789177+00	\N	\N
1685	55	32	2	1	\N	2026-06-19 01:03:43.491725+00	2026-06-19 01:03:43.491725+00	\N	\N
1687	55	31	2	1	\N	2026-06-19 01:04:57.337918+00	2026-06-19 01:15:27.690732+00	\N	\N
1689	55	30	0	1	\N	2026-06-19 01:27:59.910832+00	2026-06-19 01:28:54.057901+00	\N	\N
1691	9	32	2	0	\N	2026-06-19 01:59:58.430942+00	2026-06-19 01:59:58.430942+00	\N	\N
1673	38	32	2	0	\N	2026-06-19 00:06:08.697198+00	2026-06-19 02:44:30.631456+00	\N	\N
1675	38	29	2	0	\N	2026-06-19 00:06:45.141722+00	2026-06-19 02:44:34.05309+00	\N	\N
1654	54	32	1	0	\N	2026-06-18 21:24:59.078204+00	2026-06-19 15:47:01.104429+00	\N	\N
1686	55	29	2	0	\N	2026-06-19 01:04:30.06527+00	2026-06-20 00:41:38.387372+00	\N	\N
1692	9	30	2	3	\N	2026-06-19 02:00:06.759566+00	2026-06-19 02:00:06.759566+00	\N	\N
1693	9	29	5	1	\N	2026-06-19 02:00:14.795317+00	2026-06-19 02:00:14.795317+00	\N	\N
1694	9	31	1	2	\N	2026-06-19 02:00:23.13203+00	2026-06-19 02:00:23.13203+00	\N	\N
1695	68	32	2	0	\N	2026-06-19 02:43:44.972722+00	2026-06-19 02:43:44.972722+00	\N	\N
1782	33	29	3	0	\N	2026-06-19 15:05:35.263868+00	2026-06-19 15:05:35.263868+00	\N	\N
1674	38	30	1	1	\N	2026-06-19 00:06:27.816898+00	2026-06-19 02:44:30.982008+00	\N	\N
1725	30	29	3	0	\N	2026-06-19 03:31:21.661148+00	2026-06-19 23:13:49.474646+00	\N	\N
1703	68	29	5	0	\N	2026-06-19 02:44:58.630087+00	2026-06-19 02:44:58.630087+00	\N	\N
1705	10	32	2	1	\N	2026-06-19 02:54:36.031433+00	2026-06-19 02:54:36.031433+00	\N	\N
1706	10	30	1	2	\N	2026-06-19 02:54:43.379252+00	2026-06-19 02:54:43.379252+00	\N	\N
1707	10	29	3	0	\N	2026-06-19 02:54:48.377382+00	2026-06-19 02:54:48.377382+00	\N	\N
1708	10	31	2	1	\N	2026-06-19 02:54:59.96821+00	2026-06-19 02:54:59.96821+00	\N	\N
1709	40	31	2	1	\N	2026-06-19 03:05:24.734751+00	2026-06-19 03:05:24.734751+00	\N	\N
1710	40	29	2	1	\N	2026-06-19 03:05:51.656367+00	2026-06-19 03:05:51.656367+00	\N	\N
1712	40	30	1	3	\N	2026-06-19 03:06:01.044221+00	2026-06-19 03:06:01.044221+00	\N	\N
1713	40	32	2	1	\N	2026-06-19 03:06:10.866679+00	2026-06-19 03:06:10.866679+00	\N	\N
1716	31	32	2	1	\N	2026-06-19 03:14:26.36889+00	2026-06-19 03:14:26.36889+00	\N	\N
1717	31	29	4	0	\N	2026-06-19 03:15:02.73493+00	2026-06-19 03:15:02.73493+00	\N	\N
1719	31	31	1	2	\N	2026-06-19 03:15:23.408827+00	2026-06-19 03:15:23.408827+00	\N	\N
1721	37	30	0	2	\N	2026-06-19 03:16:45.517577+00	2026-06-19 03:16:45.517577+00	\N	\N
1722	37	29	5	0	\N	2026-06-19 03:17:01.622945+00	2026-06-19 03:17:01.622945+00	\N	\N
1723	30	32	4	1	\N	2026-06-19 03:30:13.449249+00	2026-06-19 03:30:13.449249+00	\N	\N
1726	59	32	3	1	\N	2026-06-19 03:49:04.872584+00	2026-06-19 03:49:04.872584+00	\N	\N
1727	59	30	1	1	\N	2026-06-19 03:50:27.962615+00	2026-06-19 03:50:27.962615+00	\N	\N
1728	27	32	3	1	\N	2026-06-19 04:05:31.896928+00	2026-06-19 04:05:31.896928+00	\N	\N
1729	27	29	3	0	\N	2026-06-19 04:05:39.898072+00	2026-06-19 04:05:39.898072+00	\N	\N
1730	27	31	1	2	\N	2026-06-19 04:05:50.836155+00	2026-06-19 04:06:07.148731+00	\N	\N
1732	27	30	0	2	\N	2026-06-19 04:06:15.300758+00	2026-06-19 04:06:15.300758+00	\N	\N
1733	12	32	2	0	\N	2026-06-19 09:37:44.695376+00	2026-06-19 09:37:44.695376+00	\N	\N
1734	12	30	0	2	\N	2026-06-19 09:38:20.025178+00	2026-06-19 09:38:20.025178+00	\N	\N
1735	12	29	3	0	\N	2026-06-19 09:38:29.826596+00	2026-06-19 09:38:29.826596+00	\N	\N
1736	34	32	2	1	\N	2026-06-19 11:52:52.929399+00	2026-06-19 11:52:52.929399+00	\N	\N
1737	34	30	0	2	\N	2026-06-19 11:53:03.75588+00	2026-06-19 11:53:03.75588+00	\N	\N
1738	34	29	3	0	\N	2026-06-19 11:53:09.821563+00	2026-06-19 11:53:09.821563+00	\N	\N
1739	34	31	0	1	\N	2026-06-19 11:53:19.375549+00	2026-06-19 11:53:19.375549+00	\N	\N
1740	16	32	2	1	\N	2026-06-19 12:22:42.363387+00	2026-06-19 12:22:42.363387+00	\N	\N
1741	16	30	1	3	\N	2026-06-19 12:22:53.429013+00	2026-06-19 12:22:53.429013+00	\N	\N
1742	16	29	3	0	\N	2026-06-19 12:23:07.171213+00	2026-06-19 12:23:07.171213+00	\N	\N
1743	16	31	1	1	\N	2026-06-19 12:23:18.547144+00	2026-06-19 12:23:18.547144+00	\N	\N
1744	43	32	2	1	\N	2026-06-19 12:24:04.638204+00	2026-06-19 12:24:04.638204+00	\N	\N
1745	43	30	0	1	\N	2026-06-19 12:24:09.205947+00	2026-06-19 12:24:09.205947+00	\N	\N
3877	43	72	1	1	\N	2026-06-27 15:19:31.637725+00	2026-06-27 15:19:31.637725+00	\N	\N
1747	43	31	3	1	\N	2026-06-19 12:24:54.900299+00	2026-06-19 12:24:54.900299+00	\N	\N
1748	32	32	2	2	\N	2026-06-19 12:28:37.601843+00	2026-06-19 12:28:37.601843+00	\N	\N
1749	32	30	3	2	\N	2026-06-19 12:29:16.896403+00	2026-06-19 12:29:16.896403+00	\N	\N
1750	32	29	3	2	\N	2026-06-19 12:29:34.904543+00	2026-06-19 12:29:34.904543+00	\N	\N
1783	33	31	1	2	\N	2026-06-19 15:06:47.79565+00	2026-06-19 15:06:47.79565+00	\N	\N
1755	45	32	2	1	\N	2026-06-19 13:05:48.641438+00	2026-06-19 13:05:48.641438+00	\N	\N
1756	45	30	1	1	\N	2026-06-19 13:05:59.947155+00	2026-06-19 13:05:59.947155+00	\N	\N
1757	45	29	4	0	\N	2026-06-19 13:06:07.983325+00	2026-06-19 13:06:07.983325+00	\N	\N
1758	45	31	1	1	\N	2026-06-19 13:06:17.707108+00	2026-06-19 13:06:17.707108+00	\N	\N
1704	68	31	1	3	\N	2026-06-19 02:45:12.173722+00	2026-06-19 17:36:19.304732+00	\N	\N
1762	11	32	3	1	\N	2026-06-19 13:51:43.192862+00	2026-06-19 13:51:43.192862+00	\N	\N
1763	11	30	1	2	\N	2026-06-19 13:52:03.299722+00	2026-06-19 13:52:03.299722+00	\N	\N
1718	31	30	1	2	\N	2026-06-19 03:15:10.53872+00	2026-06-19 13:55:32.804531+00	\N	\N
1765	11	29	3	0	\N	2026-06-19 14:01:24.211007+00	2026-06-19 14:01:24.211007+00	\N	\N
1766	11	31	2	1	\N	2026-06-19 14:01:39.119402+00	2026-06-19 14:02:11.219279+00	\N	\N
1772	14	32	3	1	\N	2026-06-19 14:32:42.6583+00	2026-06-19 14:32:42.6583+00	\N	\N
1774	14	29	4	0	\N	2026-06-19 14:32:55.258664+00	2026-06-19 14:32:55.258664+00	\N	\N
1775	14	31	2	1	\N	2026-06-19 14:33:02.570598+00	2026-06-19 14:33:02.570598+00	\N	\N
1773	14	30	1	2	\N	2026-06-19 14:32:51.720763+00	2026-06-19 14:35:02.622334+00	\N	\N
1778	56	29	4	0	\N	2026-06-19 14:35:45.032162+00	2026-06-19 14:35:45.032162+00	\N	\N
1780	33	32	3	1	\N	2026-06-19 15:05:08.110778+00	2026-06-19 15:05:08.110778+00	\N	\N
1785	44	32	3	1	\N	2026-06-19 15:24:00.69044+00	2026-06-19 15:24:00.69044+00	\N	\N
1786	24	32	2	1	\N	2026-06-19 15:26:22.417733+00	2026-06-19 15:26:22.417733+00	\N	\N
1761	41	30	1	2	\N	2026-06-19 13:41:54.472333+00	2026-06-19 21:32:31.975499+00	\N	\N
1792	44	30	1	2	\N	2026-06-19 15:59:51.482424+00	2026-06-19 15:59:51.482424+00	\N	\N
1793	44	29	6	0	\N	2026-06-19 16:00:53.574835+00	2026-06-19 16:00:53.574835+00	\N	\N
1794	44	31	1	2	\N	2026-06-19 16:01:06.426725+00	2026-06-19 16:01:53.833739+00	\N	\N
1724	30	30	1	2	\N	2026-06-19 03:30:31.691159+00	2026-06-19 21:18:21.219787+00	\N	\N
1797	30	31	1	2	\N	2026-06-19 16:05:04.906235+00	2026-06-19 16:05:04.906235+00	\N	\N
1769	36	32	2	1	\N	2026-06-19 14:16:23.587279+00	2026-06-19 16:14:25.593326+00	\N	\N
1770	36	30	2	2	\N	2026-06-19 14:19:51.144352+00	2026-06-19 16:15:00.218543+00	\N	\N
1771	36	29	4	0	\N	2026-06-19 14:20:06.464097+00	2026-06-19 16:16:57.03727+00	\N	\N
1784	36	31	1	2	\N	2026-06-19 15:16:45.661731+00	2026-06-19 16:17:09.153893+00	\N	\N
1802	35	32	3	1	\N	2026-06-19 16:21:08.048292+00	2026-06-19 16:21:08.048292+00	\N	\N
1803	28	32	3	0	\N	2026-06-19 16:22:43.890861+00	2026-06-19 16:22:43.890861+00	\N	\N
1804	28	30	0	3	\N	2026-06-19 16:22:54.903737+00	2026-06-19 16:22:54.903737+00	\N	\N
1805	28	29	3	0	\N	2026-06-19 16:23:02.080267+00	2026-06-19 16:23:02.080267+00	\N	\N
1806	28	31	1	1	\N	2026-06-19 16:23:10.07758+00	2026-06-19 16:23:10.07758+00	\N	\N
1791	41	29	4	0	\N	2026-06-19 15:59:02.993846+00	2026-06-19 17:30:26.704975+00	\N	\N
1759	41	32	3	1	\N	2026-06-19 13:34:39.420726+00	2026-06-19 17:31:21.777104+00	\N	\N
1406	56	32	2	1	\N	2026-06-17 21:59:47.088101+00	2026-06-19 17:38:19.728446+00	\N	\N
1779	56	30	0	1	\N	2026-06-19 14:35:54.461108+00	2026-06-19 17:38:38.880814+00	\N	\N
1822	58	30	0	2	\N	2026-06-19 17:38:46.922989+00	2026-06-19 17:38:46.922989+00	\N	\N
1823	58	29	3	0	\N	2026-06-19 17:39:21.541901+00	2026-06-19 17:39:21.541901+00	\N	\N
1711	13	32	3	1	\N	2026-06-19 03:05:56.036995+00	2026-06-19 17:56:14.227003+00	\N	\N
1715	13	30	1	2	\N	2026-06-19 03:06:32.425657+00	2026-06-19 18:49:25.535773+00	\N	\N
1720	37	32	3	1	\N	2026-06-19 03:15:52.619378+00	2026-06-19 18:41:59.369618+00	\N	\N
1714	13	31	2	0	\N	2026-06-19 03:06:18.371677+00	2026-06-19 18:51:02.501911+00	\N	\N
1657	54	31	1	1	\N	2026-06-18 21:25:11.42157+00	2026-06-19 20:16:07.407725+00	\N	\N
1781	33	30	0	2	\N	2026-06-19 15:05:29.021343+00	2026-06-19 21:18:32.18268+00	\N	\N
1697	68	30	1	2	\N	2026-06-19 02:43:53.692629+00	2026-06-19 21:55:06.837845+00	\N	\N
1752	37	31	1	2	\N	2026-06-19 12:43:37.677812+00	2026-06-20 02:34:45.430438+00	\N	\N
1751	32	31	1	2	\N	2026-06-19 12:30:00.501051+00	2026-06-20 02:57:00.033635+00	\N	\N
1777	56	31	1	1	\N	2026-06-19 14:35:37.206971+00	2026-06-19 17:39:47.103722+00	\N	\N
1825	58	31	1	2	\N	2026-06-19 17:39:59.166396+00	2026-06-19 17:39:59.166396+00	\N	\N
1827	29	32	2	1	\N	2026-06-19 18:03:28.545342+00	2026-06-19 18:03:28.545342+00	\N	\N
1828	29	30	2	1	\N	2026-06-19 18:03:37.306007+00	2026-06-19 18:03:37.306007+00	\N	\N
1829	29	29	3	0	\N	2026-06-19 18:03:42.775873+00	2026-06-19 18:03:42.775873+00	\N	\N
1830	29	31	0	2	\N	2026-06-19 18:03:52.722936+00	2026-06-19 18:03:52.722936+00	\N	\N
1831	66	32	2	1	\N	2026-06-19 18:23:03.303021+00	2026-06-19 18:23:03.303021+00	\N	\N
1832	66	30	1	2	\N	2026-06-19 18:23:36.853732+00	2026-06-19 18:23:36.853732+00	\N	\N
1833	66	29	3	0	\N	2026-06-19 18:23:57.435319+00	2026-06-19 18:23:57.435319+00	\N	\N
1834	66	31	1	1	\N	2026-06-19 18:24:21.156982+00	2026-06-19 18:24:21.156982+00	\N	\N
1835	24	30	0	2	\N	2026-06-19 18:32:23.054068+00	2026-06-19 18:32:23.054068+00	\N	\N
1836	24	29	2	0	\N	2026-06-19 18:32:31.140722+00	2026-06-19 18:32:31.140722+00	\N	\N
1837	24	31	0	1	\N	2026-06-19 18:32:40.154392+00	2026-06-19 18:32:40.154392+00	\N	\N
1838	23	32	3	1	\N	2026-06-19 18:33:57.753481+00	2026-06-19 18:34:18.395194+00	\N	\N
1840	48	32	2	1	\N	2026-06-19 18:36:19.759451+00	2026-06-19 18:36:19.759451+00	\N	\N
1841	26	32	2	2	\N	2026-06-19 18:37:31.148553+00	2026-06-19 18:37:31.148553+00	\N	\N
1842	26	30	0	2	\N	2026-06-19 18:37:47.169029+00	2026-06-19 18:37:47.169029+00	\N	\N
1845	25	32	2	0	\N	2026-06-19 18:46:23.580846+00	2026-06-19 18:46:23.580846+00	\N	\N
1846	25	30	0	3	\N	2026-06-19 18:46:33.983362+00	2026-06-19 18:46:33.983362+00	\N	\N
1847	25	29	5	0	\N	2026-06-19 18:46:41.945182+00	2026-06-19 18:46:41.945182+00	\N	\N
1848	25	31	1	2	\N	2026-06-19 18:46:50.803623+00	2026-06-19 18:46:50.803623+00	\N	\N
1849	25	35	3	0	\N	2026-06-19 18:47:06.346738+00	2026-06-19 18:47:06.346738+00	\N	\N
1850	25	33	3	0	\N	2026-06-19 18:47:13.775134+00	2026-06-19 18:47:13.775134+00	\N	\N
1851	25	34	3	0	\N	2026-06-19 18:47:20.07835+00	2026-06-19 18:47:20.07835+00	\N	\N
1852	25	36	0	2	\N	2026-06-19 18:47:28.644534+00	2026-06-19 18:47:28.644534+00	\N	\N
1853	25	37	3	0	\N	2026-06-19 18:47:50.83325+00	2026-06-19 18:47:50.83325+00	\N	\N
1854	25	39	4	0	\N	2026-06-19 18:48:06.130781+00	2026-06-19 18:48:06.130781+00	\N	\N
1855	25	38	4	0	\N	2026-06-19 18:48:11.80336+00	2026-06-19 18:48:11.80336+00	\N	\N
1856	25	40	1	1	\N	2026-06-19 18:48:28.493725+00	2026-06-19 18:48:28.493725+00	\N	\N
1858	13	29	4	0	\N	2026-06-19 18:49:54.472724+00	2026-06-19 18:49:54.472724+00	\N	\N
1860	26	29	4	0	\N	2026-06-19 18:54:19.979083+00	2026-06-19 18:54:19.979083+00	\N	\N
1861	26	31	1	2	\N	2026-06-19 18:54:35.293486+00	2026-06-19 18:54:51.292389+00	\N	\N
1864	42	29	3	0	\N	2026-06-19 19:09:48.703902+00	2026-06-19 19:09:48.703902+00	\N	\N
1865	51	30	0	1	\N	2026-06-19 19:32:55.4854+00	2026-06-19 19:32:55.4854+00	\N	\N
1866	51	29	3	0	\N	2026-06-19 19:33:50.530072+00	2026-06-19 19:33:50.530072+00	\N	\N
1868	54	35	2	1	\N	2026-06-19 20:16:41.020503+00	2026-06-19 20:16:41.020503+00	\N	\N
1869	54	33	2	0	\N	2026-06-19 20:16:47.279025+00	2026-06-19 20:16:47.279025+00	\N	\N
1870	54	34	2	0	\N	2026-06-19 20:16:52.206153+00	2026-06-19 20:16:52.206153+00	\N	\N
1871	54	36	1	1	\N	2026-06-19 20:17:00.958727+00	2026-06-19 20:17:00.958727+00	\N	\N
1872	54	38	2	1	\N	2026-06-19 20:17:10.282448+00	2026-06-19 20:17:10.282448+00	\N	\N
1873	54	39	2	0	\N	2026-06-19 20:17:13.855764+00	2026-06-19 20:17:13.855764+00	\N	\N
1874	54	37	2	0	\N	2026-06-19 20:17:18.230771+00	2026-06-19 20:17:18.230771+00	\N	\N
1875	54	40	1	1	\N	2026-06-19 20:17:27.933109+00	2026-06-19 20:18:04.303396+00	\N	\N
1877	54	43	2	0	\N	2026-06-19 20:18:12.219549+00	2026-06-19 20:18:12.219549+00	\N	\N
1879	54	41	2	1	\N	2026-06-19 20:18:34.805055+00	2026-06-19 20:18:34.805055+00	\N	\N
1881	23	30	0	2	\N	2026-06-19 21:04:40.202895+00	2026-06-19 21:04:47.903185+00	\N	\N
1883	23	29	3	0	\N	2026-06-19 21:05:10.639141+00	2026-06-19 21:05:10.639141+00	\N	\N
1884	23	31	2	1	\N	2026-06-19 21:05:35.462984+00	2026-06-19 21:05:35.462984+00	\N	\N
1886	48	30	1	3	\N	2026-06-19 21:16:27.903518+00	2026-06-19 21:16:27.903518+00	\N	\N
1887	46	30	1	2	\N	2026-06-19 21:17:51.443737+00	2026-06-19 21:17:51.443737+00	\N	\N
1863	42	30	0	1	\N	2026-06-19 19:09:41.254109+00	2026-06-19 21:59:49.176488+00	\N	\N
1814	50	29	3	0	\N	2026-06-19 17:27:05.648257+00	2026-06-19 23:58:36.438324+00	\N	\N
1897	46	29	3	0	\N	2026-06-20 00:09:27.41499+00	2026-06-20 00:09:27.41499+00	\N	\N
1671	47	31	1	3	\N	2026-06-18 23:56:09.763073+00	2026-06-20 00:11:54.079444+00	\N	\N
1901	59	29	2	1	\N	2026-06-20 00:17:24.226482+00	2026-06-20 00:17:24.226482+00	\N	\N
1746	43	29	3	0	\N	2026-06-19 12:24:22.50253+00	2026-06-20 00:20:32.185422+00	\N	\N
1905	48	31	1	2	\N	2026-06-20 01:15:39.835126+00	2026-06-20 01:15:39.835126+00	\N	\N
1928	9	35	2	1	\N	2026-06-20 02:44:38.665263+00	2026-06-20 02:44:38.665263+00	\N	\N
1908	38	33	2	0	\N	2026-06-20 01:38:44.62226+00	2026-06-20 01:38:53.767762+00	\N	\N
1910	38	34	1	0	\N	2026-06-20 01:39:06.334077+00	2026-06-20 01:39:06.334077+00	\N	\N
1911	38	36	0	1	\N	2026-06-20 01:39:39.558669+00	2026-06-20 01:39:39.558669+00	\N	\N
1906	38	35	2	2	\N	2026-06-20 01:38:16.228534+00	2026-06-20 01:39:51.533307+00	\N	\N
1913	41	31	1	1	\N	2026-06-20 02:19:44.704519+00	2026-06-20 02:19:44.704519+00	\N	\N
1914	59	31	2	1	\N	2026-06-20 02:33:31.076967+00	2026-06-20 02:33:31.076967+00	\N	\N
1885	42	31	1	2	\N	2026-06-19 21:10:24.463202+00	2026-06-20 02:36:10.32852+00	\N	\N
1929	9	33	3	1	\N	2026-06-20 02:44:45.335198+00	2026-06-20 02:44:45.335198+00	\N	\N
1894	51	31	1	0	\N	2026-06-19 22:58:01.121388+00	2026-06-20 02:37:42.832408+00	\N	\N
1919	27	36	0	3	\N	2026-06-20 02:38:13.626674+00	2026-06-20 02:38:13.626674+00	\N	\N
1921	27	33	3	1	\N	2026-06-20 02:38:48.189292+00	2026-06-20 02:38:48.189292+00	\N	\N
1922	27	35	2	1	\N	2026-06-20 02:38:55.509078+00	2026-06-20 02:38:55.509078+00	\N	\N
1923	55	35	3	1	\N	2026-06-20 02:43:02.570722+00	2026-06-20 02:43:02.570722+00	\N	\N
1924	12	31	2	1	\N	2026-06-20 02:43:07.329773+00	2026-06-20 02:43:07.329773+00	\N	\N
1925	55	33	3	0	\N	2026-06-20 02:43:15.12224+00	2026-06-20 02:43:15.12224+00	\N	\N
1926	55	34	2	2	\N	2026-06-20 02:43:26.869157+00	2026-06-20 02:43:26.869157+00	\N	\N
1927	55	36	1	2	\N	2026-06-20 02:43:44.015234+00	2026-06-20 02:43:44.015234+00	\N	\N
1930	9	34	3	0	\N	2026-06-20 02:44:52.674132+00	2026-06-20 02:44:52.674132+00	\N	\N
1931	9	36	0	1	\N	2026-06-20 02:45:03.410531+00	2026-06-20 02:45:03.410531+00	\N	\N
1932	46	31	2	2	\N	2026-06-20 02:49:05.342874+00	2026-06-20 02:49:05.342874+00	\N	\N
1935	14	35	2	1	\N	2026-06-20 05:01:10.328522+00	2026-06-20 05:01:10.328522+00	\N	\N
1936	14	33	3	1	\N	2026-06-20 05:01:20.889012+00	2026-06-20 05:01:20.889012+00	\N	\N
1937	14	34	2	0	\N	2026-06-20 05:01:31.586849+00	2026-06-20 05:01:31.586849+00	\N	\N
1938	14	36	0	3	\N	2026-06-20 05:01:39.881448+00	2026-06-20 05:01:39.881448+00	\N	\N
1939	14	38	3	0	\N	2026-06-20 05:02:21.792678+00	2026-06-20 05:02:21.792678+00	\N	\N
1940	14	39	3	1	\N	2026-06-20 05:02:31.337938+00	2026-06-20 05:02:31.337938+00	\N	\N
1941	14	37	3	0	\N	2026-06-20 05:02:40.636444+00	2026-06-20 05:02:40.636444+00	\N	\N
1942	14	40	2	2	\N	2026-06-20 05:02:52.05666+00	2026-06-20 05:02:52.05666+00	\N	\N
1943	50	35	2	1	\N	2026-06-20 05:08:16.035912+00	2026-06-20 05:08:16.035912+00	\N	\N
1944	46	35	3	2	\N	2026-06-20 05:12:20.022643+00	2026-06-20 05:12:20.022643+00	\N	\N
1946	28	35	2	0	\N	2026-06-20 11:59:59.030748+00	2026-06-20 11:59:59.030748+00	\N	\N
3878	43	70	1	2	\N	2026-06-27 15:19:39.339949+00	2026-06-27 15:19:39.339949+00	\N	\N
1948	28	34	1	0	\N	2026-06-20 12:00:55.358737+00	2026-06-20 12:00:55.358737+00	\N	\N
1945	51	35	2	1	\N	2026-06-20 11:38:33.92477+00	2026-06-20 15:24:02.993886+00	\N	\N
1899	47	34	3	0	\N	2026-06-20 00:13:01.315353+00	2026-06-20 16:18:30.296864+00	\N	\N
1920	27	34	4	1	\N	2026-06-20 02:38:23.515092+00	2026-06-20 22:02:58.988917+00	\N	\N
1878	54	42	3	0	\N	2026-06-19 20:18:16.320908+00	2026-06-22 16:55:37.808358+00	\N	\N
1880	54	44	1	1	\N	2026-06-19 20:18:40.377925+00	2026-06-22 16:55:57.337539+00	\N	\N
1949	28	36	0	2	\N	2026-06-20 12:01:10.601103+00	2026-06-20 12:01:10.601103+00	\N	\N
1947	28	33	3	1	\N	2026-06-20 12:00:15.579938+00	2026-06-20 12:01:45.340134+00	\N	\N
1951	40	35	2	1	\N	2026-06-20 12:04:27.301143+00	2026-06-20 12:04:27.301143+00	\N	\N
1952	40	33	2	1	\N	2026-06-20 12:05:41.761322+00	2026-06-20 12:05:41.761322+00	\N	\N
1953	40	34	3	1	\N	2026-06-20 12:06:43.916774+00	2026-06-20 12:06:43.916774+00	\N	\N
1954	40	36	0	2	\N	2026-06-20 12:07:42.57437+00	2026-06-20 12:07:42.57437+00	\N	\N
1956	32	35	2	0	\N	2026-06-20 12:22:02.383815+00	2026-06-20 12:22:02.383815+00	\N	\N
1958	32	34	2	2	\N	2026-06-20 12:22:35.935435+00	2026-06-20 12:22:35.935435+00	\N	\N
1955	32	36	1	1	\N	2026-06-20 12:21:45.130669+00	2026-06-20 12:22:52.17502+00	\N	\N
1960	11	35	3	2	\N	2026-06-20 12:23:41.121728+00	2026-06-20 12:23:41.121728+00	\N	\N
1962	11	36	1	2	\N	2026-06-20 12:24:54.962836+00	2026-06-20 12:24:54.962836+00	\N	\N
1963	13	35	2	1	\N	2026-06-20 12:40:12.635123+00	2026-06-20 12:40:12.635123+00	\N	\N
1964	13	33	4	1	\N	2026-06-20 12:40:22.318334+00	2026-06-20 12:40:22.318334+00	\N	\N
1965	13	34	2	0	\N	2026-06-20 12:40:30.200302+00	2026-06-20 12:40:30.200302+00	\N	\N
1970	34	35	2	1	\N	2026-06-20 13:00:16.445171+00	2026-06-20 13:00:16.445171+00	\N	\N
1971	34	33	4	0	\N	2026-06-20 13:00:28.715451+00	2026-06-20 13:00:28.715451+00	\N	\N
1972	34	34	3	0	\N	2026-06-20 13:00:39.572563+00	2026-06-20 13:00:39.572563+00	\N	\N
1973	34	36	1	3	\N	2026-06-20 13:00:52.199923+00	2026-06-20 13:00:52.199923+00	\N	\N
1968	37	36	1	3	\N	2026-06-20 12:59:34.556235+00	2026-06-20 13:02:30.817161+00	\N	\N
1967	37	33	4	1	\N	2026-06-20 12:59:04.376723+00	2026-06-20 13:02:56.229885+00	\N	\N
1976	31	35	1	0	\N	2026-06-20 13:06:41.903612+00	2026-06-20 13:06:41.903612+00	\N	\N
1977	31	33	2	0	\N	2026-06-20 13:07:05.351038+00	2026-06-20 13:07:05.351038+00	\N	\N
1978	31	34	3	0	\N	2026-06-20 13:07:28.245004+00	2026-06-20 13:07:28.245004+00	\N	\N
1979	31	36	1	1	\N	2026-06-20 13:08:04.999176+00	2026-06-20 13:08:04.999176+00	\N	\N
1980	36	35	2	1	\N	2026-06-20 13:21:29.804235+00	2026-06-20 13:21:29.804235+00	\N	\N
3879	43	69	1	1	\N	2026-06-27 15:20:02.350089+00	2026-06-27 15:20:02.350089+00	\N	\N
1984	36	38	3	1	\N	2026-06-20 13:22:30.82522+00	2026-06-20 13:22:30.82522+00	\N	\N
1985	36	39	0	3	\N	2026-06-20 13:22:46.542441+00	2026-06-20 13:22:46.542441+00	\N	\N
1988	59	33	3	1	\N	2026-06-20 13:48:11.721121+00	2026-06-20 13:48:11.721121+00	\N	\N
1989	59	35	1	1	\N	2026-06-20 13:48:27.290775+00	2026-06-20 13:48:27.290775+00	\N	\N
1990	59	34	2	0	\N	2026-06-20 13:49:50.803131+00	2026-06-20 13:49:50.803131+00	\N	\N
2056	58	35	2	1	\N	2026-06-20 16:45:17.717375+00	2026-06-20 16:45:17.717375+00	\N	\N
2000	48	33	4	2	\N	2026-06-20 14:20:39.91219+00	2026-06-20 14:20:39.91219+00	\N	\N
2001	48	35	1	2	\N	2026-06-20 14:20:47.599728+00	2026-06-20 14:20:47.599728+00	\N	\N
2002	48	34	1	1	\N	2026-06-20 14:20:57.371257+00	2026-06-20 14:20:57.371257+00	\N	\N
2006	35	36	1	2	\N	2026-06-20 14:24:45.910415+00	2026-06-20 14:24:45.910415+00	\N	\N
2007	35	35	0	2	\N	2026-06-20 14:25:06.883346+00	2026-06-20 14:25:06.883346+00	\N	\N
2008	43	35	2	0	\N	2026-06-20 14:32:19.890307+00	2026-06-20 14:32:19.890307+00	\N	\N
2009	43	33	4	0	\N	2026-06-20 14:32:23.997108+00	2026-06-20 14:32:23.997108+00	\N	\N
2010	43	34	2	0	\N	2026-06-20 14:32:31.279862+00	2026-06-20 14:32:31.279862+00	\N	\N
2011	43	36	1	2	\N	2026-06-20 14:32:37.957548+00	2026-06-20 14:32:37.957548+00	\N	\N
2013	41	34	2	0	\N	2026-06-20 15:05:29.098734+00	2026-06-20 15:05:29.098734+00	\N	\N
2014	33	35	3	1	\N	2026-06-20 15:23:17.156262+00	2026-06-20 15:23:17.156262+00	\N	\N
2015	33	33	3	1	\N	2026-06-20 15:23:35.173417+00	2026-06-20 15:23:35.173417+00	\N	\N
2016	33	34	2	1	\N	2026-06-20 15:23:48.390552+00	2026-06-20 15:23:48.390552+00	\N	\N
2019	51	33	3	1	\N	2026-06-20 15:24:23.911971+00	2026-06-20 15:24:23.911971+00	\N	\N
2020	51	34	2	0	\N	2026-06-20 15:24:30.145514+00	2026-06-20 15:24:30.145514+00	\N	\N
2003	48	36	1	2	\N	2026-06-20 14:21:06.134123+00	2026-06-21 03:25:27.098269+00	\N	\N
2023	44	36	1	2	\N	2026-06-20 15:29:59.092195+00	2026-06-20 15:29:59.092195+00	\N	\N
2024	44	34	3	0	\N	2026-06-20 15:30:01.630724+00	2026-06-20 15:30:11.715259+00	\N	\N
2026	44	33	2	0	\N	2026-06-20 15:30:21.155578+00	2026-06-20 15:30:21.155578+00	\N	\N
2027	44	35	2	1	\N	2026-06-20 15:30:28.174397+00	2026-06-20 15:30:28.174397+00	\N	\N
2029	68	33	3	0	\N	2026-06-20 15:39:19.384246+00	2026-06-20 15:39:19.384246+00	\N	\N
2030	68	34	2	0	\N	2026-06-20 15:39:28.18619+00	2026-06-20 15:39:28.18619+00	\N	\N
2031	68	36	0	3	\N	2026-06-20 15:39:45.133767+00	2026-06-20 15:39:45.133767+00	\N	\N
2028	68	35	3	1	\N	2026-06-20 15:39:12.032559+00	2026-06-20 15:40:16.752368+00	\N	\N
2012	41	35	2	1	\N	2026-06-20 15:05:07.909517+00	2026-06-20 15:41:47.361174+00	\N	\N
2034	16	35	2	1	\N	2026-06-20 15:47:29.471471+00	2026-06-20 15:47:29.471471+00	\N	\N
2036	16	34	3	0	\N	2026-06-20 15:47:55.222428+00	2026-06-20 15:47:55.222428+00	\N	\N
2037	16	36	1	3	\N	2026-06-20 15:48:04.164655+00	2026-06-20 15:48:04.164655+00	\N	\N
2041	50	33	3	1	\N	2026-06-20 16:05:21.406288+00	2026-06-20 16:05:21.406288+00	\N	\N
1966	37	35	1	2	\N	2026-06-20 12:58:46.734431+00	2026-06-20 15:50:41.640719+00	\N	\N
2040	23	35	2	2	\N	2026-06-20 16:03:06.396227+00	2026-06-20 16:03:06.396227+00	\N	\N
2042	50	34	3	0	\N	2026-06-20 16:05:36.462333+00	2026-06-20 16:05:36.462333+00	\N	\N
2052	47	36	0	3	\N	2026-06-20 16:21:38.086835+00	2026-06-20 16:21:38.086835+00	\N	\N
2053	30	35	2	1	\N	2026-06-20 16:31:35.112445+00	2026-06-20 16:31:35.112445+00	\N	\N
2054	23	33	3	1	\N	2026-06-20 16:37:21.809496+00	2026-06-20 16:37:21.809496+00	\N	\N
2044	47	35	3	1	\N	2026-06-20 16:12:38.133511+00	2026-06-20 16:16:06.524353+00	\N	\N
2051	11	33	4	1	\N	2026-06-20 16:20:53.006808+00	2026-06-20 16:20:53.006808+00	\N	\N
2063	58	36	1	2	\N	2026-06-20 16:48:18.196812+00	2026-06-20 16:48:18.196812+00	\N	\N
1992	56	35	2	1	\N	2026-06-20 14:11:02.04524+00	2026-06-20 16:45:19.179744+00	\N	\N
2058	58	33	3	1	\N	2026-06-20 16:46:00.487727+00	2026-06-20 16:46:00.487727+00	\N	\N
1994	56	34	3	1	\N	2026-06-20 14:11:11.396676+00	2026-06-20 16:46:35.568152+00	\N	\N
2061	58	34	3	0	\N	2026-06-20 16:47:05.511253+00	2026-06-20 16:47:05.511253+00	\N	\N
1993	56	33	3	1	\N	2026-06-20 14:11:07.707078+00	2026-06-20 16:47:11.727721+00	\N	\N
1996	56	36	0	2	\N	2026-06-20 14:11:26.792226+00	2026-06-20 16:48:44.25451+00	\N	\N
1981	36	33	2	2	\N	2026-06-20 13:21:43.464733+00	2026-06-20 16:50:50.317279+00	\N	\N
2066	24	35	2	1	\N	2026-06-20 16:53:03.514091+00	2026-06-20 16:53:14.32273+00	\N	\N
2068	24	33	2	1	\N	2026-06-20 16:53:28.383381+00	2026-06-20 16:53:28.383381+00	\N	\N
2069	24	34	2	0	\N	2026-06-20 16:53:36.389967+00	2026-06-20 16:53:36.389967+00	\N	\N
2070	42	35	1	0	\N	2026-06-20 16:53:39.673609+00	2026-06-20 16:53:39.673609+00	\N	\N
2071	24	36	1	2	\N	2026-06-20 16:53:46.150281+00	2026-06-20 16:53:46.150281+00	\N	\N
1983	36	36	1	2	\N	2026-06-20 13:22:10.668369+00	2026-06-20 16:54:51.113895+00	\N	\N
2018	33	36	1	3	\N	2026-06-20 15:24:17.348026+00	2026-06-20 18:52:09.972388+00	\N	\N
2035	16	33	3	1	\N	2026-06-20 15:47:44.111776+00	2026-06-20 19:08:37.3242+00	\N	\N
1957	32	33	3	2	\N	2026-06-20 12:22:19.335096+00	2026-06-20 19:33:18.461363+00	\N	\N
2004	35	33	4	1	\N	2026-06-20 14:24:28.51468+00	2026-06-20 19:46:13.952146+00	\N	\N
2045	47	33	4	1	\N	2026-06-20 16:15:27.291182+00	2026-06-20 19:54:26.319621+00	\N	\N
2043	50	36	1	3	\N	2026-06-20 16:05:41.224798+00	2026-06-20 22:00:04.771223+00	\N	\N
1961	11	34	2	1	\N	2026-06-20 12:24:19.740248+00	2026-06-20 22:06:18.273277+00	\N	\N
1969	37	34	2	1	\N	2026-06-20 12:59:44.088942+00	2026-06-20 23:08:16.156255+00	\N	\N
2005	35	34	2	0	\N	2026-06-20 14:24:37.418525+00	2026-06-20 23:41:01.563376+00	\N	\N
2021	51	36	0	1	\N	2026-06-20 15:24:32.826387+00	2026-06-21 02:54:28.990168+00	\N	\N
1987	36	40	1	2	\N	2026-06-20 13:23:13.962493+00	2026-06-21 21:02:48.894774+00	\N	\N
1986	36	37	3	1	\N	2026-06-20 13:23:01.541742+00	2026-06-21 21:04:39.351993+00	\N	\N
2196	23	39	2	0	\N	2026-06-21 12:35:10.179733+00	2026-06-21 18:24:15.477731+00	\N	\N
1982	36	34	3	1	\N	2026-06-20 13:21:55.610659+00	2026-06-20 16:54:43.551571+00	\N	\N
2078	12	35	2	1	\N	2026-06-20 16:58:25.465419+00	2026-06-20 16:58:25.465419+00	\N	\N
2077	45	35	2	1	\N	2026-06-20 16:56:25.106241+00	2026-06-20 16:58:29.972243+00	\N	\N
2080	13	36	1	3	\N	2026-06-20 16:59:12.426237+00	2026-06-20 16:59:12.426237+00	\N	\N
2081	45	33	3	0	\N	2026-06-20 17:00:32.506914+00	2026-06-20 17:00:32.506914+00	\N	\N
2082	45	34	2	0	\N	2026-06-20 17:01:21.360452+00	2026-06-20 17:01:21.360452+00	\N	\N
2083	45	36	1	2	\N	2026-06-20 17:01:33.418806+00	2026-06-20 17:01:33.418806+00	\N	\N
2084	66	33	3	1	\N	2026-06-20 17:06:12.959667+00	2026-06-20 17:06:12.959667+00	\N	\N
2085	66	34	2	0	\N	2026-06-20 17:06:33.429217+00	2026-06-20 17:06:41.624575+00	\N	\N
2087	66	36	0	1	\N	2026-06-20 17:06:51.587583+00	2026-06-20 17:06:51.587583+00	\N	\N
2088	10	33	3	1	\N	2026-06-20 17:17:21.867725+00	2026-06-20 17:17:21.867725+00	\N	\N
2089	10	34	3	0	\N	2026-06-20 17:17:29.609506+00	2026-06-20 17:17:29.609506+00	\N	\N
2090	10	36	1	3	\N	2026-06-20 17:17:37.127563+00	2026-06-20 17:17:37.127563+00	\N	\N
2091	26	33	2	0	\N	2026-06-20 17:55:17.563981+00	2026-06-20 17:55:17.563981+00	\N	\N
2092	26	34	1	0	\N	2026-06-20 17:55:28.984541+00	2026-06-20 17:55:28.984541+00	\N	\N
2093	26	36	0	2	\N	2026-06-20 17:55:45.535929+00	2026-06-20 17:55:45.535929+00	\N	\N
2094	41	33	3	1	\N	2026-06-20 18:01:50.735745+00	2026-06-20 18:01:50.735745+00	\N	\N
2095	30	33	3	1	\N	2026-06-20 18:30:24.34098+00	2026-06-20 18:30:24.34098+00	\N	\N
2096	30	34	2	1	\N	2026-06-20 18:30:31.807064+00	2026-06-20 18:30:31.807064+00	\N	\N
2097	30	36	1	3	\N	2026-06-20 18:30:42.246458+00	2026-06-20 18:52:38.937391+00	\N	\N
2072	42	33	4	1	\N	2026-06-20 16:53:50.794233+00	2026-06-20 19:44:40.603388+00	\N	\N
2105	42	36	0	2	\N	2026-06-20 19:45:17.304762+00	2026-06-20 19:45:17.304762+00	\N	\N
2106	46	33	3	1	\N	2026-06-20 19:45:44.590733+00	2026-06-20 19:45:52.00388+00	\N	\N
2110	29	34	2	1	\N	2026-06-20 20:23:42.459497+00	2026-06-20 20:23:42.459497+00	\N	\N
2111	29	36	1	2	\N	2026-06-20 20:25:55.036249+00	2026-06-20 20:25:55.036249+00	\N	\N
2112	23	34	2	0	\N	2026-06-20 21:01:09.363175+00	2026-06-20 21:01:09.363175+00	\N	\N
2177	46	38	3	1	\N	2026-06-21 08:05:23.753739+00	2026-06-21 08:05:28.635527+00	\N	\N
2104	42	34	5	0	\N	2026-06-20 19:45:00.553157+00	2026-06-20 22:49:22.358363+00	\N	\N
2123	46	34	3	0	\N	2026-06-20 23:53:59.279904+00	2026-06-20 23:53:59.279904+00	\N	\N
2124	34	38	4	0	\N	2026-06-21 00:05:25.154185+00	2026-06-21 00:05:25.154185+00	\N	\N
2125	34	39	2	1	\N	2026-06-21 00:05:33.587318+00	2026-06-21 00:05:33.587318+00	\N	\N
2126	34	37	1	0	\N	2026-06-21 00:05:47.491396+00	2026-06-21 00:05:47.491396+00	\N	\N
2127	34	40	0	2	\N	2026-06-21 00:05:56.268192+00	2026-06-21 00:05:56.268192+00	\N	\N
2128	12	36	0	2	\N	2026-06-21 00:15:24.317898+00	2026-06-21 00:15:24.317898+00	\N	\N
2129	10	38	3	1	\N	2026-06-21 01:44:26.260835+00	2026-06-21 01:44:26.260835+00	\N	\N
2130	10	39	2	1	\N	2026-06-21 01:44:33.140865+00	2026-06-21 01:44:33.140865+00	\N	\N
2132	10	40	1	2	\N	2026-06-21 01:45:07.439091+00	2026-06-21 01:45:07.439091+00	\N	\N
2113	23	36	1	2	\N	2026-06-20 21:02:23.417427+00	2026-06-21 01:45:25.300221+00	\N	\N
2134	46	36	1	2	\N	2026-06-21 02:21:54.053195+00	2026-06-21 02:21:54.053195+00	\N	\N
2135	55	38	3	1	\N	2026-06-21 02:29:05.829753+00	2026-06-21 02:29:05.829753+00	\N	\N
2137	55	39	2	2	\N	2026-06-21 02:29:14.180579+00	2026-06-21 02:29:14.180579+00	\N	\N
2138	55	37	1	2	\N	2026-06-21 02:29:21.19783+00	2026-06-21 02:29:21.19783+00	\N	\N
2140	55	40	1	2	\N	2026-06-21 02:29:28.292803+00	2026-06-21 02:29:28.292803+00	\N	\N
2136	38	38	2	0	\N	2026-06-21 02:29:07.760929+00	2026-06-21 02:30:39.532883+00	\N	\N
2142	38	40	1	1	\N	2026-06-21 02:29:55.092582+00	2026-06-21 02:30:39.535442+00	\N	\N
2139	38	39	1	0	\N	2026-06-21 02:29:23.228335+00	2026-06-21 02:30:39.733774+00	\N	\N
2131	10	37	2	1	\N	2026-06-21 01:44:50.619194+00	2026-06-21 21:44:12.267354+00	\N	\N
1991	59	36	1	2	\N	2026-06-20 13:50:45.772977+00	2026-06-21 02:59:57.656036+00	\N	\N
2149	45	38	2	0	\N	2026-06-21 03:06:05.867651+00	2026-06-21 03:06:05.867651+00	\N	\N
2150	45	39	2	0	\N	2026-06-21 03:06:11.8476+00	2026-06-21 03:06:11.8476+00	\N	\N
2151	45	37	2	0	\N	2026-06-21 03:07:10.413849+00	2026-06-21 03:07:10.413849+00	\N	\N
2152	45	40	1	2	\N	2026-06-21 03:07:38.471426+00	2026-06-21 03:07:38.471426+00	\N	\N
2154	50	38	3	1	\N	2026-06-21 03:56:54.419342+00	2026-06-21 03:56:54.419342+00	\N	\N
2155	33	38	3	0	\N	2026-06-21 06:51:54.808577+00	2026-06-21 06:51:54.808577+00	\N	\N
2156	33	39	3	1	\N	2026-06-21 06:52:08.36746+00	2026-06-21 06:52:08.36746+00	\N	\N
2158	33	37	2	1	\N	2026-06-21 06:52:22.571395+00	2026-06-21 06:52:22.571395+00	\N	\N
2157	30	38	3	1	\N	2026-06-21 06:52:18.200497+00	2026-06-21 06:52:30.314157+00	\N	\N
2160	30	39	3	0	\N	2026-06-21 06:52:43.759743+00	2026-06-21 06:52:51.103493+00	\N	\N
2162	30	37	2	1	\N	2026-06-21 06:53:07.47334+00	2026-06-21 06:53:07.47334+00	\N	\N
2163	30	40	1	3	\N	2026-06-21 06:53:34.004993+00	2026-06-21 06:53:34.004993+00	\N	\N
2164	33	40	1	3	\N	2026-06-21 06:53:34.307428+00	2026-06-21 06:53:34.307428+00	\N	\N
2165	24	38	3	0	\N	2026-06-21 06:58:35.506152+00	2026-06-21 06:58:35.506152+00	\N	\N
2166	24	39	2	1	\N	2026-06-21 06:58:43.699157+00	2026-06-21 06:58:43.699157+00	\N	\N
2167	24	37	1	0	\N	2026-06-21 06:58:50.1319+00	2026-06-21 06:58:50.1319+00	\N	\N
2168	24	40	1	2	\N	2026-06-21 06:59:00.01997+00	2026-06-21 06:59:00.01997+00	\N	\N
2170	47	37	1	2	\N	2026-06-21 07:14:30.376328+00	2026-06-21 07:14:30.376328+00	\N	\N
2179	27	38	2	0	\N	2026-06-21 11:01:02.687911+00	2026-06-21 11:01:02.687911+00	\N	\N
2180	27	39	2	1	\N	2026-06-21 11:01:14.365122+00	2026-06-21 11:01:14.365122+00	\N	\N
2169	47	38	3	1	\N	2026-06-21 07:12:39.491403+00	2026-06-21 07:17:45.49394+00	\N	\N
2181	27	37	2	0	\N	2026-06-21 11:01:30.306934+00	2026-06-21 11:01:30.306934+00	\N	\N
2182	27	40	1	2	\N	2026-06-21 11:01:45.682116+00	2026-06-21 11:01:45.682116+00	\N	\N
2183	11	38	4	1	\N	2026-06-21 11:25:31.753978+00	2026-06-21 11:25:31.753978+00	\N	\N
2184	11	39	3	1	\N	2026-06-21 11:25:49.891156+00	2026-06-21 11:25:49.891156+00	\N	\N
2185	11	37	2	1	\N	2026-06-21 11:26:27.004562+00	2026-06-21 11:26:27.004562+00	\N	\N
2186	11	40	2	2	\N	2026-06-21 11:30:17.777723+00	2026-06-21 11:30:27.071955+00	\N	\N
2199	9	38	2	0	\N	2026-06-21 12:54:50.797968+00	2026-06-21 12:54:50.797968+00	\N	\N
2192	68	40	1	0	\N	2026-06-21 12:09:54.749723+00	2026-06-21 12:09:54.749723+00	\N	\N
2188	68	38	3	1	\N	2026-06-21 12:06:33.026406+00	2026-06-21 12:30:01.241402+00	\N	\N
2189	68	37	2	0	\N	2026-06-21 12:08:06.532158+00	2026-06-21 12:30:23.776409+00	\N	\N
2195	23	38	3	0	\N	2026-06-21 12:35:01.273946+00	2026-06-21 12:35:01.273946+00	\N	\N
2197	23	37	2	0	\N	2026-06-21 12:35:18.262176+00	2026-06-21 12:35:18.262176+00	\N	\N
2200	9	39	3	1	\N	2026-06-21 12:55:02.829726+00	2026-06-21 12:55:02.829726+00	\N	\N
2201	9	37	2	0	\N	2026-06-21 12:55:13.667722+00	2026-06-21 12:55:13.667722+00	\N	\N
2202	9	40	1	2	\N	2026-06-21 12:55:24.429739+00	2026-06-21 12:55:24.429739+00	\N	\N
2203	43	38	3	0	\N	2026-06-21 13:05:22.512733+00	2026-06-21 13:05:22.512733+00	\N	\N
2204	43	39	2	0	\N	2026-06-21 13:05:36.946957+00	2026-06-21 13:05:36.946957+00	\N	\N
2205	43	37	0	0	\N	2026-06-21 13:05:44.211764+00	2026-06-21 13:05:44.211764+00	\N	\N
2206	43	40	1	3	\N	2026-06-21 13:05:51.252126+00	2026-06-21 13:05:57.832686+00	\N	\N
2208	40	38	2	0	\N	2026-06-21 13:09:54.173869+00	2026-06-21 13:09:54.173869+00	\N	\N
2209	40	39	2	1	\N	2026-06-21 13:11:30.863125+00	2026-06-21 13:11:30.863125+00	\N	\N
2191	68	39	4	0	\N	2026-06-21 12:08:23.947788+00	2026-06-21 17:44:37.471563+00	\N	\N
2172	47	40	1	2	\N	2026-06-21 07:15:44.211867+00	2026-06-22 00:54:45.330547+00	\N	\N
2198	23	40	1	2	\N	2026-06-21 12:36:41.962634+00	2026-06-21 18:24:50.279736+00	\N	\N
2141	38	37	2	0	\N	2026-06-21 02:29:39.946237+00	2026-06-21 21:11:53.084238+00	\N	\N
2210	40	37	1	2	\N	2026-06-21 13:13:07.413781+00	2026-06-21 13:13:07.413781+00	\N	\N
2211	40	40	0	1	\N	2026-06-21 13:14:39.234827+00	2026-06-21 13:14:39.234827+00	\N	\N
2213	37	38	3	1	\N	2026-06-21 13:25:46.966297+00	2026-06-21 13:25:46.966297+00	\N	\N
2214	37	39	3	1	\N	2026-06-21 13:25:56.323942+00	2026-06-21 13:25:56.323942+00	\N	\N
2215	37	37	2	1	\N	2026-06-21 13:26:04.755728+00	2026-06-21 13:26:04.755728+00	\N	\N
2216	26	38	4	0	\N	2026-06-21 14:07:53.81896+00	2026-06-21 14:07:53.81896+00	\N	\N
2217	26	37	2	1	\N	2026-06-21 14:08:21.242533+00	2026-06-21 14:08:21.242533+00	\N	\N
2218	26	40	1	1	\N	2026-06-21 14:08:38.549548+00	2026-06-21 14:08:38.549548+00	\N	\N
2219	26	39	3	0	\N	2026-06-21 14:09:00.072331+00	2026-06-21 14:09:00.072331+00	\N	\N
2220	32	38	2	1	\N	2026-06-21 14:22:45.134372+00	2026-06-21 14:22:45.134372+00	\N	\N
2221	32	39	1	1	\N	2026-06-21 14:23:12.039782+00	2026-06-21 14:23:12.039782+00	\N	\N
2222	32	37	2	1	\N	2026-06-21 14:23:34.026205+00	2026-06-21 14:23:34.026205+00	\N	\N
2224	28	38	3	0	\N	2026-06-21 14:36:43.098847+00	2026-06-21 14:36:43.098847+00	\N	\N
2225	28	39	2	0	\N	2026-06-21 14:36:53.408865+00	2026-06-21 14:36:53.408865+00	\N	\N
2226	28	37	1	0	\N	2026-06-21 14:36:59.547111+00	2026-06-21 14:36:59.547111+00	\N	\N
2227	28	40	0	1	\N	2026-06-21 14:37:06.585783+00	2026-06-21 14:37:06.585783+00	\N	\N
2228	16	38	3	1	\N	2026-06-21 14:41:48.404333+00	2026-06-21 14:41:48.404333+00	\N	\N
2229	16	39	2	0	\N	2026-06-21 14:42:03.628723+00	2026-06-21 14:42:03.628723+00	\N	\N
2230	16	37	1	0	\N	2026-06-21 14:42:18.021456+00	2026-06-21 14:42:18.021456+00	\N	\N
2231	16	40	1	2	\N	2026-06-21 14:42:28.143596+00	2026-06-21 14:42:28.143596+00	\N	\N
2232	42	38	3	0	\N	2026-06-21 15:23:26.39335+00	2026-06-21 15:23:26.39335+00	\N	\N
2233	31	38	3	1	\N	2026-06-21 15:28:03.479526+00	2026-06-21 15:28:03.479526+00	\N	\N
2234	31	39	2	1	\N	2026-06-21 15:28:11.803718+00	2026-06-21 15:28:11.803718+00	\N	\N
2235	31	37	3	0	\N	2026-06-21 15:28:27.754982+00	2026-06-21 15:28:27.754982+00	\N	\N
2236	31	40	1	1	\N	2026-06-21 15:28:41.383732+00	2026-06-21 15:28:41.383732+00	\N	\N
2237	41	38	2	0	\N	2026-06-21 15:29:36.641197+00	2026-06-21 15:29:36.641197+00	\N	\N
2238	12	38	2	0	\N	2026-06-21 15:29:36.829683+00	2026-06-21 15:29:36.829683+00	\N	\N
2239	48	38	2	1	\N	2026-06-21 15:29:52.949234+00	2026-06-21 15:29:52.949234+00	\N	\N
2240	48	39	1	1	\N	2026-06-21 15:29:59.751247+00	2026-06-21 15:29:59.751247+00	\N	\N
2241	66	38	2	2	\N	2026-06-21 15:30:00.449578+00	2026-06-21 15:30:00.449578+00	\N	\N
2244	66	39	1	3	\N	2026-06-21 15:30:16.08897+00	2026-06-21 15:30:16.08897+00	\N	\N
2245	66	37	2	1	\N	2026-06-21 15:30:29.078724+00	2026-06-21 15:30:29.078724+00	\N	\N
2246	66	40	1	1	\N	2026-06-21 15:30:40.855753+00	2026-06-21 15:30:40.855753+00	\N	\N
2247	51	38	3	1	\N	2026-06-21 15:31:47.184294+00	2026-06-21 15:31:47.184294+00	\N	\N
2248	51	39	2	0	\N	2026-06-21 15:31:53.061306+00	2026-06-21 15:31:53.061306+00	\N	\N
2249	51	37	1	0	\N	2026-06-21 15:32:04.04529+00	2026-06-21 15:32:04.04529+00	\N	\N
2250	59	38	2	0	\N	2026-06-21 15:33:12.191254+00	2026-06-21 15:33:12.191254+00	\N	\N
2251	59	39	2	1	\N	2026-06-21 15:33:40.988388+00	2026-06-21 15:33:40.988388+00	\N	\N
2252	51	40	0	1	\N	2026-06-21 15:34:03.398053+00	2026-06-21 15:34:03.398053+00	\N	\N
2253	59	37	2	1	\N	2026-06-21 15:34:21.527689+00	2026-06-21 15:34:21.527689+00	\N	\N
2254	44	38	3	0	\N	2026-06-21 15:34:28.327022+00	2026-06-21 15:34:28.327022+00	\N	\N
2255	44	37	2	0	\N	2026-06-21 15:35:46.326749+00	2026-06-21 15:35:46.326749+00	\N	\N
2256	44	39	2	1	\N	2026-06-21 15:36:00.217667+00	2026-06-21 15:36:00.217667+00	\N	\N
2257	58	38	2	1	\N	2026-06-21 15:49:55.012391+00	2026-06-21 15:49:55.012391+00	\N	\N
2258	56	38	2	1	\N	2026-06-21 15:50:18.928208+00	2026-06-21 15:50:51.780742+00	\N	\N
2260	13	39	3	1	\N	2026-06-21 16:26:50.541686+00	2026-06-21 16:26:50.541686+00	\N	\N
2261	13	37	4	1	\N	2026-06-21 16:27:26.148166+00	2026-06-21 16:28:11.269256+00	\N	\N
2263	13	40	1	2	\N	2026-06-21 16:29:01.114231+00	2026-06-21 16:29:01.114231+00	\N	\N
2264	29	37	2	1	\N	2026-06-21 17:30:16.034139+00	2026-06-21 17:30:16.034139+00	\N	\N
2265	29	40	3	0	\N	2026-06-21 17:30:25.163539+00	2026-06-21 17:30:25.163539+00	\N	\N
2266	29	39	3	0	\N	2026-06-21 17:30:42.064607+00	2026-06-21 17:30:42.064607+00	\N	\N
2171	47	39	2	1	\N	2026-06-21 07:14:34.019375+00	2026-06-21 17:41:54.625423+00	\N	\N
2270	35	39	3	0	\N	2026-06-21 17:44:43.318147+00	2026-06-21 17:44:43.318147+00	\N	\N
2271	35	37	2	0	\N	2026-06-21 17:44:53.07719+00	2026-06-21 17:44:53.07719+00	\N	\N
2272	35	40	2	0	\N	2026-06-21 17:45:00.688432+00	2026-06-21 17:45:00.688432+00	\N	\N
2274	41	37	1	0	\N	2026-06-21 17:51:11.545771+00	2026-06-21 17:51:11.545771+00	\N	\N
2275	41	40	0	2	\N	2026-06-21 17:51:23.481002+00	2026-06-21 17:51:23.481002+00	\N	\N
2276	46	39	3	1	\N	2026-06-21 18:09:05.937074+00	2026-06-21 18:09:05.937074+00	\N	\N
2277	50	39	2	1	\N	2026-06-21 18:13:01.245432+00	2026-06-21 18:13:01.245432+00	\N	\N
2278	50	37	2	0	\N	2026-06-21 18:13:05.828738+00	2026-06-21 18:13:05.828738+00	\N	\N
2212	37	40	1	3	\N	2026-06-21 13:25:40.027074+00	2026-06-21 18:13:24.02087+00	\N	\N
2280	56	39	0	1	\N	2026-06-21 18:23:30.274774+00	2026-06-21 18:23:41.768691+00	\N	\N
2283	58	39	1	3	\N	2026-06-21 18:23:44.683852+00	2026-06-21 18:23:44.683852+00	\N	\N
2284	58	37	3	3	\N	2026-06-21 18:23:56.740964+00	2026-06-21 18:23:56.740964+00	\N	\N
2285	56	37	0	0	\N	2026-06-21 18:23:58.437228+00	2026-06-21 18:23:58.437228+00	\N	\N
2288	58	40	2	1	\N	2026-06-21 18:25:42.00688+00	2026-06-21 18:25:42.00688+00	\N	\N
2289	56	40	1	0	\N	2026-06-21 18:27:28.560747+00	2026-06-21 18:27:28.560747+00	\N	\N
2290	42	39	2	1	\N	2026-06-21 18:37:51.103024+00	2026-06-21 18:37:51.103024+00	\N	\N
2292	12	39	3	1	\N	2026-06-21 18:58:32.336802+00	2026-06-21 18:58:32.336802+00	\N	\N
2293	42	37	1	0	\N	2026-06-21 20:52:46.261828+00	2026-06-21 20:52:46.261828+00	\N	\N
2242	48	37	2	1	\N	2026-06-21 15:30:07.397693+00	2026-06-21 21:18:38.034745+00	\N	\N
2299	12	37	2	0	\N	2026-06-21 21:36:20.571161+00	2026-06-21 21:36:20.571161+00	\N	\N
2300	46	37	2	0	\N	2026-06-21 21:39:29.319441+00	2026-06-21 21:39:29.319441+00	\N	\N
2302	42	40	0	1	\N	2026-06-21 21:48:11.799008+00	2026-06-21 21:48:11.799008+00	\N	\N
2317	47	42	4	1	\N	2026-06-22 00:11:45.783953+00	2026-06-22 00:11:52.521228+00	\N	\N
2319	47	41	3	0	\N	2026-06-22 00:12:33.379321+00	2026-06-22 00:13:15.232766+00	\N	\N
2305	38	44	1	1	\N	2026-06-22 00:02:19.743048+00	2026-06-22 00:08:11.717858+00	\N	\N
2308	38	41	2	1	\N	2026-06-22 00:05:52.479223+00	2026-06-22 00:08:12.601023+00	\N	\N
2304	38	42	3	1	\N	2026-06-22 00:01:45.532112+00	2026-06-22 00:08:18.817104+00	\N	\N
2303	38	43	2	0	\N	2026-06-22 00:01:16.708408+00	2026-06-22 00:08:19.359296+00	\N	\N
2316	47	43	3	1	\N	2026-06-22 00:10:28.01475+00	2026-06-22 00:10:28.01475+00	\N	\N
2321	47	44	2	2	\N	2026-06-22 00:14:03.689128+00	2026-06-22 00:14:21.450108+00	\N	\N
2323	50	40	2	2	\N	2026-06-22 00:18:04.045575+00	2026-06-22 00:18:04.045575+00	\N	\N
2324	40	43	2	1	\N	2026-06-22 00:38:19.699351+00	2026-06-22 00:38:19.699351+00	\N	\N
2325	40	42	4	1	\N	2026-06-22 00:38:57.011317+00	2026-06-22 00:39:22.393419+00	\N	\N
2327	40	41	3	2	\N	2026-06-22 00:40:09.206782+00	2026-06-22 00:40:09.206782+00	\N	\N
2243	48	40	0	2	\N	2026-06-21 15:30:15.235777+00	2026-06-22 00:44:59.891825+00	\N	\N
2330	40	44	1	1	\N	2026-06-22 00:49:31.585428+00	2026-06-22 00:49:31.585428+00	\N	\N
2223	32	40	2	1	\N	2026-06-21 14:23:58.660831+00	2026-06-22 00:55:41.263906+00	\N	\N
2333	12	40	1	2	\N	2026-06-22 00:59:33.924741+00	2026-06-22 00:59:33.924741+00	\N	\N
2334	46	43	3	1	\N	2026-06-22 01:07:22.49014+00	2026-06-22 01:07:22.49014+00	\N	\N
2335	46	42	5	0	\N	2026-06-22 01:07:30.205777+00	2026-06-22 01:07:30.205777+00	\N	\N
2336	46	41	3	1	\N	2026-06-22 01:07:41.499089+00	2026-06-22 01:07:41.499089+00	\N	\N
2337	46	44	1	2	\N	2026-06-22 01:07:55.60747+00	2026-06-22 01:07:55.60747+00	\N	\N
2339	46	45	4	1	\N	2026-06-22 01:08:54.538728+00	2026-06-22 01:08:54.538728+00	\N	\N
3889	31	68	1	0	\N	2026-06-27 17:32:08.695724+00	2026-06-27 17:32:08.695724+00	\N	\N
2342	37	43	3	1	\N	2026-06-22 02:00:40.228406+00	2026-06-22 16:25:33.787264+00	\N	\N
2348	55	43	3	0	\N	2026-06-22 03:05:00.514725+00	2026-06-22 03:05:00.514725+00	\N	\N
2349	55	42	3	1	\N	2026-06-22 03:06:05.33255+00	2026-06-22 03:06:05.33255+00	\N	\N
2350	55	41	2	1	\N	2026-06-22 03:06:23.505842+00	2026-06-22 03:06:23.505842+00	\N	\N
2351	55	44	1	2	\N	2026-06-22 03:06:35.248682+00	2026-06-22 03:06:35.248682+00	\N	\N
2352	43	43	2	0	\N	2026-06-22 09:00:54.515557+00	2026-06-22 09:00:54.515557+00	\N	\N
2353	43	42	4	0	\N	2026-06-22 09:01:00.060479+00	2026-06-22 09:01:00.060479+00	\N	\N
2354	43	41	2	1	\N	2026-06-22 09:01:08.336943+00	2026-06-22 09:01:08.336943+00	\N	\N
2355	43	44	1	1	\N	2026-06-22 09:01:17.447486+00	2026-06-22 09:01:17.447486+00	\N	\N
2356	34	43	3	0	\N	2026-06-22 09:49:13.16983+00	2026-06-22 09:49:13.16983+00	\N	\N
2357	34	42	2	0	\N	2026-06-22 09:49:25.268904+00	2026-06-22 09:49:25.268904+00	\N	\N
2359	34	41	2	1	\N	2026-06-22 09:50:09.691644+00	2026-06-22 09:50:09.691644+00	\N	\N
2360	68	43	4	0	\N	2026-06-22 10:11:20.363773+00	2026-06-22 10:11:20.363773+00	\N	\N
2361	68	42	3	0	\N	2026-06-22 10:11:32.225021+00	2026-06-22 10:11:32.225021+00	\N	\N
2362	68	41	2	1	\N	2026-06-22 10:11:46.045802+00	2026-06-22 10:11:46.045802+00	\N	\N
2364	10	42	3	1	\N	2026-06-22 10:28:32.647372+00	2026-06-22 10:28:32.647372+00	\N	\N
2365	10	41	2	1	\N	2026-06-22 10:28:41.011128+00	2026-06-22 10:28:41.011128+00	\N	\N
2366	10	44	1	2	\N	2026-06-22 10:28:48.682117+00	2026-06-22 10:28:48.682117+00	\N	\N
2367	51	43	2	0	\N	2026-06-22 11:58:26.865246+00	2026-06-22 11:58:26.865246+00	\N	\N
2369	29	43	3	0	\N	2026-06-22 12:12:02.185732+00	2026-06-22 12:12:02.185732+00	\N	\N
2370	29	42	4	0	\N	2026-06-22 12:12:11.029525+00	2026-06-22 12:12:11.029525+00	\N	\N
2371	29	41	3	1	\N	2026-06-22 12:12:19.100223+00	2026-06-22 12:12:19.100223+00	\N	\N
2372	32	42	2	1	\N	2026-06-22 12:14:59.471137+00	2026-06-22 12:14:59.471137+00	\N	\N
2373	32	43	3	1	\N	2026-06-22 12:15:26.383875+00	2026-06-22 12:15:26.383875+00	\N	\N
2374	32	41	2	0	\N	2026-06-22 12:16:30.743941+00	2026-06-22 12:16:30.743941+00	\N	\N
2375	32	44	1	0	\N	2026-06-22 12:16:55.36939+00	2026-06-22 12:16:55.36939+00	\N	\N
2377	41	42	3	1	\N	2026-06-22 12:28:40.45916+00	2026-06-22 12:28:40.45916+00	\N	\N
2345	37	41	3	1	\N	2026-06-22 02:02:21.286815+00	2026-06-22 12:35:54.320289+00	\N	\N
2380	28	43	2	0	\N	2026-06-22 12:51:35.692164+00	2026-06-22 12:51:40.283457+00	\N	\N
2382	28	42	4	0	\N	2026-06-22 12:52:09.302559+00	2026-06-22 12:52:09.302559+00	\N	\N
2383	28	41	2	1	\N	2026-06-22 12:52:27.919013+00	2026-06-22 12:52:27.919013+00	\N	\N
2384	28	44	1	2	\N	2026-06-22 12:52:58.730736+00	2026-06-22 12:52:58.730736+00	\N	\N
2386	14	43	3	0	\N	2026-06-22 13:15:24.642735+00	2026-06-22 13:15:24.642735+00	\N	\N
2387	14	42	4	0	\N	2026-06-22 13:15:31.43377+00	2026-06-22 13:15:31.43377+00	\N	\N
2388	14	41	3	1	\N	2026-06-22 13:15:39.794827+00	2026-06-22 13:15:39.794827+00	\N	\N
2389	14	44	1	2	\N	2026-06-22 13:15:47.741841+00	2026-06-22 13:15:47.741841+00	\N	\N
2390	27	42	4	0	\N	2026-06-22 13:46:00.828303+00	2026-06-22 13:46:00.828303+00	\N	\N
2391	27	41	3	1	\N	2026-06-22 13:46:52.107252+00	2026-06-22 13:46:52.107252+00	\N	\N
2392	27	44	2	1	\N	2026-06-22 13:47:08.578536+00	2026-06-22 13:47:08.578536+00	\N	\N
2393	27	43	3	0	\N	2026-06-22 13:47:21.345335+00	2026-06-22 13:47:21.345335+00	\N	\N
2394	11	43	3	1	\N	2026-06-22 13:49:42.213735+00	2026-06-22 13:49:42.213735+00	\N	\N
2378	41	41	2	1	\N	2026-06-22 12:28:48.78726+00	2026-06-22 19:58:32.894742+00	\N	\N
2385	51	44	1	2	\N	2026-06-22 13:05:57.743314+00	2026-06-22 13:50:56.379336+00	\N	\N
2368	51	42	4	0	\N	2026-06-22 11:59:10.471064+00	2026-06-22 13:51:17.008563+00	\N	\N
2402	48	43	3	1	\N	2026-06-22 14:01:03.871377+00	2026-06-22 14:01:03.871377+00	\N	\N
2403	48	42	2	0	\N	2026-06-22 14:01:14.439841+00	2026-06-22 14:01:14.439841+00	\N	\N
2406	59	43	2	1	\N	2026-06-22 14:02:04.87069+00	2026-06-22 14:02:04.87069+00	\N	\N
2407	59	42	3	0	\N	2026-06-22 14:02:38.62436+00	2026-06-22 14:02:38.62436+00	\N	\N
2408	59	41	2	1	\N	2026-06-22 14:04:34.621889+00	2026-06-22 14:04:34.621889+00	\N	\N
2409	45	43	2	1	\N	2026-06-22 14:11:21.271193+00	2026-06-22 14:11:21.271193+00	\N	\N
2410	45	42	3	0	\N	2026-06-22 14:11:45.509999+00	2026-06-22 14:11:45.509999+00	\N	\N
2411	45	41	3	1	\N	2026-06-22 14:12:10.126647+00	2026-06-22 14:12:10.126647+00	\N	\N
2412	45	44	1	1	\N	2026-06-22 14:12:37.363732+00	2026-06-22 14:12:37.363732+00	\N	\N
2413	25	43	3	0	\N	2026-06-22 14:14:20.961501+00	2026-06-22 14:14:20.961501+00	\N	\N
2414	25	42	4	0	\N	2026-06-22 14:14:26.874727+00	2026-06-22 14:14:26.874727+00	\N	\N
2415	25	41	1	2	\N	2026-06-22 14:14:36.057835+00	2026-06-22 14:14:36.057835+00	\N	\N
2416	25	44	1	2	\N	2026-06-22 14:14:55.513838+00	2026-06-22 14:14:55.513838+00	\N	\N
2376	41	43	2	0	\N	2026-06-22 12:28:28.373254+00	2026-06-22 14:32:10.187303+00	\N	\N
2347	50	43	3	1	\N	2026-06-22 02:49:41.93921+00	2026-06-22 14:33:45.931766+00	\N	\N
2419	50	42	4	0	\N	2026-06-22 14:34:07.307666+00	2026-06-22 14:34:07.307666+00	\N	\N
2420	50	44	1	2	\N	2026-06-22 14:34:36.777178+00	2026-06-22 14:34:36.777178+00	\N	\N
2428	42	43	3	0	\N	2026-06-22 14:49:10.69343+00	2026-06-22 14:49:10.69343+00	\N	\N
2404	48	41	2	1	\N	2026-06-22 14:01:28.129412+00	2026-06-22 23:59:36.162241+00	\N	\N
2425	58	43	3	1	\N	2026-06-22 14:46:43.802269+00	2026-06-22 14:46:43.802269+00	\N	\N
2422	36	43	3	1	\N	2026-06-22 14:35:51.430885+00	2026-06-22 15:03:11.431545+00	\N	\N
2427	42	42	3	0	\N	2026-06-22 14:48:54.405599+00	2026-06-22 14:48:54.405599+00	\N	\N
2439	9	41	2	0	\N	2026-06-22 15:03:19.7586+00	2026-06-22 15:03:19.7586+00	\N	\N
2430	44	43	3	1	\N	2026-06-22 14:57:53.634507+00	2026-06-22 14:57:53.634507+00	\N	\N
2431	44	42	4	0	\N	2026-06-22 14:58:14.337619+00	2026-06-22 14:58:14.337619+00	\N	\N
2432	44	41	2	1	\N	2026-06-22 14:58:28.100868+00	2026-06-22 14:58:28.100868+00	\N	\N
2442	36	41	2	2	\N	2026-06-22 15:04:20.126657+00	2026-06-22 15:04:20.126657+00	\N	\N
2434	9	43	3	1	\N	2026-06-22 15:02:53.962744+00	2026-06-22 15:03:07.241135+00	\N	\N
2435	9	42	5	0	\N	2026-06-22 15:03:00.750387+00	2026-06-22 15:03:11.379418+00	\N	\N
2440	9	44	1	1	\N	2026-06-22 15:03:27.605309+00	2026-06-22 15:03:27.605309+00	\N	\N
2441	36	42	2	1	\N	2026-06-22 15:03:48.146785+00	2026-06-22 15:03:48.146785+00	\N	\N
2443	36	44	1	2	\N	2026-06-22 15:05:15.813666+00	2026-06-22 15:05:15.813666+00	\N	\N
2444	24	43	2	1	\N	2026-06-22 15:07:19.345969+00	2026-06-22 15:07:28.298371+00	\N	\N
2446	24	42	3	0	\N	2026-06-22 15:07:34.003575+00	2026-06-22 15:07:34.003575+00	\N	\N
2447	24	41	1	1	\N	2026-06-22 15:07:42.34245+00	2026-06-22 15:07:42.34245+00	\N	\N
2449	26	43	2	1	\N	2026-06-22 15:17:45.740936+00	2026-06-22 15:17:45.740936+00	\N	\N
2450	26	42	4	0	\N	2026-06-22 15:17:56.606663+00	2026-06-22 15:17:56.606663+00	\N	\N
2451	26	41	1	1	\N	2026-06-22 15:18:07.535741+00	2026-06-22 15:18:07.535741+00	\N	\N
2452	26	44	0	1	\N	2026-06-22 15:18:16.782166+00	2026-06-22 15:18:16.782166+00	\N	\N
2363	10	43	3	1	\N	2026-06-22 10:28:21.755177+00	2026-06-22 16:33:33.598744+00	\N	\N
2448	24	44	1	2	\N	2026-06-22 15:07:52.500248+00	2026-06-22 19:07:26.435859+00	\N	\N
2421	50	41	3	1	\N	2026-06-22 14:34:46.710812+00	2026-06-22 16:52:21.037479+00	\N	\N
2396	11	41	3	1	\N	2026-06-22 13:50:17.333088+00	2026-06-22 19:08:12.973266+00	\N	\N
2395	11	42	3	1	\N	2026-06-22 13:49:59.028812+00	2026-06-22 19:22:20.339738+00	\N	\N
2344	37	42	5	0	\N	2026-06-22 02:02:05.300544+00	2026-06-22 20:57:44.27188+00	\N	\N
2358	34	44	0	1	\N	2026-06-22 09:49:44.931073+00	2026-06-23 00:50:41.208602+00	\N	\N
2341	46	48	2	0	\N	2026-06-22 01:09:09.555416+00	2026-06-23 05:05:54.16845+00	\N	\N
2399	11	44	1	2	\N	2026-06-22 13:50:48.176466+00	2026-06-23 02:04:06.524459+00	\N	\N
2346	37	44	1	2	\N	2026-06-22 02:02:32.854198+00	2026-06-23 02:19:02.953335+00	\N	\N
2405	48	44	1	1	\N	2026-06-22 14:01:40.458614+00	2026-06-23 02:07:32.336192+00	\N	\N
2340	46	46	1	3	\N	2026-06-22 01:09:01.878364+00	2026-06-23 19:21:05.394143+00	\N	\N
2453	31	43	2	0	\N	2026-06-22 15:22:18.729037+00	2026-06-22 15:22:18.729037+00	\N	\N
2454	44	44	1	0	\N	2026-06-22 15:32:56.231322+00	2026-06-22 15:32:56.231322+00	\N	\N
2455	31	42	3	0	\N	2026-06-22 15:37:24.915469+00	2026-06-22 15:37:24.915469+00	\N	\N
2456	31	41	1	1	\N	2026-06-22 15:39:18.261692+00	2026-06-22 15:39:18.261692+00	\N	\N
2398	51	41	2	2	\N	2026-06-22 13:50:45.575208+00	2026-06-22 15:39:45.43532+00	\N	\N
2458	31	44	0	2	\N	2026-06-22 15:41:10.135915+00	2026-06-22 15:41:10.135915+00	\N	\N
2459	35	43	3	0	\N	2026-06-22 15:44:26.943229+00	2026-06-22 15:44:26.943229+00	\N	\N
2460	35	42	3	0	\N	2026-06-22 15:44:33.434612+00	2026-06-22 15:44:33.434612+00	\N	\N
2461	35	41	2	0	\N	2026-06-22 15:44:40.457199+00	2026-06-22 15:44:40.457199+00	\N	\N
2462	35	44	0	1	\N	2026-06-22 15:45:09.192901+00	2026-06-22 15:45:09.192901+00	\N	\N
2464	56	43	4	0	\N	2026-06-22 15:53:20.573437+00	2026-06-22 15:53:20.573437+00	\N	\N
2576	37	46	0	4	\N	2026-06-23 02:20:43.313627+00	2026-06-23 22:09:50.78141+00	\N	\N
2566	68	48	2	1	\N	2026-06-23 02:13:37.730579+00	2026-06-23 21:51:19.252815+00	\N	\N
2471	33	41	3	1	\N	2026-06-22 15:57:24.514676+00	2026-06-22 15:57:24.514676+00	\N	\N
2466	33	43	3	1	\N	2026-06-22 15:56:16.135727+00	2026-06-22 15:58:02.282677+00	\N	\N
2470	33	42	4	1	\N	2026-06-22 15:56:51.643453+00	2026-06-22 15:58:10.388463+00	\N	\N
2474	33	44	1	2	\N	2026-06-22 15:58:26.234034+00	2026-06-22 15:58:26.234034+00	\N	\N
2467	30	43	3	1	\N	2026-06-22 15:56:18.437834+00	2026-06-22 15:58:40.10275+00	\N	\N
2476	30	42	4	1	\N	2026-06-22 15:58:48.186797+00	2026-06-22 15:58:48.186797+00	\N	\N
2477	30	41	3	1	\N	2026-06-22 15:58:56.329896+00	2026-06-22 15:58:56.329896+00	\N	\N
2478	30	44	1	2	\N	2026-06-22 15:59:04.945017+00	2026-06-22 15:59:04.945017+00	\N	\N
2479	13	43	3	1	\N	2026-06-22 16:04:56.903804+00	2026-06-22 16:04:56.903804+00	\N	\N
2480	23	43	3	1	\N	2026-06-22 16:05:15.406403+00	2026-06-22 16:05:15.406403+00	\N	\N
2481	13	42	4	0	\N	2026-06-22 16:07:03.017962+00	2026-06-22 16:07:03.017962+00	\N	\N
2482	12	43	2	1	\N	2026-06-22 16:17:57.735953+00	2026-06-22 16:17:57.735953+00	\N	\N
2483	12	42	3	0	\N	2026-06-22 16:18:04.048791+00	2026-06-22 16:18:04.048791+00	\N	\N
2489	58	44	1	1	\N	2026-06-22 16:53:22.890747+00	2026-06-22 16:53:22.890747+00	\N	\N
2490	58	42	3	0	\N	2026-06-22 16:53:42.728845+00	2026-06-22 16:53:42.728845+00	\N	\N
2491	58	41	2	1	\N	2026-06-22 16:54:00.723299+00	2026-06-22 16:54:00.723299+00	\N	\N
2492	54	47	2	0	\N	2026-06-22 16:54:47.410626+00	2026-06-22 16:54:47.410626+00	\N	\N
2493	54	45	2	0	\N	2026-06-22 16:54:55.200493+00	2026-06-22 16:54:55.200493+00	\N	\N
2494	54	46	0	2	\N	2026-06-22 16:55:02.918765+00	2026-06-22 16:55:02.918765+00	\N	\N
2495	54	48	2	0	\N	2026-06-22 16:55:11.343922+00	2026-06-22 16:55:11.343922+00	\N	\N
2501	29	45	3	0	\N	2026-06-22 17:45:19.513185+00	2026-06-22 17:45:19.513185+00	\N	\N
2502	29	46	1	2	\N	2026-06-22 17:45:29.798105+00	2026-06-22 17:45:29.798105+00	\N	\N
2503	29	48	2	0	\N	2026-06-22 17:45:36.483314+00	2026-06-22 17:45:36.483314+00	\N	\N
2570	40	48	2	1	\N	2026-06-23 02:15:31.431377+00	2026-06-23 02:15:31.431377+00	\N	\N
2508	56	41	2	1	\N	2026-06-22 19:16:07.983422+00	2026-06-22 19:16:07.983422+00	\N	\N
2463	56	44	0	1	\N	2026-06-22 15:53:13.605552+00	2026-06-22 19:16:13.750479+00	\N	\N
2573	37	47	3	1	\N	2026-06-23 02:19:42.289775+00	2026-06-23 02:20:08.827743+00	\N	\N
2465	56	42	3	0	\N	2026-06-22 15:53:27.856599+00	2026-06-22 19:55:20.319328+00	\N	\N
2515	23	42	4	1	\N	2026-06-22 19:58:37.356347+00	2026-06-22 19:58:37.356347+00	\N	\N
2516	16	42	4	0	\N	2026-06-22 20:37:47.594801+00	2026-06-22 20:37:47.594801+00	\N	\N
2520	66	42	3	0	\N	2026-06-22 21:01:38.452573+00	2026-06-22 21:01:38.452573+00	\N	\N
2522	66	41	2	1	\N	2026-06-22 21:37:14.094446+00	2026-06-22 21:37:14.094446+00	\N	\N
2523	66	44	3	2	\N	2026-06-22 21:37:30.195718+00	2026-06-22 21:37:30.195718+00	\N	\N
2524	42	41	2	0	\N	2026-06-22 23:04:40.593275+00	2026-06-22 23:04:40.593275+00	\N	\N
2525	23	41	2	1	\N	2026-06-22 23:42:00.920999+00	2026-06-22 23:42:00.920999+00	\N	\N
2526	23	44	0	1	\N	2026-06-22 23:52:20.036733+00	2026-06-22 23:52:20.036733+00	\N	\N
2528	23	47	3	0	\N	2026-06-23 00:01:40.747577+00	2026-06-23 00:01:40.747577+00	\N	\N
2529	23	45	3	0	\N	2026-06-23 00:02:19.948163+00	2026-06-23 00:02:19.948163+00	\N	\N
2530	23	46	0	2	\N	2026-06-23 00:02:40.624238+00	2026-06-23 00:02:40.624238+00	\N	\N
2532	16	44	1	1	\N	2026-06-23 00:24:01.720693+00	2026-06-23 00:24:01.720693+00	\N	\N
2533	41	44	1	2	\N	2026-06-23 00:29:58.176779+00	2026-06-23 00:29:58.176779+00	\N	\N
2531	23	48	2	0	\N	2026-06-23 00:03:15.532724+00	2026-06-23 00:40:53.222326+00	\N	\N
1453	15	47	2	1	\N	2026-06-18 00:44:38.609383+00	2026-06-23 00:54:05.435836+00	\N	\N
2539	9	47	3	0	\N	2026-06-23 01:07:39.545073+00	2026-06-23 01:07:39.545073+00	\N	\N
2540	9	45	3	1	\N	2026-06-23 01:07:47.455752+00	2026-06-23 01:07:47.455752+00	\N	\N
2543	9	48	2	1	\N	2026-06-23 01:08:06.597355+00	2026-06-23 01:08:06.597355+00	\N	\N
2544	12	44	1	2	\N	2026-06-23 01:11:25.165869+00	2026-06-23 01:11:25.165869+00	\N	\N
3880	30	70	0	3	\N	2026-06-27 15:46:06.596766+00	2026-06-27 15:46:11.577406+00	\N	\N
2548	13	44	1	3	\N	2026-06-23 01:17:21.557779+00	2026-06-23 01:17:21.557779+00	\N	\N
2549	38	48	2	1	\N	2026-06-23 01:17:36.945151+00	2026-06-23 16:53:07.151518+00	\N	\N
2546	38	45	2	1	\N	2026-06-23 01:16:39.788805+00	2026-06-23 16:53:02.007783+00	\N	\N
2545	38	47	3	0	\N	2026-06-23 01:16:15.76081+00	2026-06-23 16:52:58.856733+00	\N	\N
2565	68	46	1	2	\N	2026-06-23 02:13:26.862311+00	2026-06-23 21:51:14.383972+00	\N	\N
2554	68	44	1	1	\N	2026-06-23 01:50:48.770288+00	2026-06-23 01:50:48.770288+00	\N	\N
2559	40	47	3	1	\N	2026-06-23 02:08:53.088879+00	2026-06-23 02:08:53.088879+00	\N	\N
2560	40	45	3	1	\N	2026-06-23 02:10:10.011655+00	2026-06-23 02:10:10.011655+00	\N	\N
2561	40	46	1	3	\N	2026-06-23 02:11:23.069795+00	2026-06-23 02:11:23.069795+00	\N	\N
2562	68	47	3	0	\N	2026-06-23 02:12:50.307651+00	2026-06-23 02:12:50.307651+00	\N	\N
2563	68	45	3	0	\N	2026-06-23 02:13:02.040799+00	2026-06-23 02:13:15.82509+00	\N	\N
2584	47	45	4	0	\N	2026-06-23 03:05:59.602482+00	2026-06-23 03:06:21.662857+00	\N	\N
2580	10	46	0	3	\N	2026-06-23 02:44:06.821305+00	2026-06-23 02:44:06.821305+00	\N	\N
2582	42	44	0	2	\N	2026-06-23 02:52:24.705721+00	2026-06-23 02:52:24.705721+00	\N	\N
2583	47	47	3	1	\N	2026-06-23 03:05:01.811721+00	2026-06-23 03:05:01.811721+00	\N	\N
2588	55	47	2	0	\N	2026-06-23 04:05:44.636012+00	2026-06-23 04:05:44.636012+00	\N	\N
2589	55	45	2	1	\N	2026-06-23 04:09:18.216544+00	2026-06-23 04:09:18.216544+00	\N	\N
2590	55	46	0	1	\N	2026-06-23 04:09:22.093042+00	2026-06-23 04:09:26.707348+00	\N	\N
2592	55	48	2	1	\N	2026-06-23 04:09:47.628406+00	2026-06-23 04:10:13.455618+00	\N	\N
2338	46	47	3	0	\N	2026-06-22 01:08:39.121801+00	2026-06-23 05:05:37.474347+00	\N	\N
2578	10	47	3	1	\N	2026-06-23 02:43:52.525597+00	2026-06-23 05:33:48.987003+00	\N	\N
2597	28	47	2	0	\N	2026-06-23 09:16:57.440261+00	2026-06-23 09:16:57.440261+00	\N	\N
2598	28	45	2	0	\N	2026-06-23 09:17:35.328398+00	2026-06-23 09:17:35.328398+00	\N	\N
2599	28	46	0	2	\N	2026-06-23 09:17:45.496241+00	2026-06-23 09:17:45.496241+00	\N	\N
2600	28	48	2	0	\N	2026-06-23 09:18:00.994735+00	2026-06-23 09:18:00.994735+00	\N	\N
2601	13	47	4	1	\N	2026-06-23 11:06:25.070306+00	2026-06-23 11:06:25.070306+00	\N	\N
2500	29	47	4	1	\N	2026-06-22 17:45:13.66934+00	2026-06-23 15:21:31.401187+00	\N	\N
2575	37	45	5	0	\N	2026-06-23 02:20:16.149747+00	2026-06-23 19:05:23.115127+00	\N	\N
2585	47	46	1	2	\N	2026-06-23 03:06:18.953201+00	2026-06-23 22:34:02.729563+00	\N	\N
2579	10	45	3	0	\N	2026-06-23 02:43:59.736691+00	2026-06-23 19:11:10.999747+00	\N	\N
2577	37	48	2	1	\N	2026-06-23 02:21:30.534928+00	2026-06-24 01:34:04.608478+00	\N	\N
2541	9	46	0	2	\N	2026-06-23 01:07:54.136359+00	2026-06-23 19:35:05.358651+00	\N	\N
2587	47	48	3	1	\N	2026-06-23 03:07:01.657184+00	2026-06-23 19:38:10.003371+00	\N	\N
2581	10	48	2	1	\N	2026-06-23 02:44:17.530807+00	2026-06-24 01:00:37.180119+00	\N	\N
2602	13	45	3	0	\N	2026-06-23 11:06:36.236425+00	2026-06-23 11:06:52.794011+00	\N	\N
2605	13	46	0	1	\N	2026-06-23 11:07:06.508258+00	2026-06-23 11:07:06.508258+00	\N	\N
2606	13	48	2	1	\N	2026-06-23 11:07:21.831927+00	2026-06-23 11:07:21.831927+00	\N	\N
2607	34	47	3	1	\N	2026-06-23 11:08:41.137621+00	2026-06-23 11:08:41.137621+00	\N	\N
2608	34	45	4	0	\N	2026-06-23 11:08:54.689449+00	2026-06-23 11:08:54.689449+00	\N	\N
2609	34	46	0	2	\N	2026-06-23 11:09:04.614588+00	2026-06-23 11:09:04.614588+00	\N	\N
2610	34	48	2	1	\N	2026-06-23 11:09:10.414932+00	2026-06-23 11:09:10.414932+00	\N	\N
2611	45	47	2	0	\N	2026-06-23 12:33:17.823909+00	2026-06-23 12:33:17.823909+00	\N	\N
2612	45	45	3	1	\N	2026-06-23 12:33:32.658759+00	2026-06-23 12:33:32.658759+00	\N	\N
2613	45	46	1	2	\N	2026-06-23 12:33:46.206789+00	2026-06-23 12:33:46.206789+00	\N	\N
2614	45	48	2	1	\N	2026-06-23 12:33:55.687762+00	2026-06-23 12:33:55.687762+00	\N	\N
2615	36	47	2	0	\N	2026-06-23 12:37:04.690109+00	2026-06-23 12:37:04.690109+00	\N	\N
2616	36	45	2	0	\N	2026-06-23 12:37:12.363073+00	2026-06-23 12:37:12.363073+00	\N	\N
2617	36	46	1	1	\N	2026-06-23 12:37:22.435322+00	2026-06-23 12:37:22.435322+00	\N	\N
2618	36	48	2	1	\N	2026-06-23 12:38:26.972564+00	2026-06-23 13:05:45.766297+00	\N	\N
2621	41	45	3	1	\N	2026-06-23 13:27:30.376525+00	2026-06-23 13:27:30.376525+00	\N	\N
2622	41	46	0	2	\N	2026-06-23 13:27:55.211727+00	2026-06-23 13:27:55.211727+00	\N	\N
2623	41	48	2	1	\N	2026-06-23 13:28:27.028553+00	2026-06-23 13:28:27.028553+00	\N	\N
2624	44	47	3	0	\N	2026-06-23 13:29:58.433525+00	2026-06-23 13:29:58.433525+00	\N	\N
2625	44	45	2	0	\N	2026-06-23 13:30:23.807411+00	2026-06-23 13:30:23.807411+00	\N	\N
2626	44	46	0	3	\N	2026-06-23 13:30:52.980233+00	2026-06-23 13:31:31.078426+00	\N	\N
2628	44	48	2	1	\N	2026-06-23 13:32:53.730531+00	2026-06-23 13:32:53.730531+00	\N	\N
2630	14	45	4	1	\N	2026-06-23 13:53:03.860738+00	2026-06-23 13:53:03.860738+00	\N	\N
2631	14	48	3	0	\N	2026-06-23 13:53:18.529522+00	2026-06-23 13:53:18.529522+00	\N	\N
2632	14	46	1	3	\N	2026-06-23 13:53:34.101349+00	2026-06-23 13:53:34.101349+00	\N	\N
2633	43	47	2	0	\N	2026-06-23 13:59:27.764535+00	2026-06-23 13:59:27.764535+00	\N	\N
2634	43	45	3	0	\N	2026-06-23 13:59:32.500875+00	2026-06-23 13:59:32.500875+00	\N	\N
2635	43	46	1	1	\N	2026-06-23 13:59:42.669497+00	2026-06-23 13:59:42.669497+00	\N	\N
2637	35	47	3	1	\N	2026-06-23 14:38:27.037569+00	2026-06-23 14:38:27.037569+00	\N	\N
2638	35	45	2	0	\N	2026-06-23 14:38:38.869095+00	2026-06-23 14:38:38.869095+00	\N	\N
2639	35	46	0	3	\N	2026-06-23 14:38:53.080853+00	2026-06-23 14:38:53.080853+00	\N	\N
2640	35	48	1	1	\N	2026-06-23 14:39:03.45224+00	2026-06-23 14:39:03.45224+00	\N	\N
2641	66	47	2	1	\N	2026-06-23 14:48:03.124889+00	2026-06-23 14:48:03.124889+00	\N	\N
2642	66	45	3	0	\N	2026-06-23 14:48:14.757637+00	2026-06-23 14:48:14.757637+00	\N	\N
2643	66	46	1	2	\N	2026-06-23 14:48:31.784391+00	2026-06-23 14:48:31.784391+00	\N	\N
2644	66	48	2	1	\N	2026-06-23 14:48:46.243839+00	2026-06-23 14:48:46.243839+00	\N	\N
2645	11	47	3	1	\N	2026-06-23 14:50:26.228658+00	2026-06-23 14:50:26.228658+00	\N	\N
2648	11	48	3	0	\N	2026-06-23 14:52:11.861248+00	2026-06-23 14:52:11.861248+00	\N	\N
2649	48	47	3	0	\N	2026-06-23 15:09:12.460723+00	2026-06-23 15:09:12.460723+00	\N	\N
2650	48	45	3	1	\N	2026-06-23 15:09:23.238426+00	2026-06-23 15:09:23.238426+00	\N	\N
2651	48	46	0	2	\N	2026-06-23 15:09:41.771125+00	2026-06-23 15:09:41.771125+00	\N	\N
2629	14	47	3	1	\N	2026-06-23 13:52:57.201722+00	2026-06-23 15:11:53.036951+00	\N	\N
2620	41	47	3	1	\N	2026-06-23 13:26:23.442269+00	2026-06-23 15:22:14.057722+00	\N	\N
2657	25	47	3	0	\N	2026-06-23 15:23:17.881798+00	2026-06-23 15:23:17.881798+00	\N	\N
2658	25	45	4	0	\N	2026-06-23 15:23:25.152898+00	2026-06-23 15:23:25.152898+00	\N	\N
2659	25	46	0	2	\N	2026-06-23 15:23:34.643595+00	2026-06-23 15:23:34.643595+00	\N	\N
2660	25	48	2	0	\N	2026-06-23 15:23:38.645685+00	2026-06-23 15:23:38.645685+00	\N	\N
2661	25	52	1	1	\N	2026-06-23 15:23:53.84464+00	2026-06-23 15:23:53.84464+00	\N	\N
2662	25	51	1	2	\N	2026-06-23 15:24:04.002789+00	2026-06-23 15:24:04.002789+00	\N	\N
2663	25	49	0	2	\N	2026-06-23 15:24:10.880675+00	2026-06-23 15:24:10.880675+00	\N	\N
2664	25	50	3	0	\N	2026-06-23 15:24:28.002804+00	2026-06-23 15:24:28.002804+00	\N	\N
2665	25	53	0	1	\N	2026-06-23 15:24:38.497721+00	2026-06-23 15:24:38.497721+00	\N	\N
2666	25	54	0	2	\N	2026-06-23 15:24:42.792365+00	2026-06-23 15:24:42.792365+00	\N	\N
2668	58	47	3	1	\N	2026-06-23 15:30:10.136819+00	2026-06-23 15:30:10.136819+00	\N	\N
2669	58	45	4	1	\N	2026-06-23 15:30:18.963738+00	2026-06-23 15:30:18.963738+00	\N	\N
2670	58	46	1	3	\N	2026-06-23 15:30:28.572502+00	2026-06-23 15:30:28.572502+00	\N	\N
2671	12	47	2	0	\N	2026-06-23 15:48:51.303971+00	2026-06-23 15:48:51.303971+00	\N	\N
2672	12	45	3	1	\N	2026-06-23 15:49:07.234401+00	2026-06-23 15:49:07.234401+00	\N	\N
2673	59	47	2	1	\N	2026-06-23 16:08:30.820862+00	2026-06-23 16:08:39.014357+00	\N	\N
2675	59	45	3	1	\N	2026-06-23 16:08:46.803035+00	2026-06-23 16:08:46.803035+00	\N	\N
2676	59	46	2	1	\N	2026-06-23 16:08:59.821683+00	2026-06-23 16:08:59.821683+00	\N	\N
2677	59	48	2	0	\N	2026-06-23 16:09:07.262+00	2026-06-23 16:09:07.262+00	\N	\N
2679	31	47	2	1	\N	2026-06-23 16:10:01.682404+00	2026-06-23 16:10:01.682404+00	\N	\N
2680	51	48	2	1	\N	2026-06-23 16:10:10.491844+00	2026-06-23 16:10:10.491844+00	\N	\N
2682	51	45	3	1	\N	2026-06-23 16:10:18.144034+00	2026-06-23 16:10:40.363273+00	\N	\N
2681	51	46	0	2	\N	2026-06-23 16:10:12.856819+00	2026-06-23 16:10:53.357731+00	\N	\N
2685	31	45	3	0	\N	2026-06-23 16:11:06.592542+00	2026-06-23 16:11:06.592542+00	\N	\N
2686	31	46	0	3	\N	2026-06-23 16:11:24.231946+00	2026-06-23 16:11:24.231946+00	\N	\N
2687	31	48	2	1	\N	2026-06-23 16:11:33.116828+00	2026-06-23 16:11:33.116828+00	\N	\N
2689	42	45	3	1	\N	2026-06-23 16:12:09.720109+00	2026-06-23 16:12:09.720109+00	\N	\N
2690	50	47	3	1	\N	2026-06-23 16:16:31.037115+00	2026-06-23 16:16:31.037115+00	\N	\N
2691	50	45	3	1	\N	2026-06-23 16:16:38.908559+00	2026-06-23 16:16:38.908559+00	\N	\N
2693	50	48	2	1	\N	2026-06-23 16:16:55.500547+00	2026-06-23 16:16:55.500547+00	\N	\N
2688	42	47	3	0	\N	2026-06-23 16:12:00.658325+00	2026-06-23 16:46:53.152782+00	\N	\N
3882	35	67	0	3	\N	2026-06-27 17:30:29.043496+00	2026-06-27 17:30:29.043496+00	\N	\N
2696	27	47	2	0	\N	2026-06-23 16:20:52.898748+00	2026-06-23 16:20:52.898748+00	\N	\N
2697	27	45	3	1	\N	2026-06-23 16:21:04.068954+00	2026-06-23 16:21:04.068954+00	\N	\N
2698	27	46	0	3	\N	2026-06-23 16:21:25.244767+00	2026-06-23 16:21:25.244767+00	\N	\N
2699	33	47	3	1	\N	2026-06-23 16:22:00.737173+00	2026-06-23 16:22:00.737173+00	\N	\N
2700	33	45	3	1	\N	2026-06-23 16:22:10.428325+00	2026-06-23 16:22:10.428325+00	\N	\N
2701	27	48	2	1	\N	2026-06-23 16:22:20.754389+00	2026-06-23 16:22:20.754389+00	\N	\N
2702	30	47	3	1	\N	2026-06-23 16:22:24.479953+00	2026-06-23 16:22:24.479953+00	\N	\N
2703	33	46	1	2	\N	2026-06-23 16:22:55.363061+00	2026-06-23 16:22:55.363061+00	\N	\N
2704	30	45	3	1	\N	2026-06-23 16:23:00.342036+00	2026-06-23 16:23:00.342036+00	\N	\N
2705	33	48	2	1	\N	2026-06-23 16:23:04.054856+00	2026-06-23 16:23:04.054856+00	\N	\N
2706	30	48	2	1	\N	2026-06-23 16:23:09.162039+00	2026-06-23 16:23:09.162039+00	\N	\N
2707	30	46	1	2	\N	2026-06-23 16:23:26.314623+00	2026-06-23 16:23:26.314623+00	\N	\N
2709	56	46	0	2	\N	2026-06-23 16:27:05.180431+00	2026-06-23 16:27:05.180431+00	\N	\N
2678	51	47	3	1	\N	2026-06-23 16:09:39.65745+00	2026-06-23 16:52:04.259526+00	\N	\N
2708	56	45	3	0	\N	2026-06-23 16:27:01.080211+00	2026-06-23 19:04:30.392623+00	\N	\N
2646	11	45	4	0	\N	2026-06-23 14:50:52.451946+00	2026-06-23 19:47:56.398425+00	\N	\N
2647	11	46	0	4	\N	2026-06-23 14:51:12.060405+00	2026-06-23 19:48:23.317147+00	\N	\N
2636	43	48	2	0	\N	2026-06-23 14:00:02.809958+00	2026-06-24 01:16:31.382362+00	\N	\N
2692	50	46	0	2	\N	2026-06-23 16:16:48.683887+00	2026-06-23 20:37:20.849733+00	\N	\N
2667	58	48	1	1	\N	2026-06-23 15:29:58.265979+00	2026-06-24 01:03:53.593514+00	\N	\N
2652	48	48	2	1	\N	2026-06-23 15:10:14.707006+00	2026-06-24 01:51:50.563724+00	\N	\N
2695	56	47	3	1	\N	2026-06-23 16:20:26.765182+00	2026-06-23 16:43:51.06301+00	\N	\N
2712	24	47	1	0	\N	2026-06-23 16:44:38.305537+00	2026-06-23 16:44:38.305537+00	\N	\N
2713	24	45	2	0	\N	2026-06-23 16:44:47.488569+00	2026-06-23 16:44:47.488569+00	\N	\N
2714	26	47	3	0	\N	2026-06-23 16:45:36.530722+00	2026-06-23 16:45:47.75599+00	\N	\N
2716	26	45	3	1	\N	2026-06-23 16:46:00.687301+00	2026-06-23 16:46:00.687301+00	\N	\N
2717	26	46	0	3	\N	2026-06-23 16:46:14.102569+00	2026-06-23 16:46:14.102569+00	\N	\N
2728	24	46	0	3	\N	2026-06-23 17:43:44.458874+00	2026-06-23 17:43:44.458874+00	\N	\N
2729	24	48	2	1	\N	2026-06-23 17:44:12.079591+00	2026-06-23 17:44:12.079591+00	\N	\N
2835	15	50	3	0	\N	2026-06-24 11:12:00.321038+00	2026-06-24 11:12:00.321038+00	\N	\N
2836	15	53	0	1	\N	2026-06-24 11:15:27.502741+00	2026-06-24 11:15:27.502741+00	\N	\N
2837	15	54	0	1	\N	2026-06-24 11:15:35.794323+00	2026-06-24 11:15:35.794323+00	\N	\N
2734	32	46	1	2	\N	2026-06-23 18:56:29.047216+00	2026-06-23 18:56:29.047216+00	\N	\N
2735	32	48	3	1	\N	2026-06-23 18:57:01.81735+00	2026-06-23 18:57:01.81735+00	\N	\N
2730	32	45	3	1	\N	2026-06-23 18:42:19.298774+00	2026-06-23 18:57:24.582161+00	\N	\N
2547	38	46	0	1	\N	2026-06-23 01:17:17.340041+00	2026-06-23 21:36:11.148954+00	\N	\N
2759	12	46	0	2	\N	2026-06-23 22:39:40.573457+00	2026-06-23 22:39:40.573457+00	\N	\N
2760	12	48	3	1	\N	2026-06-23 22:39:51.02081+00	2026-06-23 22:39:51.02081+00	\N	\N
2761	42	46	0	3	\N	2026-06-23 22:44:49.040373+00	2026-06-23 22:44:49.040373+00	\N	\N
2838	15	55	0	3	\N	2026-06-24 11:15:58.161357+00	2026-06-24 11:15:58.161357+00	\N	\N
2765	42	48	2	0	\N	2026-06-24 01:01:43.194071+00	2026-06-24 01:01:43.194071+00	\N	\N
2839	15	56	0	2	\N	2026-06-24 11:16:07.439974+00	2026-06-24 11:16:07.439974+00	\N	\N
2710	56	48	0	1	\N	2026-06-23 16:29:16.138876+00	2026-06-24 01:02:31.979356+00	\N	\N
2773	10	52	2	0	\N	2026-06-24 04:00:12.818511+00	2026-06-24 04:00:12.818511+00	\N	\N
2774	37	52	2	1	\N	2026-06-24 04:00:16.139877+00	2026-06-24 04:00:16.139877+00	\N	\N
2775	10	51	1	2	\N	2026-06-24 04:00:24.382148+00	2026-06-24 04:00:24.382148+00	\N	\N
2776	10	49	1	2	\N	2026-06-24 04:00:30.608898+00	2026-06-24 04:00:30.608898+00	\N	\N
2777	10	50	2	0	\N	2026-06-24 04:00:43.741815+00	2026-06-24 04:00:43.741815+00	\N	\N
2779	10	53	1	2	\N	2026-06-24 04:00:51.806179+00	2026-06-24 04:00:51.806179+00	\N	\N
2780	10	54	1	3	\N	2026-06-24 04:00:58.86972+00	2026-06-24 04:00:58.86972+00	\N	\N
2784	37	54	0	2	\N	2026-06-24 04:02:24.173905+00	2026-06-24 04:02:24.173905+00	\N	\N
2786	24	49	0	2	\N	2026-06-24 04:06:44.20192+00	2026-06-24 04:06:44.20192+00	\N	\N
2787	24	50	3	0	\N	2026-06-24 04:06:57.440234+00	2026-06-24 04:06:57.440234+00	\N	\N
2788	24	53	1	2	\N	2026-06-24 04:07:05.390235+00	2026-06-24 04:07:05.390235+00	\N	\N
2789	24	54	0	1	\N	2026-06-24 04:07:15.241084+00	2026-06-24 04:07:15.241084+00	\N	\N
2791	27	51	3	1	\N	2026-06-24 04:25:23.008984+00	2026-06-24 04:25:23.008984+00	\N	\N
2792	27	49	1	3	\N	2026-06-24 04:25:36.367796+00	2026-06-24 04:25:36.367796+00	\N	\N
2793	27	54	2	2	\N	2026-06-24 04:25:46.136793+00	2026-06-24 04:25:46.136793+00	\N	\N
2790	27	52	0	0	\N	2026-06-24 04:25:11.77299+00	2026-06-24 04:26:08.85418+00	\N	\N
2795	27	50	2	1	\N	2026-06-24 04:26:26.2338+00	2026-06-24 04:26:26.2338+00	\N	\N
2796	27	53	1	2	\N	2026-06-24 04:27:27.258215+00	2026-06-24 04:27:27.258215+00	\N	\N
2797	55	52	2	0	\N	2026-06-24 04:46:05.685737+00	2026-06-24 04:46:05.685737+00	\N	\N
2798	55	51	2	1	\N	2026-06-24 04:46:32.139903+00	2026-06-24 04:46:32.139903+00	\N	\N
2799	55	49	1	3	\N	2026-06-24 04:46:53.032347+00	2026-06-24 04:46:53.032347+00	\N	\N
2800	55	50	2	0	\N	2026-06-24 04:47:31.948723+00	2026-06-24 04:47:31.948723+00	\N	\N
2801	55	53	1	2	\N	2026-06-24 04:47:51.525624+00	2026-06-24 04:47:51.525624+00	\N	\N
2802	55	54	1	1	\N	2026-06-24 04:48:27.240945+00	2026-06-24 04:48:27.240945+00	\N	\N
2803	32	52	2	2	\N	2026-06-24 04:51:30.543725+00	2026-06-24 04:51:30.543725+00	\N	\N
2805	32	51	1	1	\N	2026-06-24 04:52:50.852412+00	2026-06-24 04:52:50.852412+00	\N	\N
2808	33	49	1	3	\N	2026-06-24 04:53:17.641346+00	2026-06-24 04:53:17.641346+00	\N	\N
2809	33	50	3	0	\N	2026-06-24 04:53:36.521308+00	2026-06-24 04:53:36.521308+00	\N	\N
2810	33	53	1	2	\N	2026-06-24 04:54:04.382515+00	2026-06-24 04:54:04.382515+00	\N	\N
2811	32	53	1	2	\N	2026-06-24 04:54:55.666734+00	2026-06-24 04:54:55.666734+00	\N	\N
2812	33	54	1	3	\N	2026-06-24 04:54:58.843214+00	2026-06-24 04:54:58.843214+00	\N	\N
2813	32	50	2	0	\N	2026-06-24 04:55:23.020466+00	2026-06-24 04:55:23.020466+00	\N	\N
2814	32	49	1	2	\N	2026-06-24 04:55:40.683353+00	2026-06-24 04:55:40.683353+00	\N	\N
2815	32	54	1	2	\N	2026-06-24 04:56:02.192734+00	2026-06-24 04:56:02.192734+00	\N	\N
2816	29	52	2	1	\N	2026-06-24 05:01:33.431325+00	2026-06-24 05:01:33.431325+00	\N	\N
2817	29	51	2	1	\N	2026-06-24 05:01:43.928155+00	2026-06-24 05:01:43.928155+00	\N	\N
2818	29	49	0	2	\N	2026-06-24 05:01:52.826863+00	2026-06-24 05:01:52.826863+00	\N	\N
2819	29	50	3	0	\N	2026-06-24 05:02:03.362896+00	2026-06-24 05:02:03.362896+00	\N	\N
2820	29	56	1	3	\N	2026-06-24 05:03:36.991416+00	2026-06-24 05:03:36.991416+00	\N	\N
2804	47	52	2	1	\N	2026-06-24 04:51:40.696538+00	2026-06-24 05:19:57.434436+00	\N	\N
2823	47	51	2	3	\N	2026-06-24 05:20:19.331956+00	2026-06-24 05:20:19.331956+00	\N	\N
2825	47	54	1	2	\N	2026-06-24 05:22:25.738154+00	2026-06-24 05:22:25.738154+00	\N	\N
2826	47	53	0	2	\N	2026-06-24 05:22:28.423855+00	2026-06-24 05:24:56.931561+00	\N	\N
2828	47	50	3	1	\N	2026-06-24 05:25:00.911808+00	2026-06-24 05:25:25.133052+00	\N	\N
2806	33	52	1	1	\N	2026-06-24 04:52:53.685525+00	2026-06-24 05:51:52.245949+00	\N	\N
2807	33	51	2	3	\N	2026-06-24 04:52:59.885412+00	2026-06-24 05:52:25.512005+00	\N	\N
2832	15	51	1	1	\N	2026-06-24 11:11:20.695898+00	2026-06-24 11:11:20.695898+00	\N	\N
2833	15	52	2	0	\N	2026-06-24 11:11:29.057586+00	2026-06-24 11:11:29.057586+00	\N	\N
2834	15	49	1	2	\N	2026-06-24 11:11:51.633127+00	2026-06-24 11:11:51.633127+00	\N	\N
2840	15	58	0	3	\N	2026-06-24 11:16:17.173182+00	2026-06-24 11:16:17.173182+00	\N	\N
2841	15	57	1	1	\N	2026-06-24 11:16:28.776+00	2026-06-24 11:16:28.776+00	\N	\N
2842	15	59	0	2	\N	2026-06-24 11:16:36.61314+00	2026-06-24 11:16:36.61314+00	\N	\N
2843	15	60	1	0	\N	2026-06-24 11:16:45.933986+00	2026-06-24 11:16:45.933986+00	\N	\N
2781	37	49	1	3	\N	2026-06-24 04:01:01.7152+00	2026-06-24 14:34:20.979721+00	\N	\N
2846	38	51	2	1	\N	2026-06-24 11:37:01.966136+00	2026-06-24 11:37:04.474318+00	\N	\N
2849	38	49	0	2	\N	2026-06-24 11:37:35.519686+00	2026-06-24 11:38:09.656915+00	\N	\N
2844	38	52	1	1	\N	2026-06-24 11:33:52.835626+00	2026-06-24 11:44:11.175784+00	\N	\N
2852	38	53	1	2	\N	2026-06-24 11:41:17.963576+00	2026-06-24 11:44:04.836897+00	\N	\N
2851	38	50	2	0	\N	2026-06-24 11:39:23.288596+00	2026-06-24 11:43:37.143766+00	\N	\N
2853	38	54	1	2	\N	2026-06-24 11:43:26.989582+00	2026-06-24 11:44:04.681088+00	\N	\N
2778	37	51	1	1	\N	2026-06-24 04:00:45.540306+00	2026-06-24 18:36:32.108901+00	\N	\N
2862	45	52	2	0	\N	2026-06-24 12:28:09.213006+00	2026-06-24 12:28:09.213006+00	\N	\N
2864	45	51	1	1	\N	2026-06-24 12:28:46.151347+00	2026-06-24 12:28:46.151347+00	\N	\N
2866	45	53	1	2	\N	2026-06-24 12:29:34.755976+00	2026-06-24 12:29:34.755976+00	\N	\N
2868	36	52	1	1	\N	2026-06-24 12:33:04.870444+00	2026-06-24 12:33:04.870444+00	\N	\N
2869	36	51	2	1	\N	2026-06-24 12:33:16.210681+00	2026-06-24 12:33:16.210681+00	\N	\N
2782	37	50	2	0	\N	2026-06-24 04:01:40.850832+00	2026-06-24 12:41:25.087766+00	\N	\N
2863	45	49	1	3	\N	2026-06-24 12:28:33.288311+00	2026-06-24 20:31:08.966752+00	\N	\N
2783	37	53	1	2	\N	2026-06-24 04:02:09.456168+00	2026-06-25 00:11:25.930564+00	\N	\N
2865	45	50	3	1	\N	2026-06-24 12:29:10.302732+00	2026-06-24 20:31:14.766723+00	\N	\N
2867	45	54	1	2	\N	2026-06-24 12:29:51.228986+00	2026-06-24 20:31:24.58685+00	\N	\N
2824	47	49	1	4	\N	2026-06-24 05:21:28.29973+00	2026-06-24 21:58:14.646062+00	\N	\N
2821	29	58	0	2	\N	2026-06-24 05:03:47.535178+00	2026-06-25 22:21:58.537332+00	\N	\N
2870	36	50	2	0	\N	2026-06-24 12:33:36.703716+00	2026-06-24 12:33:36.703716+00	\N	\N
2785	24	52	2	0	\N	2026-06-24 04:06:06.699271+00	2026-06-24 12:39:10.136752+00	\N	\N
2872	24	51	1	1	\N	2026-06-24 12:39:22.027208+00	2026-06-24 12:39:22.027208+00	\N	\N
3883	35	68	2	1	\N	2026-06-27 17:30:39.40033+00	2026-06-27 17:30:39.40033+00	\N	\N
2880	46	50	2	0	\N	2026-06-24 12:46:17.690209+00	2026-06-24 12:46:17.690209+00	\N	\N
2881	46	53	0	2	\N	2026-06-24 12:46:29.423721+00	2026-06-24 12:46:29.423721+00	\N	\N
2882	46	54	0	2	\N	2026-06-24 12:46:35.618933+00	2026-06-24 12:46:35.618933+00	\N	\N
2883	40	52	2	0	\N	2026-06-24 12:52:03.612195+00	2026-06-24 12:52:03.612195+00	\N	\N
2884	40	51	2	2	\N	2026-06-24 12:53:36.295904+00	2026-06-24 12:53:36.295904+00	\N	\N
2888	54	50	2	0	\N	2026-06-24 12:56:41.72492+00	2026-06-24 12:56:41.72492+00	\N	\N
2890	40	49	1	3	\N	2026-06-24 12:57:54.972996+00	2026-06-24 12:57:54.972996+00	\N	\N
2885	54	52	0	1	\N	2026-06-24 12:56:24.840758+00	2026-06-24 12:58:31.475724+00	\N	\N
2886	54	51	1	2	\N	2026-06-24 12:56:31.890806+00	2026-06-24 12:58:33.166455+00	\N	\N
2887	54	49	0	3	\N	2026-06-24 12:56:37.246054+00	2026-06-24 12:58:36.397161+00	\N	\N
2889	54	53	0	1	\N	2026-06-24 12:57:14.508039+00	2026-06-24 12:58:45.881357+00	\N	\N
2896	36	53	2	2	\N	2026-06-24 12:58:46.32874+00	2026-06-24 12:58:46.32874+00	\N	\N
2891	54	54	0	1	\N	2026-06-24 12:58:24.437125+00	2026-06-24 12:58:48.687636+00	\N	\N
2898	36	54	2	2	\N	2026-06-24 12:58:54.168024+00	2026-06-24 12:58:54.168024+00	\N	\N
2900	54	56	1	2	\N	2026-06-24 12:59:38.185721+00	2026-06-24 12:59:38.185721+00	\N	\N
2899	54	55	0	1	\N	2026-06-24 12:59:24.322685+00	2026-06-24 12:59:44.115662+00	\N	\N
2902	54	58	0	2	\N	2026-06-24 12:59:48.918987+00	2026-06-24 12:59:48.918987+00	\N	\N
2903	54	57	1	0	\N	2026-06-24 12:59:54.789344+00	2026-06-24 12:59:54.789344+00	\N	\N
2904	54	59	0	1	\N	2026-06-24 13:00:13.4463+00	2026-06-24 13:00:13.4463+00	\N	\N
2905	54	60	1	0	\N	2026-06-24 13:00:22.095939+00	2026-06-24 13:00:22.095939+00	\N	\N
2906	40	50	3	1	\N	2026-06-24 13:00:23.460747+00	2026-06-24 13:00:23.460747+00	\N	\N
2907	54	61	1	2	\N	2026-06-24 13:00:29.015783+00	2026-06-24 13:00:31.857296+00	\N	\N
2909	54	62	1	0	\N	2026-06-24 13:00:43.737721+00	2026-06-24 13:00:43.737721+00	\N	\N
2910	54	65	0	1	\N	2026-06-24 13:00:49.403773+00	2026-06-24 13:00:49.403773+00	\N	\N
2912	54	64	0	1	\N	2026-06-24 13:01:05.945722+00	2026-06-24 13:01:05.945722+00	\N	\N
2911	54	66	1	1	\N	2026-06-24 13:01:01.291765+00	2026-06-24 13:01:11.55038+00	\N	\N
2914	54	63	1	0	\N	2026-06-24 13:01:24.881451+00	2026-06-24 13:01:24.881451+00	\N	\N
2915	54	67	0	2	\N	2026-06-24 13:01:36.774045+00	2026-06-24 13:01:36.774045+00	\N	\N
2916	54	71	2	2	\N	2026-06-24 13:01:54.352265+00	2026-06-24 13:01:54.352265+00	\N	\N
2917	54	68	1	0	\N	2026-06-24 13:02:07.843722+00	2026-06-24 13:02:07.843722+00	\N	\N
2918	40	53	2	1	\N	2026-06-24 13:02:23.909788+00	2026-06-24 13:02:23.909788+00	\N	\N
2919	54	72	1	0	\N	2026-06-24 13:02:57.802655+00	2026-06-24 13:02:57.802655+00	\N	\N
2920	54	70	0	2	\N	2026-06-24 13:03:05.519547+00	2026-06-24 13:03:05.519547+00	\N	\N
2962	68	51	1	2	\N	2026-06-24 14:06:40.057534+00	2026-06-24 14:06:40.057534+00	\N	\N
2924	40	54	1	2	\N	2026-06-24 13:06:17.139952+00	2026-06-24 13:06:17.139952+00	\N	\N
2925	28	52	1	0	\N	2026-06-24 13:07:20.394138+00	2026-06-24 13:07:20.394138+00	\N	\N
2926	28	51	0	2	\N	2026-06-24 13:07:27.659535+00	2026-06-24 13:07:27.659535+00	\N	\N
2927	28	49	1	3	\N	2026-06-24 13:07:36.484805+00	2026-06-24 13:07:36.484805+00	\N	\N
2928	43	52	1	1	\N	2026-06-24 13:07:36.756067+00	2026-06-24 13:07:36.756067+00	\N	\N
2929	28	50	4	0	\N	2026-06-24 13:07:42.650685+00	2026-06-24 13:07:42.650685+00	\N	\N
2930	43	51	1	2	\N	2026-06-24 13:07:45.430267+00	2026-06-24 13:07:45.430267+00	\N	\N
2932	28	53	0	2	\N	2026-06-24 13:07:52.790678+00	2026-06-24 13:07:52.790678+00	\N	\N
2931	43	49	1	3	\N	2026-06-24 13:07:50.738744+00	2026-06-24 13:07:54.876227+00	\N	\N
2934	28	54	0	1	\N	2026-06-24 13:07:58.472184+00	2026-06-24 13:07:58.472184+00	\N	\N
2935	43	50	2	0	\N	2026-06-24 13:08:18.028196+00	2026-06-24 13:08:18.028196+00	\N	\N
2936	43	53	1	2	\N	2026-06-24 13:08:27.011737+00	2026-06-24 13:08:27.011737+00	\N	\N
2937	43	54	1	1	\N	2026-06-24 13:08:36.970828+00	2026-06-24 13:08:36.970828+00	\N	\N
2876	51	52	1	0	\N	2026-06-24 12:43:12.075336+00	2026-06-24 13:26:47.877636+00	\N	\N
2941	14	52	2	1	\N	2026-06-24 13:34:06.977107+00	2026-06-24 13:34:50.422123+00	\N	\N
2943	14	51	2	1	\N	2026-06-24 13:35:32.076726+00	2026-06-24 13:35:32.076726+00	\N	\N
2944	14	49	1	3	\N	2026-06-24 13:35:41.106087+00	2026-06-24 13:35:41.106087+00	\N	\N
2945	14	50	3	0	\N	2026-06-24 13:35:45.936571+00	2026-06-24 13:35:45.936571+00	\N	\N
2946	14	53	1	1	\N	2026-06-24 13:35:55.774304+00	2026-06-24 13:35:55.774304+00	\N	\N
2947	14	54	1	2	\N	2026-06-24 13:36:03.075927+00	2026-06-24 13:36:03.075927+00	\N	\N
2948	26	52	1	1	\N	2026-06-24 13:38:41.734267+00	2026-06-24 13:38:41.734267+00	\N	\N
2949	26	51	1	1	\N	2026-06-24 13:38:59.13275+00	2026-06-24 13:38:59.13275+00	\N	\N
2950	26	49	0	3	\N	2026-06-24 13:39:16.566726+00	2026-06-24 13:39:16.566726+00	\N	\N
2951	26	50	2	1	\N	2026-06-24 13:39:33.562618+00	2026-06-24 13:39:33.562618+00	\N	\N
2952	26	53	1	2	\N	2026-06-24 13:39:49.679132+00	2026-06-24 13:39:49.679132+00	\N	\N
2953	26	54	1	2	\N	2026-06-24 13:40:05.496681+00	2026-06-24 13:40:05.496681+00	\N	\N
2954	51	51	2	1	\N	2026-06-24 13:45:43.260247+00	2026-06-24 13:45:43.260247+00	\N	\N
2955	51	49	1	3	\N	2026-06-24 13:45:53.46395+00	2026-06-24 13:45:53.46395+00	\N	\N
2956	51	50	4	0	\N	2026-06-24 13:46:06.391258+00	2026-06-24 13:46:06.391258+00	\N	\N
2957	51	53	1	2	\N	2026-06-24 13:46:17.837198+00	2026-06-24 13:46:17.837198+00	\N	\N
2958	51	54	1	2	\N	2026-06-24 13:46:37.993006+00	2026-06-24 13:46:37.993006+00	\N	\N
2959	41	52	1	0	\N	2026-06-24 13:58:02.139722+00	2026-06-24 13:58:02.139722+00	\N	\N
2960	41	51	2	2	\N	2026-06-24 14:00:06.961067+00	2026-06-24 14:00:06.961067+00	\N	\N
2961	68	52	2	0	\N	2026-06-24 14:06:26.253742+00	2026-06-24 14:06:26.253742+00	\N	\N
2964	68	50	2	0	\N	2026-06-24 14:07:14.671504+00	2026-06-24 14:07:14.671504+00	\N	\N
2967	9	52	2	0	\N	2026-06-24 14:20:45.233515+00	2026-06-24 14:20:45.233515+00	\N	\N
2968	9	51	1	2	\N	2026-06-24 14:20:55.739998+00	2026-06-24 14:20:55.739998+00	\N	\N
2969	9	49	0	3	\N	2026-06-24 14:21:01.943273+00	2026-06-24 14:21:01.943273+00	\N	\N
2970	9	50	3	0	\N	2026-06-24 14:21:09.975627+00	2026-06-24 14:21:09.975627+00	\N	\N
2971	9	53	1	2	\N	2026-06-24 14:21:19.384955+00	2026-06-24 14:21:19.384955+00	\N	\N
2972	9	54	0	2	\N	2026-06-24 14:21:29.121346+00	2026-06-24 14:21:29.121346+00	\N	\N
2974	44	52	0	2	\N	2026-06-24 14:27:17.270551+00	2026-06-24 14:27:17.270551+00	\N	\N
2975	44	51	2	0	\N	2026-06-24 14:27:43.643809+00	2026-06-24 14:27:43.643809+00	\N	\N
2976	44	49	1	3	\N	2026-06-24 14:27:55.027711+00	2026-06-24 14:27:55.027711+00	\N	\N
2977	44	50	3	0	\N	2026-06-24 14:28:15.297727+00	2026-06-24 14:28:15.297727+00	\N	\N
2978	44	53	1	2	\N	2026-06-24 14:28:30.494966+00	2026-06-24 14:28:30.494966+00	\N	\N
2979	44	54	0	1	\N	2026-06-24 14:28:52.393775+00	2026-06-24 14:28:52.393775+00	\N	\N
2981	13	52	2	1	\N	2026-06-24 14:50:33.914974+00	2026-06-24 14:50:33.914974+00	\N	\N
2982	13	51	0	2	\N	2026-06-24 14:50:43.389499+00	2026-06-24 14:50:43.389499+00	\N	\N
2983	13	49	1	3	\N	2026-06-24 14:50:52.555286+00	2026-06-24 14:50:52.555286+00	\N	\N
2984	13	50	2	0	\N	2026-06-24 14:51:26.929997+00	2026-06-24 14:51:26.929997+00	\N	\N
2985	36	49	1	3	\N	2026-06-24 15:01:01.05272+00	2026-06-24 15:01:01.05272+00	\N	\N
2879	46	49	1	3	\N	2026-06-24 12:46:11.726271+00	2026-06-24 15:57:26.033046+00	\N	\N
2878	46	51	1	2	\N	2026-06-24 12:46:05.544724+00	2026-06-24 16:08:51.033425+00	\N	\N
2963	68	49	0	3	\N	2026-06-24 14:06:50.089485+00	2026-06-24 20:25:53.478309+00	\N	\N
2921	54	69	1	1	\N	2026-06-24 13:03:14.609356+00	2026-06-26 12:33:32.077074+00	\N	\N
2966	68	54	1	2	\N	2026-06-24 14:07:31.195755+00	2026-06-25 00:22:17.975937+00	\N	\N
2965	68	53	1	3	\N	2026-06-24 14:07:22.521615+00	2026-06-25 00:22:06.424254+00	\N	\N
2986	35	51	1	2	\N	2026-06-24 15:02:00.278354+00	2026-06-24 15:02:00.278354+00	\N	\N
2987	35	49	0	2	\N	2026-06-24 15:02:11.760996+00	2026-06-24 15:02:11.760996+00	\N	\N
2988	35	50	2	0	\N	2026-06-24 15:02:26.045379+00	2026-06-24 15:02:26.045379+00	\N	\N
2989	35	52	0	1	\N	2026-06-24 15:02:32.78997+00	2026-06-24 15:02:32.78997+00	\N	\N
2990	35	53	0	2	\N	2026-06-24 15:02:41.574889+00	2026-06-24 15:02:41.574889+00	\N	\N
2993	56	51	0	2	\N	2026-06-24 15:15:41.630783+00	2026-06-24 15:15:41.630783+00	\N	\N
2994	48	52	2	1	\N	2026-06-24 15:32:46.17558+00	2026-06-24 15:32:46.17558+00	\N	\N
2992	56	52	0	2	\N	2026-06-24 15:15:36.686739+00	2026-06-24 15:57:07.757473+00	\N	\N
2877	46	52	2	1	\N	2026-06-24 12:45:45.339798+00	2026-06-24 15:57:11.261604+00	\N	\N
2997	56	49	1	4	\N	2026-06-24 15:57:17.388314+00	2026-06-24 15:57:17.388314+00	\N	\N
2998	30	52	1	1	\N	2026-06-24 15:57:22.799601+00	2026-06-24 15:57:22.799601+00	\N	\N
3001	56	53	0	1	\N	2026-06-24 15:57:30.545274+00	2026-06-24 15:57:30.545274+00	\N	\N
3002	30	51	2	3	\N	2026-06-24 15:57:31.868791+00	2026-06-24 15:57:31.868791+00	\N	\N
3003	30	49	1	3	\N	2026-06-24 15:57:40.17879+00	2026-06-24 15:57:40.17879+00	\N	\N
3004	56	54	1	1	\N	2026-06-24 15:57:42.094029+00	2026-06-24 15:57:42.094029+00	\N	\N
3005	30	50	3	0	\N	2026-06-24 15:57:50.459292+00	2026-06-24 15:57:50.459292+00	\N	\N
3006	30	53	1	2	\N	2026-06-24 15:58:04.872948+00	2026-06-24 15:58:04.872948+00	\N	\N
3007	30	54	1	3	\N	2026-06-24 15:58:20.568444+00	2026-06-24 15:58:20.568444+00	\N	\N
3008	58	52	0	2	\N	2026-06-24 16:00:36.532634+00	2026-06-24 16:00:36.532634+00	\N	\N
3009	58	51	1	3	\N	2026-06-24 16:00:48.433578+00	2026-06-24 16:00:48.433578+00	\N	\N
3010	58	49	1	3	\N	2026-06-24 16:01:03.377843+00	2026-06-24 16:01:03.377843+00	\N	\N
3011	58	50	4	0	\N	2026-06-24 16:01:12.859531+00	2026-06-24 16:01:12.859531+00	\N	\N
3012	58	53	1	1	\N	2026-06-24 16:01:21.444845+00	2026-06-24 16:01:21.444845+00	\N	\N
3013	58	54	2	1	\N	2026-06-24 16:01:35.839203+00	2026-06-24 16:01:35.839203+00	\N	\N
3015	11	51	1	2	\N	2026-06-24 16:02:27.116723+00	2026-06-24 16:02:27.116723+00	\N	\N
3016	11	49	1	3	\N	2026-06-24 16:02:36.163078+00	2026-06-24 16:02:36.163078+00	\N	\N
3017	11	50	3	0	\N	2026-06-24 16:03:04.933497+00	2026-06-24 16:03:04.933497+00	\N	\N
3020	11	54	1	2	\N	2026-06-24 16:27:18.147255+00	2026-06-24 16:27:18.147255+00	\N	\N
3021	59	52	2	0	\N	2026-06-24 16:29:06.234761+00	2026-06-24 16:29:06.234761+00	\N	\N
3022	59	51	1	2	\N	2026-06-24 16:29:34.631725+00	2026-06-24 16:29:34.631725+00	\N	\N
3026	59	54	1	1	\N	2026-06-24 16:33:33.143734+00	2026-06-24 19:02:28.612375+00	\N	\N
3028	9	55	0	1	\N	2026-06-24 16:52:45.040052+00	2026-06-24 16:52:45.040052+00	\N	\N
3029	25	55	0	3	\N	2026-06-24 16:59:26.161604+00	2026-06-24 16:59:26.161604+00	\N	\N
3030	25	56	1	2	\N	2026-06-24 16:59:34.052934+00	2026-06-24 16:59:34.052934+00	\N	\N
3031	25	58	0	5	\N	2026-06-24 16:59:43.83972+00	2026-06-24 16:59:43.83972+00	\N	\N
3032	25	57	1	0	\N	2026-06-24 16:59:51.295142+00	2026-06-24 16:59:51.295142+00	\N	\N
3033	25	59	1	1	\N	2026-06-24 17:00:10.018005+00	2026-06-24 17:00:10.018005+00	\N	\N
3034	25	61	1	2	\N	2026-06-24 17:00:29.095324+00	2026-06-24 17:00:29.095324+00	\N	\N
3035	25	62	2	0	\N	2026-06-24 17:00:38.251643+00	2026-06-24 17:00:38.251643+00	\N	\N
3036	25	65	1	0	\N	2026-06-24 17:00:43.769411+00	2026-06-24 17:00:43.769411+00	\N	\N
3037	25	66	0	1	\N	2026-06-24 17:00:50.047746+00	2026-06-24 17:00:50.047746+00	\N	\N
3038	25	64	0	2	\N	2026-06-24 17:01:05.479729+00	2026-06-24 17:01:05.479729+00	\N	\N
3039	25	63	1	0	\N	2026-06-24 17:01:16.366844+00	2026-06-24 17:01:16.366844+00	\N	\N
3040	25	67	0	4	\N	2026-06-24 17:02:49.512878+00	2026-06-24 17:02:57.813164+00	\N	\N
3042	25	68	1	0	\N	2026-06-24 17:03:06.131944+00	2026-06-24 17:03:06.131944+00	\N	\N
3043	25	71	2	1	\N	2026-06-24 17:03:16.622985+00	2026-06-24 17:03:16.622985+00	\N	\N
3044	25	72	2	0	\N	2026-06-24 17:03:37.038722+00	2026-06-24 17:03:37.038722+00	\N	\N
3045	25	70	3	0	\N	2026-06-24 17:03:47.416563+00	2026-06-24 17:03:47.416563+00	\N	\N
3046	25	69	0	2	\N	2026-06-24 17:04:13.898003+00	2026-06-24 17:04:13.898003+00	\N	\N
3047	31	52	2	1	\N	2026-06-24 17:06:53.828236+00	2026-06-24 17:06:53.828236+00	\N	\N
3048	31	51	2	1	\N	2026-06-24 17:08:29.615549+00	2026-06-24 17:08:29.615549+00	\N	\N
3050	41	49	1	3	\N	2026-06-24 17:52:40.630402+00	2026-06-24 17:52:40.630402+00	\N	\N
3014	11	52	2	1	\N	2026-06-24 16:02:16.459238+00	2026-06-24 17:56:07.385057+00	\N	\N
3052	34	52	0	0	\N	2026-06-24 17:57:48.279721+00	2026-06-24 17:57:48.279721+00	\N	\N
3053	34	54	2	2	\N	2026-06-24 17:58:35.095769+00	2026-06-24 17:58:35.095769+00	\N	\N
3055	34	51	1	2	\N	2026-06-24 17:58:54.676668+00	2026-06-24 17:58:59.512626+00	\N	\N
3057	34	49	0	3	\N	2026-06-24 17:59:06.857901+00	2026-06-24 17:59:06.857901+00	\N	\N
3054	34	50	3	0	\N	2026-06-24 17:58:37.392003+00	2026-06-24 17:59:10.945585+00	\N	\N
3059	34	53	1	2	\N	2026-06-24 17:59:17.556558+00	2026-06-24 17:59:17.556558+00	\N	\N
3060	34	55	0	2	\N	2026-06-24 17:59:32.566825+00	2026-06-24 17:59:32.566825+00	\N	\N
3061	34	56	1	3	\N	2026-06-24 17:59:39.756732+00	2026-06-24 17:59:45.957723+00	\N	\N
3063	34	58	0	3	\N	2026-06-24 17:59:51.166721+00	2026-06-24 17:59:51.166721+00	\N	\N
3064	34	57	2	1	\N	2026-06-24 17:59:56.837734+00	2026-06-24 17:59:56.837734+00	\N	\N
3065	34	59	0	3	\N	2026-06-24 18:00:01.622173+00	2026-06-24 18:00:01.622173+00	\N	\N
3066	34	60	2	1	\N	2026-06-24 18:00:08.693865+00	2026-06-24 18:00:08.693865+00	\N	\N
3067	12	52	2	1	\N	2026-06-24 18:10:14.293726+00	2026-06-24 18:10:14.293726+00	\N	\N
3068	12	51	3	1	\N	2026-06-24 18:10:26.05905+00	2026-06-24 18:10:34.761471+00	\N	\N
3070	42	52	2	1	\N	2026-06-24 18:22:38.971873+00	2026-06-24 18:22:38.971873+00	\N	\N
3071	48	51	0	1	\N	2026-06-24 18:26:07.340502+00	2026-06-24 18:26:07.340502+00	\N	\N
3072	48	49	1	4	\N	2026-06-24 18:26:20.683568+00	2026-06-24 18:26:20.683568+00	\N	\N
3073	48	50	3	0	\N	2026-06-24 18:26:35.065562+00	2026-06-24 18:26:35.065562+00	\N	\N
3074	23	52	1	1	\N	2026-06-24 18:26:40.466533+00	2026-06-24 18:26:40.466533+00	\N	\N
3075	48	53	0	2	\N	2026-06-24 18:27:03.039556+00	2026-06-24 18:27:03.039556+00	\N	\N
3077	48	54	0	1	\N	2026-06-24 18:27:46.147748+00	2026-06-24 18:27:46.147748+00	\N	\N
3078	23	51	2	1	\N	2026-06-24 18:28:07.625794+00	2026-06-24 18:28:07.625794+00	\N	\N
3018	11	53	1	3	\N	2026-06-24 16:03:26.140905+00	2026-06-24 22:56:21.485954+00	\N	\N
3083	23	50	2	0	\N	2026-06-24 18:30:43.165111+00	2026-06-24 18:30:43.165111+00	\N	\N
3085	50	52	2	1	\N	2026-06-24 18:41:29.081862+00	2026-06-24 18:41:29.081862+00	\N	\N
3087	50	49	0	2	\N	2026-06-24 18:41:38.661406+00	2026-06-24 18:41:38.661406+00	\N	\N
3088	50	50	3	0	\N	2026-06-24 18:41:42.922722+00	2026-06-24 18:41:42.922722+00	\N	\N
3089	50	53	1	2	\N	2026-06-24 18:41:51.383635+00	2026-06-24 18:41:51.383635+00	\N	\N
3090	50	54	1	3	\N	2026-06-24 18:42:03.290053+00	2026-06-24 18:42:03.290053+00	\N	\N
3024	59	50	3	0	\N	2026-06-24 16:31:28.658+00	2026-06-24 19:01:32.459891+00	\N	\N
3092	66	52	1	1	\N	2026-06-24 18:50:20.668594+00	2026-06-24 18:50:20.668594+00	\N	\N
3093	66	51	3	2	\N	2026-06-24 18:50:32.643521+00	2026-06-24 18:50:32.643521+00	\N	\N
3094	66	49	2	4	\N	2026-06-24 18:50:41.75229+00	2026-06-24 18:50:41.75229+00	\N	\N
3095	66	50	3	1	\N	2026-06-24 18:50:52.053357+00	2026-06-24 18:50:52.053357+00	\N	\N
3096	66	53	2	3	\N	2026-06-24 18:51:06.151109+00	2026-06-24 18:51:06.151109+00	\N	\N
3097	66	54	1	2	\N	2026-06-24 18:51:21.615131+00	2026-06-24 18:51:21.615131+00	\N	\N
3086	50	51	1	1	\N	2026-06-24 18:41:35.010866+00	2026-06-24 18:54:59.045304+00	\N	\N
3023	59	49	1	3	\N	2026-06-24 16:30:07.906068+00	2026-06-24 19:01:21.233486+00	\N	\N
3025	59	53	1	2	\N	2026-06-24 16:33:01.504729+00	2026-06-24 19:02:00.969786+00	\N	\N
3104	31	49	1	3	\N	2026-06-24 19:15:16.429837+00	2026-06-24 19:15:16.429837+00	\N	\N
3079	23	49	0	2	\N	2026-06-24 18:28:23.447551+00	2026-06-24 21:31:57.669+00	\N	\N
2991	35	54	0	1	\N	2026-06-24 15:02:48.97279+00	2026-06-25 00:11:21.523824+00	\N	\N
3105	56	55	1	2	\N	2026-06-24 19:15:45.132603+00	2026-06-24 19:15:45.132603+00	\N	\N
3106	56	56	0	3	\N	2026-06-24 19:15:51.465166+00	2026-06-24 19:15:51.465166+00	\N	\N
3107	31	50	2	0	\N	2026-06-24 19:15:52.93943+00	2026-06-24 19:15:52.93943+00	\N	\N
3108	56	58	0	3	\N	2026-06-24 19:16:07.856897+00	2026-06-24 19:16:07.856897+00	\N	\N
3109	56	57	1	1	\N	2026-06-24 19:16:13.496358+00	2026-06-24 19:16:13.496358+00	\N	\N
3110	56	59	0	2	\N	2026-06-24 19:16:22.651454+00	2026-06-24 19:16:22.651454+00	\N	\N
3111	56	60	1	1	\N	2026-06-24 19:16:29.915298+00	2026-06-24 19:16:29.915298+00	\N	\N
3113	31	53	0	1	\N	2026-06-24 19:16:48.790068+00	2026-06-24 19:16:48.790068+00	\N	\N
3112	56	71	0	0	\N	2026-06-24 19:16:48.614814+00	2026-06-24 19:16:54.197094+00	\N	\N
3116	56	67	1	3	\N	2026-06-24 19:17:06.458024+00	2026-06-24 19:17:06.458024+00	\N	\N
3117	56	72	3	0	\N	2026-06-24 19:17:19.450666+00	2026-06-24 19:17:19.450666+00	\N	\N
3119	56	69	2	1	\N	2026-06-24 19:17:37.551723+00	2026-06-24 19:17:37.551723+00	\N	\N
3120	31	54	0	1	\N	2026-06-24 19:17:47.144376+00	2026-06-24 19:17:47.144376+00	\N	\N
3121	41	50	3	0	\N	2026-06-24 20:23:14.119842+00	2026-06-24 20:23:14.119842+00	\N	\N
3126	23	54	0	2	\N	2026-06-24 21:01:41.105981+00	2026-06-24 21:01:41.105981+00	\N	\N
3127	23	53	0	2	\N	2026-06-24 21:01:57.042202+00	2026-06-24 21:01:57.042202+00	\N	\N
2999	56	50	2	0	\N	2026-06-24 15:57:25.570795+00	2026-06-24 21:02:04.21883+00	\N	\N
3129	12	49	0	3	\N	2026-06-24 21:29:27.186719+00	2026-06-24 21:29:27.186719+00	\N	\N
3130	12	50	2	0	\N	2026-06-24 21:29:52.632783+00	2026-06-24 21:29:52.632783+00	\N	\N
3131	12	53	0	2	\N	2026-06-24 21:30:00.38755+00	2026-06-24 21:30:00.38755+00	\N	\N
3132	12	54	1	2	\N	2026-06-24 21:30:13.303994+00	2026-06-24 21:30:13.303994+00	\N	\N
3134	42	49	1	3	\N	2026-06-24 21:32:40.366451+00	2026-06-24 21:32:40.366451+00	\N	\N
3135	42	50	3	0	\N	2026-06-24 21:33:08.743721+00	2026-06-24 21:33:08.743721+00	\N	\N
3136	42	53	1	2	\N	2026-06-24 21:33:29.189769+00	2026-06-24 21:33:29.189769+00	\N	\N
3137	42	54	0	2	\N	2026-06-24 21:33:43.53986+00	2026-06-24 21:33:55.592647+00	\N	\N
3140	13	53	1	2	\N	2026-06-24 22:14:27.031928+00	2026-06-24 22:14:27.031928+00	\N	\N
3141	13	54	0	1	\N	2026-06-24 22:14:51.982492+00	2026-06-24 22:14:51.982492+00	\N	\N
3208	40	57	2	1	\N	2026-06-25 03:20:47.113349+00	2026-06-25 03:20:47.113349+00	\N	\N
3207	40	58	0	3	\N	2026-06-25 03:20:37.111508+00	2026-06-25 03:24:18.408232+00	\N	\N
3209	40	59	0	2	\N	2026-06-25 03:20:57.952086+00	2026-06-25 03:25:52.558627+00	\N	\N
3210	40	60	2	1	\N	2026-06-25 03:21:05.008157+00	2026-06-25 03:26:42.514146+00	\N	\N
3214	45	56	0	2	\N	2026-06-25 03:27:18.165579+00	2026-06-25 03:27:18.165579+00	\N	\N
3146	38	55	0	2	\N	2026-06-24 23:50:47.429721+00	2026-06-24 23:53:24.105286+00	\N	\N
3151	38	60	2	0	\N	2026-06-24 23:52:35.825171+00	2026-06-24 23:53:55.352196+00	\N	\N
3145	38	59	0	1	\N	2026-06-24 23:43:22.187382+00	2026-06-24 23:53:55.552771+00	\N	\N
3149	38	57	2	2	\N	2026-06-24 23:51:52.313727+00	2026-06-24 23:53:56.006461+00	\N	\N
3147	38	56	0	2	\N	2026-06-24 23:51:10.473888+00	2026-06-24 23:54:23.687732+00	\N	\N
3148	38	58	1	2	\N	2026-06-24 23:51:30.069861+00	2026-06-24 23:54:23.878764+00	\N	\N
3174	37	56	0	3	\N	2026-06-25 00:17:34.623398+00	2026-06-25 00:18:09.23846+00	\N	\N
3143	41	53	2	1	\N	2026-06-24 22:58:22.652243+00	2026-06-25 00:36:20.395418+00	\N	\N
3144	41	54	0	2	\N	2026-06-24 23:00:08.247292+00	2026-06-25 00:36:27.328489+00	\N	\N
3181	23	55	1	2	\N	2026-06-25 02:04:13.3761+00	2026-06-25 02:04:13.3761+00	\N	\N
3182	23	56	0	3	\N	2026-06-25 02:07:04.443732+00	2026-06-25 02:07:04.443732+00	\N	\N
3183	23	58	0	3	\N	2026-06-25 02:07:33.316724+00	2026-06-25 02:07:33.316724+00	\N	\N
3184	23	57	2	1	\N	2026-06-25 02:08:10.312424+00	2026-06-25 02:08:10.312424+00	\N	\N
3185	23	59	1	1	\N	2026-06-25 02:08:53.445206+00	2026-06-25 02:08:53.445206+00	\N	\N
3186	23	60	2	1	\N	2026-06-25 02:09:07.591139+00	2026-06-25 02:09:07.591139+00	\N	\N
3187	15	61	2	2	\N	2026-06-25 02:29:55.055077+00	2026-06-25 02:29:55.055077+00	\N	\N
3188	15	62	3	0	\N	2026-06-25 02:30:03.076383+00	2026-06-25 02:30:03.076383+00	\N	\N
3189	15	65	2	0	\N	2026-06-25 02:30:33.907765+00	2026-06-25 02:30:33.907765+00	\N	\N
3190	15	66	1	2	\N	2026-06-25 02:30:44.643311+00	2026-06-25 02:30:44.643311+00	\N	\N
3191	15	64	0	1	\N	2026-06-25 02:31:19.535855+00	2026-06-25 02:31:19.535855+00	\N	\N
3192	15	63	2	0	\N	2026-06-25 02:31:31.505898+00	2026-06-25 02:31:31.505898+00	\N	\N
3193	15	67	0	4	\N	2026-06-25 02:31:52.950623+00	2026-06-25 02:31:52.950623+00	\N	\N
3194	15	68	1	0	\N	2026-06-25 02:32:00.800024+00	2026-06-25 02:32:00.800024+00	\N	\N
3195	15	71	2	1	\N	2026-06-25 02:32:12.976654+00	2026-06-25 02:32:12.976654+00	\N	\N
3196	15	72	1	0	\N	2026-06-25 02:32:45.041736+00	2026-06-25 02:32:45.041736+00	\N	\N
3197	15	70	0	3	\N	2026-06-25 02:32:57.339066+00	2026-06-25 02:32:57.339066+00	\N	\N
3198	15	69	1	1	\N	2026-06-25 02:33:37.981737+00	2026-06-25 02:33:37.981737+00	\N	\N
3199	13	55	0	2	\N	2026-06-25 03:06:21.340793+00	2026-06-25 03:06:21.340793+00	\N	\N
3200	13	56	1	4	\N	2026-06-25 03:06:37.014422+00	2026-06-25 03:06:37.014422+00	\N	\N
3201	13	58	0	3	\N	2026-06-25 03:06:49.628725+00	2026-06-25 03:06:49.628725+00	\N	\N
3202	13	57	2	1	\N	2026-06-25 03:17:15.786448+00	2026-06-25 03:17:15.786448+00	\N	\N
3203	13	59	1	3	\N	2026-06-25 03:17:52.855399+00	2026-06-25 03:17:52.855399+00	\N	\N
3204	13	60	2	1	\N	2026-06-25 03:20:09.638779+00	2026-06-25 03:20:09.638779+00	\N	\N
3205	40	55	1	2	\N	2026-06-25 03:20:16.83125+00	2026-06-25 03:20:16.83125+00	\N	\N
3206	40	56	1	3	\N	2026-06-25 03:20:27.070965+00	2026-06-25 03:20:27.070965+00	\N	\N
3219	45	55	0	2	\N	2026-06-25 03:29:27.333668+00	2026-06-25 03:29:27.333668+00	\N	\N
3216	45	57	2	1	\N	2026-06-25 03:28:15.535365+00	2026-06-25 03:33:12.471054+00	\N	\N
3215	45	58	0	2	\N	2026-06-25 03:27:56.545126+00	2026-06-25 03:33:40.725965+00	\N	\N
3218	45	60	0	0	\N	2026-06-25 03:29:01.428933+00	2026-06-25 03:36:32.295992+00	\N	\N
3217	45	59	0	2	\N	2026-06-25 03:28:40.064276+00	2026-06-25 03:38:30.355406+00	\N	\N
3224	10	55	1	3	\N	2026-06-25 03:58:31.457634+00	2026-06-25 03:58:31.457634+00	\N	\N
3226	10	58	1	3	\N	2026-06-25 03:58:45.680391+00	2026-06-25 03:58:45.680391+00	\N	\N
3227	10	57	1	2	\N	2026-06-25 03:58:53.361482+00	2026-06-25 03:58:53.361482+00	\N	\N
3118	56	70	1	3	\N	2026-06-24 19:17:28.323829+00	2026-06-28 01:42:31.812533+00	\N	\N
3229	10	59	1	2	\N	2026-06-25 03:59:01.753032+00	2026-06-25 03:59:01.753032+00	\N	\N
3230	10	60	2	1	\N	2026-06-25 03:59:10.516093+00	2026-06-25 03:59:10.516093+00	\N	\N
3231	9	56	1	0	\N	2026-06-25 04:27:14.383293+00	2026-06-25 04:27:14.383293+00	\N	\N
3232	9	58	0	2	\N	2026-06-25 04:27:27.873979+00	2026-06-25 04:27:27.873979+00	\N	\N
3233	9	57	2	0	\N	2026-06-25 04:27:42.46735+00	2026-06-25 04:27:42.46735+00	\N	\N
3234	9	59	1	3	\N	2026-06-25 04:27:49.690986+00	2026-06-25 04:27:49.690986+00	\N	\N
3235	9	60	2	0	\N	2026-06-25 04:27:59.65173+00	2026-06-25 04:27:59.65173+00	\N	\N
3236	55	55	0	2	\N	2026-06-25 05:13:29.666165+00	2026-06-25 05:13:29.666165+00	\N	\N
3237	55	56	1	2	\N	2026-06-25 05:14:13.203122+00	2026-06-25 05:14:13.203122+00	\N	\N
3238	55	58	0	2	\N	2026-06-25 05:15:04.310144+00	2026-06-25 05:15:04.310144+00	\N	\N
3239	55	57	2	1	\N	2026-06-25 05:16:00.26846+00	2026-06-25 05:16:00.26846+00	\N	\N
3240	55	59	1	2	\N	2026-06-25 05:16:44.298773+00	2026-06-25 05:16:44.298773+00	\N	\N
3241	55	60	1	1	\N	2026-06-25 05:17:12.899771+00	2026-06-25 05:17:12.899771+00	\N	\N
3243	58	56	1	3	\N	2026-06-25 05:43:57.177947+00	2026-06-25 05:43:57.177947+00	\N	\N
3244	58	58	1	4	\N	2026-06-25 05:44:06.193254+00	2026-06-25 05:44:06.193254+00	\N	\N
3176	37	55	0	2	\N	2026-06-25 00:18:26.967732+00	2026-06-25 12:29:58.470586+00	\N	\N
3242	58	55	1	2	\N	2026-06-25 05:43:46.031346+00	2026-06-25 16:58:53.386689+00	\N	\N
3225	10	56	1	2	\N	2026-06-25 03:58:38.583861+00	2026-06-25 19:37:08.86108+00	\N	\N
3115	56	68	2	1	\N	2026-06-24 19:16:59.91022+00	2026-06-27 14:57:38.161514+00	\N	\N
3247	58	60	2	1	\N	2026-06-25 05:44:39.174816+00	2026-06-25 05:44:39.174816+00	\N	\N
3248	11	55	1	2	\N	2026-06-25 10:05:02.600373+00	2026-06-25 10:05:20.513947+00	\N	\N
3250	11	56	1	4	\N	2026-06-25 10:05:36.232608+00	2026-06-25 10:05:36.232608+00	\N	\N
3251	11	58	0	3	\N	2026-06-25 10:06:01.07535+00	2026-06-25 10:06:01.07535+00	\N	\N
3252	11	57	2	3	\N	2026-06-25 10:06:28.611923+00	2026-06-25 10:06:28.611923+00	\N	\N
3253	11	59	1	3	\N	2026-06-25 10:06:57.885874+00	2026-06-25 10:06:57.885874+00	\N	\N
3254	11	60	2	1	\N	2026-06-25 10:07:34.437721+00	2026-06-25 10:07:34.437721+00	\N	\N
3255	14	55	1	3	\N	2026-06-25 11:08:58.563869+00	2026-06-25 11:08:58.563869+00	\N	\N
3256	14	56	0	4	\N	2026-06-25 11:09:05.068743+00	2026-06-25 11:09:05.068743+00	\N	\N
3257	14	58	0	5	\N	2026-06-25 11:09:11.85637+00	2026-06-25 11:09:11.85637+00	\N	\N
3258	14	57	1	2	\N	2026-06-25 11:10:24.517464+00	2026-06-25 11:10:24.517464+00	\N	\N
3259	14	59	2	2	\N	2026-06-25 11:10:34.655132+00	2026-06-25 11:10:34.655132+00	\N	\N
3260	14	60	1	2	\N	2026-06-25 11:11:28.250092+00	2026-06-25 11:11:28.250092+00	\N	\N
3261	32	55	1	1	\N	2026-06-25 11:52:39.056939+00	2026-06-25 11:52:39.056939+00	\N	\N
3262	32	56	1	2	\N	2026-06-25 11:52:59.60933+00	2026-06-25 11:52:59.60933+00	\N	\N
3263	32	58	1	1	\N	2026-06-25 11:53:21.826948+00	2026-06-25 11:53:21.826948+00	\N	\N
3264	32	57	1	2	\N	2026-06-25 11:53:45.262338+00	2026-06-25 11:53:45.262338+00	\N	\N
3265	32	59	2	2	\N	2026-06-25 11:54:18.322296+00	2026-06-25 11:54:18.322296+00	\N	\N
3334	35	57	1	0	\N	2026-06-25 14:53:25.102045+00	2026-06-25 14:53:25.102045+00	\N	\N
3266	32	60	1	2	\N	2026-06-25 11:54:42.27343+00	2026-06-25 11:55:29.709733+00	\N	\N
3228	29	55	1	2	\N	2026-06-25 03:58:55.556569+00	2026-06-25 12:12:41.682846+00	\N	\N
3270	29	59	1	3	\N	2026-06-25 12:13:44.052628+00	2026-06-25 12:13:44.052628+00	\N	\N
3271	41	56	0	2	\N	2026-06-25 12:29:06.383865+00	2026-06-25 12:29:06.383865+00	\N	\N
3274	41	58	0	3	\N	2026-06-25 12:31:25.506293+00	2026-06-25 12:31:25.506293+00	\N	\N
3275	37	58	0	4	\N	2026-06-25 12:33:46.446079+00	2026-06-25 12:33:46.446079+00	\N	\N
3277	37	57	2	1	\N	2026-06-25 12:34:42.165083+00	2026-06-25 12:34:42.165083+00	\N	\N
3278	41	59	0	3	\N	2026-06-25 12:35:48.110118+00	2026-06-25 12:35:48.110118+00	\N	\N
3279	41	57	2	1	\N	2026-06-25 12:36:21.53407+00	2026-06-25 12:36:21.53407+00	\N	\N
3280	41	60	2	2	\N	2026-06-25 12:37:06.519584+00	2026-06-25 12:37:06.519584+00	\N	\N
3281	37	60	1	2	\N	2026-06-25 12:38:59.382539+00	2026-06-25 12:38:59.382539+00	\N	\N
3283	9	62	2	0	\N	2026-06-25 12:49:37.916943+00	2026-06-25 12:49:37.916943+00	\N	\N
3287	9	63	2	0	\N	2026-06-25 12:50:08.685435+00	2026-06-25 12:50:08.685435+00	\N	\N
3288	43	55	1	1	\N	2026-06-25 13:24:57.289767+00	2026-06-25 13:25:03.242947+00	\N	\N
3290	43	56	1	2	\N	2026-06-25 13:25:09.517153+00	2026-06-25 13:25:09.517153+00	\N	\N
3291	43	58	0	2	\N	2026-06-25 13:25:27.206938+00	2026-06-25 13:25:27.206938+00	\N	\N
3292	43	57	2	1	\N	2026-06-25 13:25:32.732309+00	2026-06-25 13:25:37.586853+00	\N	\N
3294	43	59	0	2	\N	2026-06-25 13:25:46.560745+00	2026-06-25 13:25:46.560745+00	\N	\N
3295	43	60	1	1	\N	2026-06-25 13:26:06.417785+00	2026-06-25 13:26:06.417785+00	\N	\N
3297	27	55	1	3	\N	2026-06-25 13:28:57.381861+00	2026-06-25 13:31:00.932987+00	\N	\N
3296	27	56	1	3	\N	2026-06-25 13:28:47.110888+00	2026-06-25 13:31:11.006042+00	\N	\N
3300	27	57	3	1	\N	2026-06-25 13:32:34.099839+00	2026-06-25 13:32:34.099839+00	\N	\N
3301	27	59	0	2	\N	2026-06-25 13:32:46.724666+00	2026-06-25 13:32:46.724666+00	\N	\N
3302	48	55	1	2	\N	2026-06-25 13:34:29.301587+00	2026-06-25 13:34:29.301587+00	\N	\N
3303	48	56	0	2	\N	2026-06-25 13:34:58.569737+00	2026-06-25 13:34:58.569737+00	\N	\N
3304	48	58	1	3	\N	2026-06-25 13:35:11.393842+00	2026-06-25 13:35:11.393842+00	\N	\N
3305	48	57	1	1	\N	2026-06-25 13:35:27.788376+00	2026-06-25 13:35:27.788376+00	\N	\N
3307	48	60	1	0	\N	2026-06-25 13:36:02.395729+00	2026-06-25 13:36:02.395729+00	\N	\N
3308	24	55	0	2	\N	2026-06-25 13:46:27.985385+00	2026-06-25 13:46:27.985385+00	\N	\N
3309	24	56	1	2	\N	2026-06-25 13:46:48.432005+00	2026-06-25 13:46:48.432005+00	\N	\N
3310	24	58	0	2	\N	2026-06-25 13:46:54.679898+00	2026-06-25 13:46:54.679898+00	\N	\N
3311	24	59	1	1	\N	2026-06-25 13:47:11.952211+00	2026-06-25 13:47:11.952211+00	\N	\N
3312	24	60	2	1	\N	2026-06-25 13:47:34.806055+00	2026-06-25 13:47:34.806055+00	\N	\N
3313	24	57	2	2	\N	2026-06-25 13:47:40.731523+00	2026-06-25 13:48:03.601541+00	\N	\N
3315	46	55	1	2	\N	2026-06-25 13:52:54.761845+00	2026-06-25 13:52:54.761845+00	\N	\N
3317	46	58	0	4	\N	2026-06-25 13:53:13.460752+00	2026-06-25 13:53:13.460752+00	\N	\N
3318	46	57	1	2	\N	2026-06-25 13:53:31.869975+00	2026-06-25 13:53:40.33255+00	\N	\N
3320	46	59	0	2	\N	2026-06-25 13:53:47.090366+00	2026-06-25 13:53:47.090366+00	\N	\N
3321	46	60	2	1	\N	2026-06-25 13:53:56.316499+00	2026-06-25 13:53:56.316499+00	\N	\N
3322	51	55	0	2	\N	2026-06-25 14:21:34.231842+00	2026-06-25 14:21:41.474875+00	\N	\N
3324	44	55	0	3	\N	2026-06-25 14:25:12.466652+00	2026-06-25 14:25:12.466652+00	\N	\N
3325	44	56	1	2	\N	2026-06-25 14:25:23.923309+00	2026-06-25 14:25:23.923309+00	\N	\N
3326	44	58	0	3	\N	2026-06-25 14:25:36.537988+00	2026-06-25 14:25:36.537988+00	\N	\N
3327	44	57	1	0	\N	2026-06-25 14:26:51.586068+00	2026-06-25 14:26:51.586068+00	\N	\N
3328	44	59	1	2	\N	2026-06-25 14:27:13.268735+00	2026-06-25 14:27:13.268735+00	\N	\N
3329	44	60	2	1	\N	2026-06-25 14:27:29.101054+00	2026-06-25 14:27:29.101054+00	\N	\N
3316	46	56	0	2	\N	2026-06-25 13:53:05.193993+00	2026-06-25 14:52:27.286852+00	\N	\N
3332	35	56	0	2	\N	2026-06-25 14:53:09.212282+00	2026-06-25 14:53:09.212282+00	\N	\N
3333	35	58	0	1	\N	2026-06-25 14:53:17.909113+00	2026-06-25 14:53:17.909113+00	\N	\N
3335	35	59	0	2	\N	2026-06-25 14:53:34.046502+00	2026-06-25 14:53:34.046502+00	\N	\N
3336	35	60	0	2	\N	2026-06-25 14:53:39.531421+00	2026-06-25 14:53:39.531421+00	\N	\N
3339	33	58	1	4	\N	2026-06-25 15:01:11.476053+00	2026-06-25 15:01:11.476053+00	\N	\N
3337	33	55	1	2	\N	2026-06-25 15:00:41.803745+00	2026-06-25 15:02:06.13721+00	\N	\N
3338	33	56	1	3	\N	2026-06-25 15:00:51.503132+00	2026-06-25 15:02:26.994991+00	\N	\N
3342	33	57	2	1	\N	2026-06-25 15:02:37.69289+00	2026-06-25 15:02:37.69289+00	\N	\N
3343	33	59	1	3	\N	2026-06-25 15:03:04.843157+00	2026-06-25 15:03:04.843157+00	\N	\N
3344	33	60	2	1	\N	2026-06-25 15:04:24.958767+00	2026-06-25 15:04:24.958767+00	\N	\N
3345	36	59	2	2	\N	2026-06-25 15:48:55.191733+00	2026-06-25 15:48:55.191733+00	\N	\N
3348	30	55	1	2	\N	2026-06-25 15:49:50.91749+00	2026-06-25 15:49:50.91749+00	\N	\N
3349	30	56	1	3	\N	2026-06-25 15:49:57.570722+00	2026-06-25 15:49:57.570722+00	\N	\N
3346	36	60	2	1	\N	2026-06-25 15:49:15.357097+00	2026-06-25 15:49:58.088114+00	\N	\N
3347	36	57	1	2	\N	2026-06-25 15:49:44.097849+00	2026-06-25 15:50:04.513789+00	\N	\N
3352	30	58	1	4	\N	2026-06-25 15:50:07.287582+00	2026-06-25 15:50:07.287582+00	\N	\N
3353	36	56	1	3	\N	2026-06-25 15:50:12.751844+00	2026-06-25 15:50:12.751844+00	\N	\N
3354	30	57	2	1	\N	2026-06-25 15:50:18.156002+00	2026-06-25 15:50:18.156002+00	\N	\N
3355	30	59	1	3	\N	2026-06-25 15:50:30.07298+00	2026-06-25 15:50:30.07298+00	\N	\N
3356	30	60	2	1	\N	2026-06-25 15:50:40.474078+00	2026-06-25 15:50:40.474078+00	\N	\N
3246	58	59	2	1	\N	2026-06-25 05:44:29.256138+00	2026-06-25 16:59:11.744374+00	\N	\N
3273	41	55	0	2	\N	2026-06-25 12:30:27.221725+00	2026-06-25 17:22:05.505298+00	\N	\N
3331	35	55	2	1	\N	2026-06-25 14:52:56.083984+00	2026-06-25 19:55:07.908684+00	\N	\N
3306	48	59	0	4	\N	2026-06-25 13:35:47.97582+00	2026-06-25 22:01:28.483461+00	\N	\N
3276	37	59	1	3	\N	2026-06-25 12:34:13.635722+00	2026-06-26 00:57:11.260758+00	\N	\N
3282	9	61	1	3	\N	2026-06-25 12:49:31.363677+00	2026-06-26 17:32:15.767187+00	\N	\N
3284	9	65	1	1	\N	2026-06-25 12:49:46.552963+00	2026-06-26 17:32:29.02982+00	\N	\N
3285	9	66	1	3	\N	2026-06-25 12:49:57.777176+00	2026-06-26 17:33:08.339513+00	\N	\N
3286	9	64	0	2	\N	2026-06-25 12:50:03.745716+00	2026-06-26 17:33:03.397399+00	\N	\N
3357	36	55	1	2	\N	2026-06-25 15:52:57.285735+00	2026-06-25 15:52:57.285735+00	\N	\N
3358	36	58	1	3	\N	2026-06-25 15:53:09.999915+00	2026-06-25 15:53:09.999915+00	\N	\N
3359	68	55	1	2	\N	2026-06-25 16:18:24.069429+00	2026-06-25 16:18:24.069429+00	\N	\N
3360	68	56	1	3	\N	2026-06-25 16:18:35.384514+00	2026-06-25 16:18:35.384514+00	\N	\N
3362	68	59	1	2	\N	2026-06-25 16:18:58.849783+00	2026-06-25 16:18:58.849783+00	\N	\N
3363	68	57	2	1	\N	2026-06-25 16:19:23.537297+00	2026-06-25 16:19:23.537297+00	\N	\N
3245	58	57	2	1	\N	2026-06-25 05:44:19.029725+00	2026-06-25 16:58:33.831953+00	\N	\N
3365	66	55	1	2	\N	2026-06-25 16:58:37.750791+00	2026-06-25 16:58:37.750791+00	\N	\N
3368	66	56	1	2	\N	2026-06-25 16:59:14.574423+00	2026-06-25 16:59:14.574423+00	\N	\N
3369	66	57	2	2	\N	2026-06-25 16:59:45.132755+00	2026-06-25 16:59:45.132755+00	\N	\N
3370	66	59	1	2	\N	2026-06-25 16:59:56.308045+00	2026-06-25 16:59:56.308045+00	\N	\N
3371	66	60	1	3	\N	2026-06-25 17:00:08.999279+00	2026-06-25 17:00:08.999279+00	\N	\N
3374	51	58	1	3	\N	2026-06-25 17:24:04.44553+00	2026-06-25 17:24:08.611009+00	\N	\N
3376	27	58	0	3	\N	2026-06-25 17:50:48.971788+00	2026-06-25 17:50:48.971788+00	\N	\N
3377	27	60	2	1	\N	2026-06-25 17:51:15.256419+00	2026-06-25 17:51:15.256419+00	\N	\N
3449	38	63	1	1	\N	2026-06-26 02:11:58.662028+00	2026-06-26 13:08:47.755002+00	\N	\N
3446	38	66	1	2	\N	2026-06-26 02:11:11.099248+00	2026-06-26 13:25:03.743608+00	\N	\N
3380	28	55	0	3	\N	2026-06-25 18:01:29.085007+00	2026-06-25 18:01:29.085007+00	\N	\N
3381	28	56	0	2	\N	2026-06-25 18:01:40.459995+00	2026-06-25 18:01:40.459995+00	\N	\N
3382	28	58	1	3	\N	2026-06-25 18:01:49.975338+00	2026-06-25 18:01:49.975338+00	\N	\N
3383	28	57	2	1	\N	2026-06-25 18:01:57.573031+00	2026-06-25 18:01:57.573031+00	\N	\N
3384	28	59	0	2	\N	2026-06-25 18:02:03.169305+00	2026-06-25 18:02:03.169305+00	\N	\N
3385	28	60	0	1	\N	2026-06-25 18:02:18.846735+00	2026-06-25 18:02:18.846735+00	\N	\N
3386	51	57	2	1	\N	2026-06-25 18:28:11.469452+00	2026-06-25 18:28:11.469452+00	\N	\N
3373	51	56	2	2	\N	2026-06-25 17:23:55.60264+00	2026-06-25 18:28:37.31841+00	\N	\N
3388	26	55	0	3	\N	2026-06-25 18:30:57.697103+00	2026-06-25 18:30:57.697103+00	\N	\N
3389	26	56	1	2	\N	2026-06-25 18:31:11.22674+00	2026-06-25 18:31:11.22674+00	\N	\N
3390	26	58	1	2	\N	2026-06-25 18:31:27.495829+00	2026-06-25 18:31:27.495829+00	\N	\N
3391	26	57	2	2	\N	2026-06-25 18:31:42.869037+00	2026-06-25 18:31:42.869037+00	\N	\N
3392	26	59	1	2	\N	2026-06-25 18:32:09.106732+00	2026-06-25 18:32:09.106732+00	\N	\N
3393	26	60	1	1	\N	2026-06-25 18:32:27.80135+00	2026-06-25 18:32:27.80135+00	\N	\N
3394	31	55	0	2	\N	2026-06-25 19:22:42.169246+00	2026-06-25 19:22:42.169246+00	\N	\N
3395	31	56	1	2	\N	2026-06-25 19:22:56.306558+00	2026-06-25 19:22:56.306558+00	\N	\N
3396	31	58	0	3	\N	2026-06-25 19:23:56.231992+00	2026-06-25 19:23:56.231992+00	\N	\N
3397	31	57	2	1	\N	2026-06-25 19:24:47.117167+00	2026-06-25 19:24:47.117167+00	\N	\N
3398	31	59	1	2	\N	2026-06-25 19:26:35.700859+00	2026-06-25 19:26:35.700859+00	\N	\N
3399	31	60	1	1	\N	2026-06-25 19:27:29.130724+00	2026-06-25 19:27:29.130724+00	\N	\N
3400	42	55	0	3	\N	2026-06-25 19:32:53.685563+00	2026-06-25 19:32:53.685563+00	\N	\N
3401	42	56	1	2	\N	2026-06-25 19:33:08.674385+00	2026-06-25 19:33:08.674385+00	\N	\N
3403	50	55	1	2	\N	2026-06-25 19:53:40.028717+00	2026-06-25 19:53:40.028717+00	\N	\N
3404	50	56	1	0	\N	2026-06-25 19:53:46.134093+00	2026-06-25 19:53:46.134093+00	\N	\N
3405	50	58	0	4	\N	2026-06-25 19:53:51.86804+00	2026-06-25 19:53:51.86804+00	\N	\N
3406	50	57	3	1	\N	2026-06-25 19:53:59.631968+00	2026-06-25 19:53:59.631968+00	\N	\N
3407	12	55	0	2	\N	2026-06-25 19:54:54.513434+00	2026-06-25 19:54:54.513434+00	\N	\N
3408	12	56	1	2	\N	2026-06-25 19:55:02.285713+00	2026-06-25 19:55:02.285713+00	\N	\N
3410	50	59	0	2	\N	2026-06-25 20:01:08.541407+00	2026-06-25 20:01:08.541407+00	\N	\N
3412	51	59	1	2	\N	2026-06-25 20:32:57.014724+00	2026-06-25 20:32:57.014724+00	\N	\N
3413	47	58	0	3	\N	2026-06-25 20:38:35.255348+00	2026-06-25 20:38:35.255348+00	\N	\N
3414	47	57	1	3	\N	2026-06-25 20:50:55.737899+00	2026-06-25 20:50:55.737899+00	\N	\N
3416	47	60	1	2	\N	2026-06-25 20:53:17.493003+00	2026-06-25 20:53:17.493003+00	\N	\N
3441	38	61	1	2	\N	2026-06-26 02:09:43.873669+00	2026-06-26 13:09:00.247831+00	\N	\N
3361	68	58	0	2	\N	2026-06-25 16:18:45.437397+00	2026-06-25 21:19:30.913077+00	\N	\N
3419	59	58	1	2	\N	2026-06-25 21:40:51.517121+00	2026-06-25 21:40:51.517121+00	\N	\N
3420	59	57	2	1	\N	2026-06-25 21:41:56.676473+00	2026-06-25 21:41:56.676473+00	\N	\N
3421	59	59	1	3	\N	2026-06-25 21:42:09.486776+00	2026-06-25 21:42:09.486776+00	\N	\N
3422	59	60	1	1	\N	2026-06-25 21:42:21.970124+00	2026-06-25 21:42:21.970124+00	\N	\N
3424	29	57	2	1	\N	2026-06-25 22:21:51.165146+00	2026-06-25 22:21:51.165146+00	\N	\N
3426	29	60	2	1	\N	2026-06-25 22:37:24.861764+00	2026-06-25 22:37:24.861764+00	\N	\N
3427	42	58	0	2	\N	2026-06-25 22:55:27.287942+00	2026-06-25 22:55:37.587088+00	\N	\N
3429	42	57	2	1	\N	2026-06-25 22:56:51.598721+00	2026-06-25 22:56:51.598721+00	\N	\N
3430	68	60	3	0	\N	2026-06-25 23:12:22.034074+00	2026-06-25 23:12:22.034074+00	\N	\N
3431	42	59	0	2	\N	2026-06-25 23:39:27.429631+00	2026-06-25 23:39:27.429631+00	\N	\N
3432	42	60	2	1	\N	2026-06-25 23:39:44.003622+00	2026-06-25 23:39:44.003622+00	\N	\N
3433	51	60	1	0	\N	2026-06-26 00:05:52.032723+00	2026-06-26 00:05:52.032723+00	\N	\N
3436	12	60	1	0	\N	2026-06-26 01:04:55.720427+00	2026-06-26 01:04:55.720427+00	\N	\N
3415	47	59	0	2	\N	2026-06-25 20:52:58.341457+00	2026-06-26 01:27:22.839331+00	\N	\N
3445	38	65	2	1	\N	2026-06-26 02:10:46.329464+00	2026-06-26 13:08:57.571823+00	\N	\N
3435	12	59	2	1	\N	2026-06-26 01:04:39.55377+00	2026-06-26 01:39:16.038749+00	\N	\N
3411	50	60	2	1	\N	2026-06-25 20:01:13.517037+00	2026-06-26 01:50:39.033061+00	\N	\N
3447	38	64	0	1	\N	2026-06-26 02:11:29.708901+00	2026-06-26 13:08:47.779228+00	\N	\N
3458	47	61	1	2	\N	2026-06-26 02:35:30.210351+00	2026-06-26 02:35:30.210351+00	\N	\N
3470	46	61	2	3	\N	2026-06-26 03:05:46.4659+00	2026-06-26 03:05:46.4659+00	\N	\N
3442	38	62	1	0	\N	2026-06-26 02:10:02.915231+00	2026-06-26 13:08:38.521927+00	\N	\N
3460	47	65	2	1	\N	2026-06-26 02:39:25.401999+00	2026-06-26 02:39:25.401999+00	\N	\N
3461	47	66	1	2	\N	2026-06-26 02:41:35.256338+00	2026-06-26 02:41:35.256338+00	\N	\N
3463	47	63	2	1	\N	2026-06-26 02:44:07.133823+00	2026-06-26 02:44:07.133823+00	\N	\N
3885	35	69	1	0	\N	2026-06-27 17:31:05.45525+00	2026-06-27 17:31:05.45525+00	\N	\N
3465	56	62	2	1	\N	2026-06-26 03:03:51.359894+00	2026-06-26 03:03:51.359894+00	\N	\N
3466	58	61	2	3	\N	2026-06-26 03:03:51.900751+00	2026-06-26 03:03:51.900751+00	\N	\N
3467	58	62	1	1	\N	2026-06-26 03:03:59.840863+00	2026-06-26 03:03:59.840863+00	\N	\N
3471	46	62	3	1	\N	2026-06-26 03:05:54.158132+00	2026-06-26 03:05:59.508012+00	\N	\N
3473	46	65	2	1	\N	2026-06-26 03:06:07.09394+00	2026-06-26 03:06:07.09394+00	\N	\N
3462	47	64	1	2	\N	2026-06-26 02:42:51.272366+00	2026-06-27 02:08:45.433216+00	\N	\N
3475	46	66	1	2	\N	2026-06-26 03:06:16.402935+00	2026-06-26 03:06:16.402935+00	\N	\N
3476	56	66	1	2	\N	2026-06-26 03:06:17.938207+00	2026-06-26 03:06:17.938207+00	\N	\N
3477	58	66	2	3	\N	2026-06-26 03:06:22.73362+00	2026-06-26 03:06:22.73362+00	\N	\N
3478	46	64	0	2	\N	2026-06-26 03:06:23.077854+00	2026-06-26 03:06:29.250356+00	\N	\N
3480	46	63	1	2	\N	2026-06-26 03:06:36.136004+00	2026-06-26 03:06:36.136004+00	\N	\N
3481	27	61	2	3	\N	2026-06-26 03:07:27.997479+00	2026-06-26 03:07:27.997479+00	\N	\N
3482	56	64	1	2	\N	2026-06-26 03:07:43.646486+00	2026-06-26 03:07:43.646486+00	\N	\N
3483	27	62	2	1	\N	2026-06-26 03:07:44.316026+00	2026-06-26 03:07:44.316026+00	\N	\N
3484	56	63	1	0	\N	2026-06-26 03:07:53.393048+00	2026-06-26 03:07:53.393048+00	\N	\N
3485	27	65	2	0	\N	2026-06-26 03:07:55.563674+00	2026-06-26 03:07:55.563674+00	\N	\N
3469	58	65	0	1	\N	2026-06-26 03:04:29.784867+00	2026-06-26 03:08:15.460754+00	\N	\N
3459	47	62	2	1	\N	2026-06-26 02:36:49.688429+00	2026-06-26 04:15:42.287947+00	\N	\N
3468	56	65	1	1	\N	2026-06-26 03:04:02.920061+00	2026-06-26 20:21:43.52873+00	\N	\N
3464	56	61	2	2	\N	2026-06-26 03:03:36.651536+00	2026-06-26 03:08:06.432008+00	\N	\N
3488	58	64	2	1	\N	2026-06-26 03:08:35.929749+00	2026-06-26 03:08:35.929749+00	\N	\N
3489	27	66	1	3	\N	2026-06-26 03:08:41.464813+00	2026-06-26 03:08:41.464813+00	\N	\N
3490	27	64	1	3	\N	2026-06-26 03:08:54.185398+00	2026-06-26 03:08:54.185398+00	\N	\N
3491	58	63	1	2	\N	2026-06-26 03:08:55.835513+00	2026-06-26 03:08:55.835513+00	\N	\N
3492	27	63	2	1	\N	2026-06-26 03:09:14.273815+00	2026-06-26 03:09:14.273815+00	\N	\N
3494	10	62	2	1	\N	2026-06-26 04:04:08.371357+00	2026-06-26 04:04:08.371357+00	\N	\N
3495	10	65	2	1	\N	2026-06-26 04:04:14.933131+00	2026-06-26 04:04:14.933131+00	\N	\N
3496	10	66	1	2	\N	2026-06-26 04:04:22.371735+00	2026-06-26 04:04:22.371735+00	\N	\N
3497	10	64	1	2	\N	2026-06-26 04:04:35.106033+00	2026-06-26 04:04:35.106033+00	\N	\N
3498	10	63	2	1	\N	2026-06-26 04:04:42.473345+00	2026-06-26 04:04:42.473345+00	\N	\N
3499	33	61	2	2	\N	2026-06-26 04:07:18.306059+00	2026-06-26 04:07:18.306059+00	\N	\N
3500	33	62	2	1	\N	2026-06-26 04:09:01.399121+00	2026-06-26 04:09:01.399121+00	\N	\N
3502	33	66	1	2	\N	2026-06-26 04:10:24.541128+00	2026-06-26 04:10:24.541128+00	\N	\N
3501	33	65	2	1	\N	2026-06-26 04:10:12.719445+00	2026-06-26 04:12:11.864349+00	\N	\N
3503	33	64	0	3	\N	2026-06-26 04:11:16.0431+00	2026-06-26 04:12:21.176435+00	\N	\N
3886	35	72	1	1	\N	2026-06-27 17:31:17.131194+00	2026-06-27 17:31:17.131194+00	\N	\N
3509	55	61	1	2	\N	2026-06-26 05:43:06.992113+00	2026-06-26 05:43:06.992113+00	\N	\N
3510	55	62	2	0	\N	2026-06-26 05:43:19.207355+00	2026-06-26 05:43:19.207355+00	\N	\N
3511	55	65	1	0	\N	2026-06-26 05:43:47.837358+00	2026-06-26 05:43:47.837358+00	\N	\N
3512	55	66	1	2	\N	2026-06-26 05:44:03.739869+00	2026-06-26 05:44:03.739869+00	\N	\N
3513	55	64	0	2	\N	2026-06-26 05:44:35.063001+00	2026-06-26 05:44:35.063001+00	\N	\N
3514	55	63	1	0	\N	2026-06-26 05:45:07.820452+00	2026-06-26 05:46:28.72172+00	\N	\N
3516	40	61	1	2	\N	2026-06-26 11:09:41.537787+00	2026-06-26 11:09:41.537787+00	\N	\N
3517	48	65	2	0	\N	2026-06-26 11:09:45.937471+00	2026-06-26 11:09:45.937471+00	\N	\N
3518	40	62	1	2	\N	2026-06-26 11:09:51.063854+00	2026-06-26 11:09:51.063854+00	\N	\N
3519	40	65	2	1	\N	2026-06-26 11:10:02.362107+00	2026-06-26 11:10:02.362107+00	\N	\N
3520	40	66	2	3	\N	2026-06-26 11:10:13.71507+00	2026-06-26 11:10:13.71507+00	\N	\N
3521	40	63	2	1	\N	2026-06-26 11:10:22.595804+00	2026-06-26 11:10:22.595804+00	\N	\N
3522	48	61	2	3	\N	2026-06-26 11:10:27.309726+00	2026-06-26 11:10:27.309726+00	\N	\N
3523	40	64	2	0	\N	2026-06-26 11:10:47.670258+00	2026-06-26 11:10:47.670258+00	\N	\N
3524	48	62	2	1	\N	2026-06-26 11:10:50.931315+00	2026-06-26 11:10:50.931315+00	\N	\N
3525	48	66	2	1	\N	2026-06-26 11:14:00.537476+00	2026-06-26 11:14:00.537476+00	\N	\N
3526	48	64	1	1	\N	2026-06-26 11:14:31.22443+00	2026-06-26 11:14:31.22443+00	\N	\N
3527	48	63	1	0	\N	2026-06-26 11:14:55.536724+00	2026-06-26 11:14:55.536724+00	\N	\N
3528	31	66	1	2	\N	2026-06-26 11:32:02.891408+00	2026-06-26 11:32:02.891408+00	\N	\N
3529	28	61	0	2	\N	2026-06-26 11:50:39.43743+00	2026-06-26 11:50:39.43743+00	\N	\N
3530	28	62	1	0	\N	2026-06-26 11:50:47.427454+00	2026-06-26 11:50:47.427454+00	\N	\N
3531	28	65	1	0	\N	2026-06-26 11:50:54.129729+00	2026-06-26 11:50:54.129729+00	\N	\N
3532	28	64	0	1	\N	2026-06-26 11:52:04.315075+00	2026-06-26 11:52:04.315075+00	\N	\N
3533	28	66	3	2	\N	2026-06-26 11:52:12.478723+00	2026-06-26 11:52:12.478723+00	\N	\N
3534	28	63	1	0	\N	2026-06-26 11:52:18.141776+00	2026-06-26 11:52:18.141776+00	\N	\N
3537	29	66	1	2	\N	2026-06-26 12:33:44.592615+00	2026-06-26 12:33:44.592615+00	\N	\N
3538	29	65	2	1	\N	2026-06-26 12:35:10.400111+00	2026-06-26 12:35:10.400111+00	\N	\N
3590	66	62	0	0	\N	2026-06-26 15:40:39.912311+00	2026-06-26 15:40:39.912311+00	\N	\N
3591	66	65	2	3	\N	2026-06-26 15:41:11.360455+00	2026-06-26 15:41:11.360455+00	\N	\N
3541	37	65	3	2	\N	2026-06-26 12:49:04.392738+00	2026-06-26 12:50:35.44546+00	\N	\N
3592	66	66	2	2	\N	2026-06-26 15:42:28.580614+00	2026-06-26 15:42:28.580614+00	\N	\N
3546	37	64	0	2	\N	2026-06-26 12:56:17.654619+00	2026-06-26 12:56:17.654619+00	\N	\N
3593	66	64	0	1	\N	2026-06-26 15:42:39.1316+00	2026-06-26 15:42:39.1316+00	\N	\N
3539	37	61	2	3	\N	2026-06-26 12:37:41.997357+00	2026-06-26 13:04:32.159518+00	\N	\N
3535	37	62	2	0	\N	2026-06-26 12:19:00.850441+00	2026-06-26 13:05:33.327689+00	\N	\N
3547	37	63	2	2	\N	2026-06-26 12:58:55.284153+00	2026-06-26 13:08:27.120546+00	\N	\N
3544	37	66	1	3	\N	2026-06-26 12:53:16.512828+00	2026-06-26 13:15:18.459731+00	\N	\N
3566	32	61	2	2	\N	2026-06-26 13:48:19.015967+00	2026-06-26 13:48:19.015967+00	\N	\N
3567	32	62	1	2	\N	2026-06-26 13:48:40.431356+00	2026-06-26 13:48:40.431356+00	\N	\N
3568	32	65	2	1	\N	2026-06-26 13:49:08.54568+00	2026-06-26 13:49:08.54568+00	\N	\N
3569	32	66	2	2	\N	2026-06-26 13:49:26.710613+00	2026-06-26 13:49:26.710613+00	\N	\N
3578	45	64	0	2	\N	2026-06-26 14:36:22.943914+00	2026-06-27 02:34:45.442095+00	\N	\N
3573	13	61	2	3	\N	2026-06-26 14:10:09.697634+00	2026-06-26 14:10:09.697634+00	\N	\N
3574	45	61	1	1	\N	2026-06-26 14:35:29.050849+00	2026-06-26 14:35:29.050849+00	\N	\N
3575	45	62	2	1	\N	2026-06-26 14:35:40.130632+00	2026-06-26 14:35:40.130632+00	\N	\N
3576	45	65	2	1	\N	2026-06-26 14:35:57.300898+00	2026-06-26 14:35:57.300898+00	\N	\N
3577	45	66	2	2	\N	2026-06-26 14:36:09.137216+00	2026-06-26 14:36:09.137216+00	\N	\N
3579	45	63	1	1	\N	2026-06-26 14:36:33.237197+00	2026-06-26 14:36:33.237197+00	\N	\N
3580	11	61	2	3	\N	2026-06-26 15:08:11.298026+00	2026-06-26 15:08:11.298026+00	\N	\N
3581	11	62	1	2	\N	2026-06-26 15:08:44.438077+00	2026-06-26 15:08:44.438077+00	\N	\N
3582	11	65	2	1	\N	2026-06-26 15:09:12.677091+00	2026-06-26 15:09:23.868999+00	\N	\N
3584	11	66	1	3	\N	2026-06-26 15:09:38.082076+00	2026-06-26 15:09:38.082076+00	\N	\N
3585	11	64	2	3	\N	2026-06-26 15:09:52.371015+00	2026-06-26 15:09:52.371015+00	\N	\N
3586	11	63	2	0	\N	2026-06-26 15:10:02.212726+00	2026-06-26 15:10:07.012729+00	\N	\N
3588	13	62	1	0	\N	2026-06-26 15:23:56.872954+00	2026-06-26 15:23:56.872954+00	\N	\N
3589	66	61	1	2	\N	2026-06-26 15:40:22.538045+00	2026-06-26 15:40:22.538045+00	\N	\N
3594	66	63	1	1	\N	2026-06-26 15:43:01.023079+00	2026-06-26 15:43:01.023079+00	\N	\N
3597	36	65	3	2	\N	2026-06-26 16:02:56.289021+00	2026-06-26 16:02:56.289021+00	\N	\N
3598	36	66	1	3	\N	2026-06-26 16:03:09.146903+00	2026-06-26 16:03:09.146903+00	\N	\N
3599	14	61	2	3	\N	2026-06-26 16:05:56.267165+00	2026-06-26 16:05:56.267165+00	\N	\N
3600	14	62	2	1	\N	2026-06-26 16:06:15.382663+00	2026-06-26 16:06:15.382663+00	\N	\N
3601	14	65	1	0	\N	2026-06-26 16:06:24.213271+00	2026-06-26 16:06:24.213271+00	\N	\N
3602	14	66	1	3	\N	2026-06-26 16:06:34.110807+00	2026-06-26 16:06:34.110807+00	\N	\N
3603	14	64	1	2	\N	2026-06-26 16:06:40.490987+00	2026-06-26 16:06:40.490987+00	\N	\N
3604	14	63	3	0	\N	2026-06-26 16:06:46.167999+00	2026-06-26 16:06:46.167999+00	\N	\N
3605	43	61	1	2	\N	2026-06-26 16:24:56.142586+00	2026-06-26 16:24:56.142586+00	\N	\N
3606	43	62	2	1	\N	2026-06-26 16:25:08.089078+00	2026-06-26 16:25:08.089078+00	\N	\N
3607	43	65	1	1	\N	2026-06-26 16:25:15.550763+00	2026-06-26 16:25:15.550763+00	\N	\N
3608	43	66	1	3	\N	2026-06-26 16:25:30.399148+00	2026-06-26 16:25:30.399148+00	\N	\N
3609	43	64	0	2	\N	2026-06-26 16:26:10.135973+00	2026-06-26 16:26:10.135973+00	\N	\N
3610	43	63	1	1	\N	2026-06-26 16:26:37.262668+00	2026-06-26 16:26:37.262668+00	\N	\N
3595	36	61	2	2	\N	2026-06-26 16:02:08.819045+00	2026-06-26 16:34:22.53365+00	\N	\N
3596	36	62	2	1	\N	2026-06-26 16:02:21.965949+00	2026-06-26 16:34:29.776949+00	\N	\N
3613	36	64	1	2	\N	2026-06-26 16:35:00.44847+00	2026-06-26 16:35:00.44847+00	\N	\N
3614	36	63	2	0	\N	2026-06-26 16:35:12.303149+00	2026-06-26 16:35:59.631842+00	\N	\N
3493	10	61	1	3	\N	2026-06-26 04:04:00.79802+00	2026-06-26 16:42:54.274435+00	\N	\N
3617	24	61	1	2	\N	2026-06-26 16:58:28.60404+00	2026-06-26 16:58:28.60404+00	\N	\N
3571	32	63	3	2	\N	2026-06-26 13:50:04.97676+00	2026-06-27 00:07:34.608722+00	\N	\N
3504	33	63	2	1	\N	2026-06-26 04:11:39.229492+00	2026-06-27 02:44:33.786418+00	\N	\N
3618	24	62	2	0	\N	2026-06-26 16:58:34.635928+00	2026-06-26 16:58:34.635928+00	\N	\N
3620	24	66	1	3	\N	2026-06-26 16:58:57.759189+00	2026-06-26 16:58:57.759189+00	\N	\N
3621	24	64	0	2	\N	2026-06-26 16:59:06.285224+00	2026-06-26 16:59:06.285224+00	\N	\N
3622	24	63	2	1	\N	2026-06-26 16:59:15.447799+00	2026-06-26 16:59:15.447799+00	\N	\N
3623	51	61	2	3	\N	2026-06-26 17:05:41.773418+00	2026-06-26 17:05:41.773418+00	\N	\N
3624	51	62	2	1	\N	2026-06-26 17:05:48.06209+00	2026-06-26 17:05:48.06209+00	\N	\N
3625	51	65	1	1	\N	2026-06-26 17:06:40.850927+00	2026-06-26 17:06:40.850927+00	\N	\N
3627	51	64	1	3	\N	2026-06-26 17:06:55.508215+00	2026-06-26 17:06:55.508215+00	\N	\N
3628	51	63	2	1	\N	2026-06-26 17:07:22.933794+00	2026-06-26 17:07:22.933794+00	\N	\N
3629	35	61	2	1	\N	2026-06-26 17:10:23.172935+00	2026-06-26 17:10:23.172935+00	\N	\N
3630	35	62	2	1	\N	2026-06-26 17:10:37.802644+00	2026-06-26 17:10:37.802644+00	\N	\N
3631	35	65	1	0	\N	2026-06-26 17:10:52.577834+00	2026-06-26 17:10:52.577834+00	\N	\N
3633	35	66	0	3	\N	2026-06-26 17:11:32.99085+00	2026-06-26 17:11:32.99085+00	\N	\N
3634	34	62	3	1	\N	2026-06-26 17:11:37.294904+00	2026-06-26 17:11:37.294904+00	\N	\N
3635	50	61	1	2	\N	2026-06-26 17:11:39.639116+00	2026-06-26 17:11:39.639116+00	\N	\N
3636	50	62	2	1	\N	2026-06-26 17:11:46.343993+00	2026-06-26 17:11:46.343993+00	\N	\N
3637	50	65	1	1	\N	2026-06-26 17:11:51.283012+00	2026-06-26 17:11:51.283012+00	\N	\N
3638	34	65	1	0	\N	2026-06-26 17:12:08.828088+00	2026-06-26 17:12:08.828088+00	\N	\N
3639	34	66	1	0	\N	2026-06-26 17:12:33.307064+00	2026-06-26 17:12:33.307064+00	\N	\N
3640	34	64	0	1	\N	2026-06-26 17:12:48.170648+00	2026-06-26 17:12:48.170648+00	\N	\N
3642	50	66	2	1	\N	2026-06-26 17:12:55.396834+00	2026-06-26 17:12:55.396834+00	\N	\N
3644	34	63	2	0	\N	2026-06-26 17:13:05.863938+00	2026-06-26 17:13:05.863938+00	\N	\N
3645	50	63	1	1	\N	2026-06-26 17:13:07.730146+00	2026-06-26 17:13:07.730146+00	\N	\N
3632	34	61	1	2	\N	2026-06-26 17:11:22.217495+00	2026-06-26 17:13:19.376411+00	\N	\N
3647	34	67	0	3	\N	2026-06-26 17:13:33.200562+00	2026-06-26 17:13:33.200562+00	\N	\N
3641	35	64	2	1	\N	2026-06-26 17:12:52.664088+00	2026-06-26 17:13:58.800038+00	\N	\N
3649	34	68	2	0	\N	2026-06-26 17:14:00.450894+00	2026-06-26 17:14:00.450894+00	\N	\N
3650	34	71	2	1	\N	2026-06-26 17:14:12.221309+00	2026-06-26 17:14:12.221309+00	\N	\N
3652	34	72	2	0	\N	2026-06-26 17:14:21.319539+00	2026-06-26 17:14:21.319539+00	\N	\N
3651	35	63	1	2	\N	2026-06-26 17:14:17.679645+00	2026-06-26 17:14:26.601147+00	\N	\N
3654	34	70	0	4	\N	2026-06-26 17:14:29.326808+00	2026-06-26 17:14:29.326808+00	\N	\N
3655	34	69	0	2	\N	2026-06-26 17:14:49.915725+00	2026-06-26 17:14:49.915725+00	\N	\N
3626	51	66	1	3	\N	2026-06-26 17:06:48.870722+00	2026-06-26 17:17:08.788796+00	\N	\N
3657	31	61	1	2	\N	2026-06-26 17:27:18.144393+00	2026-06-26 17:27:18.144393+00	\N	\N
3658	31	62	2	0	\N	2026-06-26 17:27:49.363724+00	2026-06-26 17:27:49.363724+00	\N	\N
3659	31	65	1	1	\N	2026-06-26 17:28:29.734365+00	2026-06-26 17:28:29.734365+00	\N	\N
3660	31	64	0	3	\N	2026-06-26 17:29:10.827333+00	2026-06-26 17:29:10.827333+00	\N	\N
3661	31	63	2	1	\N	2026-06-26 17:29:45.449978+00	2026-06-26 17:29:45.449978+00	\N	\N
3662	68	61	1	3	\N	2026-06-26 17:31:49.513723+00	2026-06-26 17:31:49.513723+00	\N	\N
3664	68	62	1	2	\N	2026-06-26 17:32:28.777142+00	2026-06-26 17:32:28.777142+00	\N	\N
3670	9	67	0	3	\N	2026-06-26 17:33:36.751766+00	2026-06-26 17:33:36.751766+00	\N	\N
3671	9	68	1	0	\N	2026-06-26 17:33:46.557892+00	2026-06-26 17:33:46.557892+00	\N	\N
3672	9	71	2	2	\N	2026-06-26 17:33:55.428275+00	2026-06-26 17:33:55.428275+00	\N	\N
3673	9	72	2	0	\N	2026-06-26 17:34:10.655721+00	2026-06-26 17:34:10.655721+00	\N	\N
3674	9	70	0	3	\N	2026-06-26 17:34:31.123861+00	2026-06-26 17:34:31.123861+00	\N	\N
3675	9	69	1	2	\N	2026-06-26 17:34:39.168353+00	2026-06-26 17:34:39.168353+00	\N	\N
3676	12	61	1	2	\N	2026-06-26 17:59:20.314194+00	2026-06-26 17:59:20.314194+00	\N	\N
3677	12	62	2	1	\N	2026-06-26 17:59:36.654723+00	2026-06-26 17:59:36.654723+00	\N	\N
3678	12	65	1	1	\N	2026-06-26 17:59:48.086327+00	2026-06-26 17:59:48.086327+00	\N	\N
3679	12	66	1	2	\N	2026-06-26 18:00:05.703814+00	2026-06-26 18:00:05.703814+00	\N	\N
3680	41	61	2	3	\N	2026-06-26 18:00:51.088791+00	2026-06-26 18:00:51.088791+00	\N	\N
3681	26	61	1	1	\N	2026-06-26 18:01:31.65781+00	2026-06-26 18:01:31.65781+00	\N	\N
3682	26	62	1	0	\N	2026-06-26 18:01:42.357726+00	2026-06-26 18:01:42.357726+00	\N	\N
3683	26	65	1	1	\N	2026-06-26 18:01:54.692193+00	2026-06-26 18:01:54.692193+00	\N	\N
3684	26	66	1	2	\N	2026-06-26 18:02:09.167889+00	2026-06-26 18:02:09.167889+00	\N	\N
3685	41	62	2	0	\N	2026-06-26 18:02:28.453002+00	2026-06-26 18:02:28.453002+00	\N	\N
3686	41	66	1	2	\N	2026-06-26 18:02:53.567124+00	2026-06-26 18:02:53.567124+00	\N	\N
3687	26	64	1	1	\N	2026-06-26 18:02:55.308723+00	2026-06-26 18:02:55.308723+00	\N	\N
3688	26	63	2	0	\N	2026-06-26 18:03:06.866005+00	2026-06-26 18:03:06.866005+00	\N	\N
3643	50	64	1	3	\N	2026-06-26 17:13:01.036003+00	2026-06-26 23:36:04.638529+00	\N	\N
3691	13	65	1	1	\N	2026-06-26 18:33:45.687724+00	2026-06-26 18:33:45.687724+00	\N	\N
3692	30	61	2	2	\N	2026-06-26 18:33:55.124761+00	2026-06-26 18:33:55.124761+00	\N	\N
3693	30	62	2	1	\N	2026-06-26 18:34:03.674345+00	2026-06-26 18:34:03.674345+00	\N	\N
3694	30	65	3	1	\N	2026-06-26 18:34:17.239542+00	2026-06-26 18:34:17.239542+00	\N	\N
3695	23	61	1	3	\N	2026-06-26 18:34:23.906366+00	2026-06-26 18:34:23.906366+00	\N	\N
3696	30	66	1	2	\N	2026-06-26 18:34:36.229737+00	2026-06-26 18:34:36.229737+00	\N	\N
3697	23	62	2	0	\N	2026-06-26 18:34:52.334526+00	2026-06-26 18:34:52.334526+00	\N	\N
3698	30	64	0	3	\N	2026-06-26 18:34:54.867039+00	2026-06-26 18:34:54.867039+00	\N	\N
3699	30	63	1	2	\N	2026-06-26 18:35:03.77291+00	2026-06-26 18:35:03.77291+00	\N	\N
3700	23	65	1	1	\N	2026-06-26 18:35:53.580262+00	2026-06-26 18:35:53.580262+00	\N	\N
3701	13	66	3	2	\N	2026-06-26 18:36:12.150781+00	2026-06-26 18:36:12.150781+00	\N	\N
3702	13	64	0	2	\N	2026-06-26 18:36:58.606727+00	2026-06-26 18:36:58.606727+00	\N	\N
3703	13	63	1	1	\N	2026-06-26 18:37:31.401041+00	2026-06-26 18:37:31.401041+00	\N	\N
3704	59	61	1	2	\N	2026-06-26 18:39:50.028735+00	2026-06-26 18:39:50.028735+00	\N	\N
3705	59	62	2	1	\N	2026-06-26 18:40:12.492003+00	2026-06-26 18:40:12.492003+00	\N	\N
3706	59	65	1	1	\N	2026-06-26 18:40:39.008664+00	2026-06-26 18:40:39.008664+00	\N	\N
3707	59	66	2	2	\N	2026-06-26 18:41:15.081732+00	2026-06-26 18:41:15.081732+00	\N	\N
3708	29	61	1	2	\N	2026-06-26 18:44:05.387411+00	2026-06-26 18:44:05.387411+00	\N	\N
3709	29	62	2	1	\N	2026-06-26 18:44:11.303722+00	2026-06-26 18:44:11.303722+00	\N	\N
3716	42	65	2	0	\N	2026-06-26 18:54:08.289455+00	2026-06-26 18:54:52.116885+00	\N	\N
3718	42	66	0	2	\N	2026-06-26 18:55:12.699197+00	2026-06-26 18:55:12.699197+00	\N	\N
3710	42	61	2	2	\N	2026-06-26 18:44:38.451546+00	2026-06-26 18:53:23.312433+00	\N	\N
3711	42	62	2	1	\N	2026-06-26 18:44:47.055422+00	2026-06-26 18:53:50.814723+00	\N	\N
3722	37	67	0	3	\N	2026-06-26 20:41:35.864463+00	2026-06-26 20:41:35.864463+00	\N	\N
3724	37	68	2	1	\N	2026-06-26 20:41:51.766953+00	2026-06-26 20:41:51.766953+00	\N	\N
3619	24	65	1	2	\N	2026-06-26 16:58:47.29201+00	2026-06-26 20:41:57.374724+00	\N	\N
3727	37	72	1	0	\N	2026-06-26 20:42:27.085594+00	2026-06-26 20:42:27.085594+00	\N	\N
3730	37	70	0	3	\N	2026-06-26 20:42:43.986743+00	2026-06-26 20:42:43.986743+00	\N	\N
3887	31	67	0	3	\N	2026-06-27 17:31:19.400722+00	2026-06-27 17:31:19.400722+00	\N	\N
3729	38	72	1	0	\N	2026-06-26 20:42:39.060107+00	2026-06-26 20:43:17.867109+00	\N	\N
3728	38	71	2	1	\N	2026-06-26 20:42:29.369391+00	2026-06-26 20:43:19.147257+00	\N	\N
3723	38	67	0	3	\N	2026-06-26 20:41:41.953884+00	2026-06-26 20:43:29.165404+00	\N	\N
3726	38	68	2	0	\N	2026-06-26 20:41:59.746613+00	2026-06-26 20:43:31.381205+00	\N	\N
3689	41	65	2	1	\N	2026-06-26 18:07:16.339732+00	2026-06-26 22:42:52.67781+00	\N	\N
3719	42	64	0	2	\N	2026-06-26 18:55:32.476007+00	2026-06-27 01:54:49.710071+00	\N	\N
3720	42	63	2	0	\N	2026-06-26 18:55:59.65693+00	2026-06-27 01:54:53.414022+00	\N	\N
3734	38	69	0	2	\N	2026-06-26 20:43:06.992793+00	2026-06-26 20:43:10.471656+00	\N	\N
3731	38	70	0	3	\N	2026-06-26 20:42:45.457024+00	2026-06-26 20:43:11.327688+00	\N	\N
3742	68	66	2	1	\N	2026-06-26 21:03:33.497768+00	2026-06-26 21:03:33.497768+00	\N	\N
3844	28	69	0	1	\N	2026-06-27 13:18:35.557307+00	2026-06-27 13:18:35.557307+00	\N	\N
3831	51	68	1	1	\N	2026-06-27 12:23:52.696777+00	2026-06-27 20:12:33.619934+00	\N	\N
3741	68	65	1	0	\N	2026-06-26 21:03:21.630118+00	2026-06-26 21:14:32.317623+00	\N	\N
3747	68	64	0	2	\N	2026-06-26 21:16:13.884343+00	2026-06-26 21:16:13.884343+00	\N	\N
3743	68	63	2	0	\N	2026-06-26 21:04:23.039488+00	2026-06-26 21:17:12.54898+00	\N	\N
3749	41	64	1	3	\N	2026-06-26 22:40:57.583294+00	2026-06-26 22:42:44.937583+00	\N	\N
3750	41	63	2	1	\N	2026-06-26 22:42:31.367976+00	2026-06-26 22:42:59.444835+00	\N	\N
3754	28	68	1	1	\N	2026-06-26 22:49:19.921732+00	2026-06-26 22:49:19.921732+00	\N	\N
3755	28	67	0	3	\N	2026-06-26 22:49:53.302727+00	2026-06-26 22:49:53.302727+00	\N	\N
3756	28	71	0	2	\N	2026-06-26 22:49:53.567733+00	2026-06-26 22:49:53.567733+00	\N	\N
3757	29	64	2	1	\N	2026-06-26 23:23:33.475888+00	2026-06-26 23:23:33.475888+00	\N	\N
3758	29	63	0	2	\N	2026-06-26 23:23:41.423462+00	2026-06-26 23:23:41.423462+00	\N	\N
3760	23	66	2	3	\N	2026-06-26 23:48:29.920733+00	2026-06-26 23:48:29.920733+00	\N	\N
3761	23	63	2	1	\N	2026-06-26 23:48:49.080991+00	2026-06-26 23:48:49.080991+00	\N	\N
3762	23	64	0	2	\N	2026-06-26 23:51:28.157179+00	2026-06-26 23:51:28.157179+00	\N	\N
3570	32	64	2	2	\N	2026-06-26 13:49:54.258839+00	2026-06-27 00:07:22.479957+00	\N	\N
3765	59	64	1	3	\N	2026-06-27 00:27:06.651617+00	2026-06-27 00:27:06.651617+00	\N	\N
3767	44	64	1	2	\N	2026-06-27 00:45:50.109337+00	2026-06-27 00:45:50.109337+00	\N	\N
3768	44	63	1	0	\N	2026-06-27 00:45:58.87238+00	2026-06-27 00:45:58.87238+00	\N	\N
3769	58	67	0	2	\N	2026-06-27 01:27:02.692435+00	2026-06-27 01:27:02.692435+00	\N	\N
3770	58	71	2	1	\N	2026-06-27 01:27:21.514382+00	2026-06-27 01:27:21.514382+00	\N	\N
3773	58	69	1	2	\N	2026-06-27 01:27:56.546862+00	2026-06-27 01:27:56.546862+00	\N	\N
3774	58	68	2	2	\N	2026-06-27 01:28:14.091822+00	2026-06-27 01:28:14.091822+00	\N	\N
3779	45	67	0	3	\N	2026-06-27 02:36:48.471679+00	2026-06-27 02:36:48.471679+00	\N	\N
3780	45	68	2	1	\N	2026-06-27 02:37:05.87697+00	2026-06-27 02:37:05.87697+00	\N	\N
3781	45	71	1	2	\N	2026-06-27 02:37:47.380402+00	2026-06-27 02:37:47.380402+00	\N	\N
3782	45	72	1	1	\N	2026-06-27 02:38:04.287663+00	2026-06-27 02:38:04.287663+00	\N	\N
3783	45	70	0	4	\N	2026-06-27 02:38:22.081353+00	2026-06-27 02:38:22.081353+00	\N	\N
3784	45	69	1	1	\N	2026-06-27 02:38:46.220203+00	2026-06-27 02:38:46.220203+00	\N	\N
3786	55	67	0	2	\N	2026-06-27 03:25:09.399944+00	2026-06-27 03:25:09.399944+00	\N	\N
3787	14	67	0	4	\N	2026-06-27 03:25:16.73937+00	2026-06-27 03:25:16.73937+00	\N	\N
3788	14	68	3	1	\N	2026-06-27 03:25:29.250638+00	2026-06-27 03:25:29.250638+00	\N	\N
3789	14	71	2	1	\N	2026-06-27 03:25:36.992068+00	2026-06-27 03:25:36.992068+00	\N	\N
3790	14	72	2	1	\N	2026-06-27 03:25:54.979734+00	2026-06-27 03:25:54.979734+00	\N	\N
3791	14	70	0	4	\N	2026-06-27 03:26:26.798496+00	2026-06-27 03:26:26.798496+00	\N	\N
3792	14	69	1	2	\N	2026-06-27 03:26:39.423477+00	2026-06-27 03:26:39.423477+00	\N	\N
3793	55	68	1	0	\N	2026-06-27 03:26:43.036921+00	2026-06-27 03:26:43.036921+00	\N	\N
3794	13	67	1	3	\N	2026-06-27 03:27:13.710764+00	2026-06-27 03:27:13.710764+00	\N	\N
3795	13	68	2	1	\N	2026-06-27 03:27:22.193805+00	2026-06-27 03:27:22.193805+00	\N	\N
3796	13	71	2	1	\N	2026-06-27 03:27:37.316479+00	2026-06-27 03:27:37.316479+00	\N	\N
3797	13	72	2	0	\N	2026-06-27 03:27:48.841833+00	2026-06-27 03:27:48.841833+00	\N	\N
3799	55	71	1	1	\N	2026-06-27 03:28:44.040498+00	2026-06-27 03:28:44.040498+00	\N	\N
3800	55	72	1	0	\N	2026-06-27 03:31:33.38382+00	2026-06-27 03:31:33.38382+00	\N	\N
3801	55	70	0	3	\N	2026-06-27 03:31:56.450848+00	2026-06-27 03:31:56.450848+00	\N	\N
3802	55	69	1	1	\N	2026-06-27 03:32:40.182139+00	2026-06-27 03:32:40.182139+00	\N	\N
3803	24	67	0	2	\N	2026-06-27 04:08:52.406017+00	2026-06-27 04:08:52.406017+00	\N	\N
3804	23	67	0	4	\N	2026-06-27 04:14:50.027814+00	2026-06-27 04:14:50.027814+00	\N	\N
3805	23	71	2	3	\N	2026-06-27 04:15:58.56156+00	2026-06-27 04:15:58.56156+00	\N	\N
3806	23	72	2	0	\N	2026-06-27 04:16:27.028634+00	2026-06-27 04:16:27.028634+00	\N	\N
3807	27	67	0	3	\N	2026-06-27 04:17:15.751723+00	2026-06-27 04:17:15.751723+00	\N	\N
3808	27	68	2	1	\N	2026-06-27 04:17:31.914726+00	2026-06-27 04:17:31.914726+00	\N	\N
3809	23	70	0	3	\N	2026-06-27 04:17:40.047723+00	2026-06-27 04:17:40.047723+00	\N	\N
3810	27	71	2	1	\N	2026-06-27 04:18:22.587135+00	2026-06-27 04:18:22.587135+00	\N	\N
3811	27	72	1	1	\N	2026-06-27 04:18:40.883391+00	2026-06-27 04:18:40.883391+00	\N	\N
3812	27	70	0	3	\N	2026-06-27 04:18:49.572256+00	2026-06-27 04:18:49.572256+00	\N	\N
3813	27	69	1	2	\N	2026-06-27 04:19:56.921724+00	2026-06-27 04:19:56.921724+00	\N	\N
3814	23	68	2	2	\N	2026-06-27 04:33:30.999526+00	2026-06-27 04:33:30.999526+00	\N	\N
3815	23	69	0	2	\N	2026-06-27 04:33:47.454076+00	2026-06-27 04:33:47.454076+00	\N	\N
3816	33	67	0	3	\N	2026-06-27 05:03:46.5896+00	2026-06-27 05:03:46.5896+00	\N	\N
3818	33	71	1	1	\N	2026-06-27 05:04:11.404554+00	2026-06-27 05:04:38.328872+00	\N	\N
3820	33	72	2	1	\N	2026-06-27 05:04:49.136399+00	2026-06-27 05:05:01.211775+00	\N	\N
3822	33	70	0	3	\N	2026-06-27 05:05:12.871779+00	2026-06-27 05:05:12.871779+00	\N	\N
3823	33	69	2	1	\N	2026-06-27 05:05:50.360156+00	2026-06-27 05:05:50.360156+00	\N	\N
3817	33	68	3	2	\N	2026-06-27 05:04:05.204794+00	2026-06-27 05:10:57.499464+00	\N	\N
3798	13	70	0	4	\N	2026-06-27 03:28:25.33393+00	2026-06-27 10:46:55.733975+00	\N	\N
3826	51	69	1	1	\N	2026-06-27 12:22:56.178608+00	2026-06-27 12:22:56.178608+00	\N	\N
3766	51	67	0	4	\N	2026-06-27 00:29:23.58838+00	2026-06-27 20:00:29.103734+00	\N	\N
3829	51	72	2	1	\N	2026-06-27 12:23:29.464929+00	2026-06-27 23:19:01.187934+00	\N	\N
3835	46	67	0	4	\N	2026-06-27 13:08:45.234947+00	2026-06-27 13:08:45.234947+00	\N	\N
3836	46	71	2	1	\N	2026-06-27 13:09:03.203218+00	2026-06-27 13:09:03.203218+00	\N	\N
3837	46	68	2	1	\N	2026-06-27 13:09:08.582081+00	2026-06-27 13:09:17.967275+00	\N	\N
3839	46	72	1	0	\N	2026-06-27 13:09:26.061774+00	2026-06-27 13:09:26.061774+00	\N	\N
3840	46	70	0	4	\N	2026-06-27 13:09:35.08923+00	2026-06-27 13:09:35.08923+00	\N	\N
3841	46	69	1	2	\N	2026-06-27 13:09:45.436756+00	2026-06-27 13:09:45.436756+00	\N	\N
3842	28	72	1	0	\N	2026-06-27 13:18:22.297314+00	2026-06-27 13:18:22.297314+00	\N	\N
3843	28	70	0	3	\N	2026-06-27 13:18:30.997503+00	2026-06-27 13:18:30.997503+00	\N	\N
3845	32	72	2	1	\N	2026-06-27 14:38:42.927296+00	2026-06-27 14:38:42.927296+00	\N	\N
3846	32	70	1	3	\N	2026-06-27 14:39:06.791757+00	2026-06-27 14:39:06.791757+00	\N	\N
3847	32	69	2	1	\N	2026-06-27 14:39:27.152242+00	2026-06-27 14:39:27.152242+00	\N	\N
3861	11	67	0	4	\N	2026-06-27 15:01:23.804959+00	2026-06-27 15:01:23.804959+00	\N	\N
3850	32	71	3	1	\N	2026-06-27 14:42:19.910052+00	2026-06-27 14:44:05.431775+00	\N	\N
3849	32	68	2	0	\N	2026-06-27 14:41:59.939352+00	2026-06-27 14:44:11.188505+00	\N	\N
3848	32	67	1	2	\N	2026-06-27 14:41:39.610562+00	2026-06-27 14:43:54.493432+00	\N	\N
3862	11	68	3	1	\N	2026-06-27 15:01:39.859747+00	2026-06-27 15:01:39.859747+00	\N	\N
3863	11	71	2	1	\N	2026-06-27 15:01:53.82747+00	2026-06-27 15:01:53.82747+00	\N	\N
3864	11	72	2	1	\N	2026-06-27 15:02:07.347516+00	2026-06-27 15:02:20.739218+00	\N	\N
3866	11	70	0	3	\N	2026-06-27 15:02:49.915779+00	2026-06-27 15:02:49.915779+00	\N	\N
3867	11	69	2	2	\N	2026-06-27 15:05:57.571818+00	2026-06-27 15:05:57.571818+00	\N	\N
3827	51	70	0	3	\N	2026-06-27 12:23:10.72347+00	2026-06-27 19:56:54.287779+00	\N	\N
3772	58	70	0	3	\N	2026-06-27 01:27:44.789918+00	2026-06-27 21:28:56.561287+00	\N	\N
3830	51	71	1	1	\N	2026-06-27 12:23:42.687727+00	2026-06-27 23:08:58.433251+00	\N	\N
3733	37	69	1	2	\N	2026-06-26 20:43:00.159413+00	2026-06-28 01:40:34.379722+00	\N	\N
3868	10	67	1	4	\N	2026-06-27 15:09:46.844933+00	2026-06-27 15:09:46.844933+00	\N	\N
3869	10	68	1	0	\N	2026-06-27 15:10:01.887724+00	2026-06-27 15:10:01.887724+00	\N	\N
3872	10	70	0	3	\N	2026-06-27 15:10:39.260869+00	2026-06-27 15:10:39.260869+00	\N	\N
3873	10	69	1	3	\N	2026-06-27 15:10:50.626624+00	2026-06-27 15:10:50.626624+00	\N	\N
3888	35	71	1	0	\N	2026-06-27 17:31:32.855733+00	2026-06-27 17:31:32.855733+00	\N	\N
3890	31	71	1	1	\N	2026-06-27 17:32:19.34689+00	2026-06-27 17:32:19.34689+00	\N	\N
3891	31	72	2	0	\N	2026-06-27 17:32:38.343164+00	2026-06-27 17:32:38.343164+00	\N	\N
3892	31	70	0	3	\N	2026-06-27 17:32:50.33467+00	2026-06-27 17:32:50.33467+00	\N	\N
3893	36	67	1	3	\N	2026-06-27 17:33:00.85108+00	2026-06-27 17:33:07.483873+00	\N	\N
3895	36	68	1	1	\N	2026-06-27 17:33:30.977481+00	2026-06-27 17:33:30.977481+00	\N	\N
3896	36	71	2	1	\N	2026-06-27 17:33:41.951999+00	2026-06-27 17:33:41.951999+00	\N	\N
3897	31	69	1	1	\N	2026-06-27 17:33:51.361235+00	2026-06-27 17:33:51.361235+00	\N	\N
3898	36	72	2	1	\N	2026-06-27 17:34:21.869711+00	2026-06-27 17:34:21.869711+00	\N	\N
3899	36	70	1	1	\N	2026-06-27 17:34:36.700247+00	2026-06-27 17:34:36.700247+00	\N	\N
3900	36	69	0	2	\N	2026-06-27 17:34:48.452959+00	2026-06-27 17:34:48.452959+00	\N	\N
3901	44	67	0	4	\N	2026-06-27 17:42:25.447743+00	2026-06-27 17:42:25.447743+00	\N	\N
3902	44	68	2	1	\N	2026-06-27 17:42:39.772916+00	2026-06-27 17:42:39.772916+00	\N	\N
3904	44	72	2	1	\N	2026-06-27 17:42:59.969305+00	2026-06-27 17:42:59.969305+00	\N	\N
3905	44	70	0	3	\N	2026-06-27 17:43:13.046445+00	2026-06-27 17:43:13.046445+00	\N	\N
3906	44	69	1	2	\N	2026-06-27 17:43:26.626304+00	2026-06-27 17:43:26.626304+00	\N	\N
3907	40	67	1	3	\N	2026-06-27 17:44:40.272019+00	2026-06-27 17:44:40.272019+00	\N	\N
3908	40	68	2	2	\N	2026-06-27 17:44:49.007721+00	2026-06-27 17:44:49.007721+00	\N	\N
3909	40	71	2	1	\N	2026-06-27 17:45:00.442783+00	2026-06-27 17:45:00.442783+00	\N	\N
3910	40	72	3	1	\N	2026-06-27 17:45:08.417456+00	2026-06-27 17:45:08.417456+00	\N	\N
3911	40	70	1	3	\N	2026-06-27 17:45:18.682616+00	2026-06-27 17:45:18.682616+00	\N	\N
3912	40	69	1	2	\N	2026-06-27 17:45:26.037848+00	2026-06-27 17:45:26.037848+00	\N	\N
3913	68	67	0	3	\N	2026-06-27 17:59:26.031486+00	2026-06-27 17:59:26.031486+00	\N	\N
3914	68	71	2	2	\N	2026-06-27 17:59:51.029728+00	2026-06-27 17:59:51.029728+00	\N	\N
3915	68	68	0	1	\N	2026-06-27 18:00:40.207076+00	2026-06-27 18:00:40.207076+00	\N	\N
3917	68	70	0	4	\N	2026-06-27 18:01:17.362865+00	2026-06-27 18:01:17.362865+00	\N	\N
3916	68	72	1	0	\N	2026-06-27 18:00:58.464209+00	2026-06-27 18:01:40.636313+00	\N	\N
3919	30	67	0	3	\N	2026-06-27 18:15:04.632121+00	2026-06-27 18:15:04.632121+00	\N	\N
3920	30	68	3	2	\N	2026-06-27 18:15:16.627735+00	2026-06-27 18:15:16.627735+00	\N	\N
3921	30	72	2	0	\N	2026-06-27 18:16:31.546801+00	2026-06-27 18:16:31.546801+00	\N	\N
3922	30	71	2	1	\N	2026-06-27 18:17:09.20829+00	2026-06-27 18:17:09.20829+00	\N	\N
3923	30	69	2	1	\N	2026-06-27 18:17:54.215724+00	2026-06-27 18:17:54.215724+00	\N	\N
3924	29	67	1	3	\N	2026-06-27 18:58:54.617728+00	2026-06-27 18:58:54.617728+00	\N	\N
3925	29	68	2	1	\N	2026-06-27 18:59:06.234933+00	2026-06-27 18:59:06.234933+00	\N	\N
3926	29	71	2	1	\N	2026-06-27 18:59:20.087476+00	2026-06-27 18:59:20.087476+00	\N	\N
3927	29	72	1	1	\N	2026-06-27 18:59:32.549724+00	2026-06-27 18:59:32.549724+00	\N	\N
3928	29	70	0	3	\N	2026-06-27 18:59:42.232357+00	2026-06-27 18:59:42.232357+00	\N	\N
3929	29	69	0	0	\N	2026-06-27 18:59:50.312786+00	2026-06-27 18:59:50.312786+00	\N	\N
3930	42	67	0	3	\N	2026-06-27 19:05:26.815371+00	2026-06-27 19:05:26.815371+00	\N	\N
3932	41	68	2	1	\N	2026-06-27 19:19:22.778077+00	2026-06-27 19:19:22.778077+00	\N	\N
3933	41	71	2	2	\N	2026-06-27 19:19:38.520976+00	2026-06-27 19:19:38.520976+00	\N	\N
3934	41	72	2	1	\N	2026-06-27 19:20:11.067173+00	2026-06-27 19:20:11.067173+00	\N	\N
3931	41	67	0	3	\N	2026-06-27 19:18:46.853854+00	2026-06-27 19:30:17.215737+00	\N	\N
3771	58	72	2	0	\N	2026-06-27 01:27:34.260731+00	2026-06-27 19:31:38.882379+00	\N	\N
3938	41	70	0	2	\N	2026-06-27 19:34:31.997603+00	2026-06-27 19:34:31.997603+00	\N	\N
3939	13	69	2	2	\N	2026-06-27 19:53:03.580684+00	2026-06-27 19:53:03.580684+00	\N	\N
3943	50	67	0	4	\N	2026-06-27 20:23:52.758894+00	2026-06-27 20:23:56.977446+00	\N	\N
3945	50	68	2	1	\N	2026-06-27 20:24:06.032416+00	2026-06-27 20:24:06.032416+00	\N	\N
3946	50	71	1	1	\N	2026-06-27 20:24:11.681167+00	2026-06-27 20:24:11.681167+00	\N	\N
3947	50	72	2	1	\N	2026-06-27 20:24:18.457321+00	2026-06-27 20:24:18.457321+00	\N	\N
3948	50	70	0	3	\N	2026-06-27 20:24:25.936503+00	2026-06-27 20:24:25.936503+00	\N	\N
3949	50	69	1	2	\N	2026-06-27 20:24:46.159243+00	2026-06-27 20:24:46.159243+00	\N	\N
3950	59	67	1	2	\N	2026-06-27 20:38:39.613003+00	2026-06-27 20:38:39.613003+00	\N	\N
3951	59	71	2	1	\N	2026-06-27 20:38:58.181489+00	2026-06-27 20:38:58.181489+00	\N	\N
3952	24	68	2	1	\N	2026-06-27 20:39:22.78152+00	2026-06-27 20:39:22.78152+00	\N	\N
3953	24	71	1	1	\N	2026-06-27 20:39:32.774973+00	2026-06-27 20:39:32.774973+00	\N	\N
3954	24	72	1	0	\N	2026-06-27 20:39:42.063872+00	2026-06-27 20:39:42.063872+00	\N	\N
3955	24	70	0	3	\N	2026-06-27 20:39:54.552877+00	2026-06-27 20:39:54.552877+00	\N	\N
3956	24	69	1	2	\N	2026-06-27 20:40:10.623249+00	2026-06-27 20:40:10.623249+00	\N	\N
3959	48	67	1	2	\N	2026-06-27 20:46:47.095895+00	2026-06-27 20:46:47.095895+00	\N	\N
3960	47	71	2	2	\N	2026-06-27 20:47:11.524737+00	2026-06-27 20:47:11.524737+00	\N	\N
3961	47	72	3	1	\N	2026-06-27 20:47:23.622778+00	2026-06-27 20:47:28.157129+00	\N	\N
3963	47	70	0	3	\N	2026-06-27 20:48:39.729015+00	2026-06-27 20:48:39.729015+00	\N	\N
3964	47	69	1	2	\N	2026-06-27 20:52:08.43378+00	2026-06-27 20:55:32.933026+00	\N	\N
3957	47	67	0	4	\N	2026-06-27 20:46:24.528971+00	2026-06-27 20:55:49.181895+00	\N	\N
3967	48	68	1	1	\N	2026-06-27 20:56:20.353655+00	2026-06-27 20:56:20.353655+00	\N	\N
3958	47	68	2	2	\N	2026-06-27 20:46:36.170379+00	2026-06-27 20:57:13.07169+00	\N	\N
3969	12	71	2	1	\N	2026-06-27 21:07:39.201204+00	2026-06-27 21:07:39.201204+00	\N	\N
3970	12	72	2	0	\N	2026-06-27 21:07:46.824144+00	2026-06-27 21:07:46.824144+00	\N	\N
3971	12	70	0	3	\N	2026-06-27 21:07:55.481423+00	2026-06-27 21:07:55.481423+00	\N	\N
3972	12	69	1	2	\N	2026-06-27 21:08:07.457967+00	2026-06-27 21:08:07.457967+00	\N	\N
3976	42	71	2	1	\N	2026-06-27 21:33:39.540817+00	2026-06-27 21:33:39.540817+00	\N	\N
3977	42	72	2	0	\N	2026-06-27 21:33:53.230538+00	2026-06-27 21:33:53.230538+00	\N	\N
3978	66	71	2	1	\N	2026-06-27 21:44:18.841611+00	2026-06-27 21:44:18.841611+00	\N	\N
3979	66	72	2	1	\N	2026-06-27 21:44:34.043123+00	2026-06-27 21:44:34.043123+00	\N	\N
3980	66	70	2	3	\N	2026-06-27 21:44:46.033297+00	2026-06-27 21:44:46.033297+00	\N	\N
3981	66	69	2	2	\N	2026-06-27 21:44:59.76287+00	2026-06-27 21:44:59.76287+00	\N	\N
3983	26	72	2	0	\N	2026-06-27 22:45:21.57148+00	2026-06-27 22:45:21.57148+00	\N	\N
3984	26	70	0	4	\N	2026-06-27 22:45:40.937722+00	2026-06-27 22:45:40.937722+00	\N	\N
3985	26	69	1	2	\N	2026-06-27 22:45:55.164774+00	2026-06-27 22:45:55.164774+00	\N	\N
3982	26	71	1	1	\N	2026-06-27 22:45:06.094512+00	2026-06-27 22:55:11.968774+00	\N	\N
3988	42	70	0	3	\N	2026-06-27 23:00:27.833401+00	2026-06-27 23:00:27.833401+00	\N	\N
3989	48	71	2	1	\N	2026-06-27 23:08:35.659725+00	2026-06-27 23:08:35.659725+00	\N	\N
3990	48	72	2	0	\N	2026-06-27 23:08:48.981352+00	2026-06-27 23:08:48.981352+00	\N	\N
3871	10	72	2	1	\N	2026-06-27 15:10:26.352726+00	2026-06-27 23:15:23.82734+00	\N	\N
3870	10	71	3	2	\N	2026-06-27 15:10:14.703805+00	2026-06-27 23:15:38.700001+00	\N	\N
3995	68	69	0	2	\N	2026-06-27 23:19:06.046489+00	2026-06-27 23:20:03.86344+00	\N	\N
3903	44	71	3	2	\N	2026-06-27 17:42:47.864793+00	2026-06-27 23:23:22.495506+00	\N	\N
3987	37	71	1	1	\N	2026-06-27 22:56:35.840773+00	2026-06-27 23:25:55.149686+00	\N	\N
3999	59	70	0	2	\N	2026-06-27 23:43:54.998845+00	2026-06-27 23:43:54.998845+00	\N	\N
4000	59	69	1	2	\N	2026-06-27 23:44:14.140229+00	2026-06-27 23:44:14.140229+00	\N	\N
3884	35	70	0	3	\N	2026-06-27 17:30:56.131622+00	2026-06-28 01:28:44.505987+00	\N	\N
4003	48	70	0	3	\N	2026-06-28 01:35:53.171857+00	2026-06-28 01:35:53.171857+00	\N	\N
4004	48	69	1	2	\N	2026-06-28 01:36:12.894802+00	2026-06-28 01:36:12.894802+00	\N	\N
4010	34	75	2	2	21	2026-06-28 04:20:00.276672+00	2026-06-28 16:02:47.648011+00	21	10
4080	11	74	3	1	17	2026-06-28 13:10:08.186866+00	2026-06-28 13:10:08.186866+00	17	14
4081	11	75	3	1	21	2026-06-28 13:10:29.553104+00	2026-06-28 13:10:29.553104+00	21	10
4082	11	76	3	1	9	2026-06-28 13:10:42.99215+00	2026-06-28 13:11:02.578459+00	9	22
4084	28	73	1	0	2	2026-06-28 13:36:11.552982+00	2026-06-28 13:36:11.552982+00	2	5
4085	54	73	1	2	5	2026-06-28 15:08:04.760914+00	2026-06-28 15:08:04.760914+00	2	5
4088	54	76	2	1	9	2026-06-28 15:08:46.486483+00	2026-06-28 15:08:46.486483+00	9	22
4089	54	77	3	0	33	2026-06-28 15:08:53.578747+00	2026-06-28 15:08:53.578747+00	33	23
4090	54	78	0	1	35	2026-06-28 15:09:03.830336+00	2026-06-28 15:09:03.830336+00	19	35
4091	54	79	1	2	20	2026-06-28 15:09:23.373903+00	2026-06-28 15:09:23.373903+00	1	20
4092	54	80	2	1	45	2026-06-28 15:09:30.935+00	2026-06-28 15:09:30.935+00	45	42
4093	54	81	2	0	13	2026-06-28 15:09:38.810903+00	2026-06-28 15:09:38.810903+00	13	8
4094	54	82	2	1	25	2026-06-28 15:09:55.732822+00	2026-06-28 15:09:55.732822+00	25	34
4095	54	83	1	0	41	2026-06-28 15:10:02.075135+00	2026-06-28 15:10:02.075135+00	41	46
4096	54	84	2	0	29	2026-06-28 15:10:06.334129+00	2026-06-28 15:10:06.334129+00	29	39
4097	54	85	1	0	6	2026-06-28 15:10:17.247951+00	2026-06-28 15:10:17.247951+00	6	38
4024	13	74	3	1	17	2026-06-28 05:03:32.148723+00	2026-06-28 05:18:31.039598+00	17	14
4025	13	75	2	1	21	2026-06-28 05:03:32.842725+00	2026-06-28 05:18:31.584884+00	21	10
4026	13	76	3	2	9	2026-06-28 05:03:33.495638+00	2026-06-28 05:18:32.184655+00	9	22
4027	13	77	3	0	33	2026-06-28 05:03:34.036736+00	2026-06-28 05:18:32.788337+00	33	23
4028	13	78	1	3	35	2026-06-28 05:03:34.674175+00	2026-06-28 05:18:33.447991+00	19	35
4029	13	79	2	0	1	2026-06-28 05:03:35.326724+00	2026-06-28 05:18:34.042166+00	1	20
4030	13	80	3	2	45	2026-06-28 05:03:36.0599+00	2026-06-28 05:18:34.646085+00	45	42
4031	13	81	3	1	13	2026-06-28 05:03:36.985283+00	2026-06-28 05:18:35.249033+00	13	8
4032	13	82	1	1	25	2026-06-28 05:03:37.592931+00	2026-06-28 05:18:35.840381+00	25	34
4033	13	83	2	1	41	2026-06-28 05:03:38.332836+00	2026-06-28 05:18:36.848272+00	41	46
4034	13	84	3	0	29	2026-06-28 05:03:39.028535+00	2026-06-28 05:18:37.566006+00	29	39
4035	13	85	2	2	6	2026-06-28 05:03:39.562452+00	2026-06-28 05:18:38.232371+00	6	38
4036	13	86	3	1	37	2026-06-28 05:03:40.214443+00	2026-06-28 05:18:38.846584+00	37	30
4037	13	87	3	0	44	2026-06-28 05:03:40.850363+00	2026-06-28 05:18:39.453526+00	44	47
4038	13	88	1	1	26	2026-06-28 05:03:41.461379+00	2026-06-28 05:18:40.144744+00	15	26
4072	13	89	1	2	33	2026-06-28 05:19:44.294621+00	2026-06-28 05:19:44.294621+00	17	33
4073	13	91	3	1	9	2026-06-28 05:20:52.984335+00	2026-06-28 05:20:52.984335+00	9	35
4074	13	92	2	2	45	2026-06-28 05:28:19.698101+00	2026-06-28 05:28:19.698101+00	1	45
4075	10	74	2	1	17	2026-06-28 06:03:30.257589+00	2026-06-28 06:03:30.257589+00	17	14
4076	10	75	3	2	21	2026-06-28 06:05:05.478515+00	2026-06-28 06:05:05.478515+00	21	10
4077	10	76	2	1	9	2026-06-28 06:05:15.29499+00	2026-06-28 06:05:15.29499+00	9	22
4078	11	73	1	2	5	2026-06-28 13:07:38.042061+00	2026-06-28 13:09:46.88696+00	2	5
4098	54	86	1	0	37	2026-06-28 15:10:23.569597+00	2026-06-28 15:10:28.799558+00	37	30
4100	54	87	2	1	44	2026-06-28 15:10:37.705059+00	2026-06-28 15:10:37.705059+00	44	47
4101	10	73	1	2	5	2026-06-28 15:11:47.577226+00	2026-06-28 15:11:47.577226+00	2	5
4103	46	73	1	3	5	2026-06-28 15:12:42.300386+00	2026-06-28 15:12:42.300386+00	2	5
4107	37	76	2	1	9	2026-06-28 15:26:25.434633+00	2026-06-28 15:26:25.434633+00	9	22
4086	54	74	2	0	17	2026-06-28 15:08:13.056683+00	2026-06-29 14:09:26.603734+00	17	14
4110	37	78	1	2	35	2026-06-28 15:28:22.075275+00	2026-06-28 15:28:22.075275+00	19	35
4114	38	75	2	1	21	2026-06-28 15:38:12.781085+00	2026-06-28 17:22:27.533255+00	21	10
4116	38	77	3	0	33	2026-06-28 15:38:13.968688+00	2026-06-28 17:22:28.750902+00	33	23
4122	38	83	1	0	41	2026-06-28 15:38:17.970555+00	2026-06-28 17:22:32.361485+00	41	46
4120	38	81	1	0	13	2026-06-28 15:38:16.85591+00	2026-06-28 17:22:31.187607+00	13	8
4121	38	82	1	0	25	2026-06-28 15:38:17.390544+00	2026-06-28 17:22:31.759594+00	25	34
4119	38	80	1	0	45	2026-06-28 15:38:15.795241+00	2026-06-28 17:22:30.470984+00	45	42
4008	34	74	2	1	17	2026-06-28 04:17:50.37759+00	2026-06-28 16:02:47.06083+00	17	14
4123	38	84	2	0	29	2026-06-28 15:38:18.54833+00	2026-06-28 17:22:33.009294+00	29	39
4124	38	85	1	0	6	2026-06-28 15:38:19.132742+00	2026-06-28 17:22:33.60506+00	6	38
4108	37	77	3	1	33	2026-06-28 15:27:52.171048+00	2026-06-28 17:17:09.45091+00	33	23
4117	38	78	1	1	19	2026-06-28 15:38:14.583162+00	2026-06-28 17:22:29.365295+00	19	35
4115	38	76	2	0	9	2026-06-28 15:38:13.368996+00	2026-06-28 17:22:28.133434+00	9	22
4011	34	76	3	1	9	2026-06-28 04:20:17.418785+00	2026-06-28 16:02:48.290997+00	9	22
4012	34	77	4	0	33	2026-06-28 04:20:47.198824+00	2026-06-28 16:02:48.902069+00	33	23
4013	34	78	0	1	35	2026-06-28 04:21:05.583571+00	2026-06-28 16:02:49.469727+00	19	35
4014	34	79	1	1	20	2026-06-28 04:21:40.528528+00	2026-06-28 16:02:50.233267+00	1	20
4015	34	80	3	1	45	2026-06-28 04:47:20.973528+00	2026-06-28 16:02:51.447595+00	45	42
4016	34	81	2	0	13	2026-06-28 04:47:31.918182+00	2026-06-28 16:02:52.264927+00	13	8
4017	34	82	1	3	34	2026-06-28 04:47:44.436008+00	2026-06-28 16:02:52.847947+00	25	34
4019	34	83	1	1	41	2026-06-28 04:50:29.736174+00	2026-06-28 16:02:53.552912+00	41	46
4018	34	84	3	1	29	2026-06-28 04:50:11.527734+00	2026-06-28 16:02:55.132536+00	29	39
4020	34	85	3	0	6	2026-06-28 04:50:46.449235+00	2026-06-28 16:02:56.689806+00	6	38
4021	34	86	2	0	37	2026-06-28 04:52:24.148613+00	2026-06-28 16:02:57.563844+00	37	30
4022	34	87	2	1	44	2026-06-28 04:52:57.748787+00	2026-06-28 16:02:58.169934+00	44	47
4023	34	88	1	2	26	2026-06-28 04:53:12.276214+00	2026-06-28 16:02:58.703977+00	15	26
4104	37	73	1	3	5	2026-06-28 15:23:28.370087+00	2026-06-28 16:10:13.028519+00	2	5
4111	37	79	1	0	1	2026-06-28 15:29:02.808092+00	2026-06-28 21:02:57.279734+00	1	20
4113	38	74	2	0	17	2026-06-28 15:38:12.236215+00	2026-06-28 17:22:26.949691+00	17	14
4106	37	75	1	0	21	2026-06-28 15:26:13.550089+00	2026-06-28 21:01:53.884679+00	21	10
4087	54	75	2	1	21	2026-06-28 15:08:26.97551+00	2026-06-29 14:09:28.082048+00	21	10
4102	54	88	1	1	15	2026-06-28 15:11:52.337577+00	2026-06-29 14:13:34.558736+00	15	26
4130	11	78	0	2	35	2026-06-28 15:39:43.283053+00	2026-06-28 15:39:43.283053+00	19	35
4132	11	79	2	1	1	2026-06-28 15:39:53.192796+00	2026-06-28 15:39:53.192796+00	1	20
4133	11	80	3	1	45	2026-06-28 15:40:02.186388+00	2026-06-28 15:40:02.186388+00	45	42
4135	11	81	2	0	13	2026-06-28 15:40:16.575507+00	2026-06-28 15:40:16.575507+00	13	8
4137	11	82	4	2	25	2026-06-28 15:40:27.435273+00	2026-06-28 15:40:27.435273+00	25	34
4138	11	83	3	2	41	2026-06-28 15:40:38.291933+00	2026-06-28 15:40:38.291933+00	41	46
4140	11	84	4	2	29	2026-06-28 15:40:49.835096+00	2026-06-28 15:40:49.835096+00	29	39
4141	11	85	2	1	6	2026-06-28 15:40:59.822301+00	2026-06-28 15:40:59.822301+00	6	38
4142	11	86	3	1	37	2026-06-28 15:41:08.678727+00	2026-06-28 15:41:08.678727+00	37	30
4145	11	87	2	0	44	2026-06-28 15:41:30.046643+00	2026-06-28 15:41:30.046643+00	44	47
4147	11	88	2	1	15	2026-06-28 15:41:47.800465+00	2026-06-28 15:41:47.800465+00	15	26
4149	10	77	3	1	33	2026-06-28 15:42:51.554853+00	2026-06-28 15:42:51.554853+00	33	23
4151	10	78	1	2	35	2026-06-28 15:43:07.333909+00	2026-06-28 15:43:07.333909+00	19	35
4236	14	75	3	1	21	2026-06-28 16:04:36.696069+00	2026-06-28 16:04:36.696069+00	21	10
4127	38	88	1	0	15	2026-06-28 15:38:20.96283+00	2026-06-28 17:22:36.491583+00	15	26
4203	38	89	1	2	33	2026-06-28 16:00:54.78903+00	2026-06-28 17:22:50.25073+00	17	33
4158	1	73	1	0	2	2026-06-28 15:44:51.077916+00	2026-06-28 15:44:51.077916+00	2	5
4159	1	74	1	0	17	2026-06-28 15:44:56.763494+00	2026-06-28 15:44:56.763494+00	17	14
4204	38	90	0	1	21	2026-06-28 16:01:07.761075+00	2026-06-28 17:22:50.798046+00	5	21
4161	10	79	1	2	20	2026-06-28 15:47:34.770093+00	2026-06-28 15:47:34.770093+00	1	20
4162	10	80	2	0	45	2026-06-28 15:48:14.636197+00	2026-06-28 15:48:14.636197+00	45	42
4163	10	81	3	1	13	2026-06-28 15:48:22.66772+00	2026-06-28 15:48:22.66772+00	13	8
4164	10	82	1	0	25	2026-06-28 15:49:24.941566+00	2026-06-28 15:49:24.941566+00	25	34
4165	10	83	3	2	41	2026-06-28 15:49:41.495563+00	2026-06-28 15:49:41.495563+00	41	46
4166	10	84	3	1	29	2026-06-28 15:49:50.635164+00	2026-06-28 15:49:50.635164+00	29	39
4118	38	79	2	1	1	2026-06-28 15:38:15.197181+00	2026-06-28 17:22:29.899987+00	1	20
4178	10	85	2	0	6	2026-06-28 15:50:54.354686+00	2026-06-28 15:50:54.354686+00	6	38
4179	10	86	2	0	37	2026-06-28 15:51:21.40057+00	2026-06-28 15:51:21.40057+00	37	30
4180	10	87	3	1	44	2026-06-28 15:51:32.681863+00	2026-06-28 15:51:32.681863+00	44	47
4181	10	88	1	2	26	2026-06-28 15:51:40.67675+00	2026-06-28 15:51:40.67675+00	15	26
4182	10	89	1	2	33	2026-06-28 15:52:00.990621+00	2026-06-28 15:52:00.990621+00	17	33
4183	10	90	1	3	21	2026-06-28 15:52:12.353723+00	2026-06-28 15:52:12.353723+00	5	21
4184	10	91	2	1	9	2026-06-28 15:52:20.255347+00	2026-06-28 15:52:20.255347+00	9	35
4185	10	92	1	2	45	2026-06-28 15:52:28.833334+00	2026-06-28 15:52:28.833334+00	20	45
4186	10	93	2	1	41	2026-06-28 15:52:47.86894+00	2026-06-28 15:52:47.86894+00	41	29
4187	10	94	2	1	13	2026-06-28 15:52:58.028533+00	2026-06-28 15:53:00.742661+00	13	25
4189	10	95	2	1	37	2026-06-28 15:53:08.090746+00	2026-06-28 15:53:08.090746+00	37	26
4190	10	96	1	2	44	2026-06-28 15:53:15.763036+00	2026-06-28 15:53:15.763036+00	6	44
4191	10	97	3	1	33	2026-06-28 15:53:42.767987+00	2026-06-28 15:53:42.767987+00	33	21
4192	10	98	2	1	41	2026-06-28 15:53:50.831421+00	2026-06-28 15:53:50.831421+00	41	13
4193	10	99	1	0	9	2026-06-28 15:56:12.272121+00	2026-06-28 15:56:12.272121+00	9	45
4194	10	100	1	2	44	2026-06-28 15:56:19.460946+00	2026-06-28 15:56:19.460946+00	37	44
4195	10	101	2	1	33	2026-06-28 15:56:31.146957+00	2026-06-28 15:56:31.146957+00	33	41
4196	10	102	1	2	44	2026-06-28 15:56:39.786296+00	2026-06-28 15:56:39.786296+00	9	44
4197	10	103	2	1	41	2026-06-28 15:57:08.876724+00	2026-06-28 15:57:08.876724+00	41	9
4198	10	104	1	2	44	2026-06-28 15:57:26.70354+00	2026-06-28 15:57:26.70354+00	33	44
4200	56	73	0	1	5	2026-06-28 15:57:46.906722+00	2026-06-28 15:57:46.906722+00	2	5
4201	44	73	2	1	2	2026-06-28 15:59:09.344532+00	2026-06-28 15:59:09.344532+00	2	5
4202	27	74	3	1	17	2026-06-28 15:59:49.657674+00	2026-06-28 15:59:49.657674+00	17	14
4208	27	75	2	2	10	2026-06-28 16:02:04.696478+00	2026-06-28 16:02:04.696478+00	21	10
4207	34	73	0	1	5	2026-06-28 16:02:04.663999+00	2026-06-28 16:02:46.483204+00	2	5
4229	14	73	1	2	5	2026-06-28 16:03:17.679233+00	2026-06-28 16:03:17.679233+00	2	5
4231	14	74	3	1	17	2026-06-28 16:03:31.943516+00	2026-06-28 16:03:31.943516+00	17	14
4234	14	76	3	0	9	2026-06-28 16:04:11.161626+00	2026-06-28 16:04:11.161626+00	9	22
4235	27	76	2	1	9	2026-06-28 16:04:32.2649+00	2026-06-28 16:04:32.2649+00	9	22
4237	27	77	3	0	33	2026-06-28 16:04:44.179587+00	2026-06-28 16:04:44.179587+00	33	23
4239	14	78	1	1	35	2026-06-28 16:04:49.679137+00	2026-06-28 16:04:49.679137+00	19	35
4240	14	79	1	2	20	2026-06-28 16:05:01.431769+00	2026-06-28 16:05:01.431769+00	1	20
4242	14	80	3	1	45	2026-06-28 16:05:08.112137+00	2026-06-28 16:05:08.112137+00	45	42
4245	27	78	1	1	35	2026-06-28 16:06:11.054802+00	2026-06-28 16:06:33.628526+00	19	35
4249	27	79	2	1	1	2026-06-28 16:07:00.097568+00	2026-06-28 16:07:00.097568+00	1	20
4250	27	80	3	0	45	2026-06-28 16:07:12.236956+00	2026-06-28 16:07:12.236956+00	45	42
4247	38	103	3	4	9	2026-06-28 16:06:36.967644+00	2026-06-28 17:33:53.138638+00	33	9
4241	38	100	4	5	44	2026-06-28 16:05:04.156926+00	2026-06-28 17:22:57.29929+00	37	44
4230	38	97	1	0	33	2026-06-28 16:03:19.898212+00	2026-06-28 17:22:55.22857+00	33	21
4243	38	101	3	4	29	2026-06-28 16:05:35.938747+00	2026-06-28 17:23:16.672775+00	33	29
4233	34	89	1	3	33	2026-06-28 16:03:37.561233+00	2026-06-28 16:50:36.481466+00	17	33
4244	38	102	3	4	44	2026-06-28 16:06:09.510407+00	2026-06-28 17:23:18.370301+00	9	44
4199	27	73	0	1	5	2026-06-28 15:57:42.778818+00	2026-06-28 20:52:35.68624+00	2	5
4232	38	98	2	1	29	2026-06-28 16:03:33.874082+00	2026-06-28 17:22:55.93413+00	29	25
4206	38	92	0	1	45	2026-06-28 16:02:01.663926+00	2026-06-28 17:22:51.94091+00	1	45
4238	38	99	4	3	9	2026-06-28 16:04:46.958725+00	2026-06-28 17:22:56.781117+00	9	45
4210	38	94	0	1	25	2026-06-28 16:02:32.682214+00	2026-06-28 17:22:53.052347+00	13	25
4218	38	95	2	1	37	2026-06-28 16:02:51.243934+00	2026-06-28 17:22:53.652724+00	37	15
4209	38	93	1	2	29	2026-06-28 16:02:17.976023+00	2026-06-28 17:22:52.475428+00	41	29
4125	38	86	2	0	37	2026-06-28 15:38:19.695163+00	2026-06-28 17:22:34.14567+00	37	30
4126	38	87	2	0	44	2026-06-28 15:38:20.275171+00	2026-06-28 17:22:35.139897+00	44	47
4205	38	91	1	0	9	2026-06-28 16:01:29.771905+00	2026-06-28 17:22:51.410558+00	9	19
4112	38	73	0	1	5	2026-06-28 15:38:11.663562+00	2026-06-28 17:22:26.138368+00	2	5
4421	15	81	3	0	13	2026-06-28 16:20:34.34604+00	2026-06-28 16:24:53.003626+00	13	8
4259	27	81	2	0	13	2026-06-28 16:07:43.642403+00	2026-06-28 16:07:43.642403+00	13	8
4267	27	82	1	2	34	2026-06-28 16:07:57.739221+00	2026-06-28 16:07:57.739221+00	25	34
4269	27	83	2	1	41	2026-06-28 16:08:09.203726+00	2026-06-28 16:08:09.203726+00	41	46
4274	27	84	3	0	29	2026-06-28 16:08:20.460131+00	2026-06-28 16:08:20.460131+00	29	39
4423	15	82	1	1	34	2026-06-28 16:20:51.642856+00	2026-06-28 16:24:53.63212+00	25	34
4283	27	85	2	1	6	2026-06-28 16:08:38.870931+00	2026-06-28 16:08:38.870931+00	6	38
4297	27	86	1	1	37	2026-06-28 16:09:17.88674+00	2026-06-28 16:09:17.88674+00	37	30
4302	27	87	3	1	44	2026-06-28 16:09:28.749242+00	2026-06-28 16:09:28.749242+00	44	47
4303	27	88	1	2	26	2026-06-28 16:09:35.832445+00	2026-06-28 16:09:35.832445+00	15	26
4248	38	104	4	5	44	2026-06-28 16:06:55.449683+00	2026-06-28 17:33:52.592976+00	29	44
4425	15	83	1	1	41	2026-06-28 16:21:15.236544+00	2026-06-29 16:52:33.774146+00	41	46
4426	15	84	2	0	29	2026-06-28 16:21:28.290489+00	2026-06-28 16:24:54.879349+00	29	39
4427	15	85	1	1	6	2026-06-28 16:21:45.331781+00	2026-06-28 16:24:55.468376+00	6	38
4253	36	73	1	3	5	2026-06-28 16:07:18.790756+00	2026-06-28 19:52:14.770718+00	2	5
4428	15	86	3	0	37	2026-06-28 16:21:54.386731+00	2026-06-28 16:24:56.838819+00	37	30
4453	56	77	4	0	33	2026-06-28 16:24:57.359241+00	2026-06-28 16:24:57.359241+00	33	23
4398	34	95	2	0	37	2026-06-28 16:15:24.063791+00	2026-06-28 16:50:39.394011+00	37	26
4402	12	73	0	2	5	2026-06-28 16:16:17.014184+00	2026-06-28 16:16:17.014184+00	2	5
4404	14	88	0	1	26	2026-06-28 16:18:53.644578+00	2026-06-28 16:18:53.644578+00	15	26
4409	14	86	3	1	37	2026-06-28 16:19:18.632534+00	2026-06-28 16:19:18.632534+00	37	30
4410	14	85	2	1	6	2026-06-28 16:19:36.624998+00	2026-06-28 16:19:36.624998+00	6	38
4412	14	84	2	0	29	2026-06-28 16:19:46.335549+00	2026-06-28 16:19:46.335549+00	29	39
4405	14	87	2	1	44	2026-06-28 16:19:02.635488+00	2026-06-29 01:44:02.174101+00	44	47
4418	14	82	1	1	25	2026-06-28 16:20:18.13052+00	2026-06-28 16:20:18.13052+00	25	34
4352	36	76	2	1	9	2026-06-28 16:11:24.981452+00	2026-06-29 15:12:11.397032+00	9	22
4424	14	77	3	0	33	2026-06-28 16:20:57.547001+00	2026-06-28 16:20:57.547001+00	33	23
4479	15	98	1	0	29	2026-06-28 16:28:08.07646+00	2026-06-29 16:49:52.262139+00	29	13
4407	15	74	3	0	17	2026-06-28 16:19:15.040774+00	2026-06-28 16:24:46.629078+00	17	14
4406	15	75	1	1	10	2026-06-28 16:19:12.681862+00	2026-06-28 16:24:47.749516+00	21	10
4411	15	76	2	0	9	2026-06-28 16:19:38.683056+00	2026-06-28 16:24:48.879139+00	9	22
4413	15	77	3	0	33	2026-06-28 16:19:48.646011+00	2026-06-28 16:24:49.635678+00	33	23
4415	15	78	2	1	19	2026-06-28 16:20:02.980993+00	2026-06-28 16:24:50.840943+00	19	35
4417	15	79	2	1	1	2026-06-28 16:20:11.571372+00	2026-06-28 16:24:51.544469+00	1	20
4419	15	80	1	0	45	2026-06-28 16:20:27.502354+00	2026-06-28 16:24:52.350666+00	45	42
4429	15	87	2	0	44	2026-06-28 16:22:01.8542+00	2026-06-28 16:24:58.061253+00	44	47
4476	15	90	0	1	10	2026-06-28 16:27:39.363222+00	2026-06-29 16:53:13.894452+00	5	10
4457	56	79	2	1	1	2026-06-28 16:25:25.5286+00	2026-06-28 16:25:28.836+00	1	20
4459	55	73	0	1	5	2026-06-28 16:25:36.745965+00	2026-06-28 16:25:36.745965+00	2	5
4461	56	80	2	1	45	2026-06-28 16:25:49.445399+00	2026-06-28 16:25:54.232423+00	45	42
4464	56	81	2	1	13	2026-06-28 16:26:04.488979+00	2026-06-28 16:26:04.488979+00	13	8
4467	56	82	1	1	25	2026-06-28 16:26:22.819011+00	2026-06-28 16:26:22.819011+00	25	34
4469	56	83	0	0	41	2026-06-28 16:26:36.998524+00	2026-06-28 16:26:36.998524+00	41	46
4471	56	84	2	0	29	2026-06-28 16:26:49.610417+00	2026-06-28 16:26:53.48059+00	29	39
4477	56	87	1	0	44	2026-06-28 16:27:59.265358+00	2026-06-28 16:27:59.265358+00	44	47
4408	15	73	0	0	5	2026-06-28 16:19:17.835692+00	2026-06-28 16:33:26.77021+00	2	5
4462	15	92	0	2	45	2026-06-28 16:25:53.033802+00	2026-06-29 16:49:20.685958+00	1	45
4465	15	93	1	1	29	2026-06-28 16:26:07.592617+00	2026-06-29 16:49:22.147733+00	41	29
4466	15	94	1	0	13	2026-06-28 16:26:17.276926+00	2026-06-29 16:49:23.749747+00	13	34
4468	15	95	2	0	37	2026-06-28 16:26:27.597989+00	2026-06-29 16:49:24.764217+00	37	15
4470	15	96	0	1	44	2026-06-28 16:26:41.013748+00	2026-06-29 16:49:26.968673+00	6	44
4474	15	97	2	0	33	2026-06-28 16:27:05.843468+00	2026-06-29 16:49:51.735278+00	33	10
4383	34	91	2	1	9	2026-06-28 16:14:04.442087+00	2026-06-28 16:50:37.032732+00	9	35
4437	56	75	2	1	21	2026-06-28 16:24:31.651492+00	2026-06-28 19:09:52.137289+00	21	10
4431	9	73	0	2	5	2026-06-28 16:23:56.670573+00	2026-06-28 18:18:59.437976+00	2	5
4430	15	88	1	1	15	2026-06-28 16:23:50.765329+00	2026-06-29 16:52:51.167914+00	15	26
4484	15	99	1	1	9	2026-06-28 16:28:19.500443+00	2026-06-29 16:53:47.249033+00	9	45
4460	15	91	1	0	9	2026-06-28 16:25:43.543122+00	2026-06-29 16:49:19.829486+00	9	19
4385	34	92	0	2	45	2026-06-28 16:14:13.798166+00	2026-06-28 16:50:37.573866+00	20	45
4401	34	93	0	0	29	2026-06-28 16:16:01.931931+00	2026-06-28 16:50:38.181812+00	41	29
4399	34	94	0	1	34	2026-06-28 16:15:41.690781+00	2026-06-28 16:50:38.85201+00	13	34
4393	34	96	1	2	44	2026-06-28 16:15:07.809668+00	2026-06-28 16:50:39.944508+00	6	44
4433	9	74	3	1	17	2026-06-28 16:24:13.723857+00	2026-06-28 18:18:59.978731+00	17	14
4435	9	75	1	2	10	2026-06-28 16:24:20.837726+00	2026-06-28 18:19:00.548404+00	21	10
4436	9	76	2	0	9	2026-06-28 16:24:28.064731+00	2026-06-28 18:19:01.086733+00	9	22
4486	9	77	3	1	33	2026-06-28 16:29:56.943204+00	2026-06-28 18:19:01.682712+00	33	23
4487	9	78	1	2	35	2026-06-28 16:30:04.567549+00	2026-06-28 18:19:02.370775+00	19	35
4488	9	79	1	2	20	2026-06-28 16:30:12.632768+00	2026-06-28 18:19:03.049904+00	1	20
4456	56	78	1	2	35	2026-06-28 16:25:14.798203+00	2026-06-28 19:11:49.067947+00	19	35
4481	56	88	0	0	26	2026-06-28 16:28:09.440539+00	2026-06-28 23:41:04.328952+00	15	26
4441	56	76	2	1	9	2026-06-28 16:24:48.059898+00	2026-06-28 23:40:30.328743+00	9	22
4475	56	86	0	0	37	2026-06-28 16:27:12.369308+00	2026-06-28 19:33:22.543953+00	37	30
4473	56	85	1	1	6	2026-06-28 16:27:04.349734+00	2026-06-28 23:40:53.152233+00	6	38
4414	14	83	1	0	41	2026-06-28 16:19:52.319284+00	2026-06-29 01:43:26.842323+00	41	46
4420	14	81	2	2	13	2026-06-28 16:20:31.301743+00	2026-06-29 01:42:45.7735+00	13	8
4434	56	74	3	1	17	2026-06-28 16:24:19.134996+00	2026-06-29 14:01:07.78587+00	17	14
4403	12	74	3	0	17	2026-06-28 16:16:32.347834+00	2026-06-29 15:56:28.487271+00	17	14
4485	15	100	1	1	37	2026-06-28 16:28:34.388486+00	2026-06-29 16:53:57.794679+00	37	44
4511	41	73	1	2	5	2026-06-28 16:33:18.683861+00	2026-06-28 16:33:18.683861+00	2	5
4513	9	89	2	2	33	2026-06-28 16:33:29.839958+00	2026-06-28 16:33:29.839958+00	17	33
4514	56	89	2	2	33	2026-06-28 16:33:32.022932+00	2026-06-28 16:33:34.285733+00	17	33
4516	9	90	0	2	10	2026-06-28 16:33:37.357891+00	2026-06-28 16:33:37.357891+00	5	10
4518	9	91	3	2	9	2026-06-28 16:33:44.325858+00	2026-06-28 16:33:44.325858+00	9	35
4519	9	92	2	2	45	2026-06-28 16:33:56.33389+00	2026-06-28 16:33:56.33389+00	20	45
4520	9	93	2	2	41	2026-06-28 16:34:12.964561+00	2026-06-28 16:34:12.964561+00	41	29
4521	9	94	1	2	25	2026-06-28 16:34:26.753213+00	2026-06-28 16:34:26.753213+00	13	25
4522	9	95	3	1	37	2026-06-28 16:34:36.781461+00	2026-06-28 16:34:36.781461+00	37	26
4523	9	96	0	2	44	2026-06-28 16:34:47.651522+00	2026-06-28 16:34:47.651522+00	6	44
4531	9	101	2	0	33	2026-06-28 16:35:50.600732+00	2026-06-28 16:35:50.600732+00	33	41
4530	15	103	1	2	45	2026-06-28 16:35:32.703755+00	2026-06-29 18:09:30.98101+00	29	9
4534	9	102	1	2	44	2026-06-28 16:35:58.683673+00	2026-06-28 16:35:58.683673+00	45	44
4524	15	101	1	0	33	2026-06-28 16:34:54.437128+00	2026-06-29 16:49:43.906806+00	33	29
4536	9	103	1	1	45	2026-06-28 16:36:13.309711+00	2026-06-28 16:36:13.309711+00	41	45
4432	15	89	2	2	33	2026-06-28 16:24:09.379739+00	2026-06-29 16:49:17.733045+00	17	33
4532	15	104	1	1	37	2026-06-28 16:35:52.962733+00	2026-06-29 16:54:22.042365+00	33	37
4567	13	73	0	3	5	2026-06-28 16:37:28.440413+00	2026-06-28 16:37:28.440413+00	2	5
4543	29	73	0	2	5	2026-06-28 16:36:41.270767+00	2026-06-28 16:38:05.741344+00	2	5
4544	29	74	3	1	17	2026-06-28 16:36:42.165861+00	2026-06-28 16:38:18.15273+00	17	14
4570	9	104	1	1	44	2026-06-28 16:38:18.382348+00	2026-06-28 16:38:18.382348+00	33	44
4545	29	75	2	0	21	2026-06-28 16:36:43.238561+00	2026-06-28 16:38:24.578163+00	21	10
4546	29	76	3	1	9	2026-06-28 16:36:44.257262+00	2026-06-28 16:38:32.180836+00	9	22
4594	35	73	1	0	2	2026-06-28 16:59:47.066163+00	2026-06-28 16:59:47.066163+00	2	5
4547	29	77	3	1	33	2026-06-28 16:36:46.032333+00	2026-06-28 16:38:46.64809+00	33	23
4575	41	74	2	1	17	2026-06-28 16:42:22.409984+00	2026-06-28 16:42:22.409984+00	17	14
4583	34	90	0	1	21	2026-06-28 16:50:54.731724+00	2026-06-28 16:50:58.086785+00	5	21
4585	34	97	2	0	33	2026-06-28 16:51:17.0544+00	2026-06-28 16:51:17.0544+00	33	21
4586	34	98	1	2	34	2026-06-28 16:51:26.806285+00	2026-06-28 16:51:26.806285+00	29	34
4587	34	99	2	1	9	2026-06-28 16:51:37.881889+00	2026-06-28 16:51:37.881889+00	9	45
4588	34	100	1	2	44	2026-06-28 16:51:46.827731+00	2026-06-28 16:51:46.827731+00	37	44
4589	34	101	2	0	33	2026-06-28 16:51:57.42991+00	2026-06-28 16:51:57.42991+00	33	34
4590	34	102	2	0	9	2026-06-28 16:52:07.977965+00	2026-06-28 16:52:07.977965+00	9	44
4591	34	103	0	1	44	2026-06-28 16:52:16.803891+00	2026-06-28 16:52:16.803891+00	34	44
4592	34	104	2	1	33	2026-06-28 16:52:26.666151+00	2026-06-28 16:52:26.666151+00	33	9
4595	35	74	3	0	17	2026-06-28 16:59:54.266633+00	2026-06-28 16:59:54.266633+00	17	14
4596	35	75	0	1	10	2026-06-28 17:00:02.775546+00	2026-06-28 17:00:02.775546+00	21	10
4597	35	76	2	0	9	2026-06-28 17:00:09.763455+00	2026-06-28 17:00:09.763455+00	9	22
4598	35	77	2	0	33	2026-06-28 17:00:17.415941+00	2026-06-28 17:00:17.415941+00	33	23
4599	35	78	0	1	35	2026-06-28 17:00:23.915845+00	2026-06-28 17:00:23.915845+00	19	35
4600	35	79	1	2	20	2026-06-28 17:00:34.127414+00	2026-06-28 17:00:34.127414+00	1	20
4601	35	80	1	0	45	2026-06-28 17:00:42.287828+00	2026-06-28 17:00:42.287828+00	45	42
4602	35	81	0	1	8	2026-06-28 17:00:53.169411+00	2026-06-28 17:00:53.169411+00	13	8
4603	35	82	1	1	25	2026-06-28 17:01:11.040373+00	2026-06-28 17:01:11.040373+00	25	34
4604	35	83	0	1	46	2026-06-28 17:01:17.44089+00	2026-06-28 17:01:17.44089+00	41	46
4605	35	84	2	0	29	2026-06-28 17:01:27.247862+00	2026-06-28 17:01:27.247862+00	29	39
4606	35	85	1	0	6	2026-06-28 17:01:35.676554+00	2026-06-28 17:01:35.676554+00	6	38
4607	35	86	2	0	37	2026-06-28 17:01:43.263867+00	2026-06-28 17:01:43.263867+00	37	30
4608	35	87	1	0	44	2026-06-28 17:01:50.449948+00	2026-06-28 17:01:50.449948+00	44	47
4609	13	93	1	3	29	2026-06-28 17:01:53.136357+00	2026-06-28 17:01:53.136357+00	41	29
4610	35	88	0	1	26	2026-06-28 17:01:59.051065+00	2026-06-28 17:01:59.051065+00	15	26
4611	13	94	2	1	13	2026-06-28 17:02:07.346649+00	2026-06-28 17:02:07.346649+00	13	25
4612	35	89	0	1	33	2026-06-28 17:02:10.462904+00	2026-06-28 17:02:10.462904+00	17	33
4613	13	95	3	0	37	2026-06-28 17:02:15.086979+00	2026-06-28 17:02:15.086979+00	37	26
4499	9	81	1	0	13	2026-06-28 16:30:42.22854+00	2026-06-28 18:19:04.427061+00	13	8
4500	9	82	2	2	25	2026-06-28 16:30:51.535232+00	2026-06-28 18:19:05.076007+00	25	34
4501	9	83	2	0	41	2026-06-28 16:31:00.816364+00	2026-06-28 18:19:05.752991+00	41	46
4502	9	84	3	1	29	2026-06-28 16:31:07.047446+00	2026-06-28 18:19:06.831333+00	29	39
4505	9	85	1	1	6	2026-06-28 16:31:19.265494+00	2026-06-28 18:19:07.348219+00	6	38
4509	9	87	2	0	44	2026-06-28 16:31:33.395515+00	2026-06-28 18:19:08.644189+00	44	47
4510	9	88	1	3	26	2026-06-28 16:31:42.639348+00	2026-06-28 18:19:09.286897+00	15	26
4517	56	90	1	1	21	2026-06-28 16:33:41.163759+00	2026-06-28 19:34:57.898403+00	5	21
4593	58	73	1	2	5	2026-06-28 16:56:04.584141+00	2026-06-28 19:07:44.371804+00	2	5
4529	9	100	2	2	44	2026-06-28 16:35:30.557911+00	2026-06-29 15:54:26.575037+00	37	44
4527	9	98	2	1	41	2026-06-28 16:35:08.03132+00	2026-06-29 15:54:04.517171+00	41	25
4525	9	97	2	1	33	2026-06-28 16:34:57.876836+00	2026-06-29 15:54:05.125725+00	33	10
4528	9	99	1	1	45	2026-06-28 16:35:21.96031+00	2026-06-29 15:54:05.723359+00	9	45
4549	29	79	3	2	1	2026-06-28 16:36:47.43304+00	2026-06-29 16:10:43.504657+00	1	20
4548	29	78	1	2	35	2026-06-28 16:36:46.852795+00	2026-06-29 16:10:28.468212+00	19	35
4550	29	80	3	1	45	2026-06-28 16:36:48.044718+00	2026-06-29 16:10:59.043386+00	45	42
4551	29	81	2	1	13	2026-06-28 16:36:48.645114+00	2026-06-29 16:11:09.20399+00	13	8
4552	29	82	2	1	25	2026-06-28 16:36:49.180555+00	2026-06-29 16:11:18.288198+00	25	34
4554	29	84	3	0	29	2026-06-28 16:36:50.36344+00	2026-06-29 16:11:49.34489+00	29	39
4553	29	83	2	1	41	2026-06-28 16:36:49.768943+00	2026-06-29 16:11:39.395069+00	41	46
4555	29	85	1	0	6	2026-06-28 16:36:51.002142+00	2026-06-29 16:12:06.850018+00	6	38
4556	29	86	3	1	37	2026-06-28 16:36:51.661472+00	2026-06-29 16:12:24.545003+00	37	30
4557	29	87	2	1	44	2026-06-28 16:36:52.267559+00	2026-06-29 16:12:32.79237+00	44	47
4558	29	88	1	0	15	2026-06-28 16:36:52.914328+00	2026-06-29 16:12:46.625725+00	15	26
4526	15	102	0	1	37	2026-06-28 16:35:01.946538+00	2026-06-29 18:09:30.978148+00	9	37
4614	35	90	0	2	10	2026-06-28 17:02:19.567986+00	2026-06-28 17:02:19.567986+00	2	10
4615	13	96	1	2	44	2026-06-28 17:02:24.076112+00	2026-06-28 17:02:24.076112+00	6	44
4616	35	91	1	0	9	2026-06-28 17:02:28.29182+00	2026-06-28 17:02:28.29182+00	9	35
4617	35	92	0	1	45	2026-06-28 17:02:36.130605+00	2026-06-28 17:02:36.130605+00	20	45
4619	35	93	0	2	29	2026-06-28 17:02:44.671098+00	2026-06-28 17:02:44.671098+00	46	29
4621	35	94	0	1	25	2026-06-28 17:02:55.178735+00	2026-06-28 17:02:55.178735+00	8	25
4622	35	95	3	0	37	2026-06-28 17:03:01.310634+00	2026-06-28 17:03:01.310634+00	37	26
4624	35	96	0	1	44	2026-06-28 17:03:10.105927+00	2026-06-28 17:03:10.105927+00	6	44
4626	35	97	1	1	33	2026-06-28 17:03:21.204929+00	2026-06-28 17:03:21.204929+00	33	10
4627	35	98	2	0	29	2026-06-28 17:03:30.493586+00	2026-06-28 17:03:30.493586+00	29	25
4629	35	99	0	1	45	2026-06-28 17:03:38.733278+00	2026-06-28 17:03:38.733278+00	9	45
4632	35	100	1	0	37	2026-06-28 17:03:48.249728+00	2026-06-28 17:03:48.249728+00	37	44
4633	35	101	1	0	33	2026-06-28 17:03:56.649613+00	2026-06-28 17:03:56.649613+00	33	29
4634	35	102	0	1	37	2026-06-28 17:04:03.757002+00	2026-06-28 17:04:03.757002+00	45	37
4636	68	73	2	0	2	2026-06-28 17:04:13.085403+00	2026-06-28 17:04:13.085403+00	2	5
4638	35	103	1	0	29	2026-06-28 17:04:19.481354+00	2026-06-28 17:04:19.481354+00	29	45
4640	35	104	1	0	33	2026-06-28 17:04:29.861892+00	2026-06-28 17:04:29.861892+00	33	37
4645	13	90	1	2	21	2026-06-28 17:05:17.272441+00	2026-06-28 17:05:17.272441+00	5	21
4646	13	97	2	0	33	2026-06-28 17:06:53.567998+00	2026-06-28 17:06:53.567998+00	33	21
4647	13	98	2	1	29	2026-06-28 17:08:41.85872+00	2026-06-28 17:09:14.33141+00	29	13
4652	37	81	2	0	13	2026-06-28 17:18:07.26239+00	2026-06-28 23:39:17.490948+00	13	8
4228	38	96	0	2	44	2026-06-28 16:03:03.587396+00	2026-06-28 17:22:54.195812+00	6	44
4698	37	83	1	1	46	2026-06-28 17:31:51.374831+00	2026-06-28 17:31:51.374831+00	41	46
4700	37	85	2	1	6	2026-06-28 17:32:25.970807+00	2026-06-28 17:32:40.310726+00	6	38
4702	37	86	3	1	37	2026-06-28 17:33:14.367661+00	2026-06-28 17:33:36.956506+00	37	30
4728	37	88	0	1	26	2026-06-28 17:40:00.558166+00	2026-06-28 21:07:37.286327+00	15	26
4708	48	73	2	1	2	2026-06-28 17:36:34.430064+00	2026-06-28 17:36:34.430064+00	2	5
4651	37	80	2	0	45	2026-06-28 17:17:56.86669+00	2026-06-28 23:38:37.049266+00	45	42
4710	30	73	0	2	5	2026-06-28 17:38:21.354304+00	2026-06-28 17:38:21.354304+00	2	5
4712	48	74	2	1	17	2026-06-28 17:38:37.039138+00	2026-06-28 17:38:40.770831+00	17	14
4721	30	76	3	1	9	2026-06-28 17:39:26.83941+00	2026-06-28 22:27:47.293597+00	9	22
4716	48	75	1	1	10	2026-06-28 17:38:48.933009+00	2026-06-28 17:38:48.933009+00	21	10
4717	48	76	3	1	9	2026-06-28 17:38:57.748978+00	2026-06-28 17:38:57.748978+00	9	22
4718	48	77	2	1	33	2026-06-28 17:39:05.663208+00	2026-06-28 17:39:05.663208+00	33	23
4719	48	78	1	3	35	2026-06-28 17:39:12.85493+00	2026-06-28 17:39:12.85493+00	19	35
4720	48	79	2	2	1	2026-06-28 17:39:21.19172+00	2026-06-28 17:39:21.19172+00	1	20
4723	48	80	1	1	45	2026-06-28 17:39:41.305986+00	2026-06-28 17:39:41.305986+00	45	42
4725	48	81	3	1	13	2026-06-28 17:39:50.251195+00	2026-06-28 17:39:50.251195+00	13	8
4727	48	82	1	1	25	2026-06-28 17:39:59.584105+00	2026-06-28 17:39:59.584105+00	25	34
4729	48	83	2	1	41	2026-06-28 17:40:07.045915+00	2026-06-28 17:40:07.045915+00	41	46
4740	37	91	2	1	9	2026-06-28 17:45:01.564728+00	2026-06-28 17:45:01.564728+00	9	35
4741	31	73	1	2	5	2026-06-28 17:48:19.29367+00	2026-06-28 17:48:19.29367+00	2	5
4742	37	92	1	2	45	2026-06-28 17:48:24.748069+00	2026-06-28 17:48:24.748069+00	1	45
4747	31	74	3	1	17	2026-06-28 17:52:16.877325+00	2026-06-28 17:52:16.877325+00	17	14
4699	37	84	2	0	29	2026-06-28 17:32:10.932743+00	2026-06-28 23:40:35.267068+00	29	39
4653	37	82	2	1	25	2026-06-28 17:18:20.580066+00	2026-06-28 21:05:36.961729+00	25	34
4706	37	87	2	1	44	2026-06-28 17:34:15.780363+00	2026-06-28 23:43:33.757026+00	44	47
4738	37	89	2	3	33	2026-06-28 17:44:24.055725+00	2026-06-28 23:44:57.154083+00	17	33
4743	37	93	0	1	29	2026-06-28 17:49:09.875955+00	2026-06-28 23:49:29.084742+00	46	29
4739	37	90	0	2	21	2026-06-28 17:44:40.929766+00	2026-06-28 21:08:26.671383+00	5	21
4744	37	94	1	2	25	2026-06-28 17:49:26.777396+00	2026-06-28 21:09:27.166277+00	13	25
4711	30	74	2	1	17	2026-06-28 17:38:30.249025+00	2026-06-28 22:27:45.789985+00	17	14
4745	37	95	2	1	37	2026-06-28 17:49:50.068197+00	2026-06-28 21:09:59.050811+00	37	26
4713	30	75	1	2	10	2026-06-28 17:38:37.657073+00	2026-06-28 22:27:46.752182+00	21	10
4722	30	77	3	1	33	2026-06-28 17:39:36.650747+00	2026-06-28 22:27:47.954227+00	33	23
4724	30	78	0	3	35	2026-06-28 17:39:42.281299+00	2026-06-28 22:27:48.574168+00	19	35
4726	30	79	3	0	1	2026-06-28 17:39:56.839883+00	2026-06-28 22:27:49.238011+00	1	20
4730	30	80	1	0	45	2026-06-28 17:40:16.937203+00	2026-06-28 22:27:49.861437+00	45	42
4731	30	81	3	1	13	2026-06-28 17:40:24.345342+00	2026-06-28 22:27:50.567989+00	13	8
4733	30	82	2	0	25	2026-06-28 17:40:54.456616+00	2026-06-28 22:27:51.243725+00	25	34
4732	30	83	2	0	41	2026-06-28 17:40:42.382393+00	2026-06-28 22:27:51.851935+00	41	46
4734	30	84	3	1	29	2026-06-28 17:41:03.936354+00	2026-06-28 22:27:52.467372+00	29	39
4735	30	85	2	0	6	2026-06-28 17:41:31.625472+00	2026-06-28 22:27:53.169998+00	6	38
4736	30	86	2	1	37	2026-06-28 17:41:41.097784+00	2026-06-28 22:27:53.760004+00	37	30
4737	30	87	2	1	44	2026-06-28 17:41:47.315335+00	2026-06-28 22:27:54.435191+00	44	47
4618	12	75	0	0	10	2026-06-28 17:02:40.045378+00	2026-06-29 15:56:29.157386+00	21	10
4620	12	76	2	0	9	2026-06-28 17:02:54.773937+00	2026-06-29 15:56:29.759797+00	9	22
4623	12	77	3	0	33	2026-06-28 17:03:05.482338+00	2026-06-29 15:56:30.408836+00	33	23
4625	12	78	0	3	35	2026-06-28 17:03:20.225471+00	2026-06-29 15:56:30.983733+00	19	35
4628	12	79	0	2	20	2026-06-28 17:03:30.541723+00	2026-06-29 15:56:31.639662+00	1	20
4630	12	80	2	0	45	2026-06-28 17:03:39.337312+00	2026-06-29 15:56:32.37072+00	45	42
4631	12	81	2	0	13	2026-06-28 17:03:47.238652+00	2026-06-29 15:56:33.331783+00	13	8
4635	12	82	0	0	34	2026-06-28 17:04:04.959855+00	2026-06-29 15:56:33.889806+00	25	34
4637	12	83	2	0	41	2026-06-28 17:04:16.852369+00	2026-06-29 15:56:34.487716+00	41	46
4639	12	84	2	0	29	2026-06-28 17:04:24.84842+00	2026-06-29 15:56:35.052838+00	29	39
4641	12	85	0	0	6	2026-06-28 17:04:34.880567+00	2026-06-29 15:56:35.643327+00	6	38
4642	12	86	2	0	37	2026-06-28 17:04:42.577854+00	2026-06-29 15:56:36.661731+00	37	30
4644	12	88	0	1	26	2026-06-28 17:05:03.444824+00	2026-06-29 15:56:37.730719+00	15	26
4749	37	98	1	2	25	2026-06-28 17:55:42.818919+00	2026-06-28 17:55:49.545826+00	29	25
4756	37	103	1	2	9	2026-06-28 18:00:19.214407+00	2026-06-28 18:00:19.214407+00	25	9
4758	24	73	1	2	5	2026-06-28 18:06:14.538038+00	2026-06-28 18:06:14.538038+00	2	5
4759	24	74	2	0	17	2026-06-28 18:06:29.855688+00	2026-06-28 18:06:29.855688+00	17	14
4760	24	76	2	1	9	2026-06-28 18:06:52.976609+00	2026-06-28 18:06:52.976609+00	9	22
4761	24	75	1	1	21	2026-06-28 18:07:02.994827+00	2026-06-28 18:07:02.994827+00	21	10
4762	24	77	3	1	33	2026-06-28 18:07:12.84581+00	2026-06-28 18:07:12.84581+00	33	23
4763	24	78	2	1	19	2026-06-28 18:07:29.750566+00	2026-06-28 18:07:36.035023+00	19	35
4765	24	79	0	0	20	2026-06-28 18:07:50.28927+00	2026-06-28 18:08:01.124449+00	1	20
4767	24	80	2	1	45	2026-06-28 18:08:10.677614+00	2026-06-28 18:08:10.677614+00	45	42
4768	24	81	1	0	13	2026-06-28 18:08:24.666452+00	2026-06-28 18:08:24.666452+00	13	8
4769	24	82	0	1	34	2026-06-28 18:12:13.984155+00	2026-06-28 18:12:13.984155+00	25	34
4770	24	83	2	0	41	2026-06-28 18:12:26.765599+00	2026-06-28 18:12:26.765599+00	41	46
4771	25	73	0	2	5	2026-06-28 18:12:35.365467+00	2026-06-28 18:12:35.365467+00	2	5
4772	24	84	3	0	29	2026-06-28 18:12:36.965137+00	2026-06-28 18:12:36.965137+00	29	39
4773	24	85	2	1	6	2026-06-28 18:12:46.612766+00	2026-06-28 18:12:46.612766+00	6	38
4774	25	74	2	0	17	2026-06-28 18:12:47.489214+00	2026-06-28 18:12:47.489214+00	17	14
4775	24	86	3	0	37	2026-06-28 18:12:53.754348+00	2026-06-28 18:12:53.754348+00	37	30
4776	24	87	1	0	44	2026-06-28 18:13:02.405992+00	2026-06-28 18:13:02.405992+00	44	47
4777	25	75	1	2	10	2026-06-28 18:13:07.147463+00	2026-06-28 18:13:07.147463+00	21	10
4778	25	76	2	0	9	2026-06-28 18:13:16.859961+00	2026-06-28 18:13:16.859961+00	9	22
4779	25	77	3	0	33	2026-06-28 18:13:27.340723+00	2026-06-28 18:13:27.340723+00	33	23
4780	25	78	1	1	35	2026-06-28 18:13:43.297574+00	2026-06-28 18:13:43.297574+00	19	35
4781	24	88	1	3	26	2026-06-28 18:13:54.688882+00	2026-06-28 18:13:54.688882+00	15	26
4782	25	79	0	2	20	2026-06-28 18:13:56.937561+00	2026-06-28 18:13:56.937561+00	1	20
4784	25	80	3	0	45	2026-06-28 18:14:17.633874+00	2026-06-28 18:14:17.633874+00	45	42
4785	24	90	0	2	21	2026-06-28 18:14:21.064732+00	2026-06-28 18:14:21.064732+00	5	21
4786	25	81	1	0	13	2026-06-28 18:14:28.681522+00	2026-06-28 18:14:28.681522+00	13	8
4787	40	73	2	1	2	2026-06-28 18:14:31.343554+00	2026-06-28 18:14:31.343554+00	2	5
4788	24	91	1	0	9	2026-06-28 18:14:33.233777+00	2026-06-28 18:14:33.233777+00	9	19
4789	24	92	0	1	45	2026-06-28 18:14:41.04951+00	2026-06-28 18:14:41.04951+00	20	45
4790	24	93	1	2	29	2026-06-28 18:14:51.948347+00	2026-06-28 18:14:51.948347+00	41	29
4791	25	82	2	1	25	2026-06-28 18:14:56.764672+00	2026-06-28 18:14:56.764672+00	25	34
4792	31	75	1	1	10	2026-06-28 18:15:03.530053+00	2026-06-28 18:15:03.530053+00	21	10
4793	40	74	3	1	17	2026-06-28 18:15:09.962919+00	2026-06-28 18:15:09.962919+00	17	14
4795	25	83	2	1	41	2026-06-28 18:15:10.251001+00	2026-06-28 18:15:10.251001+00	41	46
4796	31	76	2	1	9	2026-06-28 18:15:14.798958+00	2026-06-28 18:15:14.798958+00	9	22
4797	24	95	2	1	37	2026-06-28 18:15:19.17526+00	2026-06-28 18:15:19.17526+00	37	26
4798	40	75	2	1	21	2026-06-28 18:15:21.235298+00	2026-06-28 18:15:21.235298+00	21	10
4799	31	77	2	1	33	2026-06-28 18:15:24.786634+00	2026-06-28 18:15:24.786634+00	33	23
4800	24	96	0	1	44	2026-06-28 18:15:27.637141+00	2026-06-28 18:15:27.637141+00	6	44
4801	25	84	3	1	29	2026-06-28 18:15:30.411743+00	2026-06-28 18:15:30.411743+00	29	39
4802	24	89	1	3	33	2026-06-28 18:15:48.478631+00	2026-06-28 18:15:48.478631+00	17	33
4803	25	85	1	1	6	2026-06-28 18:15:49.500102+00	2026-06-28 18:15:49.500102+00	6	38
4804	40	76	2	2	9	2026-06-28 18:15:51.355758+00	2026-06-28 18:15:51.355758+00	9	22
4805	40	77	2	1	33	2026-06-28 18:16:02.274966+00	2026-06-28 18:16:02.274966+00	33	23
4806	25	86	3	0	37	2026-06-28 18:16:05.078378+00	2026-06-28 18:16:05.078378+00	37	30
4822	40	85	1	2	38	2026-06-28 18:17:16.252672+00	2026-06-28 18:17:16.252672+00	6	38
4808	25	87	2	0	44	2026-06-28 18:16:13.062138+00	2026-06-28 18:16:13.062138+00	44	47
4794	24	94	1	1	13	2026-06-28 18:15:10.123612+00	2026-06-28 18:16:18.033408+00	13	34
4810	40	78	2	1	19	2026-06-28 18:16:18.052945+00	2026-06-28 18:16:18.052945+00	19	35
4811	40	79	1	2	20	2026-06-28 18:16:26.898169+00	2026-06-28 18:16:26.898169+00	1	20
4812	25	88	2	0	15	2026-06-28 18:16:29.250919+00	2026-06-28 18:16:29.250919+00	15	26
4813	24	97	2	0	33	2026-06-28 18:16:30.232728+00	2026-06-28 18:16:30.232728+00	33	21
4814	40	80	2	1	45	2026-06-28 18:16:36.389754+00	2026-06-28 18:16:36.389754+00	45	42
4815	24	98	2	1	29	2026-06-28 18:16:39.571787+00	2026-06-28 18:16:39.571787+00	29	13
4816	40	81	2	1	13	2026-06-28 18:16:43.138685+00	2026-06-28 18:16:43.138685+00	13	8
4817	40	82	1	3	34	2026-06-28 18:16:51.178597+00	2026-06-28 18:16:51.178597+00	25	34
4818	24	99	0	1	45	2026-06-28 18:16:54.679084+00	2026-06-28 18:16:54.679084+00	9	45
4819	40	83	2	1	41	2026-06-28 18:16:58.283942+00	2026-06-28 18:16:58.283942+00	41	46
4820	24	100	1	1	44	2026-06-28 18:17:07.434759+00	2026-06-28 18:17:07.434759+00	37	44
4821	40	84	2	2	29	2026-06-28 18:17:08.042718+00	2026-06-28 18:17:08.042718+00	29	39
4823	40	86	1	2	30	2026-06-28 18:17:27.667738+00	2026-06-28 18:17:27.667738+00	37	30
4824	40	87	3	1	44	2026-06-28 18:17:33.974549+00	2026-06-28 18:17:33.974549+00	44	47
4825	24	101	1	0	33	2026-06-28 18:17:38.834603+00	2026-06-28 18:17:38.834603+00	33	29
4826	40	88	1	2	26	2026-06-28 18:17:44.436421+00	2026-06-28 18:17:44.436421+00	15	26
4827	40	89	2	2	17	2026-06-28 18:17:53.391237+00	2026-06-28 18:17:53.391237+00	17	33
4828	40	90	2	3	21	2026-06-28 18:18:01.383035+00	2026-06-28 18:18:01.383035+00	2	21
4829	24	102	1	2	44	2026-06-28 18:18:02.225723+00	2026-06-28 18:18:02.225723+00	45	44
4830	24	103	1	0	29	2026-06-28 18:18:14.996612+00	2026-06-28 18:18:14.996612+00	29	45
4831	24	104	2	0	33	2026-06-28 18:18:23.593722+00	2026-06-28 18:18:23.593722+00	33	44
4498	9	80	3	0	45	2026-06-28 16:30:32.876355+00	2026-06-28 18:19:03.746124+00	45	42
4508	9	86	2	0	37	2026-06-28 16:31:26.875243+00	2026-06-28 18:19:07.991344+00	37	30
4748	37	97	2	1	33	2026-06-28 17:55:08.972721+00	2026-06-28 21:10:39.046714+00	33	21
4849	42	74	2	0	17	2026-06-28 18:19:27.305161+00	2026-06-29 16:55:07.178355+00	17	14
4754	37	101	2	1	33	2026-06-28 17:58:34.786745+00	2026-06-28 23:54:02.960341+00	33	25
4752	37	100	2	1	37	2026-06-28 17:56:40.694209+00	2026-06-28 21:11:16.858412+00	37	44
4755	37	102	2	3	37	2026-06-28 17:58:56.447401+00	2026-06-28 21:12:01.079734+00	9	37
4751	37	99	2	2	9	2026-06-28 17:56:26.694683+00	2026-06-28 23:53:17.499224+00	9	45
4757	37	104	2	3	37	2026-06-28 18:01:36.58174+00	2026-06-28 21:14:21.698746+00	33	37
4783	42	73	0	2	5	2026-06-28 18:13:58.088382+00	2026-06-28 18:20:41.482718+00	2	5
4869	40	91	2	2	9	2026-06-28 18:31:37.497721+00	2026-06-28 18:31:37.497721+00	9	19
4870	40	92	2	1	20	2026-06-28 18:31:45.393728+00	2026-06-28 18:31:45.393728+00	20	45
4871	40	93	2	1	41	2026-06-28 18:31:53.166726+00	2026-06-28 18:31:53.166726+00	41	29
4872	40	94	1	2	34	2026-06-28 18:32:00.281879+00	2026-06-28 18:32:00.281879+00	13	34
4873	40	95	2	1	30	2026-06-28 18:32:08.218301+00	2026-06-28 18:32:08.218301+00	30	26
4874	40	96	1	2	44	2026-06-28 18:32:16.572652+00	2026-06-28 18:32:16.572652+00	38	44
4875	40	97	1	3	21	2026-06-28 18:32:26.683418+00	2026-06-28 18:32:26.683418+00	17	21
4876	40	98	1	2	34	2026-06-28 18:32:36.958178+00	2026-06-28 18:32:36.958178+00	41	34
4877	40	99	1	2	20	2026-06-28 18:32:46.231934+00	2026-06-28 18:32:46.231934+00	9	20
4883	26	73	2	1	2	2026-06-28 18:33:22.131186+00	2026-06-28 18:33:22.131186+00	2	5
4885	26	74	2	1	17	2026-06-28 18:33:32.038009+00	2026-06-28 18:33:32.038009+00	17	14
4886	26	75	1	1	21	2026-06-28 18:33:43.430311+00	2026-06-28 18:33:43.430311+00	21	10
4878	40	100	1	3	44	2026-06-28 18:32:51.374174+00	2026-06-28 18:33:52.459909+00	30	44
4888	26	76	2	2	9	2026-06-28 18:33:59.540722+00	2026-06-28 18:33:59.540722+00	9	22
4889	26	77	2	0	33	2026-06-28 18:34:12.793869+00	2026-06-28 18:34:12.793869+00	33	23
4890	26	78	1	1	19	2026-06-28 18:34:27.157823+00	2026-06-28 18:34:27.157823+00	19	35
4891	26	79	2	1	1	2026-06-28 18:34:37.688944+00	2026-06-28 18:34:37.688944+00	1	20
4892	26	80	2	0	45	2026-06-28 18:34:46.431568+00	2026-06-28 18:34:46.431568+00	45	42
4893	26	81	1	1	13	2026-06-28 18:35:00.868611+00	2026-06-28 18:35:00.868611+00	13	8
4894	40	104	1	2	44	2026-06-28 18:35:02.031759+00	2026-06-28 18:35:10.993576+00	21	44
4896	26	82	1	1	25	2026-06-28 18:35:16.745908+00	2026-06-28 18:35:16.745908+00	25	34
4897	26	83	1	2	46	2026-06-28 18:35:31.172268+00	2026-06-28 18:35:31.172268+00	41	46
4898	26	84	2	1	29	2026-06-28 18:35:41.728754+00	2026-06-28 18:35:41.728754+00	29	39
4899	44	74	2	0	17	2026-06-28 18:35:43.854176+00	2026-06-28 18:35:43.854176+00	17	14
4927	26	93	0	2	29	2026-06-28 18:39:50.851513+00	2026-06-28 18:39:50.851513+00	46	29
4928	26	94	1	1	13	2026-06-28 18:40:01.75031+00	2026-06-28 18:40:01.75031+00	13	25
4902	26	85	1	1	6	2026-06-28 18:36:17.36988+00	2026-06-28 18:36:17.36988+00	6	38
4903	30	89	2	3	33	2026-06-28 18:36:19.046079+00	2026-06-28 18:36:19.046079+00	17	33
4905	40	103	2	1	34	2026-06-28 18:36:23.126727+00	2026-06-28 18:36:27.510905+00	34	20
4907	26	86	1	2	30	2026-06-28 18:36:30.179512+00	2026-06-28 18:36:30.179512+00	37	30
4908	30	91	1	2	35	2026-06-28 18:36:33.064493+00	2026-06-28 18:36:33.064493+00	9	35
4880	40	101	2	2	21	2026-06-28 18:33:04.993153+00	2026-06-28 18:36:35.259047+00	21	34
4881	40	102	1	2	44	2026-06-28 18:33:11.041231+00	2026-06-28 18:36:36.545937+00	20	44
4911	26	87	2	0	44	2026-06-28 18:36:44.230016+00	2026-06-28 18:36:44.230016+00	44	47
4912	30	92	2	1	1	2026-06-28 18:36:56.264184+00	2026-06-28 18:36:56.264184+00	1	45
4913	26	88	1	2	26	2026-06-28 18:37:02.56026+00	2026-06-28 18:37:02.56026+00	15	26
4914	30	93	2	1	41	2026-06-28 18:37:04.843765+00	2026-06-28 18:37:04.843765+00	41	29
4915	30	94	2	1	13	2026-06-28 18:38:15.36808+00	2026-06-28 18:38:15.36808+00	13	25
4916	30	95	3	1	37	2026-06-28 18:38:19.815132+00	2026-06-28 18:38:25.371195+00	37	15
4918	30	96	1	2	44	2026-06-28 18:38:51.290022+00	2026-06-28 18:38:51.290022+00	6	44
4919	26	89	1	1	17	2026-06-28 18:38:53.472289+00	2026-06-28 18:38:53.472289+00	17	33
4920	26	90	1	2	21	2026-06-28 18:39:12.790357+00	2026-06-28 18:39:12.790357+00	2	21
4922	26	91	1	0	9	2026-06-28 18:39:24.836694+00	2026-06-28 18:39:24.836694+00	9	19
4923	30	98	2	1	41	2026-06-28 18:39:32.813924+00	2026-06-28 18:39:32.813924+00	41	13
4924	26	92	1	2	45	2026-06-28 18:39:38.89411+00	2026-06-28 18:39:38.89411+00	1	45
4925	30	99	2	1	35	2026-06-28 18:39:39.93468+00	2026-06-28 18:39:39.93468+00	35	1
4926	30	100	2	1	37	2026-06-28 18:39:47.909509+00	2026-06-28 18:39:47.909509+00	37	44
4929	26	95	1	0	30	2026-06-28 18:40:12.288868+00	2026-06-28 18:40:12.288868+00	30	26
4930	26	96	1	3	44	2026-06-28 18:40:22.08583+00	2026-06-28 18:40:22.08583+00	6	44
4931	26	97	2	1	17	2026-06-28 18:40:50.262743+00	2026-06-28 18:40:50.262743+00	17	21
4932	30	101	2	1	33	2026-06-28 18:40:55.615636+00	2026-06-28 18:40:55.615636+00	33	41
4933	26	98	2	1	29	2026-06-28 18:41:02.903733+00	2026-06-28 18:41:02.903733+00	29	13
4935	50	73	1	2	5	2026-06-28 18:41:07.551862+00	2026-06-28 18:41:07.551862+00	2	5
4942	26	99	2	2	9	2026-06-28 18:41:13.860019+00	2026-06-28 18:41:13.860019+00	9	45
4944	30	102	3	2	35	2026-06-28 18:41:16.035084+00	2026-06-28 18:41:16.035084+00	35	37
4943	36	79	2	2	1	2026-06-28 18:41:13.961791+00	2026-06-29 15:12:13.236817+00	1	20
4945	36	80	2	1	45	2026-06-28 18:41:16.634138+00	2026-06-29 15:12:13.76804+00	45	42
4884	47	73	0	1	5	2026-06-28 18:33:22.733067+00	2026-06-28 19:46:10.678532+00	2	5
4921	30	97	2	1	33	2026-06-28 18:39:23.167185+00	2026-06-28 22:21:00.423911+00	33	10
4882	30	90	1	2	10	2026-06-28 18:33:14.580999+00	2026-06-28 22:13:51.193512+00	5	10
4941	36	78	2	1	19	2026-06-28 18:41:12.175434+00	2026-06-29 15:12:12.549189+00	19	35
4852	42	77	3	0	33	2026-06-28 18:19:29.079432+00	2026-06-29 16:55:24.999848+00	33	23
4904	44	75	3	1	21	2026-06-28 18:36:21.914277+00	2026-06-29 14:21:27.524912+00	21	10
4879	30	88	2	1	15	2026-06-28 18:33:00.124652+00	2026-06-28 22:27:55.175029+00	15	26
4937	36	75	1	1	21	2026-06-28 18:41:08.6092+00	2026-06-29 15:12:10.830014+00	21	10
4854	42	79	1	2	20	2026-06-28 18:19:30.366516+00	2026-06-29 16:55:37.072292+00	1	20
4851	42	76	2	1	9	2026-06-28 18:19:28.483882+00	2026-06-29 16:55:20.147723+00	9	22
4853	42	78	0	2	35	2026-06-28 18:19:29.774016+00	2026-06-29 16:55:33.141868+00	19	35
4858	42	83	2	1	41	2026-06-28 18:19:34.263871+00	2026-06-29 16:55:56.8342+00	41	46
4855	42	80	3	0	45	2026-06-28 18:19:31.035306+00	2026-06-29 16:55:41.002724+00	45	42
4857	42	82	2	1	25	2026-06-28 18:19:33.349529+00	2026-06-29 16:55:52.195668+00	25	34
4856	42	81	2	0	13	2026-06-28 18:19:31.746371+00	2026-06-29 16:55:46.76772+00	13	8
4859	42	84	3	0	29	2026-06-28 18:19:34.900714+00	2026-06-29 16:56:00.760389+00	29	39
4861	42	86	3	0	37	2026-06-28 18:19:36.588248+00	2026-06-29 16:56:09.589632+00	37	30
4860	42	85	2	1	6	2026-06-28 18:19:35.571883+00	2026-06-29 16:56:05.150943+00	6	38
4862	42	87	2	0	44	2026-06-28 18:19:37.250996+00	2026-06-29 16:56:13.187139+00	44	47
4863	42	88	1	2	26	2026-06-28 18:19:37.854354+00	2026-06-29 16:56:16.789278+00	15	26
4850	42	75	2	1	21	2026-06-28 18:19:27.834352+00	2026-06-29 16:55:15.622737+00	21	10
4948	36	83	2	1	41	2026-06-28 18:41:20.633247+00	2026-06-29 15:12:15.609297+00	41	46
4949	36	84	3	1	29	2026-06-28 18:41:21.413133+00	2026-06-29 15:12:16.645759+00	29	39
4950	36	85	2	1	6	2026-06-28 18:41:22.040658+00	2026-06-29 15:12:17.263727+00	6	38
4951	36	86	3	1	37	2026-06-28 18:41:22.671038+00	2026-06-29 15:12:17.818069+00	37	30
4952	36	87	3	0	44	2026-06-28 18:41:23.250866+00	2026-06-29 15:12:18.431358+00	44	47
4953	36	88	0	2	26	2026-06-28 18:41:24.543212+00	2026-06-29 15:12:19.048746+00	15	26
4946	36	81	2	1	13	2026-06-28 18:41:18.348569+00	2026-06-29 15:12:14.380627+00	13	8
4947	36	82	2	2	25	2026-06-28 18:41:19.839272+00	2026-06-29 15:12:14.962891+00	25	34
4954	26	100	1	2	44	2026-06-28 18:41:27.039289+00	2026-06-28 18:41:27.039289+00	30	44
4955	30	103	1	2	37	2026-06-28 18:41:35.448411+00	2026-06-28 18:41:45.352364+00	41	37
4957	26	101	1	2	29	2026-06-28 18:41:51.077086+00	2026-06-28 18:41:54.154957+00	17	29
4959	26	102	1	1	9	2026-06-28 18:42:03.552909+00	2026-06-28 18:42:03.552909+00	9	44
4960	30	104	1	0	33	2026-06-28 18:42:04.335427+00	2026-06-28 18:42:04.335427+00	33	35
4961	26	103	1	2	44	2026-06-28 18:42:23.808858+00	2026-06-28 18:42:23.808858+00	17	44
4962	26	104	1	1	29	2026-06-28 18:42:36.76562+00	2026-06-28 18:42:36.76562+00	29	9
4964	66	73	1	2	5	2026-06-28 18:56:58.186314+00	2026-06-28 18:56:58.186314+00	2	5
4697	51	73	0	0	5	2026-06-28 17:30:32.580532+00	2026-06-28 20:39:41.314882+00	2	5
4973	58	74	2	1	17	2026-06-28 19:08:38.005987+00	2026-06-28 19:08:38.005987+00	17	14
4979	58	75	0	0	21	2026-06-28 19:09:55.532403+00	2026-06-28 19:09:55.532403+00	21	10
4980	58	76	2	0	9	2026-06-28 19:10:05.782955+00	2026-06-28 19:10:05.782955+00	9	22
4981	58	77	3	1	33	2026-06-28 19:10:16.830371+00	2026-06-28 19:10:16.830371+00	33	23
4987	51	87	2	1	44	2026-06-28 19:11:23.329726+00	2026-06-28 21:25:40.560771+00	44	47
4989	58	78	2	1	19	2026-06-28 19:11:54.298077+00	2026-06-28 19:12:11.881571+00	19	35
4992	58	80	1	1	45	2026-06-28 19:13:11.73272+00	2026-06-28 19:13:11.73272+00	45	42
4963	23	73	0	1	5	2026-06-28 18:56:44.849302+00	2026-06-28 20:52:50.647904+00	2	5
4993	58	81	2	1	13	2026-06-28 19:13:33.840786+00	2026-06-28 19:13:52.946754+00	13	8
4997	58	82	1	0	25	2026-06-28 19:14:14.84353+00	2026-06-28 19:14:14.84353+00	25	34
4991	58	79	1	0	1	2026-06-28 19:12:33.553856+00	2026-06-28 19:15:18.908722+00	1	20
5015	41	75	1	0	21	2026-06-28 19:24:08.118625+00	2026-06-28 19:24:08.118625+00	21	10
5019	51	103	2	2	29	2026-06-28 19:28:06.664881+00	2026-06-29 01:49:15.672089+00	29	9
5020	58	83	3	2	41	2026-06-28 19:32:20.288257+00	2026-06-28 19:32:20.288257+00	41	46
5021	58	84	2	0	29	2026-06-28 19:32:30.950905+00	2026-06-28 19:32:30.950905+00	29	39
5022	58	85	1	1	6	2026-06-28 19:32:46.654782+00	2026-06-28 19:32:46.654782+00	6	38
5026	58	86	3	1	37	2026-06-28 19:33:39.228745+00	2026-06-28 19:33:39.228745+00	37	30
5027	58	87	2	0	44	2026-06-28 19:33:50.586856+00	2026-06-28 19:33:50.586856+00	44	47
5028	41	76	0	0	9	2026-06-28 19:33:59.041146+00	2026-06-28 19:33:59.041146+00	9	22
5029	58	88	0	0	26	2026-06-28 19:34:12.767313+00	2026-06-28 19:34:12.767313+00	15	26
5030	58	89	1	3	33	2026-06-28 19:34:50.092557+00	2026-06-28 19:34:50.092557+00	17	33
5032	58	90	2	1	5	2026-06-28 19:35:12.764828+00	2026-06-28 19:35:12.764828+00	5	21
5033	58	91	3	1	9	2026-06-28 19:35:26.961734+00	2026-06-28 19:35:26.961734+00	9	19
5034	56	91	1	1	9	2026-06-28 19:35:35.212817+00	2026-06-28 19:35:37.493631+00	9	35
5036	56	92	1	3	45	2026-06-28 19:35:46.894312+00	2026-06-28 19:35:46.894312+00	1	45
5037	58	92	1	2	45	2026-06-28 19:35:51.672921+00	2026-06-28 19:35:51.672921+00	1	45
5038	56	93	0	0	41	2026-06-28 19:36:00.643721+00	2026-06-28 19:36:00.643721+00	41	29
5040	58	93	3	2	41	2026-06-28 19:36:18.497779+00	2026-06-28 19:36:18.497779+00	41	29
5039	56	94	2	1	13	2026-06-28 19:36:08.076062+00	2026-06-28 19:36:26.729843+00	13	25
5043	58	94	1	1	25	2026-06-28 19:36:39.649013+00	2026-06-28 19:36:39.649013+00	13	25
5044	58	95	3	1	37	2026-06-28 19:36:51.387792+00	2026-06-28 19:36:51.387792+00	37	26
5046	56	97	3	1	33	2026-06-28 19:37:13.466564+00	2026-06-28 19:37:13.466564+00	33	21
5047	56	98	2	1	41	2026-06-28 19:37:20.435184+00	2026-06-28 19:37:20.435184+00	41	13
5048	58	96	1	2	44	2026-06-28 19:37:20.946112+00	2026-06-28 19:37:20.946112+00	6	44
5049	56	99	0	0	9	2026-06-28 19:37:26.730199+00	2026-06-28 19:37:26.730199+00	9	45
5051	56	100	0	0	37	2026-06-28 19:37:34.495694+00	2026-06-28 19:37:34.495694+00	37	44
5052	58	97	2	1	33	2026-06-28 19:37:41.742504+00	2026-06-28 19:37:41.742504+00	33	5
5053	56	101	2	1	33	2026-06-28 19:37:43.990246+00	2026-06-28 19:37:43.990246+00	33	41
5054	58	98	3	0	41	2026-06-28 19:37:50.545692+00	2026-06-28 19:37:50.545692+00	41	25
5055	56	102	1	2	37	2026-06-28 19:37:51.464388+00	2026-06-28 19:37:54.973334+00	9	37
5057	56	103	1	1	41	2026-06-28 19:38:02.172996+00	2026-06-28 19:38:02.172996+00	41	9
4967	51	74	2	1	17	2026-06-28 19:02:38.779989+00	2026-06-28 21:25:32.016882+00	17	14
5042	56	95	3	1	37	2026-06-28 19:36:37.343342+00	2026-06-29 18:09:31.550431+00	37	26
4970	51	77	3	1	33	2026-06-28 19:05:09.185588+00	2026-06-28 21:25:33.827983+00	33	23
4971	51	78	1	2	35	2026-06-28 19:06:40.481762+00	2026-06-28 21:25:34.524976+00	19	35
4975	51	80	3	1	45	2026-06-28 19:09:19.563505+00	2026-06-28 21:25:36.438079+00	45	42
4976	51	81	2	0	13	2026-06-28 19:09:26.694388+00	2026-06-28 21:25:37.038198+00	13	8
4977	51	82	2	1	25	2026-06-28 19:09:34.976564+00	2026-06-28 21:25:37.574738+00	25	34
4982	51	83	1	2	46	2026-06-28 19:10:32.07773+00	2026-06-28 21:25:38.183941+00	41	46
4983	51	84	2	0	29	2026-06-28 19:10:46.901732+00	2026-06-28 21:25:38.73672+00	29	39
4984	51	85	2	0	6	2026-06-28 19:10:59.559196+00	2026-06-28 21:25:39.265943+00	6	38
4986	51	86	3	1	37	2026-06-28 19:11:13.436981+00	2026-06-28 21:25:39.838724+00	37	30
4994	51	88	1	1	26	2026-06-28 19:13:39.630011+00	2026-06-28 21:25:41.121937+00	15	26
4998	51	89	1	2	33	2026-06-28 19:14:50.401103+00	2026-06-29 01:48:00.979962+00	17	33
4968	51	75	1	1	21	2026-06-28 19:04:35.29032+00	2026-06-28 21:25:32.613935+00	21	10
4999	51	90	0	2	21	2026-06-28 19:15:06.617231+00	2026-06-29 01:48:02.14445+00	5	21
5001	51	91	2	1	9	2026-06-28 19:15:21.80204+00	2026-06-29 01:48:03.104653+00	9	35
5002	51	92	1	3	45	2026-06-28 19:15:59.763725+00	2026-06-29 01:48:04.237392+00	20	45
5003	51	93	1	2	29	2026-06-28 19:16:06.342576+00	2026-06-29 01:48:05.03299+00	46	29
5004	51	94	1	2	25	2026-06-28 19:16:33.28044+00	2026-06-29 01:48:06.039276+00	13	25
5005	51	95	2	0	37	2026-06-28 19:16:40.635981+00	2026-06-29 01:48:06.760532+00	37	26
5006	51	96	0	1	44	2026-06-28 19:16:51.194169+00	2026-06-29 01:48:07.295149+00	6	44
5008	51	98	2	2	29	2026-06-28 19:17:48.190931+00	2026-06-29 01:48:32.964657+00	29	25
5007	51	97	2	0	33	2026-06-28 19:17:01.769147+00	2026-06-29 01:48:33.54983+00	33	21
5013	51	100	1	1	37	2026-06-28 19:21:37.341568+00	2026-06-29 01:48:34.740245+00	37	44
5012	51	99	1	1	9	2026-06-28 19:19:34.450375+00	2026-06-29 01:48:35.879827+00	9	45
5014	51	101	2	1	33	2026-06-28 19:22:21.935722+00	2026-06-29 01:49:07.833936+00	33	29
5016	51	102	1	1	37	2026-06-28 19:27:26.944425+00	2026-06-29 01:49:08.407966+00	9	37
5045	56	96	0	1	44	2026-06-28 19:37:00.661584+00	2026-06-29 18:09:31.555109+00	6	44
5018	51	104	2	1	33	2026-06-28 19:27:44.478518+00	2026-06-29 01:49:29.265546+00	33	37
5058	58	99	2	2	9	2026-06-28 19:38:11.98372+00	2026-06-28 19:38:11.98372+00	9	45
5060	58	100	2	1	37	2026-06-28 19:38:30.057417+00	2026-06-28 19:38:40.598502+00	37	44
5063	58	101	0	2	41	2026-06-28 19:38:53.387228+00	2026-06-28 19:38:53.387228+00	33	41
5065	58	102	1	2	37	2026-06-28 19:39:09.683599+00	2026-06-28 19:39:26.847576+00	9	37
5059	56	104	1	1	37	2026-06-28 19:38:15.207083+00	2026-06-28 19:40:01.43474+00	33	37
5068	58	103	2	1	33	2026-06-28 19:40:14.989721+00	2026-06-28 19:40:14.989721+00	33	9
5069	58	104	2	1	41	2026-06-28 19:40:26.742723+00	2026-06-28 19:40:33.559942+00	41	37
5075	41	77	3	1	33	2026-06-28 19:45:37.332906+00	2026-06-28 19:45:37.332906+00	33	23
5096	41	78	0	2	35	2026-06-28 19:46:36.834161+00	2026-06-28 19:46:36.834161+00	19	35
5099	41	79	2	1	1	2026-06-28 19:47:09.330454+00	2026-06-28 19:47:09.330454+00	1	20
5100	41	80	2	0	45	2026-06-28 19:47:34.056491+00	2026-06-28 19:47:34.056491+00	45	42
5101	41	81	2	0	13	2026-06-28 19:48:13.946139+00	2026-06-28 19:48:13.946139+00	13	8
5103	41	82	1	0	25	2026-06-28 19:48:38.854257+00	2026-06-28 19:48:38.854257+00	25	34
5104	41	83	1	1	41	2026-06-28 19:48:52.587899+00	2026-06-28 19:48:52.587899+00	41	46
5106	41	84	1	0	29	2026-06-28 19:49:01.371553+00	2026-06-28 19:49:01.371553+00	29	39
5107	41	85	2	0	6	2026-06-28 19:49:22.573303+00	2026-06-28 19:49:22.573303+00	6	38
5108	41	86	3	0	37	2026-06-28 19:49:34.959731+00	2026-06-28 19:49:34.959731+00	37	30
5109	41	87	1	0	44	2026-06-28 19:49:42.586821+00	2026-06-28 19:49:42.586821+00	44	47
5110	41	88	0	1	26	2026-06-28 19:49:56.778721+00	2026-06-28 19:49:56.778721+00	15	26
5111	41	89	0	1	33	2026-06-28 19:50:12.274215+00	2026-06-28 19:50:12.274215+00	17	33
5112	41	90	0	0	21	2026-06-28 19:50:26.773897+00	2026-06-28 19:50:26.773897+00	5	21
5114	41	91	1	1	35	2026-06-28 19:50:50.180338+00	2026-06-28 19:50:50.180338+00	9	35
5115	41	92	0	2	45	2026-06-28 19:51:00.166339+00	2026-06-28 19:51:00.166339+00	1	45
5116	41	93	2	2	41	2026-06-28 19:51:19.157984+00	2026-06-28 19:51:19.157984+00	41	29
5117	41	95	2	1	37	2026-06-28 19:51:31.548977+00	2026-06-28 19:51:31.548977+00	37	26
5118	41	96	0	1	44	2026-06-28 19:51:49.692732+00	2026-06-28 19:51:49.692732+00	6	44
5120	41	94	0	0	25	2026-06-28 19:52:09.878389+00	2026-06-28 19:52:09.878389+00	13	25
5229	50	74	3	1	17	2026-06-28 21:44:20.160937+00	2026-06-28 23:26:47.243862+00	17	14
5137	41	97	2	0	33	2026-06-28 19:52:29.128516+00	2026-06-28 19:52:29.128516+00	33	21
5138	41	98	1	0	41	2026-06-28 19:52:35.25511+00	2026-06-28 19:52:35.25511+00	41	25
5139	41	99	1	1	45	2026-06-28 19:52:48.568501+00	2026-06-28 19:52:48.568501+00	35	45
5140	41	100	2	1	37	2026-06-28 19:52:57.756989+00	2026-06-28 19:52:57.756989+00	37	44
5141	41	101	2	2	33	2026-06-28 19:53:23.941905+00	2026-06-28 19:53:23.941905+00	33	41
5142	41	102	1	1	45	2026-06-28 19:53:46.716976+00	2026-06-28 19:53:46.716976+00	45	37
5143	41	103	2	2	41	2026-06-28 19:54:22.274609+00	2026-06-28 19:54:22.274609+00	41	37
5144	41	104	2	2	33	2026-06-28 19:55:12.248372+00	2026-06-28 19:55:30.06989+00	33	45
5147	32	73	0	1	5	2026-06-28 20:30:05.932997+00	2026-06-28 20:35:46.489581+00	2	5
5185	33	73	0	1	5	2026-06-28 20:55:55.776732+00	2026-06-28 20:57:53.387722+00	2	5
4105	37	74	2	0	17	2026-06-28 15:25:52.357809+00	2026-06-28 21:02:11.062086+00	17	14
4746	37	96	0	1	44	2026-06-28 17:50:13.266939+00	2026-06-28 21:10:12.965554+00	6	44
4974	51	79	1	1	20	2026-06-28 19:09:06.932592+00	2026-06-28 21:25:35.156933+00	1	20
5235	50	81	3	1	13	2026-06-28 21:46:26.674507+00	2026-06-28 23:27:49.133253+00	13	8
5230	50	75	2	1	21	2026-06-28 21:44:46.738969+00	2026-06-28 21:48:51.646732+00	21	10
5231	50	77	3	0	33	2026-06-28 21:44:59.080502+00	2026-06-28 21:48:52.900306+00	33	23
5232	50	78	1	3	35	2026-06-28 21:45:37.231261+00	2026-06-28 21:48:53.500722+00	19	35
5233	50	79	2	1	1	2026-06-28 21:45:51.847876+00	2026-06-28 21:48:54.097724+00	1	20
5234	50	80	2	0	45	2026-06-28 21:46:09.838602+00	2026-06-28 21:48:54.66873+00	45	42
5241	50	87	2	1	44	2026-06-28 21:47:42.357164+00	2026-06-28 23:28:49.076841+00	44	47
5242	50	88	2	1	15	2026-06-28 21:48:03.974911+00	2026-06-29 16:07:39.232995+00	15	26
5237	50	83	2	1	41	2026-06-28 21:46:52.660485+00	2026-06-28 21:48:56.948946+00	41	46
5238	50	84	2	0	29	2026-06-28 21:47:14.465232+00	2026-06-28 21:48:57.571514+00	29	39
5239	50	85	2	1	6	2026-06-28 21:47:26.651317+00	2026-06-28 21:48:58.226728+00	6	38
5240	50	86	3	0	37	2026-06-28 21:47:32.879225+00	2026-06-28 21:48:58.832452+00	37	30
5258	50	89	1	2	33	2026-06-28 21:53:32.409383+00	2026-06-28 23:30:49.03488+00	17	33
5228	50	76	3	1	9	2026-06-28 21:42:48.52852+00	2026-06-29 16:51:41.648581+00	9	22
5259	59	74	3	1	17	2026-06-28 21:53:46.543031+00	2026-06-28 21:53:46.543031+00	17	14
5260	59	75	1	2	10	2026-06-28 21:54:08.353952+00	2026-06-28 21:54:08.353952+00	21	10
5262	50	90	1	3	21	2026-06-28 21:54:29.495726+00	2026-06-28 23:30:49.600895+00	5	21
5265	59	76	2	1	9	2026-06-28 21:55:22.183053+00	2026-06-28 21:55:22.183053+00	9	22
5267	59	77	3	0	33	2026-06-28 21:55:40.878434+00	2026-06-28 21:55:40.878434+00	33	23
5263	50	91	2	1	9	2026-06-28 21:54:44.667639+00	2026-06-28 23:30:50.291428+00	9	35
5264	50	92	1	2	45	2026-06-28 21:55:10.332594+00	2026-06-28 23:30:50.872498+00	1	45
5266	50	93	2	2	29	2026-06-28 21:55:26.596973+00	2026-06-28 23:30:51.592794+00	41	29
5172	23	76	2	1	9	2026-06-28 20:52:52.596803+00	2026-06-29 03:48:16.134621+00	9	22
5173	23	77	3	1	33	2026-06-28 20:52:53.183092+00	2026-06-29 03:48:16.966281+00	33	23
5174	23	78	1	1	35	2026-06-28 20:52:53.892432+00	2026-06-29 03:48:17.589631+00	19	35
5175	23	79	1	2	20	2026-06-28 20:52:54.576939+00	2026-06-29 03:48:18.215031+00	1	20
5176	23	80	2	0	45	2026-06-28 20:52:55.323002+00	2026-06-29 03:48:18.832494+00	45	42
5177	23	81	2	0	13	2026-06-28 20:52:56.234767+00	2026-06-29 03:48:19.431524+00	13	8
5178	23	82	2	1	25	2026-06-28 20:52:56.953776+00	2026-06-29 03:48:20.075435+00	25	34
5179	23	83	2	1	41	2026-06-28 20:52:57.584218+00	2026-06-29 03:48:20.698192+00	41	46
5180	23	84	3	0	29	2026-06-28 20:52:58.21791+00	2026-06-29 03:48:21.434279+00	29	39
5181	23	85	2	0	6	2026-06-28 20:52:58.856493+00	2026-06-29 03:48:21.996801+00	6	38
5184	23	88	0	1	26	2026-06-28 20:53:01.062783+00	2026-06-29 03:48:23.938335+00	15	26
5236	50	82	1	2	34	2026-06-28 21:46:38.262724+00	2026-06-29 15:50:27.15718+00	25	34
5183	23	87	2	0	44	2026-06-28 20:53:00.308068+00	2026-06-29 03:48:23.248717+00	44	47
5182	23	86	2	0	37	2026-06-28 20:52:59.553044+00	2026-06-29 03:48:22.64791+00	37	30
5170	23	74	2	1	17	2026-06-28 20:52:51.302769+00	2026-06-29 03:48:14.658315+00	17	14
5268	59	78	1	0	19	2026-06-28 21:55:56.763269+00	2026-06-28 21:55:56.763269+00	19	35
5269	59	79	1	2	20	2026-06-28 21:56:18.973979+00	2026-06-28 21:56:18.973979+00	1	20
5271	59	80	1	1	45	2026-06-28 21:57:15.778968+00	2026-06-28 21:57:15.778968+00	45	42
5273	59	81	2	1	13	2026-06-28 21:57:29.453201+00	2026-06-28 21:57:29.453201+00	13	8
5275	33	74	2	0	17	2026-06-28 21:58:01.832709+00	2026-06-28 21:58:01.832709+00	17	14
5276	59	82	0	1	34	2026-06-28 21:58:06.061768+00	2026-06-28 21:58:06.061768+00	25	34
5277	59	83	1	0	41	2026-06-28 21:58:14.407304+00	2026-06-28 21:58:14.407304+00	41	46
5278	59	84	2	1	29	2026-06-28 21:58:21.265654+00	2026-06-28 21:58:26.536309+00	29	39
5280	59	85	2	1	6	2026-06-28 21:58:47.05182+00	2026-06-28 21:58:47.05182+00	6	38
5281	46	74	3	1	17	2026-06-28 21:58:55.750748+00	2026-06-28 21:58:55.750748+00	17	14
5282	59	86	2	1	37	2026-06-28 21:59:03.032456+00	2026-06-28 21:59:03.032456+00	37	30
5283	59	87	2	1	44	2026-06-28 21:59:18.991912+00	2026-06-28 21:59:18.991912+00	44	47
5284	46	75	3	2	21	2026-06-28 21:59:35.36096+00	2026-06-28 21:59:35.36096+00	21	10
5285	59	88	2	0	15	2026-06-28 21:59:37.376096+00	2026-06-28 21:59:37.376096+00	15	26
5287	46	76	2	0	9	2026-06-28 21:59:58.160529+00	2026-06-28 21:59:58.160529+00	9	22
5289	59	89	0	2	33	2026-06-28 22:00:20.149248+00	2026-06-28 22:00:20.149248+00	17	33
5290	46	77	3	1	33	2026-06-28 22:00:23.888992+00	2026-06-28 22:00:23.888992+00	33	23
5291	33	75	0	0	21	2026-06-28 22:00:27.15933+00	2026-06-28 22:00:27.15933+00	21	10
5292	59	90	1	2	10	2026-06-28 22:00:31.623991+00	2026-06-28 22:00:31.623991+00	5	10
5293	59	91	2	1	9	2026-06-28 22:00:40.768089+00	2026-06-28 22:00:40.768089+00	9	19
5294	46	78	2	3	35	2026-06-28 22:00:49.535125+00	2026-06-28 22:00:49.535125+00	19	35
5295	33	76	2	0	9	2026-06-28 22:00:51.818279+00	2026-06-28 22:00:51.818279+00	9	22
5296	59	92	0	1	45	2026-06-28 22:01:07.89408+00	2026-06-28 22:01:07.89408+00	20	45
5297	46	79	2	1	1	2026-06-28 22:01:14.764474+00	2026-06-28 22:01:14.764474+00	1	20
5298	59	93	1	0	41	2026-06-28 22:01:21.576555+00	2026-06-28 22:01:21.576555+00	41	29
5300	59	94	3	1	13	2026-06-28 22:01:29.687812+00	2026-06-28 22:01:29.687812+00	13	34
5301	46	80	2	0	45	2026-06-28 22:01:36.775339+00	2026-06-28 22:01:36.775339+00	45	42
5302	59	95	2	0	37	2026-06-28 22:01:37.690574+00	2026-06-28 22:01:37.690574+00	37	15
5304	33	77	2	0	33	2026-06-28 22:01:44.551745+00	2026-06-28 22:01:44.551745+00	33	23
5305	46	81	3	1	13	2026-06-28 22:01:47.535736+00	2026-06-28 22:01:47.535736+00	13	8
5306	59	96	0	2	44	2026-06-28 22:01:47.846793+00	2026-06-28 22:01:47.846793+00	6	44
5307	59	97	3	1	33	2026-06-28 22:02:03.159034+00	2026-06-28 22:02:03.159034+00	33	10
5308	59	98	1	2	13	2026-06-28 22:02:12.857819+00	2026-06-28 22:02:12.857819+00	41	13
5309	33	78	1	3	35	2026-06-28 22:02:21.395019+00	2026-06-28 22:02:21.395019+00	19	35
5310	59	99	2	1	9	2026-06-28 22:02:23.570506+00	2026-06-28 22:02:23.570506+00	9	45
5311	33	79	2	1	1	2026-06-28 22:02:30.086899+00	2026-06-28 22:02:30.086899+00	1	20
5312	46	82	2	1	25	2026-06-28 22:02:37.192268+00	2026-06-28 22:02:37.192268+00	25	34
5313	59	100	0	1	44	2026-06-28 22:02:46.385578+00	2026-06-28 22:02:46.385578+00	37	44
5314	33	80	2	1	45	2026-06-28 22:02:49.451735+00	2026-06-28 22:02:49.451735+00	45	42
5315	33	81	3	1	13	2026-06-28 22:02:59.463908+00	2026-06-28 22:02:59.463908+00	13	8
5316	33	82	2	1	25	2026-06-28 22:03:12.641728+00	2026-06-28 22:03:12.641728+00	25	34
5317	46	84	2	0	29	2026-06-28 22:03:33.551141+00	2026-06-28 22:03:33.551141+00	29	39
5318	59	101	3	2	33	2026-06-28 22:03:36.928585+00	2026-06-28 22:03:36.928585+00	33	13
5319	46	83	2	1	41	2026-06-28 22:03:40.657306+00	2026-06-28 22:03:40.657306+00	41	46
5320	33	83	0	0	41	2026-06-28 22:03:41.756963+00	2026-06-28 22:03:41.756963+00	41	46
5321	59	102	0	2	44	2026-06-28 22:04:00.082459+00	2026-06-28 22:04:00.082459+00	9	44
5322	46	85	2	0	6	2026-06-28 22:04:04.033805+00	2026-06-28 22:04:04.033805+00	6	38
5323	33	84	3	1	29	2026-06-28 22:04:04.560112+00	2026-06-28 22:04:04.560112+00	29	39
5324	59	103	0	2	9	2026-06-28 22:04:18.201951+00	2026-06-28 22:04:18.201951+00	13	9
5325	59	104	0	1	44	2026-06-28 22:04:51.372018+00	2026-06-28 22:04:51.372018+00	33	44
5328	46	86	3	0	37	2026-06-28 22:06:12.655581+00	2026-06-28 22:06:12.655581+00	37	30
5329	33	85	2	1	6	2026-06-28 22:06:14.676426+00	2026-06-28 22:06:14.676426+00	6	38
5330	33	86	3	1	37	2026-06-28 22:06:21.996041+00	2026-06-28 22:06:21.996041+00	37	30
5331	46	87	1	0	44	2026-06-28 22:06:34.380564+00	2026-06-28 22:06:34.380564+00	44	47
5332	33	87	2	0	44	2026-06-28 22:06:59.27646+00	2026-06-28 22:06:59.27646+00	44	47
5334	33	88	0	0	26	2026-06-28 22:07:46.925033+00	2026-06-28 22:07:46.925033+00	15	26
5335	46	88	1	2	26	2026-06-28 22:07:55.821493+00	2026-06-28 22:07:55.821493+00	15	26
5336	46	89	2	3	33	2026-06-28 22:08:10.361034+00	2026-06-28 22:08:10.361034+00	17	33
5337	33	89	0	0	33	2026-06-28 22:08:18.852798+00	2026-06-28 22:08:18.852798+00	17	33
5338	33	90	0	0	21	2026-06-28 22:08:29.295837+00	2026-06-28 22:08:29.295837+00	5	21
5339	46	90	1	2	21	2026-06-28 22:08:32.053208+00	2026-06-28 22:08:32.053208+00	5	21
5340	33	91	3	1	9	2026-06-28 22:08:42.773853+00	2026-06-28 22:08:42.773853+00	9	35
5342	33	92	2	2	1	2026-06-28 22:10:12.135764+00	2026-06-28 22:10:12.135764+00	1	45
5343	33	93	1	2	29	2026-06-28 22:10:23.535724+00	2026-06-28 22:10:23.535724+00	41	29
5344	46	92	1	2	45	2026-06-28 22:10:28.573308+00	2026-06-28 22:10:28.573308+00	1	45
5345	33	94	2	2	13	2026-06-28 22:10:46.445633+00	2026-06-28 22:10:46.445633+00	13	25
5346	46	91	2	1	9	2026-06-28 22:10:46.653673+00	2026-06-28 22:10:46.653673+00	9	35
5347	33	95	2	1	37	2026-06-28 22:10:58.280912+00	2026-06-28 22:10:58.280912+00	37	26
5348	33	96	1	2	44	2026-06-28 22:11:08.729061+00	2026-06-28 22:11:08.729061+00	6	44
5349	33	98	2	1	29	2026-06-28 22:11:22.152862+00	2026-06-28 22:11:22.152862+00	29	13
5350	33	97	3	1	33	2026-06-28 22:11:32.846426+00	2026-06-28 22:11:32.846426+00	33	21
5351	33	99	2	1	9	2026-06-28 22:11:44.474814+00	2026-06-28 22:11:44.474814+00	9	1
5327	50	102	2	3	37	2026-06-28 22:05:02.028733+00	2026-06-28 23:30:22.074718+00	45	37
5286	50	98	3	1	29	2026-06-28 21:59:50.105366+00	2026-06-28 23:30:33.553125+00	29	13
5288	50	97	2	1	33	2026-06-28 22:00:08.569381+00	2026-06-28 23:30:34.141916+00	33	21
5299	50	99	1	2	45	2026-06-28 22:01:26.6522+00	2026-06-28 23:30:34.808198+00	9	45
5303	50	100	2	1	37	2026-06-28 22:01:40.644603+00	2026-06-28 23:30:35.467393+00	37	44
5270	50	94	3	1	13	2026-06-28 21:57:07.050088+00	2026-06-29 15:51:47.23772+00	13	34
5274	50	96	1	2	44	2026-06-28 21:57:42.668724+00	2026-06-28 23:30:53.60372+00	6	44
5272	50	95	3	1	37	2026-06-28 21:57:28.736375+00	2026-06-29 16:07:56.888821+00	37	15
5353	33	100	2	2	37	2026-06-28 22:12:13.403779+00	2026-06-28 22:12:13.403779+00	37	44
5354	46	95	2	0	37	2026-06-28 22:12:17.49709+00	2026-06-28 22:12:17.49709+00	37	26
5355	33	101	2	2	33	2026-06-28 22:12:26.787944+00	2026-06-28 22:12:26.787944+00	33	29
5356	46	96	0	2	44	2026-06-28 22:12:31.740297+00	2026-06-28 22:12:31.740297+00	6	44
5357	33	102	1	1	37	2026-06-28 22:12:50.668254+00	2026-06-28 22:12:50.668254+00	9	37
5363	36	92	2	1	1	2026-06-28 22:13:39.84205+00	2026-06-28 22:13:39.84205+00	1	45
5364	33	104	2	2	33	2026-06-28 22:13:43.485946+00	2026-06-28 22:13:43.485946+00	33	37
5366	36	94	1	0	13	2026-06-28 22:13:55.135641+00	2026-06-28 22:13:55.135641+00	13	25
5367	46	97	2	1	33	2026-06-28 22:14:00.171827+00	2026-06-28 22:14:00.171827+00	33	21
5369	36	96	0	1	44	2026-06-28 22:14:09.678308+00	2026-06-28 22:14:14.072931+00	6	44
5371	46	93	2	1	41	2026-06-28 22:14:27.230728+00	2026-06-28 22:14:27.230728+00	41	29
5387	46	94	3	0	13	2026-06-28 22:15:06.755154+00	2026-06-28 22:15:06.755154+00	13	25
5388	46	98	2	1	41	2026-06-28 22:15:36.256449+00	2026-06-28 22:15:36.256449+00	41	13
5389	46	99	1	2	45	2026-06-28 22:16:15.149161+00	2026-06-28 22:16:15.149161+00	9	45
5390	46	100	1	0	37	2026-06-28 22:16:23.296915+00	2026-06-28 22:16:23.296915+00	37	44
5391	36	93	1	0	41	2026-06-28 22:16:23.99097+00	2026-06-28 22:16:23.99097+00	41	29
5392	36	98	1	0	41	2026-06-28 22:16:40.064726+00	2026-06-28 22:16:40.064726+00	41	13
5394	36	99	1	0	9	2026-06-28 22:17:03.21626+00	2026-06-28 22:17:03.21626+00	9	1
5395	46	102	2	0	45	2026-06-28 22:17:09.750447+00	2026-06-28 22:17:09.750447+00	45	37
5396	46	101	2	1	33	2026-06-28 22:17:18.782756+00	2026-06-28 22:17:18.782756+00	33	41
5397	46	103	2	1	41	2026-06-28 22:17:30.333863+00	2026-06-28 22:17:30.333863+00	41	37
5398	11	77	4	1	33	2026-06-28 22:17:44.237259+00	2026-06-28 22:17:48.366326+00	33	23
5361	33	103	1	2	9	2026-06-28 22:13:13.763394+00	2026-06-28 22:19:07.441909+00	29	9
5401	11	89	2	3	33	2026-06-28 22:19:08.935601+00	2026-06-28 22:19:08.935601+00	17	33
5402	46	104	2	0	33	2026-06-28 22:19:19.04673+00	2026-06-28 22:19:19.04673+00	33	45
5403	11	90	1	3	21	2026-06-28 22:19:19.974248+00	2026-06-28 22:19:19.974248+00	5	21
5404	11	91	2	1	9	2026-06-28 22:19:31.847727+00	2026-06-28 22:19:31.847727+00	9	35
5405	11	92	1	3	45	2026-06-28 22:19:52.399406+00	2026-06-28 22:19:52.399406+00	1	45
5424	32	74	3	1	17	2026-06-28 23:27:23.072569+00	2026-06-28 23:27:23.072569+00	17	14
5426	32	75	1	2	10	2026-06-28 23:27:50.663351+00	2026-06-28 23:27:50.663351+00	21	10
5427	32	76	3	2	9	2026-06-28 23:28:14.391488+00	2026-06-28 23:28:14.391488+00	9	22
5429	32	77	4	1	33	2026-06-28 23:29:06.477025+00	2026-06-28 23:29:06.477025+00	33	23
5432	32	78	2	2	35	2026-06-28 23:29:48.964341+00	2026-06-28 23:29:48.964341+00	19	35
5431	50	104	3	2	29	2026-06-28 23:29:35.080725+00	2026-06-28 23:29:49.355429+00	29	37
5434	32	79	0	1	20	2026-06-28 23:30:10.052192+00	2026-06-28 23:30:10.052192+00	1	20
5430	50	103	2	1	33	2026-06-28 23:29:18.503884+00	2026-06-28 23:30:12.897095+00	33	45
5326	50	101	1	2	29	2026-06-28 22:04:55.279085+00	2026-06-28 23:30:21.495929+00	33	29
5450	32	80	3	1	45	2026-06-28 23:31:00.879093+00	2026-06-28 23:31:00.879093+00	45	42
5451	32	81	2	1	13	2026-06-28 23:31:16.896639+00	2026-06-28 23:31:16.896639+00	13	8
5452	32	82	1	2	34	2026-06-28 23:31:45.240786+00	2026-06-28 23:31:45.240786+00	25	34
5453	32	83	2	1	41	2026-06-28 23:32:16.873227+00	2026-06-28 23:32:16.873227+00	41	46
5454	32	84	3	1	29	2026-06-28 23:32:47.275034+00	2026-06-28 23:33:10.442576+00	29	39
5456	32	85	3	1	6	2026-06-28 23:33:30.787964+00	2026-06-28 23:33:30.787964+00	6	38
5457	32	86	3	1	37	2026-06-28 23:33:52.644324+00	2026-06-28 23:33:52.644324+00	37	30
5458	32	87	2	1	44	2026-06-28 23:34:09.259023+00	2026-06-28 23:34:09.259023+00	44	47
5459	32	88	2	3	26	2026-06-28 23:34:29.150164+00	2026-06-28 23:34:29.150164+00	15	26
5460	32	89	2	2	33	2026-06-28 23:35:14.663719+00	2026-06-28 23:35:14.663719+00	17	33
5461	32	90	2	3	10	2026-06-28 23:36:10.998173+00	2026-06-28 23:36:10.998173+00	5	10
5462	32	91	3	2	9	2026-06-28 23:36:29.781943+00	2026-06-28 23:36:29.781943+00	9	35
5463	32	92	1	3	45	2026-06-28 23:36:51.769111+00	2026-06-28 23:36:51.769111+00	20	45
5464	32	93	1	2	29	2026-06-28 23:37:17.553796+00	2026-06-28 23:37:17.553796+00	41	29
5465	32	94	2	1	13	2026-06-28 23:37:38.744992+00	2026-06-28 23:37:38.744992+00	13	34
5466	32	95	3	2	37	2026-06-28 23:38:03.634306+00	2026-06-28 23:38:03.634306+00	37	26
5467	32	96	1	3	44	2026-06-28 23:38:17.937722+00	2026-06-28 23:38:17.937722+00	6	44
5469	32	98	2	1	29	2026-06-28 23:38:38.984764+00	2026-06-28 23:38:38.984764+00	29	13
5470	32	97	3	2	33	2026-06-28 23:38:53.760239+00	2026-06-28 23:38:53.760239+00	33	10
5471	32	99	3	2	9	2026-06-28 23:39:14.999234+00	2026-06-28 23:39:14.999234+00	9	45
5473	32	100	2	2	37	2026-06-28 23:39:46.426907+00	2026-06-28 23:39:46.426907+00	37	44
5474	32	101	3	2	33	2026-06-28 23:40:08.596421+00	2026-06-28 23:40:08.596421+00	33	29
5477	32	102	3	3	37	2026-06-28 23:40:44.677919+00	2026-06-28 23:40:44.677919+00	9	37
5479	32	103	2	3	9	2026-06-28 23:41:02.208855+00	2026-06-28 23:41:02.208855+00	29	9
5481	32	104	3	2	33	2026-06-28 23:41:22.785596+00	2026-06-28 23:41:22.785596+00	33	37
5484	55	74	2	0	17	2026-06-28 23:45:22.491511+00	2026-06-28 23:45:22.491511+00	17	14
5485	55	75	2	1	21	2026-06-28 23:45:49.744307+00	2026-06-28 23:45:49.744307+00	21	10
5486	55	76	2	1	9	2026-06-28 23:46:12.490722+00	2026-06-28 23:46:16.930992+00	9	22
5488	55	77	3	0	33	2026-06-28 23:46:36.972234+00	2026-06-28 23:46:36.972234+00	33	23
5489	55	78	1	1	35	2026-06-28 23:47:46.333531+00	2026-06-28 23:47:46.333531+00	19	35
5490	55	79	2	1	1	2026-06-28 23:48:19.369908+00	2026-06-28 23:48:19.369908+00	1	20
5492	55	80	2	0	45	2026-06-28 23:49:40.728541+00	2026-06-28 23:49:40.728541+00	45	42
5493	55	81	2	1	13	2026-06-28 23:50:21.089459+00	2026-06-28 23:50:21.089459+00	13	8
5494	55	82	2	1	25	2026-06-28 23:50:36.380522+00	2026-06-28 23:50:36.380522+00	25	34
5495	55	83	2	1	41	2026-06-28 23:50:56.878023+00	2026-06-28 23:50:56.878023+00	41	46
5496	55	84	2	0	29	2026-06-28 23:51:22.990942+00	2026-06-28 23:51:22.990942+00	29	39
5497	55	85	2	1	6	2026-06-28 23:51:46.530958+00	2026-06-28 23:51:46.530958+00	6	38
5498	55	86	2	0	37	2026-06-28 23:52:17.196947+00	2026-06-28 23:52:17.196947+00	37	30
5499	55	87	2	1	44	2026-06-28 23:52:38.061261+00	2026-06-28 23:52:38.061261+00	44	47
5500	55	88	0	1	26	2026-06-28 23:53:03.462228+00	2026-06-28 23:53:03.462228+00	15	26
5393	36	100	1	1	44	2026-06-28 22:16:54.327425+00	2026-06-29 15:12:41.441857+00	37	44
5362	36	91	1	1	9	2026-06-28 22:13:33.195492+00	2026-06-29 18:09:35.461481+00	9	19
5368	36	95	2	0	37	2026-06-28 22:14:02.514091+00	2026-06-29 18:09:35.463369+00	37	26
5681	48	86	3	1	37	2026-06-29 14:10:52.577473+00	2026-06-29 14:10:52.577473+00	37	30
5682	48	87	2	1	44	2026-06-29 14:11:00.476491+00	2026-06-29 14:11:00.476491+00	44	47
5683	48	88	1	2	26	2026-06-29 14:11:08.308652+00	2026-06-29 14:11:08.308652+00	15	26
5532	36	89	1	0	17	2026-06-29 01:40:27.810728+00	2026-06-29 01:40:27.810728+00	17	33
5533	36	90	1	0	5	2026-06-29 01:40:35.203407+00	2026-06-29 01:40:35.203407+00	5	21
5534	36	97	1	1	17	2026-06-29 01:41:16.501475+00	2026-06-29 01:41:16.501475+00	17	5
5684	47	78	1	2	35	2026-06-29 14:11:10.349991+00	2026-06-29 14:11:10.349991+00	19	35
5685	54	93	2	1	41	2026-06-29 14:11:13.032724+00	2026-06-29 14:11:13.032724+00	41	29
5557	14	89	1	2	33	2026-06-29 01:46:29.67704+00	2026-06-29 01:46:32.95665+00	17	33
5559	14	90	0	2	21	2026-06-29 01:46:40.151941+00	2026-06-29 01:46:40.151941+00	5	21
5560	14	91	2	1	9	2026-06-29 01:46:49.76169+00	2026-06-29 01:46:49.76169+00	9	35
5561	14	92	1	1	45	2026-06-29 01:47:00.595456+00	2026-06-29 01:47:00.595456+00	20	45
5562	14	93	2	2	29	2026-06-29 01:47:22.349542+00	2026-06-29 01:47:22.349542+00	41	29
5563	14	94	1	2	25	2026-06-29 01:47:31.679933+00	2026-06-29 01:47:31.679933+00	13	25
5564	14	95	3	1	37	2026-06-29 01:47:38.934804+00	2026-06-29 01:47:38.934804+00	37	26
5565	14	96	1	2	44	2026-06-29 01:47:52.086918+00	2026-06-29 01:47:52.086918+00	6	44
5568	14	98	2	0	29	2026-06-29 01:48:02.240591+00	2026-06-29 01:48:02.240591+00	29	25
5578	14	97	1	1	33	2026-06-29 01:48:34.94086+00	2026-06-29 01:48:34.94086+00	33	21
5580	14	99	1	1	9	2026-06-29 01:48:52.744789+00	2026-06-29 01:48:52.744789+00	9	45
5581	14	100	1	2	44	2026-06-29 01:49:03.447892+00	2026-06-29 01:49:03.447892+00	37	44
5586	14	101	2	1	33	2026-06-29 01:49:26.687731+00	2026-06-29 01:49:26.687731+00	33	29
5588	14	102	1	1	44	2026-06-29 01:49:36.950977+00	2026-06-29 01:49:36.950977+00	9	44
5589	14	103	2	1	29	2026-06-29 01:49:55.697277+00	2026-06-29 01:49:55.697277+00	29	9
5590	14	104	3	2	33	2026-06-29 01:50:07.838818+00	2026-06-29 01:50:07.838818+00	33	44
5598	44	76	2	1	9	2026-06-29 02:39:57.434184+00	2026-06-29 02:39:57.434184+00	9	22
5591	45	74	3	1	17	2026-06-29 02:28:54.873596+00	2026-06-29 14:36:41.060521+00	17	14
5171	23	75	2	2	21	2026-06-28 20:52:51.955791+00	2026-06-29 03:48:15.280943+00	21	10
5643	28	74	3	1	17	2026-06-29 14:01:51.305765+00	2026-06-29 14:01:51.305765+00	17	14
5644	28	75	1	2	10	2026-06-29 14:02:09.232807+00	2026-06-29 14:02:09.232807+00	21	10
5536	36	101	1	0	17	2026-06-29 01:41:45.775716+00	2026-06-29 14:02:55.403267+00	17	41
5537	36	102	1	1	44	2026-06-29 01:41:55.357385+00	2026-06-29 15:13:02.547764+00	9	44
5686	54	94	2	1	13	2026-06-29 14:11:26.735902+00	2026-06-29 14:11:26.735902+00	13	25
4939	36	77	3	2	33	2026-06-28 18:41:10.955979+00	2026-06-29 15:12:11.950265+00	33	23
5607	45	89	1	2	33	2026-06-29 02:58:34.28892+00	2026-06-29 16:14:49.658572+00	17	33
5692	54	95	2	0	37	2026-06-29 14:12:37.497949+00	2026-06-29 18:09:36.697107+00	37	15
5668	47	74	2	1	17	2026-06-29 14:06:48.444752+00	2026-06-29 14:06:48.444752+00	17	14
5669	47	75	2	0	21	2026-06-29 14:09:10.46685+00	2026-06-29 14:09:10.46685+00	21	10
5670	47	76	3	1	9	2026-06-29 14:09:23.362974+00	2026-06-29 14:09:23.362974+00	9	22
5674	54	89	1	2	33	2026-06-29 14:10:12.774803+00	2026-06-29 14:10:12.774803+00	17	33
5675	47	77	3	0	33	2026-06-29 14:10:15.69478+00	2026-06-29 14:10:15.69478+00	33	23
5676	48	84	3	2	29	2026-06-29 14:10:27.565754+00	2026-06-29 14:10:27.565754+00	29	39
5677	54	90	0	1	21	2026-06-29 14:10:34.462264+00	2026-06-29 14:10:34.462264+00	5	21
5678	48	85	2	0	6	2026-06-29 14:10:36.335878+00	2026-06-29 14:10:36.335878+00	6	38
5679	54	91	2	1	9	2026-06-29 14:10:41.1643+00	2026-06-29 14:10:41.1643+00	9	35
5680	54	92	0	2	45	2026-06-29 14:10:49.882123+00	2026-06-29 14:10:49.882123+00	20	45
5687	54	96	1	2	44	2026-06-29 14:11:35.447726+00	2026-06-29 14:11:35.447726+00	6	44
5688	54	98	1	0	41	2026-06-29 14:11:52.237195+00	2026-06-29 14:11:52.237195+00	41	13
5689	54	97	2	0	33	2026-06-29 14:11:58.228785+00	2026-06-29 14:11:58.228785+00	33	21
5690	47	79	1	2	20	2026-06-29 14:12:01.96772+00	2026-06-29 14:12:01.96772+00	1	20
5691	54	99	2	1	9	2026-06-29 14:12:13.10682+00	2026-06-29 14:12:13.10682+00	9	45
5693	47	80	1	0	45	2026-06-29 14:12:43.746336+00	2026-06-29 14:12:43.746336+00	45	42
5695	54	100	0	1	44	2026-06-29 14:13:08.483408+00	2026-06-29 14:13:08.483408+00	37	44
5696	48	89	1	3	33	2026-06-29 14:13:34.131205+00	2026-06-29 14:13:34.131205+00	17	33
5699	47	81	2	1	13	2026-06-29 14:13:44.461639+00	2026-06-29 14:13:44.461639+00	13	8
5698	48	90	2	1	2	2026-06-29 14:13:43.096734+00	2026-06-29 14:13:55.242529+00	2	10
5694	54	101	2	0	33	2026-06-29 14:12:57.028533+00	2026-06-29 14:14:31.888936+00	33	41
5702	54	102	0	1	44	2026-06-29 14:13:56.654061+00	2026-06-29 14:14:32.495384+00	9	44
5592	45	75	2	1	21	2026-06-29 02:29:46.665366+00	2026-06-29 14:36:41.593593+00	21	10
5593	45	76	2	1	9	2026-06-29 02:30:19.983142+00	2026-06-29 14:36:42.154789+00	9	22
5595	45	77	3	0	33	2026-06-29 02:33:50.8948+00	2026-06-29 14:36:42.774971+00	33	23
5594	45	78	1	2	35	2026-06-29 02:32:54.080816+00	2026-06-29 14:36:43.356727+00	19	35
5596	45	79	1	2	20	2026-06-29 02:34:16.98411+00	2026-06-29 14:36:43.98425+00	1	20
5599	45	81	2	1	13	2026-06-29 02:40:06.763634+00	2026-06-29 14:36:46.344341+00	13	8
5601	45	84	2	0	29	2026-06-29 02:51:14.141906+00	2026-06-29 14:36:48.277613+00	29	39
5600	45	82	2	1	25	2026-06-29 02:50:38.10695+00	2026-06-29 14:36:46.944502+00	25	34
5603	45	83	1	1	41	2026-06-29 02:53:18.866569+00	2026-06-29 14:36:47.573913+00	41	46
5602	45	85	1	1	6	2026-06-29 02:51:43.874681+00	2026-06-29 14:36:48.887858+00	6	38
5604	45	86	3	0	37	2026-06-29 02:54:07.502638+00	2026-06-29 14:36:49.532819+00	37	30
5605	45	87	2	1	44	2026-06-29 02:54:32.633728+00	2026-06-29 14:36:50.153775+00	44	47
5656	28	77	3	0	33	2026-06-29 14:03:37.948425+00	2026-06-29 14:41:16.648614+00	33	23
5606	45	88	0	1	26	2026-06-29 02:54:57.088586+00	2026-06-29 14:36:50.779308+00	15	26
5609	45	94	1	0	13	2026-06-29 02:59:33.399936+00	2026-06-29 16:14:52.490925+00	13	25
5610	45	93	1	2	29	2026-06-29 03:00:44.935431+00	2026-06-29 16:14:51.948781+00	41	29
5700	23	89	1	2	33	2026-06-29 14:13:47.928612+00	2026-06-29 16:25:22.447508+00	17	33
5608	45	90	1	3	21	2026-06-29 02:58:47.391499+00	2026-06-29 16:14:50.292362+00	5	21
4936	36	74	3	1	17	2026-06-28 18:41:07.740723+00	2026-06-29 15:12:10.310341+00	17	14
5646	36	104	0	0	44	2026-06-29 14:02:26.98618+00	2026-06-29 15:15:07.792912+00	17	44
5647	28	76	1	2	22	2026-06-29 14:02:44.354723+00	2026-06-29 16:51:11.028742+00	9	22
5645	36	103	1	1	37	2026-06-29 14:02:18.431463+00	2026-06-29 18:09:35.466047+00	41	9
5704	48	91	2	1	9	2026-06-29 14:14:08.860737+00	2026-06-29 14:14:08.860737+00	9	35
5705	54	104	0	1	44	2026-06-29 14:14:12.331475+00	2026-06-29 14:14:17.860874+00	33	44
5707	48	92	1	0	1	2026-06-29 14:14:22.034051+00	2026-06-29 14:14:22.034051+00	1	45
5703	54	103	2	1	41	2026-06-29 14:14:04.951414+00	2026-06-29 14:14:23.272733+00	41	9
5785	45	98	3	1	29	2026-06-29 14:32:44.050939+00	2026-06-29 14:38:00.445494+00	29	13
5711	48	93	3	1	41	2026-06-29 14:14:46.520341+00	2026-06-29 14:15:12.238488+00	41	29
5787	45	99	1	2	45	2026-06-29 14:33:04.590875+00	2026-06-29 14:38:00.969842+00	9	45
5713	47	82	1	1	25	2026-06-29 14:14:58.966715+00	2026-06-29 14:16:56.38654+00	25	34
5717	47	83	2	1	41	2026-06-29 14:19:01.374739+00	2026-06-29 14:19:01.374739+00	41	46
5718	47	84	3	1	29	2026-06-29 14:19:40.941491+00	2026-06-29 14:19:40.941491+00	29	39
5719	47	85	1	0	6	2026-06-29 14:20:12.814006+00	2026-06-29 14:20:12.814006+00	6	38
5720	47	86	2	1	37	2026-06-29 14:20:46.881068+00	2026-06-29 14:20:46.881068+00	37	30
5721	47	87	2	0	44	2026-06-29 14:21:17.510231+00	2026-06-29 14:21:17.510231+00	44	47
5723	44	77	3	1	33	2026-06-29 14:21:51.751515+00	2026-06-29 14:21:51.751515+00	33	23
5724	44	78	1	2	35	2026-06-29 14:22:01.962922+00	2026-06-29 14:22:01.962922+00	19	35
5726	44	79	2	0	1	2026-06-29 14:22:11.589825+00	2026-06-29 14:22:11.589825+00	1	20
5725	47	88	1	1	15	2026-06-29 14:22:04.179879+00	2026-06-29 14:22:13.914347+00	15	26
5728	48	94	3	1	13	2026-06-29 14:22:14.938888+00	2026-06-29 14:22:14.938888+00	13	25
5730	48	95	4	2	37	2026-06-29 14:22:23.032352+00	2026-06-29 14:22:23.032352+00	37	26
5731	44	80	3	0	45	2026-06-29 14:22:33.863076+00	2026-06-29 14:22:33.863076+00	45	42
5732	48	96	2	3	44	2026-06-29 14:22:35.569903+00	2026-06-29 14:22:35.569903+00	6	44
5734	47	89	1	2	33	2026-06-29 14:22:48.474181+00	2026-06-29 14:22:48.474181+00	17	33
5735	44	81	3	1	13	2026-06-29 14:22:53.936574+00	2026-06-29 14:22:53.936574+00	13	8
5736	48	98	3	2	41	2026-06-29 14:22:56.540316+00	2026-06-29 14:23:09.841469+00	41	13
5740	47	90	0	2	21	2026-06-29 14:23:17.878724+00	2026-06-29 14:23:17.878724+00	5	21
5741	48	97	2	1	33	2026-06-29 14:23:33.148913+00	2026-06-29 14:24:03.097332+00	33	2
5744	47	91	2	2	9	2026-06-29 14:24:11.786022+00	2026-06-29 14:24:11.786022+00	9	35
5746	48	100	1	2	44	2026-06-29 14:24:30.346289+00	2026-06-29 14:24:30.346289+00	37	44
5747	48	99	2	2	9	2026-06-29 14:24:41.772036+00	2026-06-29 14:24:41.772036+00	9	1
5749	48	101	2	1	33	2026-06-29 14:24:55.178082+00	2026-06-29 14:24:55.178082+00	33	41
5751	48	102	1	3	44	2026-06-29 14:25:20.747125+00	2026-06-29 14:25:20.747125+00	9	44
5755	48	104	1	2	44	2026-06-29 14:25:43.369923+00	2026-06-29 14:25:51.445721+00	33	44
5758	47	92	1	1	45	2026-06-29 14:26:09.467204+00	2026-06-29 14:26:09.467204+00	20	45
5753	48	103	1	0	41	2026-06-29 14:25:30.565911+00	2026-06-29 14:26:14.544264+00	41	9
5761	47	93	0	1	29	2026-06-29 14:26:29.092589+00	2026-06-29 14:26:29.092589+00	41	29
5762	47	94	1	0	13	2026-06-29 14:27:01.445483+00	2026-06-29 14:27:01.445483+00	13	25
5764	47	95	2	0	37	2026-06-29 14:27:19.12852+00	2026-06-29 14:27:19.12852+00	37	15
5767	47	96	1	1	44	2026-06-29 14:27:50.569838+00	2026-06-29 14:27:50.569838+00	6	44
5770	47	98	2	1	29	2026-06-29 14:28:28.432733+00	2026-06-29 14:28:28.432733+00	29	13
5773	47	97	2	1	33	2026-06-29 14:29:07.889726+00	2026-06-29 14:29:07.889726+00	33	21
5780	47	99	1	0	9	2026-06-29 14:31:19.438013+00	2026-06-29 14:31:19.438013+00	9	45
5782	47	100	2	1	37	2026-06-29 14:32:07.654458+00	2026-06-29 14:32:12.930164+00	37	44
5824	28	78	0	1	35	2026-06-29 14:42:31.259729+00	2026-06-29 14:42:31.259729+00	19	35
5788	47	101	2	2	33	2026-06-29 14:33:07.43428+00	2026-06-29 14:33:07.43428+00	33	29
5789	47	102	1	1	37	2026-06-29 14:33:30.570794+00	2026-06-29 14:33:30.570794+00	9	37
5790	47	103	1	1	9	2026-06-29 14:34:51.686461+00	2026-06-29 14:34:51.686461+00	29	9
5792	47	104	1	1	33	2026-06-29 14:35:55.46646+00	2026-06-29 14:35:55.46646+00	33	37
5842	31	80	2	0	45	2026-06-29 14:53:42.552724+00	2026-06-29 14:53:42.552724+00	45	42
5777	45	92	0	2	45	2026-06-29 14:30:27.485725+00	2026-06-29 16:14:51.436553+00	20	45
5781	45	96	1	2	44	2026-06-29 14:31:39.050889+00	2026-06-29 16:14:53.577606+00	6	44
5818	45	100	1	2	44	2026-06-29 14:37:53.777248+00	2026-06-29 18:09:37.234928+00	37	44
5597	45	80	3	1	45	2026-06-29 02:39:37.672133+00	2026-06-29 14:36:44.579306+00	45	42
5784	45	97	2	1	33	2026-06-29 14:32:31.342734+00	2026-06-29 14:37:59.872925+00	33	21
5828	28	84	2	0	29	2026-06-29 14:43:05.654597+00	2026-06-29 14:43:05.654597+00	29	39
5829	28	82	1	0	25	2026-06-29 14:43:05.728524+00	2026-06-29 14:43:05.728524+00	25	34
5830	28	83	2	0	41	2026-06-29 14:43:06.336183+00	2026-06-29 14:43:06.336183+00	41	46
5831	28	85	1	0	6	2026-06-29 14:43:41.232125+00	2026-06-29 14:43:41.232125+00	6	38
5827	28	81	3	0	13	2026-06-29 14:43:05.448229+00	2026-06-29 14:43:43.649921+00	13	8
5825	28	79	1	0	1	2026-06-29 14:43:03.634977+00	2026-06-29 14:43:43.732932+00	1	20
5826	28	80	2	0	45	2026-06-29 14:43:05.131197+00	2026-06-29 14:43:43.734624+00	45	42
5837	31	78	0	1	35	2026-06-29 14:53:12.16877+00	2026-06-29 14:53:12.16877+00	19	35
5840	31	79	1	2	20	2026-06-29 14:53:34.210471+00	2026-06-29 14:53:34.210471+00	1	20
5844	31	81	2	1	13	2026-06-29 14:53:52.514826+00	2026-06-29 14:53:52.514826+00	13	8
5850	31	82	1	0	25	2026-06-29 14:54:54.546132+00	2026-06-29 14:54:54.546132+00	25	34
5851	31	83	1	0	41	2026-06-29 14:55:02.573992+00	2026-06-29 14:55:02.573992+00	41	46
5852	31	84	2	1	29	2026-06-29 14:55:12.071729+00	2026-06-29 14:55:12.071729+00	29	39
5853	31	85	2	0	6	2026-06-29 14:55:21.01389+00	2026-06-29 14:55:21.01389+00	6	38
5854	31	86	2	0	37	2026-06-29 14:55:32.337295+00	2026-06-29 14:55:32.337295+00	37	30
5836	12	90	0	2	10	2026-06-29 14:53:09.139329+00	2026-06-29 15:56:58.366018+00	5	10
5838	12	91	2	1	9	2026-06-29 14:53:18.27656+00	2026-06-29 15:56:58.984408+00	9	35
5839	12	92	0	0	45	2026-06-29 14:53:26.612739+00	2026-06-29 15:56:59.642147+00	20	45
5841	12	93	1	0	41	2026-06-29 14:53:35.418112+00	2026-06-29 15:57:00.250994+00	41	29
5843	12	94	2	1	13	2026-06-29 14:53:47.048297+00	2026-06-29 15:57:00.863984+00	13	34
5845	12	95	1	0	37	2026-06-29 14:53:55.408731+00	2026-06-29 15:57:01.496321+00	37	26
5846	12	96	0	2	44	2026-06-29 14:54:04.220171+00	2026-06-29 15:57:02.154274+00	6	44
5847	12	98	2	0	41	2026-06-29 14:54:19.293818+00	2026-06-29 15:57:24.062605+00	41	13
5848	12	97	2	0	33	2026-06-29 14:54:26.749986+00	2026-06-29 15:57:24.636034+00	33	10
5849	12	99	2	0	9	2026-06-29 14:54:36.962632+00	2026-06-29 15:57:27.047012+00	9	45
5776	45	91	2	1	9	2026-06-29 14:30:17.067937+00	2026-06-29 16:14:50.85913+00	9	35
5855	31	87	2	1	44	2026-06-29 14:55:40.574385+00	2026-06-29 14:55:40.574385+00	44	47
5856	31	88	2	1	15	2026-06-29 14:55:50.977828+00	2026-06-29 14:55:50.977828+00	15	26
5857	31	89	1	2	33	2026-06-29 14:56:05.656483+00	2026-06-29 14:56:05.656483+00	17	33
5858	31	90	1	2	10	2026-06-29 14:56:23.685492+00	2026-06-29 14:56:23.685492+00	5	10
5859	31	91	2	1	9	2026-06-29 14:57:07.979928+00	2026-06-29 14:57:07.979928+00	9	35
5860	31	92	1	2	45	2026-06-29 14:57:19.144551+00	2026-06-29 14:57:19.144551+00	20	45
5861	31	93	1	2	29	2026-06-29 14:57:28.748901+00	2026-06-29 14:57:28.748901+00	41	29
5862	31	94	1	0	13	2026-06-29 14:57:38.689833+00	2026-06-29 14:57:38.689833+00	13	25
5863	31	95	2	0	37	2026-06-29 14:57:46.778548+00	2026-06-29 14:57:46.778548+00	37	15
5864	31	96	0	1	44	2026-06-29 14:57:53.802486+00	2026-06-29 14:57:53.802486+00	6	44
5865	31	98	2	1	29	2026-06-29 14:58:06.969918+00	2026-06-29 14:58:06.969918+00	29	13
5866	31	97	2	1	33	2026-06-29 14:58:14.304492+00	2026-06-29 14:58:14.304492+00	33	10
5867	31	99	1	2	45	2026-06-29 14:58:24.55217+00	2026-06-29 14:58:24.55217+00	9	45
5868	31	100	2	1	37	2026-06-29 14:58:36.824887+00	2026-06-29 14:58:36.824887+00	37	44
5869	31	101	1	0	33	2026-06-29 14:58:49.106354+00	2026-06-29 14:58:49.106354+00	33	29
5870	31	102	0	1	37	2026-06-29 14:58:56.333443+00	2026-06-29 14:58:56.333443+00	45	37
5871	31	103	2	1	29	2026-06-29 14:59:13.438897+00	2026-06-29 14:59:13.438897+00	29	45
5872	31	104	2	1	33	2026-06-29 14:59:26.237081+00	2026-06-29 14:59:26.237081+00	33	37
5874	13	99	2	0	9	2026-06-29 15:11:20.470407+00	2026-06-29 15:11:20.470407+00	9	45
5898	55	90	1	2	21	2026-06-29 15:19:13.783023+00	2026-06-29 15:19:13.783023+00	5	21
5900	55	91	2	1	9	2026-06-29 15:19:54.171952+00	2026-06-29 15:19:54.171952+00	9	35
5954	12	102	0	2	44	2026-06-29 15:55:45.237434+00	2026-06-29 15:57:30.376101+00	9	44
5905	55	96	0	1	44	2026-06-29 15:21:15.437634+00	2026-06-29 15:21:15.437634+00	6	44
5956	12	104	0	0	44	2026-06-29 15:56:07.89726+00	2026-06-29 15:57:37.231372+00	33	44
5873	13	100	0	1	44	2026-06-29 15:10:54.671308+00	2026-06-29 15:24:46.861989+00	37	44
5899	55	89	1	2	33	2026-06-29 15:19:38.533317+00	2026-06-29 15:24:47.97982+00	17	33
5901	55	92	1	2	45	2026-06-29 15:20:09.640438+00	2026-06-29 15:27:04.862117+00	1	45
5902	55	93	1	2	29	2026-06-29 15:20:37.176298+00	2026-06-29 15:27:56.345726+00	41	29
4969	51	76	2	1	9	2026-06-28 19:04:57.151798+00	2026-06-29 15:28:49.125198+00	9	22
5904	55	94	1	2	25	2026-06-29 15:20:50.209379+00	2026-06-29 15:29:10.064728+00	13	25
5906	55	95	2	0	37	2026-06-29 15:22:14.458832+00	2026-06-29 15:29:40.653506+00	37	26
5915	13	101	1	1	33	2026-06-29 15:30:10.983732+00	2026-06-29 15:30:10.983732+00	33	29
5916	13	102	1	2	44	2026-06-29 15:30:41.167273+00	2026-06-29 15:30:41.167273+00	9	44
5917	55	98	1	0	29	2026-06-29 15:31:05.753409+00	2026-06-29 15:31:05.753409+00	29	25
5918	13	103	2	1	29	2026-06-29 15:31:19.016622+00	2026-06-29 15:31:19.016622+00	29	9
5919	55	97	2	1	33	2026-06-29 15:31:31.339133+00	2026-06-29 15:31:31.339133+00	33	21
5922	55	99	1	2	45	2026-06-29 15:34:47.861974+00	2026-06-29 16:31:17.716332+00	9	45
5927	27	89	1	2	33	2026-06-29 15:49:29.443214+00	2026-06-29 15:49:29.443214+00	17	33
5928	27	90	0	2	10	2026-06-29 15:49:37.054869+00	2026-06-29 15:49:37.054869+00	5	10
5929	27	91	2	0	9	2026-06-29 15:49:44.569725+00	2026-06-29 15:49:44.569725+00	9	35
5930	27	92	1	2	45	2026-06-29 15:49:57.200354+00	2026-06-29 15:49:57.200354+00	1	45
5931	27	93	1	2	29	2026-06-29 15:50:14.933485+00	2026-06-29 15:50:14.933485+00	41	29
5932	27	94	0	1	34	2026-06-29 15:50:20.766515+00	2026-06-29 15:50:20.766515+00	13	34
5934	27	95	3	0	37	2026-06-29 15:50:27.544273+00	2026-06-29 15:50:27.544273+00	37	26
5935	27	96	0	2	44	2026-06-29 15:50:33.135384+00	2026-06-29 15:50:33.135384+00	6	44
5936	27	98	3	0	29	2026-06-29 15:50:41.47341+00	2026-06-29 15:50:41.47341+00	29	34
5937	27	97	3	0	33	2026-06-29 15:50:50.360341+00	2026-06-29 15:50:50.360341+00	33	10
5938	27	100	1	2	44	2026-06-29 15:50:58.595016+00	2026-06-29 15:50:58.595016+00	37	44
5939	27	99	2	3	45	2026-06-29 15:51:08.277467+00	2026-06-29 15:51:08.277467+00	9	45
5941	27	101	2	1	33	2026-06-29 15:51:27.146921+00	2026-06-29 15:51:27.146921+00	33	29
5942	27	102	0	1	44	2026-06-29 15:51:36.81576+00	2026-06-29 15:51:36.81576+00	45	44
5944	27	103	1	1	29	2026-06-29 15:51:52.287036+00	2026-06-29 15:51:52.287036+00	29	45
5945	27	104	0	1	44	2026-06-29 15:52:00.235714+00	2026-06-29 15:52:00.235714+00	33	44
5955	12	103	1	2	9	2026-06-29 15:56:00.83767+00	2026-06-29 15:56:00.83767+00	41	9
4643	12	87	2	0	44	2026-06-28 17:04:50.530298+00	2026-06-29 15:56:37.214822+00	44	47
5835	12	89	0	2	33	2026-06-29 14:53:03.055725+00	2026-06-29 15:56:57.766962+00	17	33
5952	12	100	0	1	44	2026-06-29 15:55:28.13592+00	2026-06-29 15:57:26.429094+00	37	44
5953	12	101	2	0	33	2026-06-29 15:55:38.390755+00	2026-06-29 15:57:29.632899+00	33	41
5987	13	104	2	1	33	2026-06-29 15:58:41.719718+00	2026-06-29 15:58:41.719718+00	33	44
6009	23	93	1	1	41	2026-06-29 16:12:10.705193+00	2026-06-29 16:25:26.730134+00	41	29
6005	23	94	1	3	25	2026-06-29 16:11:34.784815+00	2026-06-29 16:25:27.376461+00	13	25
6011	23	95	2	0	37	2026-06-29 16:12:27.474064+00	2026-06-29 16:25:27.947505+00	37	26
6013	23	96	0	1	44	2026-06-29 16:12:39.896487+00	2026-06-29 16:25:28.653629+00	6	44
5920	55	100	2	1	37	2026-06-29 15:33:37.533721+00	2026-06-29 16:31:00.55437+00	37	44
6031	45	95	2	0	37	2026-06-29 16:14:37.15848+00	2026-06-29 16:14:53.075347+00	37	26
5995	23	91	3	1	9	2026-06-29 16:08:00.926536+00	2026-06-29 16:25:24.157954+00	9	35
5997	23	92	1	2	45	2026-06-29 16:08:28.934725+00	2026-06-29 16:25:24.78118+00	20	45
6040	29	89	3	2	17	2026-06-29 16:15:29.180734+00	2026-06-29 16:15:29.180734+00	17	33
6041	45	101	1	2	29	2026-06-29 16:15:40.57773+00	2026-06-29 16:15:40.57773+00	33	29
6042	29	90	2	2	21	2026-06-29 16:15:44.283734+00	2026-06-29 16:15:44.283734+00	5	21
6044	45	102	1	2	44	2026-06-29 16:15:55.050994+00	2026-06-29 16:15:55.050994+00	45	44
6045	25	89	0	2	33	2026-06-29 16:16:02.879663+00	2026-06-29 16:16:02.879663+00	17	33
6046	25	90	0	2	10	2026-06-29 16:16:09.396456+00	2026-06-29 16:16:09.396456+00	5	10
6047	45	103	2	1	33	2026-06-29 16:16:11.560177+00	2026-06-29 16:16:40.173018+00	33	45
5992	23	90	1	2	21	2026-06-29 16:07:22.367439+00	2026-06-29 16:25:23.256753+00	5	21
5925	55	103	2	1	29	2026-06-29 15:37:20.849062+00	2026-06-29 16:33:06.383982+00	29	45
5923	55	101	2	1	33	2026-06-29 15:35:11.142609+00	2026-06-29 16:31:41.743722+00	33	29
5924	55	102	1	2	37	2026-06-29 15:36:50.973237+00	2026-06-29 16:32:55.548995+00	45	37
5926	55	104	2	1	33	2026-06-29 15:37:44.301022+00	2026-06-29 16:33:36.234434+00	33	37
6048	25	91	1	0	9	2026-06-29 16:16:14.208331+00	2026-06-29 16:16:14.208331+00	9	35
6043	29	91	3	2	9	2026-06-29 16:15:54.833988+00	2026-06-29 16:16:27.852145+00	9	35
6051	25	93	1	2	29	2026-06-29 16:16:31.330143+00	2026-06-29 16:16:31.330143+00	41	29
6049	45	104	1	2	44	2026-06-29 16:16:26.359194+00	2026-06-29 16:16:32.250005+00	29	44
6053	25	94	0	2	25	2026-06-29 16:16:38.165991+00	2026-06-29 16:16:38.165991+00	13	25
6054	29	92	1	2	45	2026-06-29 16:16:39.135002+00	2026-06-29 16:16:39.135002+00	1	45
6056	25	95	3	0	37	2026-06-29 16:16:43.236655+00	2026-06-29 16:16:43.236655+00	37	15
6057	25	96	0	2	44	2026-06-29 16:16:47.488361+00	2026-06-29 16:16:47.488361+00	6	44
6058	29	93	3	2	41	2026-06-29 16:16:55.37871+00	2026-06-29 16:16:55.37871+00	41	29
6059	25	98	2	0	29	2026-06-29 16:16:57.484585+00	2026-06-29 16:16:57.484585+00	29	25
6060	25	97	1	0	33	2026-06-29 16:17:01.474742+00	2026-06-29 16:17:01.474742+00	33	10
6062	25	100	0	1	44	2026-06-29 16:17:11.233732+00	2026-06-29 16:17:11.233732+00	37	44
6061	29	94	2	2	13	2026-06-29 16:17:07.857092+00	2026-06-29 16:17:19.735166+00	13	25
6064	29	95	3	1	37	2026-06-29 16:17:27.694576+00	2026-06-29 16:17:30.50173+00	37	15
6066	25	92	1	0	20	2026-06-29 16:17:31.835971+00	2026-06-29 16:17:31.835971+00	20	45
6068	25	99	1	0	9	2026-06-29 16:17:43.642931+00	2026-06-29 16:17:43.642931+00	9	20
6069	25	101	0	1	29	2026-06-29 16:17:48.656338+00	2026-06-29 16:17:48.656338+00	33	29
6139	43	75	1	0	21	2026-06-29 16:28:10.984333+00	2026-06-29 16:28:10.984333+00	21	10
6071	25	102	0	1	44	2026-06-29 16:17:56.858572+00	2026-06-29 16:17:56.858572+00	9	44
6072	25	103	2	0	33	2026-06-29 16:18:06.755957+00	2026-06-29 16:18:06.755957+00	33	9
6073	25	104	0	1	44	2026-06-29 16:18:12.035625+00	2026-06-29 16:18:12.035625+00	29	44
6067	29	96	0	2	44	2026-06-29 16:17:39.00472+00	2026-06-29 16:18:38.083375+00	6	44
6075	29	98	3	2	41	2026-06-29 16:18:58.934318+00	2026-06-29 16:18:58.934318+00	41	13
6076	29	97	3	1	17	2026-06-29 16:19:06.431552+00	2026-06-29 16:19:06.431552+00	17	21
6077	29	100	1	2	44	2026-06-29 16:19:19.33279+00	2026-06-29 16:19:19.33279+00	37	44
6078	29	99	2	3	45	2026-06-29 16:19:25.847728+00	2026-06-29 16:19:25.847728+00	9	45
6079	11	93	2	1	41	2026-06-29 16:20:08.574076+00	2026-06-29 16:20:08.574076+00	41	29
6081	29	102	1	1	44	2026-06-29 16:20:49.370995+00	2026-06-29 16:20:49.370995+00	45	44
6082	29	103	2	3	45	2026-06-29 16:21:04.404274+00	2026-06-29 16:21:04.404274+00	17	45
6138	23	103	0	2	9	2026-06-29 16:28:07.367978+00	2026-06-29 16:28:17.844557+00	41	9
6087	66	74	3	2	17	2026-06-29 16:23:19.863211+00	2026-06-29 16:23:19.863211+00	17	14
6088	44	82	3	1	25	2026-06-29 16:23:41.755085+00	2026-06-29 16:23:41.755085+00	25	34
6090	44	83	0	0	41	2026-06-29 16:24:01.062082+00	2026-06-29 16:24:01.062082+00	41	46
6141	66	80	2	0	45	2026-06-29 16:28:18.034524+00	2026-06-29 16:28:18.034524+00	45	42
6093	66	75	1	1	21	2026-06-29 16:24:09.648505+00	2026-06-29 16:24:09.648505+00	21	10
6095	44	84	2	1	29	2026-06-29 16:24:11.830712+00	2026-06-29 16:24:11.830712+00	29	39
6080	29	101	1	2	41	2026-06-29 16:20:12.225453+00	2026-06-29 16:24:16.331844+00	17	41
6097	44	85	0	2	38	2026-06-29 16:24:22.032415+00	2026-06-29 16:24:22.032415+00	6	38
6099	44	86	0	0	37	2026-06-29 16:24:35.32466+00	2026-06-29 16:24:35.32466+00	37	30
6102	44	87	3	1	44	2026-06-29 16:24:49.151983+00	2026-06-29 16:24:49.151983+00	44	47
6083	23	98	1	1	41	2026-06-29 16:21:29.598647+00	2026-06-29 16:25:03.92572+00	41	25
6084	23	97	3	1	33	2026-06-29 16:21:54.733634+00	2026-06-29 16:25:04.80816+00	33	21
6086	23	100	1	1	37	2026-06-29 16:23:08.982863+00	2026-06-29 16:25:05.474368+00	37	44
6089	23	99	2	2	9	2026-06-29 16:23:49.762267+00	2026-06-29 16:25:06.538859+00	9	45
6103	44	88	1	1	15	2026-06-29 16:25:01.526362+00	2026-06-29 16:25:10.557203+00	15	26
6109	29	104	1	2	44	2026-06-29 16:25:13.163986+00	2026-06-29 16:25:13.163986+00	41	44
6110	66	76	3	2	9	2026-06-29 16:25:13.670157+00	2026-06-29 16:25:13.670157+00	9	22
6120	44	89	2	3	33	2026-06-29 16:25:43.558721+00	2026-06-29 16:25:43.558721+00	17	33
6121	66	77	2	1	33	2026-06-29 16:25:48.942957+00	2026-06-29 16:25:48.942957+00	33	23
6122	66	78	0	2	35	2026-06-29 16:26:04.852219+00	2026-06-29 16:26:04.852219+00	19	35
6125	66	79	1	2	20	2026-06-29 16:26:26.751485+00	2026-06-29 16:26:26.751485+00	1	20
6126	44	90	1	2	21	2026-06-29 16:26:32.193904+00	2026-06-29 16:26:32.193904+00	2	21
6098	23	101	2	1	33	2026-06-29 16:24:24.869606+00	2026-06-29 16:26:40.075374+00	33	41
6101	23	102	1	1	37	2026-06-29 16:24:42.507886+00	2026-06-29 16:26:40.674008+00	9	37
6129	44	91	1	0	9	2026-06-29 16:26:48.031261+00	2026-06-29 16:26:48.031261+00	9	35
6131	44	92	1	0	1	2026-06-29 16:27:03.160747+00	2026-06-29 16:27:03.160747+00	1	45
6132	43	74	3	1	17	2026-06-29 16:27:14.155905+00	2026-06-29 16:27:14.155905+00	17	14
6133	44	93	2	2	41	2026-06-29 16:27:24.291039+00	2026-06-29 16:27:24.291039+00	41	29
6134	23	104	2	1	33	2026-06-29 16:27:28.546616+00	2026-06-29 16:27:37.080342+00	33	37
6137	44	94	0	2	25	2026-06-29 16:27:53.958505+00	2026-06-29 16:27:53.958505+00	13	25
6142	44	95	3	0	37	2026-06-29 16:28:18.73491+00	2026-06-29 16:28:18.73491+00	37	15
6143	43	76	2	1	9	2026-06-29 16:28:23.365922+00	2026-06-29 16:28:23.365922+00	9	22
6144	43	77	3	0	33	2026-06-29 16:28:26.966085+00	2026-06-29 16:28:26.966085+00	33	23
6145	66	81	2	3	8	2026-06-29 16:28:29.569082+00	2026-06-29 16:28:29.569082+00	13	8
6146	44	96	1	3	44	2026-06-29 16:28:31.737628+00	2026-06-29 16:28:31.737628+00	38	44
6147	43	78	0	2	35	2026-06-29 16:28:36.536319+00	2026-06-29 16:28:36.536319+00	19	35
6148	43	79	1	1	20	2026-06-29 16:28:48.244791+00	2026-06-29 16:28:48.244791+00	1	20
6149	66	82	2	2	34	2026-06-29 16:29:01.69132+00	2026-06-29 16:29:01.69132+00	25	34
6152	43	80	2	0	45	2026-06-29 16:29:13.961327+00	2026-06-29 16:29:13.961327+00	45	42
6153	66	83	2	1	41	2026-06-29 16:29:18.142093+00	2026-06-29 16:29:18.142093+00	41	46
6154	43	81	1	1	13	2026-06-29 16:29:24.236609+00	2026-06-29 16:29:24.236609+00	13	8
6156	43	82	1	0	25	2026-06-29 16:29:36.451953+00	2026-06-29 16:29:36.451953+00	25	34
6158	66	84	3	2	29	2026-06-29 16:29:40.859721+00	2026-06-29 16:29:40.859721+00	29	39
6159	43	83	2	1	41	2026-06-29 16:29:45.429885+00	2026-06-29 16:29:45.429885+00	41	46
6161	43	84	3	0	29	2026-06-29 16:30:04.779483+00	2026-06-29 16:30:04.779483+00	29	39
6162	43	85	1	0	6	2026-06-29 16:30:12.332574+00	2026-06-29 16:30:12.332574+00	6	38
6150	44	98	1	0	41	2026-06-29 16:29:02.599155+00	2026-06-29 16:31:43.255256+00	41	25
6151	44	97	1	2	21	2026-06-29 16:29:11.923808+00	2026-06-29 16:31:44.644723+00	33	21
6155	44	100	1	1	44	2026-06-29 16:29:28.546722+00	2026-06-29 16:31:48.473067+00	37	44
6163	66	85	3	1	6	2026-06-29 16:30:15.433342+00	2026-06-29 16:30:15.433342+00	6	38
6165	43	86	2	0	37	2026-06-29 16:30:21.302146+00	2026-06-29 16:30:21.302146+00	37	30
6168	66	86	3	1	37	2026-06-29 16:30:31.474113+00	2026-06-29 16:30:31.474113+00	37	30
6166	43	87	2	1	44	2026-06-29 16:30:28.151918+00	2026-06-29 16:30:34.255082+00	44	47
6171	66	87	2	1	44	2026-06-29 16:30:46.889628+00	2026-06-29 16:30:46.889628+00	44	47
6174	43	88	1	1	26	2026-06-29 16:31:03.962323+00	2026-06-29 16:31:03.962323+00	15	26
6172	44	104	1	2	44	2026-06-29 16:30:50.365184+00	2026-06-29 16:31:04.339355+00	41	44
6261	66	101	2	0	33	2026-06-29 16:38:24.349161+00	2026-06-29 16:38:24.349161+00	33	41
6170	44	103	1	0	21	2026-06-29 16:30:39.88406+00	2026-06-29 16:31:26.871127+00	21	9
6178	66	88	0	0	15	2026-06-29 16:31:22.331956+00	2026-06-29 16:31:28.857958+00	15	26
6160	44	101	2	2	41	2026-06-29 16:29:56.956314+00	2026-06-29 16:31:33.639448+00	21	41
6164	44	102	0	2	44	2026-06-29 16:30:16.986122+00	2026-06-29 16:31:34.454727+00	9	44
6184	11	94	2	2	25	2026-06-29 16:31:38.64373+00	2026-06-29 16:31:50.349074+00	13	25
6157	44	99	1	0	9	2026-06-29 16:29:39.80872+00	2026-06-29 16:31:51.14747+00	9	1
6203	43	89	1	2	33	2026-06-29 16:32:42.889164+00	2026-06-29 16:32:42.889164+00	17	33
6205	43	90	0	1	21	2026-06-29 16:32:50.044762+00	2026-06-29 16:32:50.044762+00	5	21
6208	43	91	2	1	9	2026-06-29 16:33:01.050736+00	2026-06-29 16:33:01.050736+00	9	35
6211	43	92	1	2	45	2026-06-29 16:33:09.583962+00	2026-06-29 16:33:09.583962+00	20	45
6213	43	93	0	2	29	2026-06-29 16:33:13.731478+00	2026-06-29 16:33:13.731478+00	41	29
6214	43	94	1	1	25	2026-06-29 16:33:22.069335+00	2026-06-29 16:33:22.069335+00	13	25
6215	43	95	2	0	37	2026-06-29 16:33:27.228525+00	2026-06-29 16:33:27.228525+00	37	26
6216	43	96	0	2	44	2026-06-29 16:33:32.340647+00	2026-06-29 16:33:32.340647+00	6	44
6219	43	97	3	1	33	2026-06-29 16:33:51.446762+00	2026-06-29 16:33:51.446762+00	33	21
6220	43	98	2	0	29	2026-06-29 16:33:57.051041+00	2026-06-29 16:33:57.051041+00	29	25
6221	43	99	1	1	45	2026-06-29 16:34:06.370036+00	2026-06-29 16:34:06.370036+00	9	45
6222	43	100	2	1	37	2026-06-29 16:34:15.592722+00	2026-06-29 16:34:15.592722+00	37	44
6223	11	95	3	1	37	2026-06-29 16:34:19.04608+00	2026-06-29 16:34:19.04608+00	37	15
6224	43	101	2	2	33	2026-06-29 16:34:26.896072+00	2026-06-29 16:34:26.896072+00	33	29
6225	11	96	1	2	44	2026-06-29 16:34:30.346007+00	2026-06-29 16:34:30.346007+00	6	44
6226	43	102	1	1	45	2026-06-29 16:34:37.174188+00	2026-06-29 16:34:37.174188+00	45	37
6191	66	89	0	1	33	2026-06-29 16:31:50.038132+00	2026-06-29 16:34:46.75556+00	17	33
6228	11	98	2	1	41	2026-06-29 16:34:47.673197+00	2026-06-29 16:34:47.673197+00	41	25
6194	66	90	1	0	5	2026-06-29 16:32:05.082018+00	2026-06-29 16:34:48.231608+00	5	21
6230	43	103	2	0	29	2026-06-29 16:34:49.461885+00	2026-06-29 16:34:49.461885+00	29	37
6196	66	91	2	1	9	2026-06-29 16:32:14.957767+00	2026-06-29 16:34:49.841778+00	9	35
6200	66	92	1	3	45	2026-06-29 16:32:24.93834+00	2026-06-29 16:34:51.542501+00	20	45
6201	66	93	2	1	41	2026-06-29 16:32:39.039561+00	2026-06-29 16:34:53.066482+00	41	29
6234	43	104	2	1	33	2026-06-29 16:34:57.64934+00	2026-06-29 16:34:57.64934+00	33	45
6236	11	97	4	2	33	2026-06-29 16:35:08.257912+00	2026-06-29 16:35:08.257912+00	33	21
6237	11	100	1	2	44	2026-06-29 16:35:24.379556+00	2026-06-29 16:35:24.379556+00	37	44
6238	66	94	0	0	34	2026-06-29 16:35:35.181683+00	2026-06-29 16:35:35.181683+00	8	34
6239	66	95	2	1	37	2026-06-29 16:35:55.235586+00	2026-06-29 16:35:55.235586+00	37	15
6240	11	99	1	2	45	2026-06-29 16:35:58.270337+00	2026-06-29 16:35:58.270337+00	9	45
6243	11	101	2	1	33	2026-06-29 16:36:12.865899+00	2026-06-29 16:36:12.865899+00	33	41
6253	42	92	1	2	45	2026-06-29 16:37:09.587282+00	2026-06-29 16:56:50.344515+00	20	45
6245	66	96	0	1	44	2026-06-29 16:36:28.772947+00	2026-06-29 16:36:28.772947+00	6	44
6246	11	102	1	3	44	2026-06-29 16:36:35.662917+00	2026-06-29 16:36:35.662917+00	45	44
6248	11	103	2	1	41	2026-06-29 16:36:49.132729+00	2026-06-29 16:36:49.132729+00	41	45
6249	66	98	1	0	41	2026-06-29 16:36:50.069524+00	2026-06-29 16:36:50.069524+00	41	34
6250	66	97	2	0	33	2026-06-29 16:37:01.84741+00	2026-06-29 16:37:01.84741+00	33	5
6251	11	104	2	1	33	2026-06-29 16:37:02.935512+00	2026-06-29 16:37:06.367833+00	33	44
6256	66	99	1	0	9	2026-06-29 16:37:36.874244+00	2026-06-29 16:37:36.874244+00	9	45
6255	66	100	1	2	44	2026-06-29 16:37:27.743167+00	2026-06-29 16:38:05.735304+00	37	44
6262	42	95	3	1	37	2026-06-29 16:38:28.284529+00	2026-06-29 16:57:04.903775+00	37	26
6268	42	97	2	1	33	2026-06-29 16:39:33.819335+00	2026-06-29 16:57:35.790253+00	33	21
6265	66	102	0	1	44	2026-06-29 16:38:54.787899+00	2026-06-29 16:38:54.787899+00	9	44
6267	66	103	0	2	9	2026-06-29 16:39:17.267687+00	2026-06-29 16:39:17.267687+00	41	9
6269	66	104	0	1	44	2026-06-29 16:39:46.363408+00	2026-06-29 16:39:46.363408+00	33	44
6327	68	74	2	0	17	2026-06-29 16:50:03.732618+00	2026-06-29 16:50:03.732618+00	17	14
6283	42	103	2	0	33	2026-06-29 16:44:00.815725+00	2026-06-29 16:58:13.35287+00	33	45
6284	42	104	1	2	44	2026-06-29 16:45:00.231231+00	2026-06-29 18:09:40.74005+00	29	44
6266	42	98	2	1	29	2026-06-29 16:39:15.488918+00	2026-06-29 16:57:32.045381+00	29	13
6242	42	90	0	2	21	2026-06-29 16:36:10.597929+00	2026-06-29 16:56:39.257157+00	5	21
6329	68	75	3	1	21	2026-06-29 16:50:23.180126+00	2026-06-29 16:50:23.180126+00	21	10
6330	68	76	2	1	9	2026-06-29 16:50:46.792034+00	2026-06-29 16:50:46.792034+00	9	22
6263	42	96	0	2	44	2026-06-29 16:38:46.566443+00	2026-06-29 16:57:16.673912+00	6	44
6241	42	89	2	3	33	2026-06-29 16:36:07.737475+00	2026-06-29 16:56:34.439622+00	17	33
6259	42	94	2	1	13	2026-06-29 16:38:08.264721+00	2026-06-29 16:57:00.882869+00	13	25
6254	42	93	1	3	29	2026-06-29 16:37:26.657508+00	2026-06-29 16:56:54.799458+00	41	29
6343	28	86	2	0	37	2026-06-29 16:51:38.546996+00	2026-06-29 16:51:38.546996+00	37	30
6345	28	87	1	0	44	2026-06-29 16:51:48.469505+00	2026-06-29 16:51:48.469505+00	44	47
6346	28	88	0	1	26	2026-06-29 16:51:54.005638+00	2026-06-29 16:51:54.005638+00	15	26
6351	68	77	2	1	33	2026-06-29 16:52:22.231731+00	2026-06-29 16:52:22.231731+00	33	23
6348	28	89	1	2	33	2026-06-29 16:52:08.305925+00	2026-06-29 16:52:14.063557+00	17	33
6272	42	101	1	2	29	2026-06-29 16:41:28.553911+00	2026-06-29 16:57:57.857418+00	33	29
6352	28	90	1	2	10	2026-06-29 16:52:22.737084+00	2026-06-29 16:52:22.737084+00	2	10
6247	42	91	3	1	9	2026-06-29 16:36:46.242422+00	2026-06-29 16:56:44.576304+00	9	35
6270	42	100	0	2	44	2026-06-29 16:40:02.279726+00	2026-06-29 16:57:37.465897+00	37	44
6271	42	99	1	2	45	2026-06-29 16:40:23.638536+00	2026-06-29 16:57:42.221812+00	9	45
6354	28	91	1	0	22	2026-06-29 16:52:31.172142+00	2026-06-29 16:52:31.172142+00	22	35
6358	68	78	0	2	35	2026-06-29 16:52:43.345476+00	2026-06-29 16:52:43.345476+00	19	35
6359	28	93	1	0	41	2026-06-29 16:52:46.449955+00	2026-06-29 16:52:46.449955+00	41	29
6361	28	94	1	0	13	2026-06-29 16:52:55.300482+00	2026-06-29 16:52:55.300482+00	13	25
6362	28	95	2	0	37	2026-06-29 16:53:02.987542+00	2026-06-29 16:53:02.987542+00	37	26
6363	68	79	2	2	1	2026-06-29 16:53:11.745161+00	2026-06-29 16:53:11.745161+00	1	20
6365	28	96	0	1	44	2026-06-29 16:53:15.149826+00	2026-06-29 16:53:15.149826+00	6	44
6356	28	92	0	1	45	2026-06-29 16:52:36.980905+00	2026-06-29 16:52:36.980905+00	1	45
6367	28	98	2	0	41	2026-06-29 16:53:26.803782+00	2026-06-29 16:53:26.803782+00	41	13
6368	68	80	3	0	45	2026-06-29 16:53:30.964188+00	2026-06-29 16:53:30.964188+00	45	42
6369	28	97	2	0	33	2026-06-29 16:53:36.740005+00	2026-06-29 16:53:36.740005+00	33	10
6370	28	100	1	0	37	2026-06-29 16:53:43.169043+00	2026-06-29 16:53:43.169043+00	37	44
6372	28	99	0	1	45	2026-06-29 16:53:52.25454+00	2026-06-29 16:53:52.25454+00	22	45
6373	68	81	2	0	13	2026-06-29 16:53:56.838979+00	2026-06-29 16:53:56.838979+00	13	8
6376	28	101	2	1	33	2026-06-29 16:54:03.883958+00	2026-06-29 16:54:03.883958+00	33	41
6377	68	82	2	0	25	2026-06-29 16:54:08.709318+00	2026-06-29 16:54:08.709318+00	25	34
6378	28	102	0	1	37	2026-06-29 16:54:12.887073+00	2026-06-29 16:54:12.887073+00	45	37
6380	68	83	2	2	41	2026-06-29 16:54:24.874848+00	2026-06-29 16:54:24.874848+00	41	46
6381	28	103	2	0	41	2026-06-29 16:54:28.1353+00	2026-06-29 16:54:28.1353+00	41	45
6382	28	104	2	0	33	2026-06-29 16:54:35.430203+00	2026-06-29 16:54:35.430203+00	33	37
6383	68	84	3	0	29	2026-06-29 16:54:39.859353+00	2026-06-29 16:54:47.419065+00	29	39
6386	68	85	0	0	6	2026-06-29 16:55:09.314724+00	2026-06-29 16:55:09.314724+00	6	38
6388	68	86	3	0	37	2026-06-29 16:55:19.229183+00	2026-06-29 16:55:19.229183+00	37	30
6391	68	87	3	1	44	2026-06-29 16:55:28.981748+00	2026-06-29 16:55:28.981748+00	44	47
6396	68	88	0	3	26	2026-06-29 16:55:42.995723+00	2026-06-29 16:55:42.995723+00	15	26
6405	68	89	2	2	33	2026-06-29 16:56:24.350569+00	2026-06-29 16:56:24.350569+00	17	33
6417	68	90	0	2	21	2026-06-29 16:56:47.571213+00	2026-06-29 16:56:47.571213+00	2	21
6422	68	91	2	2	9	2026-06-29 16:57:15.538558+00	2026-06-29 16:57:15.538558+00	9	35
6434	68	92	1	2	45	2026-06-29 16:57:52.00425+00	2026-06-29 16:57:52.00425+00	1	45
6273	42	102	1	2	44	2026-06-29 16:41:41.28817+00	2026-06-29 16:58:01.729929+00	45	44
6439	68	93	2	2	41	2026-06-29 16:58:26.708737+00	2026-06-29 16:58:26.708737+00	41	29
6440	68	94	2	0	13	2026-06-29 16:59:01.2951+00	2026-06-29 16:59:01.2951+00	13	25
6441	68	95	3	2	37	2026-06-29 16:59:18.58639+00	2026-06-29 16:59:18.58639+00	37	26
6442	68	96	0	3	44	2026-06-29 16:59:32.921633+00	2026-06-29 16:59:32.921633+00	6	44
6443	68	98	2	0	41	2026-06-29 17:00:00.537912+00	2026-06-29 17:00:00.537912+00	41	13
6444	68	97	3	1	33	2026-06-29 17:00:10.69172+00	2026-06-29 17:00:10.69172+00	33	21
6445	68	100	0	2	44	2026-06-29 17:00:23.085861+00	2026-06-29 17:00:23.085861+00	37	44
6446	68	99	2	1	9	2026-06-29 17:00:42.45185+00	2026-06-29 17:00:42.45185+00	9	45
6447	68	101	3	3	33	2026-06-29 17:00:59.197243+00	2026-06-29 17:00:59.197243+00	33	41
6448	68	102	2	3	44	2026-06-29 17:01:15.565188+00	2026-06-29 17:01:15.565188+00	9	44
6449	68	103	1	2	9	2026-06-29 17:01:46.533779+00	2026-06-29 17:01:46.533779+00	41	9
6450	68	104	1	2	44	2026-06-29 17:02:02.661583+00	2026-06-29 17:02:02.661583+00	33	44
\.


--
-- Data for Name: qualifier_predictions; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.qualifier_predictions (user_id, team_id, created_at) FROM stdin;
42	1	2026-07-01 04:35:04.94555+00
42	4	2026-07-01 04:35:04.948397+00
42	5	2026-07-01 04:35:05.030419+00
42	6	2026-07-01 04:35:05.035795+00
42	9	2026-07-01 04:35:05.038545+00
42	10	2026-07-01 04:35:05.040294+00
42	14	2026-07-01 04:35:05.041911+00
42	13	2026-07-01 04:35:05.043889+00
42	17	2026-07-01 04:35:05.045887+00
42	19	2026-07-01 04:35:05.049141+00
42	22	2026-07-01 04:35:05.051197+00
42	21	2026-07-01 04:35:05.053308+00
42	25	2026-07-01 04:35:05.055145+00
42	26	2026-07-01 04:35:05.057766+00
42	29	2026-07-01 04:35:05.059542+00
42	32	2026-07-01 04:35:05.061753+00
42	33	2026-07-01 04:35:05.064146+00
42	35	2026-07-01 04:35:05.129542+00
42	37	2026-07-01 04:35:05.133504+00
42	38	2026-07-01 04:35:05.135687+00
42	44	2026-07-01 04:35:05.138509+00
42	41	2026-07-01 04:35:05.140469+00
42	45	2026-07-01 04:35:05.142879+00
42	46	2026-07-01 04:35:05.144367+00
27	1	2026-06-27 04:19:56.978223+00
27	3	2026-06-27 04:19:57.029803+00
27	6	2026-06-27 04:19:57.032288+00
27	5	2026-06-27 04:19:57.034646+00
27	9	2026-06-27 04:19:57.036955+00
27	10	2026-06-27 04:19:57.039268+00
27	13	2026-06-27 04:19:57.041795+00
27	14	2026-06-27 04:19:57.043973+00
27	17	2026-06-27 04:19:57.0465+00
27	20	2026-06-27 04:19:57.048688+00
27	22	2026-06-27 04:19:57.051586+00
27	21	2026-06-27 04:19:57.055006+00
27	25	2026-06-27 04:19:57.057439+00
27	26	2026-06-27 04:19:57.059693+00
27	29	2026-06-27 04:19:57.062072+00
27	32	2026-06-27 04:19:57.064416+00
27	33	2026-06-27 04:19:57.066799+00
27	35	2026-06-27 04:19:57.069113+00
27	37	2026-06-27 04:19:57.071488+00
27	39	2026-06-27 04:19:57.07396+00
27	44	2026-06-27 04:19:57.076259+00
27	41	2026-06-27 04:19:57.078673+00
27	45	2026-06-27 04:19:57.08156+00
27	46	2026-06-27 04:19:57.130954+00
10	1	2026-06-27 23:15:38.777294+00
10	3	2026-06-27 23:15:38.78041+00
10	5	2026-06-27 23:15:38.782493+00
10	6	2026-06-27 23:15:38.784616+00
10	9	2026-06-27 23:15:38.786673+00
10	10	2026-06-27 23:15:38.790272+00
10	16	2026-06-27 23:15:38.793941+00
10	13	2026-06-27 23:15:38.795991+00
10	17	2026-06-27 23:15:38.831975+00
10	20	2026-06-27 23:15:38.834092+00
10	21	2026-06-27 23:15:38.836011+00
10	23	2026-06-27 23:15:38.838012+00
10	25	2026-06-27 23:15:38.839921+00
10	26	2026-06-27 23:15:38.841847+00
10	29	2026-06-27 23:15:38.843801+00
10	32	2026-06-27 23:15:38.845769+00
10	33	2026-06-27 23:15:38.847765+00
10	35	2026-06-27 23:15:38.84984+00
18	3	2026-06-17 19:13:32.065255+00
18	1	2026-06-17 19:13:32.066824+00
18	5	2026-06-17 19:13:32.068155+00
18	7	2026-06-17 19:13:32.129553+00
18	9	2026-06-17 19:13:32.131764+00
18	12	2026-06-17 19:13:32.133256+00
10	37	2026-06-27 23:15:38.851798+00
10	39	2026-06-27 23:15:38.853764+00
18	14	2026-06-17 19:13:32.134807+00
18	15	2026-06-17 19:13:32.140154+00
18	17	2026-06-17 19:13:32.142098+00
18	20	2026-06-17 19:13:32.145134+00
18	23	2026-06-17 19:13:32.147112+00
18	21	2026-06-17 19:13:32.149227+00
18	25	2026-06-17 19:13:32.152206+00
18	28	2026-06-17 19:13:32.153629+00
18	32	2026-06-17 19:13:32.155039+00
18	30	2026-06-17 19:13:32.156437+00
18	36	2026-06-17 19:13:32.157958+00
18	33	2026-06-17 19:13:32.15932+00
18	37	2026-06-17 19:13:32.160738+00
18	39	2026-06-17 19:13:32.162179+00
18	44	2026-06-17 19:13:32.163548+00
18	41	2026-06-17 19:13:32.164962+00
18	47	2026-06-17 19:13:32.166333+00
18	45	2026-06-17 19:13:32.167716+00
32	1	2026-06-27 14:44:11.232757+00
32	3	2026-06-27 14:44:11.234845+00
32	5	2026-06-27 14:44:11.23697+00
32	6	2026-06-27 14:44:11.239004+00
32	9	2026-06-27 14:44:11.243128+00
32	12	2026-06-27 14:44:11.24537+00
32	15	2026-06-27 14:44:11.249556+00
32	13	2026-06-27 14:44:11.254518+00
32	17	2026-06-27 14:44:11.257231+00
32	19	2026-06-27 14:44:11.261116+00
32	21	2026-06-27 14:44:11.263225+00
32	23	2026-06-27 14:44:11.265631+00
32	26	2026-06-27 14:44:11.268814+00
32	28	2026-06-27 14:44:11.271691+00
32	29	2026-06-27 14:44:11.273767+00
32	32	2026-06-27 14:44:11.27707+00
32	33	2026-06-27 14:44:11.279195+00
32	35	2026-06-27 14:44:11.281394+00
32	37	2026-06-27 14:44:11.284277+00
32	40	2026-06-27 14:44:11.286845+00
32	44	2026-06-27 14:44:11.28888+00
32	41	2026-06-27 14:44:11.291633+00
32	45	2026-06-27 14:44:11.293653+00
32	46	2026-06-27 14:44:11.295767+00
38	3	2026-06-30 23:12:54.834344+00
38	1	2026-06-30 23:12:54.83818+00
38	6	2026-06-30 23:12:54.840927+00
38	5	2026-06-30 23:12:54.844742+00
38	9	2026-06-30 23:12:54.846382+00
38	10	2026-06-30 23:12:54.85005+00
38	14	2026-06-30 23:12:54.851779+00
38	13	2026-06-30 23:12:54.854309+00
38	17	2026-06-30 23:12:54.856344+00
38	19	2026-06-30 23:12:54.85846+00
38	21	2026-06-30 23:12:54.930569+00
38	23	2026-06-30 23:12:54.932718+00
38	25	2026-06-30 23:12:54.934495+00
38	26	2026-06-30 23:12:54.936996+00
26	3	2026-06-27 22:55:12.028526+00
26	1	2026-06-27 22:55:12.031367+00
26	5	2026-06-27 22:55:12.033644+00
26	8	2026-06-27 22:55:12.035809+00
26	9	2026-06-27 22:55:12.038086+00
26	10	2026-06-27 22:55:12.040494+00
26	13	2026-06-27 22:55:12.043106+00
26	14	2026-06-27 22:55:12.046236+00
26	17	2026-06-27 22:55:12.04814+00
26	20	2026-06-27 22:55:12.0502+00
26	22	2026-06-27 22:55:12.052212+00
26	23	2026-06-27 22:55:12.054307+00
26	25	2026-06-27 22:55:12.056375+00
26	28	2026-06-27 22:55:12.058361+00
26	29	2026-06-27 22:55:12.061369+00
26	32	2026-06-27 22:55:12.063391+00
26	33	2026-06-27 22:55:12.06537+00
26	35	2026-06-27 22:55:12.068407+00
26	37	2026-06-27 22:55:12.070451+00
26	39	2026-06-27 22:55:12.072503+00
26	41	2026-06-27 22:55:12.074598+00
38	29	2026-06-30 23:12:54.942347+00
38	32	2026-06-30 23:12:54.949765+00
38	33	2026-06-30 23:12:54.95919+00
38	35	2026-06-30 23:12:54.960794+00
38	37	2026-06-30 23:12:54.962346+00
38	39	2026-06-30 23:12:54.964393+00
38	44	2026-06-30 23:12:54.966431+00
38	41	2026-06-30 23:12:54.968551+00
38	45	2026-06-30 23:12:54.970573+00
38	46	2026-06-30 23:12:54.972393+00
26	44	2026-06-27 22:55:12.07667+00
26	46	2026-06-27 22:55:12.078679+00
26	45	2026-06-27 22:55:12.080769+00
10	44	2026-06-27 23:15:38.855711+00
10	41	2026-06-27 23:15:38.857856+00
10	45	2026-06-27 23:15:38.859766+00
10	46	2026-06-27 23:15:38.861682+00
37	3	2026-06-28 01:40:34.502723+00
37	4	2026-06-28 01:40:34.505669+00
37	6	2026-06-28 01:40:34.512687+00
37	5	2026-06-28 01:40:34.520292+00
37	9	2026-06-28 01:40:34.525173+00
37	10	2026-06-28 01:40:34.53372+00
37	13	2026-06-28 01:40:34.535842+00
37	14	2026-06-28 01:40:34.547721+00
37	17	2026-06-28 01:40:34.550731+00
37	19	2026-06-28 01:40:34.55473+00
37	22	2026-06-28 01:40:34.562451+00
37	23	2026-06-28 01:40:34.564422+00
37	25	2026-06-28 01:40:34.568732+00
37	26	2026-06-28 01:40:34.570719+00
37	29	2026-06-28 01:40:34.573485+00
37	32	2026-06-28 01:40:34.575523+00
37	33	2026-06-28 01:40:34.579685+00
37	35	2026-06-28 01:40:34.58165+00
37	37	2026-06-28 01:40:34.584754+00
37	39	2026-06-28 01:40:34.586623+00
37	41	2026-06-28 01:40:34.589418+00
37	44	2026-06-28 01:40:34.593645+00
37	45	2026-06-28 01:40:34.595975+00
37	46	2026-06-28 01:40:34.597973+00
12	3	2026-06-28 17:01:06.763128+00
12	1	2026-06-28 17:01:06.767847+00
12	6	2026-06-28 17:01:06.771842+00
12	5	2026-06-28 17:01:06.775828+00
12	9	2026-06-28 17:01:06.778544+00
12	10	2026-06-28 17:01:06.834224+00
12	16	2026-06-28 17:01:06.839572+00
12	13	2026-06-28 17:01:06.847961+00
12	17	2026-06-28 17:01:06.851058+00
12	20	2026-06-28 17:01:06.855892+00
12	22	2026-06-28 17:01:06.85836+00
12	21	2026-06-28 17:01:06.862871+00
12	25	2026-06-28 17:01:06.865403+00
12	26	2026-06-28 17:01:06.868736+00
12	29	2026-06-28 17:01:06.871726+00
12	32	2026-06-28 17:01:06.873932+00
12	33	2026-06-28 17:01:06.8768+00
29	3	2026-06-27 18:59:50.364584+00
29	4	2026-06-27 18:59:50.36689+00
54	1	2026-06-26 12:33:32.15779+00
54	3	2026-06-26 12:33:32.161842+00
54	5	2026-06-26 12:33:32.164061+00
54	7	2026-06-26 12:33:32.166189+00
54	9	2026-06-26 12:33:32.168267+00
54	10	2026-06-26 12:33:32.170566+00
54	14	2026-06-26 12:33:32.172731+00
54	13	2026-06-26 12:33:32.174968+00
54	17	2026-06-26 12:33:32.177419+00
54	20	2026-06-26 12:33:32.179537+00
54	21	2026-06-26 12:33:32.181576+00
54	22	2026-06-26 12:33:32.183615+00
54	25	2026-06-26 12:33:32.186753+00
54	26	2026-06-26 12:33:32.229688+00
54	29	2026-06-26 12:33:32.231849+00
54	32	2026-06-26 12:33:32.23389+00
54	33	2026-06-26 12:33:32.235885+00
54	35	2026-06-26 12:33:32.237942+00
54	37	2026-06-26 12:33:32.240724+00
54	39	2026-06-26 12:33:32.242765+00
54	44	2026-06-26 12:33:32.245582+00
54	41	2026-06-26 12:33:32.247765+00
54	45	2026-06-26 12:33:32.25032+00
54	46	2026-06-26 12:33:32.252306+00
44	1	2026-06-29 14:19:31.347339+00
44	3	2026-06-29 14:19:31.350103+00
44	6	2026-06-29 14:19:31.353666+00
44	5	2026-06-29 14:19:31.356325+00
44	9	2026-06-29 14:19:31.359121+00
44	10	2026-06-29 14:19:31.361338+00
44	14	2026-06-29 14:19:31.363773+00
44	13	2026-06-29 14:19:31.431792+00
44	17	2026-06-29 14:19:31.436547+00
44	20	2026-06-29 14:19:31.438911+00
44	21	2026-06-29 14:19:31.441688+00
44	22	2026-06-29 14:19:31.443954+00
44	25	2026-06-29 14:19:31.446095+00
44	28	2026-06-29 14:19:31.448253+00
44	29	2026-06-29 14:19:31.450458+00
44	32	2026-06-29 14:19:31.452639+00
44	33	2026-06-29 14:19:31.454887+00
44	35	2026-06-29 14:19:31.45873+00
44	37	2026-06-29 14:19:31.461515+00
44	39	2026-06-29 14:19:31.464763+00
44	44	2026-06-29 14:19:31.4669+00
44	41	2026-06-29 14:19:31.469054+00
44	45	2026-06-29 14:19:31.471179+00
44	46	2026-06-29 14:19:31.473319+00
12	35	2026-06-28 17:01:06.879723+00
12	37	2026-06-28 17:01:06.882927+00
12	39	2026-06-28 17:01:06.887019+00
12	41	2026-06-28 17:01:06.889833+00
12	44	2026-06-28 17:01:06.894093+00
12	45	2026-06-28 17:01:06.896721+00
12	46	2026-06-28 17:01:06.899042+00
50	1	2026-06-28 18:48:39.04735+00
50	3	2026-06-28 18:48:39.050543+00
50	5	2026-06-28 18:48:39.05325+00
50	6	2026-06-28 18:48:39.05599+00
50	9	2026-06-28 18:48:39.058466+00
50	10	2026-06-28 18:48:39.129345+00
50	14	2026-06-28 18:48:39.131947+00
50	13	2026-06-28 18:48:39.134438+00
50	20	2026-06-28 18:48:39.137504+00
50	17	2026-06-28 18:48:39.140501+00
50	21	2026-06-28 18:48:39.142956+00
50	22	2026-06-28 18:48:39.145136+00
50	25	2026-06-28 18:48:39.147671+00
50	26	2026-06-28 18:48:39.150085+00
50	32	2026-06-28 18:48:39.15224+00
50	29	2026-06-28 18:48:39.154477+00
50	33	2026-06-28 18:48:39.156685+00
50	35	2026-06-28 18:48:39.159201+00
50	37	2026-06-28 18:48:39.162135+00
50	39	2026-06-28 18:48:39.16558+00
50	41	2026-06-28 18:48:39.168442+00
50	44	2026-06-28 18:48:39.229964+00
50	45	2026-06-28 18:48:39.232442+00
50	46	2026-06-28 18:48:39.234625+00
68	1	2026-06-29 18:48:42.134841+00
68	2	2026-06-29 18:48:42.138569+00
68	5	2026-06-29 18:48:42.140732+00
68	8	2026-06-29 18:48:42.143347+00
68	9	2026-06-29 18:48:42.14559+00
68	10	2026-06-29 18:48:42.148612+00
68	14	2026-06-29 18:48:42.229841+00
68	13	2026-06-29 18:48:42.233056+00
68	17	2026-06-29 18:48:42.235533+00
68	20	2026-06-29 18:48:42.237587+00
68	22	2026-06-29 18:48:42.240065+00
68	21	2026-06-29 18:48:42.243394+00
68	25	2026-06-29 18:48:42.24652+00
68	26	2026-06-29 18:48:42.330798+00
68	32	2026-06-29 18:48:42.333599+00
68	29	2026-06-29 18:48:42.336378+00
68	33	2026-06-29 18:48:42.339125+00
68	35	2026-06-29 18:48:42.341468+00
68	37	2026-06-29 18:48:42.429964+00
68	39	2026-06-29 18:48:42.432659+00
68	41	2026-06-29 18:48:42.43421+00
68	44	2026-06-29 18:48:42.436551+00
68	45	2026-06-29 18:48:42.438199+00
68	47	2026-06-29 18:48:42.440625+00
46	1	2026-06-27 13:09:45.546945+00
46	3	2026-06-27 13:09:45.549146+00
46	5	2026-06-27 13:09:45.552163+00
46	6	2026-06-27 13:09:45.555072+00
46	9	2026-06-27 13:09:45.557162+00
46	10	2026-06-27 13:09:45.559449+00
23	3	2026-06-27 04:33:47.560957+00
23	1	2026-06-27 04:33:47.56342+00
23	6	2026-06-27 04:33:47.630758+00
23	5	2026-06-27 04:33:47.633433+00
23	9	2026-06-27 04:33:47.635634+00
23	10	2026-06-27 04:33:47.637718+00
23	16	2026-06-27 04:33:47.639688+00
23	13	2026-06-27 04:33:47.641904+00
23	17	2026-06-27 04:33:47.643859+00
23	20	2026-06-27 04:33:47.645854+00
23	21	2026-06-27 04:33:47.647808+00
23	22	2026-06-27 04:33:47.649755+00
23	25	2026-06-27 04:33:47.65178+00
23	26	2026-06-27 04:33:47.653719+00
23	29	2026-06-27 04:33:47.655761+00
23	32	2026-06-27 04:33:47.657687+00
23	33	2026-06-27 04:33:47.659688+00
23	35	2026-06-27 04:33:47.661651+00
23	37	2026-06-27 04:33:47.663585+00
23	39	2026-06-27 04:33:47.665512+00
23	41	2026-06-27 04:33:47.667691+00
23	44	2026-06-27 04:33:47.669741+00
23	45	2026-06-27 04:33:47.671717+00
23	46	2026-06-27 04:33:47.673647+00
33	3	2026-06-27 05:10:57.588637+00
33	1	2026-06-27 05:10:57.591568+00
33	5	2026-06-27 05:10:57.593785+00
33	7	2026-06-27 05:10:57.628915+00
33	9	2026-06-27 05:10:57.632302+00
33	10	2026-06-27 05:10:57.637204+00
33	13	2026-06-27 05:10:57.640934+00
33	14	2026-06-27 05:10:57.643515+00
33	17	2026-06-27 05:10:57.645596+00
33	19	2026-06-27 05:10:57.648145+00
33	21	2026-06-27 05:10:57.654516+00
33	22	2026-06-27 05:10:57.659586+00
33	25	2026-06-27 05:10:57.664425+00
33	26	2026-06-27 05:10:57.668933+00
33	29	2026-06-27 05:10:57.67242+00
33	32	2026-06-27 05:10:57.675574+00
33	33	2026-06-27 05:10:57.678115+00
33	35	2026-06-27 05:10:57.680978+00
33	37	2026-06-27 05:10:57.683402+00
33	38	2026-06-27 05:10:57.685658+00
33	41	2026-06-27 05:10:57.688006+00
33	44	2026-06-27 05:10:57.690347+00
33	45	2026-06-27 05:10:57.692566+00
33	46	2026-06-27 05:10:57.694791+00
45	3	2026-06-29 22:01:46.754647+00
45	1	2026-06-29 22:01:46.75748+00
56	1	2026-07-01 20:23:04.0509+00
56	4	2026-07-01 20:23:04.058145+00
56	5	2026-07-01 20:23:04.062859+00
56	7	2026-07-01 20:23:04.138004+00
56	9	2026-07-01 20:23:04.140742+00
56	10	2026-07-01 20:23:04.143774+00
56	13	2026-07-01 20:23:04.146019+00
56	14	2026-07-01 20:23:04.151284+00
56	17	2026-07-01 20:23:04.153818+00
56	19	2026-07-01 20:23:04.156014+00
56	21	2026-07-01 20:23:04.159724+00
56	22	2026-07-01 20:23:04.163722+00
56	25	2026-07-01 20:23:04.16595+00
56	27	2026-07-01 20:23:04.177542+00
56	29	2026-07-01 20:23:04.183866+00
56	31	2026-07-01 20:23:04.186047+00
56	35	2026-07-01 20:23:04.228924+00
56	33	2026-07-01 20:23:04.236691+00
56	37	2026-07-01 20:23:04.240795+00
56	38	2026-07-01 20:23:04.243089+00
56	41	2026-07-01 20:23:04.249574+00
56	42	2026-07-01 20:23:04.25213+00
46	13	2026-06-27 13:09:45.561876+00
46	14	2026-06-27 13:09:45.568221+00
46	17	2026-06-27 13:09:45.570236+00
46	20	2026-06-27 13:09:45.572177+00
48	1	2026-06-28 17:37:20.872989+00
48	3	2026-06-28 17:37:20.876832+00
48	5	2026-06-28 17:37:20.885782+00
48	6	2026-06-28 17:37:20.888433+00
48	10	2026-06-28 17:37:20.928928+00
48	9	2026-06-28 17:37:20.931508+00
48	13	2026-06-28 17:37:20.937926+00
48	14	2026-06-28 17:37:20.942988+00
48	17	2026-06-28 17:37:20.946728+00
48	19	2026-06-28 17:37:20.948973+00
48	23	2026-06-28 17:37:20.951629+00
48	21	2026-06-28 17:37:20.957964+00
48	26	2026-06-28 17:37:20.960144+00
48	25	2026-06-28 17:37:20.966722+00
48	32	2026-06-28 17:37:20.970414+00
48	29	2026-06-28 17:37:20.97281+00
48	33	2026-06-28 17:37:20.978722+00
48	35	2026-06-28 17:37:20.985736+00
48	37	2026-06-28 17:37:20.989682+00
48	39	2026-06-28 17:37:20.999131+00
48	44	2026-06-28 17:37:21.030726+00
48	41	2026-06-28 17:37:21.035801+00
48	45	2026-06-28 17:37:21.040728+00
48	46	2026-06-28 17:37:21.044487+00
56	45	2026-07-01 20:23:04.255314+00
56	46	2026-07-01 20:23:04.258724+00
46	21	2026-06-27 13:09:45.57432+00
46	23	2026-06-27 13:09:45.578603+00
46	25	2026-06-27 13:09:45.580597+00
46	27	2026-06-27 13:09:45.582586+00
46	29	2026-06-27 13:09:45.585004+00
46	32	2026-06-27 13:09:45.586971+00
46	33	2026-06-27 13:09:45.589144+00
46	35	2026-06-27 13:09:45.629949+00
46	37	2026-06-27 13:09:45.632283+00
46	39	2026-06-27 13:09:45.634327+00
46	44	2026-06-27 13:09:45.636413+00
46	41	2026-06-27 13:09:45.639294+00
46	45	2026-06-27 13:09:45.641506+00
46	46	2026-06-27 13:09:45.643515+00
11	3	2026-06-27 15:05:57.702527+00
11	1	2026-06-27 15:05:57.706724+00
11	5	2026-06-27 15:05:57.71072+00
11	6	2026-06-27 15:05:57.715691+00
11	9	2026-06-27 15:05:57.717769+00
11	10	2026-06-27 15:05:57.720459+00
11	13	2026-06-27 15:05:57.723843+00
11	16	2026-06-27 15:05:57.727127+00
11	17	2026-06-27 15:05:57.733046+00
11	20	2026-06-27 15:05:57.735126+00
11	21	2026-06-27 15:05:57.737365+00
11	23	2026-06-27 15:05:57.741717+00
11	25	2026-06-27 15:05:57.743805+00
11	26	2026-06-27 15:05:57.747685+00
11	29	2026-06-27 15:05:57.750729+00
11	32	2026-06-27 15:05:57.752722+00
11	33	2026-06-27 15:05:57.754822+00
11	35	2026-06-27 15:05:57.756914+00
11	37	2026-06-27 15:05:57.760023+00
29	5	2026-06-27 18:59:50.368886+00
29	8	2026-06-27 18:59:50.374007+00
29	9	2026-06-27 18:59:50.376025+00
29	12	2026-06-27 18:59:50.378135+00
29	14	2026-06-27 18:59:50.381625+00
29	13	2026-06-27 18:59:50.384142+00
29	20	2026-06-27 18:59:50.386175+00
29	17	2026-06-27 18:59:50.388156+00
29	22	2026-06-27 18:59:50.390073+00
29	21	2026-06-27 18:59:50.392896+00
29	28	2026-06-27 18:59:50.394809+00
29	25	2026-06-27 18:59:50.396777+00
29	29	2026-06-27 18:59:50.398708+00
29	32	2026-06-27 18:59:50.400584+00
29	33	2026-06-27 18:59:50.402587+00
29	35	2026-06-27 18:59:50.404559+00
29	37	2026-06-27 18:59:50.429854+00
29	39	2026-06-27 18:59:50.432019+00
29	44	2026-06-27 18:59:50.434131+00
29	41	2026-06-27 18:59:50.43607+00
45	5	2026-06-29 22:01:46.760039+00
45	6	2026-06-29 22:01:46.764057+00
45	9	2026-06-29 22:01:46.766285+00
45	10	2026-06-29 22:01:46.768726+00
45	13	2026-06-29 22:01:46.770966+00
45	14	2026-06-29 22:01:46.77311+00
45	17	2026-06-29 22:01:46.775183+00
45	20	2026-06-29 22:01:46.77738+00
45	22	2026-06-29 22:01:46.779565+00
45	21	2026-06-29 22:01:46.781802+00
45	25	2026-06-29 22:01:46.783956+00
45	26	2026-06-29 22:01:46.786112+00
45	29	2026-06-29 22:01:46.788259+00
45	32	2026-06-29 22:01:46.790397+00
45	33	2026-06-29 22:01:46.792537+00
45	35	2026-06-29 22:01:46.794789+00
45	37	2026-06-29 22:01:46.830048+00
45	39	2026-06-29 22:01:46.832373+00
45	41	2026-06-29 22:01:46.834633+00
45	44	2026-06-29 22:01:46.837204+00
66	3	2026-07-01 23:40:03.909039+00
66	1	2026-07-01 23:40:03.93672+00
66	6	2026-07-01 23:40:03.939983+00
66	5	2026-07-01 23:40:03.94292+00
45	45	2026-06-29 22:01:46.840811+00
45	46	2026-06-29 22:01:46.843254+00
66	9	2026-07-01 23:40:03.945214+00
66	10	2026-07-01 23:40:03.947453+00
66	13	2026-07-01 23:40:03.949759+00
66	15	2026-07-01 23:40:03.951952+00
66	17	2026-07-01 23:40:03.954438+00
66	20	2026-07-01 23:40:03.956683+00
66	23	2026-07-01 23:40:03.959276+00
66	22	2026-07-01 23:40:03.962049+00
66	27	2026-07-01 23:40:04.028551+00
66	25	2026-07-01 23:40:04.031677+00
66	32	2026-07-01 23:40:04.034367+00
66	29	2026-07-01 23:40:04.036722+00
66	33	2026-07-01 23:40:04.042445+00
66	35	2026-07-01 23:40:04.13227+00
66	37	2026-07-01 23:40:04.134995+00
66	40	2026-07-01 23:40:04.137295+00
66	44	2026-07-01 23:40:04.140927+00
66	41	2026-07-01 23:40:04.143859+00
66	45	2026-07-01 23:40:04.145967+00
66	46	2026-07-01 23:40:04.148741+00
55	1	2026-07-01 01:20:47.839725+00
55	4	2026-07-01 01:20:47.845048+00
55	8	2026-07-01 01:20:47.847725+00
55	6	2026-07-01 01:20:47.929574+00
55	9	2026-07-01 01:20:47.931835+00
55	10	2026-07-01 01:20:47.936182+00
55	13	2026-07-01 01:20:47.938623+00
55	16	2026-07-01 01:20:47.940818+00
55	17	2026-07-01 01:20:47.942787+00
55	20	2026-07-01 01:20:47.944719+00
55	21	2026-07-01 01:20:47.947037+00
55	22	2026-07-01 01:20:47.950145+00
55	26	2026-07-01 01:20:47.952146+00
55	25	2026-07-01 01:20:47.956731+00
55	29	2026-07-01 01:20:47.959843+00
55	30	2026-07-01 01:20:48.029564+00
55	33	2026-07-01 01:20:48.031346+00
55	35	2026-07-01 01:20:48.033456+00
55	37	2026-07-01 01:20:48.035488+00
55	38	2026-07-01 01:20:48.037416+00
55	41	2026-07-01 01:20:48.039404+00
55	44	2026-07-01 01:20:48.041141+00
55	45	2026-07-01 01:20:48.042915+00
55	46	2026-07-01 01:20:48.044544+00
29	45	2026-06-27 18:59:50.441839+00
29	46	2026-06-27 18:59:50.447678+00
14	3	2026-06-28 16:05:16.746041+00
14	4	2026-06-28 16:05:16.749981+00
14	6	2026-06-28 16:05:16.752507+00
14	5	2026-06-28 16:05:16.831056+00
14	9	2026-06-28 16:05:16.83347+00
14	10	2026-06-28 16:05:16.837417+00
14	16	2026-06-28 16:05:16.83982+00
14	13	2026-06-28 16:05:16.841932+00
14	17	2026-06-28 16:05:16.844291+00
14	19	2026-06-28 16:05:16.846758+00
14	21	2026-06-28 16:05:16.848982+00
11	39	2026-06-27 15:05:57.762675+00
11	44	2026-06-27 15:05:57.768721+00
11	41	2026-06-27 15:05:57.770716+00
11	45	2026-06-27 15:05:57.772744+00
11	46	2026-06-27 15:05:57.777213+00
14	23	2026-06-28 16:05:16.85125+00
14	25	2026-06-28 16:05:16.853432+00
14	26	2026-06-28 16:05:16.931628+00
14	29	2026-06-28 16:05:16.93421+00
14	32	2026-06-28 16:05:16.936843+00
14	33	2026-06-28 16:05:16.939262+00
14	35	2026-06-28 16:05:16.942017+00
14	37	2026-06-28 16:05:16.944281+00
14	39	2026-06-28 16:05:16.946486+00
14	44	2026-06-28 16:05:16.94895+00
14	41	2026-06-28 16:05:16.951467+00
14	45	2026-06-28 16:05:16.954646+00
14	46	2026-06-28 16:05:16.973359+00
1	3	2026-07-02 21:03:32.531523+00
1	1	2026-07-02 21:03:32.534241+00
1	8	2026-07-02 21:03:32.536395+00
1	5	2026-07-02 21:03:32.539018+00
1	9	2026-07-02 21:03:32.541721+00
1	12	2026-07-02 21:03:32.543943+00
1	15	2026-07-02 21:03:32.546354+00
1	13	2026-07-02 21:03:32.548916+00
1	17	2026-07-02 21:03:32.568903+00
1	19	2026-07-02 21:03:32.571266+00
1	22	2026-07-02 21:03:32.573518+00
47	1	2026-06-29 23:53:29.953824+00
47	3	2026-06-29 23:53:30.028606+00
1	21	2026-07-02 21:03:32.575833+00
1	25	2026-07-02 21:03:32.57874+00
1	26	2026-07-02 21:03:32.580887+00
1	31	2026-07-02 21:03:32.628902+00
1	30	2026-07-02 21:03:32.631386+00
1	33	2026-07-02 21:03:32.633603+00
1	36	2026-07-02 21:03:32.635848+00
1	38	2026-07-02 21:03:32.638088+00
1	37	2026-07-02 21:03:32.640375+00
1	44	2026-07-02 21:03:32.64261+00
1	41	2026-07-02 21:03:32.645035+00
1	46	2026-07-02 21:03:32.647585+00
1	47	2026-07-02 21:03:32.649884+00
13	3	2026-06-28 05:22:42.741646+00
13	1	2026-06-28 05:22:42.745501+00
13	5	2026-06-28 05:22:42.747725+00
13	6	2026-06-28 05:22:42.750155+00
13	9	2026-06-28 05:22:42.752829+00
13	10	2026-06-28 05:22:42.755591+00
13	13	2026-06-28 05:22:42.758022+00
13	16	2026-06-28 05:22:42.760539+00
13	17	2026-06-28 05:22:42.762591+00
13	20	2026-06-28 05:22:42.833304+00
13	21	2026-06-28 05:22:42.836383+00
13	22	2026-06-28 05:22:42.838825+00
13	25	2026-06-28 05:22:42.843023+00
13	27	2026-06-28 05:22:42.845547+00
13	32	2026-06-28 05:22:42.848573+00
13	29	2026-06-28 05:22:42.850893+00
13	33	2026-06-28 05:22:42.852944+00
13	35	2026-06-28 05:22:42.855725+00
13	37	2026-06-28 05:22:42.85846+00
13	38	2026-06-28 05:22:42.861245+00
13	44	2026-06-28 05:22:42.863855+00
13	41	2026-06-28 05:22:42.867549+00
13	45	2026-06-28 05:22:42.869531+00
13	46	2026-06-28 05:22:42.930044+00
47	5	2026-06-29 23:53:30.031517+00
47	6	2026-06-29 23:53:30.034169+00
47	9	2026-06-29 23:53:30.036315+00
47	12	2026-06-29 23:53:30.038501+00
47	13	2026-06-29 23:53:30.040773+00
47	14	2026-06-29 23:53:30.042953+00
47	17	2026-06-29 23:53:30.045087+00
47	20	2026-06-29 23:53:30.04753+00
47	21	2026-06-29 23:53:30.050018+00
47	23	2026-06-29 23:53:30.053223+00
47	26	2026-06-29 23:53:30.055334+00
47	25	2026-06-29 23:53:30.058323+00
47	29	2026-06-29 23:53:30.061793+00
47	30	2026-06-29 23:53:30.064018+00
47	33	2026-06-29 23:53:30.067299+00
47	35	2026-06-29 23:53:30.069569+00
47	37	2026-06-29 23:53:30.132978+00
47	39	2026-06-29 23:53:30.135291+00
47	44	2026-06-29 23:53:30.137808+00
47	41	2026-06-29 23:53:30.139952+00
47	45	2026-06-29 23:53:30.142098+00
47	46	2026-06-29 23:53:30.144282+00
51	1	2026-06-29 15:28:11.949217+00
51	3	2026-06-29 15:28:11.951574+00
51	6	2026-06-29 15:28:11.953732+00
51	5	2026-06-29 15:28:11.95592+00
51	9	2026-06-29 15:28:11.958198+00
51	10	2026-06-29 15:28:11.960425+00
51	13	2026-06-29 15:28:11.962854+00
51	14	2026-06-29 15:28:11.964947+00
51	17	2026-06-29 15:28:11.966955+00
51	20	2026-06-29 15:28:11.969057+00
51	21	2026-06-29 15:28:11.972785+00
51	22	2026-06-29 15:28:11.975321+00
51	25	2026-06-29 15:28:11.977288+00
51	26	2026-06-29 15:28:11.979524+00
51	29	2026-06-29 15:28:11.981975+00
51	32	2026-06-29 15:28:11.984113+00
51	33	2026-06-29 15:28:11.986165+00
51	34	2026-06-29 15:28:11.988281+00
51	37	2026-06-29 15:28:11.990554+00
51	38	2026-06-29 15:28:11.992646+00
51	41	2026-06-29 15:28:11.994663+00
51	44	2026-06-29 15:28:11.996759+00
51	45	2026-06-29 15:28:11.998779+00
51	46	2026-06-29 15:28:12.000748+00
24	3	2026-06-29 00:05:22.638875+00
24	1	2026-06-29 00:05:22.642723+00
24	6	2026-06-29 00:05:22.644832+00
24	5	2026-06-29 00:05:22.650305+00
24	10	2026-06-29 00:05:22.657749+00
24	9	2026-06-29 00:05:22.665915+00
24	13	2026-06-29 00:05:22.683292+00
24	14	2026-06-29 00:05:22.694511+00
24	17	2026-06-29 00:05:22.699884+00
24	19	2026-06-29 00:05:22.70967+00
24	21	2026-06-29 00:05:22.728262+00
24	22	2026-06-29 00:05:22.736746+00
24	25	2026-06-29 00:05:22.744023+00
24	26	2026-06-29 00:05:22.746261+00
24	29	2026-06-29 00:05:22.75637+00
24	32	2026-06-29 00:05:22.762165+00
24	33	2026-06-29 00:05:22.764918+00
24	35	2026-06-29 00:05:22.767377+00
24	37	2026-06-29 00:05:22.774784+00
24	39	2026-06-29 00:05:22.786822+00
24	41	2026-06-29 00:05:22.790939+00
24	44	2026-06-29 00:05:22.793201+00
24	45	2026-06-29 00:05:22.805956+00
24	46	2026-06-29 00:05:22.810537+00
30	3	2026-06-27 18:17:54.277725+00
30	1	2026-06-27 18:17:54.282724+00
30	5	2026-06-27 18:17:54.284803+00
30	6	2026-06-27 18:17:54.28965+00
30	9	2026-06-27 18:17:54.291811+00
30	10	2026-06-27 18:17:54.293926+00
30	13	2026-06-27 18:17:54.300785+00
30	14	2026-06-27 18:17:54.302812+00
30	17	2026-06-27 18:17:54.304956+00
30	20	2026-06-27 18:17:54.306926+00
30	21	2026-06-27 18:17:54.308942+00
30	22	2026-06-27 18:17:54.310927+00
30	25	2026-06-27 18:17:54.313728+00
30	26	2026-06-27 18:17:54.31566+00
30	29	2026-06-27 18:17:54.318723+00
30	32	2026-06-27 18:17:54.329995+00
30	33	2026-06-27 18:17:54.33373+00
30	35	2026-06-27 18:17:54.335624+00
30	37	2026-06-27 18:17:54.339205+00
30	38	2026-06-27 18:17:54.341192+00
30	44	2026-06-27 18:17:54.34314+00
30	41	2026-06-27 18:17:54.345044+00
30	45	2026-06-27 18:17:54.348225+00
30	46	2026-06-27 18:17:54.351206+00
59	1	2026-06-27 23:44:14.230812+00
59	4	2026-06-27 23:44:14.235422+00
59	5	2026-06-27 23:44:14.237572+00
59	8	2026-06-27 23:44:14.241009+00
59	9	2026-06-27 23:44:14.24372+00
59	10	2026-06-27 23:44:14.246646+00
59	13	2026-06-27 23:44:14.249463+00
59	15	2026-06-27 23:44:14.253714+00
59	17	2026-06-27 23:44:14.255732+00
59	20	2026-06-27 23:44:14.257762+00
59	21	2026-06-27 23:44:14.259759+00
59	22	2026-06-27 23:44:14.262719+00
59	25	2026-06-27 23:44:14.264727+00
59	26	2026-06-27 23:44:14.26683+00
59	29	2026-06-27 23:44:14.269634+00
59	32	2026-06-27 23:44:14.273635+00
59	33	2026-06-27 23:44:14.276636+00
59	35	2026-06-27 23:44:14.278742+00
59	37	2026-06-27 23:44:14.283926+00
59	39	2026-06-27 23:44:14.285939+00
59	44	2026-06-27 23:44:14.288375+00
59	41	2026-06-27 23:44:14.290445+00
59	45	2026-06-27 23:44:14.292321+00
59	47	2026-06-27 23:44:14.294612+00
58	2	2026-06-27 21:28:56.702774+00
58	1	2026-06-27 21:28:56.705755+00
58	7	2026-06-27 21:28:56.711224+00
58	5	2026-06-27 21:28:56.714036+00
58	9	2026-06-27 21:28:56.718679+00
58	10	2026-06-27 21:28:56.723823+00
58	14	2026-06-27 21:28:56.731767+00
58	16	2026-06-27 21:28:56.733954+00
58	17	2026-06-27 21:28:56.735994+00
58	20	2026-06-27 21:28:56.738085+00
58	21	2026-06-27 21:28:56.741607+00
58	22	2026-06-27 21:28:56.74463+00
58	27	2026-06-27 21:28:56.747644+00
58	28	2026-06-27 21:28:56.749784+00
58	29	2026-06-27 21:28:56.752634+00
58	32	2026-06-27 21:28:56.755657+00
58	33	2026-06-27 21:28:56.759733+00
58	35	2026-06-27 21:28:56.761762+00
58	37	2026-06-27 21:28:56.764146+00
58	39	2026-06-27 21:28:56.767721+00
58	44	2026-06-27 21:28:56.769766+00
58	41	2026-06-27 21:28:56.771764+00
58	45	2026-06-27 21:28:56.774632+00
58	46	2026-06-27 21:28:56.780659+00
43	3	2026-06-27 15:20:02.432405+00
43	1	2026-06-27 15:20:02.434947+00
43	5	2026-06-27 15:20:02.437518+00
43	6	2026-06-27 15:20:02.439671+00
43	9	2026-06-27 15:20:02.44184+00
43	10	2026-06-27 15:20:02.44395+00
43	13	2026-06-27 15:20:02.446354+00
43	16	2026-06-27 15:20:02.448616+00
43	17	2026-06-27 15:20:02.450978+00
43	20	2026-06-27 15:20:02.453369+00
43	22	2026-06-27 15:20:02.455487+00
43	21	2026-06-27 15:20:02.457927+00
43	25	2026-06-27 15:20:02.460437+00
43	26	2026-06-27 15:20:02.462824+00
43	29	2026-06-27 15:20:02.465249+00
43	32	2026-06-27 15:20:02.467242+00
43	33	2026-06-27 15:20:02.469212+00
43	35	2026-06-27 15:20:02.472449+00
43	37	2026-06-27 15:20:02.474459+00
43	40	2026-06-27 15:20:02.476515+00
43	41	2026-06-27 15:20:02.478809+00
43	44	2026-06-27 15:20:02.480833+00
43	45	2026-06-27 15:20:02.483737+00
43	46	2026-06-27 15:20:02.485763+00
9	3	2026-06-26 17:54:58.544258+00
9	1	2026-06-26 17:54:58.547769+00
9	5	2026-06-26 17:54:58.550043+00
9	6	2026-06-26 17:54:58.552057+00
9	9	2026-06-26 17:54:58.554182+00
9	10	2026-06-26 17:54:58.556311+00
9	14	2026-06-26 17:54:58.561192+00
9	13	2026-06-26 17:54:58.563907+00
9	20	2026-06-26 17:54:58.565996+00
9	17	2026-06-26 17:54:58.567952+00
9	21	2026-06-26 17:54:58.571647+00
9	22	2026-06-26 17:54:58.573671+00
9	25	2026-06-26 17:54:58.575723+00
9	26	2026-06-26 17:54:58.577677+00
9	29	2026-06-26 17:54:58.631868+00
9	32	2026-06-26 17:54:58.634103+00
9	33	2026-06-26 17:54:58.6361+00
9	35	2026-06-26 17:54:58.638087+00
9	37	2026-06-26 17:54:58.640057+00
9	39	2026-06-26 17:54:58.642085+00
9	41	2026-06-26 17:54:58.64425+00
9	44	2026-06-26 17:54:58.64663+00
9	45	2026-06-26 17:54:58.648684+00
9	46	2026-06-26 17:54:58.650775+00
15	3	2026-06-29 16:50:02.435135+00
15	1	2026-06-29 16:50:02.437841+00
15	5	2026-06-29 16:50:02.440919+00
15	6	2026-06-29 16:50:02.443083+00
15	9	2026-06-29 16:50:02.445263+00
15	10	2026-06-29 16:50:02.447785+00
15	13	2026-06-29 16:50:02.450021+00
15	14	2026-06-29 16:50:02.452206+00
15	17	2026-06-29 16:50:02.454437+00
15	20	2026-06-29 16:50:02.456642+00
15	23	2026-06-29 16:50:02.459085+00
15	21	2026-06-29 16:50:02.461667+00
15	25	2026-06-29 16:50:02.529359+00
15	28	2026-06-29 16:50:02.65306+00
15	29	2026-06-29 16:50:02.656501+00
15	32	2026-06-29 16:50:02.658866+00
15	33	2026-06-29 16:50:02.661161+00
15	34	2026-06-29 16:50:02.663435+00
15	37	2026-06-29 16:50:02.665591+00
15	38	2026-06-29 16:50:02.669056+00
15	44	2026-06-29 16:50:02.671811+00
15	41	2026-06-29 16:50:02.674012+00
15	45	2026-06-29 16:50:02.676334+00
15	46	2026-06-29 16:50:02.678514+00
31	1	2026-06-28 02:49:49.161686+00
31	4	2026-06-28 02:49:49.172544+00
31	6	2026-06-28 02:49:49.174689+00
31	5	2026-06-28 02:49:49.178722+00
31	9	2026-06-28 02:49:49.180755+00
31	10	2026-06-28 02:49:49.183595+00
31	14	2026-06-28 02:49:49.186787+00
31	13	2026-06-28 02:49:49.188716+00
31	17	2026-06-28 02:49:49.191616+00
31	20	2026-06-28 02:49:49.194721+00
31	21	2026-06-28 02:49:49.196642+00
31	22	2026-06-28 02:49:49.198599+00
31	25	2026-06-28 02:49:49.2016+00
41	4	2026-06-30 16:01:14.754814+00
41	3	2026-06-30 16:01:14.758256+00
41	6	2026-06-30 16:01:14.760341+00
41	5	2026-06-30 16:01:14.763238+00
41	9	2026-06-30 16:01:14.765397+00
16	3	2026-06-23 00:24:01.787589+00
16	4	2026-06-23 00:24:01.79169+00
16	5	2026-06-23 00:24:01.794781+00
16	8	2026-06-23 00:24:01.796387+00
16	9	2026-06-23 00:24:01.797935+00
16	12	2026-06-23 00:24:01.799599+00
16	13	2026-06-23 00:24:01.801168+00
16	16	2026-06-23 00:24:01.80269+00
16	17	2026-06-23 00:24:01.804777+00
16	20	2026-06-23 00:24:01.806193+00
16	21	2026-06-23 00:24:01.828519+00
16	22	2026-06-23 00:24:01.830515+00
16	25	2026-06-23 00:24:01.831964+00
16	26	2026-06-23 00:24:01.833366+00
16	29	2026-06-23 00:24:01.834772+00
16	32	2026-06-23 00:24:01.836154+00
16	33	2026-06-23 00:24:01.837546+00
16	35	2026-06-23 00:24:01.838885+00
16	37	2026-06-23 00:24:01.840225+00
16	39	2026-06-23 00:24:01.841623+00
16	41	2026-06-23 00:24:01.843077+00
16	44	2026-06-23 00:24:01.84569+00
16	47	2026-06-23 00:24:01.847108+00
16	46	2026-06-23 00:24:01.848745+00
41	10	2026-06-30 16:01:14.767785+00
41	13	2026-06-30 16:01:14.770791+00
41	14	2026-06-30 16:01:14.773372+00
41	17	2026-06-30 16:01:14.775662+00
41	20	2026-06-30 16:01:14.777924+00
41	21	2026-06-30 16:01:14.780764+00
41	22	2026-06-30 16:01:14.782857+00
41	25	2026-06-30 16:01:14.78503+00
41	26	2026-06-30 16:01:14.787134+00
41	29	2026-06-30 16:01:14.789226+00
41	32	2026-06-30 16:01:14.791263+00
41	33	2026-06-30 16:01:14.793548+00
41	35	2026-06-30 16:01:14.796271+00
41	37	2026-06-30 16:01:14.798474+00
41	39	2026-06-30 16:01:14.830131+00
41	41	2026-06-30 16:01:14.833044+00
41	44	2026-06-30 16:01:14.835726+00
41	45	2026-06-30 16:01:14.838123+00
41	46	2026-06-30 16:01:14.841451+00
28	3	2026-07-03 01:15:47.529912+00
28	1	2026-07-03 01:15:47.533245+00
28	5	2026-07-03 01:15:47.53547+00
28	6	2026-07-03 01:15:47.53844+00
28	10	2026-07-03 01:15:47.540842+00
28	9	2026-07-03 01:15:47.543256+00
28	13	2026-07-03 01:15:47.546302+00
28	16	2026-07-03 01:15:47.548932+00
28	17	2026-07-03 01:15:47.551164+00
28	20	2026-07-03 01:15:47.55393+00
28	22	2026-07-03 01:15:47.556394+00
28	21	2026-07-03 01:15:47.558503+00
28	26	2026-07-03 01:15:47.560669+00
28	25	2026-07-03 01:15:47.563078+00
28	32	2026-07-03 01:15:47.565939+00
28	29	2026-07-03 01:15:47.56814+00
28	33	2026-07-03 01:15:47.629736+00
28	35	2026-07-03 01:15:47.633503+00
28	37	2026-07-03 01:15:47.636037+00
28	39	2026-07-03 01:15:47.638914+00
28	41	2026-07-03 01:15:47.641292+00
28	44	2026-07-03 01:15:47.64378+00
28	45	2026-07-03 01:15:47.646349+00
28	46	2026-07-03 01:15:47.648945+00
31	26	2026-06-28 02:49:49.204719+00
31	29	2026-06-28 02:49:49.206859+00
31	32	2026-06-28 02:49:49.210721+00
31	33	2026-06-28 02:49:49.21272+00
31	34	2026-06-28 02:49:49.228737+00
31	37	2026-06-28 02:49:49.231721+00
31	38	2026-06-28 02:49:49.233938+00
31	41	2026-06-28 02:49:49.236719+00
31	44	2026-06-28 02:49:49.238678+00
31	45	2026-06-28 02:49:49.241629+00
31	46	2026-06-28 02:49:49.244727+00
34	3	2026-06-26 17:14:49.986646+00
34	1	2026-06-26 17:14:49.991304+00
34	5	2026-06-26 17:14:49.993919+00
34	6	2026-06-26 17:14:49.99818+00
34	9	2026-06-26 17:14:50.001214+00
34	10	2026-06-26 17:14:50.003339+00
34	13	2026-06-26 17:14:50.029821+00
34	14	2026-06-26 17:14:50.032751+00
34	17	2026-06-26 17:14:50.034922+00
34	20	2026-06-26 17:14:50.037049+00
34	21	2026-06-26 17:14:50.039079+00
34	22	2026-06-26 17:14:50.04142+00
34	25	2026-06-26 17:14:50.043381+00
34	26	2026-06-26 17:14:50.045558+00
34	32	2026-06-26 17:14:50.047672+00
34	29	2026-06-26 17:14:50.05013+00
34	33	2026-06-26 17:14:50.052355+00
34	35	2026-06-26 17:14:50.054922+00
34	37	2026-06-26 17:14:50.057342+00
34	39	2026-06-26 17:14:50.059602+00
34	44	2026-06-26 17:14:50.069733+00
34	41	2026-06-26 17:14:50.073722+00
34	45	2026-06-26 17:14:50.078844+00
34	46	2026-06-26 17:14:50.082829+00
25	3	2026-06-24 17:04:13.982058+00
25	1	2026-06-24 17:04:13.984401+00
25	5	2026-06-24 17:04:13.986446+00
25	6	2026-06-24 17:04:13.988383+00
25	10	2026-06-24 17:04:13.990311+00
25	9	2026-06-24 17:04:13.992371+00
25	13	2026-06-24 17:04:14.031833+00
25	14	2026-06-24 17:04:14.033995+00
25	17	2026-06-24 17:04:14.036033+00
25	20	2026-06-24 17:04:14.038073+00
25	21	2026-06-24 17:04:14.040085+00
25	22	2026-06-24 17:04:14.042044+00
25	25	2026-06-24 17:04:14.044001+00
25	26	2026-06-24 17:04:14.045911+00
25	29	2026-06-24 17:04:14.047898+00
25	32	2026-06-24 17:04:14.049769+00
25	33	2026-06-24 17:04:14.051765+00
25	34	2026-06-24 17:04:14.053728+00
25	37	2026-06-24 17:04:14.055718+00
25	40	2026-06-24 17:04:14.057693+00
25	44	2026-06-24 17:04:14.059661+00
25	41	2026-06-24 17:04:14.061634+00
25	45	2026-06-24 17:04:14.063747+00
25	46	2026-06-24 17:04:14.065723+00
35	1	2026-06-28 01:28:44.547227+00
35	4	2026-06-28 01:28:44.549658+00
35	5	2026-06-28 01:28:44.551754+00
35	6	2026-06-28 01:28:44.553729+00
35	9	2026-06-28 01:28:44.555751+00
35	10	2026-06-28 01:28:44.558007+00
35	13	2026-06-28 01:28:44.560654+00
35	16	2026-06-28 01:28:44.562766+00
35	17	2026-06-28 01:28:44.564735+00
35	20	2026-06-28 01:28:44.566651+00
35	22	2026-06-28 01:28:44.569692+00
35	23	2026-06-28 01:28:44.571607+00
35	28	2026-06-28 01:28:44.573649+00
35	25	2026-06-28 01:28:44.575726+00
35	29	2026-06-28 01:28:44.577652+00
35	32	2026-06-28 01:28:44.579628+00
35	35	2026-06-28 01:28:44.581628+00
35	33	2026-06-28 01:28:44.583631+00
35	37	2026-06-28 01:28:44.585688+00
35	38	2026-06-28 01:28:44.587952+00
35	44	2026-06-28 01:28:44.590724+00
35	41	2026-06-28 01:28:44.592783+00
35	45	2026-06-28 01:28:44.594673+00
35	46	2026-06-28 01:28:44.596654+00
40	3	2026-06-27 17:45:26.332958+00
40	4	2026-06-27 17:45:26.335445+00
40	6	2026-06-27 17:45:26.337532+00
40	8	2026-06-27 17:45:26.339723+00
40	10	2026-06-27 17:45:26.341769+00
40	9	2026-06-27 17:45:26.343797+00
40	13	2026-06-27 17:45:26.34601+00
40	14	2026-06-27 17:45:26.349138+00
40	17	2026-06-27 17:45:26.351638+00
40	20	2026-06-27 17:45:26.353743+00
40	21	2026-06-27 17:45:26.355818+00
40	22	2026-06-27 17:45:26.35777+00
40	26	2026-06-27 17:45:26.360087+00
40	28	2026-06-27 17:45:26.362128+00
40	29	2026-06-27 17:45:26.364054+00
40	30	2026-06-27 17:45:26.366143+00
40	33	2026-06-27 17:45:26.368114+00
40	35	2026-06-27 17:45:26.370438+00
40	37	2026-06-27 17:45:26.373533+00
40	39	2026-06-27 17:45:26.376977+00
40	44	2026-06-27 17:45:26.378914+00
40	41	2026-06-27 17:45:26.381042+00
40	45	2026-06-27 17:45:26.383101+00
40	46	2026-06-27 17:45:26.38526+00
36	3	2026-06-28 16:12:14.04083+00
36	1	2026-06-28 16:12:14.043357+00
36	6	2026-06-28 16:12:14.046141+00
36	8	2026-06-28 16:12:14.048507+00
36	9	2026-06-28 16:12:14.051091+00
36	10	2026-06-28 16:12:14.054094+00
36	14	2026-06-28 16:12:14.128609+00
36	13	2026-06-28 16:12:14.132578+00
36	17	2026-06-28 16:12:14.134923+00
36	20	2026-06-28 16:12:14.137932+00
36	21	2026-06-28 16:12:14.141043+00
36	23	2026-06-28 16:12:14.144111+00
36	25	2026-06-28 16:12:14.146339+00
36	26	2026-06-28 16:12:14.148552+00
36	29	2026-06-28 16:12:14.151526+00
36	32	2026-06-28 16:12:14.154236+00
36	33	2026-06-28 16:12:14.230611+00
36	34	2026-06-28 16:12:14.233937+00
36	37	2026-06-28 16:12:14.236538+00
36	39	2026-06-28 16:12:14.238763+00
36	44	2026-06-28 16:12:14.24112+00
36	41	2026-06-28 16:12:14.243576+00
36	45	2026-06-28 16:12:14.245889+00
36	47	2026-06-28 16:12:14.248008+00
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.schema_migrations (version, created_at) FROM stdin;
001_init.sql	2026-06-02 23:53:42.025725+00
002_manual_schedule.sql	2026-06-02 23:53:42.363729+00
003_user_payments.sql	2026-06-02 23:53:42.441736+00
004_official_scoring.sql	2026-06-02 23:53:42.453725+00
005_calendar_date.sql	2026-06-02 23:53:42.569263+00
006_prediction_bracket_snapshot.sql	2026-06-03 14:31:23.756819+00
007_user_active.sql	2026-06-14 21:03:40.559656+00
008_bonus_extras_manual_review.sql	2026-06-17 13:00:18.177988+00
009_match_score_multiplier.sql	2026-06-17 19:39:33.776175+00
\.


--
-- Data for Name: scoring_rules; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.scoring_rules (id, exact_score_points, outcome_points, advancing_team_points, qualified_team_points, exact_group_order_points, champion_points, top_scorer_points, best_defense_points, best_player_points, updated_at, goal_diff_points, draw_points, r8_advance_points, r8_exact_points, r4_advance_points, r4_exact_points, sf_advance_points, sf_exact_points, final_advance_points, final_exact_points, semifinalist_points, semifinalist_max_points, finalist_points, finalist_max_points, runner_up_points, third_place_points, top_assister_points, group_master_bonus, expert_day_bonus, invicto_bonus) FROM stdin;
1	5	3	8	4	3	40	25	4	4	2026-06-02 23:53:42.453725+00	2	3	8	5	12	7	18	10	40	15	10	40	20	40	20	15	20	5	10	15
\.


--
-- Data for Name: standings; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.standings (id, tournament_id, group_id, team_id, rank, points, played, won, draw, lost, goals_for, goals_against, goal_diff) FROM stdin;
17	1	5	17	1	6	3	2	0	1	10	4	6
19	1	5	19	2	6	3	2	0	1	4	2	2
20	1	5	20	3	4	3	1	1	1	2	2	0
18	1	5	18	4	1	3	0	1	2	1	9	-8
21	1	6	21	1	7	3	2	1	0	10	4	6
22	1	6	22	2	5	3	1	2	0	7	3	4
23	1	6	23	3	4	3	1	1	1	7	7	0
24	1	6	24	4	0	3	0	0	3	2	12	-10
25	1	7	25	1	5	3	1	2	0	6	2	4
4	1	1	4	4	1	3	0	1	2	2	6	-4
6	1	2	6	1	7	3	2	1	0	7	3	4
5	1	2	5	2	4	3	1	1	1	8	3	5
8	1	2	8	3	4	3	1	1	1	5	6	-1
7	1	2	7	4	1	3	0	1	2	2	10	-8
9	1	3	9	1	7	3	2	1	0	7	1	6
10	1	3	10	2	7	3	2	1	0	6	3	3
12	1	3	12	3	3	3	1	0	2	1	4	-3
11	1	3	11	4	0	3	0	0	3	2	8	-6
13	1	4	13	1	6	3	2	0	1	8	4	4
15	1	4	15	2	4	3	1	1	1	2	2	0
14	1	4	14	3	4	3	1	1	1	2	4	-2
16	1	4	16	4	3	3	1	0	2	3	5	-2
1	1	1	1	1	9	3	3	0	0	6	0	6
2	1	1	2	2	4	3	1	1	1	2	3	-1
3	1	1	3	3	3	3	1	0	2	2	3	-1
26	1	7	26	2	5	3	1	2	0	5	3	2
27	1	7	27	3	3	3	0	3	0	3	3	0
28	1	7	28	4	1	3	0	1	2	4	10	-6
29	1	8	29	1	7	3	2	1	0	5	0	5
30	1	8	30	2	3	3	0	3	0	2	2	0
32	1	8	32	3	2	3	0	2	1	3	4	-1
31	1	8	31	4	2	3	0	2	1	1	5	-4
33	1	9	33	1	9	3	3	0	0	10	2	8
35	1	9	35	2	6	3	2	0	1	8	7	1
34	1	9	34	3	3	3	1	0	2	8	6	2
36	1	9	36	4	0	3	0	0	3	1	12	-11
37	1	10	37	1	9	3	3	0	0	8	1	7
39	1	10	39	2	4	3	1	1	1	6	6	0
38	1	10	38	3	4	3	1	1	1	5	7	-2
40	1	10	40	4	0	3	0	0	3	3	8	-5
44	1	11	44	1	7	3	2	1	0	4	1	3
41	1	11	41	2	5	3	1	2	0	6	1	5
42	1	11	42	3	4	3	1	1	1	4	3	1
43	1	11	43	4	0	3	0	0	3	2	11	-9
45	1	12	45	1	7	3	2	1	0	6	2	4
46	1	12	46	2	6	3	2	0	1	5	5	0
47	1	12	47	3	4	3	1	1	1	2	2	0
48	1	12	48	4	0	3	0	0	3	0	4	-4
\.


--
-- Data for Name: sync_runs; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.sync_runs (id, started_at, finished_at, status, details) FROM stdin;
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.teams (id, external_id, name, short_name, logo_url, created_at) FROM stdin;
1	wc2026-team-mexico	México	MEX	https://flagcdn.com/w80/mx.png	2026-06-03 00:43:14.287377+00
2	wc2026-team-sudafrica	Sudáfrica	SUD	https://flagcdn.com/w80/za.png	2026-06-03 00:43:14.289973+00
3	wc2026-team-corea-del-sur	Corea del Sur	KOR	https://flagcdn.com/w80/kr.png	2026-06-03 00:43:14.292216+00
4	wc2026-team-republica-checa	República Checa	CZE	https://flagcdn.com/w80/cz.png	2026-06-03 00:43:14.294427+00
5	wc2026-team-canada	Canadá	CAN	https://flagcdn.com/w80/ca.png	2026-06-03 00:43:14.296758+00
6	wc2026-team-suiza	Suiza	SUI	https://flagcdn.com/w80/ch.png	2026-06-03 00:43:14.329959+00
7	wc2026-team-catar	Catar	CAT	https://flagcdn.com/w80/qa.png	2026-06-03 00:43:14.332425+00
8	wc2026-team-bosnia-y-herzegovina	Bosnia y Herzegovina	BIH	https://flagcdn.com/w80/ba.png	2026-06-03 00:43:14.334768+00
9	wc2026-team-brasil	Brasil	BRA	https://flagcdn.com/w80/br.png	2026-06-03 00:43:14.337044+00
10	wc2026-team-marruecos	Marruecos	MAR	https://flagcdn.com/w80/ma.png	2026-06-03 00:43:14.339225+00
11	wc2026-team-haiti	Haití	HAI	https://flagcdn.com/w80/ht.png	2026-06-03 00:43:14.341508+00
12	wc2026-team-escocia	Escocia	ESC	https://flagcdn.com/w80/gb-sct.png	2026-06-03 00:43:14.343793+00
13	wc2026-team-estados-unidos	Estados Unidos	USA	https://flagcdn.com/w80/us.png	2026-06-03 00:43:14.345966+00
14	wc2026-team-paraguay	Paraguay	PAR	https://flagcdn.com/w80/py.png	2026-06-03 00:43:14.348071+00
15	wc2026-team-australia	Australia	AUS	https://flagcdn.com/w80/au.png	2026-06-03 00:43:14.350258+00
16	wc2026-team-turquia	Turquía	TUR	https://flagcdn.com/w80/tr.png	2026-06-03 00:43:14.352501+00
17	wc2026-team-alemania	Alemania	ALE	https://flagcdn.com/w80/de.png	2026-06-03 00:43:14.354822+00
18	wc2026-team-curazao	Curazao	CUR	https://flagcdn.com/w80/cw.png	2026-06-03 00:43:14.357172+00
19	wc2026-team-costa-de-marfil	Costa de Marfil	CIV	https://flagcdn.com/w80/ci.png	2026-06-03 00:43:14.359554+00
20	wc2026-team-ecuador	Ecuador	ECU	https://flagcdn.com/w80/ec.png	2026-06-03 00:43:14.361709+00
21	wc2026-team-paises-bajos	Países Bajos	NED	https://flagcdn.com/w80/nl.png	2026-06-03 00:43:14.364005+00
22	wc2026-team-japon	Japón	JAP	https://flagcdn.com/w80/jp.png	2026-06-03 00:43:14.366202+00
23	wc2026-team-suecia	Suecia	SUE	https://flagcdn.com/w80/se.png	2026-06-03 00:43:14.368957+00
24	wc2026-team-tunez	Túnez	TÚN	https://flagcdn.com/w80/tn.png	2026-06-03 00:43:14.371349+00
25	wc2026-team-belgica	Bélgica	BÉL	https://flagcdn.com/w80/be.png	2026-06-03 00:43:14.374181+00
26	wc2026-team-egipto	Egipto	EGI	https://flagcdn.com/w80/eg.png	2026-06-03 00:43:14.376523+00
27	wc2026-team-iran	Irán	IRÁ	https://flagcdn.com/w80/ir.png	2026-06-03 00:43:14.3788+00
28	wc2026-team-nueva-zelanda	Nueva Zelanda	NZL	https://flagcdn.com/w80/nz.png	2026-06-03 00:43:14.381298+00
29	wc2026-team-espana	España	ESP	https://flagcdn.com/w80/es.png	2026-06-03 00:43:14.38356+00
30	wc2026-team-cabo-verde	Cabo Verde	CAB	https://flagcdn.com/w80/cv.png	2026-06-03 00:43:14.385893+00
31	wc2026-team-arabia-saudita	Arabia Saudita	KSA	https://flagcdn.com/w80/sa.png	2026-06-03 00:43:14.388202+00
32	wc2026-team-uruguay	Uruguay	URU	https://flagcdn.com/w80/uy.png	2026-06-03 00:43:14.390423+00
33	wc2026-team-francia	Francia	FRA	https://flagcdn.com/w80/fr.png	2026-06-03 00:43:14.392844+00
34	wc2026-team-senegal	Senegal	SEN	https://flagcdn.com/w80/sn.png	2026-06-03 00:43:14.395125+00
35	wc2026-team-noruega	Noruega	NOR	https://flagcdn.com/w80/no.png	2026-06-03 00:43:14.397345+00
36	wc2026-team-irak	Irak	IRA	https://flagcdn.com/w80/iq.png	2026-06-03 00:43:14.399612+00
37	wc2026-team-argentina	Argentina	ARG	https://flagcdn.com/w80/ar.png	2026-06-03 00:43:14.401916+00
38	wc2026-team-argelia	Argelia	ARG	https://flagcdn.com/w80/dz.png	2026-06-03 00:43:14.404172+00
39	wc2026-team-austria	Austria	AUS	https://flagcdn.com/w80/at.png	2026-06-03 00:43:14.406425+00
40	wc2026-team-jordania	Jordania	JOR	https://flagcdn.com/w80/jo.png	2026-06-03 00:43:14.408788+00
41	wc2026-team-portugal	Portugal	POR	https://flagcdn.com/w80/pt.png	2026-06-03 00:43:14.411005+00
42	wc2026-team-rd-congo	RD Congo	COD	https://flagcdn.com/w80/cd.png	2026-06-03 00:43:14.41319+00
43	wc2026-team-uzbekistan	Uzbekistán	UZB	https://flagcdn.com/w80/uz.png	2026-06-03 00:43:14.415651+00
44	wc2026-team-colombia	Colombia	COL	https://flagcdn.com/w80/co.png	2026-06-03 00:43:14.417991+00
45	wc2026-team-inglaterra	Inglaterra	ENG	https://flagcdn.com/w80/gb-eng.png	2026-06-03 00:43:14.420211+00
46	wc2026-team-croacia	Croacia	CRO	https://flagcdn.com/w80/hr.png	2026-06-03 00:43:14.423002+00
47	wc2026-team-ghana	Ghana	GHA	https://flagcdn.com/w80/gh.png	2026-06-03 00:43:14.425229+00
48	wc2026-team-panama	Panamá	PAN	https://flagcdn.com/w80/pa.png	2026-06-03 00:43:14.427499+00
49	wc2026-tbd	Por definir	TBD	\N	2026-06-28 02:14:57.303533+00
\.


--
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.tournaments (id, name, external_id, season, created_at) FROM stdin;
1	Mundial FIFA 2026	wc-2026	2026	2026-06-03 00:43:14.28455+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: polla
--

COPY public.users (id, email, password_hash, role, created_at, display_name, amount_paid, payment_notes, is_active) FROM stdin;
17	3042503496	$2b$10$F.DfMAhQXTvZVM3yw2gFWOs5ddRY0F.7ACf5qMZUnq9lkSz7Aqu5G	USER	2026-06-03 14:22:24.253474+00	Daniel sanchez 	0.00	\N	f
10	3206185693	$2b$10$Wg34TF2BoYxr0rL7XUMztel8wXA8Wbqi0vcwTxPi5TtTc3Kli.e72	USER	2026-06-03 12:37:44.254039+00	Andres Cardona 	50000.00	\N	t
9	3208919987	$2b$10$fjcaNYgowsBUt82NtEsc0ea8bwVwNFYf8D4JYRWrNJT1s.U8Tbfz2	USER	2026-06-03 12:18:12.058301+00	Felipe Florez	50000.00	\N	t
24	3148962815	$2b$10$dZ4qDpnWyiRsEgq0RzHOuOoiFCqaIYtqjn2kw8GRiWGpHL1Vy7v5.	USER	2026-06-04 20:19:50.22893+00	Mario Duque 	50000.00	\N	t
15	3108279341	$2b$10$sFdarv0Lqq.fTYZ4skK4DeOsaCrFgG5R2BUiRzcac6wrXpUWa2Dk2	USER	2026-06-03 13:37:01.690198+00	Jorge zuleta 	50000.00	\N	t
44	3103805180	$2b$10$BmurDENZgyNPykyvWaRCMe3VmXYCXGD9YhwDJrU89V.1mSaW0Leku	USER	2026-06-11 21:47:45.133186+00	Esteban Loaiza 	20000.00	\N	t
27	3218481877	$2b$10$g/61qyJFpw2Lc6FKtv/c9uA6qXvQzEzvBiQ/H8TkiQ055s2oZ7U9u	USER	2026-06-05 22:09:48.356052+00	Andrés Ospina 	0.00	\N	t
55	3128418975	$2b$10$mBNvclylSQ/YvsUrDUKriu5OsMeRdBLoyL5R4w3Kh8yJR8lH98Cri	USER	2026-06-12 18:57:36.205735+00	Angela ortiz	50000.00	\N	t
33	3145564742	$2b$10$0C9A.LZ/JGxNFCT.ZEaC.eY69btplYtsZbcU/O9kOnicxE.RE6Hbq	USER	2026-06-11 18:57:31.539047+00	Sebastián garzon	50000.00	\N	t
26	3147334115	$2b$10$YMNwpakOVSHoClUQdtN.8.QZdHMEvDnjUTS9U0sdwlf5y.p2/p7Ta	USER	2026-06-05 02:12:01.559731+00	Felipe Gómez 	50000.00	\N	t
28	3002178818	$2b$10$4qZNtN3if/L802SLezkFiu0thtSKBZRje.cFMdLGnb6YEHVLJpS12	USER	2026-06-11 18:08:09.053683+00	Felipe Leal	50000.00	\N	t
31	3116300205	$2b$10$rX8cu7aLhICG1VV0hq0yP.gJObTjYrCNiLnEiHz4iisKmDeMZjmNa	USER	2026-06-11 18:56:31.273811+00	Wilson murillo	50000.00	\N	t
45	3174977821	$2b$10$DalG0BCxpyNtvz/HDapvhOU/M0tHdO3XnqMJtBYqSjwKyxLdHJJ4m	USER	2026-06-11 22:24:39.012912+00	Diana Vera	50000.00	\N	t
35	3007416786	$2b$10$kFI.zh7lCegPy4fsYKOd9e5zJORApSbkxhx9B8uXVqKp9l4NP36RK	USER	2026-06-11 19:11:32.526414+00	Anderson Duque Baena	50000.00	\N	t
11	3128740361	$2b$10$lnxQ8N5rKa5RJBOMG/C9WeMhBm9Bk2OnMERW461lEZCd/hQ8nfdW6	USER	2026-06-03 12:50:18.895426+00	Christian Diseño	50000.00	\N	t
29	3184731866	$2b$10$P2ZHcr7lgY1CTbgwWcs3Jumo3uoCMwq5lXofJpifZxDpaddaHfaQi	USER	2026-06-11 18:53:13.146355+00	David Arias 	50000.00	\N	t
42	3144457638	$2b$10$.dWEW40wXuawVo0lILdab.lQmCdIoysccHdKlAc/LFoN/kEqUdRLi	USER	2026-06-11 20:55:18.745006+00	Luis Fernando Paez	50000.00	\N	t
34	3103740017	$2b$10$nUgA8wk5m8IGy.xpcOb9GuIqYsutGSMW16UhZ5BKmdm93Ik6wzAta	USER	2026-06-11 19:07:37.642271+00	John Escobar	50000.00	\N	t
39	3127043440	$2b$10$Sb8uDBtUUQSUnKz3/nxxnu2uRKv0TMc4GYORhjsE8ZZSE7VeP8PW.	USER	2026-06-11 19:31:50.953417+00	Javier Giraldo	0.00	\N	f
43	3122741411	$2b$10$8HrxTsuFyByh9RD7YZE37urEgzm4XDpMHvVBLCqbWqcHyJReEnBXO	USER	2026-06-11 21:26:24.624293+00	Bryan Alexis Murcia Bocanegra 	50000.00	\N	t
56	3217022835	$2b$10$PG2JqWF1uTF4Q4/i.VtVCu.3oDbJYcJtM6uEmSFVF17feYuhoVO/W	USER	2026-06-12 19:45:24.40919+00	Laura María Arango 	50000.00	\N	t
58	3117201788	$2b$10$pF4ZkjY2JEIs8lxDeG5RA.42YNavl0t7iAVX/EULBwmwKPP2Qac2e	USER	2026-06-13 15:41:47.507724+00	Diana Arango	50000.00	\N	t
48	3145156187	$2b$10$MjJP.iq8rtSZ0DcSXCbNmewx.jcPI9Ye.fDncfewn4PppqacA5Uua	USER	2026-06-12 01:48:50.638289+00	Edilberto Bañol 	50000.00	\N	t
1	1000000001	$2b$10$boi6ZUL/1eOzYyH90VsUvembrYpsU9cxwX5v3Q6UwtwhE6beIyfc2	ADMIN	2026-06-02 23:53:43.268733+00	-	0.00	\N	t
41	3104232941	$2b$10$GpKYeFb1rdoSuh/2e.cXbeU8PVzwOwkyKfdXCE3lCn1cbBbFIORda	USER	2026-06-11 20:07:47.027351+00	Lorena Grisales	50000.00	\N	t
36	3168694905	$2b$10$ZZR0yL1A2s5DtOCPqngaS.hLeFIO0aInOyhaEbz5lTfKUbzqEp/r6	USER	2026-06-11 19:19:29.216653+00	Luz mila	50000.00	\N	t
13	3128365605	$2b$10$i4WeOqGhI1mCE3sD43W8ae/tlqnVM3pzD1xiEEtH9L6kGTbqO834O	USER	2026-06-03 13:14:54.160189+00	Julian trejos 	50000.00	\N	t
46	3102728996	$2b$10$j9fu/tB0Md0i88Sh/oJBU.FXuV28gUB3XgzrZTClxFb3upbCNfPUa	USER	2026-06-11 23:39:23.221552+00	Mateo pineda	20000.00	\N	t
16	315828330	$2b$10$DcuJWTKxBsnoY4e2dceBI.SHEMPT0AtwPhRYFwvUQMKyJc0OAd4gS	USER	2026-06-03 13:47:57.95461+00	Brandon Arboleda 	47976.00	\N	f
12	3145974905	$2b$10$HuOTSN3VGOBYVqLybbPYdeYFIdtg7Djex7DnsK/K7cnL8V1uolIXC	USER	2026-06-03 12:55:17.258134+00	Leche	50000.00	\N	t
37	3504767153	$2b$10$CgKyuHuewXCwlJmm5Byk2OebwkATMHjzCOaKsVtBE2IH0GOIqxInq	USER	2026-06-11 19:21:22.812038+00	José garcia	50000.00	\N	t
66	3165837914	$2b$10$MZMUfFSeVBn5d.zT2.yMUOjFWHZ93oDDky45jN26iApos2FpDNHAu	USER	2026-06-14 22:58:06.451543+00	Pablo garzon	30000.00	\N	t
30	3126010320	$2b$10$eaop6VzVE83dszc0bCZz0.5MnA8LkhkVFxr1eTrqf28giJzoa5.0m	USER	2026-06-11 18:54:58.71815+00	Valeria toro	50000.00	\N	t
38	3207381772	$2b$10$iOH4e.tb/bMEE74JCqFnK.0.O7kkpm4A6RZTGrMBbEQln.9mv4zsK	USER	2026-06-11 19:23:37.280061+00	Nora Lucia	50000.00	\N	t
51	3136384155	$2b$10$Sm8rzNIDGdRcLCkOYvtKZebEn/IQv4p3PwTBCFz3h19XEzGzTkumK	USER	2026-06-12 14:09:11.778569+00	Samuel Naranjo	50000.00	\N	t
54	3148752382	$2b$10$Re8pg9tCeUqHA5kjCR77NegsSJPnxMV.N/tL5HLpM5F.YnjEXKrn2	USER	2026-06-12 17:27:04.221588+00	Alejandro Henao	50000.00	\N	t
18	3015217555	$2b$10$HaPf2nmuO/n0J/62t3GNgutruwn8LlTqeF3M8uwBKHE1Vd17Uis3e	USER	2026-06-03 14:27:18.053774+00	Richard Escalante	20000.00	\N	f
25	3117776250	$2b$10$ZdFL/vRmao10xT/jzXxisuN5X1L.ZwWCQZuLxOaKqB/9RWyEXBRS.	USER	2026-06-04 20:46:50.681186+00	Camilo Rodriguez	20000.00	\N	t
14	3135444351	$2b$10$v2pi6tAOOZkc2y.EGtTZVOhwiiFZZOn8CcnuRN8gPaRmWwr10FQaC	USER	2026-06-03 13:27:39.855212+00	Jhon velez 	20000.00	\N	t
23	3136561494	$2b$10$2EHnUdZ0vD6ugSIRd5gugeHi3u/NgGWqdLmgTIY6zOFYwOOtWBYHO	USER	2026-06-03 21:05:36.83872+00	Marlon Valencia 	50000.00	\N	t
50	3145717731	$2b$10$/MT4d5dot52gr6r/DYVIkOIU2Xbdg/pJ/76eqoRTTYLhX2Io1FOvG	USER	2026-06-12 13:20:06.393549+00	Eliana Osorio	50000.00	\N	t
59	3045263963	$2b$10$tMZtYJ6UayMiCXhgciXcneV6QtjKpuTiHrpDbnBlFuSGPYsbGi55m	USER	2026-06-13 15:44:20.9122+00	Daniela Amaya	50000.00	\N	t
40	3017843241	$2b$10$yHuoKVXEnfaL7QN7a3j6FuQGjZ2fK/pARDNA6UJaEgi2dLftaXfx2	USER	2026-06-11 20:02:28.136357+00	Lina Rico	50000.00	\N	t
68	3178954812	$2b$10$8NNnI2rnUt4FIRjQVA4RQeIJ3ZWM/jM6N/w51G13kOtbKISCOmyj2	USER	2026-06-17 17:06:12.491863+00	Daniel Parra	25000.00	\N	t
47	3137705632	$2b$10$.FW78nZ7hG.Nlg9XVaOvCOwAYTU3GUJEW1qmMFHGknBCZJf/3.em.	USER	2026-06-12 00:25:58.224376+00	Julio Garzon	50000.00	\N	t
32	3175248356	$2b$10$vlwigaJXdlzD78F9ivigluxyvOLZ.O9pk0ayIbEktz3yzur2KakCG	USER	2026-06-11 18:56:56.637741+00	Norma henao	50000.00	\N	t
\.


--
-- Name: bonus_predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.bonus_predictions_id_seq', 9890, true);


--
-- Name: group_predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.group_predictions_id_seq', 1, false);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.groups_id_seq', 12, true);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.matches_id_seq', 104, true);


--
-- Name: prediction_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.prediction_scores_id_seq', 13980, true);


--
-- Name: predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.predictions_id_seq', 6450, true);


--
-- Name: scoring_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.scoring_rules_id_seq', 1, false);


--
-- Name: standings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.standings_id_seq', 48, true);


--
-- Name: sync_runs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.sync_runs_id_seq', 1, false);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.teams_id_seq', 49, true);


--
-- Name: tournaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.tournaments_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: polla
--

SELECT pg_catalog.setval('public.users_id_seq', 84, true);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (key);


--
-- Name: bonus_predictions bonus_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions
    ADD CONSTRAINT bonus_predictions_pkey PRIMARY KEY (id);


--
-- Name: bonus_predictions bonus_predictions_user_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions
    ADD CONSTRAINT bonus_predictions_user_id_key UNIQUE (user_id);


--
-- Name: group_predictions group_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.group_predictions
    ADD CONSTRAINT group_predictions_pkey PRIMARY KEY (id);


--
-- Name: group_predictions group_predictions_user_id_group_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.group_predictions
    ADD CONSTRAINT group_predictions_user_id_group_id_key UNIQUE (user_id, group_id);


--
-- Name: groups groups_external_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_external_id_key UNIQUE (external_id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: matches matches_external_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_external_id_key UNIQUE (external_id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: prediction_scores prediction_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.prediction_scores
    ADD CONSTRAINT prediction_scores_pkey PRIMARY KEY (id);


--
-- Name: prediction_scores prediction_scores_user_id_source_type_source_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.prediction_scores
    ADD CONSTRAINT prediction_scores_user_id_source_type_source_id_key UNIQUE (user_id, source_type, source_id);


--
-- Name: predictions predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (id);


--
-- Name: predictions predictions_user_id_match_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_user_id_match_id_key UNIQUE (user_id, match_id);


--
-- Name: qualifier_predictions qualifier_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.qualifier_predictions
    ADD CONSTRAINT qualifier_predictions_pkey PRIMARY KEY (user_id, team_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scoring_rules scoring_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.scoring_rules
    ADD CONSTRAINT scoring_rules_pkey PRIMARY KEY (id);


--
-- Name: standings standings_group_id_team_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_group_id_team_id_key UNIQUE (group_id, team_id);


--
-- Name: standings standings_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_pkey PRIMARY KEY (id);


--
-- Name: sync_runs sync_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.sync_runs
    ADD CONSTRAINT sync_runs_pkey PRIMARY KEY (id);


--
-- Name: teams teams_external_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_external_id_key UNIQUE (external_id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tournaments tournaments_external_id_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_external_id_key UNIQUE (external_id);


--
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_matches_calendar_date; Type: INDEX; Schema: public; Owner: polla
--

CREATE INDEX idx_matches_calendar_date ON public.matches USING btree (tournament_id, calendar_date);


--
-- Name: matches_external_id_unique; Type: INDEX; Schema: public; Owner: polla
--

CREATE UNIQUE INDEX matches_external_id_unique ON public.matches USING btree (external_id) WHERE (external_id IS NOT NULL);


--
-- Name: matches_stage_idx; Type: INDEX; Schema: public; Owner: polla
--

CREATE INDEX matches_stage_idx ON public.matches USING btree (stage);


--
-- Name: matches_starts_at_idx; Type: INDEX; Schema: public; Owner: polla
--

CREATE INDEX matches_starts_at_idx ON public.matches USING btree (starts_at);


--
-- Name: bonus_predictions bonus_predictions_best_defense_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions
    ADD CONSTRAINT bonus_predictions_best_defense_team_id_fkey FOREIGN KEY (best_defense_team_id) REFERENCES public.teams(id);


--
-- Name: bonus_predictions bonus_predictions_champion_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions
    ADD CONSTRAINT bonus_predictions_champion_team_id_fkey FOREIGN KEY (champion_team_id) REFERENCES public.teams(id);


--
-- Name: bonus_predictions bonus_predictions_runner_up_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions
    ADD CONSTRAINT bonus_predictions_runner_up_team_id_fkey FOREIGN KEY (runner_up_team_id) REFERENCES public.teams(id);


--
-- Name: bonus_predictions bonus_predictions_third_place_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions
    ADD CONSTRAINT bonus_predictions_third_place_team_id_fkey FOREIGN KEY (third_place_team_id) REFERENCES public.teams(id);


--
-- Name: bonus_predictions bonus_predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.bonus_predictions
    ADD CONSTRAINT bonus_predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: group_predictions group_predictions_first_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.group_predictions
    ADD CONSTRAINT group_predictions_first_team_id_fkey FOREIGN KEY (first_team_id) REFERENCES public.teams(id);


--
-- Name: group_predictions group_predictions_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.group_predictions
    ADD CONSTRAINT group_predictions_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_predictions group_predictions_second_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.group_predictions
    ADD CONSTRAINT group_predictions_second_team_id_fkey FOREIGN KEY (second_team_id) REFERENCES public.teams(id);


--
-- Name: group_predictions group_predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.group_predictions
    ADD CONSTRAINT group_predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups groups_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: matches matches_away_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_away_team_id_fkey FOREIGN KEY (away_team_id) REFERENCES public.teams(id);


--
-- Name: matches matches_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: matches matches_home_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_home_team_id_fkey FOREIGN KEY (home_team_id) REFERENCES public.teams(id);


--
-- Name: matches matches_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id);


--
-- Name: matches matches_winner_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_winner_team_id_fkey FOREIGN KEY (winner_team_id) REFERENCES public.teams(id);


--
-- Name: prediction_scores prediction_scores_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.prediction_scores
    ADD CONSTRAINT prediction_scores_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: predictions predictions_bracket_away_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_bracket_away_team_id_fkey FOREIGN KEY (bracket_away_team_id) REFERENCES public.teams(id);


--
-- Name: predictions predictions_bracket_home_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_bracket_home_team_id_fkey FOREIGN KEY (bracket_home_team_id) REFERENCES public.teams(id);


--
-- Name: predictions predictions_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id) ON DELETE CASCADE;


--
-- Name: predictions predictions_predicted_advancing_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_predicted_advancing_team_id_fkey FOREIGN KEY (predicted_advancing_team_id) REFERENCES public.teams(id);


--
-- Name: predictions predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: qualifier_predictions qualifier_predictions_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.qualifier_predictions
    ADD CONSTRAINT qualifier_predictions_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: qualifier_predictions qualifier_predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.qualifier_predictions
    ADD CONSTRAINT qualifier_predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: standings standings_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: standings standings_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: standings standings_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: polla
--

ALTER TABLE ONLY public.standings
    ADD CONSTRAINT standings_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON SEQUENCES TO polla;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES TO polla;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON FUNCTIONS TO polla;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES TO polla;


--
-- PostgreSQL database dump complete
--

\unrestrict ikGexjEfnbAEuB3i0nlvH7KjYspW3Au0sxefKDhNZAlxkVjd2wOhl4Ldr25St1y

