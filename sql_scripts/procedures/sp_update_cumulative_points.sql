-- ALTER TABLE prod.matchups ADD COLUMN cumulative_points FLOAT;
-- ALTER TABLE prod.matchups ADD COLUMN cumulative_wins INT;
-- ALTER TABLE prod.matchups ADD COLUMN cumulative_losses INT;
-- ALTER TABLE prod.matchups ADD COLUMN rank INT;

CREATE OR REPLACE PROCEDURE sp_update_cumulative_points()
    LANGUAGE plpgsql
AS
$$
BEGIN

    -- Create a temporary table to compute the cumulative points for each person, week, league_id, and league_season
    WITH base AS (SELECT league_id,
                         league_season,
                         week,
                         team_1_key,
                         team_2_key,
                         SUM(team_1_points) OVER (
                             PARTITION BY league_id, league_season, team_1_key
                             ORDER BY week
                             RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                             ) AS cumulative_points,
                         SUM(CASE WHEN team_1_points > team_2_points THEN 1 ELSE 0 END) OVER (
                             PARTITION BY league_id, league_season, team_1_key
                             ORDER BY week
                             RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                             ) AS cumulative_wins,
                         SUM(CASE WHEN team_1_points <= team_2_points THEN 1 ELSE 0 END) OVER (
                             PARTITION BY league_id, league_season, team_1_key
                             ORDER BY week
                             RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                             ) AS cumulative_losses
                  FROM staging.matchups
                  WHERE is_playoffs = FALSE),
         ranking AS (SELECT league_id,
                            league_season,
                            week,
                            team_1_key,
                            team_2_key,
                            cumulative_points,
                            cumulative_wins,
                            cumulative_losses,
                            RANK() OVER (
                                PARTITION BY league_id, league_season, week
                                ORDER BY cumulative_wins DESC, cumulative_points DESC
                                ) AS rank
                     FROM base)

    INSERT INTO staging.matchups (league_id,
                                  league_season,
                                  week,
                                  team_1_key,
                                  team_2_key,
                                  cumulative_points,
                                  cumulative_wins,
                                  cumulative_losses,
                                  rank)
    SELECT *
    FROM ranking
    on CONFLICT on CONSTRAINT matchups_natural_key
    DO UPDATE
    SET cumulative_points = excluded.cumulative_points,
        cumulative_wins = excluded.cumulative_wins,
        cumulative_losses = excluded.cumulative_losses,
        rank = excluded.rank;

END;
$$;

-- To call the procedure:
-- CALL sp_update_cumulative_points();
