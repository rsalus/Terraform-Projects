output "ecs_task_role" {
  value = {
    name = iamrole.ecs_task_role.name
    arn  = iamrole.ecs_task_role.arn
  }
}

output "ecs_task_execution_role" {
  value = {
    name = iamrole.ecs_task_execution_role.name
    arn  = iamrole.ecs_task_execution_role.arn
  }
}

output "generic_base_domain" {
  value = {
    id           = aws_route53_zone.generic_base_domain.id
    zone_id      = aws_route53_zone.generic_base_domain.zone_id
    name         = aws_route53_zone.generic_base_domain.name
    name_servers = aws_route53_zone.generic_base_domain.name_servers
  }
}

output "generic_subdomain" {
  value = {
    id           = aws_route53_zone.generic_subdomain.id
    zone_id      = aws_route53_zone.generic_subdomain.zone_id
    name         = aws_route53_zone.generic_subdomain.name
    name_servers = aws_route53_zone.generic_subdomain.name_servers
  }
}

output "generic_primary_region_domain" {
  value = {
    id           = aws_route53_zone.generic_primary_region_domain.id
    zone_id      = aws_route53_zone.generic_primary_region_domain.zone_id
    name         = aws_route53_zone.generic_primary_region_domain.name
    name_servers = aws_route53_zone.generic_primary_region_domain.name_servers
  }
}

output "generic_secondary_region_domain" {
  value = {
    id           = aws_route53_zone.generic_secondary_region_domain.id
    zone_id      = aws_route53_zone.generic_secondary_region_domain.zone_id
    name         = aws_route53_zone.generic_secondary_region_domain.name
    name_servers = aws_route53_zone.generic_secondary_region_domain.name_servers
  }
}
