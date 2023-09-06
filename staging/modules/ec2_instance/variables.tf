variable "proj_name" {
  description = "Name of project, feel free to rename it. Used to prefix names of AWS resources"
  type        = string
  default     = "ansible4-hashivault"
}

variable "is_private" {
  description = "Whether the EC2 instance is in private subnet"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of EC2 instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "ami_name" {
  description = "Path to the public key for SSH to EC2 instance"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"
}

variable "root_block_device" {
  description = "Root block device of EC2 instance"
  type        = any
  default     = {}
}

variable "bastion_host" {
  description = "Name of the Bastion Host to allow SSH access"
  type        = string
  default     = ""
}

variable "ingress_with_cidr_blocks" {
  description = "Security group ingress rules of EC2 instance with CIDR blocks"
  type        = list(any)
  default     = []
}

variable "egress_with_cidr_blocks" {
  description = "Security group egress rules of EC2 instance with CIDR blocks"
  type        = list(any)
  default     = []
}

variable "user_data_filepath" {
  description = "Path to the EC2 instance User Data bash file"
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Name of IAM instance profile"
  type        = string
  default     = null
}

variable "source_dest_check" {
  description = "Enable source destination check"
  type        = bool
  default     = true
}
