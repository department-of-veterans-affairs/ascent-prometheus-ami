###############################################################################
#
# Create Security group for monitor 
#
###############################################################################


resource "aws_security_group_rule" "allow_base_monitor_inbound" {
  count        = "${length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0}"
  type         = "ingress"
  from_port    = "${var.node_exporter_port}"
  to_port      = "${var.node_exporter_port}"
  protocol     = "tcp"
  cidr_blocks  = ["${var.allowed_inbound_cidr_blocks}"]
  security_group_id = "${var.security_group_id}"
}

resource "aws_security_group_rule" "allow_node_inbound_from_security_group_ids" {
  count                    = "${length(var.allowed_inbound_security_group_ids)}"
  type                     = "ingress"
  from_port                = "${var.node_exporter_port}"
  to_port                  = "${var.node_exporter_port}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.allowed_inbound_security_group_ids, count.index)}"

  security_group_id = "${var.security_group_id}"
}


