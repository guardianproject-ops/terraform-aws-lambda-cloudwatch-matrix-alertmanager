output "lambda" {
  description = "the lambda resource output"
  value       = aws_lambda_function.default
}

output "lambda_arn" {
  description = "the lambda resource's arn "
  value       = aws_lambda_function.default.arn
}

output "lambda_qualified_arn" {
  description = "the lambda resource's qualified arn"
  value       = aws_lambda_function.default.qualified_arn
}
