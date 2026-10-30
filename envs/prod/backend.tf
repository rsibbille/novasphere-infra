terraform {
  backend "s3" {
    bucket       = "novasphere-tfstate-rsi-2026"
    key          = "novasphere/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
