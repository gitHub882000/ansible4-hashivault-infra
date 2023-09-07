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

variable "hashivault_dynamo_table" {
  description = "Name of Dynamodb table for Hashicorp Vault storage backend"
  type        = string
  default     = "hashivault"
}

variable "hashivault_server_config" {
  description = "Hashivault server configurations"
  type        = any
  default     = {}
}
