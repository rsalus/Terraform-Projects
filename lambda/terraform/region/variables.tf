########################################################################
#       Variables
########################################################################

variable "application_name" {
  description = "Name of the application"
  default     = "service.Lambda.Trigger"
}

variable "environment" {
  description = "The environment we are spinning up infrastructure in. Ex: np, prod."
}

variable "region" {
}

variable "account" {
}

variable "lambda_role" {
}

variable "pagerduty_cloudwatch_service_all_hours" {
  description = "The PagerDuty Integration URL to use as a webhook for CloudWatch alarms that will alert 24/7."
  default     = ""
}

variable "default_tags" {
}
