/*
  More to come...
*/

/*
  SUBNETS
    Setup logic to decide what subnet structure should be used based on the CIDR range.
*/
variable "cidr_range_16" {
  default = 0
}

variable "cidr_range_18" {
  default = 0
}

variable "cidr_range_20" {
  default = 0
}

locals {
  cidr_range_16 = "${cidrnetmask(var.vpc_cidr) == "255.255.0.0" ? 1 : 0 }"
  cidr_range_18 = "${cidrnetmask(var.vpc_cidr) == "255.255.192.0" ? 1 : 0 }"
  cidr_range_20 = "${cidrnetmask(var.vpc_cidr) == "255.255.240.0" ? 1 : 0 }"
}

/*
  Define default subnets for our account given a 10.0.0.0/20 CIDR
  ex 10.45.48.0/20 (10.45.48/63)
    3 public/ALB across the provided AZs /25
      10.45.48.1/127
      10.45.49.1/127
      10.45.50.1/127
    3 public (NAT) across the provided AZs /27
      10.45.57.1/31
      10.45.57.32/63
      10.45.57.64/95
    3 private Web/App (combined) across the provided AZs /24
      10.45.51.1/255
      10.45.52.1/255
      10.45.53.1/255
    3 private Data combined across the provided AZs /24
      10.45.54.1/255
      10.45.55.1/255
      10.45.56.1/255

  See urls for docs on how the cidrsubnet function operates.
    http://jodies.de/ipcalc
    https://www.terraform.io/docs/configuration/interpolation.html#cidrsubnet-iprange-newbits-netnum-

*/

/*
  Get and sort AZs
  Sorting the list reduces (but does not eliminate) the likelyhood of values changing in future plans.
*/
data "aws_availability_zones" "available_az" {
  state = "available"
}

locals {
  sorted_az_list = "${sort(data.aws_availability_zones.available_az.names)}"
}

# Public ALB subnets.  Allow AWS to decide on AZ.
resource "aws_subnet" "subnet_public_lb_1" {
  count             = "${local.cidr_range_20}"
  vpc_id            = "${aws_vpc.vpc_1a.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc_1a.cidr_block, 5, 0)}"
  availability_zone = "${local.sorted_az_list[0]}"

  tags = "${merge(var.default_tags,
    map(
      "Name", join(" ", list(var.subnet_prefix_pub_tier1, "Zone1")),
      "tier", var.subnet_prefix_pub_tier1
      ))}"
}

output "subnet_public_lb_1" {
  value = "${aws_subnet.subnet_public_lb_1.*.id}"
}

resource "aws_subnet" "subnet_public_lb_2" {
  count             = "${local.cidr_range_20}"
  vpc_id            = "${aws_vpc.vpc_1a.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc_1a.cidr_block, 5, 2)}"
  availability_zone = "${local.sorted_az_list[1]}"

  tags = "${merge(var.default_tags,
    map(
      "Name", join(" ", list(var.subnet_prefix_pub_tier1, "Zone2")),
      "tier", var.subnet_prefix_pub_tier1
      ))}"
}

output "subnet_public_lb_2" {
  value = "${aws_subnet.subnet_public_lb_2.*.id}"
}

resource "aws_subnet" "subnet_public_lb_3" {
  count             = "${local.cidr_range_20}"
  vpc_id            = "${aws_vpc.vpc_1a.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc_1a.cidr_block, 5, 4)}"
  availability_zone = "${local.sorted_az_list[2]}"

  tags = "${merge(var.default_tags,
    map(
     "Name", join(" ", list(var.subnet_prefix_pub_tier1, "Zone3")),
     "tier", var.subnet_prefix_pub_tier1
      ))}"
}

output "subnet_public_lb_3" {
  value = "${aws_subnet.subnet_public_lb_3.*.id}"
}

# Public NAT subnets. Allow AWS to decide on AZ.
resource "aws_subnet" "subnet_public_nat_1" {
  count             = "${local.cidr_range_20}"
  vpc_id            = "${aws_vpc.vpc_1a.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc_1a.cidr_block, 7, 72)}"
  availability_zone = "${local.sorted_az_list[0]}"

  tags = "${merge(var.default_tags,
    map(
     "Name", join(" ", list(var.subnet_prefix_pub_tier2, "Zone1")),
     "tier", var.subnet_prefix_pub_tier2
      ))}"
}
