module "dns" {
  source = "./dns"

  domain_name                     = var.domain_name
  environment                     = var.environment
  account                         = var.account
  vpc_id                          = var.vpc_id
  default_tags                    = var.default_tags
  application_name                = var.application_name
  is_primary                      = var.is_primary
  aws_regions                     = var.aws_regions
  subdomain                       = var.subdomain
  alb_arn                         = aws_lb.alb.arn
  region                          = var.region
  generic_base_domain             = var.generic_base_domain
  generic_subdomain               = var.generic_subdomain
  generic_primary_region_domain   = var.generic_primary_region_domain
  generic_secondary_region_domain = var.generic_secondary_region_domain
}
