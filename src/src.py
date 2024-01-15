import pandas as pd
from utils.yahoo_utils import authenticate, get_league_settings, get_teams_data, get_player_data, \
    get_player_stats_data, get_matchups
from utils.database_utils import read_sql
import pprint
from utils.aws_utils import AWSUtil  # Import the AWS utility class
import os
from dotenv import load_dotenv

pp = pprint.PrettyPrinter(indent=2)

# Load environment variables
load_dotenv()

bucket_name = os.getenv('BUCKET_NAME')


# Go to this website, login with Yahoo, and then copy the Access Token
# https://lemon-dune-0cd4b231e.azurestaticapps.net/.


def main(league_index):
    headers = authenticate()

    # Define view
    view = 'prod.vw_leagues'
    print(f'Processing {view}')

    # Fetch user data from Postgres
    query = f"""
    SELECT ROW_NUMBER() OVER (ORDER BY league_key) AS row_number,
           league_key,
           league_name, 
           season,
           league_id FROM {view}
           where league_id = 4
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

    # Write DataFrames to S3 as CSV
    aws = AWSUtil()  # Initialize the AWS utility

    # players_df.to_csv('players_temp.csv', index=False)
    aws.upload_to_s3('players_temp.csv', bucket_name, f'players/fct_players_{league_key}.csv')

    team_data.to_csv('teams_temp.csv', index=False)
    aws.upload_to_s3('teams_temp.csv', bucket_name, f'teams/fct_teams_{league_key}.csv')

    matchups_df.to_csv('matchups_temp.csv', index=False)
    aws.upload_to_s3('matchups_temp.csv', bucket_name, f'matchups/fct_matchups_{league_key}.csv')

    print(f"Processed league {league_index}/{len(leagues)}.")


if __name__ == "__main__":
    # Fetch the desired league index from the user
    index = int(input("Enter the league index (1-based) you wish to process: "))
    main(index)
