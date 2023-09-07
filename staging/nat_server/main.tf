provider "aws" {
  region = local.aws_region
}

# ################################################################################
# Deploy NAT server
################################################################################
module "nat_server" {
  source = "../modules/ec2_instance"

  proj_name                = local.proj_name
  is_private               = local.nat_config["is_private"]
  name                     = local.nat_config["name"]
  instance_type            = local.nat_config["instance_type"]
  ami_name                 = local.nat_config["ami_name"]
  bastion_host             = local.nat_config["bastion_host"]
  source_dest_check        = local.nat_config["source_dest_check"]
  root_block_device        = local.nat_config["root_block_device"]
  ingress_with_cidr_blocks = local.nat_config["ingress_with_cidr_blocks"]
  egress_with_cidr_blocks  = local.nat_config["egress_with_cidr_blocks"]
  user_data_filepath       = local.nat_config["user_data_filepath"]
}

# ################################################################################
# Deploy test-NAT server
################################################################################
module "test_nat_server" {
  source = "../modules/ec2_instance"

  proj_name                = local.proj_name
  name                     = local.test_nat_config["name"]
  is_private               = local.test_nat_config["is_private"]
  instance_type            = local.test_nat_config["instance_type"]
  ami_name                 = local.test_nat_config["ami_name"]
  bastion_host             = local.test_nat_config["bastion_host"]
  source_dest_check        = local.test_nat_config["source_dest_check"]
  root_block_device        = local.test_nat_config["root_block_device"]
  ingress_with_cidr_blocks = local.test_nat_config["ingress_with_cidr_blocks"]
  egress_with_cidr_blocks  = local.test_nat_config["egress_with_cidr_blocks"]
  user_data_filepath       = local.test_nat_config["user_data_filepath"]
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
  network_interface_id   = module.nat_server.primary_network_interface_id
}