locals {
  default_nsg = {
    my-postgres-nsg = {
      type = "postgres" //libreria di type predefiniti per servizi più usati, 443, cosmos, eventhub, redis

      source_subnet_name = "my-subnet"
      source_subnet_vnet_name = "my-vnet"

      destination_subnet_name = "my-subnet"
      destination_subnet_vnet_name = "my-vnet"

    }
  }


  nsg = {
    my-aks-nsg = {
      inbound_rules = [
        {
          name                       = "my-inbound-1"
          priority                   = 100
          access                     = "Allow"
          protocol                   = "*"

          source_subnet_name = "my-subnet"
          source_subnet_vnet_name = "my-vnet"

          destination_subnet_name = "my-subnet"
          destination_subnet_vnet_name = "my-vnet"

          source_port_ranges = []
          destination_port_ranges = ["80"]

          source_application_security_group_ids = []
          destination_application_security_group_ids = []
        }
      ]

      outbound_rules = [
        {
          name                       = "my-outbound-1"
          priority                   = 100
          access                     = "Allow"
          protocol                   = "*"

          source_subnet_name = "my-subnet"
          source_subnet_vnet_name = "my-vnet"

          destination_subnet_name = "my-subnet"
          destination_subnet_vnet_name = "my-vnet"

          source_port_ranges = []
          destination_port_ranges = ["80"]

          source_application_security_group_ids = []
          destination_application_security_group_ids = []

        }
      ]

    }
  }
}


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
        name = subnet
        vnet_name = vnet.name
        rg_name = vnet.resource_group_name
      }
    ]
  ])
}

data "azurerm_subnet" "subnet" {
  for_each = { for subnet in local.subnet_names : "${subnet.name}-${subnet.vnet_name}" => subnet }

  name                = each.value.name
  virtual_network_name = each.value.vnet_name
  resource_group_name = each.value.rg_name
}


resource "azurerm_network_security_group" "custom_nsg" {
  for_each = var.custom_security_group

  name                = "${var.prefix}-${each.key}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "security_rule" {
    for_each = each.value.inbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_ranges         = security_rule.value.source_port_ranges
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefix      = data.azurerm_subnet.subnet["${security_rule.value.source_subnet_name}-${security_rule.value.source_subnet_vnet_name}"].address_prefixes
      destination_address_prefix = data.azurerm_subnet.subnet["${security_rule.value.destination_subnet_name}-${security_rule.value.destination_subnet_vnet_name}"].address_prefixes
    }
  }

  dynamic "security_rule" {
    for_each = each.value.outbound_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Outbound"
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_ranges         = security_rule.value.source_port_ranges
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefix      = data.azurerm_subnet.subnet["${security_rule.value.source_subnet_name}-${security_rule.value.source_subnet_vnet_name}"].address_prefixes
      destination_address_prefix = data.azurerm_subnet.subnet["${security_rule.value.destination_subnet_name}-${security_rule.value.destination_subnet_vnet_name}"].address_prefixes
    }
  }


  tags                = var.tags

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
