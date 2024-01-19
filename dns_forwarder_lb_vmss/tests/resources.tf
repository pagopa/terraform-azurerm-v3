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

module "dns_forwarder_lb_vmss" {
  source = "../../dns_forwarder_lb_vmss"

  name                 = var.prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  subscription_id      = data.azurerm_subscription.current.subscription_id
  source_image_name    = var.source_image_name
  tenant_id            = data.azurerm_client_config.current.tenant_id

  tags = var.tags
}
