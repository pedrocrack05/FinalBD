--
-- PostgreSQL database dump
--

-- Dumped from database version 16.5
-- Dumped by pg_dump version 16.3

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
-- Name: log_special_offer(); Type: FUNCTION; Schema: public; Owner: BDO_owner
--

CREATE FUNCTION public.log_special_offer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica si el ComicID corresponde a "Superman en Calzoncillos con Batman Asustado"
    IF NEW.ComicID = (SELECT ComicID FROM Comics WHERE Title = 'Superman en Calzoncillos') THEN
        -- Inserta el nombre y cumpleaños del cliente en la tabla SpecialOffers
        INSERT INTO SpecialOffers (CustomerName, CustomerBirthday)
        VALUES (
                   (SELECT Name FROM Customers WHERE CustomerID = NEW.CustomerID),
                   (SELECT Birthday FROM Customers WHERE CustomerID = NEW.CustomerID)
               );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_special_offer() OWNER TO "BDO_owner";

--
-- Name: refresh_top_customers(); Type: FUNCTION; Schema: public; Owner: BDO_owner
--

CREATE FUNCTION public.refresh_top_customers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW Top_Customers;
    RETURN NULL; -- Los triggers AFTER no necesitan devolver un valor
END;
$$;


ALTER FUNCTION public.refresh_top_customers() OWNER TO "BDO_owner";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: battles; Type: TABLE; Schema: public; Owner: BDO_owner
--

CREATE TABLE public.battles (
    battleid integer NOT NULL,
    heroname character varying(255) NOT NULL,
    villainname character varying(255) NOT NULL,
    outcome character varying(50) NOT NULL,
    battledate date NOT NULL
);


ALTER TABLE public.battles OWNER TO "BDO_owner";

--
-- Name: battles_battleid_seq; Type: SEQUENCE; Schema: public; Owner: BDO_owner
--

CREATE SEQUENCE public.battles_battleid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.battles_battleid_seq OWNER TO "BDO_owner";

--
-- Name: battles_battleid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: BDO_owner
--

ALTER SEQUENCE public.battles_battleid_seq OWNED BY public.battles.battleid;


--
-- Name: characters; Type: TABLE; Schema: public; Owner: BDO_owner
--

CREATE TABLE public.characters (
    characterid integer NOT NULL,
    name character varying(255) NOT NULL,
    powers text[],
    weaknesses text[],
    groupaffiliations text[]
);


ALTER TABLE public.characters OWNER TO "BDO_owner";

--
-- Name: characters_characterid_seq; Type: SEQUENCE; Schema: public; Owner: BDO_owner
--

CREATE SEQUENCE public.characters_characterid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.characters_characterid_seq OWNER TO "BDO_owner";

--
-- Name: characters_characterid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: BDO_owner
--

ALTER SEQUENCE public.characters_characterid_seq OWNED BY public.characters.characterid;


--
-- Name: comics; Type: TABLE; Schema: public; Owner: BDO_owner
--

CREATE TABLE public.comics (
    comicid integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    category character varying(50) NOT NULL
);


ALTER TABLE public.comics OWNER TO "BDO_owner";

--
-- Name: comics_comicid_seq; Type: SEQUENCE; Schema: public; Owner: BDO_owner
--

CREATE SEQUENCE public.comics_comicid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comics_comicid_seq OWNER TO "BDO_owner";

--
-- Name: comics_comicid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: BDO_owner
--

ALTER SEQUENCE public.comics_comicid_seq OWNED BY public.comics.comicid;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: BDO_owner
--

CREATE TABLE public.customers (
    customerid integer NOT NULL,
    name character varying(255) NOT NULL,
    birthday date NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE public.customers OWNER TO "BDO_owner";

--
-- Name: customers_customerid_seq; Type: SEQUENCE; Schema: public; Owner: BDO_owner
--

CREATE SEQUENCE public.customers_customerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_customerid_seq OWNER TO "BDO_owner";

--
-- Name: customers_customerid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: BDO_owner
--

ALTER SEQUENCE public.customers_customerid_seq OWNED BY public.customers.customerid;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: BDO_owner
--

CREATE TABLE public.transactions (
    transactionid integer NOT NULL,
    comicid integer,
    customerid integer,
    purchasedate date NOT NULL,
    totalamount numeric(10,2) NOT NULL
);


ALTER TABLE public.transactions OWNER TO "BDO_owner";

--
-- Name: popular_comics; Type: VIEW; Schema: public; Owner: BDO_owner
--

CREATE VIEW public.popular_comics AS
 SELECT c.comicid,
    c.title,
    count(t.transactionid) AS purchases
   FROM (public.comics c
     JOIN public.transactions t ON ((c.comicid = t.comicid)))
  GROUP BY c.comicid, c.title
 HAVING (count(t.transactionid) > 50);


ALTER VIEW public.popular_comics OWNER TO "BDO_owner";

--
-- Name: specialoffers; Type: TABLE; Schema: public; Owner: BDO_owner
--

CREATE TABLE public.specialoffers (
    specialofferid integer NOT NULL,
    customername character varying(255),
    customerbirthday date
);


ALTER TABLE public.specialoffers OWNER TO "BDO_owner";

--
-- Name: specialoffers_specialofferid_seq; Type: SEQUENCE; Schema: public; Owner: BDO_owner
--

CREATE SEQUENCE public.specialoffers_specialofferid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specialoffers_specialofferid_seq OWNER TO "BDO_owner";

--
-- Name: specialoffers_specialofferid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: BDO_owner
--

ALTER SEQUENCE public.specialoffers_specialofferid_seq OWNED BY public.specialoffers.specialofferid;


--
-- Name: top_customers; Type: MATERIALIZED VIEW; Schema: public; Owner: BDO_owner
--

CREATE MATERIALIZED VIEW public.top_customers AS
 SELECT c.customerid,
    c.name,
    count(t.transactionid) AS totalpurchases,
    sum(t.totalamount) AS totalspent
   FROM (public.customers c
     JOIN public.transactions t ON ((c.customerid = t.customerid)))
  GROUP BY c.customerid, c.name
 HAVING (count(t.transactionid) > 10)
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.top_customers OWNER TO "BDO_owner";

--
-- Name: transactions_transactionid_seq; Type: SEQUENCE; Schema: public; Owner: BDO_owner
--

CREATE SEQUENCE public.transactions_transactionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_transactionid_seq OWNER TO "BDO_owner";

--
-- Name: transactions_transactionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: BDO_owner
--

ALTER SEQUENCE public.transactions_transactionid_seq OWNED BY public.transactions.transactionid;


--
-- Name: villagersandmortalarms; Type: TABLE; Schema: public; Owner: BDO_owner
--

CREATE TABLE public.villagersandmortalarms (
    itemid integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    availability boolean NOT NULL
);


ALTER TABLE public.villagersandmortalarms OWNER TO "BDO_owner";

--
-- Name: villagersandmortalarms_itemid_seq; Type: SEQUENCE; Schema: public; Owner: BDO_owner
--

CREATE SEQUENCE public.villagersandmortalarms_itemid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.villagersandmortalarms_itemid_seq OWNER TO "BDO_owner";

--
-- Name: villagersandmortalarms_itemid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: BDO_owner
--

ALTER SEQUENCE public.villagersandmortalarms_itemid_seq OWNED BY public.villagersandmortalarms.itemid;


--
-- Name: battles battleid; Type: DEFAULT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.battles ALTER COLUMN battleid SET DEFAULT nextval('public.battles_battleid_seq'::regclass);


--
-- Name: characters characterid; Type: DEFAULT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.characters ALTER COLUMN characterid SET DEFAULT nextval('public.characters_characterid_seq'::regclass);


--
-- Name: comics comicid; Type: DEFAULT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.comics ALTER COLUMN comicid SET DEFAULT nextval('public.comics_comicid_seq'::regclass);


--
-- Name: customers customerid; Type: DEFAULT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.customers ALTER COLUMN customerid SET DEFAULT nextval('public.customers_customerid_seq'::regclass);


--
-- Name: specialoffers specialofferid; Type: DEFAULT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.specialoffers ALTER COLUMN specialofferid SET DEFAULT nextval('public.specialoffers_specialofferid_seq'::regclass);


--
-- Name: transactions transactionid; Type: DEFAULT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.transactions ALTER COLUMN transactionid SET DEFAULT nextval('public.transactions_transactionid_seq'::regclass);


--
-- Name: villagersandmortalarms itemid; Type: DEFAULT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.villagersandmortalarms ALTER COLUMN itemid SET DEFAULT nextval('public.villagersandmortalarms_itemid_seq'::regclass);


--
-- Data for Name: battles; Type: TABLE DATA; Schema: public; Owner: BDO_owner
--

INSERT INTO public.battles VALUES (1, 'Superman', 'Lex Luthor', 'defeated', '2024-11-01');
INSERT INTO public.battles VALUES (2, 'Batman', 'The Joker', 'defeated', '2024-11-02');
INSERT INTO public.battles VALUES (3, 'Wonder Woman', 'Cheetah', 'defeated', '2024-11-03');
INSERT INTO public.battles VALUES (4, 'Superman', 'Lex Luthor', 'defeated', '2024-11-04');
INSERT INTO public.battles VALUES (5, 'Batman', 'The Joker', 'defeated', '2024-11-05');
INSERT INTO public.battles VALUES (6, 'Superman', 'Lex Luthor', 'defeated', '2024-11-06');
INSERT INTO public.battles VALUES (7, 'Batman', 'The Penguin', 'draw', '2024-11-07');
INSERT INTO public.battles VALUES (8, 'Wonder Woman', 'Ares', 'won', '2024-11-08');
INSERT INTO public.battles VALUES (9, 'Superman', 'Lex Luthor', 'defeated', '2024-11-09');
INSERT INTO public.battles VALUES (10, 'Batman', 'The Joker', 'defeated', '2024-11-12');
INSERT INTO public.battles VALUES (11, 'Batman', 'The Joker', 'defeated', '2024-11-17');


--
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: BDO_owner
--

INSERT INTO public.characters VALUES (1, 'Superman', '{flight,"super strength","x-ray vision"}', '{kryptonite}', '{"Justice League"}');
INSERT INTO public.characters VALUES (2, 'Batman', '{intelligence,"martial arts",gadgets}', '{"no superpowers"}', '{"Justice League"}');
INSERT INTO public.characters VALUES (3, 'Lex Luthor', '{intelligence,wealth}', '{arrogance}', '{None}');
INSERT INTO public.characters VALUES (4, 'Wonder Woman', '{"super strength",agility,"lasso of truth"}', '{none}', '{"Justice League"}');
INSERT INTO public.characters VALUES (5, 'Thor', '{thunder,"super strength"}', '{arrogance}', '{"Justice League",Avengers}');
INSERT INTO public.characters VALUES (6, 'Hulk', '{"super strength",regeneration}', '{"anger issues"}', '{Avengers}');
INSERT INTO public.characters VALUES (7, 'Flash', '{"super speed",agility}', '{dicks}', '{"Justice League",Avengers}');


--
-- Data for Name: comics; Type: TABLE DATA; Schema: public; Owner: BDO_owner
--

INSERT INTO public.comics VALUES (1, 'Superman en Calzoncillos', 'Una edición especial de Superman con su icónico traje.', 99.99, 'Superhero');
INSERT INTO public.comics VALUES (2, 'Batman: El Caballero Asustado', 'Un cómic emocionante de Batman enfrentando sus mayores miedos.', 75.50, 'Superhero');
INSERT INTO public.comics VALUES (3, 'El Villano Desconocido', 'Una historia oscura sobre un nuevo villano en la ciudad.', 45.00, 'Villain');
INSERT INTO public.comics VALUES (4, 'La Liga de la Justicia: Reunión', 'Un épico encuentro de los héroes más poderosos.', 120.00, 'Superhero');
INSERT INTO public.comics VALUES (5, 'Spider-man; origins', 'La telaraña nunca salia por las manos', 15.00, 'Superhero');


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: BDO_owner
--

INSERT INTO public.customers VALUES (1, 'Mauricio Garcés', '1930-12-16', 'mauricio@example.com');
INSERT INTO public.customers VALUES (2, 'Juana Pérez', '1995-04-10', 'juana.perez@example.com');
INSERT INTO public.customers VALUES (3, 'Pedro González', '1987-11-23', 'pedro.gonzalez@example.com');


--
-- Data for Name: specialoffers; Type: TABLE DATA; Schema: public; Owner: BDO_owner
--

INSERT INTO public.specialoffers VALUES (1, 'Mauricio Garcés', '1930-12-16');
INSERT INTO public.specialoffers VALUES (2, 'Mauricio Garcés', '1930-12-16');
INSERT INTO public.specialoffers VALUES (3, 'Mauricio Garcés', '1930-12-16');


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: BDO_owner
--

INSERT INTO public.transactions VALUES (1, 1, 1, '2024-11-17', 99.99);
INSERT INTO public.transactions VALUES (2, 2, 2, '2024-11-15', 75.50);
INSERT INTO public.transactions VALUES (3, 1, 1, '2024-11-20', 99.99);
INSERT INTO public.transactions VALUES (4, 1, 1, '2024-11-17', 99.99);
INSERT INTO public.transactions VALUES (5, 2, 1, '2024-11-18', 75.50);
INSERT INTO public.transactions VALUES (6, 3, 1, '2024-11-19', 45.00);
INSERT INTO public.transactions VALUES (7, 4, 1, '2024-11-20', 120.00);
INSERT INTO public.transactions VALUES (8, 1, 1, '2024-11-21', 99.99);
INSERT INTO public.transactions VALUES (9, 3, 1, '2024-11-22', 45.00);


--
-- Data for Name: villagersandmortalarms; Type: TABLE DATA; Schema: public; Owner: BDO_owner
--

INSERT INTO public.villagersandmortalarms VALUES (1, 'Lasso of Truth', 'La cuerda mágica de Wonder Woman.', true);
INSERT INTO public.villagersandmortalarms VALUES (2, 'Batarang', 'El icónico arma arrojadiza de Batman.', true);
INSERT INTO public.villagersandmortalarms VALUES (3, 'Kryptonite Fragment', 'Un fragmento de kryptonita que debilita a Superman.', false);
INSERT INTO public.villagersandmortalarms VALUES (4, 'Invisible Jet', 'El avión invisible de Wonder Woman.', true);


--
-- Name: battles_battleid_seq; Type: SEQUENCE SET; Schema: public; Owner: BDO_owner
--

SELECT pg_catalog.setval('public.battles_battleid_seq', 11, true);


--
-- Name: characters_characterid_seq; Type: SEQUENCE SET; Schema: public; Owner: BDO_owner
--

SELECT pg_catalog.setval('public.characters_characterid_seq', 7, true);


--
-- Name: comics_comicid_seq; Type: SEQUENCE SET; Schema: public; Owner: BDO_owner
--

SELECT pg_catalog.setval('public.comics_comicid_seq', 5, true);


--
-- Name: customers_customerid_seq; Type: SEQUENCE SET; Schema: public; Owner: BDO_owner
--

SELECT pg_catalog.setval('public.customers_customerid_seq', 3, true);


--
-- Name: specialoffers_specialofferid_seq; Type: SEQUENCE SET; Schema: public; Owner: BDO_owner
--

SELECT pg_catalog.setval('public.specialoffers_specialofferid_seq', 3, true);


--
-- Name: transactions_transactionid_seq; Type: SEQUENCE SET; Schema: public; Owner: BDO_owner
--

SELECT pg_catalog.setval('public.transactions_transactionid_seq', 9, true);


--
-- Name: villagersandmortalarms_itemid_seq; Type: SEQUENCE SET; Schema: public; Owner: BDO_owner
--

SELECT pg_catalog.setval('public.villagersandmortalarms_itemid_seq', 4, true);


--
-- Name: battles battles_pkey; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.battles
    ADD CONSTRAINT battles_pkey PRIMARY KEY (battleid);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (characterid);


--
-- Name: comics comics_pkey; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.comics
    ADD CONSTRAINT comics_pkey PRIMARY KEY (comicid);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customerid);


--
-- Name: specialoffers specialoffers_pkey; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.specialoffers
    ADD CONSTRAINT specialoffers_pkey PRIMARY KEY (specialofferid);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transactionid);


--
-- Name: villagersandmortalarms villagersandmortalarms_pkey; Type: CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.villagersandmortalarms
    ADD CONSTRAINT villagersandmortalarms_pkey PRIMARY KEY (itemid);


--
-- Name: transactions after_purchase_special_offer; Type: TRIGGER; Schema: public; Owner: BDO_owner
--

CREATE TRIGGER after_purchase_special_offer AFTER INSERT ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.log_special_offer();


--
-- Name: transactions update_top_customers; Type: TRIGGER; Schema: public; Owner: BDO_owner
--

CREATE TRIGGER update_top_customers AFTER INSERT OR DELETE OR UPDATE ON public.transactions FOR EACH STATEMENT EXECUTE FUNCTION public.refresh_top_customers();


--
-- Name: transactions transactions_comicid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_comicid_fkey FOREIGN KEY (comicid) REFERENCES public.comics(comicid);


--
-- Name: transactions transactions_customerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: BDO_owner
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_customerid_fkey FOREIGN KEY (customerid) REFERENCES public.customers(customerid);


--
-- Name: top_customers; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: BDO_owner
--

REFRESH MATERIALIZED VIEW public.top_customers;


--
-- PostgreSQL database dump complete
--

