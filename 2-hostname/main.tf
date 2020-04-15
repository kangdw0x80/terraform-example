/*
  web_admin.pub is from "ssh-keygen -t rsa -b 4096 -C "<EMAIL_ADDRESS>" -f "$HOME/.ssh/web_admin" -N """
*/
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
resource "aws_security_group" "http" {
  name        = "Allow HTTP from ALL"
  description = "Allow http port from all"
  //HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name        = "HTTPS security allow"
  description = "Allow https"
  // SSL
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "provisioning_test" {
  ami           = "ami-0c18c811d459726f8"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.web_admin.key_name}"
  // Provisioning via SSH connection with private key
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname test.provisioning.com"
    ]
    connection {
      host        = self.public_ip
      user        = "centos"
      type        = "ssh"
      private_key = "${file("~/.ssh/web_admin")}"
      timeout     = "2m"
    }

  }
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
    , "${aws_security_group.http.id}"
    , "${aws_security_group.https.id}"
  ]

}

resource "aws_instance" "userdata_test" {
  // ami is CentOS7
  ami           = "ami-009bbbf94a294326d"
  instance_type = "t2.micro"

  key_name  = "${aws_key_pair.web_admin.key_name}"
  user_data = <<-EOT
  #!/usr/bin/env bash
  sudo hostnamectl set-hostname test.userdata.com
  EOT

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
    , "${aws_security_group.http.id}"
    , "${aws_security_group.https.id}"
  ]
}
