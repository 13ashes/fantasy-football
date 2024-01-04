-- CALL migrate_teams_data();
CREATE OR REPLACE PROCEDURE migrate_teams_data()
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO staging.teams(name,
                              team_key,
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
                              league_season)
    SELECT name,
           team_key,
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
           league_season
    FROM loading.teams
    ON CONFLICT ON CONSTRAINT teams_natural_key
        DO UPDATE SET name              = EXCLUDED.name,
                      team_key          = EXCLUDED.team_key,
                      number_of_moves   = EXCLUDED.number_of_moves,
                      number_of_trades  = EXCLUDED.number_of_trades,
                      clinched_playoffs = EXCLUDED.clinched_playoffs,
                      manager_name      = EXCLUDED.manager_name,
                      division_id       = EXCLUDED.division_id,
                      draft_grade       = EXCLUDED.draft_grade,
                      rank              = EXCLUDED.rank,
                      points_for        = EXCLUDED.points_for,
                      points_against    = EXCLUDED.points_against,
                      wins              = EXCLUDED.wins,
                      losses            = EXCLUDED.losses,
                      league_id         = EXCLUDED.league_id,
                      league_season     = EXCLUDED.league_season;

    -- Optional: You can add a DELETE or TRUNCATE statement here if you want to clear the `loading.matchups` table after migration
    -- DELETE FROM loading.teams;

END;
$$;