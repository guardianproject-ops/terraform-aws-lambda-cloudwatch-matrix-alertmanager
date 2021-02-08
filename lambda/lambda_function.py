from urllib.parse import quote
import json
import os
import requests
from aws_lambda_powertools import Logger


MATRIX_ALERTMANAGER_URL = os.environ["MATRIX_ALERTMANAGER_URL"]
MATRIX_ALERTMANAGER_RECEIVER = os.environ["MATRIX_ALERTMANAGER_RECEIVER"]

logger = Logger()


def to_alertmanager(message):
    alarm_name = message["AlarmName"]
    old_state = message["OldStateValue"].lower()
    new_state = message["NewStateValue"].lower()
    reason = message["NewStateReason"]
    description = message["AlarmDescription"]
    region = message["Region"]

    console_url = f"https://console.aws.amazon.com/cloudwatch/home?region={region}#alarm:alarmFilter=ANY;name={quote(alarm_name)}"
    description = f"{description} ({region})"

    if new_state == "alarm":
        status = "firing"
    else:
        status = "resolved"

    return {
        "receiver": MATRIX_ALERTMANAGER_RECEIVER,
        "status": status,
        "alerts": [
            {
                "status": status,
                "labels": {"instance": alarm_name, "job": alarm_name},
                "annotations": {"description": description},
                "generatorURL": console_url,
            }
        ],
    }


@logger.inject_lambda_context
def lambda_handler(event, context):
    logger.debug("event", extra={"event": event})
    url = MATRIX_ALERTMANAGER_URL
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    payload = json.dumps(to_alertmanager(message)).encode("utf-8")
    resp = requests.post(url, json=payload)
    resp.raise_for_status()
    logger.debug("response from matrix bot", {"reponse": resp.json()})
    print({"message": message, "status_code": resp.status_code})
