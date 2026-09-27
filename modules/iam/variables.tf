variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "tags" {
  description = "Tags for IAM resources."
  type        = map(string)
  default     = {}
}
