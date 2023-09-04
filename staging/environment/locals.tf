data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  vpc_cidr = var.vpc_cidr
  num_azs  = min(length(data.aws_availability_zones.available.names), var.num_azs)
  azs      = slice(data.aws_availability_zones.available.names, 0, local.num_azs)

  tags = {
    Name        = var.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
