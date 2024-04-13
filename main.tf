# resource "aws_kms_key" "my_kms_key" {
#   description             = "My KMS Key"
#   deletion_window_in_days = 7  # Adjust as needed
#   policy                  = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "kms:*",
#         Resource  = "*",
#       },
#     ]
#   })
# }
resource "aws_kms_key" "my_kms_key" {
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  policy                  = var.kms_key_policy
}



# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "your_log_group_name"
  retention_in_days = 30  # Adjust retention period as needed
  kms_key_id = aws_kms_key.my_kms_key.arn
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
  alarm_name          = var.cloudwatch_alarm_name
  comparison_operator = var.cloudwatch_comparison_operator
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = var.cloudwatch_metric_name
  namespace           = var.cloudwatch_namespace
  period              = var.cloudwatch_period
  statistic           = var.cloudwatch_statistic
  threshold           = var.cloudwatch_threshold
  alarm_description   = var.cloudwatch_alarm_description
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
  endpoint  = var.email_subscription_endpoint
}

# Create Lambda function for ITSM ticket creation
resource "aws_lambda_function" "itsm_ticket_creator" {
  filename      =  "main.zip"
  function_name = "itsm_ticket_creator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.itsm_tickets_table.name
    }
  }
}

# Create DynamoDB table for ITSM tickets
resource "aws_dynamodb_table" "itsm_tickets_table" {
  name           = "itsm_tickets_table"
  billing_mode   = "PAY_PER_REQUEST"  # Adjust as needed
  hash_key       = "ticket_id"
  attribute {
    name = "ticket_id"
    type = "S"
  }
}

# Create IAM role for Lambda function
# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
resource "aws_iam_role" "lambda_role" {
  name               = var.lambda_role_name
  assume_role_policy = var.assume_role_policy_document
}


# Attach policy to IAM role for Lambda function
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

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