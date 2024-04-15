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

variable "kms_key_id" {
  type = string
  # Provide a default value or set it dynamically based on your requirements
}


# Create CloudWatch Log Metric Filter
variable "log_metric_filter_name" {
  type    = string
  default = "log_metric_filter"
}

variable "log_metric_filter_pattern" {
  type    = string
  default = "invalid syntax"
}

variable "metric_transformation_name" {
  type    = string
  default = "InvalidSyntaxCount"
}

variable "metric_transformation_namespace" {
  type    = string
  default = "CustomMetrics"
}

variable "metric_transformation_value" {
  type    = string
  default = "1"
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

# Create Lambda function for ITSM ticket creation
variable "lambda_function_filename" {
  type = string
}

variable "lambda_function_name" {
  type = string
  default = "itsm_ticket_creator"
}

# Create CloudWatch Log Group
variable "log_group_name" {
  type    = string
  default = "your_log_group_name"
}

variable "log_group_retention" {
  type    = number
  default = 30
}


variable "lambda_function_handler" {
  type = string
}

variable "lambda_function_runtime" {
  type = string
}
