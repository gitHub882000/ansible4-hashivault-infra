################################################################################
# EC2 instace
################################################################################
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = [local.ami_name]
  }

  owners = ["amazon"]
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [local.tag_name_vpc]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_name_subnet}*"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${local.name}-key"
  public_key = file(local.public_key_path)

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-${local.name}-key"
    }
  )
}

resource "aws_security_group" "this" {
  name        = local.tags.Name
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-${local.name}-sg"
    }
  )
}

resource "aws_security_group_rule" "ingress_with_cidr_blocks" {
  count             = length(local.ingress_with_cidr_blocks)
  security_group_id = aws_security_group.this.id
  type              = "ingress"

  cidr_blocks = local.ingress_with_cidr_blocks[count.index]["cidr_blocks"]
  description = local.ingress_with_cidr_blocks[count.index]["description"]

  from_port = local.ingress_with_cidr_blocks[count.index]["from_port"]
  to_port   = local.ingress_with_cidr_blocks[count.index]["to_port"]
  protocol  = local.ingress_with_cidr_blocks[count.index]["protocol"]
}

resource "aws_security_group_rule" "egress_with_cidr_blocks" {
  count             = length(local.ingress_with_cidr_blocks)
  security_group_id = aws_security_group.this.id
  type              = "egress"

  cidr_blocks = local.egress_with_cidr_blocks[count.index]["cidr_blocks"]
  description = local.egress_with_cidr_blocks[count.index]["description"]

  from_port = local.egress_with_cidr_blocks[count.index]["from_port"]
  to_port   = local.egress_with_cidr_blocks[count.index]["to_port"]
  protocol  = local.egress_with_cidr_blocks[count.index]["protocol"]
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.image_id
  instance_type                   = local.instance_type
  subnet_id              = data.aws_subnets.this.ids[0]
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = aws_key_pair.this.key_name

  user_data_replace_on_change = true
  user_data                   = local.user_data_filepath == "" ? "" : file(local.user_data_filepath)

  root_block_device {
    delete_on_termination = local.root_block_device.delete_on_termination
    encrypted             = local.root_block_device.encrypted
    iops                  = local.root_block_device.iops
    throughput            = local.root_block_device.throughput
    volume_size           = local.root_block_device.volume_size
    volume_type           = local.root_block_device.volume_type

    tags = merge(
      local.tags,
      {
        "Name" : "${local.tags.Name}-${local.name}-root-volume"
      }
    )
  }

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-${local.name}"
    }
  )
}
