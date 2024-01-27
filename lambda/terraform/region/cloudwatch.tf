########################################################################
#       Cloudwatch
########################################################################

locals {
  alarm_name_prefix = "${var.environment}-${var.region}: ${var.application_name}>"
}

resource "aws_cloudwatch_log_group" "lambda_logs-GenericTrigger" {
  name = "/aws/lambda/GenericTrigger-${var.environment}-${var.region}"

  retention_in_days = "30"
}

# ErrorCount Metric
resource "aws_cloudwatch_log_metric_filter" "errorCount" {
  name           = "GenericTrigger-metrics-ErrorCount"
  pattern        = "Error-dictionary"
  log_group_name = aws_cloudwatch_log_group.lambda_logs-GenericTrigger.name
  metric_transformation {
    name          = "ErrorCount"
    namespace     = var.application_name
    value         = 1
    default_value = 0
  }
}

# Alarm for ErrorCount metric > threshold
resource "aws_cloudwatch_metric_alarm" "ErrorCount_TooHigh" {
  alarm_name          = "${local.alarm_name_prefix} GenericTrigger ErrorCount TooHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "ErrorCount"
  namespace           = var.application_name
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors error count in GenericTrigger-${var.environment}-${var.region} application."
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    data.aws_sns_topic.service-alarm.arn
  ]
}

# High Priority
data "aws_sns_topic" "service-alarm" {
  name = "service-alarm"
}

resource "aws_sns_topic_subscription" "service-All-Hours-RuleSet" {
  protocol               = "https"
  endpoint               = var.alarm_cloudwatch_service
  endpoint_auto_confirms = true
  topic_arn              = data.aws_sns_topic.service-alarm.arn
}
