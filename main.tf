data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#########################################################################################
# Lambda resources

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1" # requires Terraform >= 0.13.0

  context    = module.this.context
  attributes = ["lambda"]
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "1.36.0"

  function_name = module.label.id
  description   = "Forwards cloudwatch alerts to matrix"
  handler       = "lambda_function.lambda_handler"
  runtime       = var.python_runtime_version
  timeout       = var.lambda_timeout_seconds
  source_path   = "${path.module}/lambda/"

  allowed_triggers = { for topic_arn in var.sns_topic_arns :
    "AllowExecutionFromSNS_${topic_arn}" =>
    {
      principal  = "sns.amazonaws.com"
      source_arn = topic_arn
    }
  }
  publish                                 = false
  create_current_version_allowed_triggers = false

  attach_policies = true
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
  ]
  number_of_policies                = 2
  cloudwatch_logs_retention_in_days = 14
  cloudwatch_logs_tags              = module.label.tags
  attach_network_policy             = var.attach_network_policy
  vpc_subnet_ids                    = var.vpc_subnet_ids
  vpc_security_group_ids            = local.vpc_enabled ? [aws_security_group.lambda[0].id] : null
  environment_variables = {
    MATRIX_ALERTMANAGER_URL      = var.matrix_alertmanager_url
    MATRIX_ALERTMANAGER_RECEIVER = var.matrix_alertmanager_receiver
    LOG_LEVEL                    = var.lambda_log_level
  }
  tags = module.label.tags
}

####

#resource "aws_lambda_permission" "sns" {
#  count         = length(var.sns_topic_arns)
#  action        = "lambda:InvokeFunction"
#  function_name = module.lambda.function_name
#  principal     = "sns.amazonaws.com"
#  statement_id  = "${module.this.id}-AllowExecutionFromSNS-${count.index}"
#  source_arn    = element(var.sns_topic_arns, count.index)
#}
#
#resource "aws_lambda_alias" "default" {
#  name             = "default"
#  description      = "Use latest version as default"
#  function_name    = module.lambda.function_name
#  function_version = "$LATEST"
#}
