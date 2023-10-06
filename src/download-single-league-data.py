import requests
import xmltodict
from datetime import datetime
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt
import pprint
import ast
import json

pp = pprint.PrettyPrinter(indent=2)


# Go to this website, login with Yahoo, and then copy the Access Token
# https://lemon-dune-0cd4b231e.azurestaticapps.net/.

def main(league_id):
    token = "NWm4bWKapVgOudeiZvR5yfIGoyCoiILPNoTPtBvxlAc7QCezp8aPomWkiI2p5b5nAcwbnCji0iVlhvfRNJni4xmd2MlU3_MKdM7E_8ystU5Isbon_9EGI82nuK7jFAznBrOrzBNMZhuqpP5Yq71BgSWUWA23V9Y8HXfdf2V9bJsRBDKhMp75O_0KmpOdogHCPdNXcdAGx2ncny2_K5xNyynCnGX7Rkba5kXWhVjDFjChCx6jCg0CAd8LENiLF4.j7CKsML85ttceEG5jqv8Yy_WIvzU5JIP4xDas9FYvEJ1OlhzUacvNWGMJtJ3IRsAZM2papzGQca2gBJbFvQJtronJWBp6hLszR3nJOf0Tpu4hwZWugZOVg1JPkS9sdjY29uGgsCA7VMMrmaH5e1bR0wlqie9lkHdK6l9NiEzfDToRyDOtDYljyP0_z_esnGROk80rml6Iqth7Dg.Ha37Cui.M5pD1LtSWDtjGefK3vREy4GKFHC76YnXxv2tFFB5ytNdZG01S_uf7Ufvlj5LUoMGes2z12.EId_GrzC8P5HLFrMLfI3cODTRT7ClAJ9q48N_zvLtoWqDQXDE_YU6qu1f7x6ynsOUe0jvbmJGVGAgNTO28tryqNfYygY.76viBIf9PywdSoJmxA9YFSveWTkkbLS1nPM9C.X1oEFVZd.o094kqDcWA.y8cNeI6YiNFtmhrlGNuYL2wCepHV0xCKCjVWzNakcfU.UWhclxGnFhQSdlRzUBYPj1AldMeeD7XzqhcotP5PweydVRaGxRxML7ZaouTFTHq7nAY1jMDBp9g3cvLzXR0bmjtXE0k8X4k.os_Jr9fRJNFep77estktwas2eUfc5422xdKRKpCaazUCG4CkjUdpai1luN8U_zrAFrnV518wIQNxZiV1MGKLNZM2t8Y5bwUK4xSB83kwYMP"
    authorization = "Bearer " + token
    headers = {'Authorization': authorization}

    uri = "https://fantasysports.yahooapis.com/fantasy/v2/users;use_login=1/games/leagues"
    r = requests.get(uri, headers=headers)
    pp.pprint(r)
    leagues_content = xmltodict.parse(r.text)

    games = leagues_content["fantasy_content"]["users"]["user"]["games"]["game"]
    league_dicts = []
    for game in games:
        if "leagues" in game and game["leagues"] != None:
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
    leagues_df = pd.DataFrame(league_dicts,
                              columns=['league_key', 'name', 'game_code', 'season', 'num_teams'])
    # leagues_df

    league_key = league_id

    # denver league_keys = ["390.l.1031063", "399.l.301184", "406.l.151652", "414.l.598560"]
    # IC league_keys = ["273.l.838679","331.l.661280","348.l.464735","359.l.18316","371.l.24819","380.l.951129","390.l.763777","399.l.627892","406.l.779300", "414.l.194005"]
    # LVILLE league_keys = ["348.l.330085","359.l.53710","371.l.829067","380.l.245120","390.l.495602","399.l.304191", "406.l.611874"]

    season = leagues_df[leagues_df["league_key"] == league_key]["season"].values[0]
    league_name = leagues_df[leagues_df["league_key"] == league_key]["name"].values[0]
    file_suffix = season
    file_prefix = league_name

    # Get Settings Data
    uri = f"https://fantasysports.yahooapis.com/fantasy/v2/leagues;league_keys={league_key}/settings"
    r = requests.get(uri, headers=headers)
    pp.pprint(r)
    settings_content = xmltodict.parse(r.text)

    stat_map = {}
    for stat in settings_content["fantasy_content"]["leagues"]["league"]["settings"]["stat_categories"]["stats"][
        "stat"]:
        stat_map[stat['stat_id']] = stat['name']

    league_settings = {}
    playoffsStartWeek = settings_content['fantasy_content']['leagues']['league']['settings']["playoff_start_week"]
    league_settings["playoff_startweek"] = playoffsStartWeek
    positions = []
    for position in settings_content['fantasy_content']['leagues']['league']['settings']['roster_positions'][
        'roster_position']:
        for i in range(0, int(position['count'])):
            positions.append(position['position'])
    league_settings["positions"] = positions

    with open(f'data/league-settings/{file_prefix}_league_settings_{file_suffix}.json', 'w') as f:
        json.dump(league_settings, f)

    # Get Teams Data
    uri = f"https://fantasysports.yahooapis.com/fantasy/v2/leagues;league_keys={league_key}/standings"
    r = requests.get(uri, headers=headers)
    pp.pprint(r)
    teams_content = xmltodict.parse(r.text)

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

    def get_nickname(team_key):
        return teams_df[teams_df["team_key"] == team_key]["manager_name"].values[0]

    teams_df.to_csv(f"data/teams/{file_prefix}_teams_{file_suffix}.csv", index=False)

    # Get Players Data
    # 1. get rosters
    # 2. get player stats
    # 3. merge info

    team_keys = ",".join(teams_df["team_key"])
    baseUri = f"https://fantasysports.yahooapis.com/fantasy/v2/teams;team_keys={team_keys}/roster"
    roster_content_list = []
    for i in range(start_week, end_week + 1):
        uri = baseUri + ";week=" + str(i)
        r = requests.get(uri, headers=headers)
        pp.pprint(r)
        roster_content = xmltodict.parse(r.text)
        roster_content_list.append(roster_content)

    player_dicts = []
    for roster_content in roster_content_list:
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
                    "manager_name": get_nickname(team_key)
                }
                player_dicts.append(player_dict)
    players_df = pd.DataFrame(player_dicts)
    players_df.head(5)

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
    player_stats_df.head(5)

    players_df = pd.merge(players_df, player_stats_df, how='outer', left_on=['player_key', 'week', 'name'],
                          right_on=['player_key', 'week', 'name'])
    players_df.head(5)

    players_df.to_csv(f"data/players/{file_prefix}_players_{file_suffix}.csv", index=False)

    # Get Matchups Data

    team_keys = ",".join(teams_df["team_key"])
    uri = f"https://fantasysports.yahooapis.com/fantasy/v2/teams;team_keys={team_keys}/matchups"
    r = requests.get(uri, headers=headers)
    pp.pprint(r)
    matchups_content = xmltodict.parse(r.text)

    matchup_dicts = []
    for team in matchups_content["fantasy_content"]["teams"]["team"]:
        for matchup in team["matchups"]["matchup"]:
            team_1 = matchup["teams"]["team"][0]
            matchup_dict = {
                "week": int(matchup['week']),
                "is_playoffs": matchup["is_playoffs"] == "1",
                "is_consolation": matchup["is_consolation"] == "1",
                "team_1_key": team_1["team_key"],
                "team_1_nickname": get_nickname(team_1["team_key"]),
                "team_1_points": float(team_1["team_points"]["total"]),
                "team_1_projected_points": float(team_1["team_projected_points"]["total"])
            }
            if matchup["teams"]["@count"] == "1":
                matchup_dict["is_bye"] = True
            else:
                matchup_dict["is_bye"] = False
                team_2 = matchup["teams"]["team"][1]
                matchup_dict["team_2_key"] = team_2["team_key"]
                matchup_dict["team_2_nickname"] = get_nickname(team_2["team_key"])
                matchup_dict["team_2_points"] = team_2["team_points"]["total"]
                matchup_dict["team_2_projected_points"] = team_2["team_projected_points"]["total"]
            matchup_dicts.append(matchup_dict)
    matchups_df = pd.DataFrame(matchup_dicts)
    matchups_df.head(5)

    matchups_df.to_csv(f"data/matchups/{file_prefix}_matchups_{file_suffix}.csv", index=False)


if __name__ == "__main__":
    # denver league_keys = ["390.l.1031063", "399.l.301184", "406.l.151652", "414.l.598560"]
    # IC league_keys = ["273.l.838679","331.l.661280","348.l.464735","359.l.18316","371.l.24819","380.l.951129","390.l.763777","399.l.627892","406.l.779300", "414.l.194005"]
    # LVILLE league_keys = ["348.l.330085","359.l.53710","371.l.829067","380.l.245120","390.l.495602","399.l.304191", "406.l.611874", "414.l.309654"]
    leagues = ["390.l.1031063", "399.l.301184", "406.l.151652", "414.l.598560", "273.l.838679", "331.l.661280",
               "348.l.464735", "359.l.18316", "371.l.24819", "380.l.951129", "390.l.763777", "399.l.627892",
               "406.l.779300", "414.l.194005", "348.l.330085", "359.l.53710", "371.l.829067", "380.l.245120",
               "390.l.495602", "399.l.304191", "406.l.611874", "414.l.309654"]
    for league in leagues:
        main(league)
