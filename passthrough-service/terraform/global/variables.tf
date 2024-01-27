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

variable "subdomain" {
}

variable "aws_regions" {
  type = list(string)
}
