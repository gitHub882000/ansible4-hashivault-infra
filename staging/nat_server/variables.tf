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
      iops                  = number
      throughput            = number
      volume_size           = number
      volume_type           = string
    })

    ingress_with_cidr_blocks = list(
      object({
        cidr_blocks = list(string)
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
      })
    )

    egress_with_cidr_blocks = list(
      object({
        cidr_blocks = list(string)
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
      })
    )
  })
}

variable "test_nat_config" {
  description = "test-NAT server configurations"
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
      iops                  = number
      throughput            = number
      volume_size           = number
      volume_type           = string
    })

    ingress_with_cidr_blocks = list(
      object({
        cidr_blocks = list(string)
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
      })
    )

    egress_with_cidr_blocks = list(
      object({
        cidr_blocks = list(string)
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
      })
    )
    }
  )
}
