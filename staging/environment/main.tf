provider "aws" {
  region = var.aws_region
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
