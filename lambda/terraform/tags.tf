locals {
  default_tags = {
    Application = var.application_name
    Environment = var.environment
    Name        = "service-lambda-${lower(var.environment)}"
  }
}
