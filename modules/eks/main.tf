resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = length(var.cluster_endpoint_public_access_cidrs) > 0 ? var.cluster_endpoint_public_access_cidrs : null
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = var.tags
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  version         = var.kubernetes_version
  instance_types  = [var.node_instance_type]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    min_size     = var.node_min_size
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = var.tags
}

locals {
  standard_addons = toset([
    "coredns",
    "eks-pod-identity-agent",
    "kube-proxy",
    "vpc-cni",
  ])
}

resource "aws_eks_addon" "standard" {
  for_each = local.standard_addons

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = var.ebs_csi_role_arn

  depends_on = [aws_eks_addon.standard["eks-pod-identity-agent"]]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_pod_identity_association.ebs_csi]
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = var.external_secrets_namespace
  service_account = var.external_secrets_service_account
  role_arn        = var.external_secrets_role_arn

  depends_on = [aws_eks_addon.standard["eks-pod-identity-agent"]]
}

# ------------------------------------------------------------------------------
# Client EC2 Access Entry & API Security Rule
# ------------------------------------------------------------------------------

resource "aws_eks_access_entry" "client_ec2" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.client_ec2_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "client_ec2" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.client_ec2_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.client_ec2]
}

resource "aws_security_group_rule" "cluster_ingress_client_ec2" {
  description              = "Allow administrative client EC2 to communicate with EKS control plane on port 443"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = var.client_ec2_security_group_id
}

# ------------------------------------------------------------------------------
# AWS Load Balancer Controller Pod Identity Association
# ------------------------------------------------------------------------------

resource "aws_eks_pod_identity_association" "aws_load_balancer_controller" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = var.aws_load_balancer_controller_namespace
  service_account = var.aws_load_balancer_controller_service_account
  role_arn        = var.aws_load_balancer_controller_role_arn

  depends_on = [aws_eks_addon.standard["eks-pod-identity-agent"]]
}
