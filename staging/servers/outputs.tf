output "servers_ssh_cmd" {
  description = "SSH to servers with the command: "
  value       = {for k, v in module.servers: k => v.server_ssh_cmd}
}
