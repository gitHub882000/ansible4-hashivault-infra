output "servers_ssh_cmd" {
  description = "SSH to servers with the command: "
  value       = zipmap(module.servers[*].server_name, module.servers[*].server_ssh_cmd)
}
