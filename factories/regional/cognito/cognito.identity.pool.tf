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
    authenticated = aws_iam_role.cognito_authenticated_role.arn
  }
}

########################################
## COGNITO - IDENTITY POOL
## AUTHENTICATED IAM Role
######################################## 

// Cognito Identity Pool Authenticated Role
resource "aws_iam_role" "cognito_authenticated_role" {
  name               = "TranscriberAuthenticatedRole"
  assume_role_policy = data.aws_iam_policy_document.assume_cognito_authenticated_role_policy.json
}

// define trust relationship assume policy
data "aws_iam_policy_document" "assume_cognito_authenticated_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        "cognito-identity.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = ["${aws_cognito_identity_pool.transcriber_identity_pool.id}"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}


//  the policy content
data "aws_iam_policy_document" "cognito_authenticated_role_addon" {
  statement {
    sid = "AllowS3PutObject"
    actions = [
      "s3:PutObject"
    ]
    resources = ["*"]
  }
}

// the policy itself
resource "aws_iam_policy" "cognito_authenticated_role_addon" {
  name        = "CognitoAuthenticatedRole-Addon"
  description = "Provides additional grants to the TranscriberAuthenticatedRole"
  policy      = data.aws_iam_policy_document.cognito_authenticated_role_addon.json
}


// attach addon managed policy
resource "aws_iam_role_policy_attachment" "lambda_assume_role_attachment" {
  policy_arn = aws_iam_policy.cognito_authenticated_role_addon.arn
  role       = aws_iam_role.cognito_authenticated_role.id
}