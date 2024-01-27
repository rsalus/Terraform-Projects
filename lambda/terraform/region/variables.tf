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

variable "alarm_cloudwatch_service" {
  description = "The alarm Integration URL to use as a webhook for CloudWatch alarms that will alert 24/7."
  default     = ""
}

variable "default_tags" {
}
