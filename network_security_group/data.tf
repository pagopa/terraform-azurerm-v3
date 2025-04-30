data "azurerm_virtual_network" "vnet" {
  for_each = { for vnet in var.vnets : vnet.name => vnet }

  name                = each.value.name
  resource_group_name = each.value.rg_name
}

data "azurerm_subnet" "subnet" {
  for_each = { for subnet in local.subnet_names : "${subnet.name}-${subnet.vnet_name}" => subnet }

  name                 = each.value.name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg_name
}


data "azurerm_log_analytics_workspace" "analytics_workspace" {
  name                = var.flow_logs.traffic_analytics_law_name
  resource_group_name = var.flow_logs.traffic_analytics_law_rg
}
