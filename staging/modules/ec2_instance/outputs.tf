output "server_name" {
  description = "Name of the EC2 instance: "
  value       = "${local.tags.Name}-${local.name}"
}

output "server_ssh_cmd" {
  description = "SSH to server with the command: "
  value       = "ssh -i key-pair.pem ubuntu@${local.bastion_host == "" ? aws_instance.this.public_ip : aws_instance.this.private_ip}"
}
