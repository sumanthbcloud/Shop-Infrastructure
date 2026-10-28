#!/usr/bin/env bash
# ==============================================================================
# Script: bootstrap-eks-client.sh
# Purpose: Run inside the administrative client EC2 workstation to verify tools,
#          configure kubeconfig, and confirm cluster connectivity.
# ==============================================================================

set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-sum-shop}"

echo "================================================="
echo "Verifying Client Tools & Cluster Connectivity"
echo "================================================="

# 1. Verify Installed Tools
for tool in aws kubectl helm git jq curl argocd; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "✓ $tool is installed: $(command -v "$tool")"
  else
    echo "✗ $tool is MISSING" >&2
  fi
done

# 2. Check AWS STS Caller Identity
echo ""
echo "Checking AWS IAM identity..."
CALLER_IDENTITY=$(aws sts get-caller-identity --region "${AWS_REGION}")
echo "${CALLER_IDENTITY}"

# 3. Update Kubeconfig
echo ""
echo "Updating kubeconfig for cluster ${CLUSTER_NAME}..."
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}"

# 4. Verify EKS Cluster Communication
echo ""
echo "Testing kubectl connectivity..."
kubectl cluster-info
echo ""
echo "Listing EKS nodes:"
kubectl get nodes -o wide

echo ""
echo "================================================="
echo "Client workstation is ready for Day-0 operations."
echo "================================================="
