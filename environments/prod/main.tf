module "vpc" {
  source = "../../modules/vpc"

  name                 = "${var.project_name}-${var.environment}"
  cluster_name         = var.cluster_name
  cidr                 = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  tags                 = local.common_tags
}

module "secrets" {
  source = "../../modules/secrets"

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  cluster_name                 = var.cluster_name
  external_secrets_target_arns = module.secrets.secret_arns
  tags                         = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name                          = var.cluster_name
  kubernetes_version                    = var.kubernetes_version
  private_subnet_ids                    = module.vpc.private_subnet_ids
  cluster_role_arn                      = module.iam.cluster_role_arn
  node_role_arn                         = module.iam.node_role_arn
  ebs_csi_role_arn                      = module.iam.ebs_csi_role_arn
  external_secrets_role_arn             = module.iam.external_secrets_role_arn
  client_ec2_role_arn                   = module.iam.client_ec2_role_arn
  client_ec2_security_group_id          = module.vpc.client_ec2_security_group_id
  aws_load_balancer_controller_role_arn = module.iam.aws_load_balancer_controller_role_arn
  cluster_endpoint_private_access       = var.cluster_endpoint_private_access
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs
  node_instance_type                    = var.node_instance_type
  node_min_size                         = var.node_min_size
  node_desired_size                     = var.node_desired_size
  node_max_size                         = var.node_max_size
  tags                                  = local.common_tags
}
