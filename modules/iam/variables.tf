variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "tags" {
  description = "Tags for IAM resources."
  type        = map(string)
  default     = {}
}

variable "external_secrets_target_arns" {
  description = "List of Secrets Manager secret ARNs that External Secrets Operator is permitted to access."
  type        = list(string)
  default     = []
}
