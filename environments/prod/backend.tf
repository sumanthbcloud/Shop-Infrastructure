terraform {
  backend "s3" {
    bucket       = "sum-store"
    key          = "prod/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
