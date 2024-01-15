-- CALL sp_update_active_players(2023);
CREATE OR REPLACE PROCEDURE sp_update_active_players(par_season INTEGER DEFAULT NULL)
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_season INTEGER;
BEGIN

    v_season = par_season;

    INSERT
    INTO prod.dim_person (identity,
                          person_name,
                          is_active,
                          full_name)
    SELECT identity,
           person_name,
           CASE
               WHEN identity IN (SELECT player_id FROM prod.dim_team WHERE league_season = v_season) THEN TRUE
               ELSE FALSE END AS is_active,
           full_name
    FROM prod.dim_person
    ON CONFLICT (identity)
        DO UPDATE
        SET is_active = EXCLUDED.is_active;

END;
$$;