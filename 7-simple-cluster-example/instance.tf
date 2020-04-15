
resource "aws_ebs_volume" "mgmt_disk" {
  count             = var.mgmt["disk_count"] * var.mgmt["node_count"]
  snapshot_id       = var.data_snapshot["extra"] // add if-statement
  availability_zone = var.aws_avail_zone
  size              = var.mgmt["data_disk_size"]
  type              = var.mgmt["data_disk_type"]
  tags = {
    Name = "mgmt-disk-${count.index + 1}"
  }
}

resource "aws_volume_attachment" "mgmt-disk-attachment" {
  count        = var.mgmt["disk_count"] * var.mgmt["node_count"]
  device_name  = var.data_volume_device_list[count.index % var.mgmt["disk_count"]]
  instance_id  = aws_instance.mgmt[floor(count.index / var.mgmt["disk_count"])].id
  volume_id    = aws_ebs_volume.mgmt_disk[count.index].id
  skip_destroy = "true" // For destory
}

resource "aws_instance" "mgmt" {
  ami           = var.mgmt_images[var.aws_avail_zone]
  instance_type = var.mgmt["instance_type"]
  count         = var.mgmt["node_count"]

  vpc_security_group_ids = [
    aws_security_group.cluster-sg.id
  ]
  subnet_id  = aws_subnet.private-subnet.id
  private_ip = var.mgmt_private_ip[count.index]

  root_block_device {
    delete_on_termination = true
    volume_size           = var.mgmt["root_disk_size"]
    volume_type           = var.mgmt["root_disk_type"]
  }
  key_name = var.aws_keypair != "" ? var.aws_keypair : aws_key_pair.cluster-keypair[0].key_name

  //  user_data                   = file("mgmt-init.sh")
  user_data = <<-EOT
  #!/usr/bin/env bash
  sudo hostnamectl set-hostname ${var.mgmt_hostname[count.index]}

  ####### Resize Root device #############
  growpart /dev/xvda 2
  pvresize /dev/xvda2
  lvextend -l +100%FREE /dev/mapper/centos-root
  resize2fs /dev/mapper/centos-root
  touch /tmp/fin

  touch /root/fin
  echo "hi" > /tmp/fin
  cat /tmp/fin
  EOT

  associate_public_ip_address = var.use-eip != "true" ? true : false

  provisioner "local-exec" {
    command = "echo ${self.private_ip} ${var.mgmt_hostname[count.index]} >>./temp/cluster-hosts"
  }
  provisioner "local-exec" {
    command = "echo ${self.tags.private_hostname} >>./temp/add-hosts"
  }

  tags = {
    Name             = "${var.prefix_node_name}-MGMT${count.index + 1}"
    private_hostname = "${var.mgmt_hostname[count.index]}"
  }

  lifecycle {
    ignore_changes = [
      associate_public_ip_address
    ]
  }
}

resource "aws_ebs_volume" "datanode-disk" {
  count             = var.datanode["disk_count"] * var.datanode["node_count"]
  snapshot_id       = var.data_snapshot["extra"] // add if-statement
  availability_zone = var.aws_avail_zone
  size              = var.datanode["data_disk_size"]
  type              = var.datanode["data_disk_type"]

  tags = {
    Name = "dn-disk-${count.index + 1}"
  }
}

resource "aws_volume_attachment" "datanode-disk-attachment" {
  count = var.datanode["disk_count"] * var.datanode["node_count"]

  /*
  device_name = var.data_volume_device_list[floor(count.index / var.datanode["node_count"]) % var.datanode["disk_count"]]
  instance_id = aws_instance.cluster-datanode[count.index % var.datanode["node_count"]].id
  volume_id   = aws_ebs_volume.datanode-disk[count.index].id
*/

  device_name = var.data_volume_device_list[count.index % var.datanode["disk_count"]]
  instance_id = aws_instance.cluster-datanode[floor(count.index / var.datanode["disk_count"])].id
  volume_id   = aws_ebs_volume.datanode-disk[count.index].id

  skip_destroy = "true" // For destory
  /*
  provisioner "local-exec" {
    command = "sudo mkdir /data${count.index % var.datanode["disk_count"] + 1}"
  }
  provisioner "local-exec" {
    command = "sudo mount -t ext4 ${var.data_volume_device_list[count.index % var.datanode["disk_count"]]}1 /data${count.index % var.datanode["disk_count"] + 1}"

  }
  provisioner "local-exec" {
    command = "echo hello data >> /tmp/log; whoami >> /tmp/log"
  }
  provisioner "local-exec" {
    command = "echo mount -t ext4 ${var.data_volume_device_list[count.index % var.datanode["disk_count"]]}1 /data${count.index % var.datanode["disk_count"] + 1} >> /tmp/log"
  }
  */

}


resource "aws_instance" "cluster-datanode" {
  //ami           = lookup(var.dn_images, var.avail_zone)
  ami           = var.dn_images[var.aws_avail_zone]
  count         = var.datanode["node_count"]
  instance_type = var.datanode["instance_type"]

  //key_name = aws_key_pair.web_admin.key_name
  key_name = var.aws_keypair != "" ? var.aws_keypair : aws_key_pair.cluster-keypair[0].key_name

  vpc_security_group_ids = [
    aws_security_group.cluster-sg.id
  ]
  subnet_id  = aws_subnet.private-subnet.id
  private_ip = var.dn_private_ip[count.index]


  root_block_device {
    delete_on_termination = true
    volume_size           = var.datanode["root_disk_size"]
    volume_type           = var.datanode["root_disk_type"]
  }
  associate_public_ip_address = var.datanode["public_ip_set"]

  user_data = <<-EOT
  #!/usr/bin/env bash
  sudo hostnamectl set-hostname ${var.dn_hostname[count.index]}

  ####### Resize Root device #############
  growpart /dev/xvda 2
  pvresize /dev/xvda2
  lvextend -l +100%FREE /dev/mapper/centos-root
  resize2fs /dev/mapper/centos-root
  touch /tmp/fin
  EOT

  provisioner "local-exec" {
    command = "echo ${self.private_ip} ${var.dn_hostname[count.index]}>>./temp/cluster-hosts"
  }
  provisioner "local-exec" {
    command = "echo ${self.tags.private_hostname} >>./temp/add-hosts"
  }
  tags = {
    Name             = "${var.prefix_node_name}-DN${count.index + 1} Node"
    private_hostname = "${var.dn_hostname[count.index]}"
  }
}


