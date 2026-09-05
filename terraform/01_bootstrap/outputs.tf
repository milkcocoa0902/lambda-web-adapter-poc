output "ecr_repository_url" {
  description = "URL of the ECR repository used for the Lambda container image."
  value       = aws_ecr_repository.ecr_lwa.repository_url
}

output "aws_region" {
  description = "AWS Region containing the ECR repository."
  value       = data.aws_region.current.region
}
