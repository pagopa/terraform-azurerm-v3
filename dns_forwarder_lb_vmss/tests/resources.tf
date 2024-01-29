resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

#tfsec:ignore:azure-keyvault-no-purge
resource "azurerm_key_vault" "this" {
  name                     = "${var.prefix}-kv"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.location
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow" #tfsec:ignore:AZU020
  }
}

module "dns_forwarder_lb_vmss" {
  source = "../../dns_forwarder_lb_vmss"

  name                 = var.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  subscription_id      = data.azurerm_subscription.current.subscription_id
  source_image_name    = var.source_image_name
  tenant_id            = data.azurerm_client_config.current.tenant_id
  key_vault_id         = azurerm_key_vault.this.id

  tags = var.tags
}
