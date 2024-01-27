locals {
  live_env              = var.environment == "np" ? "dev" : "production"
  soa_region_ns         = var.region == "us-east-1" ? var.generic_primary_region_domain.name_servers : var.generic_secondary_region_domain.name_servers
  current_region_domain = var.region == "us-east-1" ? var.generic_primary_region_domain : var.generic_secondary_region_domain
}


########################################################################
#       Route53 Certificates
########################################################################

## Global (generic)
resource "aws_acm_certificate" "cert" {
  domain_name       = var.generic_subdomain.name
  validation_method = "DNS"
  subject_alternative_names = [
    "*.${var.subdomain}.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "generic_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.generic_subdomain.id
}

// Cert validation may timeout
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.generic_cert_validation : record.fqdn]
}

## Regional
resource "aws_acm_certificate" "region_cert" {
  domain_name       = local.current_region_domain.name
  validation_method = "DNS"
  subject_alternative_names = [
    "*.${var.region}.${var.subdomain}.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "generic_region_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.region_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.current_region_domain.id
}

// Cert validation may timeout
resource "aws_acm_certificate_validation" "region_cert" {
  certificate_arn         = aws_acm_certificate.region_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.generic_region_cert_validation : record.fqdn]
}


########################################################################
#       Route53 Records
########################################################################

## SOA
resource "aws_route53_record" "soa" {
  allow_overwrite = true
  zone_id         = var.generic_subdomain.id
  name            = var.generic_subdomain.name
  type            = "SOA"
  ttl             = "30"
  count           = var.is_primary ? 1 : 0

  records = [
    "${var.generic_subdomain.name_servers[0]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

resource "aws_route53_record" "soa_region" {
  allow_overwrite = true
  zone_id         = local.current_region_domain.id
  name            = local.current_region_domain.name
  type            = "SOA"
  ttl             = "30"

  records = [
    "${local.soa_region_ns[0]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

## NS
resource "aws_route53_record" "base_sub_name_servers" {
  zone_id = var.generic_base_domain.zone_id
  name    = var.subdomain
  type    = "NS"
  ttl     = "30"
  records = var.generic_subdomain.name_servers
  count   = var.is_primary ? 1 : 0
}

// Regional
resource "aws_route53_record" "base_region_name_servers" {
  zone_id = var.generic_base_domain.zone_id
  name    = local.current_region_domain.name
  type    = "NS"
  ttl     = "30"
  records = local.current_region_domain.name_servers
}

// Regional
resource "aws_route53_record" "sub_region_name_servers" {
  zone_id = var.generic_subdomain.zone_id
  name    = local.current_region_domain.name
  type    = "NS"
  ttl     = "30"
  records = local.current_region_domain.name_servers
}

## A
// Regional
resource "aws_route53_record" "dr_failover" {
  zone_id = var.generic_subdomain.zone_id
  name    = "api-${local.live_env}"
  type    = "A"

  weighted_routing_policy {
    weight = 50
  }

  set_identifier = "${var.region}-${var.environment}-weighted"

  health_check_id = aws_route53_health_check.healthcheck.id
  alias {
    name                   = data.aws_alb.alb.dns_name
    zone_id                = data.aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}

// Regional
resource "aws_route53_record" "alias" {
  zone_id = local.current_region_domain.id
  name    = "api.${var.region}.${var.generic_subdomain.name}"
  type    = "A"
  alias {
    name                   = data.aws_alb.alb.dns_name
    zone_id                = data.aws_alb.alb.zone_id
    evaluate_target_health = false
  }
}

// Regional
resource "aws_route53_record" "region" {
  for_each = {
    next = "api-next-${local.live_env}.${var.region}.${var.generic_subdomain.name}"
    live = "api-${local.live_env}.${var.region}.${var.generic_subdomain.name}"
    prev = "api-prev-${local.live_env}.${var.region}.${var.generic_subdomain.name}"
  }

  zone_id = local.current_region_domain.id
  name    = each.value
  type    = "A"
  alias {
    name                   = data.aws_alb.alb.dns_name
    zone_id                = data.aws_alb.alb.zone_id
    evaluate_target_health = false
  }
}
