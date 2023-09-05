locals {
  proj_name    = var.proj_name
  is_private   = var.is_private
  bastion_host = var.bastion_host

  tag_name_vpc        = "${local.proj_name}-vpc"
  tag_name_subnet     = "${local.proj_name}-${local.is_private ? "private" : "public"}"
  tag_bastion_host_sg = "${local.proj_name}-${local.bastion_host}"

  name              = var.name
  instance_type     = var.instance_type
  ami_name          = var.ami_name
  source_dest_check = var.source_dest_check

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
