# SUM Store AWS Infrastructure

Terraform for the SUM Store AWS platform. The architecture uses a two-AZ VPC, public and private subnets, one NAT gateway, IAM roles, and an EKS cluster with private managed nodes and EBS CSI support. Production state is stored in the existing `sum-store` S3 bucket.

## Structure

- `environments/prod` is the deployment root and contains the intentionally tracked, non-sensitive production inputs.
- `modules/vpc` provisions networking across two availability zones.
- `modules/iam` provisions the IAM roles required by EKS, managed nodes, and EBS CSI.
- `modules/eks` provisions the cluster, managed node group, and EKS add-ons.

Terraform state uses the existing S3 backend with encryption and native S3 state locking. No DynamoDB lock table is required.

## Usage

```shell
cd environments/prod
terraform init
terraform plan
```

The manual GitHub Actions workflow supports `plan`, `apply`, and `destroy`. It authenticates to AWS through GitHub OIDC using the repository variables `AWS_ROLE_ARN` and `AWS_REGION`; the OIDC provider and CI role are configured externally and are not managed by this Terraform stack.

Never store AWS credentials in this repository. Kubernetes workloads are managed in Sumstore-GitOps, and the AWS Load Balancer Controller is managed separately from this stack.
