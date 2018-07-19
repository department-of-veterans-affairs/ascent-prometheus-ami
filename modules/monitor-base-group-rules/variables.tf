###############################################################################
# REQUIRED VARIABLES
###############################################################################

variable "security_group_id" {
  description = "The ID of the security group to which we should add the monitor  security group rules"
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to monitor"
  type        = "list"
}

###############################################################################
# OPTIONAL VARIABLES
###############################################################################


variable "base_monitor_port" {
  description = "The port used for monitor server to scrape metrics"
  default     = 9100
}

