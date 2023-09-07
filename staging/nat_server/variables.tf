variable "proj_name" {
  description = "Name of project, feel free to rename it. Used to prefix names of AWS resources"
  type        = string
  default     = "ansible4-hashivault"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "nat_config" {
  description = "NAT server configurations"
  type        = any
  default     = {}
}

variable "test_nat_config" {
  description = "test-NAT server configurations"
  type        = any
  default     = {}
}
