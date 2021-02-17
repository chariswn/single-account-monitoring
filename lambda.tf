resource "aws_iam_role" "role_lambda" {
  name = "role_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "lambda-logging-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSLambdaCloudWatch" {
  role = aws_iam_role.role_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.role_lambda.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

resource "aws_lambda_function" "track_users" {
  filename = "/Users/chariswn/Sandbox/poc/change-monitoring/single-account/lambda/helloWorld.zip"
  function_name = "helloWorld"
  role = aws_iam_role.role_lambda.arn
  handler = "helloWorld.handler"
  runtime = "nodejs14.x"

  vpc_config {
    security_group_ids = [
      aws_security_group.security_group_lambda.id]
    subnet_ids = [
      aws_subnet.subnet_1.id]
  }
  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  depends_on = [
    aws_lambda_function.track_users
  ]
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.track_users.function_name
  principal = "logs.ap-southeast-1.amazonaws.com"
  source_arn = "${aws_cloudwatch_log_group.log_group.arn}:*"
}

resource "aws_security_group" "security_group_lambda" {
  name = "security_group_lambda"
  description = "Lambda traffic"
  vpc_id = aws_vpc.vpc_intranet.id

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}