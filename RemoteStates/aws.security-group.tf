/*
  Example resource that may exist in a seperate state file.
  This is a resource we want to reference in our current state.
*/

resource "aws_security_group" "my_core_group" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.12.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = ["pl-12c4e678"]
  }
}

# To get the required information into the root of our state file we must output the data we want.

output "core_ext_sg" {
  value = "${aws_security_group.my_core_group.id}"
}
