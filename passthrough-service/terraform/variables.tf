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

variable "aws_regions" {
  type = list(string)
}

variable "primary_region" {
  # Set to desired
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

variable "vpc_id_secondary" {
}

variable "account" {
}

variable "domain_name" {
}

variable "subdomain" {
}
