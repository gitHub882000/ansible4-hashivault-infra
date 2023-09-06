provider "aws" {
  region = local.aws_region
}

################################################################################
# Spinup NAT, test-NAT, and Hashicorp Vault server
################################################################################
module "servers" {
  source   = "../modules/ec2_instance"
  for_each = zipmap(local.servers_configs[*]["name"], local.servers_configs[*])

  proj_name                = local.proj_name
  is_private               = each.value["is_private"]
  name                     = each.value["name"]
  instance_type            = each.value["instance_type"]
  ami_name                 = each.value["ami_name"]
  bastion_host             = each.value["bastion_host"]
  source_dest_check        = each.value["source_dest_check"]
  root_block_device        = each.value["root_block_device"]
  ingress_with_cidr_blocks = each.value["ingress_with_cidr_blocks"]
  egress_with_cidr_blocks  = each.value["egress_with_cidr_blocks"]
  user_data_filepath       = each.value["user_data_filepath"]
}

################################################################################
# Modify private subnets' route tables for NAT
################################################################################
data "aws_route_tables" "private" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_name_private_rtb}*"]
  }
}

resource "aws_route" "public_nat" {
  count                  = length(data.aws_route_tables.private.ids)
  route_table_id         = data.aws_route_tables.private.ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.servers["nat"].primary_network_interface_id
}
