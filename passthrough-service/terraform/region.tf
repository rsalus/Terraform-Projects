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

  application_name                = var.application_name
  environment                     = var.environment
  region                          = var.aws_regions[0]
  primary_region                  = var.primary_region
  ghe_url                         = var.ghe_url
  service_name                    = var.service_name
  splunk_hec_token                = var.splunk_hec_token
  sns_pagerduty_topic             = var.sns_pagerduty_topic
  statsd_host                     = var.statsd_host
  vpc_id                          = var.vpc_id
  account                         = var.account
  domain_name                     = var.domain_name
  subdomain                       = var.subdomain
  task_role_arn                   = module.global.ecs_task_role.arn
  task_execution_role_arn         = module.global.ecs_task_execution_role.arn
  default_tags                    = local.default_tags
  is_primary                      = true
  aws_regions                     = var.aws_regions
  generic_base_domain             = module.global.generic_base_domain
  generic_subdomain               = module.global.generic_subdomain
  generic_primary_region_domain   = module.global.generic_primary_region_domain
  generic_secondary_region_domain = module.global.generic_secondary_region_domain
}

module "secondary" {
  source = "./region"

  providers = {
    aws = aws.secondary
  }

  application_name                = var.application_name
  environment                     = var.environment
  region                          = var.aws_regions[1]
  primary_region                  = var.primary_region
  ghe_url                         = var.ghe_url
  service_name                    = var.service_name
  splunk_hec_token                = var.splunk_hec_token
  sns_pagerduty_topic             = var.sns_pagerduty_topic
  statsd_host                     = var.statsd_host
  vpc_id                          = var.vpc_id_secondary
  account                         = var.account
  domain_name                     = var.domain_name
  subdomain                       = var.subdomain
  task_role_arn                   = module.global.ecs_task_role.arn
  task_execution_role_arn         = module.global.ecs_task_execution_role.arn
  default_tags                    = local.default_tags
  is_primary                      = false
  aws_regions                     = var.aws_regions
  generic_base_domain             = module.global.generic_base_domain
  generic_subdomain               = module.global.generic_subdomain
  generic_primary_region_domain   = module.global.generic_primary_region_domain
  generic_secondary_region_domain = module.global.generic_secondary_region_domain
}
