resource "azurerm_resource_group" "rg_runner" {
  name     = local.rg_name
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = local.law_name
  location            = azurerm_resource_group.rg_runner.location
  resource_group_name = azurerm_resource_group.rg_runner.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

#tfsec:ignore:azure-keyvault-specify-network-acl
#tfsec:ignore:azure-keyvault-no-purge
resource "azurerm_key_vault" "key_vault" {
  resource_group_name           = azurerm_resource_group.rg_runner.name
  name                          = local.key_vault_name
  sku_name                      = "standard"
  location                      = azurerm_resource_group.rg_runner.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true
  soft_delete_retention_days    = 7

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg_runner.name
  name                = local.vnet_name
  location            = azurerm_resource_group.rg_runner.location
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg_runner.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/23"]
}

resource "azurerm_container_app_environment" "container_app_environment" {
  name                           = local.environment_name
  resource_group_name            = azurerm_resource_group.rg_runner.name
  location                       = azurerm_resource_group.rg_runner.location
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  infrastructure_subnet_id       = azurerm_subnet.subnet.id
  zone_redundancy_enabled        = false
  internal_load_balancer_enabled = true

  tags = var.tags
}

# module to use
module "container_app_job_runner" {
  source = "../" # change me with module URI

  location            = var.location
  resource_group_name = local.rg_name
  prefix              = var.prefix
  env_short           = substr(random_id.unique.hex, 0, 1) # change me with your env

  # sets reference to the secret which holds the GitHub PAT with access to your repos
  key_vault = {
    resource_group_name = azurerm_key_vault.key_vault.resource_group_name
    name                = azurerm_key_vault.key_vault.name
    secret_name         = var.key_vault.secret_name
  }

  # sets reference to the log analytics workspace you want to use for logging
  environment = {
    name                = azurerm_container_app_environment.container_app_environment.name
    resource_group_name = azurerm_container_app_environment.container_app_environment.resource_group_name
  }

  # sets job properties
  job = var.job

  tags = var.tags
}
