############################################
## STEP Function - Start Transcribe Lambda
############################################


####################################
## Lambda Creation
####################################

resource "aws_lambda_function" "transcriber_job_starter" {
  filename      = "${path.module}/lambda_startTranscribe/lambda.zip"
  function_name = "TRANSCRIBER_JOB_STARTER"
  role          = aws_iam_role.transcriber_job_starter_role.arn
  description   = "This Lambda will Start AWS Transcribe Job"
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

data "archive_file" "transcriber_job_starter_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_startTranscribe/"
  output_path = "${path.module}/lambda_startTranscribe/lambda.zip"
}

resource "aws_iam_role" "transcriber_job_starter_role" {
  name               = "TranscriberJobStarterRole"
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

resource "aws_iam_role_policy_attachment" "transcriber_job_starter_role_policy-attachment" {
  role       = aws_iam_role.transcriber_job_starter_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Policy to allow AWS Transcribe Actions for the Lambda Function
data "aws_iam_policy_document" "transcriber_job_starter_role_step_policy" {

  statement {
    sid = "AllowTranscribeActions"
    actions = [
      "transcribe:List*",
      "transcribe:Describe*",
      "transcribe:Get*",
      "transcribe:StartTranscriptionJob",
      "s3:Get*",
      "s3:List*",
      "s3:Describe*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "transcriber_job_starter_code_iam_policy_step_policy" {
  name   = "TranscriberJobStarterPolicy"
  role   = aws_iam_role.transcriber_job_starter_role.id
  policy = data.aws_iam_policy_document.transcriber_job_starter_role_step_policy.json
}