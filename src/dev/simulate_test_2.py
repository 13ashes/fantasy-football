# Define the source data for players
players = [
    {
        "name": "Player 1",
        "seed": 1,
        "playoff_data": {
            "Week 15": 100,
            "Week 16": 120,
            "Week 17": 140,
        },
    },
    {
        "name": "Player 2",
        "seed": 2,
        "playoff_data": {
            "Week 15": 110,
            "Week 16": 130,
            "Week 17": 150,
        },
    },
    {
        "name": "Player 3",
        "seed": 3,
        "playoff_data": {
            "Week 15": 90,
            "Week 16": 100,
            "Week 17": 110,
        },
    },
    {
        "name": "Player 4",
        "seed": 4,
        "playoff_data": {
            "Week 15": 95,
            "Week 16": 115,
            "Week 17": 135,
        },
    },
    {
        "name": "Player 5",
        "seed": 5,
        "playoff_data": {
            "Week 15": 120,
            "Week 16": 140,
            "Week 17": 160,
        },
    },
    {
        "name": "Player 6",
        "seed": 6,
        "playoff_data": {
            "Week 15": 85,
            "Week 16": 105,
            "Week 17": 125,
        },
    },
]

# Week 1 matchups
week1_matchups = [(1, None), (3, 6), (4, 5), (2, None)]  # 1 and 2 get byes

# Function to simulate a matchup
def simulate_matchup(player1, player2):
    if player2 is None:
        return player1
    p1_points = sum(player1["playoff_data"].values())
    p2_points = sum(player2["playoff_data"].values())
    return player1 if p1_points > p2_points else player2

# Simulate Week 1
week1_winners = []
for p1, p2 in week1_matchups:
    player1 = players[p1 - 1]
    player2 = players[p2 - 1] if p2 is not None else None
    winner = simulate_matchup(player1, player2)
    week1_winners.append(winner)

# Simulate Week 2
week2_matchups = [(week1_winners[0], week1_winners[1]), (week1_winners[2], week1_winners[3])]

# Determine 5th place game players
week2_5th_place_players = [player for player in week1_winners if player not in week2_matchups]

# Simulate Week 3
week3_championship = simulate_matchup(week2_matchups[0][0], week2_matchups[0][1])
week3_3rd_place_game = simulate_matchup(week2_matchups[1][0], week2_matchups[1][1])

# Determine final placements
placements = [
    week3_championship,
    week3_3rd_place_game,
    week2_matchups[0][0] if week2_matchups[0][0] not in week2_5th_place_players else week2_matchups[0][1],
    week2_matchups[1][0] if week2_matchups[1][0] not in week2_5th_place_players else week2_matchups[1][1],
    week2_5th_place_players[0],
    week2_5th_place_players[1],
]

# Output final placements
print("Final Placements:")
for i, player in enumerate(placements, start=1):
    print(f"{i}. {player['name']}")