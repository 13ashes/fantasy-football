-- CALL prod.sp_migrate_matchups_data();
CREATE OR REPLACE PROCEDURE prod.sp_migrate_matchups_data()
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO prod.fct_matchups(week,
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
                                  league_season,
                                  league_key)
    SELECT week,
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
           league_season,
           league_key
    FROM staging.matchups
    ON CONFLICT ON CONSTRAINT matchups_natural_key
        DO UPDATE SET week                    = EXCLUDED.week,
                      is_playoffs             = EXCLUDED.is_playoffs,
                      is_consolation          = EXCLUDED.is_consolation,
                      team_1_key              = EXCLUDED.team_1_key,
                      team_1_nickname         = EXCLUDED.team_1_nickname,
                      team_1_points           = EXCLUDED.team_1_points,
                      team_1_projected_points = EXCLUDED.team_1_projected_points,
                      is_bye                  = EXCLUDED.is_bye,
                      team_2_key              = EXCLUDED.team_2_key,
                      team_2_nickname         = EXCLUDED.team_2_nickname,
                      team_2_points           = EXCLUDED.team_2_points,
                      team_2_projected_points = EXCLUDED.team_2_projected_points,
                      league_id               = EXCLUDED.league_id,
                      league_season           = EXCLUDED.league_season,
                      league_key              = EXCLUDED.league_key;

    -- Optional: You can add a DELETE or TRUNCATE statement here if you want to clear the `staging.matchups` table after migration
    -- DELETE FROM staging.matchups;

END;
$$;