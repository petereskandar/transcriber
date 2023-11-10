
// output bucket name
output "s3_bucket_name" {
  value = element(split(".", aws_s3_bucket.audio_transcriber_bucket.bucket_domain_name), 0)
}