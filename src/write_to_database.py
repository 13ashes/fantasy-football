import pandas as pd
from src.utils.database_utils import write_df_to_postgres
from src.utils.aws_utils import AWSUtil
from io import StringIO
import pprint
import os
from dotenv import load_dotenv

pp = pprint.PrettyPrinter(indent=2)

# Load environment variables
load_dotenv()


def load_csv_from_s3_to_db(bucket_name, s3_object_path):
    # Initialize the AWS utility
    aws = AWSUtil()

    try:
        # Download CSV content from S3
        csv_obj = aws.s3.get_object(Bucket=bucket_name, Key=s3_object_path)
        body = csv_obj['Body']
        csv_string = body.read().decode('utf-8')

        # Convert CSV string to DataFrame
        df = pd.read_csv(StringIO(csv_string))

        return df

    except aws.s3.exceptions.NoSuchKey:
        print(f"File {s3_object_path} not found in S3 bucket {bucket_name}. Skipping...")
        return None


def main():
    # Configuration
    bucket_name = os.getenv('BUCKET_NAME')
    categories = ['matchups', 'teams']
    league_keys = ['153.l.709122', '175.l.696127']

    # Loop through each category and then through each league key for that category
    for category in categories:
        for league_key in league_keys:
            print(f"Processing {category} data for league key {league_key}...")

            # Define S3 path based on category and league key
            s3_path = f'{category}/fct_{category}_{league_key}.csv'

            # Get data from S3
            df = load_csv_from_s3_to_db(bucket_name, s3_path)

            # Write to Postgres in the 'staging' schema
            write_df_to_postgres(df, table_name=category, schema_name='staging')

            print(
                f"Loaded {category} data for league key {league_key} from {s3_path} to staging.{category} in Postgres.")


if __name__ == "__main__":
    main()
