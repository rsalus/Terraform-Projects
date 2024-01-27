########################################################################
#       Health Check
########################################################################

resource "aws_route53_health_check" "healthcheck" {
  reference_name    = "${var.application_name}-${var.environment}-${var.region}-hc"
  failure_threshold = "3"
  fqdn              = "api-${local.live_env}.${var.region}.${var.subdomain}.${var.domain_name}"
  port              = 443
  request_interval  = "30"
  resource_path     = "/health"
  search_string     = "\"HealthStatus\":\"Healthy\""
  type              = "HTTPS_STR_MATCH"
  tags = {
    Name = "${var.application_name}-${var.environment}-${var.region}-hc"
  }
}
