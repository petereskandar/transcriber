variable "tags" {
  type        = map(string)
  default     = {}
  description = ""
}

variable "identity_pool_id" {
  type        = string
  description = "Cognito Identity Pool Id"
}

variable "user_pool_id" {
  type        = string
  description = "Cognito User Pool Id"
}

variable "user_pool_webClientId" {
  type        = string
  description = "Cognito User Pool WebClientId"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 Bucket Used for Audio Files Upload"
}