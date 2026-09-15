# ==============================================================================
# 🚀 LIGHTWEIGHT ENTERPRISE SRE TERRAFORM CI/CD STACK
# Fast, 100% Reliable for Local Floci Testing & GitHub Actions CI/CD
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# 1. VPC & Multi-AZ Subnets
resource "aws_vpc" "cicd_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "sre-cicd-vpc-${random_string.suffix.result}"
    Environment = var.environment
    ManagedBy   = "Terraform-CICD"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.cicd_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = { Name = "sre-public-subnet-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.cicd_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = { Name = "sre-public-subnet-b" }
}

# 2. KMS Key & Secrets Manager Vault
resource "aws_kms_key" "cicd_kms" {
  description             = "KMS CMK for Enterprise SRE Encryption at Rest"
  deletion_window_in_days = 7
  enable_key_rotation     = false

  tags = { Name = "sre-kms-${random_string.suffix.result}" }
}

resource "aws_secretsmanager_secret" "db_credentials_secret" {
  name                    = "sre-db-credentials-${random_string.suffix.result}"
  kms_key_id              = aws_kms_key.cicd_kms.arn
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials_secret.id
  secret_string = jsonencode({
    username = "sre_admin"
    password = "SuperSecurePassword123!"
    engine   = "postgres"
    port     = 5432
  })
}

# 3. Async SQS Queue & DLQ
resource "aws_sqs_queue" "sqs_dlq" {
  name              = "sre-dlq-${random_string.suffix.result}"
  kms_master_key_id = aws_kms_key.cicd_kms.arn
}

resource "aws_sqs_queue" "primary_queue" {
  name                      = "sre-primary-queue-${random_string.suffix.result}"
  receive_wait_time_seconds = 10
  kms_master_key_id         = aws_kms_key.cicd_kms.arn

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sns_topic" "events_topic" {
  name              = "sre-events-topic-${random_string.suffix.result}"
  kms_master_key_id = aws_kms_key.cicd_kms.arn
}

# 4. Observability Log Group
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/sre/app-logs-${random_string.suffix.result}"
  retention_in_days = 14
}
