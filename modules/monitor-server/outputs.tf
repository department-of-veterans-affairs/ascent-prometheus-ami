
output "security_group_id" {
  value = "${aws_security_group.monitor_security_group.id}"
}

# TODO : Ask Brett about this because it's making stuff break. Is it needed?
#output "base_monitor_security_group_id" {
#  value = "${aws_security_group.base_monitor_inbound_security_group.id}"
#}

output "private_ip" {
  value = "${aws_instance.monitor.private_ip}"
}
