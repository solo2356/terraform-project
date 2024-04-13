import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Log the incoming event
    logger.info("Received event: " + json.dumps(event))
    
    # Perform any desired processing here
    
    # Return a response
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "Lambda function executed successfully"}),
        "headers": {
            "Content-Type": "application/json"
        }
    }
    
    return response
