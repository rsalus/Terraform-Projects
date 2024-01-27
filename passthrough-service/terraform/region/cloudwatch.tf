########################################################################
#       Cloudwatch
########################################################################

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = var.application_name
  retention_in_days = 30
  tags              = var.default_tags
}
