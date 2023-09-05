provider "aws" {
  region = local.aws_region
}

################################################################################
# Spinup NAT, test-NAT, and Hashicorp Vault server
################################################################################
module "servers" {
  source = "../modules/ec2_instance"
  count  = length(local.servers_configs)

  proj_name                = local.proj_name
  is_private               = local.servers_configs[count.index]["is_private"]
  name                     = local.servers_configs[count.index]["name"]
  instance_type            = local.servers_configs[count.index]["instance_type"]
  ami_name                 = local.servers_configs[count.index]["ami_name"]
  bastion_host             = local.servers_configs[count.index]["bastion_host"]
  source_dest_check        = local.servers_configs[count.index]["source_dest_check"]
  root_block_device        = local.servers_configs[count.index]["root_block_device"]
  ingress_with_cidr_blocks = local.servers_configs[count.index]["ingress_with_cidr_blocks"]
  egress_with_cidr_blocks  = local.servers_configs[count.index]["egress_with_cidr_blocks"]
  user_data_filepath       = local.servers_configs[count.index]["user_data_filepath"]
}

################################################################################
# Modify private subnets' route tables for NAT
################################################################################
# data "aws_route_tables" "private" {
#   filter {
#     name   = "tag:Name"
#     values = ["${local.tag_name_private_rtb}*"]
#   }
# }

# data "aws_instances" "nat" {
#   filter {
#     name   = "tag:Name"
#     values = ["nat*"]
#   }
#   depends_on = [
#     module.servers
#   ]
# }

# resource "aws_route" "public_nat" {
#   count                  = length(data.aws_route_tables.private.ids)
#   route_table_id         = data.aws_route_tables.private.ids[count.index]
#   destination_cidr_block = "0.0.0.0/0"
#   instance_id            = data.aws_instances.nat.ids[0]
# }
