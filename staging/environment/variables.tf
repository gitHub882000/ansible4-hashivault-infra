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
  description = "Local path to the public key for SSH to EC2 instance"
  type        = string
}

variable "ssh_private_path" {
  description = "Local path to the private key for SSH to EC2 instance"
  type        = string
}

variable "playbooks_private_path" {
  description = "Local path to the private key for SSH to Playbooks GitHub"
  type        = string
}

variable "hashivault_key_path" {
  description = "Local path to the private key for Hashicorp Vault TLS"
  type        = string
}

variable "hashivault_cert_path" {
  description = "Local path to the full chain certificate for Hashicorp Vault TLS"
  type        = string
}

variable "ansible_config" {
  description = "Ansible server configurations"
  type = object({
    is_private         = bool
    name               = string
    instance_type      = string
    ami_name           = string
    user_data_filepath = optional(string, null)
    bastion_host       = optional(string, "")
    source_dest_check  = optional(bool, true)

    root_block_device = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = bool
      throughput            = bool
      volume_size           = bool
      volume_type           = string
    })

    ingress_with_cidr_blocks = list(
      object({
        cidr_blocks = list(string)
        description = string
        from_port   = bool
        to_port     = bool
        protocol    = string
      })
    )

    egress_with_cidr_blocks = list(
      object({
        cidr_blocks = list(string)
        description = string
        from_port   = bool
        to_port     = bool
        protocol    = string
      })
    )
  })
}
