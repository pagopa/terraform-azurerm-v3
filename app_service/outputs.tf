output "id" {
  value = azurerm_linux_web_app.this.id
}

output "resource_group_name" {
  value = azurerm_linux_web_app.this.resource_group_name
}

output "name" {
  value = azurerm_linux_web_app.this.name
}

output "plan_id" {
  value = var.plan_type == "internal" ? azurerm_service_plan.this[0].id : var.plan_id
}

output "plan_name" {
  value = var.plan_type == "internal" ? azurerm_service_plan.this[0].name : null
}

output "default_site_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "principal_id" {
  value = azurerm_linux_web_app.this.identity[0].principal_id
}

output "custom_domain_verification_id" {
  value = azurerm_linux_web_app.this.custom_domain_verification_id
}
