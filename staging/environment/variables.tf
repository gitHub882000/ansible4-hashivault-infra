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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "Number of AZs to span takes the minimum between num_azs and number of available AZs in the region"
  type        = number
  default     = 3
}

variable "ssh_public_path" {
  description = "Path to the public key for SSH to EC2 instance"
  type        = string
}

variable "ssh_private_path" {
  description = "Path to the private key for SSH to EC2 instance"
  type        = string
}

variable "ansible_config" {
  description = "Ansible server configurations"
  type        = any
  default     = {}
}
