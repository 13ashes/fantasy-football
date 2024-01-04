ALTER TABLE staging.matchups ADD COLUMN league_key TEXT;

with base as (
    SELECT league_id, season, league_key from public.leagues
)
UPDATE staging.matchups
set league_key = base.league_key
from base
where matchups.league_id = base.league_id and matchups.league_season = base.season::INT;