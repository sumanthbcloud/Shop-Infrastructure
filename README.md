# SUM Store AWS Infrastructure

Terraform for the SUM Store AWS platform. The architecture uses a two-AZ VPC, public and private subnets, one NAT gateway, IAM roles, and an EKS cluster with private managed nodes and EBS CSI support. Production state is stored in the existing `sum-store` S3 bucket.

## Usage skeleton

```shell
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```

Authenticate through the AWS CLI, environment variables, or an IAM role. Never store AWS credentials in this repository.
