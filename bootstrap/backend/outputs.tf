output "backend_bucket_name" {
  description = "Name of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.id
}

output "backend_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_bucket_region" {
  description = "AWS region containing the Terraform state bucket."
  value       = var.aws_region
}
