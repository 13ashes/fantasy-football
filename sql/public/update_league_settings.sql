ALTER TABLE public.leagues
    ADD COLUMN regular_season_weeks INTEGER;
ALTER TABLE public.leagues
    ADD COLUMN regular_season_last_week INTEGER;
ALTER TABLE public.leagues
    ADD COLUMN playoff_weeks INTEGER;
ALTER TABLE public.leagues
    ADD COLUMN playoff_last_week INTEGER;
ALTER TABLE public.leagues
    ADD COLUMN is_playoff_reseeding BOOLEAN;


WITH stats AS (
    SELECT
        matchups.league_id,
        league_season,
        leagues.league_key,
        COUNT(DISTINCT week) FILTER (WHERE is_playoffs = FALSE) AS regular_season_weeks,
        MAX(week) FILTER (WHERE is_playoffs = FALSE) AS regular_season_last_week,
        COUNT(DISTINCT week) FILTER (WHERE is_playoffs = TRUE) AS playoff_weeks,
        MAX(week) FILTER (WHERE is_playoffs = TRUE) AS playoff_last_week
    FROM staging.matchups
    JOIN public.leagues leagues ON matchups.league_id = leagues.league_id
    GROUP BY matchups.league_id, league_season, leagues.league_key
)

UPDATE public.leagues l
SET
    regular_season_weeks = s.regular_season_weeks,
    regular_season_last_week = s.regular_season_last_week,
    playoff_weeks = s.playoff_weeks,
    playoff_last_week = s.playoff_last_week
FROM stats s
WHERE l.league_key = s.league_key;


UPDATE public.leagues
set is_playoff_reseeding = FALSE
where league_id = 2 and season != '2019';