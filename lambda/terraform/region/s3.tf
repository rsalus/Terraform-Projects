########################################################################
#       S3
########################################################################

resource "aws_s3_bucket" "generic_bucket" {
  bucket        = "service-generic-bucket-${var.account}-${var.region}"
  force_destroy = true
  tags          = var.default_tags
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.generic_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::270411072756:root",
        "arn:aws:iam::421303189384:root"
      ]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.generic_bucket.arn,
      "${aws_s3_bucket.generic_bucket.arn}/*"
    ]
  }
}
