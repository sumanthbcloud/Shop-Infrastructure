# Shop-Infrastructure — AWS EKS & Cloud Foundation

This repository contains the Terraform Infrastructure as Code (IaC) that provisions and manages the cloud foundation for **SUM Store** on AWS.

---

## 1. What Terraform Creates

Terraform provisions the persistent AWS infrastructure foundation:

- **Virtual Private Cloud (VPC)**:
  - Dedicated public and private subnets across multiple Availability Zones.
  - Internet Gateway for public egress and single NAT Gateway for private egress.
  - Required Kubernetes discovery tags (`kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`).
- **Amazon EKS Cluster**:
  - Managed Kubernetes control plane configured with a private API server endpoint.
  - Managed worker node group running in private subnets with configurable instance sizing and root volume disk sizes.
  - Standard AWS-managed add-ons: CoreDNS, kube-proxy, VPC CNI, and EKS Pod Identity Agent.
- **AWS IAM & Pod Identity Associations**:
  - Control plane and worker node IAM roles.
  - AWS EBS CSI Driver Pod Identity role & managed add-on.
  - External Secrets Operator (ESO) Pod Identity role with least-privilege Secrets Manager and ECR token permissions.
  - AWS Load Balancer Controller (LBC) Pod Identity role with official AWS IAM policies.
- **AWS Secrets Manager**:
  - Secret containers for authoritative datastore credentials (`sumstore/mysql`, `sumstore/rabbitmq`). No raw secret values are stored in Terraform.

---

## 2. Repository Structure

```
Shop-Infrastructure/
├── environments/
│   └── prod/                         # Environment root module
│       ├── backend.tf                # S3 remote state configuration with native lockfile
│       ├── main.tf                   # Orchestrates reusable modules (vpc, secrets, iam, eks)
│       ├── outputs.tf                # Operational outputs (VPC IDs, subnets, cluster endpoint, IAM ARNs)
│       ├── providers.tf              # AWS provider configuration & common default tags
│       ├── terraform.tfvars          # Primary human-readable environment contract
│       ├── variables.tf              # Input variable definitions and validation rules
│       └── versions.tf               # Terraform (>= 1.10) and AWS provider (~> 6.0) constraints
└── modules/
    ├── vpc/                          # Reusable multi-AZ VPC, subnets, and routing
    ├── iam/                          # Cluster, node, and Pod Identity IAM roles & policies
    ├── eks/                          # EKS cluster, managed node group, add-ons, Pod Identity
    └── secrets/                      # AWS Secrets Manager secret containers
```

---

## 3. Environment Configuration Contract (`terraform.tfvars`)

All environment-specific configuration is controlled via `environments/<env>/terraform.tfvars`. The modules in `modules/` remain completely environment-agnostic:

```hcl
aws_region   = "us-east-1"
project_name = "sum-store"
environment  = "prod"
cluster_name = "sum-shop"

# EKS Kubernetes version explicitly pinned for this environment.
kubernetes_version = "1.36"

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
```

---

## 4. Backend & State Design

Terraform state is stored in an Amazon S3 remote backend with native locking:
- **Bucket**: `sum-store`
- **Key**: `prod/terraform.tfstate`
- **Region**: `us-east-1`
- **Encryption**: Enabled
- **Locking**: Native S3 lockfile (`use_lockfile = true`)

---

## 5. Basic Terraform Workflow

```bash
cd environments/prod

# 1. Initialize provider plugins and remote S3 backend
terraform init

# 2. Validate configuration syntax and variable contracts
terraform validate

# 3. Review proposed changes against live state
terraform plan

# 4. Provision or update infrastructure
terraform apply

# 5. Tear down infrastructure (when destroying test environments)
terraform destroy
```

---

## 6. Architecture & Responsibility Boundaries

To maintain clean separation of concerns, the following components are **strictly outside** this Terraform repository:

- **Temporary Client / Admin Workstation**: Not managed by Terraform. Launched and terminated manually for operational tasks.
- **In-Cluster Controllers**: External Secrets Operator, AWS Load Balancer Controller, and Argo CD are installed out-of-band via Helm / manifests.
- **Secret Values**: Raw passwords are populated out-of-band into AWS Secrets Manager.
- **Kubernetes Workloads & GitOps**: All namespaces, deployments, services, ingress rules, and configurations are managed autonomously by Argo CD in the [Sumstore-GitOps](https://github.com/sumanthbcloud/Sumstore-GitOps) repository.
