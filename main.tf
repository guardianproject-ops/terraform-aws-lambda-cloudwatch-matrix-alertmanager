data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#########################################################################################
# Cloudwatch resources
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${module.this.id}"
  retention_in_days = 14
}

#########################################################################################
# IAM resources
data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.main.arn
    ]
  }
}

resource "aws_iam_policy" "lambda" {
  name        = module.label.id
  description = "Allow lambda to create/put logstreams"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.lambda.arn
}

#########################################################################################
# Lambda resources

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1" # requires Terraform >= 0.13.0

  context    = module.this.context
  attributes = ["lambda"]
}

module "lambda" {
  source = "git::https://github.com/claranet/terraform-aws-lambda.git?ref=tags/v1.2.0"

  function_name = module.label.id
  description   = "Forwards cloudwatch alerts to matrix"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 300

  tags = module.label.tags

  // Specify a file or directory for the source code.
  source_path = "${path.module}/lambda/"

  // Add environment variables.
  environment = {
    variables = {
      MATRIX_ALERTMANAGER_URL      = var.matrix_alertmanager_url
      MATRIX_ALERTMANAGER_RECEIVER = var.matrix_alertmanager_receiver
    }
  }
}

resource "aws_lambda_permission" "sns" {
  count         = length(var.sns_topic_arns)
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "sns.amazonaws.com"
  statement_id  = "${module.this.id}-AllowExecutionFromSNS-${count.index}"
  source_arn    = element(var.sns_topic_arns, count.index)
}

resource "aws_lambda_alias" "default" {
  name             = "default"
  description      = "Use latest version as default"
  function_name    = module.lambda.function_name
  function_version = "$LATEST"
}
