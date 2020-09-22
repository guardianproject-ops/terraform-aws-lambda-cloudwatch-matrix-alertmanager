variable "matrix_alertmanager_url" {
  type        = string
  description = "Full URL to the alertmanager matrix endpoint (including query param with shared secret)"
}
variable "matrix_alertmanager_receiver" {
  type        = string
  description = "The alertmanager receiver to receive the alert"
}
variable "build_number" {
  type        = string
  description = "Any time this value changes, the lambda will be rebuilt from source. The value it self has no meaning."
  default     = "1"
}
variable "sns_topic_arns" {
  type        = list(string)
  description = "List of sns_topics that will be sending alarms to this lambda"
}
