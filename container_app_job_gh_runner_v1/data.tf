data "azurerm_resource_group" "rg_runner" {
  name = var.environment.resource_group_name # workaround due to TF bug: with a name it fails to find the rg
}

data "azurerm_key_vault" "key_vault" {
  resource_group_name = var.key_vault.resource_group_name
  name                = var.key_vault.name
}

data "azurerm_container_app_environment" "container_app_environment" {
  name                = var.environment.name
  resource_group_name = var.environment.resource_group_name
}
