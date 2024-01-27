########################################################################
#       IAM Role
########################################################################

resource "iamrole" "ecs_task_role" {
  name                     = "${var.application_name}-task-role"
  type                     = "Amazon EC2 Container Service Task Role"
  tags                     = var.default_tags
  include_default_policies = false
}


########################################################################
#       Policies
########################################################################

resource "aws_iam_role_policy" "generic_ecs_task_Policy" {
  name = "generic_ecs_task_Policy"
  role = iamrole.ecs_task_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectRetention",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectRetention",
          "s3:ListBucket",
          "s3:GetBucketAcl"
        ],
        "Resource" : [
          "arn:aws:s3:::generic-bucket-${var.account}-us-east-1/*",
          "arn:aws:s3:::generic-bucket-${var.account}-us-east-2/*",
          "arn:aws:s3:::generic-bucket-${var.account}-us-east-1",
          "arn:aws:s3:::generic-bucket-${var.account}-us-east-2"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : [
          "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/All/*",
          "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/${lower(var.application_name)}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "SSMReadOnlyAccess_TaskRole" {
  role       = iamrole.ecs_task_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
