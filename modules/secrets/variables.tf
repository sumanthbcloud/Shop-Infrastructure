variable "tags" {
  description = "Tags to apply to Secrets Manager resources."
  type        = map(string)
  default     = {}
}
