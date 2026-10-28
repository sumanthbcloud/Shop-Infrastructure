variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming and common tags."
  type        = string
  default     = "sum-store"
}

variable "environment" {
  description = "Deployment environment name (e.g., prod, dev)."
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "sum-shop"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster. NOTE: Current value is a temporary validation placeholder; an approved current AWS-supported version must be selected immediately prior to live deployment."
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the VPC."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required for high availability."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (must match the number of availability zones)."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "The number of public subnet CIDRs must match the number of availability zones."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (must match the number of availability zones)."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "The number of private subnet CIDRs must match the number of availability zones."
  }
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
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint if enabled."
  type        = list(string)
  default     = []
}

variable "node_instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)
  default     = ["m7i-flex.large"]
}

variable "node_disk_size" {
  description = "Root disk size in GiB for EKS worker nodes."
  type        = number
  default     = 50
}

variable "node_min_size" {
  description = "Minimum number of EKS managed nodes."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired number of EKS managed nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of EKS managed nodes."
  type        = number
  default     = 4
}

variable "secret_prefix" {
  description = "Prefix for AWS Secrets Manager secret containers."
  type        = string
  default     = "sumstore"
}
