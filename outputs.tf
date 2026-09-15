# ==============================================================================
# 📤 OUTPUT DEFINITIONS - SRE TERRAFORM CI/CD PROJECT
# ==============================================================================

output "vpc_id" {
  value       = aws_vpc.cicd_vpc.id
  description = "VPC ID"
}

output "kms_key_arn" {
  value       = aws_kms_key.cicd_kms.arn
  description = "KMS Customer Managed Key ARN"
}

output "secrets_manager_arn" {
  value       = aws_secretsmanager_secret.db_credentials_secret.arn
  description = "Secrets Manager Secret ARN"
}

output "sqs_queue_url" {
  value       = aws_sqs_queue.primary_queue.id
  description = "Primary SQS Queue URL"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.events_topic.arn
  description = "SNS Events Topic ARN"
}
