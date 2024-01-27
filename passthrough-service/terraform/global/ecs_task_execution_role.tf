########################################################################
#       IAM Role
########################################################################

resource "iamrole" "ecs_task_execution_role" {
  name                     = "${var.application_name}-task-execution-role"
  type                     = "Amazon EC2 Container Service Task Role"
  tags                     = var.default_tags
  include_default_policies = false
}

########################################################################
#       Policies
########################################################################

resource "aws_iam_role_policy" "ecs_task_execution_role_policies" {
  name   = "ecs_task_execution_role_policies"
  role   = iamrole.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.task_execution_inline_policies.json
}

data "aws_iam_policy_document" "task_execution_inline_policies" {
  statement {
    sid    = "Cloudwatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:${lower(var.application_name)}",
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:${lower(var.application_name)}:*:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  role       = iamrole.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "SSMReadOnlyAccess_Execution" {
  role       = iamrole.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
