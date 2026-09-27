terraform {
  backend "s3" {
    bucket       = "sum-store"
    key          = "prod/terraform.tfstate"
    encrypt      = true
    region       = us-east-1
    use_lockfile = true
  }
}
