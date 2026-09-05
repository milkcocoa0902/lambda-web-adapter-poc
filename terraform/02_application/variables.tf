variable "service_name" {
  description = "Service identifier used in AWS resource names and default tags."
  type        = string
  default     = "lwa"
}

variable "environment" {
  description = "Deployment environment identifier used in AWS resource names and default tags."
  type        = string
  default     = "dev"
}

variable "application_name" {
  description = "Application identifier used in AWS resource names and default tags."
  type        = string
  default     = "quotes-api"
}

variable "lwa_port" {
  description = "TCP port on which the web application listens inside the Lambda container."
  type        = number
  default     = 8080
}

variable "lwa_health_check_path" {
  description = "HTTP path that Lambda Web Adapter polls to determine application readiness."
  type        = string
  default     = "/"
}

variable "lwa_image" {
  description = "Complete ECR image URI, including an immutable tag or digest, deployed to the Lambda function."
  type        = string
}
