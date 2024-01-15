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

INSERT INTO prod.dim_person (identity, person_name, is_active, full_name)
VALUES (28, 'G. WILLIAMS III', TRUE, 'Gil Williams III'),
       (64, 'M. MCFALL', FALSE, 'Marcus McFall'),
       (65, 'D. MARTIN', FALSE, 'Dalton Martin'),
       (10, 'T. WYCOFF', FALSE, 'Taylor Wycoff'),
       (13, 'I. MACK', FALSE, 'Isaiah Mack'),
       (14, 'A. SCHURR', FALSE, 'AJ Schurr'),
       (15, 'A. AZZATO', TRUE, 'Anthony Azzato'),
       (16, 'B. SCHMIDT', TRUE, 'Brady Schmidt'),
       (17, 'J. DUGUID', TRUE, 'Jake Duguid'),
       (18, 'M. THURMAN', TRUE, 'Mack Thurman'),
       (19, 'M. SCHMITZ', TRUE, 'Michael Schmitz'),
       (20, 'M. KLEIN', TRUE, 'Mikey Klein'),
       (21, 'R. DITTMAN', TRUE, 'Robbie Dittman'),
       (22, 'R. BARTH', FALSE, 'Ryan Barth'),
       (23, 'G. WILLIAMS IV', TRUE, 'Gibby Williams IV'),
       (24, 'M. JACOBSON', TRUE, 'Matt Jacobson'),
       (25, 'A. TAYLOR', FALSE, 'Alex Taylor'),
       (26, 'B. STOCK', TRUE, 'Bill Stock'),
       (27, 'D. ALLEN', TRUE, 'David Allen'),
       (29, 'J. TRAVERS', FALSE, 'Jerry Travers'),
       (30, 'J. SCHMITZ', TRUE, 'John Schmitz'),
       (66, 'J. LUEHRSEN', TRUE, 'John Luehrsen'),
       (67, 'M. EADES', FALSE, 'Mike Eades'),
       (31, 'B. KAY', TRUE, 'Bob Kay'),
       (32, 'S. FANCHER', TRUE, 'Scott Fancher'),
       (40, 'J. TEDDER', FALSE, 'Joe Tedder'),
       (44, 'AUGUST', FALSE, 'August'),
       (45, 'CARTER', FALSE, 'Carter'),
       (46, 'N. PERRY', FALSE, 'Nate'),
       (48, 'BRIAN', FALSE, 'Brian'),
       (49, 'CHANCE', FALSE, 'Chance'),
       (50, 'DAVID', FALSE, 'David'),
       (51, 'DAVID I', FALSE, 'David_I'),
       (52, 'JAKE', FALSE, 'Jake'),
       (53, 'K. BENNETT', FALSE, 'Keith Bennett'),
       (54, 'MATT', FALSE, 'Matt'),
       (55, 'NICK', FALSE, 'Nick'),
       (56, 'R. SHAFIQ', FALSE, 'Razi Shafiq'),
       (57, 'R. DOLGIN', FALSE, 'Ronny Dolgin'),
       (58, 'S. DOLGIN', FALSE, 'Sammy Dolgin'),
       (59, 'TAYLOR', FALSE, 'Taylor'),
       (60, 'TJ', FALSE, 'TJ'),
       (61, 'DUSTIN', FALSE, 'Dustin'),
       (62, 'NATHAN', FALSE, 'Nathan'),
       (1, 'D. ANGEL', TRUE, 'Diego Angel'),
       (2, 'A. KNIGHT', TRUE, 'Alex Knight'),
       (3, 'M. STAMMEN', TRUE, 'Marcus Stammen'),
       (4, 'M. RAMIREZ', TRUE, 'Manny Ramirez'),
       (5, 'P. MCGUSHIN', TRUE, 'Patrick McGushin'),
       (6, 'R. SCHWINN', TRUE, 'Richard Schwinn'),
       (7, 'R. OAKES', TRUE, 'Ryan Oakes'),
       (8, 'S. WARD', TRUE, 'Steve Ward'),
       (9, 'T. FANCHER', TRUE, 'Tony Fancher'),
       (11, 'A. ZACK', TRUE, 'Adam Zack'),
       (12, 'I. HASAN', TRUE, 'Imran Hasan'),
       (33, 'A. ZARA', TRUE, 'Alex Zara'),
       (34, 'A. SWETNAM', TRUE, 'Andrew Swetnam'),
       (35, 'T. PISANI', TRUE, 'Tony Pisani'),
       (36, 'B. TEETER', TRUE, 'Ben Teeter'),
       (37, 'B. ISLEY', TRUE, 'Brian Isley'),
       (38, 'O. SALAZAR', TRUE, 'Oscar Salazar'),
       (39, 'G. HARDAWAY', TRUE, 'Geoff Hardaway'),
       (41, 'S. TURETSKY', TRUE, 'Steve Turetsky'),
       (42, 'W. HIGHTOWER', TRUE, 'Will Hightower'),
       (43, 'Z. HILBORN', TRUE, 'Zach Hilborn'),
       (47, 'H. COHEN', TRUE, 'Hyman Cohen'),
       (63, 'A. HOLMES', TRUE, 'Alex Holmes');



CREATE TABLE prod.dim_league_categories
(
    identity    SERIAL PRIMARY KEY,
    league_name VARCHAR(255) NOT NULL CHECK (league_name <> '')
);
INSERT INTO prod.dim_league_categories (league_name)
VALUES ('IC BOYS'),
       ('ASS CLAPPERS'),
       ('KUZ DONT LOSE'),
       ('LIBERTYVILLE MENS LEAGUE'),
       ('DYNASTY CONSORTIUM');