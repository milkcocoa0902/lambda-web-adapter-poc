resource "aws_iam_role" "lwa_lambda_role" {
  name = "iam-${local.name_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "iam-role-${local.name_suffix}"
  }
}

resource "aws_iam_role_policy_attachment" "lwa_lambda_basic_execution" {
  role       = aws_iam_role.lwa_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lwa_dynamo_policy" {
  name = "iam-role-${local.name_suffix}"
  role = aws_iam_role.lwa_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Action" : "dynamodb:GetItem",
      "Resource" : aws_dynamodb_table.quotes_table.arn,
      "Effect" : "Allow"
    }]
  })
}
