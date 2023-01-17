resource "azurerm_cosmosdb_mongo_collection" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name

  account_name  = var.cosmosdb_mongo_account_name
  database_name = var.cosmosdb_mongo_database_name

  default_ttl_seconds    = var.default_ttl_seconds
  analytical_storage_ttl = var.analytical_storage_ttl

  shard_key  = var.shard_key
  throughput = var.throughput

  dynamic "index" {
    for_each = var.indexes
    iterator = index
    content {
      keys   = index.value.keys
      unique = index.value.unique
    }
  }

  lifecycle {
    ignore_changes = [
      # ignore changes to autoscale_settings due to this operation is done manually
      autoscale_settings,
    ]
  }

  dynamic "autoscale_settings" {
    for_each = var.max_throughput == null ? [] : ["dummy"]
    content {
      max_throughput = var.max_throughput
    }
  }

  timeouts {
    create = var.timeout_create
    update = var.timeout_update
    read   = var.timeout_read
    delete = var.timeout_delete
  }

}

resource "azurerm_management_lock" "this" {
  count      = var.lock_enable ? 1 : 0
  name       = format("mongodb-collection-%s-lock", azurerm_cosmosdb_mongo_collection.this.name)
  scope      = azurerm_cosmosdb_mongo_collection.this.id
  lock_level = "CanNotDelete"
  notes      = "This items can't be deleted in this subscription!"
}
