variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
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

variable "node_instance_type" {
  description = "EC2 instance type used by the managed node group."
  type        = string
  default     = "t3.medium"
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
