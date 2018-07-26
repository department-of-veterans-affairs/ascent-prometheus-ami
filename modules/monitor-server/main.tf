# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.8 AND ABOVE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.9.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the monitor instance
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "monitor" {
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami_id}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${var.subnet_ids[length(var.subnet_ids) - 1]}"
  vpc_security_group_ids      = ["${aws_security_group.monitor_security_group.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  
  tags {
      Name = "${var.instance_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Control Traffic to instances
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "monitor_security_group" {
  name_prefix = "${var.instance_name}"
  description = "Security group for the ${var.instance_name} instances"
  vpc_id      = "${var.vpc_id}"
  tags {
    Name = "${var.instance_name}"
  }
}

module "security_group_rules" {
  source = "../monitor-security-group-rules"

  security_group_id                  = "${aws_security_group.monitor_security_group.id}"
  allowed_inbound_cidr_blocks        = ["${var.allowed_inbound_cidr_blocks}"]
  allowed_inbound_security_group_ids = ["${var.allowed_inbound_security_group_ids}"]
  allowed_ssh_cidr_blocks            = ["${var.allowed_ssh_cidr_blocks}"]
  cloudwatch_port                    = "${var.cloudwatch_port}"
  alertmanager_port                  = "${var.alertmanager_port}"
  prometheus_port                    = "${var.prometheus_port}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO MONITOR EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS CLI without having to figure out
# how to get our secret AWS access keys onto the box.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.instance_name}"
  path        = "${var.instance_profile_path}"
  role        = "${aws_iam_role.instance_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.instance_name}"
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

# ---------------------------------------------------------------------------------------------------------------------
# THE IAM POLICIES COME FROM THE MONITOR-IAM-POLICIES MODULE
# ---------------------------------------------------------------------------------------------------------------------

module "iam_policies" {
  source = "../monitor-iam-policies"

  iam_role_id = "${aws_iam_role.instance_role.id}"
}
