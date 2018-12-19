variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "workspace_iam_roles" {
  type = "map"
}

variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"

  assume_role {
    role_arn     = "${var.workspace_iam_roles[terraform.workspace]}"
    session_name = "terraform"
  }
}