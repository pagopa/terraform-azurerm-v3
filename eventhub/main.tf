locals {
  consumers = { for hc in flatten([for h in var.eventhubs :
    [for c in h.consumers : {
      hub  = h.name
      name = c
  }]]) : format("%s.%s", hc.hub, hc.name) => hc }

  keys = { for hk in flatten([for h in var.eventhubs :
    [for k in h.keys : {
      hub = h.name
      key = k
  }]]) : format("%s.%s", hk.hub, hk.key.name) => hk }

  hubs = { for h in var.eventhubs : h.name => h }
}

resource "azurerm_eventhub_namespace" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.capacity
  auto_inflate_enabled          = var.auto_inflate_enabled
  maximum_throughput_units      = var.auto_inflate_enabled ? var.maximum_throughput_units : null
  zone_redundant                = var.zone_redundant
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version

  dynamic "network_rulesets" {
    for_each = var.network_rulesets
    content {
      default_action = network_rulesets.value["default_action"]
      # virtual_network_rule {} # optional one ore more
      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value["virtual_network_rule"]
        content {
          subnet_id                                       = virtual_network_rule.value["subnet_id"]
          ignore_missing_virtual_network_service_endpoint = virtual_network_rule.value["ignore_missing_virtual_network_service_endpoint"]
        }
      }
      dynamic "ip_rule" {
        for_each = network_rulesets.value["ip_rule"]
        content {
          ip_mask = ip_rule.value["ip_mask"]
          action  = ip_rule.value["action"]
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_eventhub" "events" {
  for_each = local.hubs

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
  partition_count     = each.value.partitions
  message_retention   = each.value.message_retention
}

resource "azurerm_eventhub_consumer_group" "events" {
  for_each = local.consumers

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = each.value.hub
  resource_group_name = var.resource_group_name
  user_metadata       = "terraform"

  depends_on = [azurerm_eventhub.events]
}

resource "azurerm_eventhub_authorization_rule" "events" {
  for_each = local.keys

  name                = each.value.key.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = each.value.hub
  resource_group_name = var.resource_group_name

  listen = each.value.key.listen
  send   = each.value.key.send
  manage = each.value.key.manage

  depends_on = [azurerm_eventhub.events]
}

# Create a Private DNS zone only if one isn't provided as input
resource "azurerm_private_dns_zone" "eventhub" {
  count = (var.sku != "Basic" && length(var.private_dns_zones.id) == 0) ? 1 : 0

  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "eventhub" {
  count = (var.sku != "Basic" && length(var.private_dns_zones.id) == 0) ? length(var.virtual_network_ids) : 0

  name                  = format("%s-private-dns-zone-link-%02d", var.name, count.index + 1)
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.eventhub[0].name
  virtual_network_id    = var.virtual_network_ids[count.index]

  tags = var.tags
}

resource "azurerm_private_endpoint" "eventhub" {
  count = var.sku != "Basic" ? 1 : 0

  name                = format("%s-private-endpoint", var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name = format("%s-private-dns-zone-group", var.name)
    # One of the concatenated arrays is empty
    private_dns_zone_ids = concat(var.private_dns_zones.id, azurerm_private_dns_zone.eventhub.*.id)
  }

  private_service_connection {
    name                           = format("%s-private-service-connection", var.name)
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
}

resource "azurerm_private_dns_a_record" "private_dns_a_record_eventhub" {
  count = (var.sku != "Basic" && var.private_dns_zone_record_A_name != null) ? 1 : 0

  name                = var.private_dns_zone_record_A_name
  zone_name           = length(var.private_dns_zones.id) > 0 ? var.private_dns_zones.name[0] : azurerm_private_dns_zone.eventhub[0].name
  resource_group_name = var.private_dns_zone_resource_group != null ? var.private_dns_zone_resource_group : var.resource_group_name
  ttl                 = 300
  records             = azurerm_private_endpoint.eventhub[0].private_service_connection.*.private_ip_address
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each = var.metric_alerts

  name                = format("%s-%s", azurerm_eventhub_namespace.this.name, upper(each.key))
  description         = each.value.description
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_eventhub_namespace.this.id]
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  enabled             = var.alerts_enabled

  dynamic "action" {
    for_each = var.action
    content {
      # action_group_id - (required) is a type of string
      action_group_id = action.value["action_group_id"]
      # webhook_properties - (optional) is a type of map of string
      webhook_properties = action.value["webhook_properties"]
    }
  }

  criteria {
    aggregation      = each.value.aggregation
    metric_namespace = "microsoft.eventhub/namespaces"
    metric_name      = each.value.metric_name
    operator         = each.value.operator
    threshold        = each.value.threshold

    dynamic "dimension" {
      for_each = each.value.dimension
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }
}
