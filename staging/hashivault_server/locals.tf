locals {
  proj_name               = var.proj_name
  aws_region              = var.aws_region
  tag_name_private_rtb    = "${local.proj_name}-private"
  tag_name_hashivault_eip = "${local.proj_name}-hashivault"
  hashivault_dynamo_table = var.hashivault_dynamo_table

  hashivault_server_config = var.hashivault_server_config

  tags = {
    Name        = var.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
