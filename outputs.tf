output "lambda" {
  description = "the lambda resource output"
  value       = module.lambda

  depends_on = [
    # the policy must be attached before the lambda is usable
    aws_iam_role_policy_attachment.lambda,
  ]
}

output "lambda_arn" {
  description = "the lambda resource's arn "
  value       = module.lambda.function_arn
}

output "lambda_qualified_arn" {
  description = "the lambda resource's qualified arn"
  value       = module.lambda.function_qualified_arn
}
