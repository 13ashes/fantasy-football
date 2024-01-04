CREATE TABLE public.dim_league (
    identity SERIAL PRIMARY KEY,
    league_name VARCHAR(255) NOT NULL CHECK (league_name <> '')
);
INSERT INTO public.dim_league (league_name) VALUES ('IC BOYS');
INSERT INTO public.dim_league (league_name) VALUES ('ASS CLAPPERS');
INSERT INTO public.dim_league (league_name) VALUES ('KUZ DONT LOSE');
INSERT INTO public.dim_league (league_name) VALUES ('LIBERTYVILLE MENS LEAGUE');
INSERT INTO public.dim_league (league_name) VALUES ('DYNASTY CONSORTIUM');