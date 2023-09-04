locals {
  proj_name  = var.proj_name

  tag_name_vpc    = "${local.proj_name}-vpc"
  tag_name_subnet = "${local.proj_name}-${var.is_private ? "private" : "public"}"

  name             = var.name
  instance_type             = var.instance_type
  ami_name         = var.ami_name
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path

  root_block_device        = var.root_block_device
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.egress_with_cidr_blocks

  user_data_filepath = var.user_data_filepath

  tags = {
    Name        = local.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
