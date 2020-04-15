/*
  web_admin.pub is from "ssh-keygen -t rsa -b 4096 -C "<EMAIL_ADDRESS>" -f "$HOME/.ssh/web_admin" -N """
*/
resource "aws_key_pair" "web_admin" {
  key_name   = "web_admin"
  public_key = "${file("~/.ssh/web_admin.pub")}"
}

resource "aws_security_group" "ssh" {
  name        = "Allow SSH from ALL"
  description = "Allow http port from all"

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

resource "aws_instance" "testins1" {
  count         = 1
  ami           = "ami-009bbbf94a294326d"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.web_admin.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
    , "${aws_security_group.http.id}"
    , "${aws_security_group.https.id}"
  ]
}

