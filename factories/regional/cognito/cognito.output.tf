output "user_pool_endpoint" {
  value = aws_cognito_user_pool.transcriber_user_pool.endpoint
}

output "user_pool_id" {
  value = aws_cognito_user_pool.transcriber_user_pool.id
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.transcriber_user_pool.arn
}
