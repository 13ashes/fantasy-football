-- DROP VIEW prod.vw_analytics cascade;
CREATE OR REPLACE VIEW prod.vw_analytics AS

-- Step 1: Actual wins and losses
WITH ActualWinsLosses AS (SELECT league_name,
                                 league_id,
                                 league_key,
                                 league_season,
                                 team_1_key,
                                 team_1_person,
                                 player_is_active,
                                 SUM(CASE WHEN team_1_points > team_2_points THEN 1 ELSE 0 END) AS actual_wins,
                                 SUM(CASE WHEN team_1_points < team_2_points THEN 1 ELSE 0 END) AS actual_losses,
                                 SUM(CASE WHEN team_1_points > team_2_points THEN 1 ELSE 0 END) /
                                 COUNT(*)::NUMERIC                                              AS actual_winning_percentage,
                                 SUM(team_1_points)                                             AS total_team_1_points,
                                 SUM(team_2_points)                                             AS total_team_2_points
                          FROM prod.vw_matchups
                          WHERE NOT is_playoffs
                            AND NOT is_bye
                          GROUP BY league_name, league_id, league_key, league_season, team_1_key, team_1_person, player_is_active),

-- Step 2: Calculate the average
     Averages AS (SELECT league_name,
                         league_id,
                         league_key,
                         league_season,
                         week,
                         PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY team_1_points) AS median_points
                  FROM prod.vw_matchups
                  WHERE NOT is_playoffs
                  GROUP BY league_name, league_id, league_key, league_season, week),

-- Step 3: Wins and losses based on comparison with average score
     AverageWinsLosses AS (SELECT v.league_name,
                                  v.league_id,
                                  v.league_key,
                                  v.league_season,
                                  v.team_1_key,
                                  v.team_1_person,
                                  SUM(CASE WHEN v.team_1_points > av.median_points THEN 1 ELSE 0 END) AS average_wins,
                                  SUM(CASE WHEN v.team_1_points < av.median_points THEN 1 ELSE 0 END) AS average_losses,
                                  SUM(CASE WHEN v.team_1_points > av.median_points THEN 1 ELSE 0 END) /
                                  COUNT(*)::NUMERIC                                                   AS average_winning_percentage
                           FROM prod.vw_matchups v
                                    JOIN Averages av
                                         ON v.league_name = av.league_name AND v.league_season = av.league_season AND
                                            v.week = av.week
                           WHERE NOT is_playoffs
                             AND NOT is_bye
                           GROUP BY v.league_name, v.league_id, v.league_key, v.league_season, v.team_1_key, v.team_1_person),

-- Step 4: Aggregate both win/loss metrics
     AggregatedWinsLosses AS (SELECT a.league_name,
                                     a.league_id,
                                     a.league_key,
                                     a.league_season,
                                     a.team_1_key,
                                     a.team_1_person,
                                     a.player_is_active,
                                     a.actual_wins,
                                     a.actual_losses,
                                     a.total_team_1_points,
                                     a.total_team_2_points,
                                     COALESCE(aw.average_wins, 0)                     AS average_wins,
                                     COALESCE(aw.average_losses, 0)                   AS average_losses,
                                     a.actual_wins + COALESCE(aw.average_wins, 0)     AS total_wins,
                                     a.actual_losses + COALESCE(aw.average_losses, 0) AS total_losses,
                                     actual_winning_percentage,
                                     average_winning_percentage
                              FROM ActualWinsLosses a
                                       LEFT JOIN AverageWinsLosses aw ON a.league_name = aw.league_name AND
                                                                         a.league_season = aw.league_season AND
                                                                         a.team_1_person = aw.team_1_person),

     MaxPlayerPoints AS (SELECT team_1_key,
                                league_id,
                                league_season,
                                MAX(team_1_points) AS max_week_points_for
                         FROM prod.vw_matchups
                         GROUP BY team_1_key, league_id, league_season),
     MaxPlayerPointsWeek AS (SELECT mp.team_1_key,
                                    mp.league_id,
                                    mp.league_season,
                                    max_week_points_for,
                                    vm.week                                                                              AS week,
                                    RANK()
                                    OVER (PARTITION BY mp.league_id, mp.league_season ORDER BY max_week_points_for DESC) AS max_week_points_for_rank
                             FROM MaxPlayerPoints mp
                                      JOIN prod.vw_matchups vm
                                           ON mp.team_1_key = vm.team_1_key AND mp.league_id = vm.league_id AND
                                              mp.league_season = vm.league_season AND
                                              mp.max_week_points_for = vm.team_1_points)

SELECT league_name,
       base.league_id,
       base.league_key,
       base.league_season,
       leagues.num_teams as num_teams,
       team_1_person,
       player_is_active,
       total_team_1_points,
       total_team_2_points,
       actual_wins,
       actual_losses,
       teams.rank                                                                                                                           AS final_ranking,
       RANK() OVER (PARTITION BY league_name, base.league_season ORDER BY actual_wins DESC, actual_losses, total_team_1_points DESC)        AS regular_season_ranking,
       ((total_team_1_points * 2) + (total_team_1_points * actual_winning_percentage) + (total_team_1_points * average_winning_percentage)) AS power_ranking,
       RANK() OVER (PARTITION BY league_name, base.league_season ORDER BY ((total_team_1_points * 2) + (total_team_1_points * actual_winning_percentage) + (total_team_1_points * average_winning_percentage)) DESC) AS power_rank,
       RANK() OVER (PARTITION BY league_name, base.league_season ORDER BY total_team_1_points DESC)                                         AS points_ranking,
       mp.week                                                                                                                              AS max_points_for_week,
       mp.max_week_points_for                                                                                                               AS max_week_points_for,
       mp.max_week_points_for_rank                                                                                                          AS max_week_points_for_rank,
       CASE WHEN teams.rank = 1 THEN TRUE ELSE FALSE END AS first_place,
       CASE WHEN teams.rank = 2 THEN TRUE ELSE FALSE END AS second_place,
       CASE WHEN teams.rank = 3 THEN TRUE ELSE FALSE END AS third_place,
       CASE WHEN teams.rank = leagues.num_teams::INTEGER THEN TRUE ELSE FALSE END AS last_place,
       CASE WHEN RANK() OVER (PARTITION BY league_name, base.league_season ORDER BY total_team_1_points DESC) = 1 THEN TRUE ELSE FALSE END AS points_for_leader,
       CASE WHEN RANK() OVER (PARTITION BY league_name, base.league_season ORDER BY ((total_team_1_points * 2) + (total_team_1_points * actual_winning_percentage) + (total_team_1_points * average_winning_percentage)) DESC) = 1 THEN TRUE ELSE FALSE END AS power_rank_leader,
       CASE WHEN mp.max_week_points_for_rank = 1 THEN TRUE ELSE FALSE END AS max_week_points_for_leader

FROM AggregatedWinsLosses base
         JOIN prod.dim_team teams ON base.team_1_key = teams.team_key
         JOIN MaxPlayerPointsWeek mp ON base.team_1_key = mp.team_1_key
         JOIN prod.dim_league leagues ON base.league_key = leagues.league_key;

SELECT *
FROM prod.vw_matchups
WHERE league_key = '423.l.653974';