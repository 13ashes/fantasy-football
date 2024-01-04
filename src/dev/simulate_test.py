import pandas as pd
import ast
import csv
from io import StringIO

def simulate_playoffs(data):
    # Use csv.reader to correctly parse data
    reader = csv.reader(StringIO(data))
    headers = next(reader)  # Extract the header
    rows = list(reader)  # Extract the data rows

    df = pd.DataFrame(rows, columns=headers)
    df["playoff_data"] = df["playoff_data"].apply(ast.literal_eval)

    # Define matchups
    week1_matchups = [(3, 6), (4, 5)]
    byes = [1, 2]

    def determine_winner(player1, player2, week):
        player1_data = df.loc[df["team_1_person"] == player1, "playoff_data"].values
        if len(player1_data) == 0:
            print(f"Player {player1} not found in the DataFrame!")
            return None  # or handle this case appropriately

        player1_score = player1_data[0][str(week)]
        player2_score = df.loc[df["team_1_person"] == player2, "playoff_data"].values[0][str(week)]

        if player1_score > player2_score:
            return player1
        return player2

    # Week 1
    week1_winners = []
    for match in week1_matchups:
        winner = determine_winner(df.iloc[match[0]-1]["team_1_person"], df.iloc[match[1]-1]["team_1_person"], 15)
        week1_winners.append(winner)

    print(f"Week 1 matchups teams: {[df.iloc[match[0] - 1]['team_1_person'] for match in week1_matchups]}")
    print(f"Week 1 winners: {week1_winners}")

    # Week 2
    week2_matchups = [(byes[0], week1_winners[0]), (byes[1], week1_winners[1])]
    fifth_place_match = list(
        set([df.iloc[match[0] - 1]["team_1_person"] for match in week1_matchups]) - set(week1_winners))

    # Add the debugging print statement
    print(f"Fifth place match teams: {fifth_place_match}")

    if len(fifth_place_match) != 2:
        print("Error in determining the fifth-place match teams.")
        return

    week2_winners = []
    for match in week2_matchups:
        winner = determine_winner(match[0], match[1], 16)
        week2_winners.append(winner)

    fifth_place_winner = determine_winner(fifth_place_match[0], fifth_place_match[1], 16)

    # Week 3
    champion = determine_winner(week2_winners[0], week2_winners[1], 17)
    third_place_match = list(set(week2_matchups[0] + week2_matchups[1]) - set(week2_winners))
    third_place = determine_winner(third_place_match[0], third_place_match[1], 17)

    results = {
        "Champion": champion,
        "Runner-up": week2_winners[1] if week2_winners[0] == champion else week2_winners[0],
        "Third Place": third_place,
        "Fourth Place": third_place_match[1] if third_place_match[0] == third_place else third_place_match[0],
        "Fifth Place": fifth_place_winner,
        "Sixth Place": fifth_place_match[1] if fifth_place_match[0] == fifth_place_winner else fifth_place_match[0]
    }

    return results

data = """team_1_person,actual_ranking,total_ranking,playoff_data
Alex Zara,12,12,"{""15"": 102.46, ""16"": 117.22, ""17"": 67.96}"
Andrew Swetnam,10,9,"{""15"": 115.24000000000001, ""16"": 183.8, ""17"": 151.2}"
Ben Teeter,8,8,"{""15"": 116.44, ""16"": 117.36, ""17"": 108.62}"
Brian Isley,5,3,"{""15"": 132, ""16"": 108.66000000000001, ""17"": 113.88}"
Geoff Hardaway,3,4,"{""15"": 136.39999999999998, ""16"": 109.36, ""17"": 113}"
Hyman Cohen,11,11,"{""15"": 90.72, ""16"": 108.90000000000002, ""17"": 79.4}"
Oscar Salazar,7,7,"{""15"": 130.18, ""16"": 98.44000000000001, ""17"": 106.98}"
Steve Turetsky,6,6,"{""15"": 129.86, ""16"": 104.38, ""17"": 98.4}"
Tony Fancher,4,5,"{""15"": 119.02000000000001, ""16"": 97.9, ""17"": 88.3}"
Tony Pisani,9,10,"{""15"": 111.66, ""16"": 102.46000000000001, ""17"": 111.46000000000001}"
Will Hightower,2,1,"{""15"": 123.8, ""16"": 142.3, ""17"": 104.69999999999999}"
Zach Hilborn,1,2,"{""15"": 126.94, ""16"": 118.88000000000001, ""17"": 110.28}"
"""
print(simulate_playoffs(data))
