resource "aws_dynamodb_table" "quotes_table" {
  name         = "dynamo-${local.name_suffix}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "N"
  }

  tags = {
    Name = "dynamo-${local.name_suffix}"
  }
}
