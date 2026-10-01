# Shop-Infrastructure — AWS EKS & Cloud Infrastructure

This repository contains the Terraform Infrastructure as Code (IaC) that provisions and manages the cloud foundation for **SUM Store** on AWS. Everything from our isolated network topology to the managed Amazon EKS cluster and IAM role definitions is version-controlled and automated here.

---

## What We Provision

- **VPC & Networking**: Multi-AZ virtual private cloud with dedicated public and private subnets, NAT gateways for secure outbound egress, and proper Kubernetes subnet tagging (`kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`).
- **Amazon EKS Cluster**: Managed Kubernetes control plane running production-grade add-ons (VPC CNI, CoreDNS, kube-proxy).
- **Managed Node Groups**: Auto-scaling worker node groups running in private subnets with custom launch templates, optimized instance sizing, and rolling upgrade capabilities.
- **IAM & IRSA**: IAM Roles for Service Accounts (IRSA) giving fine-grained AWS permissions directly to Kubernetes pods (AWS Load Balancer Controller, external DNS, EBS CSI driver) without hardcoding long-lived credentials.
- **Remote State**: S3 remote backend with DynamoDB state locking to ensure safe, concurrent team operations.

---

## Architecture Overview

```
                      +---------------------------------------+
                      |         AWS Cloud (us-east-1)         |
                      |                                       |
                      |   +-------------------------------+   |
                      |   |           SUM-VPC             |   |
                      |   |                               |   |
                      |   |   Public Subnets (NAT / ALB)  |   |
                      |   |   Private Subnets (EKS Nodes) |   |
                      |   +---------------+---------------+   |
                      +-------------------|-------------------+
                                          v
                      +---------------------------------------+
                      |           Amazon EKS Cluster          |
                      |  - Managed Control Plane              |
                      |  - Private Worker Node Groups         |
                      |  - OIDC Provider + IRSA               |
                      +---------------------------------------+
                                          |
                                          v
                              Target of GitOps Delivery
                           (Sumstore-GitOps & ArgoCD)
```

---

## Repository Structure

```
├── environments/
│   └── dev/                  # Environment-specific variables, backend configs, and root module
│       ├── main.tf           # Module calls and orchestration
│       ├── variables.tf      # Environment input variables
│       ├── terraform.tfvars  # Concrete values (region, cluster name, node sizes)
│       └── outputs.tf        # Cluster endpoint, ARN, and security group outputs
├── modules/
│   ├── vpc/                  # VPC, subnets, route tables, IGW, and NAT gateways
│   ├── eks/                  # EKS cluster control plane, addons, and node groups
│   └── iam/                  # IAM roles, policies, and OIDC provider integration
└── .github/                  # CI workflows for Terraform lint, validate, and plan
```

---

## Deployment Walkthrough

### 1. Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) (>= 1.5.x)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate IAM credentials
- `kubectl` for interacting with the cluster once provisioned

### 2. Configure Backend & Variables
Ensure your AWS credentials are set:
```shell
export AWS_REGION="us-east-1"
export AWS_PROFILE="your-aws-profile"
```

Navigate to the target environment directory:
```shell
cd environments/dev
```

Inspect and update `terraform.tfvars` if you need to adjust instance types, node counts, or cluster naming.

### 3. Initialize & Deploy

```shell
# Initialize provider plugins and S3 backend
terraform init

# Validate configuration syntax
terraform validate

# Review proposed changes
terraform plan

# Apply changes to provision infrastructure
terraform apply
```

### 4. Connect to Your EKS Cluster
Once Terraform finishes, update your local `kubeconfig`:

```shell
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
```

Verify your worker nodes are up and ready:
```shell
kubectl get nodes -o wide
```

---

## Security & Best Practices

- **Zero Public Nodes**: All worker nodes run strictly within private subnets. Only the load balancers sit on public subnets.
- **Least-Privilege IRSA**: Pods assume least-privilege IAM roles tied to their Kubernetes ServiceAccount via AWS STS and OIDC.
- **State Locking**: DynamoDB prevents multiple engineers or pipelines from running overlapping applies.
- **Destroy Protection**: Critical resources (such as state storage and database volumes) carry termination protection.

---

## Next Step: Application Delivery

Once this infrastructure is provisioned, application deployment and continuous delivery are handled via GitOps in the [Sumstore-GitOps](https://github.com/sumanthbcloud/Sumstore-GitOps) repository.
