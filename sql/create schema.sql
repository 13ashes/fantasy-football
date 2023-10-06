CREATE SCHEMA staging;
CREATE SCHEMA loading;

CREATE TABLE loading.matchups
(
    id                      BIGSERIAL PRIMARY KEY,
    week                    INTEGER,
    is_playoffs             BOOLEAN,
    is_consolation          BOOLEAN,
    team_1_key              TEXT,
    team_1_nickname         VARCHAR(255),
    team_1_points           NUMERIC,
    team_1_projected_points NUMERIC,
    is_bye                  BOOLEAN,
    team_2_key              TEXT,
    team_2_nickname         VARCHAR(255),
    team_2_points           NUMERIC,
    team_2_projected_points NUMERIC
)