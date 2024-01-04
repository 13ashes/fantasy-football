-- CALL migrate_matchups_data();
CREATE OR REPLACE PROCEDURE migrate_matchups_data()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO staging.matchups(
        week,
        is_playoffs,
        is_consolation,
        team_1_key,
        team_1_nickname,
        team_1_points,
        team_1_projected_points,
        is_bye,
        team_2_key,
        team_2_nickname,
        team_2_points,
        team_2_projected_points,
        league_id,
        league_season
    )
    SELECT
        week,
        is_playoffs,
        is_consolation,
        team_1_key,
        team_1_nickname,
        team_1_points,
        team_1_projected_points,
        is_bye,
        team_2_key,
        team_2_nickname,
        team_2_points,
        team_2_projected_points,
        league_id,
        league_season
    FROM loading.matchups
    ON CONFLICT ON CONSTRAINT matchups_natural_key
    DO UPDATE SET
        week = EXCLUDED.week,
        is_playoffs = EXCLUDED.is_playoffs,
        is_consolation = EXCLUDED.is_consolation,
        team_1_key = EXCLUDED.team_1_key,
        team_1_nickname = EXCLUDED.team_1_nickname,
        team_1_points = EXCLUDED.team_1_points,
        team_1_projected_points = EXCLUDED.team_1_projected_points,
        is_bye = EXCLUDED.is_bye,
        team_2_key = EXCLUDED.team_2_key,
        team_2_nickname = EXCLUDED.team_2_nickname,
        team_2_points = EXCLUDED.team_2_points,
        team_2_projected_points = EXCLUDED.team_2_projected_points,
        league_id = EXCLUDED.league_id,
        league_season = EXCLUDED.league_season;

    -- Optional: You can add a DELETE or TRUNCATE statement here if you want to clear the `loading.matchups` table after migration
    -- DELETE FROM loading.matchups;

END;
$$;