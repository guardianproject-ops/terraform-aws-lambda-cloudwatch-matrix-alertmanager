data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "null_resource" "lambda" {
  triggers = {
    build_number = var.build_number
  }
  provisioner "local-exec" {
    command = "cd ${path.module} && make artifact"
  }
}

module "label_log" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.2"
  delimiter = "/"
  context   = module.this.context
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${module.label_log.id}"
  retention_in_days = 14
}

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

resource "aws_iam_role" "lambda" {
  name               = module.this.id
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = module.this.tags
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
  name        = module.this.id
  description = "Allow lambda to create/put logstreams"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_lambda_function" "default" {
  function_name    = module.this.id
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = 300
  tags             = module.this.tags

  environment {
    variables = {
      MATRIX_ALERTMANAGER_URL      = var.matrix_alertmanager_url
      MATRIX_ALERTMANAGER_RECEIVER = var.matrix_alertmanager_receiver
    }
  }
}

resource "aws_lambda_permission" "sns" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "sns.amazonaws.com"
  statement_id  = "${module.context.id}-AllowExecutionFromSNS"
  source_arn    = var.sns_topic_arn
}

resource "aws_lambda_alias" "default" {
  name             = "default"
  description      = "Use latest version as default"
  function_name    = aws_lambda_function.default.function_name
  function_version = "$LATEST"
}
