###
## General tips


## Use Security Group Attachments not inline defined ingress / egress rules
# Defining rules outside of the group will allow you to have a static security group id while altering the rules.
# In this example, terraform will not attempt to recreate the group if a specific rule changes.

resource "aws_security_group" "security_group_a" {
  name    = "My Special Group"
  vpc_id  = "${var.vpc_id}"

  tags = {
    Name  = "My Special Group",
  }
}

resource "aws_security_group_rule" "ingr_80_http" {
  type               = "ingress"
  from_port          = 80
  to_port            = 80
  protocol           = "tcp"
  description        = "80 - Default HTTP port"
  cidr_blocks        = ["0.0.0.0/0"]
  security_group_id  = "${aws_security_group.intern_named.id}"
}
resource "aws_security_group_rule" "egr_allow_all" {
  type               = "egress"
  from_port          = 0
  to_port            = 0
  protocol           = "-1"
  description        = "Allow all outbound traffic"
  cidr_blocks        = ["0.0.0.0/0"]
  security_group_id  = "${aws_security_group.security_group_a.id}"
}


## Use volume attachment when building instances, not in-line volumes.
# This allows you to resize the drives of an instance without Terraform attempting to recreate the instance.

resource "aws_instance" "ec2_instance_a" {
  ami           = "${var.my_ami}"
  instance_type = "t2.micro"
  subnet_id     = "${var.my_subnet}"
  key_name      = "${var.my_key}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = true
  }
/*
  # No!
   ebs_block_device = {
    device_name           = "xvdb"
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = true
  }
*/
  tags = {
    Name = "My Great EC2 Instance"
  }

  volume_tags = "${var.default_tags}"
}
# Define extra EBS volume independantly
resource "aws_ebs_volume" "instance_a_device123" {
    availability_zone = "us-east-1a"
    type = "gp2"
    size = 40
    tags {
      Name = "Instance A Device /dev/xvdb"
    }
}
# Attach extra EBS volume independantly
resource "aws_volume_attachment" "instance_a_device123_attach" {
  device_name = "/dev/xvdb"
  volume_id   = "${aws_ebs_volume.instance_a_device123.id}"
  instance_id = "${aws_instance.ec2_instance_a.id}"
}
