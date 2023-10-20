CREATE SCHEMA staging;
CREATE SCHEMA loading;

CREATE TABLE loading.matchup_stats
(
    week                    INTEGER,
    is_playoffs             BOOLEAN,
    is_consolation          BOOLEAN,
    team_1_key              VARCHAR(255),
    team_1_nickname         VARCHAR(255),
    team_1_points           FLOAT,
    team_1_projected_points FLOAT,
    is_bye                  BOOLEAN,
    team_2_key              VARCHAR(255),
    team_2_nickname         VARCHAR(255),
    team_2_points           FLOAT,
    team_2_projected_points FLOAT
);

CREATE TABLE loading.team_stats
(
    week                    INTEGER,
    is_playoffs             BOOLEAN,
    is_consolation          BOOLEAN,
    team_1_key              VARCHAR(255),
    team_1_nickname         VARCHAR(255),
    team_1_points           FLOAT,
    team_1_projected_points FLOAT,
    is_bye                  BOOLEAN,
    team_2_key              VARCHAR(255),
    team_2_nickname         VARCHAR(255),
    team_2_points           FLOAT,
    team_2_projected_points FLOAT
);


CREATE TABLE loading.player_stats
(
    player_key                         VARCHAR(255),
    name                               VARCHAR(255),
    position                           VARCHAR(50),
    week                               INTEGER,
    started                            BOOLEAN,
    team_key                           VARCHAR(255),
    manager_name                       VARCHAR(255),
    points                             FLOAT,
    passing_yards                      FLOAT,
    passing_touchdowns                 FLOAT,
    interceptions                      FLOAT,
    rushing_attempts                   FLOAT,
    rushing_yards                      FLOAT,
    rushing_touchdowns                 FLOAT,
    targets                            FLOAT,
    receptions                         FLOAT,
    receiving_yards                    FLOAT,
    receiving_touchdowns               FLOAT,
    return_touchdowns                  FLOAT,
    two_point_conversions              FLOAT,
    fumbles_lost                       FLOAT,
    offensive_fumble_return_td         FLOAT,
    field_goals_0_19_yards             FLOAT,
    field_goals_20_29_yards            FLOAT,
    field_goals_30_39_yards            FLOAT,
    field_goals_40_49_yards            FLOAT,
    field_goals_50_plus_yards          FLOAT,
    point_after_attempt_made           FLOAT,
    points_allowed                     FLOAT,
    sack                               FLOAT,
    interception                       FLOAT,
    fumble_recovery                    FLOAT,
    touchdown                          FLOAT,
    safety                             FLOAT,
    block_kick                         FLOAT,
    kickoff_and_punt_return_touchdowns FLOAT,
    points_allowed_0_points            FLOAT,
    points_allowed_1_6_points          FLOAT,
    points_allowed_7_13_points         FLOAT,
    points_allowed_14_20_points        FLOAT,
    points_allowed_21_27_points        FLOAT,
    points_allowed_28_34_points        FLOAT,
    points_allowed_35_plus_points      FLOAT,
    extra_point_returned               FLOAT
);

