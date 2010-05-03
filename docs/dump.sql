SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET search_path = public, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;
CREATE TABLE quakes (
    id integer NOT NULL,
    date timestamp without time zone,
    coordinates point,
    magnitude double precision,
    location character(200),
    depth integer,
    added timestamp without time zone,
    url character(200),
    identifier character(50)
);
ALTER TABLE public.quakes OWNER TO quakes;
CREATE SEQUENCE quakes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
ALTER TABLE public.quakes_id_seq OWNER TO quakes;
ALTER SEQUENCE quakes_id_seq OWNED BY quakes.id;
ALTER TABLE quakes ALTER COLUMN id SET DEFAULT nextval('quakes_id_seq'::regclass);
CREATE INDEX identifier ON quakes USING btree (identifier);
