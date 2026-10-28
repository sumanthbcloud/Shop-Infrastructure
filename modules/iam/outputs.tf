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

output "external_secrets_role_arn" {
  description = "ARN of the External Secrets Operator Pod Identity IAM role."
  value       = aws_iam_role.external_secrets.arn
  depends_on  = [aws_iam_role_policy_attachment.external_secrets]
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller Pod Identity IAM role."
  value       = aws_iam_role.aws_load_balancer_controller.arn
  depends_on  = [aws_iam_role_policy_attachment.aws_load_balancer_controller]
}
