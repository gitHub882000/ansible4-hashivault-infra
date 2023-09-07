output "nat_server_ssh_cmd" {
  description = "SSH to NAT server with the command: "
  value       = module.nat_server.server_ssh_cmd
}

output "test_nat_server_ssh_cmd" {
  description = "SSH to test-NAT server with the command: "
  value       = module.test_nat_server.server_ssh_cmd
}
