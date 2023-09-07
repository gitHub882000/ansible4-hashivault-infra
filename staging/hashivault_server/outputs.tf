output "hashivault_server_ssh_cmd" {
  description = "SSH to Hashicorp Vault server with the command: "
  value       = module.hashivault_server.server_ssh_cmd
}
