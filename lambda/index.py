import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    # Log the event for debugging
    logger.info("Received event: " + json.dumps(event, indent=2))

    # Loop through records (in case multiple files are uploaded)
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        # Requirement: Log "Image received: [filename]"
        print(f"Image received: {key}")
        logger.info(f"Image received: {key} from bucket {bucket}")
        
    return {
        'statusCode': 200,
        'body': json.dumps('Process complete')
    }