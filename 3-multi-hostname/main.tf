
resource "aws_key_pair" "web_admin" {
  key_name   = "web_admin"
  public_key = "${file("~/.ssh/web_admin.pub")}"
}

resource "aws_security_group" "ssh" {
  name        = "Allow SSH from ALL"
  description = "Allow SSH port from all"

  //SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "testins2" {
  count         = length(var.host_names)
  ami           = "ami-009bbbf94a294326d"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.web_admin.key_name}"

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.host_names[count.index]}"
    ]
    connection {
      host        = self.public_ip
      user        = "centos"
      type        = "ssh"
      private_key = "${file("./nexr.pem")}"
      timeout     = "2m"
    }

  }

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
  ]
  tags = {
    Name = "NodeName-${var.host_names[count.index]}"
  }
}
