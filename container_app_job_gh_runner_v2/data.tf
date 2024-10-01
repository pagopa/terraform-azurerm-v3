data "azurerm_resource_group" "rg_runner" {
  name = var.environment_rg # workaround due to TF bug: with a name it fails to find the rg
}

data "azurerm_key_vault" "key_vault" {
  resource_group_name = var.key_vault_rg
  name                = var.key_vault_name
}

data "azurerm_container_app_environment" "container_app_environment" {
  name                = var.environment_name
  resource_group_name = var.environment_rg
}
