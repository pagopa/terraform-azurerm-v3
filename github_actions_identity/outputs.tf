output "azure_environment_cd" {
  value = {
    app_name       = "${local.app_name}-cd"
    client_id      = azuread_service_principal.environment_cd.application_id
    application_id = azuread_service_principal.environment_cd.application_id
    object_id      = azuread_service_principal.environment_cd.object_id
  }
}

output "azure_environment_runner" {
  value = {
    app_name       = "${local.app_name}-runner"
    client_id      = azuread_service_principal.environment_runner.application_id
    application_id = azuread_service_principal.environment_runner.application_id
    object_id      = azuread_service_principal.environment_runner.object_id
  }
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}
