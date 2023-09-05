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

  private_key_path = var.private_key_path
  public_key_path  = var.public_key_path

  ansible_config = var.ansible_config

  tags = {
    Name        = local.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
