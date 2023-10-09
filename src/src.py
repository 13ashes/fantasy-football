import requests
import xmltodict
import pandas as pd
import json
import ast
from yahoo_utils import authenticate, get_league_settings, get_teams_data, get_player_data, get_player_stats_data, \
    get_nickname, get_matchups
from database_utils import read_sql, write_df_to_postgres
import pprint

pp = pprint.PrettyPrinter(indent=2)


# Main Function
def main():
    headers = authenticate()

    # Define view
    view = 'public.vw_leagues'
    print(f'Processing {view}')

    # Fetch user data from Postgres
    query = f"""
    SELECT league_key, 
           league_name, 
           season,
           league_id FROM {view}
    """
    leagues = read_sql(query)

    # Initialize lists to store DataFrames
    all_players_data = []
    all_teams_data = []
    all_matchups_data = []

    # Loop through each user
    for index, league in leagues.iterrows():
        league_key = league['league_key']
        league_season = league['season']
        league_id = league['league_id']
        # start pulling data
        league_settings, stat_map = get_league_settings(headers, league_key)
        team_data, start_week, end_week, start_date = get_teams_data(headers, league_key, league_id, league_season)
        player_data = get_player_data(headers, team_data, start_week, end_week, league_id, league_season)
        player_stats_data = get_player_stats_data(headers, player_data, start_week, end_week, stat_map, league_key)
        players_df = pd.merge(player_data, player_stats_data, how='outer', left_on=['player_key', 'week', 'name'],
                              right_on=['player_key', 'week', 'name'])
        matchups_df = get_matchups(headers, team_data, league_id, league_season)

        # Append DataFrames to respective lists
        all_players_data.append(players_df)
        all_teams_data.append(team_data)
        all_matchups_data.append(matchups_df)

    # Concatenate all DataFrames and write to PostgreSQL
    final_players_df = pd.concat(all_players_data, ignore_index=True)
    final_teams_df = pd.concat(all_teams_data, ignore_index=True)
    final_matchups_df = pd.concat(all_matchups_data, ignore_index=True)

    # Write final DataFrames to PostgreSQL
    write_df_to_postgres(final_players_df, 'fct_players', 'staging')
    write_df_to_postgres(final_teams_df, 'fct_teams', 'staging')
    write_df_to_postgres(final_matchups_df, 'fct_matchups', 'staging')


if __name__ == "__main__":
    main()
