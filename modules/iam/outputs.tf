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

output "client_ec2_role_arn" {
  description = "ARN of the administrative client EC2 IAM role."
  value       = aws_iam_role.client_ec2.arn
}

output "client_ec2_instance_profile_name" {
  description = "Name of the administrative client EC2 IAM instance profile."
  value       = aws_iam_instance_profile.client_ec2.name
}

output "client_ec2_instance_profile_arn" {
  description = "ARN of the administrative client EC2 IAM instance profile."
  value       = aws_iam_instance_profile.client_ec2.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller Pod Identity IAM role."
  value       = aws_iam_role.aws_load_balancer_controller.arn
  depends_on  = [aws_iam_role_policy_attachment.aws_load_balancer_controller]
}
