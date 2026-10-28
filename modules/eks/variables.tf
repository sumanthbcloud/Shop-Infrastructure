variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster (e.g., 1.36)."
  type        = string
  default     = null
  nullable    = true
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the control plane and managed nodes."
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the managed node group IAM role."
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "ARN of the IAM role used by the EBS CSI Pod Identity association."
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types used by the managed node group."
  type        = list(string)
  default     = ["m7i-flex.large"]
}

variable "node_disk_size" {
  description = "Root volume size in GiB for worker nodes."
  type        = number
  default     = 50
}

variable "node_min_size" {
  description = "Minimum number of managed nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.node_min_size >= 0
    error_message = "The minimum node count must not be negative."
  }
}

variable "node_desired_size" {
  description = "Desired number of managed nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= var.node_min_size && var.node_desired_size <= var.node_max_size
    error_message = "The desired node count must be between the minimum and maximum."
  }
}

variable "node_max_size" {
  description = "Maximum number of managed nodes."
  type        = number
  default     = 4

  validation {
    condition     = var.node_max_size >= var.node_min_size
    error_message = "The maximum node count must be greater than or equal to the minimum."
  }
}

variable "tags" {
  description = "Tags for EKS resources."
  type        = map(string)
  default     = {}
}

variable "external_secrets_role_arn" {
  description = "ARN of the IAM role for External Secrets Operator Pod Identity association."
  type        = string
}

variable "external_secrets_namespace" {
  description = "Kubernetes namespace where External Secrets Operator runs."
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_service_account" {
  description = "Kubernetes service account used by External Secrets Operator."
  type        = string
  default     = "external-secrets"
}


variable "aws_load_balancer_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller Pod Identity association."
  type        = string
}

variable "aws_load_balancer_controller_namespace" {
  description = "Kubernetes namespace where AWS Load Balancer Controller runs."
  type        = string
  default     = "kube-system"
}

variable "aws_load_balancer_controller_service_account" {
  description = "Kubernetes service account used by AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = []
}
