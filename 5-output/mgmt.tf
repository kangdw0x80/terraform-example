
resource "aws_key_pair" "web_admin" {
  key_name   = "web_admin2"
  public_key = file("~/.ssh/web_admin.pub")
}


resource "aws_instance" "mgmt" {
  ami           = var.mgmt_images[var.avail_zone]
  instance_type = var.mgmt_type

  key_name = aws_key_pair.web_admin.key_name

  vpc_security_group_ids = [
    aws_security_group.dev_ssh.id
  ]
  subnet_id  = aws_subnet.private.id
  private_ip = var.mgmt_private_ip

  root_block_device {
    delete_on_termination = true
  }
  user_data                   = file("mgmt-init.sh")
  associate_public_ip_address = false
  tags = {
    Name = "MGNT"
  }
}


