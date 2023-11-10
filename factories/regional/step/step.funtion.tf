####################################
## STEP Function Definition
####################################

resource "aws_sfn_state_machine" "sfn_transcribe_state_machine" {
  name     = "AudioTranscribeStateMachine"
  role_arn = aws_iam_role.sfn_transcribe_state_machine_role.arn
  tags     = var.tags
  // "arn:aws:lambda:eu-west-3:250950161175:function:transcribeS3ObjOnUpload:$LATEST",
  // "arn:aws:lambda:eu-west-3:250950161175:function:deleteTranscriptionJob:$LATEST",
  definition = <<EOF
{
  "Comment": "Transcribe an object uploded to S3",
  "StartAt": "transcribe",
  "States": {
    "transcribe": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${aws_lambda_function.transcriber_job_starter.arn}",
        "Payload": {
          "Input.$": "$"
        }
      },
      "Next": "transcribe-wait"
    },
    "transcribe-wait": {
      "Type": "Wait",
      "Seconds": 2,
      "Next": "transcribe-status"
    },
    "transcribe-status": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:eu-west-3:250950161175:function:lambdaTranscribeStatusChecker:$LATEST",
        "Payload": {
          "Input.$": "$"
        }
      },
      "Next": "transcribe-complete"
    },
    "transcribe-complete": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Payload.TranscriptionJobStatus",
          "StringEquals": "COMPLETED",
          "Next": "success"
        },
        {
          "Variable": "$.Payload.TranscriptionJobStatus",
          "StringEquals": "FAILED",
          "Next": "error"
        }
      ],
      "Default": "transcribe-wait"
    },
    "delete-transcription-job": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${aws_lambda_function.transcriber_email_sender.arn}", 
        "Payload": {
          "Input.$": "$"
        }
      },
      "End": true
    },
    "success": {
      "Type": "Pass",
      "Next": "delete-transcription-job"
    },
    "error": {
      "Type": "Pass",
      "Next": "delete-transcription-job"
    }
  }
}
EOF
}


####################################
## STEP Function - IAM Role
####################################

resource "aws_iam_role" "sfn_transcribe_state_machine_role" {
  name               = "TranscribeStateMachineRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sfn_transcribe_state_machine_role_policy-attachment" {
  role       = aws_iam_role.sfn_transcribe_state_machine_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}