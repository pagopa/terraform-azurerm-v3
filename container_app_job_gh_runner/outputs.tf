output "subnet_name" {
  value       = azurerm_subnet.runner_subnet.name
  description = "Subnet name"
}

output "subnet_cidr" {
  value       = azurerm_subnet.runner_subnet.address_prefixes
  description = "Subnet CIDR blocks"
}

output "cae_id" {
  value       = azurerm_container_app_environment.container_app_environment.id
  description = "Container App Environment id"
}

output "cae_name" {
  value       = azurerm_container_app_environment.container_app_environment.name
  description = "Container App Environment name"
}

output "ca_id" {
  value       = azapi_resource.runner_job.id
  description = "Container App job id"
}

output "ca_name" {
  value       = azapi_resource.runner_job.name
  description = "Container App job name"
}
