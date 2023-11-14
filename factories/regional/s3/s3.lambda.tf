####################################
## S3 Event Notification - Lambda
####################################

// Trigger Lambda on all Object Create related Events"
resource "aws_s3_bucket_notification" "audio_transcriber_bucket_notifications" {
  bucket = aws_s3_bucket.audio_transcriber_bucket.id
  lambda_function {
    id                  = "Trigger Lambda on Audio Upload"
    lambda_function_arn = aws_lambda_function.transcriber_lambda_starter.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "Transcribe/"
  }
  depends_on = [aws_lambda_permission.allow_audio_transcriber_bucket]
}

// Allow S3 Lambda Invokation
resource "aws_lambda_permission" "allow_audio_transcriber_bucket" {
  source_arn    = aws_s3_bucket.audio_transcriber_bucket.arn
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transcriber_lambda_starter.arn
  principal     = "s3.amazonaws.com"
}


####################################
## S3 - Lambda Creation
####################################

resource "aws_lambda_function" "transcriber_lambda_starter" {
  filename      = "${path.module}/lambda/lambda.zip"
  function_name = "TRANSCRIBER_LAMBDA_STARTER"
  role          = aws_iam_role.transcriber_lambda_starter_code_iam.arn
  description   = "This Lambda will be triggered by S3 on Audio File Upload to Trigger a Step Function responsible for Audio Transcription"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 600
  environment {
    variables = {
      STATEMACHINEARN = "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:AudioTranscribeStateMachine"
    }
  }
}

// create Lambda CloudWatch Log Group
resource "aws_cloudwatch_log_group" "transcriber_lambda_starter_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.transcriber_lambda_starter.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "transcriber_lambda_starter_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_iam_role" "transcriber_lambda_starter_code_iam" {
  name               = "TranscriberLambdaStarterRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "transcriber_lambda_starter_code_iam_policy-attachment" {
  role       = aws_iam_role.transcriber_lambda_starter_code_iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Policy to allow Step Function Actions for the Lambda Function
data "aws_iam_policy_document" "transcriber_lambda_starter_code_iam_step_policy" {

  statement {
    sid = "AllowStepStartExecution"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:AudioTranscribeStateMachine"
    ]
  }
}

resource "aws_iam_role_policy" "transcriber_lambda_starter_code_iam_policy_step_policy" {
  name   = "TranscriberLambdaStarterPolicy"
  role   = aws_iam_role.transcriber_lambda_starter_code_iam.id
  policy = data.aws_iam_policy_document.transcriber_lambda_starter_code_iam_step_policy.json
}