resource "azurerm_redis_cache" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  shard_count                   = var.shard_count
  enable_non_ssl_port           = var.enable_non_ssl_port
  minimum_tls_version           = "1.2"
  subnet_id                     = var.subnet_id
  private_static_ip_address     = var.private_static_ip_address
  family                        = var.family
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled
  redis_version                 = var.redis_version

  redis_configuration {
    enable_authentication         = var.enable_authentication
    rdb_backup_enabled            = var.backup_configuration != null
    rdb_backup_frequency          = var.backup_configuration != null ? var.backup_configuration.frequency : null
    rdb_backup_max_snapshot_count = var.backup_configuration != null ? var.backup_configuration.max_snapshot_count : null
    rdb_storage_connection_string = var.backup_configuration != null ? var.backup_configuration.storage_connection_string : null
  }

  dynamic "patch_schedule" {
    for_each = var.patch_schedules
    iterator = schedule
    content {
      day_of_week    = schedule.value.day_of_week
      start_hour_utc = schedule.value.start_hour_utc
    }
  }

  tags = var.tags

  # NOTE: There's a bug in the Redis API where the original storage connection string isn't being returned,
  # which is being tracked here [https://github.com/Azure/azure-rest-api-specs/issues/3037].
  # In the interim we use the ignore_changes attribute to ignore changes to this field.
  lifecycle {
    ignore_changes = [redis_configuration[0].rdb_storage_connection_string]
  }
}

resource "azurerm_private_endpoint" "this" {
  count = var.private_endpoint.enabled ? 1 : 0

  name                = "${azurerm_redis_cache.this.name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_dns_zone_group {
    name                 = "${azurerm_redis_cache.this.name}-private-dns-zone-group"
    private_dns_zone_ids = var.private_endpoint.private_dns_zone_ids
  }

  private_service_connection {
    name                           = "${azurerm_redis_cache.this.name}-private-service-connection"
    private_connection_resource_id = azurerm_redis_cache.this.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  tags = var.tags
}
