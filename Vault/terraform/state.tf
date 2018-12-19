terraform {
  backend "s3" {
    bucket = "terraform.state.jaretdeprin.com"
    key    = "aws.terraform/vault-cluster/main-state.tfstate"
    region = "us-west-2"
  }
}
