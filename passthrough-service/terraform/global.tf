########################################################################
#       Global
########################################################################

module "global" {
  source = "./global"

  application_name = var.application_name
  account          = var.account
  default_tags     = local.default_tags
  environment      = var.environment
  vpc_id           = var.vpc_id
  domain_name      = var.domain_name
  subdomain        = var.subdomain
  aws_regions      = var.aws_regions
}
