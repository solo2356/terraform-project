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
