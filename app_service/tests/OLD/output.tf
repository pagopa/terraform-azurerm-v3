output "login_server" {
  value = azurerm_container_registry.reg.login_server
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}