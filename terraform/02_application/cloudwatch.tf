resource "aws_cloudwatch_log_group" "lwa_lambda" {
  name              = "cw-${local.name_suffix}"
  retention_in_days = 7
  tags = {
    Name = "cw-${local.name_suffix}"
  }
}
