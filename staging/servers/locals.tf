locals {
  proj_name  = var.proj_name
  aws_region = var.aws_region

  servers_configs = var.servers_configs

  tags = {
    Name        = var.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
