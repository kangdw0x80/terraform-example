##########################
# AWS Access Information
##########################

variable "aws_access_key" {
  default = ""
}
variable "aws_secret_key" {
  default = ""
}
variable "aws_keypair" {
  default = "dennis-key"
  //default = ""
}
variable "aws_new_keypair" {
  default = "dennis-web"
}
variable "aws_pubkey_file" {
  default = "/home/kangdw/.ssh/web_admin.pub"
}
variable "aws_pubkey" {
  default = ""
}

variable "private_keyfile" {
  default = "./dennis-key.pem"
}

##########################
# AWS Region Information
##########################

variable "aws_region" {
  default = "ap-northeast-2"
}
variable "aws_avail_zone" {
  default = "ap-northeast-2a"
}
variable "allow_ip" {
  default = "0.0.0.0"
}
variable prefix_node_name {
  default = "extra-node"
}
variable "use-eip" {
  default = "false"
}
##########################
# Instance Information
##########################
variable "mgmt" {
  type = map
  default = {
    instance_type  = "m4.2xlarge"
    node_count     = 1
    disk_count     = 1  // Set 1 or 0
    root_disk_size = 32 // minimum: 16
    root_disk_type = "standard"
    data_disk_size = 10 // minimum: 8
    data_disk_type = "standard"
  }
}
variable "datanode" {
  type = map
  default = {
    instance_type  = "m4.xlarge"
    node_count     = 3          // max 25
    disk_count     = 1          // disk count per 1 datanode, max 8
    root_disk_size = 32         // minimum: 16
    root_disk_type = "standard" // gp2, standard, ...
    data_disk_size = 50         // minimum: 8
    data_disk_type = "standard"
    public_ip_set  = "true"
  }
}

