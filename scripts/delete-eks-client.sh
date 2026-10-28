#!/usr/bin/env bash
# ==============================================================================
# Script: delete-eks-client.sh
# Purpose: Safely locate and terminate the temporary client EC2 instance.
# ==============================================================================

set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
INSTANCE_TAG="${INSTANCE_TAG:-sumstore-eks-client}"

echo "================================================="
echo "Terminating Administrative Client EC2 Workstation"
echo "Region: ${AWS_REGION}"
echo "Tag:    ${INSTANCE_TAG}"
echo "================================================="

if ! command -v aws >/dev/null 2>&1; then
  echo "ERROR: aws CLI is required." >&2
  exit 1
fi

echo "Searching for active instances with Name=${INSTANCE_TAG}..."
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=${INSTANCE_TAG}" "Name=instance-state-name,Values=pending,running,stopped" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text \
  --region "${AWS_REGION}")

if [ -z "${INSTANCE_IDS}" ] || [ "${INSTANCE_IDS}" = "None" ]; then
  echo "No active client EC2 instances found matching Name=${INSTANCE_TAG}."
  exit 0
fi

echo "Found instance(s): ${INSTANCE_IDS}"
read -rp "Are you sure you want to terminate these instance(s)? [y/N]: " CONFIRM
if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo "Terminating instance(s)..."
aws ec2 terminate-instances --instance-ids ${INSTANCE_IDS} --region "${AWS_REGION}" >/dev/null

echo "Waiting for instance(s) to terminate..."
aws ec2 wait instance-terminated --instance-ids ${INSTANCE_IDS} --region "${AWS_REGION}"
echo "✓ Instance(s) successfully terminated."
