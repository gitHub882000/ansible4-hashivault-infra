provider "aws" {
  region = local.aws_region
}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-vpc"
    }
  )
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-igw"
    }
  )
}

################################################################################
# Publiс Subnets
################################################################################
resource "aws_subnet" "public" {
  count                   = local.num_azs
  cidr_block              = cidrsubnet(local.vpc_cidr, 6, count.index)
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-public-${element(local.azs, count.index)}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-public"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = local.num_azs
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

################################################################################
# Private Subnets
################################################################################
resource "aws_subnet" "private" {
  count             = local.num_azs
  cidr_block        = cidrsubnet(local.vpc_cidr, 6, count.index + 10)
  availability_zone = element(local.azs, count.index)
  vpc_id            = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-private-${element(local.azs, count.index)}"
    }
  )
}

# There are as many routing tables as the number of private subnets
resource "aws_route_table" "private" {
  count  = local.num_azs
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-private-${element(local.azs, count.index)}"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = local.num_azs

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}

################################################################################
# Store SSH key-pair with Secrets Manager
# There should be multiple key-pairs corresponding to multiple servers
# However, for the purpose of simplifying this lab, only 1 key-pair will be used
#   for all servers
################################################################################
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "ssh_private" {
  name                    = "${local.proj_name}-ssh-private"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "ssh_private" {
  secret_id     = aws_secretsmanager_secret.ssh_private.id
  secret_string = file(local.private_key_path)
}

resource "aws_secretsmanager_secret" "ssh_public" {
  name                    = "${local.proj_name}-ssh-public"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "ssh_public" {
  secret_id     = aws_secretsmanager_secret.ssh_public.id
  secret_string = file(local.public_key_path)
}

################################################################################
# Ansible server
################################################################################
module "ansible_server" {
  source = "../modules/ec2_instance"

  proj_name                = local.proj_name
  is_private               = local.ansible_config["is_private"]
  name                     = local.ansible_config["name"]
  instance_type            = local.ansible_config["instance_type"]
  ami_name                 = local.ansible_config["ami_name"]
  root_block_device        = local.ansible_config["root_block_device"]
  ingress_with_cidr_blocks = local.ansible_config["ingress_with_cidr_blocks"]
  egress_with_cidr_blocks  = local.ansible_config["egress_with_cidr_blocks"]
  user_data_filepath       = local.ansible_config["user_data_filepath"]
}
