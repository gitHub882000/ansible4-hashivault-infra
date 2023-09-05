output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "ansible_server_ssh_cmd" {
  description = "SSH to Ansible server with the command: "
  value       = module.ansible_server.server_ssh_cmd
}
