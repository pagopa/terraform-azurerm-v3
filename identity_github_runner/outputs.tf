output "identity_resource_group" {
  value       = azurerm_user_assigned_identity.identity.resource_group_name
  description = "User Managed Identity resource group"
}

output "identity_app_name" {
  value       = azurerm_user_assigned_identity.identity.name
  description = "User Managed Identity name"
}

output "identity_client_id" {
  value       = azurerm_user_assigned_identity.identity.client_id
  description = "User Managed Identity client id"
}

output "identity_principal_id" {
  value       = azurerm_user_assigned_identity.identity.principal_id
  description = "User Managed Identity principal id"
}
