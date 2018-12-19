terraform {
  required_version = ">= 0.9.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AUTO SCALING GROUP (ASG) TO RUN VAULT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix = "${var.cluster_name}"

  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"

  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.subnet_eks_private_zone1_id}",
    "${data.terraform_remote_state.vpc.subnet_eks_private_zone2_id}",
    "${data.terraform_remote_state.vpc.subnet_eks_private_zone3_id}",
  ]

  # Use a fixed-size cluster
  min_size             = "${var.cluster_min_size}"
  max_size             = "${var.cluster_max_size}"
  desired_capacity     = "${var.cluster_desired_size}"
  termination_policies = ["${var.termination_policies}"]

  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"

  enabled_metrics = ["${var.enabled_metrics}"]

  # Use bucket and policies names in tags for depending on them when they are there
  # And only create the cluster after S3 bucket and policies exist
  # Otherwise Vault might boot and not find the bucket or not yet have the necessary permissions
  # Not using `depends_on` because these resources might not exist
  tags = [
    {
      "key" = "${var.cluster_tag_key}"
      "value" = "${var.cluster_name}"
      "propagate_at_launch" = true
    },
    {
      "key" = "${var.consul_cluster_tag_key}"
      "value" = "${var.consul_cluster_tag_vault}"
      "propagate_at_launch" = true
    },
    {
      "key" = "cost"
      "value" = "${var.default_tags["cost"]}"
      "propagate_at_launch" = true
    },
    {
      "key" = "tech_owner"
      "value" = "${var.default_tags["tech_owner"]}"
      "propagate_at_launch" = true
    },
    {
      "key" = "environment"
      "value" = "${var.default_tags["environment"]}"
      "propagate_at_launch" = true
    },

  ]

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE LAUNCH CONFIGURATION TO DEFINE WHAT RUNS ON EACH INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  user_data     = "${var.user_data}"

  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  key_name                    = "${var.ssh_key_name}"
  security_groups             = [
    "${aws_security_group.lc_security_group.id}",
    "${data.terraform_remote_state.vpc.secgroup_allow_office_and_remote_id}"
  ]
  placement_tenancy           = "${var.tenancy}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  ebs_optimized = "${var.root_volume_ebs_optimized}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO CONTROL WHAT REQUESTS CAN GO IN AND OUT OF EACH EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "lc_security_group" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for the ${var.cluster_name} launch configuration"
  vpc_id      = "${var.vpc_id}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(map("Name", var.cluster_name), var.default_tags)}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self" {
  type      = "ingress"
  from_port = "${var.vault_cluster_port}"
  to_port   = "${var.vault_cluster_port}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self_api" {
  type      = "ingress"
  from_port = "${var.vault_api_port}"
  to_port   = "${var.vault_api_port}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self_consul_api" {
  type      = "ingress"
  from_port = "${var.consul_api_port}"
  to_port   = "${var.consul_api_port}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self_consul_dns" {
  type      = "ingress"
  from_port = "${var.consul_dns_port}"
  to_port   = "${var.consul_dns_port}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self_cli_rpc" {
  type      = "ingress"
  from_port = "${var.cli_rpc_port}"
  to_port   = "${var.cli_rpc_port}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self_server_rpc" {
  type      = "ingress"
  from_port = "${var.server_rpc_port}"
  to_port   = "${var.server_rpc_port}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self_serf" {
  type      = "ingress"
  from_port = "${var.serf_lan_port}"
  to_port   = "${var.serf_wan_port}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.lc_security_group.id}"
}
# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO EACH EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS APIs without having to figure out
# how to get our secret AWS access keys onto the box.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.cluster_name}"
  path        = "${var.instance_profile_path}"
  role        = "${aws_iam_role.instance_role.name}"

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.instance_role.json}"

  # aws_iam_instance_profile.instance_profile in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "instance_role_attach_ro_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role = "${aws_iam_role.instance_role.name}"
}