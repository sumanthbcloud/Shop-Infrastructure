data "aws_partition" "current" {}

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
  tags               = var.tags
}

locals {
  eks_node_policy_arns = toset([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
  ])
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  for_each = local.eks_node_policy_arns

  role       = aws_iam_role.eks_node.name
  policy_arn = each.value
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "${var.cluster_name}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "AllowReadSumstoreSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = var.external_secrets_target_arns
  }

  statement {
    sid       = "AllowECRAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${var.cluster_name}-external-secrets-policy"
  description = "Least-privilege policy for External Secrets Operator to access SUM Store Secrets Manager secrets."
  policy      = data.aws_iam_policy_document.external_secrets.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# ------------------------------------------------------------------------------
# Administrative Client EC2 Workstation IAM
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "client_ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "client_ec2" {
  name               = "${var.cluster_name}-client-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.client_ec2_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "client_ec2_ssm" {
  role       = aws_iam_role.client_ec2.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "client_ec2_permissions" {
  statement {
    sid    = "AllowEKSClusterDiscovery"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowSecretsManagerBootstrap"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:PutSecretValue",
    ]
    resources = length(var.external_secrets_target_arns) > 0 ? var.external_secrets_target_arns : ["*"]
  }

  statement {
    sid    = "AllowECRAuthentication"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "client_ec2" {
  name        = "${var.cluster_name}-client-ec2-policy"
  description = "Permissions for administrative client EC2 to discover EKS, bootstrap secrets, and access ECR."
  policy      = data.aws_iam_policy_document.client_ec2_permissions.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "client_ec2_permissions" {
  role       = aws_iam_role.client_ec2.name
  policy_arn = aws_iam_policy.client_ec2.arn
}

resource "aws_iam_instance_profile" "client_ec2" {
  name = "${var.cluster_name}-client-ec2-profile"
  role = aws_iam_role.client_ec2.name
  tags = var.tags
}

# ------------------------------------------------------------------------------
# AWS Load Balancer Controller IAM (Pod Identity)
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "${var.cluster_name}-aws-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json
  tags               = var.tags
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.cluster_name}-aws-load-balancer-controller-policy"
  description = "Official permissions for AWS Load Balancer Controller to manage ALBs, target groups, and network resources."
  policy      = file("${path.module}/policies/aws_load_balancer_controller.json")
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}
