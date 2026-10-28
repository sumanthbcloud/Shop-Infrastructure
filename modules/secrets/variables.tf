variable "secret_prefix" {
  description = "Prefix for Secrets Manager secret names (e.g., sumstore)."
  type        = string
  default     = "sumstore"
}

variable "tags" {
  description = "Tags to apply to Secrets Manager resources."
  type        = map(string)
  default     = {}
}
