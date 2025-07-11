# Outputs for Ansible dynamic inventory
output "client_ips" {
  description = "Map of client VM names to their IP addresses"
  value       = local.client_ips
}

output "gateway_internet_ips" {
  description = "Map of gateway VM names to their internet IP addresses"
  value       = local.gateway_internet_ips
}

output "gateway_intranet_ips" {
  description = "Map of gateway VM names to their intranet IP addresses"
  value       = local.gateway_intranet_ips
}
