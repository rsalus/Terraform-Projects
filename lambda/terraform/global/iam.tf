########################################################################
#       IAM Role
########################################################################

resource "iamrole" "lambda_role" {
  name                     = "${var.application_name}-role"
  type                     = "AWS Lambda"
  tags                     = var.default_tags
  include_default_policies = false
}


########################################################################
#       Policies
########################################################################

resource "aws_iam_role_policy_attachment" "lambda-execute-policy" {
  role       = iamrole.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_iam_role_policy_attachment" "xray-daemon-policy" {
  role       = iamrole.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "lambda-vpc-access-execution-policy" {
  role       = iamrole.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda-ssm-access" {
  name = "allow-get-params"
  role = iamrole.lambda_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ],
    "Resource": [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/all/*",
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/service/*"
    ]
  }]
}
EOF
}
