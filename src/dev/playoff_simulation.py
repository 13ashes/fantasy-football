import pandas as pd
from src.utils.database_utils import read_sql


def get_playoff_start_week(league_id, league_season):
    query = f"SELECT MIN(week) as start_week FROM staging.vw_matchups WHERE is_playoffs = True AND league_id = {league_id} AND league_season = {league_season}"
    result = read_sql(query)
    return result['start_week'][0]


def get_top_teams_by_ranking(ranking_type, league_id, league_season):
    query = f"SELECT * FROM staging.vw_analytics WHERE {ranking_type} <= 6 AND league_id = {league_id} AND league_season = {league_season} ORDER BY {ranking_type} ASC"
    return read_sql(query)


def get_matchup(week, team_name, league_id, league_season):
    query = f"SELECT * FROM staging.vw_matchups WHERE week = {week} AND league_id = {league_id} AND league_season = {league_season} AND (team_1_person = '{team_name}' OR team_2_person = '{team_name}')"
    return read_sql(query).iloc[0]


def simulate_playoffs(ranking_type, is_playoff_reseeding, league_id, league_season):
    # Define playoff start week
    start_week = get_playoff_start_week(league_id, league_season)

    # Fetch the top 6 teams based on ranking type
    teams = get_top_teams_by_ranking(ranking_type, league_id, league_season)

    # Week 1 Simulation
    match1_data = get_matchup(start_week, teams.iloc[2]['team_1_person'], league_id, league_season)
    print(match1_data)
    match2_data = get_matchup(start_week, teams.iloc[3]['team_1_person'], league_id, league_season)

    # Extract winners of Week 1
    week1_winners = [
        teams.iloc[2] if match1_data['team_1_points'] > match1_data['team_2_points'] else teams.iloc[5],
        teams.iloc[3] if match2_data['team_1_points'] > match2_data['team_2_points'] else teams.iloc[4]
    ]

    # Week 2 Simulation
    week2_winners = []
    if is_playoff_reseeding:
        # Determine seeds
        lowest_seed_winner = max(week1_winners, key=lambda x: x[ranking_type])
        week1_winners.remove(lowest_seed_winner)
        other_winner = week1_winners[0]

        match1_week2_data = get_matchup(start_week + 1, teams.iloc[0]['team_1_person'], league_id, league_season)
        print(match1_week2_data)
        match2_week2_data = get_matchup(start_week + 1, teams.iloc[1]['team_1_person'], league_id, league_season)

        week2_winners.append(teams.iloc[0] if match1_week2_data['team_1_points'] > lowest_seed_winner[
            'team_2_points'] else lowest_seed_winner)
        week2_winners.append(teams.iloc[1] if match2_week2_data['team_1_points'] > other_winner[
            'team_2_points'] else other_winner)

    else:
        match1_week2_data = get_matchup(start_week + 1, teams.iloc[0]['team_1_person'], league_id, league_season)
        print(match1_week2_data)
        match2_week2_data = get_matchup(start_week + 1, teams.iloc[1]['team_1_person'], league_id, league_season)

        week2_winners.append(teams.iloc[0] if match1_week2_data['team_1_points'] > week1_winners[0]['team_2_points'] else week1_winners[0])
        week2_winners.append(teams.iloc[1] if match2_week2_data['team_1_points'] > week1_winners[1]['team_2_points'] else week1_winners[1])

    fifth_place_winner = max(week1_winners, key=lambda x: x['team_2_points'])

    # Week 3 Simulation for championship and other matches
    match_final_week_data = get_matchup(start_week + 2, week2_winners[0]['team_1_person'], league_id, league_season)

    championship_winner = week2_winners[0] if match_final_week_data['team_1_points'] > match_final_week_data[
        'team_2_points'] else week2_winners[1]
    third_place_winner = week2_winners[1] if championship_winner == week2_winners[0] else week2_winners[0]

    # Create output dataframe
    results = [
        {'team_1_person': championship_winner['team_1_person'], 'finish_position': 1, 'league_id': league_id,
         'league_season': league_season},
        {'team_1_person': third_place_winner['team_1_person'], 'finish_position': 3, 'league_id': league_id,
         'league_season': league_season},
        {'team_1_person': fifth_place_winner['team_1_person'], 'finish_position': 5, 'league_id': league_id,
         'league_season': league_season}
    ]
    for i, team in enumerate(teams.itertuples()):
        if team.team_1_person not in [champ['team_1_person'] for champ in [championship_winner, third_place_winner, fifth_place_winner]]:
            results.append({'team_1_person': team.team_1_person, 'finish_position': i + 6, 'league_id': league_id,
                            'league_season': league_season})

    return pd.DataFrame(results)



# Simulating for both ranking types and specific league id and season
league_id = 2  # Example league_id
league_season = 2022  # Example league_season

# actual_rank_results = simulate_playoffs("actual_ranking", False, league_id, league_season)
# total_rank_results = simulate_playoffs("total_ranking", False, league_id, league_season)

test = get_top_teams_by_ranking('total_ranking', league_id, league_season)

# print(actual_rank_results)
# print(total_rank_results)
# Set the display options
pd.set_option('display.max_rows', None)  # Display all rows
pd.set_option('display.max_columns', None)  # Display all columns
pd.set_option('display.width', None)  # Ensure that the display width fits the console
pd.set_option('display.max_colwidth', None)  # Display full column content

print(test)

# Week 1 Simulation
match1_data = get_matchup(15, 'Geoff Hardaway', league_id, league_season)
print(match1_data)