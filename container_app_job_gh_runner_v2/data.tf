data "azurerm_resource_group" "rg_runner" {
  name = var.container_app_environment_rg_name
}

data "azurerm_container_app_environment" "container_app_environment" {
  name                = var.container_app_environment_name
  resource_group_name = var.container_app_environment_rg_name
}

# data "azurerm_key_vault" "key_vault" {
#   resource_group_name = var.key_vault.resource_group_name
#   name                = var.key_vault.name
# }
