resource "azurerm_dashboard_grafana" "this" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  api_key_enabled                   = var.api_key_enabled
  deterministic_outbound_ip_enabled = var.deterministic_outbound_ip_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  sku                               = var.sku
  zone_redundancy_enabled           = var.zone_redundancy_enabled

  identity {
    type = var.identity_type
  }

  tags = var.tags
}
