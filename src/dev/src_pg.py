import pandas as pd
from src.utils.yahoo_utils import authenticate, get_league_settings, get_teams_data, get_player_data, get_player_stats_data, \
    get_matchups
from src.utils.database_utils import read_sql, write_df_to_postgres
import pprint

pp = pprint.PrettyPrinter(indent=2)


def main(league_index):
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

    if league_index < 1 or league_index > len(leagues):
        print(f"Invalid league index {league_index}. Please provide a number between 1 and {len(leagues)}.")
        return

    league = leagues.iloc[league_index - 1]  # -1 because lists/df are 0-indexed
    league_key = league['league_key']
    league_season = league['season']
    league_id = league['league_id']

    # Start pulling data
    league_settings, stat_map = get_league_settings(headers, league_key)
    team_data, start_week, end_week, start_date = get_teams_data(headers, league_key, league_id, league_season)
    player_data = get_player_data(headers, team_data, start_week, end_week, league_id, league_season)
    player_stats_data = get_player_stats_data(headers, player_data, start_week, end_week, stat_map, league_key)
    players_df = pd.merge(player_data, player_stats_data, how='outer', left_on=['player_key', 'week', 'name'],
                          right_on=['player_key', 'week', 'name'])
    matchups_df = get_matchups(headers, team_data, league_id, league_season)

    # Write DataFrames to PostgreSQL
    write_df_to_postgres(players_df, 'fct_players', 'loading')
    write_df_to_postgres(team_data, 'fct_teams', 'loading')
    write_df_to_postgres(matchups_df, 'fct_matchups', 'loading')

    print(f"Processed league {league_index}/{len(leagues)}.")


if __name__ == "__main__":
    # Fetch the desired league index from the user
    index = int(input("Enter the league index (1-based) you wish to process: "))
    main(index)
