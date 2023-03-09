output "id" {
  value = azurerm_linux_web_app_slot.this.id
}

output "name" {
  value = azurerm_linux_web_app_slot.this.name
}

output "default_site_hostname" {
  value = azurerm_linux_web_app_slot.this.default_hostname
}

output "principal_id" {
  value = azurerm_linux_web_app_slot.this.identity[0].principal_id
}
