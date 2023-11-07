output "user_pool_endpoint" {
  value = aws_cognito_user_pool.transcriber_user_pool.endpoint
}

// user pool id
output "user_pool_id" {
  value = aws_cognito_user_pool.transcriber_user_pool.id
}

// user pool arn
output "user_pool_arn" {
  value = aws_cognito_user_pool.transcriber_user_pool.arn
}

// user pool WebClientID
output "user_pool_webClientId" {
  value = aws_cognito_user_pool_client.transcriber_client.id
}

// Cognito Identity Pool Id
output "identity_pool_id" {
  value = aws_cognito_identity_pool.transcriber_identity_pool.id
}
