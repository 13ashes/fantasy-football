create view public.vw_leagues (league_key, league_name, season, league_id) as
select league_key,
       dim_league.league_name,
       season,
       league_id
from public.leagues
join public.dim_league on leagues.league_id = dim_league.identity