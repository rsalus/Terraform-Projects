########################################################################
#       Variables
########################################################################

variable "application_name" {
  description = "Name of the application"
}

variable "default_tags" {
}

variable "account" {
}

variable "aws_regions" {
  type = list(string)
}
