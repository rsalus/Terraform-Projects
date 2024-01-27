########################################################################
#       ECS Cluster
########################################################################

resource "aws_ecs_cluster" "generic_cluster" {
  name = "generic"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.default_tags
}


########################################################################
#       ECS Task Definition
########################################################################

locals {
  # Set this to your AWS service path
  deploymentPath = "generic-path"
}

resource "aws_ecs_task_definition" "generic_task" {
  family       = var.application_name
  network_mode = "awsvpc"

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.task_execution_role_arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096

  container_definitions = <<EOF
[
	{
		"name": "${var.application_name}",
		"image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.application_name}/${local.deploymentPath}:latest",
		"portMappings": [
			{
				"containerPort": 80,
				"hostPort": 80,
				"protocol": "tcp"
			}
		],
		"essential": true,
		"environment": [
			{
				"name": "CONTEXT_REGION",
				"value": "${var.region}"
			},
			{
				"name": "CONTEXT_ACCOUNT",
				"value": "${var.account}"
			},
			{
				"name": "CONTEXT_ENVIRONMENT",
				"value": "${var.environment}"
			},
			{
				"name": "APP_NAME",
				"value": "${var.application_name}"
			},
		],
		"logConfiguration": {
			"logDriver": "awslogs",
			"options": {
				"awslogs-group": "${aws_cloudwatch_log_group.app_logs.name}",
				"awslogs-region": "${var.region}",
				"awslogs-stream-prefix": "${var.application_name}"
			}
		}
	},
]
EOF
}

data "aws_ecs_task_definition" "generic_latest" {
  task_definition = aws_ecs_task_definition.generic_task.family
}


########################################################################
#       ECS Service
########################################################################

resource "aws_ecs_service" "generic-service" {
  name            = var.application_name
  cluster         = aws_ecs_cluster.generic_cluster.id
  task_definition = data.aws_ecs_task_definition.generic_latest.arn
  desired_count   = 1

  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 120

  load_balancer {
    target_group_arn = aws_lb_target_group.instance_tg.arn
    container_name   = var.application_name
    container_port   = 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.instance_tg.arn
    container_name   = var.application_name
    container_port   = 80
  }

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.generic_task_security_group.id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [ aws_lb_listener_rule.dr_forward ]
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.generic_cluster.name
  capacity_providers = ["FARGATE"]
}

locals {
  ecs_task_max_counts = {
    np   = 10
    prod = 40
  }
  ecs_task_max_count = local.ecs_task_max_counts[var.environment]
}


########################################################################
#       Security Group
########################################################################

resource "aws_security_group" "generic_task_security_group" {
  name        = "${var.application_name}-${var.environment}-task"
  description = "Allow VPC traffic on 80"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}


########################################################################
#       Application AutoScaling
########################################################################

resource "aws_appautoscaling_target" "task" {
  min_capacity = 1
  max_capacity = local.ecs_task_max_count

  resource_id        = "service/${aws_ecs_cluster.generic_cluster.name}/${aws_ecs_service.generic-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [min_capacity]
  }
}

resource "aws_appautoscaling_policy" "live_alb" {
  name               = "target-alb-policy"
  resource_id        = aws_appautoscaling_target.task.resource_id
  scalable_dimension = aws_appautoscaling_target.task.scalable_dimension
  service_namespace  = aws_appautoscaling_target.task.service_namespace

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.alb.arn_suffix}/${aws_lb_target_group.instance_tg.arn_suffix}"
    }

    target_value       = 1000
    scale_out_cooldown = 30
    scale_in_cooldown  = 300
  }
}

resource "aws_appautoscaling_policy" "live_cpu" {
  name               = "target-cpu-policy"
  resource_id        = aws_appautoscaling_target.task.resource_id
  scalable_dimension = aws_appautoscaling_target.task.scalable_dimension
  service_namespace  = aws_appautoscaling_target.task.service_namespace

  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}

########################################################################
#       S3 Access Logs
########################################################################

locals {
  elb_account_region_map = { "us-east-1" = "", "us-east-2" = "", "us-west-1" = "", "us-west-2" = "", "af-south-1" = "", "ca-central-1" = "", "eu-central-1" = "", "eu-west-1" = "", "eu-west-2" = "", "eu-south-1" = "", "eu-west-3" = "", "eu-north-1" = "", "ap-east-1" = "", "ap-northeast-1" = "", "ap-northeast-2" = "", "ap-northeast-3" = "", "ap-southeast-1" = "", "ap-southeast-2" = "", "ap-south-1" = "", "me-south-1" = "", "sa-east-1" = "" }
}

resource "aws_s3_bucket" "access_logs" {
  bucket        = lower("${var.application_name}-${var.environment}-${var.region}-access-logs")
  force_destroy = true
  tags          = var.default_tags
}

resource "aws_s3_bucket_public_access_block" "restrict_public_access" {
  bucket              = aws_s3_bucket.access_logs.id
  block_public_acls   = true
  block_public_policy = true
}

resource "time_sleep" "wait_30_seconds" {
  # s3 bucket policy and public access block don't like running in parallel
  depends_on       = [aws_s3_bucket.access_logs, aws_s3_bucket_public_access_block.restrict_public_access]
  create_duration  = "30s"
  destroy_duration = "30s"
}

resource "aws_s3_bucket_policy" "access_log_policy" {
  depends_on = [time_sleep.wait_30_seconds]
  bucket     = aws_s3_bucket.access_logs.id
  policy     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.elb_account_region_map[var.region]}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.access_logs.arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.access_logs.arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.access_logs.arn}"
    }
  ]
}
EOF
}
