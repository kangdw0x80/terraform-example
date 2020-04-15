output "instance_ip_addr" {
  value = aws_instance.mgmt.private_ip
}
output "DN_ip_addr" {
  value = aws_instance.dn.*.private_ip
}
