
resource "aws_key_pair" "web_admin" {
  key_name   = "web_admin2"
  public_key = file("~/.ssh/web_admin.pub")
}


resource "aws_instance" "ndap_mgmt" {
  ami           = var.mgmt_images[var.avail_zone]
  instance_type = var.mgmt_type
  count         = 1
  key_name      = aws_key_pair.web_admin.key_name

  vpc_security_group_ids = [
    aws_security_group.dev_ssh.id
  ]
  subnet_id  = aws_subnet.private.id
  private_ip = var.mgmt_private_ip[count.index]

  root_block_device {
    delete_on_termination = true
  }

  /*
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    volume_size           = 8
    volume_type           = "gp2"
  }
*/
  //  user_data                   = file("mgmt-init.sh")
  user_data = <<-EOT
  #!/usr/bin/env bash
  sudo hostnamectl set-hostname mgmt.nexr.com
  ####### Resize Root device #############
  growpart /dev/xvda 2
  pvresize /dev/xvda2
  lvextend -l +100%FREE /dev/mapper/centos-root
  resize2fs /dev/mapper/centos-root
  ######## Run CMD ##################
  echo "${var.datanode["node_count"]}"
  ls
  EOT

  associate_public_ip_address = false
  tags = {
    Name = "NDAP MGNT"
  }
}


