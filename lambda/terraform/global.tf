########################################################################
#       Global
########################################################################

module "global" {
  source = "./global"

  application_name = var.application_name
  default_tags     = local.default_tags
  account          = var.account
  aws_regions      = var.aws_regions
}
