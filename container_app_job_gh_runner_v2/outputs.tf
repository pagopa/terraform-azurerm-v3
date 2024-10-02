output "id" {
  value       = azurerm_container_app_job.container_app_job.id
  description = "Container App job id"
}

output "name" {
  value       = azurerm_container_app_job.container_app_job.name
  description = "Container App job name"
}

output "resource_group_name" {
  value       = data.azurerm_resource_group.rg_runner.name
  description = "Container App job resource group name"
}
