-- Players Table
CREATE TABLE prod.fct_players
(
    id                                 SERIAL PRIMARY KEY,
    player_key                         TEXT,
    name                               TEXT,
    position                           TEXT,
    week                               INTEGER,
    started                            BOOLEAN,
    team_key                           TEXT,
    manager_name                       TEXT,
    league_id                          INT,
    league_season                      INT,
    points                             FLOAT,
    passing_yards                      INTEGER,
    passing_touchdowns                 INTEGER,
    passing_interceptions              INTEGER,
    rushing_attempts                   INTEGER,
    rushing_yards                      INTEGER,
    rushing_touchdowns                 INTEGER,
    receptions                         INTEGER,
    receiving_yards                    INTEGER,
    receiving_touchdowns               INTEGER,
    return_touchdowns                  INTEGER,
    two_point_conversions              INTEGER,
    fumbles_lost                       INTEGER,
    targets                            INTEGER,
    offensive_fumble_return_td         INTEGER,
    field_goals_0_19_yards             INTEGER,
    field_goals_20_29_yards            INTEGER,
    field_goals_30_39_yards            INTEGER,
    field_goals_40_49_yards            INTEGER,
    field_goals_50_plus_yards          INTEGER,
    point_after_attempt_made           INTEGER,
    points_allowed                     INTEGER,
    sack                               INTEGER,
    interception                       INTEGER,
    fumble_recovery                    INTEGER,
    touchdown                          INTEGER,
    safety                             INTEGER,
    block_kick                         INTEGER,
    kickoff_and_punt_return_touchdowns INTEGER,
    points_allowed_0_points            INTEGER,
    points_allowed_1_6_points          INTEGER,
    points_allowed_7_13_points         INTEGER,
    points_allowed_14_20_points        INTEGER,
    points_allowed_21_27_points        INTEGER,
    points_allowed_28_34_points        INTEGER,
    points_allowed_35_plus_points      INTEGER,
    extra_point_returned               INTEGER,
    field_goals_made                   INTEGER,
    field_goals_total_yards            INTEGER,
    field_goals_missed                 INTEGER,
    CONSTRAINT players_natural_key
        UNIQUE (player_key, week, league_id, league_season)
);

CREATE TABLE prod.fct_matchups
(
    id                      SERIAL PRIMARY KEY,
    week                    INTEGER,
    is_playoffs             BOOLEAN,
    is_consolation          BOOLEAN,
    team_1_key              TEXT,
    team_1_nickname         TEXT,
    team_1_points           FLOAT,
    team_1_projected_points FLOAT,
    is_bye                  BOOLEAN,
    team_2_key              TEXT,
    team_2_nickname         TEXT,
    team_2_points           FLOAT,
    team_2_projected_points FLOAT,
    league_id               INTEGER,
    league_season           INTEGER,
    league_key              TEXT,
    cumulative_points       DOUBLE PRECISION,
    cumulative_wins         INTEGER,
    cumulative_losses       INTEGER,
    rank                    INTEGER,
    CONSTRAINT matchups_natural_key
        UNIQUE (team_1_key, team_2_key, week, league_id, league_season)
);

-- Teams Table
CREATE TABLE prod.dim_team
(
    id                SERIAL PRIMARY KEY,
    name              TEXT,
    team_key          TEXT,
    number_of_moves   INTEGER,
    number_of_trades  INTEGER,
    clinched_playoffs BOOLEAN,
    manager_name      TEXT,
    division_id       INTEGER,
    draft_grade       TEXT,
    rank              INTEGER,
    points_for        FLOAT,
    points_against    FLOAT,
    wins              INTEGER,
    losses            INTEGER,
    league_id         INTEGER,
    league_season     INTEGER,
    player_id         INTEGER,
    league_key        TEXT,
    CONSTRAINT teams_natural_key
        UNIQUE (team_key, league_id, league_season)
);

CREATE TABLE prod.dim_league
(
    id                       SERIAL PRIMARY KEY,
    league_key               TEXT,
    name                     TEXT,
    game_code                TEXT,
    season                   TEXT,
    num_teams                TEXT,
    league_id                INTEGER,
    regular_season_weeks     INTEGER,
    playoff_weeks            INTEGER,
    is_playoff_reseeding     BOOLEAN,
    playoff_last_week        INTEGER,
    regular_season_last_week INTEGER,
    CONSTRAINT teams_natural_key
        UNIQUE (league_key)
);

ALTER TABLE prod.dim_league
    OWNER TO admin;

CREATE TABLE prod.dim_person
(
    identity    SERIAL PRIMARY KEY,
    person_name VARCHAR(255) NOT NULL CHECK (person_name <> ''),
    is_active   BOOLEAN,
    full_name   VARCHAR(255) NOT NULL CHECK (person_name <> '')
);

CREATE TABLE prod.dim_league_categories
(
    identity    SERIAL PRIMARY KEY,
    league_name VARCHAR(255) NOT NULL CHECK (league_name <> '')
);