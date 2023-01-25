
resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  dynamic "delegation" {
    for_each = var.delegation == null ? [] : ["delegation"]
    content {
      name = var.delegation.name

      service_delegation {
        name    = var.delegation.service_delegation.name
        actions = var.delegation.service_delegation.actions
      }
    }
  }

  service_endpoints = var.service_endpoints

  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
}
