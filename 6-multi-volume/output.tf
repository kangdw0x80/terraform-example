output "instance_ip_addr" {
  value = aws_instance.ndap_mgmt.*.private_ip
}
output "DN_ip_addr" {
  value = aws_instance.ndap_dn.*.private_ip
}
output "EIP_public_IP" {
  value = aws_eip.ndap_eip.public_ip
}
