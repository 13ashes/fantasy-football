ALTER TABLE public.leagues
ADD COLUMN id serial;

UPDATE public.leagues
SET id = subquery.row_number
FROM (
    SELECT
        league_key,
        ROW_NUMBER() OVER (ORDER BY league_key) AS row_number
    FROM
        public.leagues
) AS subquery
WHERE
    public.leagues.league_key = subquery.league_key;
