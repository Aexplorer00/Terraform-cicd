# ==============================================================================
# 📥 VARIABLE DEFINITIONS - SRE TERRAFORM CI/CD PROJECT
# ==============================================================================

variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS Region for deployment"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR Block for VPC"
}
