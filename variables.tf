variable "kms_key_description" {
  description = "Description for the KMS Key"
  type        = string
  default     = "My KMS Key"
}

variable "kms_key_deletion_window_in_days" {
  description = "Deletion window in days for the KMS Key"
  type        = number
  default     = 7
}

variable "kms_key_policy" {
  description = "Policy for the KMS Key"
  type        = string
  default     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

# Create CloudWatch Alarm

variable "cloudwatch_alarm_name" {
  description = "Name for the CloudWatch alarm"
  type        = string
  default     = "log_metric_alarm"
}

variable "cloudwatch_comparison_operator" {
  description = "Comparison operator for the CloudWatch alarm"
  type        = string
  default     = "GreaterThanOrEqualToThreshold"
}

variable "cloudwatch_evaluation_periods" {
  description = "Number of evaluation periods for the CloudWatch alarm"
  type        = number
  default     = 3
}

variable "cloudwatch_metric_name" {
  description = "Name of the metric for the CloudWatch alarm"
  type        = string
  default     = "InvalidSyntaxCount"
}

variable "cloudwatch_namespace" {
  description = "Namespace for the CloudWatch alarm"
  type        = string
  default     = "CustomMetrics"
}

variable "cloudwatch_period" {
  description = "Period for the CloudWatch alarm"
  type        = number
  default     = 3600
}

variable "cloudwatch_statistic" {
  description = "Statistic for the CloudWatch alarm"
  type        = string
  default     = "Sum"
}

variable "cloudwatch_threshold" {
  description = "Threshold for the CloudWatch alarm"
  type        = number
  default     = 3
}

variable "cloudwatch_alarm_description" {
  description = "Description for the CloudWatch alarm"
  type        = string
  default     = "Alarm for invalid syntax occurrences"
}

variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "ap-south-1"
}

variable "email_endpoint" {
  description = "The email address to which SNS notifications will be sent."
  type        = string
}

variable "lambda_function_filename" {
  description = "The filename of the Lambda function code."
  type        = string
}

variable "lambda_function_handler" {
  description = "The handler function of the Lambda function."
  type        = string
}

variable "lambda_function_runtime" {
  description = "The runtime environment for the Lambda function."
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "The billing mode for the DynamoDB table."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "email_subscription_endpoint" {
  description = "endpoint"
}

# Create IAM role for Lambda function
variable "lambda_role_name" {
  type    = string
  default = "lambda_role"
}

variable "assume_role_policy_document" {
  type    = string
  default = <<EOF
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
