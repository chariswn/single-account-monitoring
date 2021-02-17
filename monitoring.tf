resource "random_string" "random" {
  length = 16
  special = false
}

resource "aws_s3_bucket" "bucket" {
  bucket = lower(random_string.random.result)
  acl = "private"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${lower(random_string.random.result)}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${lower(random_string.random.result)}/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
}
EOF

  tags = {
    Environment = var.env
  }
}

resource "aws_kms_key" "kms_key" {
  description = "KMS key for Cloud Trail"
  deletion_window_in_days = 10
  tags = {
    Environment = var.env
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "log-group"

  tags = {
    Environment = var.env
  }
}

resource "aws_cloudwatch_log_subscription_filter" "subscription_filter" {
  depends_on = [
    aws_lambda_permission.lambda_permission]
  name = "subscription-filter"
  log_group_name = aws_cloudwatch_log_group.log_group.name
  filter_pattern = "userIdentity"
  destination_arn = aws_lambda_function.track_users.arn
}

resource "aws_cloudtrail" "cloud_trail" {
  depends_on = [
    aws_s3_bucket.bucket,
    aws_cloudwatch_log_group.log_group]
  name = "cloud-trail"
  s3_bucket_name = aws_s3_bucket.bucket.id
  include_global_service_events = true
  enable_log_file_validation = true
  is_multi_region_trail = true
  kms_key_id = aws_kms_key.kms_key.arn
//  cloud_watch_logs_role_arn = aws_iam_role.role_cloud_trail.arn
  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.log_group.arn
  tags = {
    Environment = var.env
  }
}
