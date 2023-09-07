locals {
  proj_name            = var.proj_name
  aws_region           = var.aws_region
  tag_name_private_rtb = "${local.proj_name}-private"

  nat_config      = var.nat_config
  test_nat_config = var.test_nat_config

  tags = {
    Name        = var.proj_name
    Environment = "staging"
    Terraform   = "true"
  }
}
