variable "access_key" {
  default = ""
}
variable "secret_key" {
  default = ""
}
variable "region" {
  default = "ap-northeast-2"
}
variable "avail_zone" {
  default = "ap-northeast-2a"
}

variable "mgmt_type" {
  default = "m4.2xlarge"
}
variable "datanode" {
  type = map
  default = {
    node_count    = 3
    disk_count    = 3 // disk count per 1 datanode
    disk_size     = 100
    disk_type     = "standard"
    instance_type = "m4.xlarge"
  }
}

variable "data_volume_device_list" {
  description = "device list for EC2 mapping"
  type        = list
  default = ["/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi"
    , "/dev/xvdj", "/dev/xvdk", "/dev/xvdl", "/dev/xvdm"
  ]
}

variable "mgmt_images" {
  type = map
  default = {
    ap-northeast-2a = "ami-0bb608e95cd598686"
  }
}
variable "dn_images" {
  type = map
  default = {
    ap-northeast-2a = "ami-0bb608e95cd598686"
  }
}
variable "zones" {
  type    = list
  default = ["ap-northeast-2a"]
}


variable "vpc_cidr" {
  default = "172.16.0.0/16"
}
variable "subnet_cidr" {
  default = "172.16.101.0/24"
}



variable "mgmt_private_ip" {
  type = list
  default = [
    "172.16.101.10"
  ]
}
variable "dn_private_ip" {
  type = list
  default = [
    "172.16.101.11"
    , "172.16.101.12"
    , "172.16.101.13"
    , "172.16.101.14"
    , "172.16.101.15"
    , "172.16.101.16"
    , "172.16.101.17"
    , "172.16.101.18"
    , "172.16.101.19"
    , "172.16.101.20"
    , "172.16.101.21"
    , "172.16.101.22"
    , "172.16.101.23"
    , "172.16.101.24"
    , "172.16.101.25"
  ]
}
variable "mgmt_hostname" {
  type = list
  default = [
    "mgmt.test.com"
  ]
}
variable "dn_hostname" {
  type = list
  default = [
    "dn01.test.com"
    , "dn02.test.com"
    , "dn03.test.com"
    , "dn04.test.com"
    , "dn05.test.com"
    , "dn06.test.com"
    , "dn07.test.com"
    , "dn08.test.com"
    , "dn09.test.com"
    , "dn10.test.com"
    , "dn11.test.com"
    , "dn12.test.com"
    , "dn13.test.com"
    , "dn14.test.com"
    , "dn15.test.com"
    , "dn16.test.com"
    , "dn17.test.com"
    , "dn18.test.com"
    , "dn19.test.com"
    , "dn20.test.com"
    , "dn21.test.com"
    , "dn22.test.com"
    , "dn23.test.com"
    , "dn24.test.com"
    , "dn25.test.com"
  ]
}
