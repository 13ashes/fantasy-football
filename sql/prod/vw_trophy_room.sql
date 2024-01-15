-- DROP view prod.vw_trophy_recipients;
CREATE OR REPLACE VIEW prod.vw_trophy_recipients AS

SELECT league_id,
       league_season,
       league_name,
       1 as trophy_id,
       '1ST PLACE' AS trophy_type,
       team_1_person AS trophy_recipient,
       power_ranking as trophy_value,
       actual_wins::TEXT || '-' || actual_losses::TEXT as record
FROM prod.vw_analytics
WHERE first_place = TRUE

UNION ALL

SELECT league_id,
       league_season,
       league_name,
       2 as trophy_id,
       '2ND PLACE' AS trophy_type,
       team_1_person AS trophy_recipient,
       power_ranking as trophy_value,
       actual_wins::TEXT || '-' || actual_losses::TEXT as record
FROM prod.vw_analytics
WHERE second_place = TRUE

UNION ALL

SELECT league_id,
       league_season,
       league_name,
       3 as trophy_id,
       '3RD PLACE' AS trophy_type,
       team_1_person AS trophy_recipient,
       power_ranking as trophy_value,
       actual_wins::TEXT || '-' || actual_losses::TEXT as record
FROM prod.vw_analytics
WHERE third_place = TRUE

UNION ALL

SELECT league_id,
       league_season,
       league_name,
       4 as trophy_id,
       'LAST PLACE' AS trophy_type,
       team_1_person AS trophy_recipient,
       power_ranking as trophy_value,
       actual_wins::TEXT || '-' || actual_losses::TEXT as record
FROM prod.vw_analytics
WHERE last_place = TRUE

UNION ALL

SELECT league_id,
       league_season,
       league_name,
       6 as trophy_id,
       'POINTS LEADER' AS trophy_type,
       team_1_person AS trophy_recipient,
       total_team_1_points as trophy_value,
       actual_wins::TEXT || '-' || actual_losses::TEXT as record
FROM prod.vw_analytics
WHERE points_for_leader = TRUE

UNION ALL

SELECT league_id,
       league_season,
       league_name,
       7 as trophy_id,
       'WEEK POINTS LEADER' AS trophy_type,
       team_1_person AS trophy_recipient,
       max_week_points_for as trophy_value,
       actual_wins::TEXT || '-' || actual_losses::TEXT as record
FROM prod.vw_analytics
WHERE max_week_points_for_leader = TRUE

UNION ALL

SELECT league_id,
       league_season,
       league_name,
       5 as trophy_id,
       'POWER RANK LEADER' AS trophy_type,
       team_1_person AS trophy_recipient,
       power_ranking as trophy_value,
       actual_wins::TEXT || '-' || actual_losses::TEXT as record
FROM prod.vw_analytics
WHERE power_rank_leader = TRUE;

select * from prod.vw_trophy_recipients;