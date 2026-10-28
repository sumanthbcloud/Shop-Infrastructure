# Shop-Infrastructure — AWS EKS & Cloud Infrastructure

This repository contains the Terraform Infrastructure as Code (IaC) that provisions and manages the cloud foundation for **SUM Store** on AWS.

The design enforces strict boundaries between cloud foundation, temporary administrative access, initial controller bootstrap, and autonomous GitOps delivery.

---

## Architecture & Operational Boundaries

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. TERRAFORM (Shop-Infrastructure)                                          │
│    Persistent AWS Foundation                                                │
│    • Multi-AZ VPC (public subnets, private subnets, IGW, NAT Gateway)       │
│    • Amazon EKS Cluster (private API endpoint, managed node group)          │
│    • AWS Secrets Manager secret containers (sumstore/mysql, sumstore/rabbitmq)│
│    • IAM Roles & Pod Identity associations (EBS CSI, ESO, AWS LBC)           │
│    • Client EC2 IAM instance profile, security group, and EKS Access Entry  │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. MANUAL CLIENT EC2 (Temporary Administrative Workstation)                 │
│    • Launched manually into one of the VPC public subnets (public IPv4)     │
│    • Attaches Terraform-managed IAM instance profile and security group     │
│    • Access via AWS Systems Manager Session Manager (SSM)                   │
│    • Communicates with private EKS API endpoint via VPC internal routing    │
│    • Terminated immediately after Day-0 bootstrap is completed              │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. HELM / CLIENT OPERATIONS (Initial Day-0 Controller Bootstrap)            │
│    • External Secrets Operator (installed with Pod Identity)                │
│    • AWS Load Balancer Controller (installed with Pod Identity)             │
│    • Argo CD (installed via official manifests)                            │
│    • Out-of-band secret population (bootstrap-secrets.sh)                   │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. ARGO CD (Sumstore-GitOps — Autonomous Continuous Delivery)               │
│    • Platform Security: ClusterSecretStore, ECR token generator, Secrets    │
│    • Platform Storage: gp3 StorageClass & stateful datastores               │
│    • Platform Networking: AWS ALB Ingress & routing transforms              │
│    • Workloads: ApplicationSet pulling microservice:1.0.0 from private ECR  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
├── environments/
│   └── prod/                         # Environment root module
│       ├── backend.tf                # S3 remote state with native lockfile
│       ├── main.tf                   # Clean orchestration of reusable modules
│       ├── outputs.tf                # Operational outputs for client and bootstrap
│       ├── providers.tf              # AWS provider configuration & common tags
│       ├── terraform.tfvars          # Primary human-readable environment contract
│       ├── variables.tf              # Input variables with relationship validations
│       └── versions.tf               # Terraform and provider version constraints
├── modules/
│   ├── vpc/                          # Reusable multi-AZ VPC, subnets, NAT, and client SG
│   ├── eks/                          # EKS cluster, managed node group, addons, and Pod Identity
│   ├── iam/                          # Explicit least-privilege IAM roles and instance profiles
│   └── secrets/                      # AWS Secrets Manager secret containers
└── scripts/
    ├── create-eks-client.sh          # Helper to launch client EC2 using Terraform outputs
    ├── bootstrap-eks-client.sh       # Hands-on verification of client tools and cluster connectivity
    └── delete-eks-client.sh          # Helper to safely terminate the temporary client EC2
```

---

## Module Design & Reusability Principles

1. **Environment Agnostic**: Modules in `modules/` do not contain hardcoded environment names or fixed assumptions. All environment-specific inputs flow from `environments/<env>/terraform.tfvars`.
2. **Flexible Networking**: The `vpc` module supports any number of Availability Zones (minimum 2 for EKS HA) and validates that public and private subnet CIDR lists match the AZ count.
3. **Explicit IAM Contracts**: Every IAM role defines exactly who assumes it (EKS control plane, EC2 nodes, or Pod Identity), what permissions it receives, and why it exists.
4. **AWS Load Balancer Controller Boundary**: Terraform provisions only the AWS prerequisites (IAM role, official policy, EKS Pod Identity association, and subnet ELB discovery tags). The controller itself is installed later from the client EC2 via Helm.
5. **Client EC2 Boundary**: Terraform never creates the EC2 instance. It only manages the persistent security group, IAM instance profile, and EKS access entry. The instance is launched manually in a public subnet with a public IP for administrative operations and terminated afterward.

---

## Configuration Contract (`environments/prod/terraform.tfvars`)

```hcl
aws_region           = "us-east-1"
project_name         = "sum-store"
environment          = "prod"
cluster_name         = "sum-shop"
kubernetes_version   = "1.30"

# Networking
vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

# EKS API Access & Client Security
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = false
client_ssh_cidr_blocks          = []  # Empty by default (SSM only). 0.0.0.0/0 strictly prohibited.

# EKS Worker Compute
node_instance_types  = ["m7i-flex.large"]
node_disk_size       = 50
node_min_size        = 2
node_desired_size    = 2
node_max_size        = 4
```

---

## Deployment Walkthrough

### 1. Provision AWS Foundation
```bash
cd environments/prod
terraform init
terraform validate
terraform plan
terraform apply
```

### 2. Launch Administrative Client EC2
Run the helper script (or execute the equivalent `aws ec2 run-instances` CLI command):
```bash
./scripts/create-eks-client.sh
```

### 3. Connect via AWS Systems Manager
```bash
aws ssm start-session --target <instance-id> --region us-east-1
```

### 4. Hands-on Cluster Bootstrap (Inside Client EC2)
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name sum-shop

# Verify cluster nodes
kubectl get nodes -o wide

# Run the client verification script
./scripts/bootstrap-eks-client.sh
```

### 5. Terminate Client EC2 (Post-Bootstrap)
```bash
./scripts/delete-eks-client.sh
```
