output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = aws_iam_role.eks_cluster.arn
  depends_on  = [aws_iam_role_policy_attachment.eks_cluster]
}

output "node_role_arn" {
  description = "ARN of the EKS managed node group IAM role."
  value       = aws_iam_role.eks_node.arn
  depends_on  = [aws_iam_role_policy_attachment.eks_node]
}

output "ebs_csi_role_arn" {
  description = "ARN of the EBS CSI Pod Identity IAM role."
  value       = aws_iam_role.ebs_csi.arn
  depends_on  = [aws_iam_role_policy_attachment.ebs_csi]
}
