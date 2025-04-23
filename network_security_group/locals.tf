locals {
  # Define the target services and their respective port ranges and protocols
  target_services = {
    postgresql = {
      port_ranges = ["5432", "6432"]
      protocol    = "tcp"
    }
    redis = {
      port_ranges = ["6379"]
      protocol    = "tcp"
    }
    cosmos = {
      port_ranges = ["443", "10255", "10256"]
      protocol    = "tcp"
    }
    eventhub = {
      port_ranges = ["5671-5672", "443", "9093"]
      protocol    = "tcp"
    }
    storage = {
      port_ranges = ["443"]
      protocol    = "tcp"
    }
  }



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
        # user defined inbound rules
        for rule in nsg.inbound_rules : {
          name               = rule.name
          priority           = rule.priority
          access             = rule.access
          protocol           = rule.target_service != null ? title(local.target_services[rule.target_service].protocol) : rule.protocol
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

          destination_port_ranges = rule.target_service != null ? local.target_services[rule.target_service].port_ranges : (contains(rule.destination_port_ranges, "*") ? null : rule.destination_port_ranges)
          destination_port_range  = rule.target_service != null ? null : (contains(rule.destination_port_ranges, "*") ? "*" : null)

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
      ])
    ],
    [
      for key, nsg in var.custom_security_group :
      concat([
        # user defined outbound rules
        for rule in nsg.outbound_rules :
        {
          name                    = rule.name
          priority                = rule.priority
          access                  = rule.access
          protocol                = rule.target_service != null ? title(local.target_services[rule.target_service].protocol) : rule.protocol
          source_port_ranges      = contains(rule.source_port_ranges, "*") ? null : rule.source_port_ranges
          source_port_range       = contains(rule.source_port_ranges, "*") ? "*" : null
          destination_port_ranges = rule.target_service != null ? local.target_services[rule.target_service].port_ranges : (contains(rule.destination_port_ranges, "*") ? null : rule.destination_port_ranges)
          destination_port_range  = rule.target_service != null ? null : (contains(rule.destination_port_ranges, "*") ? "*" : null)


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

          nsg_name  = key
          direction = "Outbound"
        }
      ])
    ]
    )
  )
}
