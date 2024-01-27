########################################################################
#       Variables
########################################################################

variable "application_name" {
  description = "Name of the application"
}

variable "account" {
}

variable "default_tags" {
}

variable "environment" {
  description = "The environment we are spinning up infrastructure in. Ex: lab, np, prod."
}

variable "vpc_id" {
}

variable "domain_name" {
}

variable "is_primary" {
  description = "Is primary module"
}

variable "aws_regions" {
  type = list(string)
}

variable "subdomain" {
}

variable "alb_arn" {
}

variable "region" {
}

variable "generic_base_domain" {
}

variable "generic_subdomain" {
}

variable "generic_primary_region_domain" {
}

variable "generic_secondary_region_domain" {
}
