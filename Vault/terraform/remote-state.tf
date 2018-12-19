data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config {
    bucket = "terraform.state.jaretdeprin.com"
    key    = "aws.terraform/vpc/main-state.tfstate"
    region = "us-west-2"
  }
}
