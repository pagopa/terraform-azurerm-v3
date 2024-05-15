output "random_id" {
  value = random_id.unique.hex
}

output "subnet_name" {
  value       = azurerm_subnet.subnet.name
  description = "Subnet name"
}

output "subnet_cidr" {
  value       = azurerm_subnet.subnet.address_prefixes
  description = "Subnet CIDR blocks"
}

output "cae_name" {
  value       = azurerm_container_app_environment.container_app_environment.name
  description = "Container App Environment name"
}

output "ca_name" {
  value       = module.container_app_job_runner.name
  description = "Container App job name"
}
