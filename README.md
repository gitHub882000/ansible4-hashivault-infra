# Terraform for Ansible, NAT, and Hashicorp Vault EC2 instances

## Problem statement

Your objective is to utilize Terraform (AWS provider only) and Ansible to establish the following infrastructure components. While you're
restricted from using external modules in Terraform, you can leverage external modules for Ansible as needed:

1. Virtual Private Cloud (VPC) – Create a VPC that meets to the following requirements:
   - 3 public subnets spread across different Availability Zones
   - 3 private subnets spread across different Availability Zones
2. Network Address Translation (NAT) Instance – Utilize Ansible to provision a NAT instance.
3. Self-Managed HashiCorp Vault Standalone Instance:

   Use Ansible to establish a standalone HashiCorp Vault instance with the specified attributes:

   - Integrate the DynamoDB backend for secure storage.
   - Implement SSL for secure communication.

## About this repository

This repository utilizes Terraform (AWS provider only) to establish the following infrastructure components:

1. Virtual Private Cloud (VPC) – Create a VPC that meets to the following requirements:
   - 3 public subnets spread across different Availability Zones
   - 3 private subnets spread across different Availability Zones
2. EC2 Instance that serves both as bastion host and Ansible controller
3. EC2 Instance that serves Network Address Translation (NAT)
4. EC2 Instance in a private subnet to test NAT instance
5. EC2 Instance that hosts Self-Managed HashiCorp Vault Standalone

Having completely deployed the AWS infrastructure using this repository, you can move to [Ansible playbooks repository](https://github.com/gitHub882000/ansible4-hashivault-playbooks) for further configuring the servers.

## Directory structure

The overall directory structure of the project is as follow:

```
production/
├─ .../
staging/
├─ assets/
│  ├─ ...
├─ environment/
│  ├─ main.tf
│  ├─ ...
├─ hashivault_server/
│  ├─ main.tf
│  ├─ ...
├─ modules/
│  ├─ ec2_instance/
│  │  ├─ main.tf
│  │  ├─ ...
│  ├─ ...
├─ nat_server/
│  ├─ main.tf
│  ├─ ...
```

Where `develop`, `staging/`, and `production/` represents the workload environment. Each environment directory has nearly the same structure as follows:

1. `assets/` contains utilities that are referenced by Terraform modules. For example, `setup_bastion.sh` helps to setup secret keys, AWS CLI, and Ansible on the bastion host.
2. `environment/` is a Terraform root module that deploys:

   1. VPC with 3 public and private subnets spread across different Availability Zones.
   2. AWS Secrets Manager which keeps the following keys:

      - Keys to SSH for each EC2 instance.
      - Private key that allows bastion host to download Ansible playbooks from GitHub repository.
      - Full chain certificate and private key to support Hashicorp Vault TLS configuration.

      Following security best practices, the secret keys are generated and managed outside of Terraform code and loaded to AWS Secrets Manager. This helps separating confidential assets from the infrastructure code.

   3. EC2 instance as bastion host which downloads AWS Secrets Manager secrets, configures AWS CLI and Ansible on its first bootstrap.

   This module **MUST BE RUN FIRST** before any others so as to bootstrap the AWS environment.

3. `hashivault_server/` is a Terraform root module that deploys:

   1. EC2 instance as Hashicorp Vault standalone instance with necessary IAM permissions to download TLS certificates from AWS Secrets Manager and connect to DynamoDB table.
   2. DynamoDB as backend storage.

4. `nat_server/` is a Terraform root module that deploys:

   1. EC2 instance as NAT instance.
   2. EC2 instance in private subnet to validate the success of NAT configuration.

5. `modules/` contains all the Terraform modules that are leveraged by the other root modules. In this directory, only `ec2_instance/` module is presented, which spinups EC2 instance based on the input variables. Note that there is one strange variable `bastion_host` in the module. `bastion_host` is the bastion host's name to allow SSH access. In the future, this could be improved by fetching resource from AWS using `data` in Terraform.

## Instructions

### Prerequisites

These are the prerequisites to run the codes:

- Terraform v1.5.0
- The server that runs this code needs `FullAccess` permissions. This will be restricted in the future!

### How to run

1. Change your current working directory into this repository:

```
cd <path-to-repository>
```

2. Download the secret keys for this solution from the S3 URI `s3://ansible4-hashivault-tfstates/assets/.confidential/`, where:

   1. `ssh_private.pem` and `ssh_public.pem.pub` is the private and public key used to setup SSH to every EC2 instance in the system. In the future, each EC2 instance should have its own SSH key pair.

   2. `playbooks_private.pem` and `playbooks_private.pem.pub` is the private and public key used to setup SSH to the GitHub repository. This enables the bastion host to clone the playbook repository.

   3. `lab.aandd.io/fullchain.cer` and `lab.aandd.io/lab.aandd.io.key` is the full chain certificate and private key to setup TLS encryption for Hashicorp Vault server.

3. The `terraform.tfvars` files which were used to deploy infrastructure are saved in this S3 URI `s3://ansible4-hashivault-tfstates/assets/tfvars/`. Download the files and move the `terraform.tfvars` into each Terraform root module. For example:

```
mv <download-path-of-environment/terraform.tfvars-from-s3>/terraform.tfvars <path-to-repository>/staging/environment/terraform.tfvars
```

4. Modify the `ssh_public_path`, `ssh_private_path`, `playbooks_private_path`, `hashivault_key_path`, and `hashivault_cert_path` in `staging/environment/terraform.tfvars` to the respective paths of keys that you downloaded in step 1.

5. Run the following commands in the `environment/` root module. After the environment is fully deployed, run the same set of commands for `hashivault_server/` and `nat_server/` in any order:

```
terraform init
terraform plan

# Check the plan and apply
terraform apply --auto-approve
```

5. Take note of all the EC2 instance's public IP (if bastion host) and private IP.

6. SSH to the bastion host and start running Ansible.

## Some considerations

1. With the current requirements, the Hashicorp Vault server is assumed to be accessed from anywhere on port `8200`.

2. The schema for some Terraform variables is vague. `hashivault_server_config` variable of the `hashivault_server/` is a prime example of this. In the future, it would be structured more explicitly using the `object` data type.

```
variable "hashivault_server_config" {
  description = "Hashivault server configurations"
  type        = any
  default     = {}
}
```
