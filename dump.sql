--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name text NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    goal numeric NOT NULL,
    about text NOT NULL,
    headline text NOT NULL,
    video_url text,
    short_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    about_html text,
    recommended boolean DEFAULT false,
    home_page_comment text,
    permalink text NOT NULL,
    video_thumbnail text,
    state character varying(255),
    online_days integer DEFAULT 0,
    online_date timestamp with time zone,
    how_know text,
    more_links text,
    first_backers text,
    uploaded_image character varying(255),
    video_embed_url character varying(255),
    govid character varying(255),
    paypal character varying(255),
    stripe_userid character varying(255),
    stripe_access_token character varying(255),
    stripe_key character varying(255),
    currency character varying(255),
    CONSTRAINT projects_about_not_blank CHECK ((length(btrim(about)) > 0)),
    CONSTRAINT projects_headline_length_within CHECK (((length(headline) >= 1) AND (length(headline) <= 140))),
    CONSTRAINT projects_headline_not_blank CHECK ((length(btrim(headline)) > 0))
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: expires_at(projects); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION expires_at(projects) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
     SELECT ((((($1.online_date AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo') + ($1.online_days || ' days')::interval)  )::date::text || ' 23:59:59')::timestamp AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo'))::timestamptz )               
    $_$;


ALTER FUNCTION public.expires_at(projects) OWNER TO postgres;

--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE authorizations (
    id integer NOT NULL,
    oauth_provider_id integer NOT NULL,
    user_id integer NOT NULL,
    uid text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.authorizations OWNER TO postgres;

--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.authorizations_id_seq OWNER TO postgres;

--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE authorizations_id_seq OWNED BY authorizations.id;


--
-- Name: backers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE backers (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer,
    value numeric NOT NULL,
    confirmed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    anonymous boolean DEFAULT false,
    key text,
    credits boolean DEFAULT false,
    notified_finish boolean DEFAULT false,
    payment_method text,
    payment_token text,
    payment_id character varying(255),
    payer_name text,
    payer_email text,
    payer_document text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_zip_code text,
    address_city text,
    address_state text,
    address_phone_number text,
    payment_choice text,
    payment_service_fee numeric,
    state character varying(255),
    CONSTRAINT backers_value_positive CHECK ((value >= (0)::numeric))
);


ALTER TABLE public.backers OWNER TO postgres;

--
-- Name: rewards; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    project_id integer NOT NULL,
    minimum_value numeric NOT NULL,
    maximum_backers integer,
    description text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reindex_versions timestamp without time zone,
    row_order integer,
    days_to_delivery integer,
    CONSTRAINT rewards_maximum_backers_positive CHECK ((maximum_backers >= 0)),
    CONSTRAINT rewards_minimum_value_positive CHECK ((minimum_value >= (0)::numeric))
);


ALTER TABLE public.rewards OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email text,
    name text,
    nickname text,
    bio text,
    image_url text,
    newsletter boolean DEFAULT false,
    project_updates boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    full_name text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_city text,
    address_state text,
    address_zip_code text,
    phone_number text,
    locale text DEFAULT 'pt'::text NOT NULL,
    cpf text,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    twitter character varying(255),
    facebook_link character varying(255),
    other_link character varying(255),
    uploaded_image text,
    moip_login character varying(255),
    state_inscription character varying(255),
    stripe_key character varying(255),
    stripe_userid character varying(255),
    stripe_access_token character varying(255),
    favourite_id integer,
    CONSTRAINT users_bio_length_within CHECK (((length(bio) >= 0) AND (length(bio) <= 140)))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: backer_reports; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW backer_reports AS
    SELECT b.project_id, u.name, b.value, r.minimum_value, r.description, b.payment_method, b.payment_choice, b.payment_service_fee, b.key, (b.created_at)::date AS created_at, (b.confirmed_at)::date AS confirmed_at, u.email, b.payer_email, b.payer_name, COALESCE(b.payer_document, u.cpf) AS cpf, u.address_street, u.address_complement, u.address_number, u.address_neighbourhood, u.address_city, u.address_state, u.address_zip_code, b.state FROM ((backers b JOIN users u ON ((u.id = b.user_id))) LEFT JOIN rewards r ON ((r.id = b.reward_id))) WHERE ((b.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text]));


ALTER TABLE public.backer_reports OWNER TO postgres;

--
-- Name: configurations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE configurations (
    id integer NOT NULL,
    name text NOT NULL,
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT configurations_name_not_blank CHECK ((length(btrim(name)) > 0))
);


ALTER TABLE public.configurations OWNER TO postgres;

--
-- Name: backer_reports_for_project_owners; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW backer_reports_for_project_owners AS
    SELECT b.project_id, COALESCE(r.id, 0) AS reward_id, r.description AS reward_description, (b.confirmed_at)::date AS confirmed_at, b.value AS back_value, (b.value * (SELECT (configurations.value)::numeric AS value FROM configurations WHERE (configurations.name = 'catarse_fee'::text))) AS service_fee, u.email AS user_email, u.name AS user_name, b.payer_email, b.payment_method, COALESCE(b.address_street, u.address_street) AS street, COALESCE(b.address_complement, u.address_complement) AS complement, COALESCE(b.address_number, u.address_number) AS address_number, COALESCE(b.address_neighbourhood, u.address_neighbourhood) AS neighbourhood, COALESCE(b.address_city, u.address_city) AS city, COALESCE(b.address_state, u.address_state) AS state, COALESCE(b.address_zip_code, u.address_zip_code) AS zip_code, b.anonymous FROM ((backers b JOIN users u ON ((u.id = b.user_id))) LEFT JOIN rewards r ON ((r.id = b.reward_id))) WHERE ((b.state)::text = 'confirmed'::text);


ALTER TABLE public.backer_reports_for_project_owners OWNER TO postgres;

--
-- Name: backers_by_periods; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW backers_by_periods AS
    WITH weeks AS (SELECT (generate_series.generate_series * 7) AS days FROM generate_series(0, 7) generate_series(generate_series)), current_period AS (SELECT 'current_period'::text AS series, sum(b.value) AS sum, (w.days / 7) AS week FROM (backers b RIGHT JOIN weeks w ON ((((b.confirmed_at)::date >= ((('now'::text)::date - w.days) - 7)) AND (b.confirmed_at < (('now'::text)::date - w.days))))) WHERE ((b.state)::text <> ALL (ARRAY[('pending'::character varying)::text, ('canceled'::character varying)::text, ('waiting_confirmation'::character varying)::text, ('deleted'::character varying)::text])) GROUP BY (w.days / 7)), previous_period AS (SELECT 'previous_period'::text AS series, sum(b.value) AS sum, (w.days / 7) AS week FROM (backers b RIGHT JOIN weeks w ON ((((b.confirmed_at)::date >= (((('now'::text)::date - w.days) - 7) - 56)) AND (b.confirmed_at < ((('now'::text)::date - w.days) - 56))))) WHERE ((b.state)::text <> ALL (ARRAY[('pending'::character varying)::text, ('canceled'::character varying)::text, ('waiting_confirmation'::character varying)::text, ('deleted'::character varying)::text])) GROUP BY (w.days / 7)), last_year AS (SELECT 'last_year'::text AS series, sum(b.value) AS sum, (w.days / 7) AS week FROM (backers b RIGHT JOIN weeks w ON ((((b.confirmed_at)::date >= (((('now'::text)::date - w.days) - 7) - 365)) AND (b.confirmed_at < ((('now'::text)::date - w.days) - 365))))) WHERE ((b.state)::text <> ALL (ARRAY[('pending'::character varying)::text, ('canceled'::character varying)::text, ('waiting_confirmation'::character varying)::text, ('deleted'::character varying)::text])) GROUP BY (w.days / 7)) (SELECT current_period.series, current_period.sum, current_period.week FROM current_period UNION ALL SELECT previous_period.series, previous_period.sum, previous_period.week FROM previous_period) UNION ALL SELECT last_year.series, last_year.sum, last_year.week FROM last_year ORDER BY 1, 3;


ALTER TABLE public.backers_by_periods OWNER TO postgres;

--
-- Name: backers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE backers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.backers_id_seq OWNER TO postgres;

--
-- Name: backers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE backers_id_seq OWNED BY backers.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name_pt text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name_en character varying(255),
    CONSTRAINT categories_name_not_blank CHECK ((length(btrim(name_pt)) > 0))
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE channels (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    permalink character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    twitter character varying(255),
    facebook character varying(255),
    email character varying(255),
    image character varying(255),
    website character varying(255)
);


ALTER TABLE public.channels OWNER TO postgres;

--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.channels_id_seq OWNER TO postgres;

--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE channels_id_seq OWNED BY channels.id;


--
-- Name: channels_projects; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE channels_projects (
    id integer NOT NULL,
    channel_id integer,
    project_id integer
);


ALTER TABLE public.channels_projects OWNER TO postgres;

--
-- Name: channels_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE channels_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.channels_projects_id_seq OWNER TO postgres;

--
-- Name: channels_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE channels_projects_id_seq OWNED BY channels_projects.id;


--
-- Name: channels_subscribers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE channels_subscribers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    channel_id integer NOT NULL
);


ALTER TABLE public.channels_subscribers OWNER TO postgres;

--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE channels_subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.channels_subscribers_id_seq OWNER TO postgres;

--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE channels_subscribers_id_seq OWNED BY channels_subscribers.id;


--
-- Name: channels_trustees; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE channels_trustees (
    id integer NOT NULL,
    user_id integer,
    channel_id integer
);


ALTER TABLE public.channels_trustees OWNER TO postgres;

--
-- Name: channels_trustees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE channels_trustees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.channels_trustees_id_seq OWNER TO postgres;

--
-- Name: channels_trustees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE channels_trustees_id_seq OWNED BY channels_trustees.id;


--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.configurations_id_seq OWNER TO postgres;

--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE configurations_id_seq OWNED BY configurations.id;


--
-- Name: favourites; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE favourites (
    id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    state text
);


ALTER TABLE public.favourites OWNER TO postgres;

--
-- Name: favourites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE favourites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.favourites_id_seq OWNER TO postgres;

--
-- Name: favourites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE favourites_id_seq OWNED BY favourites.id;


--
-- Name: financial_reports; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW financial_reports AS
    SELECT p.name, u.moip_login, p.goal, expires_at(p.*) AS expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));


ALTER TABLE public.financial_reports OWNER TO postgres;

--
-- Name: notification_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE notification_types (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    layout text DEFAULT 'email'::text NOT NULL
);


ALTER TABLE public.notification_types OWNER TO postgres;

--
-- Name: notification_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE notification_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_types_id_seq OWNER TO postgres;

--
-- Name: notification_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE notification_types_id_seq OWNED BY notification_types.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    dismissed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    notification_type_id integer NOT NULL,
    backer_id integer,
    update_id integer,
    favourite_id integer
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE oauth_providers (
    id integer NOT NULL,
    name text NOT NULL,
    key text NOT NULL,
    secret text NOT NULL,
    scope text,
    "order" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    strategy text,
    path text,
    CONSTRAINT oauth_providers_key_not_blank CHECK ((length(btrim(key)) > 0)),
    CONSTRAINT oauth_providers_name_not_blank CHECK ((length(btrim(name)) > 0)),
    CONSTRAINT oauth_providers_secret_not_blank CHECK ((length(btrim(secret)) > 0))
);


ALTER TABLE public.oauth_providers OWNER TO postgres;

--
-- Name: oauth_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE oauth_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oauth_providers_id_seq OWNER TO postgres;

--
-- Name: oauth_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE oauth_providers_id_seq OWNED BY oauth_providers.id;


--
-- Name: payment_notifications; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE payment_notifications (
    id integer NOT NULL,
    backer_id integer NOT NULL,
    extra_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.payment_notifications OWNER TO postgres;

--
-- Name: payment_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE payment_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_notifications_id_seq OWNER TO postgres;

--
-- Name: payment_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE payment_notifications_id_seq OWNED BY payment_notifications.id;


--
-- Name: paypal_payments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE paypal_payments (
    data text,
    hora text,
    fusohorario text,
    nome text,
    tipo text,
    status text,
    moeda text,
    valorbruto text,
    tarifa text,
    liquido text,
    doe_mail text,
    parae_mail text,
    iddatransacao text,
    statusdoequivalente text,
    statusdoendereco text,
    titulodoitem text,
    iddoitem text,
    valordoenvioemanuseio text,
    valordoseguro text,
    impostosobrevendas text,
    opcao1nome text,
    opcao1valor text,
    opcao2nome text,
    opcao2valor text,
    sitedoleilao text,
    iddocomprador text,
    urldoitem text,
    datadetermino text,
    iddaescritura text,
    iddafatura text,
    "idtxn_dereferência" text,
    numerodafatura text,
    numeropersonalizado text,
    iddorecibo text,
    saldo text,
    enderecolinha1 text,
    enderecolinha2_distrito_bairro text,
    cidade text,
    "estado_regiao_território_prefeitura_republica" text,
    cep text,
    pais text,
    numerodotelefoneparacontato text,
    extra text
);


ALTER TABLE public.paypal_payments OWNER TO postgres;

--
-- Name: project_totals; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW project_totals AS
    SELECT backers.project_id, sum(backers.value) AS pledged, sum(backers.payment_service_fee) AS total_payment_service_fee, count(*) AS total_backers FROM backers WHERE ((backers.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('refunded'::character varying)::text, ('requested_refund'::character varying)::text])) GROUP BY backers.project_id;


ALTER TABLE public.project_totals OWNER TO postgres;

--
-- Name: projects_by_periods; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW projects_by_periods AS
    WITH weeks AS (SELECT (generate_series.generate_series * 7) AS days FROM generate_series(0, 7) generate_series(generate_series)), current_period AS (SELECT 'current_period'::text AS series, count(*) AS count, (w.days / 7) AS week FROM (projects p RIGHT JOIN weeks w ON ((((p.created_at)::date >= ((('now'::text)::date - w.days) - 7)) AND (p.created_at < (('now'::text)::date - w.days))))) GROUP BY (w.days / 7)), previous_period AS (SELECT 'previous_period'::text AS series, count(*) AS count, (w.days / 7) AS week FROM (projects p RIGHT JOIN weeks w ON ((((p.created_at)::date >= (((('now'::text)::date - w.days) - 7) - 56)) AND (p.created_at < ((('now'::text)::date - w.days) - 56))))) GROUP BY (w.days / 7)), last_year AS (SELECT 'last_year'::text AS series, count(*) AS count, (w.days / 7) AS week FROM (projects p RIGHT JOIN weeks w ON ((((p.created_at)::date >= (((('now'::text)::date - w.days) - 7) - 365)) AND (p.created_at < ((('now'::text)::date - w.days) - 365))))) GROUP BY (w.days / 7)) (SELECT current_period.series, current_period.count, current_period.week FROM current_period UNION ALL SELECT previous_period.series, previous_period.count, previous_period.week FROM previous_period) UNION ALL SELECT last_year.series, last_year.count, last_year.week FROM last_year ORDER BY 1, 3;


ALTER TABLE public.projects_by_periods OWNER TO postgres;

--
-- Name: projects_curated_pages; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE projects_curated_pages (
    id integer NOT NULL,
    project_id integer,
    curated_page_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description_html text
);


ALTER TABLE public.projects_curated_pages OWNER TO postgres;

--
-- Name: projects_curated_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE projects_curated_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_curated_pages_id_seq OWNER TO postgres;

--
-- Name: projects_curated_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE projects_curated_pages_id_seq OWNED BY projects_curated_pages.id;


--
-- Name: projects_for_home; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW projects_for_home AS
    WITH recommended_projects AS (SELECT 'recommended'::text AS origin, recommends.id, recommends.name, recommends.user_id, recommends.category_id, recommends.goal, recommends.about, recommends.headline, recommends.video_url, recommends.short_url, recommends.created_at, recommends.updated_at, recommends.about_html, recommends.recommended, recommends.home_page_comment, recommends.permalink, recommends.video_thumbnail, recommends.state, recommends.online_days, recommends.online_date, recommends.how_know, recommends.more_links, recommends.first_backers, recommends.uploaded_image, recommends.video_embed_url, recommends.govid, recommends.paypal, recommends.stripe_userid, recommends.stripe_access_token, recommends.stripe_key, recommends.currency FROM projects recommends WHERE (recommends.recommended AND ((recommends.state)::text = 'online'::text)) ORDER BY random() LIMIT 8), recents_projects AS (SELECT 'recents'::text AS origin, recents.id, recents.name, recents.user_id, recents.category_id, recents.goal, recents.about, recents.headline, recents.video_url, recents.short_url, recents.created_at, recents.updated_at, recents.about_html, recents.recommended, recents.home_page_comment, recents.permalink, recents.video_thumbnail, recents.state, recents.online_days, recents.online_date, recents.how_know, recents.more_links, recents.first_backers, recents.uploaded_image, recents.video_embed_url, recents.govid, recents.paypal, recents.stripe_userid, recents.stripe_access_token, recents.stripe_key, recents.currency FROM projects recents WHERE ((((recents.state)::text = 'online'::text) AND ((now() - recents.online_date) <= '5 days'::interval)) AND (NOT (recents.id IN (SELECT recommends.id FROM recommended_projects recommends)))) ORDER BY random() LIMIT 3), expiring_projects AS (SELECT 'expiring'::text AS origin, expiring.id, expiring.name, expiring.user_id, expiring.category_id, expiring.goal, expiring.about, expiring.headline, expiring.video_url, expiring.short_url, expiring.created_at, expiring.updated_at, expiring.about_html, expiring.recommended, expiring.home_page_comment, expiring.permalink, expiring.video_thumbnail, expiring.state, expiring.online_days, expiring.online_date, expiring.how_know, expiring.more_links, expiring.first_backers, expiring.uploaded_image, expiring.video_embed_url, expiring.govid, expiring.paypal, expiring.stripe_userid, expiring.stripe_access_token, expiring.stripe_key, expiring.currency FROM projects expiring WHERE ((((expiring.state)::text = 'online'::text) AND (expires_at(expiring.*) <= (now() + '14 days'::interval))) AND (NOT (expiring.id IN (SELECT recommends.id FROM recommended_projects recommends UNION SELECT recents.id FROM recents_projects recents)))) ORDER BY random() LIMIT 3) (SELECT recommended_projects.origin, recommended_projects.id, recommended_projects.name, recommended_projects.user_id, recommended_projects.category_id, recommended_projects.goal, recommended_projects.about, recommended_projects.headline, recommended_projects.video_url, recommended_projects.short_url, recommended_projects.created_at, recommended_projects.updated_at, recommended_projects.about_html, recommended_projects.recommended, recommended_projects.home_page_comment, recommended_projects.permalink, recommended_projects.video_thumbnail, recommended_projects.state, recommended_projects.online_days, recommended_projects.online_date, recommended_projects.how_know, recommended_projects.more_links, recommended_projects.first_backers, recommended_projects.uploaded_image, recommended_projects.video_embed_url, recommended_projects.govid, recommended_projects.paypal, recommended_projects.stripe_userid, recommended_projects.stripe_access_token, recommended_projects.stripe_key, recommended_projects.currency FROM recommended_projects UNION SELECT recents_projects.origin, recents_projects.id, recents_projects.name, recents_projects.user_id, recents_projects.category_id, recents_projects.goal, recents_projects.about, recents_projects.headline, recents_projects.video_url, recents_projects.short_url, recents_projects.created_at, recents_projects.updated_at, recents_projects.about_html, recents_projects.recommended, recents_projects.home_page_comment, recents_projects.permalink, recents_projects.video_thumbnail, recents_projects.state, recents_projects.online_days, recents_projects.online_date, recents_projects.how_know, recents_projects.more_links, recents_projects.first_backers, recents_projects.uploaded_image, recents_projects.video_embed_url, recents_projects.govid, recents_projects.paypal, recents_projects.stripe_userid, recents_projects.stripe_access_token, recents_projects.stripe_key, recents_projects.currency FROM recents_projects) UNION SELECT expiring_projects.origin, expiring_projects.id, expiring_projects.name, expiring_projects.user_id, expiring_projects.category_id, expiring_projects.goal, expiring_projects.about, expiring_projects.headline, expiring_projects.video_url, expiring_projects.short_url, expiring_projects.created_at, expiring_projects.updated_at, expiring_projects.about_html, expiring_projects.recommended, expiring_projects.home_page_comment, expiring_projects.permalink, expiring_projects.video_thumbnail, expiring_projects.state, expiring_projects.online_days, expiring_projects.online_date, expiring_projects.how_know, expiring_projects.more_links, expiring_projects.first_backers, expiring_projects.uploaded_image, expiring_projects.video_embed_url, expiring_projects.govid, expiring_projects.paypal, expiring_projects.stripe_userid, expiring_projects.stripe_access_token, expiring_projects.stripe_key, expiring_projects.currency FROM expiring_projects;


ALTER TABLE public.projects_for_home OWNER TO postgres;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO postgres;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: recommendations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW recommendations AS
    SELECT recommendations.user_id, recommendations.project_id, recommendations.count FROM (SELECT b.user_id, recommendations.id AS project_id, count(DISTINCT recommenders.user_id) AS count FROM ((((backers b JOIN projects p ON ((p.id = b.project_id))) JOIN backers backers_same_projects ON ((p.id = backers_same_projects.project_id))) JOIN backers recommenders ON ((recommenders.user_id = backers_same_projects.user_id))) JOIN projects recommendations ON ((recommendations.id = recommenders.project_id))) WHERE ((((((((b.state)::text = 'confirmed'::text) AND ((backers_same_projects.state)::text = 'confirmed'::text)) AND ((recommenders.state)::text = 'confirmed'::text)) AND (b.user_id <> backers_same_projects.user_id)) AND (recommendations.id <> b.project_id)) AND ((recommendations.state)::text = 'online'::text)) AND (NOT (EXISTS (SELECT true AS bool FROM backers b2 WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = b.user_id)) AND (b2.project_id = recommendations.id)))))) GROUP BY b.user_id, recommendations.id UNION SELECT b.user_id, recommendations.id AS project_id, 0 AS count FROM ((backers b JOIN projects p ON ((b.project_id = p.id))) JOIN projects recommendations ON ((recommendations.category_id = p.category_id))) WHERE ((b.state)::text = 'confirmed'::text)) recommendations WHERE (NOT (EXISTS (SELECT true AS bool FROM backers b2 WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = recommendations.user_id)) AND (b2.project_id = recommendations.project_id))))) ORDER BY recommendations.count DESC;


ALTER TABLE public.recommendations OWNER TO postgres;

--
-- Name: reward_ranges; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE reward_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


ALTER TABLE public.reward_ranges OWNER TO postgres;

--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rewards_id_seq OWNER TO postgres;

--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO postgres;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    acronym character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT states_acronym_not_blank CHECK ((length(btrim((acronym)::text)) > 0)),
    CONSTRAINT states_name_not_blank CHECK ((length(btrim((name)::text)) > 0))
);


ALTER TABLE public.states OWNER TO postgres;

--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.states_id_seq OWNER TO postgres;

--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: statistics; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW statistics AS
    SELECT (SELECT count(*) AS count FROM users) AS total_users, backers_totals.total_backs, backers_totals.total_backers, backers_totals.total_backed, projects_totals.total_projects, projects_totals.total_projects_success, projects_totals.total_projects_online FROM (SELECT count(*) AS total_backs, count(DISTINCT backers.user_id) AS total_backers, sum(backers.value) AS total_backed FROM backers WHERE ((backers.state)::text <> ALL (ARRAY[('waiting_confirmation'::character varying)::text, ('pending'::character varying)::text, ('canceled'::character varying)::text, 'deleted'::text]))) backers_totals, (SELECT count(*) AS total_projects, count(CASE WHEN ((projects.state)::text = 'successful'::text) THEN 1 ELSE NULL::integer END) AS total_projects_success, count(CASE WHEN ((projects.state)::text = 'online'::text) THEN 1 ELSE NULL::integer END) AS total_projects_online FROM projects WHERE ((projects.state)::text <> ALL (ARRAY[('draft'::character varying)::text, ('rejected'::character varying)::text]))) projects_totals;


ALTER TABLE public.statistics OWNER TO postgres;

--
-- Name: subscriber_reports; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW subscriber_reports AS
    SELECT u.id, cs.channel_id, u.name, u.email FROM (users u JOIN channels_subscribers cs ON ((cs.user_id = u.id)));


ALTER TABLE public.subscriber_reports OWNER TO postgres;

--
-- Name: total_backed_ranges; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE total_backed_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


ALTER TABLE public.total_backed_ranges OWNER TO postgres;

--
-- Name: unsubscribes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE unsubscribes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    notification_type_id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.unsubscribes OWNER TO postgres;

--
-- Name: unsubscribes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE unsubscribes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unsubscribes_id_seq OWNER TO postgres;

--
-- Name: unsubscribes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE unsubscribes_id_seq OWNED BY unsubscribes.id;


--
-- Name: updates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE updates (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    title text,
    comment text NOT NULL,
    comment_html text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    exclusive boolean DEFAULT false
);


ALTER TABLE public.updates OWNER TO postgres;

--
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.updates_id_seq OWNER TO postgres;

--
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE updates_id_seq OWNED BY updates.id;


--
-- Name: user_totals; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW user_totals AS
    SELECT b.user_id AS id, b.user_id, count(DISTINCT b.project_id) AS total_backed_projects, sum(b.value) AS sum, count(*) AS count, sum(CASE WHEN (((p.state)::text <> 'failed'::text) AND (NOT b.credits)) THEN (0)::numeric WHEN (((p.state)::text = 'failed'::text) AND b.credits) THEN (0)::numeric WHEN (((p.state)::text = 'failed'::text) AND ((((b.state)::text = ANY (ARRAY[('requested_refund'::character varying)::text, ('refunded'::character varying)::text])) AND (NOT b.credits)) OR (b.credits AND (NOT ((b.state)::text = ANY (ARRAY[('requested_refund'::character varying)::text, ('refunded'::character varying)::text])))))) THEN (0)::numeric WHEN ((((p.state)::text = 'failed'::text) AND (NOT b.credits)) AND ((b.state)::text = 'confirmed'::text)) THEN b.value ELSE (b.value * ((-1))::numeric) END) AS credits FROM (backers b JOIN projects p ON ((b.project_id = p.id))) WHERE ((b.state)::text = ANY (ARRAY[('confirmed'::character varying)::text, ('requested_refund'::character varying)::text, ('refunded'::character varying)::text])) GROUP BY b.user_id;


ALTER TABLE public.user_totals OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


ALTER TABLE public.versions OWNER TO postgres;

--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.versions_id_seq OWNER TO postgres;

--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY authorizations ALTER COLUMN id SET DEFAULT nextval('authorizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY backers ALTER COLUMN id SET DEFAULT nextval('backers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels ALTER COLUMN id SET DEFAULT nextval('channels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_projects ALTER COLUMN id SET DEFAULT nextval('channels_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_subscribers ALTER COLUMN id SET DEFAULT nextval('channels_subscribers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_trustees ALTER COLUMN id SET DEFAULT nextval('channels_trustees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY configurations ALTER COLUMN id SET DEFAULT nextval('configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY favourites ALTER COLUMN id SET DEFAULT nextval('favourites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notification_types ALTER COLUMN id SET DEFAULT nextval('notification_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY oauth_providers ALTER COLUMN id SET DEFAULT nextval('oauth_providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payment_notifications ALTER COLUMN id SET DEFAULT nextval('payment_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY projects_curated_pages ALTER COLUMN id SET DEFAULT nextval('projects_curated_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unsubscribes ALTER COLUMN id SET DEFAULT nextval('unsubscribes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY updates ALTER COLUMN id SET DEFAULT nextval('updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Data for Name: authorizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY authorizations (id, oauth_provider_id, user_id, uid, created_at, updated_at) FROM stdin;
\.


--
-- Name: authorizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('authorizations_id_seq', 1, false);


--
-- Data for Name: backers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY backers (id, project_id, user_id, reward_id, value, confirmed_at, created_at, updated_at, anonymous, key, credits, notified_finish, payment_method, payment_token, payment_id, payer_name, payer_email, payer_document, address_street, address_number, address_complement, address_neighbourhood, address_zip_code, address_city, address_state, address_phone_number, payment_choice, payment_service_fee, state) FROM stdin;
1	1	1	1	10.0	\N	2013-11-09 21:33:25.875968	2013-11-09 21:33:36.627094	f	9bf4891264ad7c5e4def42dc907b59b1	f	f	MoIP	\N	\N	test	alex.daoud@mac.com	\N									\N	\N	pending
2	1	1	1	10.0	\N	2013-11-09 23:14:14.950749	2013-11-09 23:14:14.988961	f	bfba4d5aca90954b7f4d3c3e993ce790	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
3	1	1	1	10.0	\N	2013-11-09 23:16:53.153822	2013-11-09 23:17:05.41144	f	a5e8ae4bcfef5e3c9d0e09fc60ae63ce	f	f	MoIP	\N	\N	Alex	alex.daoud@mac.com	\N									\N	\N	pending
4	1	1	1	10.0	\N	2013-11-09 23:24:36.389926	2013-11-09 23:24:36.40214	f	f701330944d4ca7b3d9e28853fe5e76a	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
15	4	1	7	20.0	\N	2013-11-29 18:00:48.000989	2013-11-29 18:00:48.035592	f	0e6047007750dbb526cef823bc25b756	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
5	1	1	1	10.0	\N	2013-11-09 23:27:28.046261	2013-11-09 23:27:55.795656	f	99238f8a59cef85b2d57c790c09adec1	f	f	MoIP	cus_2uaJHbgUaumSfM	\N	Alex	alex.daoud@mac.com	\N									\N	\N	pending
6	1	1	1	10.0	\N	2013-11-09 23:31:44.742028	2013-11-09 23:31:44.754078	f	5cf05c909bba6d80c50944ad98548bc8	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
16	4	1	5	10.0	\N	2013-11-29 23:08:08.532319	2013-11-29 23:08:08.790351	f	bb78547851e0c3798055f8204d24f73e	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
7	1	1	1	10.0	\N	2013-11-09 23:32:30.743851	2013-11-09 23:33:01.521779	f	145e222bfe583c852a26104d1059004e	f	f	MoIP	cus_2uaOIcBNQODlVv	\N	Alex	alex.daoud@mac.com	\N									\N	\N	pending
8	1	1	1	10.0	\N	2013-11-09 23:44:00.608184	2013-11-09 23:44:27.794071	f	aab4f3cfe0e7b7688e11e9f235a8417f	f	f	MoIP	cus_2uaapkbjEILhi8	\N	alex	alex.daoud@mac.com	\N									\N	\N	pending
17	4	1	5	10.0	\N	2013-11-29 23:21:02.820711	2013-11-29 23:21:02.829025	f	7ffd9a395c06591f1e6e55a4dabaea52	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
9	1	1	1	10.0	\N	2013-11-09 23:52:55.87126	2013-11-09 23:53:43.163676	f	9950b439723d7f30cdcde764b86448a6	f	f	MoIP	cus_2uajND1UrUFiqa	\N	alex	alex.daoud@mac.com	\N									\N	\N	pending
18	4	1	5	10.0	\N	2013-11-29 23:21:29.491788	2013-11-29 23:21:29.498828	f	a52333ce7efe67bf6f61199ed1a9c6df	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
10	1	1	1	10.0	\N	2013-11-09 23:59:29.384191	2013-11-09 23:59:52.387548	f	f3965ef4e030a8a9f6241b0a6b231570	f	f	MoIP	cus_2uapIjeaoplK9e	\N	alex	alex.daoud@mac.com	\N									\N	\N	pending
11	1	1	1	10.0	\N	2013-11-10 00:03:22.75114	2013-11-10 00:03:50.160041	f	2be252f493f2b6c3565778f6da89a4f4	f	f	MoIP	cus_2uatcQexlYk9zP	\N	alex	alex.daoud@mac.com	\N									\N	\N	pending
19	4	1	5	10.0	\N	2013-11-29 23:22:09.24307	2013-11-29 23:22:09.251279	f	62040818e912f638e2d901a859787a27	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
12	1	1	1	10.0	\N	2013-11-10 00:06:10.00141	2013-11-10 00:06:45.345575	f	b153364e5ac15b897fde46fc07a3c3e2	f	f	Stripe	cus_2uawEjX8yuVsm2	ch_102uaw2wEU9cVCwNlrk5RbxL	alex	alex.daoud@mac.com	\N									\N	\N	pending
13	1	1	1	10.0	\N	2013-11-20 01:52:20.592001	2013-11-20 01:52:20.718338	f	03159629d7d3728103e465bd75deb60b	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
14	4	1	5	10.0	\N	2013-11-29 16:56:52.75867	2013-11-29 16:56:52.868627	f	da43b6f27a44f33c84566081324779f0	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
20	4	1	5	10.0	\N	2013-11-29 23:22:49.251208	2013-11-29 23:22:49.259235	f	2d88dff649e0fceea6ad16c939f8fd58	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
21	4	1	5	10.0	\N	2013-11-29 23:28:54.439263	2013-11-29 23:28:54.446137	f	ce0028e3ea526388f44f0222029b1119	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
22	4	1	5	10.0	\N	2013-11-29 23:30:37.191456	2013-11-29 23:30:37.19822	f	7776774b5beab0e6f550df36fcb1ac3b	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
23	4	1	5	10.0	\N	2013-11-29 23:30:58.200666	2013-11-29 23:30:58.208557	f	cc4903517a59c0cbb20aa9c5b1f305fa	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
24	4	1	5	10.0	\N	2013-11-29 23:31:51.488275	2013-11-29 23:31:51.496217	f	74b87e82217dd3d52ef7952b7a970675	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
25	4	1	5	10.0	\N	2013-11-29 23:32:41.325975	2013-11-29 23:32:44.183977	f	032e3e7c4ae020d55ee0b1d4e6a5496f	f	f	MoIP	\N	\N		alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
26	4	1	5	10.0	\N	2013-11-29 23:36:24.5363	2013-11-29 23:36:24.550728	f	c9af2218757d1bb8e9b303407126cc5c	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
27	4	1	5	10.0	\N	2013-11-29 23:39:10.32983	2013-11-29 23:39:10.339503	f	df6683d3b7c199014eb31ef9ffad16fd	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
28	4	1	5	10.0	\N	2013-11-29 23:39:30.109754	2013-11-29 23:39:30.11664	f	b9f9d119c493d4c630558b0def56cb35	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
29	4	1	5	10.0	\N	2013-11-29 23:42:05.752659	2013-11-29 23:42:05.7623	f	9e59d5665b2ba80c636397aeed6e6479	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
36	4	1	6	10.0	\N	2013-11-30 14:04:32.850041	2013-11-30 14:04:32.860343	f	7692fc0083f65ee99acff42c944b4f4e	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
30	4	1	5	10.0	\N	2013-11-29 23:42:18.598763	2013-11-29 23:43:19.415158	f	713ea7e9e73fcd44fed00c9f635d67df	f	f	MoIP	\N	\N	alex	alex	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
31	4	1	6	10.0	\N	2013-11-29 23:50:29.992014	2013-11-29 23:50:30.002741	f	1ef08a47ebc8aac84b1d398526caf94e	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
37	4	1	6	10.0	\N	2013-11-30 14:05:37.667692	2013-11-30 14:05:37.678267	f	d470249b96224accd991de749c5e45c8	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
32	4	1	6	10.0	\N	2013-11-29 23:50:43.948138	2013-11-29 23:50:59.637211	f	0562f9e9bf6e30e120513992856ac4ab	f	f	stripe	\N	\N	test	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
33	4	1	6	10.0	\N	2013-11-30 13:19:06.354431	2013-11-30 13:19:14.649087	f	93060e681d9ac6738f86b833b6fe0028	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
38	4	1	6	10.0	\N	2013-11-30 14:06:30.391216	2013-11-30 14:06:30.39844	f	8f69b10b89f693732e4abfecb62f78c8	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
34	4	1	6	10.0	\N	2013-11-30 13:27:59.10827	2013-11-30 13:28:06.661073	f	029d71bbeee1ab2e6216eb53f5f9fb3a	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
35	4	1	6	10.0	\N	2013-11-30 14:01:59.786363	2013-11-30 14:01:59.793431	f	c24ea57628ac406bbdc7fdf933516d42	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
39	4	1	6	10.0	\N	2013-11-30 14:07:23.823593	2013-11-30 14:07:23.845239	f	cf5660ff7d3eafb614b51e90d801ba87	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
40	4	1	6	10.0	\N	2013-11-30 14:07:31.503035	2013-11-30 14:07:31.509913	f	876888c7162a6204341f08c119840b2a	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
41	4	1	6	10.0	\N	2013-11-30 14:08:04.510573	2013-11-30 14:08:04.580721	f	c0e11aeef2a9d1472df61ff068f94909	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
42	4	1	6	10.0	\N	2013-11-30 14:18:17.679339	2013-11-30 14:18:17.686185	f	bf003b3106145a1056bbbc8bc037ae78	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
43	4	1	6	10.0	\N	2013-11-30 14:20:53.035835	2013-11-30 14:20:53.044338	f	095b577ecc147c9c938d879f2c3173c4	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
44	4	1	6	10.0	\N	2013-11-30 14:21:10.73867	2013-11-30 14:21:10.747074	f	e64fc8ebf243e293b39530857793c0f2	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
45	4	1	6	10.0	\N	2013-11-30 14:21:53.213381	2013-11-30 14:21:53.220482	f	e6da093137872a98ba2d5b7b313ef787	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
46	4	1	6	10.0	\N	2013-11-30 14:23:24.391204	2013-11-30 14:23:24.401569	f	a8505a0b198c57cc9c8af7dbebc993b2	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
47	4	1	\N	10.0	\N	2013-11-30 14:27:08.308045	2013-11-30 14:27:08.316127	f	5cc98ed46bc4016c35e73720e4d75b5d	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
48	4	1	\N	10.0	\N	2013-11-30 14:27:41.497076	2013-11-30 14:27:41.503994	f	9974f96b5dad1c3b73e504169ea41276	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
49	4	1	5	10.0	\N	2013-11-30 14:27:54.512556	2013-11-30 14:27:54.528525	f	7ac7f8920ce993ca6a3966a81f7a05bf	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
50	4	1	5	10.0	\N	2013-11-30 14:34:19.884665	2013-11-30 14:34:19.900832	f	28b7d689bce6c57088e4132973028a6d	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
51	4	1	5	10.0	\N	2013-11-30 14:34:47.429254	2013-11-30 14:34:47.441237	f	982e6f62d0af4ce462565bc1d8ad0ee9	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
52	4	1	5	10.0	\N	2013-11-30 14:35:17.806048	2013-11-30 14:35:17.81889	f	76754e25f3b8327525b00ee809e26e5a	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
53	4	1	5	10.0	\N	2013-11-30 14:36:40.530524	2013-11-30 14:36:40.541036	f	3e0b9766037b72be92d391dc8030d5ef	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
54	4	1	5	10.0	\N	2013-11-30 14:38:37.603466	2013-11-30 14:38:37.61247	f	8c3abeb1ad794bf61f9df1f6a479bae2	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
55	4	1	5	10.0	\N	2013-11-30 14:39:18.791596	2013-11-30 14:39:18.801315	f	72a45e776b74476967115fb11d5897ce	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
56	4	1	5	10.0	\N	2013-11-30 14:40:10.612511	2013-11-30 14:40:10.625938	f	a38c6741c216e9a82df9ccf83551ecac	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
57	4	1	5	10.0	\N	2013-11-30 14:40:50.61055	2013-11-30 14:40:50.61805	f	a8a0538c8f6acc5a55f5cb64c4543fd3	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
59	4	1	5	10.0	\N	2013-11-30 14:45:14.752891	2013-11-30 14:45:14.770557	f	06b7fb3aaf0d7b69c2d914cba5547fb3	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
58	4	1	5	10.0	\N	2013-11-30 14:43:33.199349	2013-11-30 14:43:33.207529	f	a5f15f2b0d8cba6f62d5f28f16641a50	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
60	4	1	5	10.0	\N	2013-11-30 14:46:26.163421	2013-11-30 14:46:26.170183	f	9b40c5ccc5755d14f6f627910ab67525	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
86	5	1	8	10.0	\N	2014-01-06 01:30:25.01027	2014-01-06 01:30:25.01926	f	043ad7effd5c70201fff4b09045f03ec	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
61	4	1	5	10.0	\N	2013-11-30 14:46:48.186094	2013-11-30 14:51:10.723912	f	c691e7fca123e3db21251a54f8657ecd	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
62	4	1	5	10.0	\N	2013-11-30 14:52:08.070806	2013-11-30 14:52:08.084899	f	df1b36a77237ebf12d0b3b81e6c8b715	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
77	4	1	5	10.0	\N	2013-11-30 15:23:15.835456	2013-11-30 15:23:23.365529	f	690c67a8391af461ac3980bb68e01850	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
63	4	1	5	10.0	\N	2013-11-30 14:52:32.9898	2013-11-30 14:52:44.328362	f	1b68f7984c9d2205dd2439a58f28da94	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
64	4	1	5	10.0	\N	2013-11-30 14:54:33.951136	2013-11-30 14:54:33.960503	f	764960e15842555cbed33f35661f2752	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
65	4	1	5	10.0	\N	2013-11-30 14:54:57.134872	2013-11-30 14:55:03.076109	f	53a8df357b43e5a93304d2baac8c5b3e	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
66	4	1	5	10.0	\N	2013-11-30 14:56:33.432038	2013-11-30 14:56:33.44049	f	b7ce2ccd25ba4dfb0bea798e517dab61	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
67	4	1	5	10.0	\N	2013-11-30 14:56:50.578166	2013-11-30 14:56:50.586564	f	5a29587e441766ebf114d8ac6165c6a9	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
68	4	1	5	10.0	\N	2013-11-30 15:00:22.76067	2013-11-30 15:00:22.771303	f	9a3371f2090e82d9979f434beda8ccb0	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
69	4	1	5	10.0	\N	2013-11-30 15:00:44.88375	2013-11-30 15:00:44.898457	f	b071a1d1377749f0a34328567f2a82e8	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
70	4	1	5	10.0	\N	2013-11-30 15:02:09.920254	2013-11-30 15:03:15.235266	f	5d46f4a767d66e152e88b652844977ac	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
71	4	1	5	10.0	\N	2013-11-30 15:04:43.588998	2013-11-30 15:04:43.598381	f	2b2b156d233ec7b124a6f2e8652fa358	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
72	4	1	5	10.0	\N	2013-11-30 15:09:06.204526	2013-11-30 15:09:14.187088	f	712f3a6abcfc53bfee5a8822558e7d83	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
73	4	1	5	10.0	\N	2013-11-30 15:13:35.843264	2013-11-30 15:13:42.295136	f	6ffede47e27905436a17bb24bd72fc63	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
87	5	1	8	10.0	\N	2014-01-06 01:31:10.769031	2014-01-06 01:31:10.78272	f	b14d3c98230cfe635c09a2c8c28f5e98	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
74	4	1	5	10.0	\N	2013-11-30 15:14:59.594288	2013-11-30 15:15:07.264805	f	e52a0d9d1a8ff2b67581071bfb9e0c0c	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
78	4	1	6	10.0	\N	2013-11-30 17:17:18.23135	2013-11-30 20:08:10.769671	f	690b28a5898a6ce07a7d883207e374f5	f	f	Stripe	cus_32Opk3YIm0jOmZ	ch_1032Op2wEU9cVCwNfQegCbKS	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
75	4	1	5	10.0	\N	2013-11-30 15:16:38.012534	2013-11-30 15:16:44.347791	f	13c32e0e54e428c88218132e847473c5	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
76	4	1	5	10.0	\N	2013-11-30 15:18:37.471976	2013-11-30 15:19:26.746344	f	86c4d8bbe91cc7a48b9efe5e6310a8dd	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
79	4	1	5	10.0	\N	2013-11-30 20:14:58.190041	2013-11-30 20:15:08.437801	f	524a30aaf30acf3824d6d96f21df50e4	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
80	4	1	5	10.0	\N	2013-11-30 20:25:23.567575	2013-11-30 20:25:30.681168	f	8bdcd0b4b7e29d5515d29f2f26ccade0	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
88	5	1	8	10.0	\N	2014-01-06 01:32:28.065892	2014-01-06 01:32:28.076727	f	7bece94b3dc3259ca0be864842c19a9a	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
81	4	1	5	10.0	\N	2013-11-30 20:27:26.877846	2013-11-30 20:27:36.668375	f	a209fd3a0bb0c001a5576d56553c6cb7	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
82	4	1	5	10.0	\N	2013-11-30 20:28:45.131036	2013-11-30 20:28:50.768414	f	c60e403c63f56341a7dc610d71efc2c2	f	f	stripe	\N	\N	alex	alex.daoud@mac.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
83	5	1	8	10.0	\N	2014-01-06 01:24:43.943996	2014-01-06 01:25:06.590136	f	80ca19528ce55dc8cc8bee5332fd4785	f	f	MoIP	\N	\N	alexandre	alex.daoud@mac.com	\N									\N	\N	pending
84	5	1	8	10.0	\N	2014-01-06 01:28:10.706012	2014-01-06 01:28:10.716154	f	5510f65d636b5d0a12623322822e4de6	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
85	5	1	8	10.0	\N	2014-01-06 01:29:52.764549	2014-01-06 01:29:52.774417	f	8687706d9b9cbbdae43e33ba7d990479	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
89	5	1	8	10.0	\N	2014-01-06 01:33:31.456947	2014-01-06 01:33:31.468791	f	26aa05279c2eeae6ad691b93775bc1c7	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
90	5	1	8	10.0	\N	2014-01-06 01:43:49.060249	2014-01-06 01:43:49.071131	f	3f449d2db6290018dc247fb707502941	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
91	5	1	8	10.0	\N	2014-01-06 01:46:00.414746	2014-01-06 01:46:00.425229	f	c085774b1929fc98276e5fd7b4376676	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
92	5	1	8	10.0	\N	2014-01-06 01:46:29.065173	2014-01-06 01:46:29.076039	f	2707580296e0a34c0265c3cb5f8ac9dc	f	f	MoIP	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pending
\.


--
-- Name: backers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('backers_id_seq', 92, true);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY categories (id, name_pt, created_at, updated_at, name_en) FROM stdin;
1	Arte	2013-11-09 21:26:50.608312	2013-11-09 21:26:50.608312	Art
2	Artes plásticas	2013-11-09 21:26:50.638069	2013-11-09 21:26:50.638069	Visual Arts
3	Circo	2013-11-09 21:26:50.690101	2013-11-09 21:26:50.690101	Circus
4	Comunidade	2013-11-09 21:26:50.752914	2013-11-09 21:26:50.752914	Community
5	Humor	2013-11-09 21:26:50.96783	2013-11-09 21:26:50.96783	Humor
6	Quadrinhos	2013-11-09 21:26:51.023715	2013-11-09 21:26:51.023715	Comicbooks
7	Dança	2013-11-09 21:26:51.082062	2013-11-09 21:26:51.082062	Dance
8	Design	2013-11-09 21:26:51.146061	2013-11-09 21:26:51.146061	Design
9	Eventos	2013-11-09 21:26:51.212952	2013-11-09 21:26:51.212952	Events
10	Moda	2013-11-09 21:26:51.280561	2013-11-09 21:26:51.280561	Fashion
11	Gastronomia	2013-11-09 21:26:51.346862	2013-11-09 21:26:51.346862	Gastronomy
12	Cinema & Vídeo	2013-11-09 21:26:51.401442	2013-11-09 21:26:51.401442	Film & Video
13	Jogos	2013-11-09 21:26:51.457092	2013-11-09 21:26:51.457092	Games
14	Jornalismo	2013-11-09 21:26:51.523824	2013-11-09 21:26:51.523824	Journalism
15	Música	2013-11-09 21:26:51.595152	2013-11-09 21:26:51.595152	Music
16	Fotografia	2013-11-09 21:26:51.647142	2013-11-09 21:26:51.647142	Photography
17	Ciência e Tecnologia	2013-11-09 21:26:51.68931	2013-11-09 21:26:51.68931	Science & Technology
18	Teatro	2013-11-09 21:26:51.746136	2013-11-09 21:26:51.746136	Theatre
19	Esporte	2013-11-09 21:26:51.812131	2013-11-09 21:26:51.812131	Sport
20	Web	2013-11-09 21:26:51.862774	2013-11-09 21:26:51.862774	Web
21	Carnaval	2013-11-09 21:26:51.923302	2013-11-09 21:26:51.923302	Carnival
22	Arquitetura & Urbanismo	2013-11-09 21:26:51.979462	2013-11-09 21:26:51.979462	Architecture & Urbanism
23	Literatura	2013-11-09 21:26:52.046751	2013-11-09 21:26:52.046751	Literature
24	Mobilidade e Transporte	2013-11-09 21:26:52.09958	2013-11-09 21:26:52.09958	Mobility & Transportation
25	Meio Ambiente	2013-11-09 21:26:52.159122	2013-11-09 21:26:52.159122	Environment
26	Negócios Sociais	2013-11-09 21:26:52.224147	2013-11-09 21:26:52.224147	Social Business
27	Educação	2013-11-09 21:26:52.291557	2013-11-09 21:26:52.291557	Education
28	Filmes de Ficção	2013-11-09 21:26:52.357764	2013-11-09 21:26:52.357764	Fiction Films
29	Filmes Documentários	2013-11-09 21:26:52.423534	2013-11-09 21:26:52.423534	Documentary Films
30	Filmes Universitários	2013-11-09 21:26:52.514418	2013-11-09 21:26:52.514418	Experimental Films
31	Country	2013-12-22 14:58:09.965812	2013-12-22 14:58:09.965812	Country
32	Electronic	2013-12-22 14:58:10.060357	2013-12-22 14:58:10.060357	Electronic
33	Hip Hop	2013-12-22 14:58:10.100986	2013-12-22 14:58:10.100986	Hip Hop
34	Jazz	2013-12-22 14:58:10.142397	2013-12-22 14:58:10.142397	Jazz
35	Metal	2013-12-22 14:58:10.189103	2013-12-22 14:58:10.189103	Metal
36	Pop	2013-12-22 14:58:10.266646	2013-12-22 14:58:10.266646	Pop
37	R&B	2013-12-22 14:58:10.303054	2013-12-22 14:58:10.303054	R&B
38	Rock	2013-12-22 14:58:10.34637	2013-12-22 14:58:10.34637	Rock
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('categories_id_seq', 38, true);


--
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY channels (id, name, description, permalink, created_at, updated_at, twitter, facebook, email, image, website) FROM stdin;
1	Channel name	Lorem Ipsum	sample-permalink	2013-11-09 21:26:56.307312	2013-11-09 21:26:56.307312	\N	\N	\N	\N	\N
\.


--
-- Name: channels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('channels_id_seq', 1, true);


--
-- Data for Name: channels_projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY channels_projects (id, channel_id, project_id) FROM stdin;
\.


--
-- Name: channels_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('channels_projects_id_seq', 1, false);


--
-- Data for Name: channels_subscribers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY channels_subscribers (id, user_id, channel_id) FROM stdin;
\.


--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('channels_subscribers_id_seq', 1, false);


--
-- Data for Name: channels_trustees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY channels_trustees (id, user_id, channel_id) FROM stdin;
\.


--
-- Name: channels_trustees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('channels_trustees_id_seq', 1, false);


--
-- Data for Name: configurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY configurations (id, name, value, created_at, updated_at) FROM stdin;
78	blog_url	http://blog.catarse.me	2014-02-26 22:12:27.655893	2014-02-26 22:12:27.655893
79	github_url	http://github.com/catarse	2014-02-26 22:12:27.716024	2014-02-26 22:12:27.716024
80	contato_url	http://suporte.catarse.me/	2014-02-26 22:12:27.769986	2014-02-26 22:12:27.769986
81	stripe_api_key	pk_test_Cn1EzZY1Z9JqEnRC7q6Ro3tE	2014-02-26 22:12:27.837832	2014-02-26 22:12:27.837832
82	stripe_secret_key	sk_test_kPcf0Yb4LTS95jqvojnNn2ls	2014-02-26 22:12:27.893183	2014-02-26 22:12:27.893183
47	secret_token	c2e7a67059bac7a9856b8aa2ddfb5f7fc7f31e1e73eea1bbe50b82349b89ebfc3a97539e76bfd340e5000ac0287232b6380579f9b24f73f54970f2ab64010a5c	2014-02-26 22:12:23.407188	2014-02-26 22:12:23.407188
48	company_name	Jampoff	2014-02-26 22:12:25.764844	2014-02-26 22:12:25.764844
49	host	tribaltears.com	2014-02-26 22:12:25.8534	2014-02-26 22:12:25.8534
50	base_url	http://tribaltears.com	2014-02-26 22:12:25.920151	2014-02-26 22:12:25.920151
51	email_contact	contato@catarse.me	2014-02-26 22:12:26.000715	2014-02-26 22:12:26.000715
52	email_payments	financeiro@catarse.me	2014-02-26 22:12:26.053559	2014-02-26 22:12:26.053559
53	email_projects	projetos@catarse.me	2014-02-26 22:12:26.108823	2014-02-26 22:12:26.108823
54	email_system	system@catarse.me	2014-02-26 22:12:26.164015	2014-02-26 22:12:26.164015
55	email_no_reply	no-reply@catarse.me	2014-02-26 22:12:26.211061	2014-02-26 22:12:26.211061
56	facebook_url	http://facebook.com/jampoff	2014-02-26 22:12:26.25348	2014-02-26 22:12:26.25348
57	facebook_app_id	173747042661491	2014-02-26 22:12:26.320468	2014-02-26 22:12:26.320468
58	twitter_url	http://twitter.com/jampoff	2014-02-26 22:12:26.387484	2014-02-26 22:12:26.387484
59	twitter_username	jampoff	2014-02-26 22:12:26.475972	2014-02-26 22:12:26.475972
60	mailchimp_url	http://catarse.us5.list-manage.com/subscribe/post?u=ebfcd0d16dbb0001a0bea3639&amp;id=149c39709e	2014-02-26 22:12:26.56402	2014-02-26 22:12:26.56402
61	catarse_fee	0.13	2014-02-26 22:12:26.653922	2014-02-26 22:12:26.653922
62	support_forum	http://suporte.catarse.me/	2014-02-26 22:12:26.712523	2014-02-26 22:12:26.712523
63	base_domain	tribaltears.com	2014-02-26 22:12:26.765774	2014-02-26 22:12:26.765774
64	uservoice_secret_gadget	change_this	2014-02-26 22:12:26.826577	2014-02-26 22:12:26.826577
65	uservoice_key	uservoice_key	2014-02-26 22:12:26.881865	2014-02-26 22:12:26.881865
66	faq_url	http://suporte.catarse.me/	2014-02-26 22:12:26.93936	2014-02-26 22:12:26.93936
67	feedback_url	http://suporte.catarse.me/forums/103171-catarse-ideias-gerais	2014-02-26 22:12:26.986706	2014-02-26 22:12:26.986706
68	support_url	http://suporte.catarse.me/	2014-02-26 22:12:27.048305	2014-02-26 22:12:27.048305
69	terms_url	http://suporte.catarse.me/knowledgebase/articles/161102-terms-of-use	2014-02-26 22:12:27.104939	2014-02-26 22:12:27.104939
70	privacy_url	http://suporte.catarse.me/knowledgebase/articles/161104-privacy-policy	2014-02-26 22:12:27.157663	2014-02-26 22:12:27.157663
71	instagram_url	http://instagram.com/jampoff	2014-02-26 22:12:27.215838	2014-02-26 22:12:27.215838
72	soundcloud_url	www.soundcloud/jampoff	2014-02-26 22:12:27.270642	2014-02-26 22:12:27.270642
73	google_url	https://plus.google.com/b/109965324337247827518/109965324337247827518/about?hl=en	2014-02-26 22:12:27.3267	2014-02-26 22:12:27.3267
74	pinterest_url	http://www.pinterest.com/jampoff/	2014-02-26 22:12:27.38243	2014-02-26 22:12:27.38243
75	tumblr_url	http://jampoff.tumblr.com/	2014-02-26 22:12:27.443761	2014-02-26 22:12:27.443761
76	myspace_url	https://myspace.com/jampoff	2014-02-26 22:12:27.488703	2014-02-26 22:12:27.488703
77	youtube_url	http://www.youtube.com/user/Jampoff	2014-02-26 22:12:27.549696	2014-02-26 22:12:27.549696
83	stripe_test	TRUE	2014-02-26 22:12:27.949266	2014-02-26 22:12:27.949266
84	stripe_client_id	ca_2uW3Flc20I4UqjNiwOGyDyZUv3Xi8kua	2014-02-26 22:12:28.00209	2014-02-26 22:12:28.00209
85	aws_access_key	AKIAIDJAMCVP5M44OGGA	2014-02-26 22:12:28.055504	2014-02-26 22:12:28.055504
87	aws_bucket	s3.tribaltears.com	2014-02-26 22:12:28.170932	2014-02-26 22:12:28.170932
88	banner1	https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/1	2014-02-26 22:12:28.2257	2014-02-26 22:12:28.2257
89	banner2	https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/2	2014-02-26 22:12:28.281539	2014-02-26 22:12:28.281539
90	banner3	https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/3	2014-02-26 22:12:28.338781	2014-02-26 22:12:28.338781
91	banner4	https://s3-us-west-2.amazonaws.com/catarsemusic1/uploads/banner/4	2014-02-26 22:12:28.393116	2014-02-26 22:12:28.393116
92	banner1_id	6	2014-02-26 22:12:28.448973	2014-02-26 22:12:28.448973
96	mandrill_username	alex.daoud@mac.com	2014-02-26 22:12:28.67344	2014-02-26 22:12:28.67344
97	mandrill_password	XXX	2014-02-26 22:12:28.728206	2014-02-26 22:12:28.728206
93	banner2_id	1	2014-02-26 22:12:28.504592	2014-02-26 22:14:20.997978
95	banner4_id	3	2014-02-26 22:12:28.619354	2014-02-26 22:14:29.825516
94	banner3_id	5	2014-02-26 22:12:28.560604	2014-02-26 22:14:43.488224
86	aws_secret_key	PbriYbE4rFidFzL4ee5fGmeZpCmsUVNHspYlJsJ	2014-02-26 22:12:28.117037	2014-02-26 22:34:49.576664
\.


--
-- Name: configurations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('configurations_id_seq', 97, true);


--
-- Data for Name: favourites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY favourites (id, project_id, created_at, updated_at, user_id, state) FROM stdin;
134	6	2013-12-19 01:07:03.368345	2013-12-21 19:40:47.630387	1	notified
137	3	2013-12-19 19:30:38.643254	2013-12-21 19:40:48.807461	1	notified
\.


--
-- Name: favourites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('favourites_id_seq', 137, true);


--
-- Data for Name: notification_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY notification_types (id, name, created_at, updated_at, layout) FROM stdin;
1	confirm_backer	2013-11-09 21:26:52.807826	2013-11-09 21:26:52.807826	email
2	payment_slip	2013-11-09 21:26:52.855194	2013-11-09 21:26:52.855194	email
3	project_success	2013-11-09 21:26:52.89687	2013-11-09 21:26:52.89687	email
4	backer_project_successful	2013-11-09 21:26:52.96292	2013-11-09 21:26:52.96292	email
5	backer_project_unsuccessful	2013-11-09 21:26:53.056024	2013-11-09 21:26:53.056024	email
6	project_received	2013-11-09 21:26:53.118454	2013-11-09 21:26:53.118454	email
7	project_received_channel	2013-11-09 21:26:53.163477	2013-11-09 21:26:53.163477	email
8	updates	2013-11-09 21:26:53.229175	2013-11-09 21:26:53.229175	email
9	project_unsuccessful	2013-11-09 21:26:53.284083	2013-11-09 21:26:53.284083	email
10	project_visible	2013-11-09 21:26:53.339608	2013-11-09 21:26:53.339608	email
11	processing_payment	2013-11-09 21:26:53.395908	2013-11-09 21:26:53.395908	email
12	new_draft_project	2013-11-09 21:26:53.486571	2013-11-09 21:26:53.486571	email
13	new_draft_channel	2013-11-09 21:26:53.573189	2013-11-09 21:26:53.573189	email
14	project_rejected	2013-11-09 21:26:53.663383	2013-11-09 21:26:53.663383	email
15	pending_backer_project_unsuccessful	2013-11-09 21:26:53.717705	2013-11-09 21:26:53.717705	email
16	project_owner_backer_confirmed	2013-11-09 21:26:53.772476	2013-11-09 21:26:53.772476	email
17	adm_project_deadline	2013-11-09 21:26:53.829798	2013-11-09 21:26:53.829798	email
18	project_in_wainting_funds	2013-11-09 21:26:53.885392	2013-11-09 21:26:53.885392	email
19	credits_warning	2013-11-09 21:26:53.939851	2013-11-09 21:26:53.939851	email
20	backer_confirmed_after_project_was_closed	2013-11-09 21:26:53.996037	2013-11-09 21:26:53.996037	email
21	backer_canceled_after_confirmed	2013-11-09 21:26:54.051119	2013-11-09 21:26:54.051119	email
22	new_user_registration	2013-11-09 21:26:54.105974	2013-11-09 21:26:54.105974	email
23	project_about_to_expire	2013-12-18 23:58:44.393615	2013-12-18 23:58:44.393615	email
\.


--
-- Name: notification_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('notification_types_id_seq', 23, true);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY notifications (id, user_id, project_id, dismissed, created_at, updated_at, notification_type_id, backer_id, update_id, favourite_id) FROM stdin;
1	1	\N	t	2013-11-09 21:28:50.328842	2013-11-09 21:28:50.328842	22	\N	\N	\N
2	1	1	t	2013-11-09 21:32:21.565054	2013-11-09 21:32:21.565054	6	\N	\N	\N
3	1	1	t	2013-11-09 21:32:50.723827	2013-11-09 21:32:50.723827	10	\N	\N	\N
5	2	\N	t	2013-11-20 15:41:46.549368	2013-11-20 15:41:46.549368	22	\N	\N	\N
6	1	3	t	2013-11-21 17:31:11.26219	2013-11-21 17:31:11.26219	6	\N	\N	\N
7	1	4	t	2013-11-23 16:18:51.15086	2013-11-23 16:18:51.15086	6	\N	\N	\N
8	1	3	t	2013-11-23 16:21:21.555935	2013-11-23 16:21:21.555935	10	\N	\N	\N
9	1	4	t	2013-11-23 16:21:28.651531	2013-11-23 16:21:28.651531	10	\N	\N	\N
10	1	5	t	2013-12-12 19:12:27.982547	2013-12-12 19:12:27.982547	6	\N	\N	\N
11	1	5	t	2013-12-12 19:15:07.582749	2013-12-12 19:15:07.582749	10	\N	\N	\N
12	1	6	t	2013-12-12 19:23:26.173633	2013-12-12 19:23:26.173633	6	\N	\N	\N
13	1	6	t	2013-12-12 19:23:37.328624	2013-12-12 19:23:37.328624	10	\N	\N	\N
47	1	3	t	2013-12-19 00:02:37.384039	2013-12-19 00:02:37.384039	23	\N	\N	\N
48	1	3	t	2013-12-19 00:33:43.037137	2013-12-19 00:33:43.037137	23	\N	\N	\N
49	1	3	t	2013-12-19 00:36:50.478592	2013-12-19 00:36:50.478592	23	\N	\N	\N
50	1	3	t	2013-12-19 00:48:46.127548	2013-12-19 00:48:46.127548	23	\N	\N	\N
51	1	3	t	2013-12-19 01:06:03.449125	2013-12-19 01:06:03.449125	23	\N	\N	\N
52	1	3	t	2013-12-19 02:05:19.361698	2013-12-19 02:05:19.361698	23	\N	\N	\N
53	1	1	t	2013-12-21 19:40:35.036514	2013-12-21 19:40:35.036514	9	\N	\N	\N
54	1	3	t	2013-12-21 19:40:43.673112	2013-12-21 19:40:43.673112	9	\N	\N	\N
55	1	4	t	2013-12-21 19:40:45.863538	2013-12-21 19:40:45.863538	9	\N	\N	\N
56	1	6	t	2013-12-21 19:40:47.646889	2013-12-21 19:40:47.646889	23	\N	\N	\N
57	1	3	t	2013-12-21 19:40:48.850901	2013-12-21 19:40:48.850901	23	\N	\N	\N
\.


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('notifications_id_seq', 58, true);


--
-- Data for Name: oauth_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY oauth_providers (id, name, key, secret, scope, "order", created_at, updated_at, strategy, path) FROM stdin;
1	facebook	your_facebook_app_key	your_facebook_app_secret	\N	\N	2013-11-09 21:26:56.347612	2013-11-09 21:26:56.347612	\N	facebook
\.


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('oauth_providers_id_seq', 1, true);


--
-- Data for Name: payment_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY payment_notifications (id, backer_id, extra_data, created_at, updated_at) FROM stdin;
1	12	{"id":"ch_102uaw2wEU9cVCwNlrk5RbxL","object":"charge","created":1384042010,"livemode":false,"paid":true,"amount":1000,"currency":"usd","refunded":false,"card":{"id":"card_102uaw2wEU9cVCwNTCgIhzBB","object":"card","last4":"4242","type":"Visa","exp_month":11,"exp_year":2013,"fingerprint":"f5GoQOKIKM82cByn","customer":"cus_2uawEjX8yuVsm2","country":"US","name":"alex","address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":"pass","address_line1_check":null,"address_zip_check":null},"captured":true,"refunds":[],"balance_transaction":"txn_102uaw2wEU9cVCwNTV7eJgh8","failure_message":null,"failure_code":null,"amount_refunded":0,"customer":"cus_2uawEjX8yuVsm2","invoice":null,"description":"Back project testing with R$10 (USD)","dispute":null,"metadata":{}}	2013-11-10 00:06:45.460031	2013-11-10 00:06:45.460031
2	12	{"id":"ch_102uaw2wEU9cVCwNlrk5RbxL","object":"charge","created":1384042010,"livemode":false,"paid":true,"amount":1000,"currency":"usd","refunded":false,"card":{"id":"card_102uaw2wEU9cVCwNTCgIhzBB","object":"card","last4":"4242","type":"Visa","exp_month":11,"exp_year":2013,"fingerprint":"f5GoQOKIKM82cByn","customer":"cus_2uawEjX8yuVsm2","country":"US","name":"alex","address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":"pass","address_line1_check":null,"address_zip_check":null},"captured":true,"refunds":[],"balance_transaction":"txn_102uaw2wEU9cVCwNTV7eJgh8","failure_message":null,"failure_code":null,"amount_refunded":0,"customer":"cus_2uawEjX8yuVsm2","invoice":null,"description":"Back project testing with R$10 (USD)","dispute":null,"metadata":{}}	2013-11-10 00:06:47.287978	2013-11-10 00:06:47.287978
3	78	{"id":"ch_1032Op2wEU9cVCwNfQegCbKS","object":"charge","created":1385842097,"livemode":false,"paid":true,"amount":1000,"currency":"gbp","refunded":false,"card":{"id":"card_1032Op2wEU9cVCwN9jbfVYjA","object":"card","last4":"4242","type":"Visa","exp_month":12,"exp_year":2013,"fingerprint":"f5GoQOKIKM82cByn","customer":"cus_32Opk3YIm0jOmZ","country":"US","name":"Alex","address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":"pass","address_line1_check":null,"address_zip_check":null},"captured":true,"refunds":[],"balance_transaction":"txn_1032Op2wEU9cVCwN0BT9FVLK","failure_message":null,"failure_code":null,"amount_refunded":0,"customer":"cus_32Opk3YIm0jOmZ","invoice":null,"description":"Back project new with £10 (USD)","dispute":null,"metadata":{}}	2013-11-30 20:08:10.879303	2013-11-30 20:08:10.879303
4	78	{"id":"ch_1032Op2wEU9cVCwNfQegCbKS","object":"charge","created":1385842097,"livemode":false,"paid":true,"amount":1000,"currency":"gbp","refunded":false,"card":{"id":"card_1032Op2wEU9cVCwN9jbfVYjA","object":"card","last4":"4242","type":"Visa","exp_month":12,"exp_year":2013,"fingerprint":"f5GoQOKIKM82cByn","customer":"cus_32Opk3YIm0jOmZ","country":"US","name":"Alex","address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":"pass","address_line1_check":null,"address_zip_check":null},"captured":true,"refunds":[],"balance_transaction":"txn_1032Op2wEU9cVCwN0BT9FVLK","failure_message":null,"failure_code":null,"amount_refunded":0,"customer":"cus_32Opk3YIm0jOmZ","invoice":null,"description":"Back project new with £10 (USD)","dispute":null,"metadata":{}}	2013-11-30 20:08:12.214352	2013-11-30 20:08:12.214352
\.


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('payment_notifications_id_seq', 4, true);


--
-- Data for Name: paypal_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY paypal_payments (data, hora, fusohorario, nome, tipo, status, moeda, valorbruto, tarifa, liquido, doe_mail, parae_mail, iddatransacao, statusdoequivalente, statusdoendereco, titulodoitem, iddoitem, valordoenvioemanuseio, valordoseguro, impostosobrevendas, opcao1nome, opcao1valor, opcao2nome, opcao2valor, sitedoleilao, iddocomprador, urldoitem, datadetermino, iddaescritura, iddafatura, "idtxn_dereferência", numerodafatura, numeropersonalizado, iddorecibo, saldo, enderecolinha1, enderecolinha2_distrito_bairro, cidade, "estado_regiao_território_prefeitura_republica", cep, pais, numerodotelefoneparacontato, extra) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY projects (id, name, user_id, category_id, goal, about, headline, video_url, short_url, created_at, updated_at, about_html, recommended, home_page_comment, permalink, video_thumbnail, state, online_days, online_date, how_know, more_links, first_backers, uploaded_image, video_embed_url, govid, paypal, stripe_userid, stripe_access_token, stripe_key, currency) FROM stdin;
1	testing	1	22	10.0	testing	testing	http://vimeo.com/38814733	\N	2013-11-09 21:32:21.249243	2013-12-21 19:40:33.560895	<p>testing</p>	t	\N	testing	open-uri20131109-13327-18gxxvy	failed	10	2013-11-09 21:32:50+00	\N	\N	\N	\N	http://player.vimeo.com/video/38814733	b0c3baedebd1c3d520de4fd67fc3f5fa.jpg.png	alex	acct_102uYo2wEU9cVCwN	sk_test_NcU3sn5KvQmCjZZcr4XVvzVq	pk_test_dLozstJciPiTMjS2ZN2kmV4Y	GBP
3	british	1	22	10.0	10	british	http://www.youtube.com/watch?v=d7bciRAJduA	\N	2013-11-21 17:31:11.029204	2013-12-21 19:40:43.653079	<p>10</p>	t	\N	british	open-uri20131121-14920-1x4m3ng	failed	10	2013-11-23 16:21:21+00	\N	\N	\N	\N	www.youtube.com/embed/d7bciRAJduA	b0c3baedebd1c3d520de4fd67fc3f5fa.jpg.png	\N	acct_102uYo2wEU9cVCwN	sk_test_NcU3sn5KvQmCjZZcr4XVvzVq	pk_test_dLozstJciPiTMjS2ZN2kmV4Y	GBP
4	new	1	22	10.0	test	new	http://www.youtube.com/watch?v=Q1qMuGsI81w	\N	2013-11-23 16:18:50.807307	2013-12-21 19:40:45.826412	<p>test</p>	t	\N	testingnew	open-uri20131123-2543-xv8tpi	failed	10	2013-11-23 16:21:28+00	\N	\N	\N	\N	www.youtube.com/embed/Q1qMuGsI81w	b0c3baedebd1c3d520de4fd67fc3f5fa.jpg.png	\N	acct_102uYo2wEU9cVCwN	sk_test_NcU3sn5KvQmCjZZcr4XVvzVq	pk_test_dLozstJciPiTMjS2ZN2kmV4Y	GBP
5	fourth	1	22	10.0	tesst	fourth	http://www.youtube.com/watch?v=Y-tdfSQRn7Q	\N	2013-12-12 19:12:27.555608	2013-12-12 20:25:56.322387	<p>tesst</p>	t	\N	fourth	\N	online	10	2013-12-12 19:15:07+00	\N	\N	\N	\N	www.youtube.com/embed/Y-tdfSQRn7Q	Screenshot_from_2013-11-20_15_06_31.png	\N	acct_102uYo2wEU9cVCwN	sk_test_NcU3sn5KvQmCjZZcr4XVvzVq	pk_test_dLozstJciPiTMjS2ZN2kmV4Y	GBP
6	fifth	1	22	10.0	https://soundcloud.com/kmichelle-4	fifth	http://www.youtube.com/watch?v=Y-tdfSQRn7Q	\N	2013-12-12 19:23:26.148518	2013-12-21 18:31:20.146898	<iframe width="100%" height="450" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Fusers%2F18903675&show_artwork=true&target=_blank"></iframe>	t	\N	fifth	\N	online	10	2013-12-12 19:23:37+00	\N	\N	\N	\N	www.youtube.com/embed/Y-tdfSQRn7Q	Screenshot_from_2013-11-20_15_06_31.png	\N	acct_102uYo2wEU9cVCwN	sk_test_NcU3sn5KvQmCjZZcr4XVvzVq	pk_test_dLozstJciPiTMjS2ZN2kmV4Y	GBP
\.


--
-- Data for Name: projects_curated_pages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY projects_curated_pages (id, project_id, curated_page_id, description, created_at, updated_at, description_html) FROM stdin;
\.


--
-- Name: projects_curated_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('projects_curated_pages_id_seq', 1, false);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('projects_id_seq', 7, true);


--
-- Data for Name: reward_ranges; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY reward_ranges (name, lower, upper) FROM stdin;
\.


--
-- Data for Name: rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY rewards (id, project_id, minimum_value, maximum_backers, description, created_at, updated_at, reindex_versions, row_order, days_to_delivery) FROM stdin;
1	1	10.0	\N	testing	2013-11-09 21:32:21.409645	2013-11-09 21:32:21.409645	\N	0	10
4	3	10.0	10	10	2013-11-21 17:31:11.077387	2013-11-21 17:31:11.077387	\N	0	10
5	4	10.0	10	new	2013-11-23 16:18:50.874146	2013-11-23 16:18:50.874146	\N	0	10
6	4	10.0	10	10	2013-11-27 22:53:39.627191	2013-11-27 22:53:39.627191	\N	4194304	10
7	4	20.0	20	20	2013-11-27 22:53:48.83732	2013-11-27 22:53:48.83732	\N	6291456	20
8	5	10.0	10	10	2013-12-12 19:12:27.623282	2013-12-12 19:12:27.623282	\N	0	10
9	6	10.0	10	10	2013-12-12 19:23:26.155305	2013-12-12 19:23:26.155305	\N	0	10
\.


--
-- Name: rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('rewards_id_seq', 10, true);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY schema_migrations (version) FROM stdin;
20121226120921
20121227012003
20121227012324
20121230111351
20130102180139
20130104005632
20130104104501
20130105123546
20130110191750
20130117205659
20130118193907
20130121162447
20130121204224
20130121212325
20130131121553
20130201200604
20130201202648
20130201202829
20130201205659
20130204192704
20130205143533
20130206121758
20130211174609
20130212145115
20130213184141
20130218201312
20130218201751
20130221171018
20130221172840
20130221175717
20130221184144
20130221185532
20130221201732
20130222163633
20130225135512
20130225141802
20130228141234
20130304193806
20130307074614
20130307090153
20130308200907
20130311191444
20130311192846
20130312001021
20130313032607
20130313034356
20130319131919
20130410181958
20130410190247
20130410191240
20130411193016
20130419184530
20130422071805
20130422072051
20130423162359
20130424173128
20130426204503
20130429142823
20130429144749
20130429153115
20130430203333
20130502175814
20130505013655
20130506191243
20130506191508
20130514132519
20130514185010
20130514185116
20130514185926
20130515192404
20130523144013
20130523173609
20130527204639
20130529171845
20130604171730
20130604172253
20130604175953
20130604180503
20130607222330
20130617175402
20130618175432
20130626122439
20130626124055
20130702192659
20130703171547
20130705131825
20130705184845
20130710122804
20130722222945
20130730232043
20130805230126
20130812191450
20130814174329
20130815161926
20130818015857
20130822215532
20130827210414
20130828160026
20130829180232
20130905153553
20130911180657
20131104082356
20131109192319
20131109192320
20131109192321
20131109192322
20131109192323
20131121161333
20131121161602
20131121161603
20131216225150
20131216225331
20131216233314
20131218221710
20131218221711
20131218221712
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sessions (id, session_id, data, created_at, updated_at) FROM stdin;
16	b14d436a8ee0840b72002c4f3415498c	BAh7CUkiEF9jc3JmX3Rva2VuBjoGRUZJIjFlTkFjcEZUMTk2NllIdnJPRzZF\nUlZaWDNGK0FpZzNrTXJoOXNMN3VTb0NVPQY7AEZJIhl3YXJkZW4udXNlci51\nc2VyLmtleQY7AFRbB1sGaQciIiQyYSQxMCRsMFYvUldrN3RjWEVic1BndTFv\nbnV1SSIOcmV0dXJuX3RvBjsARkkiLmh0dHA6Ly8xMjcuMC4wLjE6MzAwMC9w\nYXltZW50L3N0cmlwZS9hdXRoBjsAVEkiCm9hdXRoBjsARnsA\n	2013-11-20 15:41:47.1048	2013-11-20 15:52:53.264005
6	8b2c50f7a60ade51b866dbc5539b7634	BAh7CkkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIiaHR0cDovLzEyNy4wLjAuMTozMDAwL3Rlc3RpbmcGOwBUSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxbHdoM0lJVlU2bVBMZUFHcFdEVWw3dlBLUlhWSW1sUjdZ\nTyt2eGpydzJGZz0GOwBGSSIYdGhhbmtfeW91X2JhY2tlcl9pZAY7AEZpEUki\nCm9hdXRoBjsARnsA\n	2013-11-09 23:43:52.542375	2013-11-10 00:09:08.447519
7	186998f3c6131d77c8b80ee55ad05776	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzL25ldwY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjFDczNjK0ZHdFVTeE5FdE1OQXFlaytUVjlpSEZI\ndUFvZm05QWFTUzc1cGtRPQY7AEY=\n	2013-11-10 19:02:38.672507	2013-11-11 05:56:21.351731
4	d749f1d491de857c2722f153ed9899db	BAh7CkkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFaYXdqa3U0Qm9OQWFadnAzTEhEczg5SWQzcE5IZHZwNDVVTTA0cDVa\nS3M4PQY7AEZJIgpvYXV0aAY7AEZ7AEkiDnJldHVybl90bwY7AEZJIjJodHRw\nOi8vbG9jYWxob3N0OjMwMDAvcGF5bWVudC9zdHJpcGUvNy9jaGFyZ2UGOwBU\nSSIYdGhhbmtfeW91X2JhY2tlcl9pZAY7AEZpDA==\n	2013-11-09 22:00:13.460468	2013-11-09 23:32:41.71805
2	5f4540473e49add6e957428a6c014acc	BAh7CkkiEF9jc3JmX3Rva2VuBjoGRUZJIjF0ZnN5UkgyK0E3SXhGTDNwK2U1\nL3JjWHlkdStINE5KVVMrbXlHZkVMY2FFPQY7AEZJIhl3YXJkZW4udXNlci51\nc2VyLmtleQY7AFRbB1sGaQYiIiQyYSQxMCRMSllJVVFjQXhMM1dDUFc2N2w0\nQWVlSSIOcmV0dXJuX3RvBjsARkkiLmh0dHA6Ly8xMjcuMC4wLjE6MzAwMC9w\nYXltZW50L3N0cmlwZS9hdXRoBjsAVEkiGHRoYW5rX3lvdV9iYWNrZXJfaWQG\nOwBGaQZJIgpvYXV0aAY7AEZ7AA==\n	2013-11-09 21:28:50.811531	2013-11-09 21:44:17.657207
20	aa8ab4532af7fba9ee6240b94ac72196	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFaNElydmxuWVNpYnk1QWs4YUR5TE4vbzRIYSs0Y2lPT3NZTitvT3JD\nOE9nPQY7AEY=\n	2013-11-21 17:30:18.263092	2013-11-21 17:40:49.54123
21	4cc09571aff2f592353619d86f29a91e	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIiaHR0cDovLzEyNy4wLjAuMTozMDAwL3Rlc3RpbmcGOwBUSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxV3gxeGovalBocCtPZ25ObnY2NmV5T05sRVFiZDIwYmlF\nZGxNTEsrNlFBbz0GOwBG\n	2013-11-23 11:30:10.584912	2013-11-23 11:50:56.097402
9	fc0ddc6f9a0bf5ebbd939d2eae3852d2	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIraHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzLzIvZW1iZWQGOwBU\nSSIQX2NzcmZfdG9rZW4GOwBGSSIxS1N3aUJid2ZSMnhicnQxS3dtaTNrT2dl\nTDUyRktvYVV6S3RYSXpEUC94dz0GOwBG\n	2013-11-18 00:36:45.603767	2013-11-18 00:57:17.734382
22	272116bebfba4de24ceeed17a7b56dea	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFKdzlCUzJ1WUhtYlo0RzMzWVk0R0Q1Rkd1VUxnWkY1ODY5RnBNYld0\nQko4PQY7AEY=\n	2013-11-23 12:29:26.019628	2013-11-23 18:20:36.285547
23	9e05a05fe419d1f01341e2a1ac7cb871	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjF5R0JkY1c3UCtTQ3hzNldOdEdjUk13ZERZaDRlRnBmbGhhVUNZZHQ4\nTUM4PQY7AEY=\n	2013-11-23 21:13:41.06794	2013-11-23 21:13:41.06794
24	c4b1e715749b9b6db68b079bfefa4bf6	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFIYWZIN3ExT3E5TTZFS0YxNGVqcHZFN0dqZ0lMeHZsTnRJbGZKWG1r\nekI4PQY7AEY=\n	2013-11-23 21:54:10.860043	2013-11-23 21:54:10.860043
10	202093f841b7fe7a7853559436a2ff67	BAh7CUkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzL25ldwY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjFjVVJNbGpET2xHalRqbU1lTHdMTjRMdnpGRURD\nQi84cEpTNTFvWWN0STJFPQY7AEZJIhh0aGFua195b3VfYmFja2VyX2lkBjsA\nRmkS\n	2013-11-20 01:51:57.795377	2013-11-20 06:40:19.511277
25	05289e830825156a457fe385a1dcd625	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFBWHMyVW5OTCtESW9WYWxKQzRhemJRajU3NmhFU05DRTk4RlhURmc1\nZG9rPQY7AEY=\n	2013-11-24 14:04:01.526388	2013-11-24 14:04:01.526388
30	4da18886d263bd3239afe41253b1076c	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTo4OTk5\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjF6eU53Q2lVL2tnT3dPYlpEd3Qx\nL2Z2bmlUakt5Mk1rREx1M1B0bEt5VVNFPQY7AEY=\n	2013-11-24 19:21:37.231153	2013-11-24 19:21:37.231153
32	a00610d172ff26987088759e59b7c2c2	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIfaHR0cDovLzEwLjE3Ny4xOTQuMzA6ODk5OS8GOwBUSSIQX2NzcmZfdG9r\nZW4GOwBGSSIxYkxuSkZjajlyRU5kcnVrcUJ3QUg5akI4dllBVWE1SVNOQjZO\nUDM1dlZBOD0GOwBG\n	2013-11-24 19:36:53.386243	2013-11-24 19:36:58.855003
34	159dd65060802e759f701e3aa284ae72	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjF5QVRrL2NacHp6d3JDd3hsMWcrcTRGaEw4R1RGY0hVMklzQUJUMnlX\nSGlnPQY7AEY=\n	2013-11-24 20:16:49.720611	2013-11-24 23:17:53.537189
35	d6f0fd134e7b28fc38a45c6cbdbdb90a	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFjYmUxMkcwemp3N2VCYS9sSENBQkwyRkdSSE5YTk1VcXVYa3JNZUZl\nNUVBPQY7AEY=\n	2013-11-26 21:45:03.805252	2013-11-26 21:45:03.805252
36	57ba786fc741dda1d1ca654c248f2fcc	BAh7CkkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIzaHR0cDovLzEyNy4wLjAuMTozMDAwL3BheW1lbnQvc3RyaXBlLzgyL2No\nYXJnZQY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFXUnovZGdVUEFha0lZTGxB\nV3NweWJVOUJKNm45U29UREtlL2d3cjRLVUtFPQY7AEZJIgpvYXV0aAY7AEZ7\nAEkiGHRoYW5rX3lvdV9iYWNrZXJfaWQGOwBGaVc=\n	2013-11-27 19:13:09.166096	2013-11-30 20:28:51.575675
37	b509d9b23434b9212039e9c5ea4737fe	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFrQmVQWXptM3c5b2tWM241UGYx\nbGpqaDVUSlBiNHVVRDZDZzViZEUzaFJBPQY7AEY=\n	2013-12-11 19:30:41.013803	2013-12-11 19:30:41.013803
38	5d249db138309af08ecc42ee2db0e8cc	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFpWFpmcFIxbE81U3IxWGQzTS9y\nVDEwd1Y0bUhrRTlCdCtNUHpja1EvMmdnPQY7AEY=\n	2013-12-11 21:36:53.940274	2013-12-11 21:36:53.940274
39	0a4a5f6c0d6ed9db10c08033c1bcd9fc	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFyM2w4dnhFRUN5TWtQdDBwdFVW\nbWpkMHZvZTdFZDNpMWhzUGljNDJRSVFFPQY7AEY=\n	2013-12-11 21:48:06.41835	2013-12-11 21:48:06.41835
40	7deaf77bda28a28e0ca8ee4203799e44	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFBYzliTmNBRnl1T2JwWEVhVWdT\nYVQ5VzZKTnhQS09Ta3pNaGw1dWdrRDdrPQY7AEY=\n	2013-12-11 21:58:12.335821	2013-12-11 21:58:12.335821
41	87d4738cf2635076050e8bd99070a739	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFJMkpRZ29TKzR1cTZ2QnR0dHR0\neTBxcE5iK0grK3BxZUJYMjlUbDVnc0lrPQY7AEY=\n	2013-12-11 22:03:45.290979	2013-12-11 22:03:45.290979
42	893575f70c8b3906604e232e3589585d	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFFYklkeEI4Yk5kN1FWNUozV0Nz\nSDF0d0twZmhPOEtqS0ltRjFYcm1mOEVJPQY7AEY=\n	2013-12-11 22:04:19.602955	2013-12-11 22:04:19.602955
100	0933ed1d15d673e94c0abd7f1c41ff61	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFSSHB4ZzFrZVJEaU9yZUVVWERzOEJEc09nQmN3WGNWRFhJWmZyVjI4\nYWRvPQY7AEY=\n	2013-12-15 12:59:26.66661	2013-12-15 12:59:27.279256
44	8f5c98fda1e95f6d5b58956711fefd5c	BAh7CkkiFG9tbmlhdXRoLnBhcmFtcwY6BkVUewBJIhRvbW5pYXV0aC5vcmln\naW4GOwBUIhtodHRwOi8vMTI3LjAuMC4xOjMwMDAvSSIZd2FyZGVuLnVzZXIu\ndXNlci5rZXkGOwBUWwdbBmkGSSIiJDJhJDEwJExKWUlVUWNBeEwzV0NQVzY3\nbDRBZWUGOwBUSSIOcmV0dXJuX3RvBjsARkkiG2h0dHA6Ly8xMjcuMC4wLjE6\nMzAwMC8GOwBUSSIQX2NzcmZfdG9rZW4GOwBGSSIxRHRVVTRMTm5JZDdBc3pw\nZy8wOGIxQ0gwSC9MRmhZZ2FNcyszanV4aGxSbz0GOwBG\n	2013-12-11 22:36:51.684399	2013-12-11 23:04:49.264199
45	ace982dc6e1384a6d4b1e0d162cba686	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjEwZzU3SzNIOXJyZm04dUZJaEJyMmdsWnJldGptN2RUSFhlbGlXUkxw\nazF3PQY7AEY=\n	2013-12-12 17:11:37.462158	2013-12-12 17:11:37.462158
46	2e6aafe35d64336c0c9261fea927dc30	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFMekYvbTFCMzN1WmE3cktxSG1B\namErUzd2dExDbHNJK2t2aHNhWXlBWVNrPQY7AEY=\n	2013-12-12 17:46:27.335008	2013-12-12 17:46:27.335008
47	09d69affd0395e91d1cc527237fb68aa	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjF0LzdNSzl0WkNxTFFVVHo0SnhI\ndStsY2I5REhFRit2Q0xuL0NhQ2tSRW9nPQY7AEY=\n	2013-12-12 17:55:25.352094	2013-12-12 17:55:25.352094
114	75801251aec2be52bf4c8227edf4137d	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIiaHR0cDovLzEyNy4wLjAuMTozMDAwL2JyaXRpc2gGOwBUSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxeEN4bnZTQW45Qm4yY3hLWVlMd0FnWmcwMjdLbWcyeVVQ\nUUZCekpFYjdSST0GOwBG\n	2013-12-19 18:59:55.916961	2013-12-19 18:59:55.916961
51	33b89b67b101bc6fec83f35c9a0489e6	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL2FkbS9wcm9qZWN0cwY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjExSFJVcmhDMG1SS0kwL2JGKzNTZzRwNU9lejVT\nS2QraWlSemJ2TExwdm1RPQY7AEY=\n	2013-12-12 19:11:29.929843	2013-12-12 19:12:47.541273
104	c76a478df00423e08eacc36ebb4385cb	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIiaHR0cDovLzEyNy4wLjAuMTozMDAwL2JyaXRpc2gGOwBUSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxSSt4amhBdDFvbWMvcXpGbTB2NW1KTlpNZHJZa3dWQ3gy\nYnczTzJhd1JsST0GOwBG\n	2013-12-16 23:56:14.72463	2013-12-16 23:56:18.701995
106	771bf8f188e348c82dcb7c5998e37d17	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIyaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleC9mYXZvdXJp\ndGVzBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMXQ4QTJCNHhIMGpTK3Bhbklj\nYlFZRVRmcnZhSWF1QTJPV2hwaTNjS0dtOXc9BjsARg==\n	2013-12-16 23:57:51.055993	2013-12-17 01:34:57.897323
87	0cfc82fb8dd519037d6816cebe1cf678	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjEwNVVHQmlLbFZKT2FZSVVtTERyU2VITlFFM0Vhc2g4M29SR3ZGYjFp\naktvPQY7AEY=\n	2013-12-12 19:49:19.46366	2013-12-12 20:15:49.006108
88	a20e522afd7d5f19d5b37a3ed111f186	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFHMWtma1pxM0RndEV5a2tZMDVM\nSkxtMktrMDdtL2RmR2wvKzFjZ3RqVWh3PQY7AEY=\n	2013-12-12 20:19:34.124758	2013-12-12 20:19:34.124758
89	b10d82bfb29b7f8d8ea2f67de1b393ba	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFlVU44emhHbFZFVDZrdCs3UUpX\nUEw5b3lkVGJYTEdTTHlIL3dUMHF3UW1zPQY7AEY=\n	2013-12-12 20:20:55.092455	2013-12-12 20:20:55.092455
91	603787e96d96d0c1150da40c15ab4373	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFuaDgwdWVFenQ0MG1LMlZYbjFlenJLRVpyZ09KbU5Zc0VzR0NwY01r\ndFUwPQY7AEY=\n	2013-12-12 20:25:45.063973	2013-12-12 20:25:58.641959
92	f4160b665108ff7ab1841b28ca3e4f90	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIiaHR0cDovLzEyNy4wLjAuMTozMDAwL2V4cGxvcmUGOwBUSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxVXk3Yjlra0p5bngrTThzS2FSNURBSGthUEx4RC9TSWdN\nRHNsUnU4amRQTT0GOwBG\n	2013-12-14 22:22:07.812876	2013-12-14 22:23:30.034789
93	12e69822426a11949b7d7d92f3fc01a1	BAh7CEkiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFrQmhNUndqNEppWWg1NDZCUGNo\nWVRYWGhvY091d2NNNkRQOVFpTEg4RXJVPQY7AEZJIhRwcm9qZWN0X2hpc3Rv\ncnkGOwBGWwpJIgx0ZXN0aW5nBjsAVEkiC2ZvdXJ0aAY7AFRJIgpmaWZ0aAY7\nAFRJIg90ZXN0aW5nbmV3BjsAVEkiDGJyaXRpc2gGOwBU\n	2013-12-14 22:34:19.662817	2013-12-15 12:34:38.610096
95	592c81861f8d57112670e0b8f02d7682	BAh7CUkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFIamNxTEFzZmJBd1JkbXFTTDUybmhvNkJySTFzOU11U1ZTdytqbk1E\nTXEwPQY7AEZJIhRwcm9qZWN0X2hpc3RvcnkGOwBGWwZJIg90ZXN0aW5nbmV3\nBjsAVA==\n	2013-12-15 12:37:48.014961	2013-12-15 12:38:06.768076
96	3878f108dc605d53201b22493d4cad80	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIiaHR0cDovLzEyNy4wLjAuMTozMDAwL2JyaXRpc2gGOwBUSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxNFE3RnN4UjVZUHpEOHFPQ0FBNmh0WGNIZU9jTmVwNTRO\nb1JMaWp5c1NhQT0GOwBG\n	2013-12-15 12:38:23.187541	2013-12-15 12:41:14.118679
97	3629d3e35d5039e671581737d9a00eb1	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjEyNkl5MkszZ2tvcTVjNC94OWlY\nNmU1K3lSN0FQTGxtaWRRQUpZTUhmRElZPQY7AEY=\n	2013-12-15 12:52:25.694794	2013-12-15 12:55:03.652727
98	cdc38892149b836e1502d5db19a46c01	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFSUEliaXA4N1ErVnFEYWdDekJY\nUW1JT05qaHAxL2RmenZoYnVRMGNWU01BPQY7AEY=\n	2013-12-15 12:55:23.397232	2013-12-15 12:58:22.678546
127	3fbc79ba0fa9206f3432365f35ddb1ad	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleAY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjFXNkpGZ2ozY2tzY3Z4YSsrMWN1M0ZHQkViaTB3\nR1MyTDh4WDI2aHFwcU1nPQY7AEY=\n	2013-12-30 21:54:30.162397	2013-12-30 21:54:37.852115
155	d362b1aa0ee1deee3b89d1d1a68e42b8	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIgaHR0cDovLzEyNy4wLjAuMTozMDAwL2Fib3V0BjsAVEkiEF9jc3JmX3Rv\na2VuBjsARkkiMXlXQ0o4eGxSUEVuUjEwbUFHU2NsY3pHL1dMbXEvVnd5eG1w\nYkp1NUJqd1U9BjsARg==\n	2014-02-25 19:29:01.128808	2014-02-25 19:54:46.759757
129	73fda647834704f521498ea6065ac973	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleAY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjE0emI1M3JOZTBwUVQ2T3ovM2JKQjVmZXAxUkxo\naVBwYlB0aVNaRjBtc2ZBPQY7AEY=\n	2013-12-30 22:16:19.502495	2013-12-30 22:48:01.601909
113	8d51c0ffbe0ecba154deffdc5593f7a4	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIyaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleC9mYXZvdXJp\ndGVzBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMXg1eUJZT2RpdzYrVUhlK254\nOHNLRUdsWExYREdmT2VnRjhOellFem1YbW89BjsARg==\n	2013-12-18 12:16:19.156278	2013-12-19 13:14:38.867182
130	a5eaf55ebc50181f4dbfc9867711a8b1	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleAY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjFyYnVybTk0MEI1ZTFaUE1kbnBDOGkwT1gxUDgy\nSjRsS0N1WU5ZN0IrMllNPQY7AEY=\n	2014-01-04 01:53:46.880283	2014-01-04 01:54:02.727498
156	b6ca58b409a49a972592ba4875bbbbed	BAh7B0kiDnJldHVybl90bwY6BkVGSSIvaHR0cDovLzEyNy4wLjAuMTozMDAw\nL2NvbW11bml0eV9ndWlkZWxpbmVzBjsAVEkiEF9jc3JmX3Rva2VuBjsARkki\nMVBOd09YaTM2WllscEVMWnUwNE1jdnh1U2h3ZTRsTHBVdmNXT20zNU04dkk9\nBjsARg==\n	2014-02-25 20:04:33.765653	2014-02-25 21:59:05.706221
116	abd837a6ce76390efbae4514e58c822e	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIiaHR0cDovLzEyNy4wLjAuMTozMDAwL2JyaXRpc2gGOwBUSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxODFiY3RDclhyQU5NcVZWazV5RjVKc004aENRK1ZsQmlh\nSmdwSGYwY3V6Yz0GOwBG\n	2013-12-19 19:09:33.108846	2013-12-20 17:56:47.813691
157	78c8c264241ee5526ea2428ffedd1468	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFveXYvNHg4SHpzWnJWQ3h5QWJL\nd2k4cVdmRjVsK1ppcFFzRkg3a1ZkTW1FPQY7AEY=\n	2014-02-26 21:50:35.802999	2014-02-26 21:52:17.258508
158	8a262b59f339e6e403eadc4b59a053c1	BAh7B0kiDnJldHVybl90bwY6BkVGSSIbaHR0cDovLzEyNy4wLjAuMTozMDAw\nLwY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFraHE2NVNyR0JEUkxOL29SQzRK\ncTBGdVZpbjFpSWlkcWNJMHkwVWFBUTNFPQY7AEY=\n	2014-02-26 21:52:30.922187	2014-02-26 21:52:30.922187
118	706e96413323686124dd9fec604d247a	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIgaHR0cDovLzEyNy4wLjAuMTozMDAwL2ZpZnRoBjsAVEkiEF9jc3JmX3Rv\na2VuBjsARkkiMWNjdnRDOUpTK1hZdElKZVZWMzJwN1g0bXQ1MW0vTXZSYmhy\nTUpHSWF3bGc9BjsARg==\n	2013-12-21 18:25:54.075895	2013-12-21 18:31:24.2426
119	f833cd0e58afb9dd582e8c7d3b350a47	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIjaHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzBjsAVEkiEF9jc3Jm\nX3Rva2VuBjsARkkiMXlSbjFjYXdJaWFHRFc2NFdzaTVIelVIeStGL3F6R0U3\nRHQwVkRQOFpkUTQ9BjsARg==\n	2013-12-23 00:27:14.946304	2013-12-23 01:22:20.744587
120	be4ca6cb8e1e7364670f59ffc226ea64	BAh7B0kiDnJldHVybl90bwY6BkVGSSIjaHR0cDovLzEyNy4wLjAuMTozMDAw\nL3Byb2plY3RzBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMVNlbEhzaDJvVU1x\ndVFTMGdZdzRQOTArbkRZVzlGTE1Qc1ZsSjZrcXFZZzA9BjsARg==\n	2013-12-23 18:26:15.534561	2013-12-23 18:26:15.534561
132	cfb7a80492aa74431e35ee092bc89ce8	BAh7CkkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSItaHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzLzUvYmFja2VycwY7\nAFRJIhBfY3NyZl90b2tlbgY7AEZJIjF2VjJtQTYrQVlpM2t4SkRtL0RqdDcr\nSDhmSjM4dVhPVTFyWVRkaHN3NHFnPQY7AEZJIhh0aGFua195b3VfYmFja2Vy\nX2lkBjsARmlYSSIKb2F1dGgGOwBGewA=\n	2014-01-04 02:17:17.025123	2014-01-06 01:25:06.668578
122	47e33c0640cc263fc06444b266237bee	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIjaHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzBjsAVEkiEF9jc3Jm\nX3Rva2VuBjsARkkiMUxNTXl1NncvTjM1WUhzWDhYMlRKSk9zMy9ORFcrYUhX\nM0Y1cWtQdC9XZjQ9BjsARg==\n	2013-12-23 18:26:42.266615	2013-12-23 22:39:39.794766
134	a76361fd19076a4e556187f96521deb4	BAh7CkkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleAY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjFORTVZYk13K1ZidnBuUkFHeU9yQittZHpSbXl6\nTWVONktqR2VFckZoM3ZFPQY7AEZJIhh0aGFua195b3VfYmFja2VyX2lkBjsA\nRmlhSSIKb2F1dGgGOwBGewA=\n	2014-01-06 01:27:57.773793	2014-01-06 01:48:46.712085
136	1ac4572bc4a3a88d0bd5070a66ed9702	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleAY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjE4SE5uUXMvVFdCWHpTS0RXWmEzc2QzeXliZlF0\nRWM1NmRtQStRd3cwdndjPQY7AEY=\n	2014-01-19 15:16:14.785884	2014-01-19 15:16:25.193755
138	4e64e9884d8cefb602ebe14cfb1c434f	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSInaHR0cDovLzEyNy4wLjAuMTozMDAwL3VzZXJzLzEtYWxleAY7AFRJIhBf\nY3NyZl90b2tlbgY7AEZJIjFMRkptTWZQd1VJR1NCbkU1NDQxOFJLY3hLL01N\nUkZYQVdqZklqb1hnZmRBPQY7AEY=\n	2014-02-09 14:24:10.770992	2014-02-09 14:24:11.641889
147	9e99289fffcd6daf4b0076554a1edf66	BAh7B0kiDnJldHVybl90bwY6BkVGSSIraHR0cDovL2xvY2FsaG9zdDozMDAw\nL3Byb2plY3RzLzEvZW1iZWQGOwBUSSIQX2NzcmZfdG9rZW4GOwBGSSIxSURW\ndkR2TU1CaFZYMldUajRXUW5zaXdzUE4zMnZpM3FLNHlTaFVsL3BxST0GOwBG\n	2014-02-13 21:26:45.827396	2014-02-13 21:26:45.827396
148	d30ce3b147173f28c4b1c06b108d7f2c	BAh7B0kiDnJldHVybl90bwY6BkVGSSIraHR0cDovL2xvY2FsaG9zdDozMDAw\nL3Byb2plY3RzLzYvZW1iZWQGOwBUSSIQX2NzcmZfdG9rZW4GOwBGSSIxd0hQ\nZVVFd2ltVGdyM0pJbzNxZzRYVlZZMEs0UUNlZmxScG4zN2ZMZVp2bz0GOwBG\n	2014-02-13 22:35:40.540212	2014-02-13 23:23:55.362266
125	45e6a7c4c33b74a3d7871e494d937e08	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQdJIiIkMmEk\nMTAkbDBWL1JXazd0Y1hFYnNQZ3Uxb251dQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIbaHR0cDovLzEyNy4wLjAuMTozMDAwLwY7AFRJIhBfY3NyZl90b2tlbgY7\nAEZJIjFBMGxkZFZNVE1SK2k1T2RQMTJFRHRLWlpoSUYvOWh1ZTJXdzVHZ0s3\nTTRNPQY7AEY=\n	2013-12-24 01:01:42.203909	2013-12-24 01:12:55.975914
144	afdee6a7b34f3ed22f05ed53fe7e398d	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIhaHR0cDovLzEyNy4wLjAuMTozMDAwL2ZvdXJ0aAY7AFRJIhBfY3NyZl90\nb2tlbgY7AEZJIjFReU1QNTFXSHFhNzNDaVVLQnhDMjhVMHYvVTQzU29ET1ZW\nSS80UDUrOXEwPQY7AEY=\n	2014-02-09 16:29:13.854781	2014-02-09 21:05:12.544583
145	81fcb06d731d0a86fe6cf0bc1a1553be	BAh7B0kiDnJldHVybl90bwY6BkVGSSIhaHR0cDovLzEyNy4wLjAuMTozMDAw\nL2ZvdXJ0aAY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjEwWGVUTUQzVlU0OUJQ\na2d1M3dJM2JIeUNJcDdhclJmOVR6TVlEVUliUHdVPQY7AEY=\n	2014-02-09 21:27:33.946073	2014-02-09 21:27:33.946073
146	44e541f651e417af6995a1b15fc3f7cc	BAh7B0kiDnJldHVybl90bwY6BkVGSSIhaHR0cDovLzEyNy4wLjAuMTozMDAw\nL2ZvdXJ0aAY7AFRJIhBfY3NyZl90b2tlbgY7AEZJIjFKS1Bqd091OGlaeUZP\nZGl5bFV2akwvWW13dlA4WElqTjNSL0VEcTVVTnY0PQY7AEY=\n	2014-02-09 22:38:34.342752	2014-02-09 22:38:34.342752
150	2a83f1bb169cad08bc470c5634427fa6	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIlaHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzLzYGOwBUSSIQX2Nz\ncmZfdG9rZW4GOwBGSSIxdnZqVkE5elpPSFhaTmpCNS9MRHJnVWE5VCtUVnpi\nam8rMEFKbk1kMm5TUT0GOwBG\n	2014-02-13 23:19:41.801322	2014-02-13 23:26:49.644319
153	6aa6e1404584cc92385dfe4a2dfc4948	BAh7B0kiDnJldHVybl90bwY6BkVGSSIraHR0cDovL2xvY2FsaG9zdDozMDAw\nL3Byb2plY3RzLzYvZW1iZWQGOwBUSSIQX2NzcmZfdG9rZW4GOwBGSSIxRkFW\nYjM1Ni82b3BPOWVJejl3QmM4d3Rub0hxOXE2cU1qL1lzdDExcHRmVT0GOwBG\n	2014-02-14 00:02:28.520643	2014-02-14 00:02:28.520643
152	f1e6952892431ebc098d92cd16aebed4	BAh7CEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjoGRVRbB1sGaQZJIiIkMmEk\nMTAkTEpZSVVRY0F4TDNXQ1BXNjdsNEFlZQY7AFRJIg5yZXR1cm5fdG8GOwBG\nSSIlaHR0cDovLzEyNy4wLjAuMTozMDAwL3Byb2plY3RzLzYGOwBUSSIQX2Nz\ncmZfdG9rZW4GOwBGSSIxRk0wK0tnbmZ2VHY4bFdwbUl3cUN3b0ZMSzRhYVZT\nMzZuaUp2bkkrNHFGQT0GOwBG\n	2014-02-13 23:54:16.203132	2014-02-14 00:02:30.005664
\.


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('sessions_id_seq', 158, true);


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY states (id, name, acronym, created_at, updated_at) FROM stdin;
\.


--
-- Name: states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('states_id_seq', 1, false);


--
-- Data for Name: total_backed_ranges; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY total_backed_ranges (name, lower, upper) FROM stdin;
\.


--
-- Data for Name: unsubscribes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY unsubscribes (id, user_id, notification_type_id, project_id, created_at, updated_at) FROM stdin;
\.


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('unsubscribes_id_seq', 1, false);


--
-- Data for Name: updates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY updates (id, user_id, project_id, title, comment, comment_html, created_at, updated_at, exclusive) FROM stdin;
1	1	4	hello	test	<p>test</p>	2013-11-28 21:01:52.729481	2013-11-28 21:01:52.729481	f
2	1	4	hello	test	<p>test</p>	2013-11-28 21:01:53.564346	2013-11-28 21:01:53.564346	f
3	1	4	hello	test	<p>test</p>	2013-11-28 21:01:54.914913	2013-11-28 21:01:54.914913	f
4	1	4	hello	test	<p>test</p>	2013-11-28 21:01:56.925959	2013-11-28 21:01:56.925959	f
5	1	4	hello	test	<p>test</p>	2013-11-28 21:01:57.454246	2013-11-28 21:01:57.454246	f
6	1	4	hello	test	<p>test</p>	2013-11-28 21:02:47.327079	2013-11-28 21:02:47.327079	f
7	1	4	hello	test	<p>test</p>	2013-11-28 21:02:56.126158	2013-11-28 21:02:56.126158	f
8	1	4	hello	gello	<p>gello</p>	2013-11-28 21:04:29.089912	2013-11-28 21:04:29.089912	f
\.


--
-- Name: updates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('updates_id_seq', 8, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY users (id, email, name, nickname, bio, image_url, newsletter, project_updates, created_at, updated_at, admin, full_name, address_street, address_number, address_complement, address_neighbourhood, address_city, address_state, address_zip_code, phone_number, locale, cpf, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, twitter, facebook_link, other_link, uploaded_image, moip_login, state_inscription, stripe_key, stripe_userid, stripe_access_token, favourite_id) FROM stdin;
1	alex.daoud@mac.com	alex	\N	This is my bio. I am testing if the text will wrap or not. Just a test.  Just a test.  Just a test.  Just a test.  Just a test.  Just a test	\N	t	f	2013-11-09 21:28:50.038878	2014-02-25 19:29:01.006548	t	alexandre									pt	\N	$2a$10$LJYIUQcAxL3WCPW67l4AeepzdIqC2sLGTWEkFWQErOKQ12SOGu6Vi	\N	\N	2014-02-25 19:29:00.974123	68	2014-02-25 19:29:01.004829	2014-02-13 23:54:16.001375	127.0.0.1	127.0.0.1				b0c3baedebd1c3d520de4fd67fc3f5fa.jpg.png			pk_test_dLozstJciPiTMjS2ZN2kmV4Y	acct_102uYo2wEU9cVCwN	sk_test_NcU3sn5KvQmCjZZcr4XVvzVq	\N
2	alex.daoud@live.com	alexx	\N	\N	\N	t	f	2013-11-20 15:41:46.230448	2014-02-09 16:28:57.346379	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	pt	\N	$2a$10$l0V/RWk7tcXEbsPgu1onuuSEyovNguNWvSumjRyv1dz7wbgj1MDCa	\N	\N	\N	5	2014-02-09 16:10:03.192835	2013-12-24 01:01:42.091491	127.0.0.1	127.0.0.1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('users_id_seq', 2, true);


--
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY versions (id, item_type, item_id, event, whodunnit, object, created_at) FROM stdin;
1	Reward	1	create	1	\N	2013-11-09 21:32:21.457359
2	Reward	2	create	1	\N	2013-11-09 21:32:21.515369
3	Reward	3	create	1	\N	2013-11-18 00:40:02.333164
4	Reward	2	destroy	1	---\nproject_id: 1\nminimum_value: 10.0\nmaximum_backers: \ndescription: testing\ncreated_at: 2013-11-09 21:32:21.504167000 Z\nupdated_at: 2013-11-09 21:32:21.504167000 Z\nreindex_versions: \nrow_order: 4194304\ndays_to_delivery: 10\nid: 2\n	2013-11-20 06:55:14.238387
5	Reward	4	create	1	\N	2013-11-21 17:31:11.095761
6	Reward	5	create	1	\N	2013-11-23 16:18:50.89891
7	Reward	3	destroy	\N	---\nproject_id: 2\nminimum_value: 10.0\nmaximum_backers: \ndescription: test\ncreated_at: 2013-11-18 00:40:02.294634000 Z\nupdated_at: 2013-11-18 00:40:02.294634000 Z\nreindex_versions: \nrow_order: 0\ndays_to_delivery: 10\nid: 3\n	2013-11-23 16:21:04.935804
8	Reward	6	create	1	\N	2013-11-27 22:53:39.701894
9	Reward	7	create	1	\N	2013-11-27 22:53:48.843406
10	Reward	8	create	1	\N	2013-12-12 19:12:27.6726
11	Reward	9	create	1	\N	2013-12-12 19:23:26.15837
\.


--
-- Name: versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('versions_id_seq', 12, true);


--
-- Name: authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: backers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_pkey PRIMARY KEY (id);


--
-- Name: categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_name_unique UNIQUE (name_pt);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: channel_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY channels
    ADD CONSTRAINT channel_profiles_pkey PRIMARY KEY (id);


--
-- Name: channels_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT channels_projects_pkey PRIMARY KEY (id);


--
-- Name: channels_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT channels_subscribers_pkey PRIMARY KEY (id);


--
-- Name: channels_trustees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY channels_trustees
    ADD CONSTRAINT channels_trustees_pkey PRIMARY KEY (id);


--
-- Name: configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configurations
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: favourites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY favourites
    ADD CONSTRAINT favourites_pkey PRIMARY KEY (id);


--
-- Name: notification_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notification_types
    ADD CONSTRAINT notification_types_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_providers_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_name_unique UNIQUE (name);


--
-- Name: oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: payment_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_pkey PRIMARY KEY (id);


--
-- Name: projects_curated_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY projects_curated_pages
    ADD CONSTRAINT projects_curated_pages_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: reward_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reward_ranges
    ADD CONSTRAINT reward_ranges_pkey PRIMARY KEY (name);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: states_acronym_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_acronym_unique UNIQUE (acronym);


--
-- Name: states_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_name_unique UNIQUE (name);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: total_backed_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY total_backed_ranges
    ADD CONSTRAINT total_backed_ranges_pkey PRIMARY KEY (name);


--
-- Name: unsubscribes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_pkey PRIMARY KEY (id);


--
-- Name: updates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: fk__authorizations_oauth_provider_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__authorizations_oauth_provider_id ON authorizations USING btree (oauth_provider_id);


--
-- Name: fk__authorizations_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__authorizations_user_id ON authorizations USING btree (user_id);


--
-- Name: fk__channels_subscribers_channel_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_channel_id ON channels_subscribers USING btree (channel_id);


--
-- Name: fk__channels_subscribers_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_user_id ON channels_subscribers USING btree (user_id);


--
-- Name: fk__favourites_project_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__favourites_project_id ON favourites USING btree (project_id);


--
-- Name: fk__favourites_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__favourites_user_id ON favourites USING btree (user_id);


--
-- Name: fk__notifications_favourite_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__notifications_favourite_id ON notifications USING btree (favourite_id);


--
-- Name: fk__users_favourite_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk__users_favourite_id ON users USING btree (favourite_id);


--
-- Name: index_authorizations_on_uid_and_oauth_provider_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_uid_and_oauth_provider_id ON authorizations USING btree (uid, oauth_provider_id);


--
-- Name: index_backers_on_key; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_backers_on_key ON backers USING btree (key);


--
-- Name: index_backers_on_project_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_backers_on_project_id ON backers USING btree (project_id);


--
-- Name: index_backers_on_reward_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_backers_on_reward_id ON backers USING btree (reward_id);


--
-- Name: index_backers_on_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_backers_on_user_id ON backers USING btree (user_id);


--
-- Name: index_categories_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_categories_on_name ON categories USING btree (name_pt);


--
-- Name: index_channels_on_permalink; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_on_permalink ON channels USING btree (permalink);


--
-- Name: index_channels_projects_on_channel_id_and_project_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_projects_on_channel_id_and_project_id ON channels_projects USING btree (channel_id, project_id);


--
-- Name: index_channels_projects_on_project_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_channels_projects_on_project_id ON channels_projects USING btree (project_id);


--
-- Name: index_channels_subscribers_on_user_id_and_channel_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_subscribers_on_user_id_and_channel_id ON channels_subscribers USING btree (user_id, channel_id);


--
-- Name: index_channels_trustees_on_channel_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_channels_trustees_on_channel_id ON channels_trustees USING btree (channel_id);


--
-- Name: index_channels_trustees_on_user_id_and_channel_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_trustees_on_user_id_and_channel_id ON channels_trustees USING btree (user_id, channel_id);


--
-- Name: index_configurations_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_configurations_on_name ON configurations USING btree (name);


--
-- Name: index_notification_types_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_notification_types_on_name ON notification_types USING btree (name);


--
-- Name: index_notifications_on_update_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_notifications_on_update_id ON notifications USING btree (update_id);


--
-- Name: index_payment_notifications_on_backer_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_payment_notifications_on_backer_id ON payment_notifications USING btree (backer_id);


--
-- Name: index_projects_on_category_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_projects_on_category_id ON projects USING btree (category_id);


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_projects_on_name ON projects USING btree (name);


--
-- Name: index_projects_on_permalink; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_permalink ON projects USING btree (permalink);


--
-- Name: index_projects_on_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_projects_on_user_id ON projects USING btree (user_id);


--
-- Name: index_rewards_on_project_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_rewards_on_project_id ON rewards USING btree (project_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_unsubscribes_on_notification_type_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_notification_type_id ON unsubscribes USING btree (notification_type_id);


--
-- Name: index_unsubscribes_on_project_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_project_id ON unsubscribes USING btree (project_id);


--
-- Name: index_unsubscribes_on_user_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_user_id ON unsubscribes USING btree (user_id);


--
-- Name: index_updates_on_project_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_updates_on_project_id ON updates USING btree (project_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: backers_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: backers_reward_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_reward_id_reference FOREIGN KEY (reward_id) REFERENCES rewards(id);


--
-- Name: backers_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_authorizations_oauth_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_oauth_provider_id FOREIGN KEY (oauth_provider_id) REFERENCES oauth_providers(id);


--
-- Name: fk_authorizations_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channels_projects_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_projects_project_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_channels_subscribers_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_subscribers_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channels_trustees_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_trustees
    ADD CONSTRAINT fk_channels_trustees_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_trustees_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY channels_trustees
    ADD CONSTRAINT fk_channels_trustees_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_favourites_project_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY favourites
    ADD CONSTRAINT fk_favourites_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_favourites_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY favourites
    ADD CONSTRAINT fk_favourites_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_notifications_favourite_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_notifications_favourite_id FOREIGN KEY (favourite_id) REFERENCES favourites(id);


--
-- Name: fk_users_favourite_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_favourite_id FOREIGN KEY (favourite_id) REFERENCES favourites(id);


--
-- Name: notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_backer_id_fk FOREIGN KEY (backer_id) REFERENCES backers(id);


--
-- Name: notifications_notification_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_notification_type_id_fk FOREIGN KEY (notification_type_id) REFERENCES notification_types(id);


--
-- Name: notifications_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: notifications_update_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_update_id_fk FOREIGN KEY (update_id) REFERENCES updates(id);


--
-- Name: notifications_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: payment_notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_backer_id_fk FOREIGN KEY (backer_id) REFERENCES backers(id);


--
-- Name: projects_category_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_category_id_reference FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: projects_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rewards_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_notification_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_notification_type_id_fk FOREIGN KEY (notification_type_id) REFERENCES notification_types(id);


--
-- Name: unsubscribes_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: updates_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: updates_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

