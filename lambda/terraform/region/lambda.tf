########################################################################
#       Lambda
########################################################################

locals {
  environment_prefix = var.environment == "np" ? "Dev" : "Production"
}

data "aws_security_group" "redis_sg" {
  name = "${var.account}-${local.environment_prefix}-redis_sg"
}

data "aws_elasticache_subnet_group" "redis_subnets" {
  name = lower("${var.account}-${local.environment_prefix}-redis-subnet-group")
}

resource "aws_lambda_function" "GenericTrigger" {
  description   = "Stream PriceGuide files created from an AWS S3 bucket and store it in AWS Redis cache"
  filename      = "./service.Lambda.Trigger.zip"
  function_name = "GenericTrigger-${var.environment}-${var.region}"
  role          = var.lambda_role.arn
  handler       = "${var.application_name}::${var.application_name}.Functions::GenericTrigger"
  runtime       = "dotnet6"
  timeout       = "900" # seconds
  memory_size   = 512   # MB

  # Update by publishing a new version of the existing lambda
  publish = true

  environment {
    variables = {
      APP_ENVIRONMENT = var.environment
    }
  }

  vpc_config {
    subnet_ids         = data.aws_elasticache_subnet_group.redis_subnets.subnet_ids
    security_group_ids = ["${data.aws_security_group.redis_sg.id}"]
  }
}

resource "aws_lambda_alias" "next-GenericTrigger" {
  name             = "NEXT"
  function_name    = aws_lambda_function.GenericTrigger.arn
  function_version = aws_lambda_function.GenericTrigger.version
}

resource "aws_lambda_alias" "live-GenericTrigger" {
  name             = "LIVE"
  function_name    = aws_lambda_function.GenericTrigger.arn
  function_version = aws_lambda_function.GenericTrigger.version
}

resource "aws_lambda_alias" "prev-GenericTrigger" {
  name             = "PREV"
  function_name    = aws_lambda_function.GenericTrigger.arn
  function_version = aws_lambda_function.GenericTrigger.version
}

resource "aws_lambda_alias" "latest-GenericTrigger" {
  name             = "LATEST"
  function_name    = aws_lambda_function.GenericTrigger.arn
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_bucket_for_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.GenericTrigger.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.generic_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "service-generic-bucket-${var.account}-${var.region}"

  lambda_function {
    lambda_function_arn = aws_lambda_function.GenericTrigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_bucket_for_s3]
}
