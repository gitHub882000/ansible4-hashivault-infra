output "server_name" {
  description = "Name of the EC2 instance: "
  value       = "${local.tags.Name}-${local.name}"
}

output "server_ssh_cmd" {
  description = "SSH to server with the command: "
  value       = "ssh -i ${local.private_key_path} ubuntu@${aws_instance.this.public_ip}"
}
