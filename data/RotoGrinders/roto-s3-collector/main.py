import os
import boto3

if __name__ == '__main__':
    base_dir = 'C:/Users/Antonio/Documents/NBA/data/RotoGrinders/jsons/fanduel/2022_23/'
    access_key = os.getenv('aws_access_key')
    access_secret = os.getenv('aws_secret_access_key')
    session = boto3.Session(
        aws_access_key_id=access_key,
        aws_secret_access_key=access_secret,
    )
    s3 = session.resource('s3')
    client = session.client('s3')
    bucket = s3.Bucket('roto-data')
    for my_bucket_object in bucket.objects.all():
        key = my_bucket_object.key
        if 'data_22' in key:
            day = key.split('/')[0] + ".json"
            bucket.download_file(key, base_dir + day)
            print(key)

