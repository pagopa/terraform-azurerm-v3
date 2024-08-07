resource "azurerm_virtual_network_peering" "source" {
  name                      = var.source_custom_name == null ? format("%s-to-%s", var.source_virtual_network_name, var.target_virtual_network_name) : var.source_custom_name
  resource_group_name       = var.source_resource_group_name
  virtual_network_name      = var.source_virtual_network_name
  remote_virtual_network_id = var.target_remote_virtual_network_id

  allow_virtual_network_access = var.source_allow_virtual_network_access
  allow_forwarded_traffic      = var.source_allow_forwarded_traffic
  allow_gateway_transit        = var.source_allow_gateway_transit
  use_remote_gateways          = var.source_use_remote_gateways
}

resource "azurerm_virtual_network_peering" "target" {
  name                      = var.target_custom_name == null ? format("%s-to-%s", var.target_virtual_network_name, var.source_virtual_network_name) : var.target_custom_name
  resource_group_name       = var.target_resource_group_name
  virtual_network_name      = var.target_virtual_network_name
  remote_virtual_network_id = var.source_remote_virtual_network_id

  allow_virtual_network_access = var.target_allow_virtual_network_access
  allow_forwarded_traffic      = var.target_allow_forwarded_traffic
  allow_gateway_transit        = var.target_allow_gateway_transit
  use_remote_gateways          = var.target_use_remote_gateways
}
