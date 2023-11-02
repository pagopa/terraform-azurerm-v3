output "resource_group" {
  value       = azurerm_resource_group.runner_rg.name
  description = "Resource group name"
}

output "subnet_name" {
  value       = azurerm_subnet.runner_subnet.name
  description = "Subnet name"
}

output "subnet_cidr" {
  value       = azurerm_subnet.runner_subnet.address_prefixes
  description = "Subnet CIDR blocks"
}

output "cae_name" {
  value       = azapi_resource.runner_environment.name
  description = "Container App Environment name"
}

output "ca_name" {
  value       = azapi_resource.runner_job.name
  description = "Container App job name"
}
