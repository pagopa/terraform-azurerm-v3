resource "azurerm_cosmosdb_sql_container" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name

  account_name       = var.account_name
  database_name      = var.database_name
  partition_key_path = var.partition_key_path
  throughput         = var.throughput
  default_ttl        = var.default_ttl

  dynamic "indexing_policy" {
    for_each = var.indexing_policy == null ? [] : [var.indexing_policy]
    # including indexing policy, if defined
    content {
      # including "indexing mode" by variable
      indexing_mode = var.indexing_policy.indexing_mode
      # including list of "included path", if present
      dynamic "included_path" {
        for_each = var.indexing_policy.included_paths
        iterator = path
        content {
          path = path.value
        }
      }
      # including list of "excluded path", if present
      dynamic "excluded_path" {
        for_each = var.indexing_policy.excluded_paths
        iterator = path
        content {
          path = path.value
        }
      }
      # including list of "composite index", if present
      dynamic "composite_index" {
        for_each = var.indexing_policy.composite_indexes
        iterator = single_composite_index
        content {
          # include path component on each single composite index
          dynamic "index" {
            for_each = single_composite_index.value
            iterator = single_index
            content {
              order = single_index.value.order
              path  = single_index.value.path
            }
          }
        }
      }
    }
  }

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

  conflict_resolution_policy {
    mode = var.conflict_resolution_policy.mode
    conflict_resolution_path = var.conflict_resolution_policy.mode == "LastWriterWins" ? var.conflict_resolution_policy.path : null
    conflict_resolution_procedure = var.conflict_resolution_policy.mode == "Custom" ? var.conflict_resolution_policy.procedure : null
  }

}
