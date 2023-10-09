from yahoo_utils import authenticate, get_league_settings
from database_utils import read_sql, write_df_to_postgres
import pprint
import json

pp = pprint.PrettyPrinter(indent=2)


def main():
    headers = authenticate()

    # Define view
    view = 'loading.dim_leagues'
    print(f'Processing {view}')

    # Fetch user data from Postgres
    query = f"""
    SELECT league_key, 
           name, 
           season FROM {view} WHERE league_key in ('423.l.653974','423.l.332174')
    """
    leagues = read_sql(query)
    all_league_settings = {}

    # Loop through each user
    for index, league in leagues.iterrows():
        file_suffix = league['season']
        league_settings = get_league_settings(headers, league['league_key'])
        with open(f'league_settings_{file_suffix}.json', 'w') as f:
            json.dump(league_settings, f)


if __name__ == "__main__":
    main()
