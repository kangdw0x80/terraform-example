
resource "aws_instance" "ndap_dn" {
  ami           = lookup(var.dn_images, var.avail_zone)
  count         = var.datanode["node_count"]
  instance_type = var.datanode["instance_type"]

  key_name = aws_key_pair.web_admin.key_name
  vpc_security_group_ids = [
    aws_security_group.dev_ssh.id
  ]
  subnet_id  = aws_subnet.private.id
  private_ip = var.dn_private_ip[count.index]

  root_block_device {
    delete_on_termination = true
    volume_size           = 32
    volume_type           = "standard"
  }
  associate_public_ip_address = true

  user_data = <<-EOT
  #!/usr/bin/env bash
  sudo hostnamectl set-hostname ${var.dn_hostname[count.index]}

  ####### Resize Root device #############
  growpart /dev/xvda 2
  pvresize /dev/xvda2
  lvextend -l +100%FREE /dev/mapper/centos-root
  resize2fs /dev/mapper/centos-root
  EOT

  tags = {
    Name = "DN${count.index + 1} Node"
  }
}
