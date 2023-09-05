locals {
  proj_name            = var.proj_name
  aws_region           = var.aws_region
  tag_name_private_rtb = "${local.proj_name}-private"

  servers_configs = var.servers_configs

  tags = {
    Name        = var.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
