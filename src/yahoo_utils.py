import os
from _datetime import datetime
import requests
import xmltodict
import pprint
import pandas as pd
import ast
from dotenv import load_dotenv

load_dotenv()

pp = pprint.PrettyPrinter(indent=2)


# Authentication
def authenticate():
    token = os.getenv("YAHOO_ACCESS_TOKEN")
    authorization = "Bearer " + token
    headers = {'Authorization': authorization}
    return headers


def get_leagues(headers):
    uri = "https://fantasysports.yahooapis.com/fantasy/v2/users;use_login=1/games/leagues"
    response = requests.get(uri, headers=headers)
    pp.pprint(response)
    data = xmltodict.parse(response.text)
    # Extracting the necessary data from the nested structure
    games = data["fantasy_content"]["users"]["user"]["games"]["game"]
    league_dicts = []

    # Iterating through games and extracting league information
    for game in games:
        if "leagues" in game and game["leagues"] is not None:
            game_leagues = game["leagues"]["league"]
            if not isinstance(game_leagues, list):
                game_leagues = [game_leagues]
            for league in game_leagues:
                league_dict = {
                    "league_key": league["league_key"],
                    "name": league["name"],
                    "game_code": league["game_code"],
                    "season": league["season"],
                    "num_teams": league["num_teams"]
                }
                league_dicts.append(league_dict)

    # Converting list of dictionaries to DataFrame
    leagues_df = pd.DataFrame(league_dicts,
                              columns=['league_key', 'name', 'game_code', 'season', 'num_teams'])
    return leagues_df


def get_league_settings(headers, league_key):
    uri = f"https://fantasysports.yahooapis.com/fantasy/v2/leagues;league_keys={league_key}/settings"
    response = requests.get(uri, headers=headers)
    pp.pprint(response)
    settings_content = xmltodict.parse(response.text)

    stat_map = {}
    for stat in settings_content["fantasy_content"]["leagues"]["league"]["settings"]["stat_categories"]["stats"][
        "stat"]:
        stat_map[stat['stat_id']] = stat['name']

    # initialize dictionary
    league_settings = {}
    playoffs_start_week = settings_content['fantasy_content']['leagues']['league']['settings']["playoff_start_week"]
    league_settings['playoff_start_week'] = playoffs_start_week
    positions = []
    for position in settings_content['fantasy_content']['leagues']['league']['settings']['roster_positions'][
        'roster_position']:
        for i in range(0, int(position['count'])):
            positions.append(position['position'])
    league_settings['positions'] = positions
    return league_settings, stat_map


def get_teams_data(headers, league_key, league_id, league_season):
    uri = f"https://fantasysports.yahooapis.com/fantasy/v2/leagues;league_keys={league_key}/standings"
    response = requests.get(uri, headers=headers)
    pp.pprint(response)
    teams_content = xmltodict.parse(response.text)

    league = teams_content["fantasy_content"]["leagues"]["league"]
    start_date = datetime.strptime(league["start_date"], '%Y-%m-%d')
    start_week = int(league["start_week"])
    end_week = int(league["end_week"])  # could use current week as end if mid year

    team_dicts = []
    for team in league["standings"]["teams"]["team"]:
        manager = team["managers"]["manager"]
        if isinstance(manager, list):
            manager = manager[0]
        team_dict = {
            "name": team["name"],
            "team_key": team["team_key"],
            "number_of_moves": int(team["number_of_moves"]),
            "number_of_trades": int(team["number_of_trades"]),
            "clinched_playoffs": "clinched_playoffs" in team and team["clinched_playoffs"] == "1",
            "manager_name": manager["nickname"],
            "division_id": team["division_id"] if 'division_id' in team else None,
            "draft_grade": team["draft_grade"] if "draft_grade" in team else None,
            "rank": int(team["team_standings"]["rank"]),
            "points_for": float(team["team_standings"]["points_for"]),
            "points_against": float(team["team_standings"]["points_against"]),
            "wins": int(team["team_standings"]["outcome_totals"]["wins"]),
            "losses": int(team["team_standings"]["outcome_totals"]["losses"]),
        }
        team_dicts.append(team_dict)
    teams_df = pd.DataFrame(team_dicts)
    teams_df['league_id'] = league_id
    teams_df['league_season'] = league_season
    return teams_df, start_week, end_week, start_date


def get_nickname(teams_df, team_key):
    return teams_df[teams_df["team_key"] == team_key]["manager_name"].values[0]


def get_player_data(headers, teams_df, start_week, end_week, league_id, league_season):
    team_keys = ",".join(teams_df["team_key"])
    base_uri = f"https://fantasysports.yahooapis.com/fantasy/v2/teams;team_keys={team_keys}/roster"
    player_dicts = []  # Initialize player_dicts outside of the loop

    for i in range(start_week, end_week + 1):
        uri = base_uri + ";week=" + str(i)
        response = requests.get(uri, headers=headers)
        pp.pprint(response)
        roster_content = xmltodict.parse(response.text)

        # Process each team within roster_content, no need to append and re-iterate
        for team in roster_content["fantasy_content"]["teams"]["team"]:
            team_key = team["team_key"]
            week = team["roster"]["week"]
            for player in team["roster"]["players"]["player"]:
                player_dict = {
                    "player_key": player["player_key"],
                    "name": player["name"]["full"],
                    "position": player["primary_position"],
                    "week": int(player["selected_position"]["week"]),
                    "started": player["selected_position"]['position'] == player["primary_position"] or
                               player["selected_position"]['is_flex'] == '1',
                    "team_key": team_key,
                    "manager_name": get_nickname(teams_df, team_key)
                }
                player_dicts.append(player_dict)  # Append to player_dicts within the loop

    players_df = pd.DataFrame(player_dicts)
    players_df['league_id'] = league_id
    players_df['league_season'] = league_season
    return players_df  # Return the DataFrame constructed from player_dicts


def get_player_stats_data(headers, players_df, start_week, end_week, stat_map, league_key):
    player_keys = players_df.player_key.unique()
    player_stats_contents = []
    for week in range(start_week, end_week + 1):
        # max page size is 25
        print(f"downloading week {week}")
        for i in range(0, len(player_keys), 25):
            player_keys_subset_str = ",".join(player_keys[i:i + 25])
            uri = f"https://fantasysports.yahooapis.com/fantasy/v2/leagues;league_keys={league_key}/players;player_keys={player_keys_subset_str}/stats;type=week;week={week}"
            r = requests.get(uri, headers=headers)
            pp.pprint(r)
            player_stats_content = xmltodict.parse(r.text)
            player_stats_contents.append(player_stats_content)

    player_stats_dicts = []
    for player_stats_content in player_stats_contents:
        for player_stats in player_stats_content["fantasy_content"]["leagues"]["league"]["players"]["player"]:
            player_stats_dict = {
                'player_key': player_stats["player_key"],
                'week': int(player_stats["player_stats"]["week"]),
                'points': float(player_stats["player_points"]["total"]),
                'name': player_stats["name"]["full"]
            }
            for stat in player_stats["player_stats"]["stats"]["stat"]:
                stat_name = stat_map[stat['stat_id']]
                stat_value = ast.literal_eval(stat['value'])
                player_stats_dict[stat_name] = stat_value
            player_stats_dicts.append(player_stats_dict)
    player_stats_df = pd.DataFrame(player_stats_dicts)
    return player_stats_df


def get_matchups(headers, teams_df, league_id, league_season):
    team_keys = ",".join(teams_df["team_key"])
    uri = f"https://fantasysports.yahooapis.com/fantasy/v2/teams;team_keys={team_keys}/matchups"
    response = requests.get(uri, headers=headers)
    pp.pprint(response)
    matchups_content = xmltodict.parse(response.text)

    matchup_dicts = []
    for team in matchups_content["fantasy_content"]["teams"]["team"]:
        for matchup in team["matchups"]["matchup"]:
            team_1 = matchup["teams"]["team"][0]
            matchup_dict = {
                "week": int(matchup['week']),
                "is_playoffs": matchup["is_playoffs"] == "1",
                "is_consolation": matchup["is_consolation"] == "1",
                "team_1_key": team_1["team_key"],
                "team_1_nickname": get_nickname(teams_df, team_1["team_key"]),
                "team_1_points": float(team_1["team_points"]["total"]),
                "team_1_projected_points": float(team_1["team_projected_points"]["total"])
            }
            if matchup["teams"]["@count"] == "1":
                matchup_dict["is_bye"] = True
            else:
                matchup_dict["is_bye"] = False
                team_2 = matchup["teams"]["team"][1]
                matchup_dict["team_2_key"] = team_2["team_key"]
                matchup_dict["team_2_nickname"] = get_nickname(teams_df, team_2["team_key"])
                matchup_dict["team_2_points"] = team_2["team_points"]["total"]
                matchup_dict["team_2_projected_points"] = team_2["team_projected_points"]["total"]
            matchup_dicts.append(matchup_dict)
    matchups_df = pd.DataFrame(matchup_dicts)
    matchups_df['league_id'] = league_id
    matchups_df['league_season'] = league_season
    return matchups_df
