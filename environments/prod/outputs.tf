# ------------------------------------------------------------------------------
# Operational Outputs
# ------------------------------------------------------------------------------

output "region" {
  description = "AWS region."
  value       = var.aws_region
}

output "project_name" {
  description = "Project name identifier."
  value       = var.project_name
}

output "environment" {
  description = "Environment name."
  value       = var.environment
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (where EKS worker nodes run)."
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster API."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_name" {
  description = "Name of the managed node group."
  value       = module.eks.node_group_name
}

# ------------------------------------------------------------------------------
# IAM Roles & Secrets Prerequisites
# ------------------------------------------------------------------------------

output "eks_cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane."
  value       = module.iam.cluster_role_arn
}

output "eks_node_role_arn" {
  description = "IAM role ARN for the EKS worker nodes."
  value       = module.iam.node_role_arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI Driver Pod Identity."
  value       = module.iam.ebs_csi_role_arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN for External Secrets Operator Pod Identity."
  value       = module.iam.external_secrets_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller Pod Identity."
  value       = module.iam.aws_load_balancer_controller_role_arn
}

output "mysql_secret_arn" {
  description = "Secrets Manager ARN for MySQL credentials container."
  value       = module.secrets.mysql_secret_arn
}

output "rabbitmq_secret_arn" {
  description = "Secrets Manager ARN for RabbitMQ credentials container."
  value       = module.secrets.rabbitmq_secret_arn
}

output "mongodb_secret_arn" {
  description = "Secrets Manager ARN for MongoDB credentials container."
  value       = module.secrets.mongodb_secret_arn
}

output "redis_secret_arn" {
  description = "Secrets Manager ARN for Redis credentials container."
  value       = module.secrets.redis_secret_arn
}
