#!/usr/bin/python3.8
import urllib3
from urllib.parse import quote
import json
import os

http = urllib3.PoolManager()

MATRIX_ALERTMANAGER_URL = os.environ["MATRIX_ALERTMANAGER_URL"]
MATRIX_ALERTMANAGER_RECEIVER = os.environ["MATRIX_ALERTMANAGER_RECEIVER"]


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


def lambda_handler(event, context):
    url = MATRIX_ALERTMANAGER_URL
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    payload = json.dumps(to_alertmanager(message)).encode("utf-8")
    resp = http.request(
        "POST", url, body=payload, headers={"Content-Type": "application/json"}
    )
    print({"message": message, "status_code": resp.status, "response": resp.data})
