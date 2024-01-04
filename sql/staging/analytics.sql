-- DROP VIEW staging.vw_analytics;
CREATE OR REPLACE VIEW staging.vw_analytics AS

-- Step 1: Actual wins and losses
WITH ActualWinsLosses AS (SELECT league_name,
                                 league_id,
                                 league_season,
                                 team_1_key,
                                 team_1_person,
                                 SUM(CASE WHEN team_1_points > team_2_points THEN 1 ELSE 0 END) AS actual_wins,
                                 SUM(CASE WHEN team_1_points < team_2_points THEN 1 ELSE 0 END) AS actual_losses,
                                 SUM(CASE WHEN team_1_points > team_2_points THEN 1 ELSE 0 END) / COUNT(*)::numeric as actual_winning_percentage,
                                 SUM(team_1_points)                                             AS total_team_1_points,
                                 SUM(team_2_points)                                             AS total_team_2_points
                          FROM staging.vw_matchups
                          WHERE NOT is_playoffs
                            AND NOT is_bye
                          GROUP BY league_name, league_id, league_season, team_1_key, team_1_person),

-- Step 2: Calculate the average
     Averages AS (SELECT league_name,
                         league_id,
                         league_season,
                         week,
                         PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY team_1_points) AS median_points
                  FROM staging.vw_matchups
                  WHERE NOT is_playoffs
                  GROUP BY league_name, league_id, league_season, week),

-- Step 3: Wins and losses based on comparison with average score
     AverageWinsLosses AS (SELECT v.league_name,
                                  v.league_id,
                                  v.league_season,
                                  v.team_1_key,
                                  v.team_1_person,
                                  SUM(CASE WHEN v.team_1_points > av.median_points THEN 1 ELSE 0 END) AS average_wins,
                                  SUM(CASE WHEN v.team_1_points < av.median_points THEN 1 ELSE 0 END) AS average_losses,
                                  SUM(CASE WHEN v.team_1_points > av.median_points THEN 1 ELSE 0 END) / COUNT(*)::numeric as average_winning_percentage
                           FROM staging.vw_matchups v
                                    JOIN Averages av
                                         ON v.league_name = av.league_name AND v.league_season = av.league_season AND
                                            v.week = av.week
                           WHERE NOT is_playoffs
                             AND NOT is_bye
                           GROUP BY v.league_name, v.league_id, v.league_season, v.team_1_key, v.team_1_person),

-- Step 4: Aggregate both win/loss metrics
     AggregatedWinsLosses AS (SELECT a.league_name,
                                     a.league_id,
                                     a.league_season,
                                     a.team_1_key,
                                     a.team_1_person,
                                     a.actual_wins,
                                     a.actual_losses,
                                     a.total_team_1_points,
                                     a.total_team_2_points,
                                     COALESCE(aw.average_wins, 0)                      AS average_wins,
                                     COALESCE(aw.average_losses, 0)                    AS average_losses,
                                     a.actual_wins + COALESCE(aw.average_wins, 0)      AS total_wins,
                                     a.actual_losses + COALESCE(aw.average_losses, 0)  AS total_losses,
                                     actual_winning_percentage,
                                     average_winning_percentage
                              FROM ActualWinsLosses a
                                       LEFT JOIN AverageWinsLosses aw ON a.league_name = aw.league_name AND
                                                                         a.league_season = aw.league_season AND
                                                                         a.team_1_person = aw.team_1_person)

-- Step 5: Produce rankings
SELECT league_name,
       base.league_id,
       base.league_season,
       team_1_person,
       total_team_1_points,
       total_team_2_points,
       RANK() OVER (PARTITION BY league_name, base.league_season ORDER BY actual_wins DESC, actual_losses, total_team_1_points DESC) AS regular_season_actual_ranking,
       RANK() OVER (PARTITION BY league_name, base.league_season ORDER BY total_wins DESC, total_losses, total_team_1_points DESC)   AS regular_season_total_ranking,
       ((total_team_1_points * 2) + (total_team_1_points * actual_winning_percentage) + (total_team_1_points * average_winning_percentage)) AS power_ranking,
       teams.rank as final_ranking,
       actual_wins,
       actual_losses,
       average_wins,
       average_losses,
       total_wins,
       total_losses
FROM AggregatedWinsLosses base
join staging.teams teams on base.team_1_key = teams.team_key
WHERE base.league_id = 1 and base.league_season = 2013
;

SELECT *
FROM staging.vw_analytics
WHERE league_season = 2013 and league_id  = 1;
