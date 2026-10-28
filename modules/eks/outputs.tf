output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "ID of the EKS-managed cluster security group."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL exposed by the EKS cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_group_name" {
  description = "Name of the managed node group."
  value       = aws_eks_node_group.this.node_group_name
}

output "external_secrets_pod_identity_association_id" {
  description = "ID of the External Secrets Operator Pod Identity association."
  value       = aws_eks_pod_identity_association.external_secrets.id
}

output "aws_load_balancer_controller_pod_identity_association_id" {
  description = "ID of the AWS Load Balancer Controller Pod Identity association."
  value       = aws_eks_pod_identity_association.aws_load_balancer_controller.id
}
