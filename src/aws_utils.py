import boto3
from botocore.exceptions import NoCredentialsError


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


# Example usage
if __name__ == "__main__":
    aws = AWSUtil()

    # List all buckets
    print(aws.list_buckets())

    # Upload a file
    aws.upload_to_s3('/Users/anthonyfancher/fantasy-football/src/test.csv', 'rhithm-insights', 'test.csv')

    # Download a file
    # aws.download_from_s3('downloaded_file.csv', 'your_bucket_name', 'path_in_bucket.csv')

    # Delete a file
    aws.delete_from_s3('rhithm-insights', 'test.csv')
