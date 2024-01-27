########################################################################
#       Region
########################################################################

# for_each over aws_regions would be great here, but you can't set the provider when using it
# https://github.com/hashicorp/terraform/issues/24476

module "primary" {
  source = "./region"

  providers = {
    aws = aws.primary
  }

  application_name                       = var.application_name
  environment                            = var.environment
  region                                 = var.aws_regions[0]
  account                                = var.account
  lambda_role                            = module.global.lambda_role
  pagerduty_cloudwatch_service_all_hours = var.pagerduty_cloudwatch_service_all_hours
  default_tags                           = local.default_tags
}

module "secondary" {
  source = "./region"

  providers = {
    aws = aws.secondary
  }

  application_name                       = var.application_name
  environment                            = var.environment
  region                                 = var.aws_regions[1]
  account                                = var.account
  lambda_role                            = module.global.lambda_role
  pagerduty_cloudwatch_service_all_hours = var.pagerduty_cloudwatch_service_all_hours
  default_tags                           = local.default_tags
}
