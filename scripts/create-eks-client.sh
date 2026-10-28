#!/usr/bin/env bash
# ==============================================================================
# Script: create-eks-client.sh
# Purpose: Launch a temporary administrative client EC2 workstation in a public
#          subnet using Terraform outputs.
#
# Boundary:
# - Terraform creates the persistent IAM instance profile & security group.
# - This script (or a manual AWS CLI command) launches the temporary EC2 instance.
# - Connect via AWS Systems Manager Session Manager (or restricted SSH).
# - Communicates with the private EKS API endpoint via VPC routing.
# - Once bootstrapping is complete, terminate via scripts/delete-eks-client.sh.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../environments/prod"
AWS_REGION="${AWS_REGION:-us-east-1}"
INSTANCE_TAG="${INSTANCE_TAG:-sumstore-eks-client}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.medium}"

echo "================================================="
echo "Launching Administrative Client EC2 Workstation"
echo "Region: ${AWS_REGION}"
echo "================================================="

if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI is required." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required." >&2
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "ERROR: terraform is required to discover infrastructure outputs." >&2
  exit 1
fi

echo "Retrieving Terraform outputs from ${ENV_DIR}..."
TF_OUTPUTS=$(cd "${ENV_DIR}" && terraform output -json)

CLUSTER_NAME=$(echo "${TF_OUTPUTS}" | jq -r '.eks_cluster_name.value // empty')
VPC_ID=$(echo "${TF_OUTPUTS}" | jq -r '.vpc_id.value // empty')
SUBNET_ID=$(echo "${TF_OUTPUTS}" | jq -r '.public_subnet_ids.value[0] // empty')
INSTANCE_PROFILE=$(echo "${TF_OUTPUTS}" | jq -r '.client_ec2_instance_profile_name.value // empty')
SECURITY_GROUP_ID=$(echo "${TF_OUTPUTS}" | jq -r '.client_ec2_security_group_id.value // empty')

if [ -z "${CLUSTER_NAME}" ] || [ -z "${SUBNET_ID}" ] || [ -z "${INSTANCE_PROFILE}" ] || [ -z "${SECURITY_GROUP_ID}" ]; then
  echo "ERROR: Missing required Terraform outputs. Ensure Terraform has been applied." >&2
  exit 1
fi

echo "Discovered Infrastructure Details:"
echo "  Cluster Name:      ${CLUSTER_NAME}"
echo "  VPC ID:            ${VPC_ID}"
echo "  Target Subnet ID:  ${SUBNET_ID} (Public Subnet)"
echo "  Instance Profile:  ${INSTANCE_PROFILE}"
echo "  Security Group ID: ${SECURITY_GROUP_ID}"

echo "Looking up latest Amazon Linux 2023 AMI via SSM parameter..."
AMI_ID=$(aws ssm get-parameter \
  --name "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" \
  --query "Parameter.Value" \
  --output text \
  --region "${AWS_REGION}")
echo "  Selected AMI ID:   ${AMI_ID}"

echo "Launching EC2 instance in public subnet with public IP..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "${AMI_ID}" \
  --instance-type "${INSTANCE_TYPE}" \
  --iam-instance-profile "Name=${INSTANCE_PROFILE}" \
  --subnet-id "${SUBNET_ID}" \
  --security-group-ids "${SECURITY_GROUP_ID}" \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_TAG}},{Key=ManagedBy,Value=ManualCLI}]" \
  --metadata-options "HttpTokens=required,HttpPutResponseHopLimit=2,HttpEndpoint=enabled" \
  --region "${AWS_REGION}" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "Instance launched successfully: ${INSTANCE_ID}"
echo "Waiting for instance to reach running state..."
aws ec2 wait instance-running --instance-ids "${INSTANCE_ID}" --region "${AWS_REGION}"

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "${INSTANCE_ID}" \
  --region "${AWS_REGION}" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "✓ Instance ${INSTANCE_ID} is now running."
echo "  Public IPv4: ${PUBLIC_IP}"
echo ""
echo "================================================="
echo "Connect using AWS Systems Manager Session Manager:"
echo "  aws ssm start-session --target ${INSTANCE_ID} --region ${AWS_REGION}"
echo ""
echo "Hands-on Bootstrap Checklist inside the instance:"
echo "  1. Install tools (kubectl, helm, argocd):"
echo "     sudo dnf install -y git jq tar gzip unzip curl openssl"
echo "  2. Update kubeconfig:"
echo "     aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
echo "  3. Verify EKS cluster nodes:"
echo "     kubectl get nodes -o wide"
echo "================================================="
