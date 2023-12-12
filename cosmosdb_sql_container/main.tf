resource "azurerm_cosmosdb_sql_container" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name

  account_name       = var.account_name
  database_name      = var.database_name
  partition_key_path = var.partition_key_path
  throughput         = var.throughput
  default_ttl        = var.default_ttl

  dynamic "unique_key" {
    for_each = var.unique_key_paths
    content {
      paths = [unique_key.value]
    }
  }

  dynamic "autoscale_settings" {
    for_each = var.autoscale_settings != null ? [var.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  # Confliction resolution policy
  conflict_resolution_polic = {
    mode                          = var.conflict_resolution_policy.mode
    conflict_resolution_path      = var.conflict_resolution_policy.mode == "LastWriterWins" ? var.conflict_resolution_policy.path : null
    conflict_resolution_procedure = var.conflict_resolution_policy.mode == "Custom" ? var.conflict_resolution_policy.procedure : null
  }

}
