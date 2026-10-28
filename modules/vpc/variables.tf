variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name used for Kubernetes subnet discovery tags."
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the VPC subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required for high availability."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (must match the number of availability zones)."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "The number of public subnet CIDRs must match the number of availability zones."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (must match the number of availability zones)."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "The number of private subnet CIDRs must match the number of availability zones."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create one NAT gateway for private subnet egress."
  type        = bool
  default     = true
}

variable "client_ssh_cidr_blocks" {
  description = "Allowed CIDR blocks for SSH access to the administrative client EC2. NEVER allow 0.0.0.0/0. Defaults to empty (SSM only)."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.client_ssh_cidr_blocks, "0.0.0.0/0")
    error_message = "SSH access from 0.0.0.0/0 is strictly prohibited for security."
  }
}

variable "tags" {
  description = "Tags for VPC resources."
  type        = map(string)
  default     = {}
}
