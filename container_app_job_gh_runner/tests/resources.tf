resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

#tfsec:ignore:azure-keyvault-specify-network-acl
#tfsec:ignore:azure-keyvault-no-purge
resource "azurerm_key_vault" "key_vault" {
  resource_group_name           = azurerm_resource_group.rg.name
  name                          = local.key_vault_name
  sku_name                      = "standard"
  location                      = azurerm_resource_group.rg.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true
  soft_delete_retention_days    = 7
}

resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = local.vnet_name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# module to use
module "runner" {
  source = "../" # change me with module URI

  location  = var.location
  prefix    = var.prefix
  env_short = local.env_short # change me with your env

  # set reference to the secret which holds the GitHub PAT with access to your repos
  key_vault = {
    resource_group_name = azurerm_key_vault.key_vault.resource_group_name
    name                = azurerm_key_vault.key_vault.name
    secret_name         = var.key_vault.secret_name
  }

  # creates a subnet in the specified existing vnet. Use a /23 CIDR block
  network = {
    rg_vnet      = azurerm_virtual_network.vnet.resource_group_name
    vnet         = azurerm_virtual_network.vnet.name
    cidr_subnets = var.network.cidr_subnets
  }

  # set reference to the log analytics workspace you want to use for logging
  environment = {
    customerId = var.environment.customerId
    sharedKey  = var.environment.sharedKey
  }

  # set app properties - especially the list of repos to support
  app = {
    repos      = var.app.repos
    repo_owner = var.app.repo_owner
  }

  tags = var.tags
}
