# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.8 AND ABOVE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.9.3"
}

resource "aws_iam_user" "prometheus" {
  name = "prometheus"
  path = "/"
}

resource "aws_iam_policy_attachment" "prometheus-attach" {
  name       = "prometheus-attachment"
  users      = ["${aws_iam_user.prometheus.name}"]
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonEC2ReadOnlyAccess"
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

resource "aws_security_group" "base_monitor_inbound_security_group" {
  name_prefix = "base_monitor_inbound_security_group"
  description = "Security group for the base monitor scraping"
  vpc_id      = "${var.vpc_id}"
  tags {
    Name = "base_monitor_inbound_security_group"
  }
}

module "security_base_group_rules" {
  source = "../monitor-base-group-rules"

  security_group_id                  = "${aws_security_group.base_monitor_inbound_security_group.id}"
  allowed_inbound_cidr_blocks        = ["${var.allowed_inbound_cidr_blocks}"]
  base_monitor_port                    = "${var.base_monitor_port}"
}

