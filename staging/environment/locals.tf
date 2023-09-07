data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  proj_name  = var.proj_name
  aws_region = var.aws_region

  vpc_cidr = var.vpc_cidr
  num_azs  = min(length(data.aws_availability_zones.available.names), var.num_azs)
  azs      = slice(data.aws_availability_zones.available.names, 0, local.num_azs)

  ssh_private_path       = var.ssh_private_path
  ssh_public_path        = var.ssh_public_path
  playbooks_private_path = var.playbooks_private_path
  hashivault_key_path    = var.hashivault_key_path
  hashivault_cert_path   = var.hashivault_cert_path

  ansible_config = var.ansible_config

  tags = {
    Name        = local.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
