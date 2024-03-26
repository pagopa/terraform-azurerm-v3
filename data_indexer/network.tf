resource "azurerm_subnet" "this" {
  name                                          = "${var.name}-di-snet"
  resource_group_name                           = var.virtual_network.resource_group_name
  virtual_network_name                          = var.virtual_network.name
  address_prefixes                              = var.subnet.address_prefixes
  service_endpoints                             = var.subnet.service_endpoints
  private_link_service_network_policies_enabled = true
  private_endpoint_network_policies_enabled     = true
  delegation {
    name = "default"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}