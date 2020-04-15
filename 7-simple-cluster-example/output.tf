output "Connect_NODE_IP_ADDRESS" {
  value = var.use-eip == "true" ? "${aws_eip.cluster-eip[0].public_ip}:8080" : "${aws_instance.mgmt[0].public_ip}:8080"
}
output "Private_key_name" {
  value = var.private_keyfile
}

