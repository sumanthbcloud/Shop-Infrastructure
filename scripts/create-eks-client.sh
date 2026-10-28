#!/usr/bin/env bash
# ==============================================================================
# Script: create-eks-client.sh
# Purpose: Launch the administrative client EC2 instance using AWS CLI.
#          Discovers Terraform outputs automatically.
# DO NOT RUN during offline readiness phase.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../environments/prod"
AWS_REGION="${AWS_REGION:-us-east-1}"
INSTANCE_TAG="${INSTANCE_TAG:-sumstore-eks-client}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.medium}"

echo "================================================="
echo "Creating Administrative Client EC2 Workstation"
echo "Region: ${AWS_REGION}"
echo "================================================="

if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI is required." >&2
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
SUBNET_ID=$(echo "${TF_OUTPUTS}" | jq -r '.private_subnet_ids.value[0] // empty')
INSTANCE_PROFILE=$(echo "${TF_OUTPUTS}" | jq -r '.client_ec2_instance_profile_name.value // empty')
SECURITY_GROUP_ID=$(echo "${TF_OUTPUTS}" | jq -r '.client_ec2_security_group_id.value // empty')

if [ -z "${CLUSTER_NAME}" ] || [ -z "${SUBNET_ID}" ] || [ -z "${INSTANCE_PROFILE}" ] || [ -z "${SECURITY_GROUP_ID}" ]; then
  echo "ERROR: Missing required Terraform outputs. Ensure Terraform has been applied." >&2
  exit 1
fi

echo "Discovered Infrastructure Details:"
echo "  Cluster Name:      ${CLUSTER_NAME}"
echo "  VPC ID:            ${VPC_ID}"
echo "  Target Subnet ID:  ${SUBNET_ID} (Private)"
echo "  Instance Profile:  ${INSTANCE_PROFILE}"
echo "  Security Group ID: ${SECURITY_GROUP_ID}"

echo "Looking up latest Amazon Linux 2023 AMI via SSM parameter..."
AMI_ID=$(aws ssm get-parameter \
  --name "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" \
  --query "Parameter.Value" \
  --output text \
  --region "${AWS_REGION}")
echo "  Selected AMI ID:   ${AMI_ID}"

# Prepare UserData to install basic bootstrap dependencies
USER_DATA_FILE=$(mktemp)
cat << 'UD_EOF' > "${USER_DATA_FILE}"
#!/bin/bash
set -e
dnf update -y
dnf install -y git jq tar gzip unzip curl openssl

# Install kubectl (v1.30)
KUBECTL_VERSION="v1.30.5"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# Install Helm (v3)
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Argo CD CLI
ARGOCD_VERSION="v2.13.0"
curl -sSL -o argocd-linux-amd64 "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm -f argocd-linux-amd64

echo "Base bootstrap complete." > /var/log/client-bootstrap.log
UD_EOF

echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "${AMI_ID}" \
  --instance-type "${INSTANCE_TYPE}" \
  --iam-instance-profile "Name=${INSTANCE_PROFILE}" \
  --subnet-id "${SUBNET_ID}" \
  --security-group-ids "${SECURITY_GROUP_ID}" \
  --user-data "file://${USER_DATA_FILE}" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_TAG}},{Key=ManagedBy,Value=ManualCLI}]" \
  --metadata-options "HttpTokens=required,HttpPutResponseHopLimit=2,HttpEndpoint=enabled" \
  --region "${AWS_REGION}" \
  --query "Instances[0].InstanceId" \
  --output text)

rm -f "${USER_DATA_FILE}"

echo "Instance launched successfully: ${INSTANCE_ID}"
echo ""
echo "Waiting for instance to reach running state..."
aws ec2 wait instance-running --instance-ids "${INSTANCE_ID}" --region "${AWS_REGION}"
echo "✓ Instance ${INSTANCE_ID} is now running."
echo ""
echo "================================================="
echo "Connect using AWS Systems Manager Session Manager:"
echo "  aws ssm start-session --target ${INSTANCE_ID} --region ${AWS_REGION}"
echo ""
echo "Once connected, update your kubeconfig:"
echo "  aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
echo "  kubectl get nodes"
echo "================================================="
