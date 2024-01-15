import boto3
from botocore.exceptions import NoCredentialsError
import pandas as pd
from io import StringIO
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

bucket_name = os.getenv('BUCKET_NAME')


class AWSUtil:

    def __init__(self, access_key=None, secret_key=None, region_name='us-east-1'):
        self.s3 = self._get_s3_client(access_key, secret_key, region_name)
        self.region_name = region_name

    def _get_s3_client(self, access_key, secret_key, region_name):
        if access_key and secret_key:
            return boto3.client('s3', aws_access_key_id=access_key,
                                aws_secret_access_key=secret_key,
                                region_name=region_name)
        else:
            # Will use AWS CLI configuration or IAM role
            return boto3.client('s3', region_name=region_name)

    def list_buckets(self):
        return [bucket['Name'] for bucket in self.s3.list_buckets()['Buckets']]

    def upload_to_s3(self, file_name, bucket_name, object_name=None):
        if not object_name:
            object_name = file_name

        try:
            self.s3.upload_file(file_name, bucket_name, object_name)
            print(f"Upload Successful. {file_name} uploaded to {bucket_name}/{object_name}.")
            return True
        except FileNotFoundError:
            print(f"The file {file_name} was not found.")
            return False
        except NoCredentialsError:
            print("Credentials not available.")
            return False

    def download_from_s3(self, file_name, bucket_name, object_name=None):
        if not object_name:
            object_name = file_name

        try:
            self.s3.download_file(bucket_name, object_name, file_name)
            print(f"Download Successful. {object_name} downloaded from {bucket_name} to {file_name}.")
            return True
        except NoCredentialsError:
            print("Credentials not available.")
            return False

    def delete_from_s3(self, bucket_name, object_name):
        self.s3.delete_object(Bucket=bucket_name, Key=object_name)
        print(f"Deleted {object_name} from {bucket_name}.")

    def get_unique_columns_from_s3_folder(self, bucket_name, folder_name):
        objects = self.s3.list_objects(Bucket=bucket_name, Prefix=folder_name)
        all_columns = set()  # Using a set to store unique columns

        for obj in objects.get('Contents', []):
            file_key = obj['Key']

            # Get CSV content
            csv_obj = self.s3.get_object(Bucket=bucket_name, Key=file_key)
            body = csv_obj['Body']
            csv_string = body.read().decode('utf-8')

            # Convert CSV string to DataFrame and extract columns
            df = pd.read_csv(StringIO(csv_string))
            all_columns.update(df.columns)

        return all_columns


# Example usage
if __name__ == "__main__":
    aws = AWSUtil()

    # List all buckets
    print(aws.list_buckets())

    # Upload a file
    aws.upload_to_s3('/Users/anthonyfancher/fantasy-football/src/test.csv', bucket_name, 'test.csv')

    # Download a file
    # aws.download_from_s3('downloaded_file.csv', 'your_bucket_name', 'path_in_bucket.csv')

    # Delete a file
    aws.delete_from_s3(bucket_name, 'test.csv')
