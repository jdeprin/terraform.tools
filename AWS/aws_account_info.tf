/*
  Pulls account specific data from AWS
*/

data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

data "aws_subnet" "app_tier_zone1" {
  id = "${var.default_subnet}"
}

output "az_from_subnet" {
  value = "${data.aws_subnet.app_tier_zone1.availability_zone}"
}
