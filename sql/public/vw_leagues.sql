create view vw_leagues(id, league_key, league_name, season, league_id) as
SELECT leagues.id,
       leagues.league_key,
       dim_league.league_name,
       leagues.season,
       leagues.league_id
FROM leagues
         JOIN dim_league ON leagues.league_id = dim_league.identity;

alter table vw_leagues
    owner to admin