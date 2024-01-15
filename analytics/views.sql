CREATE OR REPLACE VIEW prod.vw_players
            (
             id,
             player_key,
             name,
             position,
             week,
             started,
             team_key,
             person,
             manager_name,
             league_id,
             league_name,
             league_season,
             points,
             passing_yards,
             passing_touchdowns,
             passing_interceptions,
             rushing_attempts,
             rushing_yards,
             rushing_touchdowns,
             receptions,
             receiving_yards,
             receiving_touchdowns,
             return_touchdowns,
             two_point_conversions,
             fumbles_lost,
             targets,
             offensive_fumble_return_td,
             field_goals_0_19_yards,
             field_goals_20_29_yards,
             field_goals_30_39_yards,
             field_goals_40_49_yards,
             field_goals_50_plus_yards,
             point_after_attempt_made,
             points_allowed,
             sack,
             interception,
             fumble_recovery,
             touchdown,
             safety,
             block_kick,
             kickoff_and_punt_return_touchdowns,
             points_allowed_0_points,
             points_allowed_1_6_points,
             points_allowed_7_13_points,
             points_allowed_14_20_points,
             points_allowed_21_27_points,
             points_allowed_28_34_points,
             points_allowed_35_plus_points,
             extra_point_returned,
             field_goals_made,
             field_goals_total_yards,
             field_goals_missed)
AS
SELECT players.id,
       player_key,
       players.name,
       position,
       week,
       started,
       players.team_key,
       person_name,
       players.manager_name,
       players.league_id,
       league_name,
       players.league_season,
       points,
       passing_yards,
       passing_touchdowns,
       passing_interceptions,
       rushing_attempts,
       rushing_yards,
       rushing_touchdowns,
       receptions,
       receiving_yards,
       receiving_touchdowns,
       return_touchdowns,
       two_point_conversions,
       fumbles_lost,
       targets,
       offensive_fumble_return_td,
       field_goals_0_19_yards,
       field_goals_20_29_yards,
       field_goals_30_39_yards,
       field_goals_40_49_yards,
       field_goals_50_plus_yards,
       point_after_attempt_made,
       points_allowed,
       sack,
       interception,
       fumble_recovery,
       touchdown,
       safety,
       block_kick,
       kickoff_and_punt_return_touchdowns,
       points_allowed_0_points,
       points_allowed_1_6_points,
       points_allowed_7_13_points,
       points_allowed_14_20_points,
       points_allowed_21_27_points,
       points_allowed_28_34_points,
       points_allowed_35_plus_points,
       extra_point_returned,
       field_goals_made,
       field_goals_total_yards,
       field_goals_missed
FROM prod.fct_players players
         LEFT JOIN prod.dim_team teams ON players.team_key = teams.team_key
         LEFT JOIN prod.dim_person prs ON teams.player_id = prs.identity
         JOIN prod.dim_league_categories league ON players.league_id = league.identity;

ALTER VIEW prod.vw_players
    OWNER TO admin;


-- drop view prod.vw_matchups cascade;
CREATE OR REPLACE VIEW prod.vw_matchups
            (id,
             week,
             is_playoffs,
             is_consolation,
             team_1_key,
             team_1_person,
             team_1_nickname,
             team_1_points,
             team_1_projected_points,
             player_is_active,
             is_bye,
             team_2_key,
             team_2_person,
             team_2_nickname,
             team_2_points,
             team_2_projected_points,
             team_2_is_active,
             cumulative_points,
             cumulative_wins,
             cumulative_losses,
             rank,
             league_id,
             league_name,
             league_key,
             league_season)
AS
SELECT matchups.id,
       week,
       is_playoffs,
       is_consolation,
       team_1_key,
       COALESCE(prs_one.person_name, 'Unknown')::CHARACTER VARYING(255),
       team_1_nickname,
       team_1_points,
       team_1_projected_points,
       prs_one.is_active,
       is_bye,
       team_2_key,
       prs_two.person_name,
       team_2_nickname,
       team_2_points,
       team_2_projected_points,
       prs_two.is_active,
       cumulative_points,
       cumulative_wins,
       cumulative_losses,
       matchups.rank,
       matchups.league_id,
       league.league_name,
       matchups.league_key,
       matchups.league_season
FROM prod.fct_matchups matchups
         LEFT JOIN prod.dim_team team_one_xref ON matchups.team_1_key = team_one_xref.team_key
         LEFT JOIN prod.dim_team team_two_xref ON matchups.team_2_key = team_two_xref.team_key
         LEFT JOIN prod.dim_person prs_one ON team_one_xref.player_id = prs_one.identity
         LEFT JOIN prod.dim_person prs_two ON team_two_xref.player_id = prs_two.identity
         JOIN prod.dim_league_categories league ON matchups.league_id = league.identity;


ALTER VIEW prod.vw_matchups
    OWNER TO admin;

-- DROP view prod.vw_teams;
CREATE OR REPLACE VIEW prod.vw_teams
            (id,
             name,
             team_key,
             person_name,
             person_is_active,
             number_of_moves,
             number_of_trades,
             clinched_playoffs,
             manager_name,
             division_id,
             draft_grade,
             rank,
             points_for,
             points_against,
             wins,
             losses,
             league_id,
             league_name,
             league_season)
AS
SELECT teams.id,
       teams.name,
       teams.team_key,
       COALESCE(person_name, 'Unknown')::CHARACTER VARYING(255),
       prs_one.is_active,
       teams.number_of_moves,
       teams.number_of_trades,
       teams.clinched_playoffs,
       teams.manager_name,
       teams.division_id,
       teams.draft_grade,
       teams.rank,
       teams.points_for,
       teams.points_against,
       teams.wins,
       teams.losses,
       teams.league_id,
       league_name,
       teams.league_season
FROM prod.dim_team teams
         LEFT JOIN prod.dim_person prs_one ON teams.player_id = prs_one.identity
         JOIN prod.dim_league_categories league ON teams.league_id = league.identity;

ALTER VIEW prod.vw_teams
    OWNER TO admin;

CREATE OR REPLACE VIEW prod.vw_leagues (id, league_key, league_name, season, league_id) AS
SELECT fct.identity,
       fct.league_key,
       dim.league_name,
       fct.season,
       fct.league_id
FROM prod.dim_league fct
         JOIN prod.dim_league_categories dim ON fct.league_id = dim.identity;

ALTER TABLE prod.vw_leagues
    OWNER TO admin;


CREATE OR REPLACE VIEW prod.vw_person (id, person_name, league_name, season, league_id) AS
SELECT fct.identity,
       fct.league_key,
       dim.league_name,
       fct.season,
       fct.league_id
FROM prod.dim_league fct
         JOIN prod.dim_league_categories dim ON fct.league_id = dim.identity;

ALTER TABLE prod.vw_leagues
    OWNER TO admin;