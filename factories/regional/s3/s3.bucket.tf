####################################
## S3 Bucket Creation
####################################

resource "random_string" "random" {
  length  = 5
  numeric = false
  special = false
}

resource "aws_s3_bucket" "audio_transcriber_bucket" {
  bucket = lower("audio-transcriber-bucket-${random_string.random.result}")
  tags   = var.tags
}

####################################
## S3 Bucket - CORS Configuration
####################################
resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.audio_transcriber_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://${var.domain_name_prefix}.${var.domain_name}"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

####################################
## S3 Bucket Policy Creation
####################################

resource "aws_s3_bucket_policy" "audio_transcriber_bucket_policy" {
  bucket = aws_s3_bucket.audio_transcriber_bucket.bucket
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "${aws_s3_bucket.audio_transcriber_bucket.arn}",
        "${aws_s3_bucket.audio_transcriber_bucket.arn}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
POLICY
}

####################################
## S3 Bucket Lifecycle Rule
####################################

// lifecycle rule to empty folder everyday
resource "aws_s3_bucket_lifecycle_configuration" "audio_transcriber_bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.audio_transcriber_bucket.id
  rule {
    id = "AUDIO_RETENTION"
    expiration {
      days = 1
    }
    filter {
      prefix = "Transcriber/"
    }
    status = "Enabled"
  }
}

