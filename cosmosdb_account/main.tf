resource "azurerm_cosmosdb_account" "this" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  offer_type                = var.offer_type
  kind                      = var.kind
  enable_free_tier          = var.enable_free_tier
  enable_automatic_failover = var.enable_automatic_failover
  key_vault_key_id          = var.key_vault_key_id

  mongo_server_version = var.mongo_server_version

  geo_location {
    location          = var.main_geo_location_location
    failover_priority = 0
    zone_redundant    = var.main_geo_location_zone_redundant
  }

  dynamic "geo_location" {
    for_each = var.additional_geo_locations

    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }

  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = var.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = var.consistency_policy.max_staleness_prefix
  }

  dynamic "capabilities" {
    for_each = var.capabilities

    content {
      name = capabilities.value
    }
  }

  public_network_access_enabled = var.public_network_access_enabled

  // Virtual network settings
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled

  dynamic "virtual_network_rule" {
    for_each = var.allowed_virtual_network_subnet_ids
    iterator = subnet_id

    content {
      id = subnet_id.value
    }
  }

  dynamic "backup" {
    for_each = var.backup_continuous_enabled ? ["dummy"] : []
    content {
      type = "Continuous"
    }
  }

  dynamic "backup" {
    for_each = var.backup_periodic_enabled != null ? ["dummy"] : []

    content {
      type                = "Periodic"
      interval_in_minutes = var.backup_periodic_enabled.interval_in_minutes
      retention_in_hours  = var.backup_periodic_enabled.retention_in_hours
      storage_redundancy  = var.backup_periodic_enabled.storage_redundancy
    }
  }

  // IP filtering
  ip_range_filter = var.ip_range

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

#
# Private endpoints
#
resource "azurerm_private_endpoint" "sql" {
  count = var.private_endpoint_enabled && length(var.capabilities) == 0 ? 1 : 0

  name                = coalesce(var.private_endpoint_name, var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = coalesce(var.private_endpoint_name, format("%s-private-endpoint", var.name))
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? ["dummy"] : []
    content {
      name                 = "private-dns-zone-group"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}

resource "azurerm_private_endpoint" "mongo" {
  count = var.private_endpoint_enabled && contains(var.capabilities, "EnableMongo") ? 1 : 0

  name                = coalesce(var.private_endpoint_name, format("%s-private-endpoint", var.name))
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = coalesce(var.private_endpoint_name, format("%s-private-endpoint", var.name))
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["MongoDB"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? ["dummy"] : []
    content {
      name                 = "private-dns-zone-group"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}

resource "azurerm_private_endpoint" "cassandra" {
  count = var.private_endpoint_enabled && contains(var.capabilities, "EnableCassandra") ? 1 : 0

  name                = coalesce(var.private_endpoint_name, var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = coalesce(var.private_endpoint_name, format("%s-private-endpoint", var.name))
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["Cassandra"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? ["dummy"] : []
    content {
      name                 = "private-dns-zone-group"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}

#
# Locks
#
resource "azurerm_management_lock" "this" {
  count      = var.lock_enable ? 1 : 0
  name       = format("%s-lock", azurerm_cosmosdb_account.this.name)
  scope      = azurerm_cosmosdb_account.this.id
  lock_level = "CanNotDelete"
  notes      = "This items can't be deleted in this subscription!"
}
