terraform {
  required_version = "> 0.12"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}
resource "aws_key_pair" "cluster-keypair" {
  key_name   = var.aws_new_keypair
  public_key = var.aws_pubkey != "" ? var.aws_pubkey : (var.aws_pubkey_file != "" ? file(var.aws_pubkey_file) : "")
  count      = var.aws_new_keypair != "" ? 1 : 0
}

