data "azurerm_virtual_network" "vnet" {
  for_each = { for vnet in var.vnets : vnet.name => vnet }

  name                = each.value.name
  resource_group_name = each.value.rg_name
}


locals {
  subnet_names = flatten([
    for vnet in data.azurerm_virtual_network.vnet :
    [
      for subnet in vnet.subnets :
      {
        name      = subnet
        vnet_name = vnet.name
        rg_name   = vnet.resource_group_name
      }
    ]
  ])

  security_rules = flatten(concat(
    [
      for key, nsg in var.custom_security_group :
      concat([
        for rule in nsg.inbound_rules :
        {
          name               = rule.name
          priority           = rule.priority
          access             = rule.access
          protocol           = rule.protocol
          source_port_ranges = contains(rule.source_port_ranges, "*") ? null : rule.source_port_ranges
          source_port_range  = contains(rule.source_port_ranges, "*") ? "*" : null

          # Defines the source address prefixes for security rule:
          # - If source_address_prefixes list is empty:
          #   - Use subnet's address prefixes from source subnet
          # - If source_address_prefixes contains elements:
          #   - If all prefixes are numeric (no letters), use them as is
          #     - If any prefix contains letters/asterisk:
          #       - Use "*" if present in the list
          #   - Otherwise use the first prefix
          source_address_prefixes = length(rule.source_address_prefixes) == 0 ? data.azurerm_subnet.subnet["${rule.source_subnet_name}-${rule.source_subnet_vnet_name}"].address_prefixes : (alltrue([for p in rule.source_address_prefixes : (length(regexall("[A-Za-z\\*]", p)) == 0)]) ? rule.source_address_prefixes : null)
          source_address_prefix   = length(rule.source_address_prefixes) > 0 && (anytrue([for p in rule.source_address_prefixes : (length(regexall("[A-Za-z\\*]", p)) > 0)])) ? (contains(rule.source_address_prefixes, "*") ? "*" : rule.source_address_prefixes[0]) : null

          source_application_security_group_ids = rule.source_application_security_group_ids
          destination_port_ranges               = contains(rule.destination_port_ranges, "*") ? null : rule.destination_port_ranges
          destination_port_range                = contains(rule.destination_port_ranges, "*") ? "*" : null

          # Defines the destination address prefixes for security rule:
          # - If destination_address_prefixes list is empty:
          #   - Use subnet's address prefixes from target subnet
          # - If destination_address_prefixes contains elements:
          #   - If all prefixes are numeric (no letters), use them as is
          #   - If any prefix contains letters/asterisk:
          #     - Use "*" if present in the list
          #     - Otherwise use the first prefix
          destination_address_prefixes = length(rule.destination_address_prefixes) == 0 ? data.azurerm_subnet.subnet["${nsg.target_subnet_name}-${nsg.target_subnet_vnet_name}"].address_prefixes : (alltrue([for p in rule.destination_address_prefixes : (length(regexall("[A-Za-z]", p)) == 0)]) ? rule.destination_address_prefixes : null)
          destination_address_prefix   = length(rule.destination_address_prefixes) > 0 && (anytrue([for p in rule.destination_address_prefixes : (length(regexall("[A-Za-z\\*]", p)) > 0)])) ? (contains(rule.destination_address_prefixes, "*") ? "*" : rule.destination_address_prefixes[0]) : null


          nsg_name  = key
          direction = "Inbound"
        }
      ], nsg.deny_everything_else_inbound ? [{
          name                         = "DenyAllInbound"
          priority                     = 4096
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_range            = "*"
          source_port_ranges           = []
          source_address_prefix        = "*"
          source_address_prefixes      = []
          destination_port_range       = "*"
          destination_port_ranges      = []
          destination_address_prefix   = "*"
          destination_address_prefixes = []
        nsg_name  = key
      }] : [])
    ],
    [
      for key, nsg in var.custom_security_group :
      concat([
        for rule in nsg.outbound_rules :
        {
          name                    = rule.name
          priority                = rule.priority
          access                  = rule.access
          protocol                = rule.protocol
          source_port_ranges      = contains(rule.source_port_ranges, "*") ? null : rule.source_port_ranges
          source_port_range       = contains(rule.source_port_ranges, "*") ? "*" : null
          destination_port_ranges = contains(rule.destination_port_ranges, "*") ? null : rule.destination_port_ranges
          destination_port_range  = contains(rule.destination_port_ranges, "*") ? "*" : null

          # Defines the source address prefixes for outbound security rule:
          # - If source_address_prefixes list is empty:
          #   - Use subnet's address prefixes from target subnet
          # - If source_address_prefixes contains elements:
          #   - If all prefixes are numeric (no letters), use them as is
          #     - If any prefix contains letters/asterisk:
          #       - Use "*" if present in the list
          #     - Otherwise use the first prefix
          source_address_prefixes = length(rule.source_address_prefixes) == 0 ? data.azurerm_subnet.subnet["${nsg.target_subnet_name}-${nsg.target_subnet_vnet_name}"].address_prefixes : (alltrue([for p in rule.destination_address_prefixes : (length(regexall("[A-Za-z]", p)) == 0)]) ? rule.destination_address_prefixes : null)
          source_address_prefix   = length(rule.source_address_prefixes) > 0 && (anytrue([for p in rule.source_address_prefixes : (length(regexall("[A-Za-z\\*]", p)) > 0)])) ? (contains(rule.source_address_prefixes, "*") ? "*" : rule.source_address_prefixes[0]) : null


          # Defines the destination address prefix for the security rule:
          # - If destination_address_prefixes list has elements and contains letters/asterisk:
          # - Use "*" if present in the list
          # - Otherwise use the first element of the list
          # - If no elements or no letters/asterisks are found, set to null
          destination_address_prefixes = length(rule.destination_address_prefixes) == 0 ? data.azurerm_subnet.subnet["${rule.destination_subnet_name}-${rule.destination_subnet_vnet_name}"].address_prefixes : (alltrue([for p in rule.destination_address_prefixes : (regex("[A-Za-z\\*]", p) == null)]) ? rule.destination_address_prefixes : null)
          destination_address_prefix   = length(rule.destination_address_prefixes) > 0 && (anytrue([for p in rule.destination_address_prefixes : (length(regexall("[A-Za-z\\*]", p)) > 0)])) ? (contains(rule.destination_address_prefixes, "*") ? "*" : rule.destination_address_prefixes[0]) : null

          destination_application_security_group_ids = rule.destination_application_security_group_ids
          nsg_name                                   = key
          direction                                  = "Outbound"
        }
      ], nsg.deny_everything_else_outbound ? [{
          name                         = "DenyAllOutbound"
          priority                     = 4096
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_range            = "*"
          source_port_ranges           = []
          source_address_prefix        = "*"
          source_address_prefixes      = []
          destination_port_range       = "*"
          destination_port_ranges      = []
          destination_address_prefix   = "*"
          destination_address_prefixes = []
        nsg_name  = key
      }] : [])
    ]
    )
  )
}

data "azurerm_subnet" "subnet" {
  for_each = { for subnet in local.subnet_names : "${subnet.name}-${subnet.vnet_name}" => subnet }

  name                 = each.value.name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg_name
}

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


# todo
# azurerm_subnet_network_security_group_association


# resource "azurerm_network_watcher_flow_log" "test" {
#   network_watcher_name = azurerm_network_watcher.test.name
#   resource_group_name  = azurerm_resource_group.example.name
#   name                 = "example-log"
#
#   target_resource_id = azurerm_network_security_group.test.id
#   storage_account_id = azurerm_storage_account.test.id
#   enabled            = true
#
#   retention_policy {
#     enabled = true
#     days    = 7
#   }
#
#   traffic_analytics {
#     enabled               = true
#     workspace_id          = azurerm_log_analytics_workspace.test.workspace_id
#     workspace_region      = azurerm_log_analytics_workspace.test.location
#     workspace_resource_id = azurerm_log_analytics_workspace.test.id
#     interval_in_minutes   = 10
#   }
# }
