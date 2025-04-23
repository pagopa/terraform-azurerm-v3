



resource "azurerm_network_security_group" "custom_nsg" {
  for_each = var.custom_security_group

  name                = "${var.prefix}-${each.key}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags

}


resource "azurerm_network_security_rule" "custom_security_rule" {
  for_each = { for sr in local.security_rules : "${sr.nsg_name}-${sr.name}" => sr }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  source_port_ranges           = each.value.source_port_ranges
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes

  resource_group_name = var.resource_group_name

  network_security_group_name = azurerm_network_security_group.custom_nsg[each.value.nsg_name].name
}


resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = var.custom_security_group

  subnet_id                 = data.azurerm_subnet.subnet["${each.value.target_subnet_name}-${each.value.target_subnet_vnet_name}"].id
  network_security_group_id = azurerm_network_security_group.custom_nsg[each.key].id
}



resource "azurerm_network_watcher_flow_log" "network_watcher_flow_log" {
  for_each = var.custom_security_group

  network_watcher_name = var.flow_logs.network_watcher_name
  resource_group_name  = var.flow_logs.network_watcher_rg
  name                 = "${var.prefix}-${each.key}-flow-log"

  network_security_group_id = azurerm_network_security_group.custom_nsg[each.key].id
  storage_account_id        = var.flow_logs.storage_account_id
  enabled                   = each.value.watcher_enabled

  retention_policy {
    enabled = true
    days    = var.flow_logs.retention_days
  }

  traffic_analytics {
    enabled               = each.value.watcher_enabled
    workspace_id          = data.azurerm_log_analytics_workspace.analytics_workspace.workspace_id
    workspace_region      = data.azurerm_log_analytics_workspace.analytics_workspace.location
    workspace_resource_id = data.azurerm_log_analytics_workspace.analytics_workspace.id
    interval_in_minutes   = var.flow_logs.traffic_analytics_law_interval_minutes
  }

}
