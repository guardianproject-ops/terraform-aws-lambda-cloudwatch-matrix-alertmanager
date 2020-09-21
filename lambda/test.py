import unittest
import os


os.environ["MATRIX_ALERTMANAGER_URL"] = "http://test.com"
os.environ["MATRIX_ALERTMANAGER_RECEIVER"] = "test"

from lambda_function import to_alertmanager


class TestLambda(unittest.TestCase):
    def test_upper(self):
        payload_in = {
            "AlarmName": "TestAlarm",
            "AlarmDescription": "This is a test",
            "AWSAccountId": "12346789",
            "NewStateValue": "ALARM",
            "NewStateReason": "Threshold Crossed: 1 out of the last 1 datapoints [1.0 (21/09/20 13:51:00)] was less than or equal to the threshold (10.0) (minimum 1 datapoint for OK -> ALARM transition).",
            "StateChangeTime": "2020-09-21T13:52:36.560+0000",
            "Region": "EU (Frankfurt)",
            "AlarmArn": "arn:aws:cloudwatch:eu-central-1:12346789:alarm:TestAlarm",
            "OldStateValue": "INSUFFICIENT_DATA",
        }
        result = to_alertmanager(payload_in)
        self.assertEquals(
            result,
            {
                "receiver": "test",
                "status": "firing",
                "alerts": [
                    {
                        "status": "firing",
                        "labels": {"instance": "TestAlarm", "job": "TestAlarm"},
                        "annotations": {
                            "description": "This is a test (EU (Frankfurt))"
                        },
                        "generatorURL": "https://console.aws.amazon.com/cloudwatch/home?region=EU (Frankfurt)#alarm:alarmFilter=ANY;name=TestAlarm",
                    }
                ],
            },
        )


if __name__ == "__main__":
    unittest.main()
