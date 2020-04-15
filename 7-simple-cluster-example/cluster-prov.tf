locals {
  access_ip = var.use-eip == "true" ? aws_eip.cluster-eip[0].public_ip : aws_instance.mgmt[0].public_ip
}

resource "null_resource" "create-hosts-file" {
  depends_on = [
    aws_instance.cluster-datanode,
    aws_instance.mgmt,
    aws_volume_attachment.datanode-disk-attachment,
    aws_volume_attachment.mgmt-disk-attachment
  ]
  triggers = {
    //instance = "${aws_instance.mgmt[0].id}"
    ids = "${join(",", aws_instance.cluster-datanode.*.id)}"
  }
  connection {
    host        = local.access_ip
    user        = "root"
    type        = "ssh"
    private_key = file(var.private_keyfile)
    timeout     = "10m"
  }
  provisioner "local-exec" {
    command = "rm temp/*"
    when    = destroy
  }

  provisioner "file" {
    source      = "./temp/cluster-hosts"
    destination = "/root/cluster-hosts"
  }
  provisioner "file" {
    source      = "./temp/add-hosts"
    destination = "/root/add-hosts"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /root/cluster-hosts >> /etc/hosts"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sync",
      "sleep 10"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "ssh-keyscan dn04.test.com"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/provisioning/bin/mkhosts.sh /root/add-hosts"
    ]
  }
  /*
  provisioner "remote-exec" {
    inline = [
      "ansible all -i /root/add-hosts -m copy -a \"src=/etc/hosts dest=/etc/hosts\"",
    ]
  }
*/
  # Will be deprecated
  provisioner "local-exec" {
    command = "mv ./temp/cluster-hosts temp/backup-cluster-hosts"
  }
  provisioner "local-exec" {
    command = "mv ./temp/cluster-hosts temp/backup-add-hosts"
  }
  ############################
  # Set /etc/hosts
  ############################
}


resource "null_resource" "node-init" {
  depends_on = [
    null_resource.create-hosts-file,
    aws_volume_attachment.datanode-disk-attachment,
    aws_volume_attachment.mgmt-disk-attachment
  ]
  ## 데이터 노드가 생기면 항상 수행
  triggers = {
    ids = "${join(",", aws_instance.cluster-datanode.*.id)}"
  }
  connection {
    host        = local.access_ip
    user        = "root"
    type        = "ssh"
    private_key = file("${var.private_keyfile}")
    timeout     = "10m"
  }
  provisioner "local-exec" {
    command = "echo node-init>>add.log"
  }
  provisioner "remote-exec" {
    inline = [
      "ansible all -i /root/add-hosts -m shell -a \"bash /root/provisioning/bin/reconfigure-env.sh\"",
      "ansible all -i /root/add-hosts -m shell -a \"bash /root/provisioning/bin/resize-disk.sh 1\"",
      "ansible all -i /root/add-hosts -m shell -a \"bash /root/provisioning/bin/recover-data.sh\""
    ]
  }
}



resource "null_resource" "all-datanode-disk-resize" {
  depends_on = [
    null_resource.create-hosts-file,
    null_resource.node-init,
    aws_volume_attachment.datanode-disk-attachment,
    aws_volume_attachment.mgmt-disk-attachment
  ]
  triggers = {
    size = "${var.datanode["data_disk_size"]}"
  }
  connection {
    host        = local.access_ip
    user        = "root"
    type        = "ssh"
    private_key = file(var.private_keyfile)
    timeout     = "10m"
  }
  provisioner "local-exec" {
    command = "echo -e \"${join("\n", aws_instance.cluster-datanode.*.tags.private_hostname)}\" > temp/resize-hosts"
  }
  #"ansible all -i /root/add-hosts -m shell -a \"bash /root/provisioning/bin/resize-disk.sh\"",
  provisioner "file" {
    source      = "./temp/resize-hosts"
    destination = "/root/resize-hosts"
  }
  provisioner "remote-exec" {
    inline = [
      "ansible all -i /root/resize-hosts -m shell -a \"bash /root/provisioning/bin/resize-disk.sh 0\"",
    ]
  }
}
resource "null_resource" "cluster-start" {
  depends_on = [
    null_resource.create-hosts-file,
    null_resource.node-init,
    aws_volume_attachment.datanode-disk-attachment,
    null_resource.all-datanode-disk-resize,
  ]
  triggers = {
    instance = "${aws_instance.mgmt[0].id}"
  }
  connection {
    host        = local.access_ip
    user        = "root"
    type        = "ssh"
    private_key = file("${var.private_keyfile}")
    timeout     = "10m"
  }
  # Run NDAP
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook  start.yml"
    ]
  }
}

resource "null_resource" "cluster-node-add" {
  depends_on = [
    aws_volume_attachment.datanode-disk-attachment,
    null_resource.all-datanode-disk-resize,
    null_resource.cluster-start,
    null_resource.create-hosts-file
  ]
  ## 데이터 노드가 생기면 항상 수행
  # 필요한 정보: 새로 만들어진 datanode hostname
  triggers = {
    ids = "${join(",", aws_instance.cluster-datanode.*.id)}"
  }
  connection {
    host        = local.access_ip
    user        = "root"
    type        = "ssh"
    private_key = file(var.private_keyfile)
    timeout     = "10m"
  }
  provisioner "local-exec" {
    command = "echo cluster add >> temp/add.log"
  }
  provisioner "remote-exec" {
    inline = [
      "bash /root/provisioning/bin/cluster-add.sh /root/add-hosts"
    ]
  }

}


