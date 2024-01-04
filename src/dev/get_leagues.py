from yahoo_utils import authenticate, get_leagues
from database_utils import write_df_to_postgres
import pprint

pp = pprint.PrettyPrinter(indent=2)


def main():
    headers = authenticate()
    league_data = get_leagues(headers)
    write_df_to_postgres(league_data, 'dim_leagues', 'loading')


if __name__ == "__main__":
    main()
