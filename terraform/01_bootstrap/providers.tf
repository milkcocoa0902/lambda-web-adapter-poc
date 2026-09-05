provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Env         = var.environment
      Service     = var.service_name
      Application = var.application_name
      ManagedBy   = "Terraform"
    }
  }
}
