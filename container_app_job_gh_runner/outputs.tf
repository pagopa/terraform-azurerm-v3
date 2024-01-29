output "id" {
  value       = azapi_resource.container_app_job.id
  description = "Container App job id"
}

output "name" {
  value       = azapi_resource.container_app_job.name
  description = "Container App job name"
}

output "resource_group_name" {
  value       = data.azurerm_resource_group.rg_runner.name
  description = "Container App job resource group name"
}
