variable "matrix_alertmanager_url" {
  type        = string
  description = "Full URL to the alertmanager matrix endpoint (including query param with shared secret)"
}
variable "matrix_alertmanager_receiver" {
  type        = string
  description = "The alertmanager receiver to receive the alert"
}
variable "sns_topic_arns" {
  type        = list(string)
  description = "List of sns_topics that will be sending alarms to this lambda"
}

variable "python_runtime_version" {
  type        = string
  default     = "python3.7"
  description = "lambda function runtime. the same version must be available in the controller's system PATH."
}

variable "vpc_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}

variable "vpc_id" {
  description = "The VPC id that the lambda will be attached to"
  type        = string
  default     = null
}

variable "attach_network_policy" {
  description = "Controls whether VPC/network policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "lambda_timeout_seconds" {
  description = "The maximum time in seconds the lambda is allowed to run."
  type        = number
  default     = 300
}

variable "lambda_log_level" {
  description = "The log level of the lambda function, one of CRITICAl, ERROR, WARNING, INFO, DEBUG"
  type        = string
  default     = "INFO"
}
