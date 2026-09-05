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
