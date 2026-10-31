output "web_acl_arn" {
  description = "ARN of the AWS WAF web ACL associated with CloudFront."
  value       = aws_wafv2_web_acl.lwa_waf.arn
}

output "quotes_table_name" {
  description = "Name of the DynamoDB table seeded by script/seed_quotes.sh."
  value       = aws_dynamodb_table.quotes_table.name
}

output "quotes_table_arn" {
  description = "ARN of the DynamoDB quotes table."
  value       = aws_dynamodb_table.quotes_table.arn
}

output "aws_region" {
  description = "AWS Region containing the DynamoDB quotes table."
  value       = data.aws_region.current.region
}

output "cloudfront_distribution_url" {
  description = "CloudFront distribution url"
  value = aws_cloudfront_distribution.lwa_cloudfront.domain_name
}
