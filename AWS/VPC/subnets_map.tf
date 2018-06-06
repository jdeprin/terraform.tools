/*
  This module will output a list of maps containint all subnets in a VPC.  The map
  contains the subnet id and the Name.
*/

variable "vpc_id" {
  description = "The VPC ID to pull subnets from."
  default     = "vpc-1234abcd"
}

data "aws_subnet_ids" "vpc_subnet_ids" {
  vpc_id = "${var.vpc_id}"
}

data "aws_subnet" "subnet_details" {
  count = "${length(data.aws_subnet_ids.vpc_subnet_ids.ids)}"
  id    = "${data.aws_subnet_ids.vpc_subnet_ids.ids[count.index]}"
}

locals {
  subnet_list = ["${null_resource.subnets_formated.*.triggers}"]
}

resource "null_resource" "subnets_formated" {
  count = "${length(data.aws_subnet_ids.vpc_subnet_ids.ids)}"

  triggers = "${map(
    "id", element(data.aws_subnet.subnet_details.*.id, count.index),
    "name", element(data.aws_subnet.subnet_details.*.tags.Name, count.index)
  )}"
}
