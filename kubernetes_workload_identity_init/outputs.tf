output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.this.id
}

output "user_assigned_identity_name" {
  value = azurerm_user_assigned_identity.this.name
}

output "user_assigned_identity_resource_group_name" {
  value = azurerm_user_assigned_identity.this.resource_group_name
}

output "user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}

output "user_assigned_identity_client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "workload_identity_principal_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}

