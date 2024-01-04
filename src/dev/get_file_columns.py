from src.utils.aws_utils import AWSUtil


def main():
    aws = AWSUtil()  # Initialize the AWS utility

    # Fetch unique columns from each folder
    matchups_columns = aws.get_unique_columns_from_s3_folder('rhithm-insights', 'matchups/')
    players_columns = aws.get_unique_columns_from_s3_folder('rhithm-insights', 'players/')
    teams_columns = aws.get_unique_columns_from_s3_folder('rhithm-insights', 'teams/')

    # Print the results
    print("Matchups columns:", matchups_columns)
    print("Players columns:", players_columns)
    print("Teams columns:", teams_columns)


if __name__ == "__main__":
    main()
