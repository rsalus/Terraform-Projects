########################################################################
#       Variables
########################################################################

## General ##

variable "application_name" {
  description = "Name of the application"
  default     = "generic_application"
}

variable "environment" {
  description = "The environment we are spinning up infrastructure in. Ex: np, prod."
}

variable "region" {
}

variable "primary_region" {
  # Set to desired region
  default = ""
}

variable "ghe_url" {
  default = ""
}

variable "service_name" {
  description = "The first part of the name of the service (usually api or www)"
  default     = "api"
}


## Parameters ##

variable "splunk_hec_token" {
  description = "Optional Splunk HTTP Event Collector token enables Splunk log driver"
  default     = ""
}

variable "sns_pagerduty_topic" {
  description = "SNS topic for PagerDuty notifications"
  type        = string
}

variable "statsd_host" {
  default = ""
}

variable "vpc_id" {
}

variable "account" {
}

variable "domain_name" {
}

variable "subdomain" {
}

variable "task_role_arn" {
}

variable "task_execution_role_arn" {
}

variable "is_primary" {
  description = "Is primary module"
}

variable "aws_regions" {
  type = list(string)
}

## Passthrough ##

variable "default_tags" {
}

variable "generic_base_domain" {
}

variable "generic_subdomain" {
}

variable "generic_primary_region_domain" {
}

variable "generic_secondary_region_domain" {
}
