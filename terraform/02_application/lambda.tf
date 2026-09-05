resource "aws_lambda_function" "lwa_lambda" {
  function_name = "lambda-${local.name_suffix}"
  role          = aws_iam_role.lwa_lambda_role.arn
  package_type  = "Image"
  image_uri     = var.lwa_image


  memory_size = 512
  timeout     = 30

  architectures = ["x86_64"]
  tags = {
    Name = "lambda-${local.name_suffix}"
  }

  logging_config {
    log_group  = aws_cloudwatch_log_group.lwa_lambda.name
    log_format = "Text"
  }

  environment {
    variables = {
      "AWS_LWA_INVOKE_MODE"                    = "response_stream"
      "AWS_LWA_PORT"                           = var.lwa_port
      "AWS_LWA_READINESS_CHECK_HEALTHY_STATUS" = "200-299"
      "AWS_LWA_READINESS_CHECK_PATH"           = var.lwa_health_check_path
      "QUOTES_TABLE_NAME"                      = aws_dynamodb_table.quotes_table.name
    }
  }
}

resource "aws_lambda_function_url" "lwa_lambda_fn_url" {
  function_name      = aws_lambda_function.lwa_lambda.function_name
  authorization_type = "AWS_IAM"
  invoke_mode        = "RESPONSE_STREAM"
}

resource "aws_lambda_permission" "allow_cloudfront_function_url" {
  statement_id  = "AllowCloudFrontInvokeFunctionUrl"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.lwa_lambda.function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = aws_cloudfront_distribution.lwa_cloudfront.arn

  function_url_auth_type = "AWS_IAM"
}

resource "aws_lambda_permission" "allow_cloudfront_function" {
  statement_id  = "AllowCloudFrontInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lwa_lambda.function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = aws_cloudfront_distribution.lwa_cloudfront.arn

  invoked_via_function_url = true
}
