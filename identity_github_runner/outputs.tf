output "user_managed_identity" {
  value = {
    resource_group_name = azurerm_user_assigned_identity.identity.resource_group_name
    app_name            = azurerm_user_assigned_identity.identity.name
    client_id           = azurerm_user_assigned_identity.identity.client_id
    object_id           = azurerm_user_assigned_identity.identity.principal_id
  }
}
