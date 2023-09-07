provider "aws" {
  region = local.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_eips" "hashivault" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_name_hashivault_eip}*"]
  }
}

################################################################################
# Deploy Dynamodb storage backend
################################################################################
resource "aws_dynamodb_table" "hashivault" {
  name           = local.hashivault_dynamo_table
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Path"
  range_key      = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = merge(
    local.tags,
    {
      "Name" : "${local.tags.Name}-${local.hashivault_dynamo_table}-dynamo-table"
    }
  )
}

################################################################################
# Deploy necessary IAM profile
################################################################################
resource "aws_iam_policy" "dynamodb" {
  name        = "${local.proj_name}-dynamodb-policy"
  description = "Provides permission to Dynamodb storage backend"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "dynamodb:DescribeReservedCapacityOfferings",
          "dynamodb:DescribeReservedCapacity",
          "dynamodb:ListTables",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:CreateTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:GetRecords",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.hashivault.arn
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "secretsmanager" {
  name        = "${local.proj_name}-tls-secretsmanager-policy"
  description = "Provides permission to retrieve TLS certs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${local.proj_name}*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "hashivault" {
  name = "${local.proj_name}-hashivault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "hashivault_dynamodb" {
  name       = "${local.proj_name}-hashivault-dynamodb-attachment"
  roles      = [aws_iam_role.hashivault.name]
  policy_arn = aws_iam_policy.dynamodb.arn
}

resource "aws_iam_policy_attachment" "hashivault_secretsmanager" {
  name       = "${local.proj_name}-hashivault-secretsmanager-attachment"
  roles      = [aws_iam_role.hashivault.name]
  policy_arn = aws_iam_policy.secretsmanager.arn
}

resource "aws_iam_instance_profile" "hashivault_profile" {
  name = "${local.proj_name}-hashivault-profile"
  role = aws_iam_role.hashivault.name
}

################################################################################
# Deploy Hashicorp Vault server
################################################################################
module "hashivault_server" {
  source = "../modules/ec2_instance"

  proj_name                = local.proj_name
  is_private               = local.hashivault_server_config["is_private"]
  name                     = local.hashivault_server_config["name"]
  instance_type            = local.hashivault_server_config["instance_type"]
  ami_name                 = local.hashivault_server_config["ami_name"]
  bastion_host             = local.hashivault_server_config["bastion_host"]
  source_dest_check        = local.hashivault_server_config["source_dest_check"]
  root_block_device        = local.hashivault_server_config["root_block_device"]
  ingress_with_cidr_blocks = local.hashivault_server_config["ingress_with_cidr_blocks"]
  egress_with_cidr_blocks  = local.hashivault_server_config["egress_with_cidr_blocks"]
  user_data_filepath       = local.hashivault_server_config["user_data_filepath"]
  instance_profile_name    = aws_iam_instance_profile.hashivault_profile.name
}

resource "aws_eip_association" "hashivault_eip_association" {
  instance_id   = module.hashivault_server.instance_id
  allocation_id = data.aws_eips.hashivault.allocation_ids[0]
}
