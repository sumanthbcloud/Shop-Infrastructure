# ==============================================================================
# Environment Configuration: Production
# ==============================================================================

aws_region   = "us-east-1"
project_name = "sum-store"
environment  = "prod"
cluster_name = "sum-shop"

# EKS Version Selection:
# NOTE: The value below is a temporary validation placeholder.
# An approved, current AWS-supported EKS version must be explicitly selected and pinned
# immediately prior to live terraform plan/apply.
kubernetes_version = "1.30"

# Networking
vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

# EKS Control Plane Endpoint Access
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = false

# EKS Worker Compute
node_instance_types = ["m7i-flex.large"]
node_disk_size      = 50
node_min_size       = 2
node_desired_size   = 2
node_max_size       = 4
