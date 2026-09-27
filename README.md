# SUM Store AWS Infrastructure

Terraform foundation for the SUM Store AWS platform. The planned architecture uses a two-AZ VPC, public and private subnets, one NAT gateway, IAM roles, and an EKS cluster with private managed nodes and EBS CSI support.

`bootstrap/backend` is kept separate because the S3 state bucket must exist before the production configuration can initialize its remote backend. The repository implements the backend bucket, VPC networking, EKS IAM, EKS cluster, managed nodes, standard add-ons, and EBS CSI support.

## Usage skeleton

```shell
cd bootstrap/backend
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan

cd ../../environments/prod
cp terraform.tfvars.example terraform.tfvars
# Set the real bucket and key in backend.tf before initialization.
terraform init
terraform plan
```

Authenticate through the AWS CLI, environment variables, or an IAM role. Never store AWS credentials in this repository.
