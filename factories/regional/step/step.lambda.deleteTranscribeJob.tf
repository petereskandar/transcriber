############################################
## STEP Function - Delete Transcribe Job
## && Send Notification Lambda
############################################


####################################
## Lambda Creation
####################################

resource "aws_lambda_function" "transcriber_email_sender" {
  filename      = "${path.module}/lambda_deleteTranscribeJob/lambda.zip"
  function_name = "TRANSCRIBER_EMAIL_SENDER"
  role          = aws_iam_role.transcriber_email_sender_role.arn
  description   = "This Lambda will delete Transcribe Job after completion and send email with the final results"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 600
  environment {
    variables = {
      REGION       = data.aws_region.current.name,
      SENDER_EMAIL = var.sender_email
    }
  }
  tags = var.tags
}

// create Lambda CloudWatch Log Group
resource "aws_cloudwatch_log_group" "transcriber_email_sender_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.transcriber_email_sender.function_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "transcriber_email_sender_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_deleteTranscribeJob/"
  output_path = "${path.module}/lambda_deleteTranscribeJob/lambda.zip"
}

resource "aws_iam_role" "transcriber_email_sender_role" {
  name               = "TranscriberEmailSenderRole"
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

resource "aws_iam_role_policy_attachment" "transcriber_email_sender_role_policy-attachment" {
  role       = aws_iam_role.transcriber_email_sender_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Policy to allow AWS Transcribe Actions for the Lambda Function
data "aws_iam_policy_document" "transcriber_email_sender_policy" {
  statement {
    sid = "AllowTranscribeActions"
    actions = [
      "ses:SendEmail",
      "transcribe:DeleteTranscriptionJob"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "transcriber_email_sender_policy" {
  name   = "TranscriberEmailSenderPolicy"
  role   = aws_iam_role.transcriber_email_sender_role.id
  policy = data.aws_iam_policy_document.transcriber_email_sender_policy.json
}