# ==============================================================================
# Environment Configuration: Production
# ==============================================================================

aws_region         = "us-east-1"
project_name       = "sum-store"
environment        = "prod"
cluster_name       = "sum-shop"
kubernetes_version = "1.30"

# Networking
vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

# EKS API Access & Client Security
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = false
client_ssh_cidr_blocks          = []

# EKS Worker Compute
node_instance_types = ["m7i-flex.large"]
node_disk_size      = 50
node_min_size       = 2
node_desired_size   = 2
node_max_size       = 4
