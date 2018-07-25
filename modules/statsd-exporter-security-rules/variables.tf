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

variable "allowed_inbound_security_group_ids" {
  description = "A list of security group IDs that will be allowed to connect to monitor"
  type        = "list"
  default     = []
}

variable "statsd_exporter_port" {
  description = "The port used to connect to prometheus."
  default     = 9102
}

