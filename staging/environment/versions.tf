terraform {
  required_version = "~> 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15.0"
    }
  }

  backend "s3" {
    bucket         = "ansible4-hashivault-tfstates"
    key            = "environment/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "ansible4-hashivault-tflocks"
  }
}
