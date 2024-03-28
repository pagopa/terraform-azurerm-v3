output "id" {
  value = azapi_resource.container_app_environment.id
}

output "resource_group_name" {
  value = azurerm_container_app_environment.container_app_environment.parent_id
}

output "name" {
  value = azurerm_container_app_environment.container_app_environment.name
}
