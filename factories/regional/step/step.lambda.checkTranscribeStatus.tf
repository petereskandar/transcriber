############################################
## STEP Function - Check Transcribe Job
## Status
############################################


####################################
## Lambda Creation
####################################

resource "aws_lambda_function" "transcriber_job_checker" {
  filename      = "${path.module}/lambda_checkTranscribeStatus/lambda.zip"
  function_name = "TRANSCRIBER_JOB_STATUS_CHECKER"
  role          = aws_iam_role.transcriber_job_checker_role.arn
  description   = "This Lambda will check Transcribe Job Status"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 600
  environment {
    variables = {
      REGION = data.aws_region.current.name
    }
  }
  tags = var.tags
}

// create Lambda CloudWatch Log Group
resource "aws_cloudwatch_log_group" "transcriber_job_checker_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.transcriber_job_checker.function_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "transcriber_job_checker_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_checkTranscribeStatus/"
  output_path = "${path.module}/lambda_checkTranscribeStatus/lambda.zip"
}

resource "aws_iam_role" "transcriber_job_checker_role" {
  name               = "TranscriberJobCheckerRole"
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

resource "aws_iam_role_policy_attachment" "transcriber_job_checker_role_policy-attachment" {
  role       = aws_iam_role.transcriber_job_checker_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Policy to allow AWS Transcribe Actions for the Lambda Function
data "aws_iam_policy_document" "transcriber_job_checker_policy" {
  statement {
    sid = "AllowTranscribeActions"
    actions = [
      "transcribe:Get*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "transcriber_job_checker_role_policy" {
  name   = "TranscriberJobCheckerPolicy"
  role   = aws_iam_role.transcriber_job_checker_role.id
  policy = data.aws_iam_policy_document.transcriber_job_checker_policy.json
}