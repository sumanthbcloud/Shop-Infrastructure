output "vpc_id" {
  description = "ID of the production VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the production public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the production private subnets."
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = module.iam.cluster_role_arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS managed node group IAM role."
  value       = module.iam.node_role_arn
}

output "ebs_csi_role_arn" {
  description = "ARN of the EBS CSI Pod Identity IAM role."
  value       = module.iam.ebs_csi_role_arn
}

output "eks_cluster_name" {
  description = "Name of the production EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the production EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS-managed cluster security group."
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group."
  value       = module.eks.node_group_name
}

output "ebs_csi_addon_name" {
  description = "Name of the EBS CSI managed add-on."
  value       = module.eks.ebs_csi_addon_name
}
