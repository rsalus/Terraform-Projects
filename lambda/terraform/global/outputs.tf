output "lambda_role" {
  value = {
    name = iamrole.lambda_role.name
    arn  = iamrole.lambda_role.arn
  }
}
