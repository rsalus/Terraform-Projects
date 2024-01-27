########################################################################
#       Route53 Domains
########################################################################

resource "aws_route53_zone" "generic_base_domain" {
  name = var.domain_name
}

resource "aws_route53_zone" "generic_subdomain" {
  name = "${var.subdomain}.${var.domain_name}"
}

resource "aws_route53_zone" "generic_primary_region_domain" {
  name = "${var.aws_regions[0]}.${var.subdomain}.${var.domain_name}"
}

resource "aws_route53_zone" "generic_secondary_region_domain" {
  name = "${var.aws_regions[1]}.${var.subdomain}.${var.domain_name}"
}
