########################################
## COGNITO - IDENTITY POOL
########################################

resource "aws_cognito_identity_pool" "transcriber_identity_pool" {
  identity_pool_name               = "transcriber_identity_pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.transcriber_client.id
    provider_name           = aws_cognito_user_pool.transcriber_user_pool.endpoint
    server_side_token_check = true
  }
}


########################################
## COGNITO - IDENTITY POOL
## AUTHENTICATED USER ROLE ASSIGNMENT
########################################

resource "aws_cognito_identity_pool_roles_attachment" "transcriber_identity_pool_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.transcriber_identity_pool.id
  roles = {
    authenticated = "arn:aws:iam::250950161175:role/demo_identity_pool_tf"
  }
}
 