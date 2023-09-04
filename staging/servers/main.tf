provider "aws" {
  region = var.aws_region
}

################################################################################
# Ansible server
################################################################################
module "servers" {
  source = "../modules/ec2_instance"
  count  = length(local.servers_configs)

  proj_name                = local.proj_name
  is_private               = local.servers_configs[count.index]["is_private"]
  name                     = local.servers_configs[count.index]["name"]
  instance_type            = local.servers_configs[count.index]["instance_type"]
  ami_name                 = local.servers_configs[count.index]["ami_name"]
  public_key_path          = local.servers_configs[count.index]["public_key_path"]
  private_key_path         = local.servers_configs[count.index]["private_key_path"]
  root_block_device        = local.servers_configs[count.index]["root_block_device"]
  ingress_with_cidr_blocks = local.servers_configs[count.index]["ingress_with_cidr_blocks"]
  egress_with_cidr_blocks  = local.servers_configs[count.index]["egress_with_cidr_blocks"]
  user_data_filepath       = local.servers_configs[count.index]["user_data_filepath"]
}
