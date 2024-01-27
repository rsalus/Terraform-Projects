########################################################################
#       Load Balancer
########################################################################

resource "aws_lb" "alb" {
  name               = "alb-${var.application_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = data.aws_subnets.public.ids

  access_logs {
    bucket  = aws_s3_bucket.access_logs.id
    prefix  = var.environment
    enabled = true
  }

  tags = var.default_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.dns.ssl_region_cert

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not configured"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_certificate" "lb_cert" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = module.dns.ssl_cert
}

resource "aws_lb_target_group" "instance_tg" {
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.selected.id

  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    enabled  = true
    path     = "/healthz"
    timeout  = 15
    interval = 60
    matcher  = "200-299"
  }

  depends_on = [aws_lb.alb]
}

resource "aws_lb_target_group" "instance_tg" {
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.selected.id

  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    enabled  = true
    path     = "/healthz"
    timeout  = 15
    interval = 60
    matcher  = "200-299"
  }

  depends_on = [aws_lb.alb]
}


########################################################################
#       Load Balancer Rules
########################################################################

locals {
  prefix = var.environment == "np" ? "api-dev" : "api"
  env    = var.environment == "np" ? "dev" : "production"
}

resource "aws_lb_listener_rule" "dr_forward" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance_tg.arn
  }

  condition {
    host_header {
      values = [
        "${local.prefix}.${var.subdomain}.${var.domain_name}"
      ]
    }
  }
}

resource "aws_lb_listener_rule" "alb_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance_tg.arn
  }

  condition {
    host_header {
      values = [
        "${local.prefix}.${var.region}.${var.subdomain}.${var.domain_name}"
      ]
    }
  }
}

resource "aws_lb_listener_rule" "redirects" {
  for_each = {
    next = {
      hostname = "api-next-${local.env}.${var.region}.${var.subdomain}.${var.domain_name}"
      instance = "api-${local.env}.${var.region}.${var.subdomain}.${var.domain_name}"
    }
    prev = {
      hostname = "api-prev-${local.env}.${var.region}.${var.subdomain}.${var.domain_name}"
      instance = "api-${local.env}.${var.region}.${var.subdomain}.${var.domain_name}"
    }
  }

  listener_arn = aws_lb_listener.https.arn

  action {
    type = "redirect"
    redirect {
      host        = each.value.instance
      status_code = "HTTP_302"
    }
  }

  condition {
    host_header {
      values = [each.value.hostname]
    }
  }
}

resource "aws_lb_listener_rule" "live" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance_tg.arn
  }

  condition {
    host_header {
      values = [
        "api-${local.env}.${var.region}.${var.subdomain}.${var.domain_name}"
      ]
    }
  }
}


########################################################################
#       Security Group
########################################################################

resource "aws_security_group" "alb_security_group" {
  name        = "${var.application_name}-${var.environment}-ingress"
  description = "Allow public traffic on 80 and 443"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}
