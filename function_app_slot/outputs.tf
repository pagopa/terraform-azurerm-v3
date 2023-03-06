output "id" {
  value = azurerm_linux_function_app_slot.this.id
}

output "name" {
  value = azurerm_linux_function_app_slot.this.name
}

output "default_hostname" {
  value     = azurerm_linux_function_app_slot.this.default_hostname
  sensitive = true
}

output "possible_outbound_ip_addresses" {
  value = azurerm_linux_function_app_slot.this.possible_outbound_ip_addresses
}

output "default_key" {
  value     = var.export_keys ? data.azurerm_function_app_host_keys.this[0].default_function_key : null
  sensitive = true
}

output "master_key" {
  value     = var.export_keys ? data.azurerm_function_app_host_keys.this[0].primary_key : null
  sensitive = true
}

output "primary_key" {
  value     = var.export_keys ? data.azurerm_function_app_host_keys.this[0].primary_key : null
  sensitive = true
}
