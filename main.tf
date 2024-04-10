# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "your_log_group_name"
  retention_in_days = 30  # Adjust retention period as needed
}

# Create CloudWatch Log Metric Filter
resource "aws_cloudwatch_log_metric_filter" "log_metric_filter" {
  name           = "log_metric_filter"
  pattern        = "invalid syntax"
  log_group_name = aws_cloudwatch_log_group.log_group.name

  metric_transformation {
    name      = "InvalidSyntaxCount"
    namespace = "CustomMetrics"
    value     = "1"
  }
}

# Create CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "log_metric_alarm" {
  alarm_name          = "log_metric_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "InvalidSyntaxCount"
  namespace           = "CustomMetrics"
  period              = "3600"  # 1 hour
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "Alarm for invalid syntax occurrences"
  
  alarm_actions       = [aws_sns_topic.itsm_notification_topic.arn]
}

# Create SNS Topic
resource "aws_sns_topic" "itsm_notification_topic" {
  name = "itsm_notification_topic"
}

# Create SNS Topic Subscription for Email
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.itsm_notification_topic.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}

# Create Lambda function for ITSM ticket creation
resource "aws_lambda_function" "itsm_ticket_creator" {
  filename      = var.lambda_function_filename
  function_name = "itsm_ticket_creator"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_function_handler
  runtime       = var.lambda_function_runtime
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.itsm_tickets_table.name
    }
  }
}

# Create DynamoDB table for ITSM tickets
resource "aws_dynamodb_table" "itsm_tickets_table" {
  name           = "itsm_tickets_table"
  billing_mode   = var.dynamodb_billing_mode  # Adjust as needed
  hash_key       = "ticket_id"
  attribute {
    name = "ticket_id"
    type = "S"
  }
}

# Create IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to IAM role for Lambda function
resource "aws_iam_role_policy_attachment" "sns_full_access_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_role.name
}

# Configure SNS topic subscription to Lambda function
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.itsm_notification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.itsm_ticket_creator.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.itsm_ticket_creator.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.itsm_notification_topic.arn
}
