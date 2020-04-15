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

/*
resource "aws_security_group" "HTTPtest" {
  name = "allow_http_from_all"
  description = "Allow http port from all"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/
/*data "aws_security_group" "default" {
  name = "default"
}
*/
/*
resource "aws_ebs_volume" "test-vda" {
  #count = "1"
  //device_name           = "dev/sdd"
  size              = "10"
  availability_zone = "ap-northeast-2c"


}
*/
resource "aws_instance" "testins1" {
  //  count=1
  ami           = "ami-009bbbf94a294326d"
  instance_type = "t2.micro"

  key_name                    = "${aws_key_pair.web_admin.key_name}"
  associate_public_ip_address = true
  /*
  provisioner "remote-exec" {
    inline = [
      "date >> /tmp/echotest"
      , "echo provisioner >>/tmp/echotest"
    ]
    connection {
      host        = self.public_ip
      user        = "centos"
      type        = "ssh"
      private_key = "${file("./nexr.pem")}"
      //private_key= "${aws_key_pair.web_admin.key_name}"
      //private_key= "${file("~/.ssh/web_admin.pub")}"
      //private_key = "${file("~/.ssh/id_rsa")}"
      timeout = "2m"
    }
  }
  */
  user_data = "${file("userdata.sh")}"
  tags = {
    Name  = "Echo Test"
    Batch = "5AM hehe"
  }

  //key_name = "nexr"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
    , "${aws_security_group.http.id}"
    , "${aws_security_group.https.id}"
    //   ,"${aws_security_group.HTTPtest.id}"
    //,"${data.aws_security_group.default.id}"
  ]
}

resource "aws_instance" "testins2" {
  //  count=1
  ami           = "ami-009bbbf94a294326d"
  instance_type = "t2.micro"

  key_name                    = "${aws_key_pair.web_admin.key_name}"
  associate_public_ip_address = false
  user_data                   = "${file("userdata.sh")}"
  tags = {
    Name  = "Echo Test"
    Batch = "5AM hehe"
  }

  //key_name = "nexr"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}"
    , "${aws_security_group.http.id}"
    , "${aws_security_group.https.id}"
  ]
}
