



#start

resource "aws_kms_key" "my_kms_key" {
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  policy                  = var.kms_key_policy
}



# Create CloudWatch Log Group

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.log_group_retention
  kms_key_id = var.kms_key_id
}


# Create CloudWatch Log Metric Filter
resource "aws_cloudwatch_log_metric_filter" "log_metric_filter" {
  name           = var.log_metric_filter_name
  pattern        = var.log_metric_filter_pattern
  log_group_name = aws_cloudwatch_log_group.log_group.name


  metric_transformation {
    name      = var.metric_transformation_name
    namespace = var.metric_transformation_namespace
    value     = var.metric_transformation_value
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



resource "aws_sns_topic" "itsm_notification_topic" {
  name   = "itsm_notification_topic"
  # policy = jsonencode(var.sns_topic_policy)
  kms_master_key_id = var.kms_key_id
}



# Create SNS Topic Subscription for Email
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.itsm_notification_topic.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}

# Create Lambda function for ITSM ticket creation
resource "aws_lambda_function" "itsm_ticket_creator" {
   filename      = var.lambda_function_filename
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_function_handler
  runtime       = var.lambda_function_runtime
  kms_key_arn   = var.kms_key_id
  
}


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