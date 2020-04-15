/*


*/

resource "aws_ebs_volume" "datanode_disk" {
  count             = var.datanode["disk_count"] * var.datanode["node_count"]
  availability_zone = var.avail_zone
  size              = var.datanode["disk_size"]
  type              = var.datanode["disk_type"]

  tags = {
    Name = "dn-disk-${count.index}"
  }
}

resource "aws_volume_attachment" "datanode-disk-attachment" {
  count        = var.datanode["disk_count"] * var.datanode["node_count"]
  device_name  = var.data_volume_device_list[count.index % var.datanode["node_count"]]
  instance_id  = aws_instance.ndap_dn[floor(count.index / var.datanode["node_count"])].id
  volume_id    = aws_ebs_volume.datanode_disk[count.index].id
  skip_destroy = "true" // destory
}
